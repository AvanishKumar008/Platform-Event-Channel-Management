public with sharing class AddPlatformMemberScreenController {
  @AuraEnabled(cacheable=true)
  public static UtilDTO.DualListDTO getInitialDetails(String recordId) {
    UtilDTO.DualListDTO dualDTO = new UtilDTO.DualListDTO();
    try {
      dualDTO.customChannel = CustomChannelService.getCustomChannel(new List<String>{recordId})[0];
      dualDTO.selectedOption = getSelectedObjectsFromRecord(recordId);
      dualDTO.options = getCDCEnabledObjects();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    return dualDTO;
  }

  // Method to get optionDTO of CDC enabled Objects
  private static List<UtilDTO.OptionDTO> getCDCEnabledObjects() {
    List<UtilDTO.OptionDTO> objectOptions = new List<UtilDTO.OptionDTO>();
    for (Schema.SObjectType obj : filterCDCEnabledObjects().values()) {
      // Get the object describe to show label
      Schema.DescribeSObjectResult describe = obj.getDescribe();
      String optionValue = describe.getName();
      String optionLabel =
        describe.getLabel() +
        ' (' +
        describe.getName() +
        ')';
      objectOptions.add(new UtilDTO.OptionDTO(optionLabel, optionValue));
    }
    objectOptions.sort();
    return objectOptions;
  }

  private static Map<String, Schema.SObjectType> filterCDCEnabledObjects() {
    Map<String, Schema.SObjectType> cdcObjects = new Map<String, Schema.SObjectType>();

    // Get all global describe
    Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

    // Iterate through all objects
    for (String objName : globalDescribe.keySet()) {
      // Check if the object name ends with 'ChangeEvent'
      if (objName.toLowerCase().endsWith('changeevent')) {
        // Remove 'ChangeEvent' suffix to get the original object name
        String originalObjName = objName.toLowerCase()
          .replace('__changeevent', '__c')
          .removeEnd('changeevent');
        cdcObjects.put(originalObjName, globalDescribe.get(originalObjName));
      }
    }

    return cdcObjects;
  }

  private static List<String> getSelectedObjectsFromRecord(String recordId) {
    List<String> selectedObjects = new List<String>();
    for (Channel_Member__c cMember : [
      SELECT
        Id,
        Enriched_Fields__c,
        Filter_Expression__c,
        Object_API_Name__c
      FROM Channel_Member__c
      WHERE Custom_Channel__c = :recordId AND Add_to_Channel__c = true WITH SECURITY_ENFORCED
    ]) {
      selectedObjects.add(cMember.Object_API_Name__c);
    }
    return selectedObjects;
  }

  @AuraEnabled
  public static void createAndRemoveChannelMember(Custom_Channel__c customChannel, List<String> memberToBeAdded, List<String> memberToBeRemoved){
    try {
      List<Channel_Member__c> membersToBeUpsert = new List<Channel_Member__c>();
      for (String objName : memberToBeAdded) {
        membersToBeUpsert.add(new Channel_Member__c(
          Custom_Channel__c = customChannel.Id,
          Object_API_Name__c = objName,
          Member_Name__c = generateChannelMemberFullName(objName, customChannel.Channel_Name__c),
          Add_to_Channel__c = true,
          Status__c = 'Pending'
        ));
      }
      for (String objName : memberToBeRemoved) {
        membersToBeUpsert.add(new Channel_Member__c(
          Member_Name__c = generateChannelMemberFullName(objName, customChannel.Channel_Name__c),
          Add_to_Channel__c = false,
          Error_Details__c = null,
          Status__c = 'Pending'
        ));
      }
      upsert membersToBeUpsert Member_Name__c;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static String generateChannelMemberFullName(String objName, String channelFullName){
    String memberFullName = channelFullName.replace('__chn', '_chn');

    objName = objName.trim();
    memberFullName += '_' + (objName.endsWith('__c') ? objName.replace('__c', '_ChangeEvent') : objName + 'ChangeEvent');

    return memberFullName;
  }
}