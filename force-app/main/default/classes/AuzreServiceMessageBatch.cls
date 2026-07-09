global class AuzreServiceMessageBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{

    global static Boolean hasMessageRemain = true;
    global static Integer count = 1;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        //查询需要接收消息的队列或者主题配置，可以先写成配置数据，这里先用Account代替查询
        String query = 'select id,Source_Type__c from AL_Message_Setting__c limit 150';
        return Database.getQueryLocator(query);
    }

/**
*  @method: STY-13807 : execute
*  @description: this method will process the queried records
*  @param: Database.BatchableContext BC, List<Account> scope
*  @return: void
*/
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
            // if(null == scope || scope.isEmpty()){
            //     return;
            // }

            // for (AL_Message_Setting__c item : (List<AL_Message_Setting__c>)scope) {
            //     Integer sourceType = Integer.valueOf(item.Source_Type__c);
            //     List<String> messages = AzureDataFactory.receiveAllMessageFromQueue2(null,100,sourceType);
            //     if(null != messages && !messages.isEmpty()){
            //         for(String message:messages){
            //             // AzureDataFactory.saveMessageToObj(message, null,sourceType);
            //         }
            //     }
            // }


    }

    global void finish(Database.BatchableContext BC) {

    }

}
