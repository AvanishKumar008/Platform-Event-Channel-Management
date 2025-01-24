public class ChannelMemberService {
  //Fetch the Platform Member ID for the update
  public static String getPlatfromMemberId(Channel_Member__c channelMember) {
    String entityName = '';
    String objName = channelMember.Object_API_Name__c.trim();
    if (objName.endsWith('__c')) {
      entityName = objName.replace('__c', '__ChangeEvent');
    } else {
      entityName = objName + 'ChangeEvent';
    }

    String query =
      'SELECT Id,SelectedEntity FROM PlatformEventChannelMember WHERE' +
      '(SelectedEntity=\'' +
      entityName +
      '\' AND EventChannel=\'' +
      channelMember.Custom_Channel__r.Channel_Id__c +
      '\') OR Id = \'' +
      channelMember.Member_Id__c +
      '\'';

    RestService callout = new RestService(
        Constant.baseURL + Constant.toolingQueryURL + query.replace(' ', '+')
      )
      .setHeaders(Constant.defaultHeaders)
      .setTimeout(60000);
    String response = callout.get().getBody();
    return response;
  }

  public static void createCustomChannelMember(
    Channel_Member__c channelMember
  ) {
    RestService callout = new RestService(
        Constant.baseURL +
          Constant.toolingsObjectURL +
          'PlatformEventChannelMember'
      )
      .setHeaders(Constant.defaultHeaders)
      .setTimeout(60000);

    String response = callout.post(setupobject(channelMember)).getBody();
  }

  public static void updateCustomChannelMember(
    Channel_Member__c channelMember
  ) {
    String entityId = getPlatfromMemberId(channelMember);
    if (entityId != null) {
      RestService callout = new RestService(
          Constant.baseURL +
            Constant.toolingsObjectURL +
            'PlatformEventChannelMember/' +
            entityId
        )
        .setHeaders(Constant.defaultHeaders)
        .setTimeout(60000);

      String response = callout.patch(setupobject(channelMember)).getBody();
    } else {
      createCustomChannelMember(channelMember);
    }
  }

  public static void deleteCustomChannelMember(
    Channel_Member__c channelMember
  ) {
    String entityId = getPlatfromMemberId(channelMember);
    if (entityId != null) {
      RestService callout = new RestService(
          Constant.baseURL +
            Constant.toolingsObjectURL +
            'PlatformEventChannelMember/' +
            entityId
        )
        .setHeaders(Constant.defaultHeaders)
        .setTimeout(60000);

      String response = callout.del().getBody();
    }
  }

  public static List<Channel_Member__c> getChannelMember(
    List<String> channelMemberIds
  ) {
    return [
      SELECT
        Id,
        Enriched_Fields__c,
        Filter_Expression__c,
        Object_Name__c,
        Object_API_Name__c,
        Member_Id__c,
        Custom_Channel__r.Channel_Id__c
      FROM Channel_Member__c
      WHERE Id IN :channelMemberIds
    ];
  }

  public static ChannelMemberDTO setupobject(Channel_Member__c channelMember) {
    ChannelMemberDTO cmDTO = new ChannelMemberDTO();
    ChannelMemberDTO.Metadata cmwMetadata = new ChannelMemberDTO.Metadata();

    list<ChannelMemberDTO.enrichedFields> enrichedFieldslist = new List<ChannelMemberDTO.enrichedFields>();

    if (String.isNotBlank(channelMember.Enriched_Fields__c)) {
      for (string fld : channelMember.Enriched_Fields__c.trim().split(',')) {
        ChannelMemberDTO.enrichedFields enRichfields = new ChannelMemberDTO.enrichedFields();
        enRichfields.name = fld.trim();
        enrichedFieldslist.add(enRichfields);
      }
    }

    cmwMetadata.enrichedFields = enrichedFieldslist;
    if (String.isNotBlank(channelMember.Filter_Expression__c)) {
      cmwMetadata.filterExpression = channelMember.Filter_Expression__c.trim();
    }
    // parameter channel name
    cmwMetadata.eventChannel =
      channelMember.Custom_Channel__r.Channel_Name__c + '__chn';
    String objName = channelMember.Object_API_Name__c.trim();
    if (objName.endsWith('__c')) {
      cmwMetadata.selectedEntity = objName.replace('__c', '__ChangeEvent');
    } else {
      cmwMetadata.selectedEntity = objName + 'ChangeEvent';
    }
    cmDTO.fullname =
      channelMember.Custom_Channel__r.Channel_Name__c +
      '_chn_' +
      cmwMetadata.selectedEntity;
    cmDTO.Metadata = cmwMetadata;
    return cmDTO;
  }
}
