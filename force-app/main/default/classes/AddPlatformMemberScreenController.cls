public with sharing class AddPlatformMemberScreenController {
  @AuraEnabled(cacheable=true)
  public static UtilDTO.DualListDTO getObjectDetails() {
    UtilDTO.DualListDTO dualDTO = new UtilDTO.DualListDTO();
    try {
      dualDTO.selectedOption = new List<String>();
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
}
