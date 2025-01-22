public class CustomChannelService {
    
    //Check Channel Exist or not
    public static String isChannelExist(String chnName){
        String query = 'SELECT Id,fullname FROM PlatformEventChannel where developerName=\''+chnName+'\'';
        
        RestService callout = new RestService(Constant.baseURL + Constant.toolingQueryURL + query.replace(' ', '+'))
            .setHeaders(Constant.defaultHeaders)
            .setTimeout(60000);
        String response = callout.get().getBody();
        Map<string,object> fileInfos = (Map<string,object>) JSON.deserializeUntyped(response);
        if(fileInfos.containsKey('records')) {
            List < Object > stIds= (List < Object > ) fileInfos.get('records');
            
            for (Object objLabel: stIds) {
                Map < String, Object > label = (Map < String, Object > ) objLabel;
                if(label.get('Id') !=null){
                    return String.valueof(label.get('Id'));
                }else{
                    return null;
                }  
            }
        }
        return null; 
    }
    
    //Create Custom Channel
    public static void createCustomchannel(Custom_Channel__c customChannel){
        RestService callout = new RestService(Constant.baseURL + Constant.toolingsObjectURL +'PlatformEventChannel')
            .setHeaders(Constant.defaultHeaders)
            .setTimeout(60000);
        
        Map<string,object> innerType= new Map<string,object>();
        innerType.put('channelType', customChannel.Channel_Type__c);
        innerType.put('label',customChannel.Name);
        Map<string,object> channelBody = new Map<string,object>();
        // parmeter channel name
        channelBody.put('FullName',customChannel.Channel_Name__c);
        channelBody.put('Metadata',innerType);
        
        String response = callout.post(channelBody).getBody();
        Map<string,object> fileInfos = (Map<string,object>) JSON.deserializeUntyped(response);
        
        if(fileInfos.containsKey('id')) {
            String channelId = String.valueof(fileInfos.get('id'));
            update new Custom_Channel__c(Id = customChannel.Id, Channel_Id__c = channelId);
        }
    }
    
    public static List<Custom_Channel__c> getCustomChannel(List<String> channelIds){
        return [SELECT Id, Name, Channel_Name__c, Channel_Type__c, Channel_Id__c
                From Custom_Channel__c Where Id IN :channelIds];
    }
}