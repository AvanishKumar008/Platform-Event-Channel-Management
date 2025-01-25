public class CustomChannelService {
  //Check Channel Exist or not
  public static String isChannelExist(String chnName) {
    String query =
      'SELECT Id,fullname FROM PlatformEventChannel where developerName=\'' +
      chnName +
      '\'';

    RestService callout = new RestService(
        Constant.baseURL + Constant.toolingQueryURL + query.replace(' ', '+')
      )
      .setHeaders(Constant.defaultHeaders)
      .setTimeout(60000);
    String response = callout.get().getBody();
    Map<string, object> fileInfos = (Map<string, object>) JSON.deserializeUntyped(
      response
    );
    if (fileInfos.containsKey('records')) {
      List<Object> stIds = (List<Object>) fileInfos.get('records');

      for (Object objLabel : stIds) {
        Map<String, Object> label = (Map<String, Object>) objLabel;
        if (label.get('Id') != null) {
          return String.valueof(label.get('Id'));
        } else {
          return null;
        }
      }
    }
    return null;
  }

  //Create Custom Channel
  public static String createCustomchannel(Custom_Channel__c customChannel) {
    RestService callout = new RestService(
        Constant.baseURL + Constant.toolingsObjectURL + 'PlatformEventChannel'
      )
      .setHeaders(Constant.defaultHeaders)
      .setTimeout(60000);

    Map<string, object> innerType = new Map<string, object>();
    innerType.put('channelType', customChannel.Type__c);
    innerType.put('label', customChannel.Name);
    Map<string, object> channelBody = new Map<string, object>();
    // parmeter channel name
    channelBody.put('FullName', customChannel.Channel_Name__c);
    channelBody.put('Metadata', innerType);

    String response = callout.post(channelBody).getBody();
    System.debug(response);
    Map<string, object> fileInfos = (Map<string, object>) JSON.deserializeUntyped(
      response
    );
System.debug(fileInfos);
    String channelId;
    if (fileInfos.containsKey('id')) {
      channelId = String.valueof(fileInfos.get('id'));
    }
    return channelId;
  }

  public static List<Custom_Channel__c> getCustomChannel(
    List<String> channelIds
  ) {
    return [
      SELECT Id, Name, Channel_Name__c, Type__c, Channel_Id__c
      FROM Custom_Channel__c
      WHERE Id IN :channelIds
    ];
  }
}
