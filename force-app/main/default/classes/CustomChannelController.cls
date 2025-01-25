public with sharing class CustomChannelController {
    //Map<String, String> channelProps = new Map<String, String>{'label'=>'test', 'name'=>'test', 'type'=>'Data'};
    
//CustomChannelController.createCustomChannel(channelProps);
    @AuraEnabled
    public static void createCustomChannel(Map<String, String> channelProps) {
        System.debug('channelProps ------- ');
        System.debug(channelProps);
        Custom_Channel__c channel = new Custom_Channel__c();
        channel.Name = channelProps.get('label');
        channel.Channel_Name__c = channelProps.get('name')+'__chn';
        channel.Type__c = channelProps.get('type');

        insert channel;
        createCustomChannel(channel.Id);
    }

    @future(callout=true)
    public static void createCustomChannel(String channelId) {
        Custom_Channel__c channel = CustomChannelService.getCustomChannel(new List<String>{channelId})[0];
        String platformChannelId = CustomChannelService.createCustomChannel(channel);

        if(String.isNotBlank(platformChannelId)){
            channel.Channel_Id__c = platformChannelId;
            update channel;
        }
    }
}
