global with sharing class UpdateLocalProductBatch  implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //查询需要接收消息的队列或者主题配置，可以先写成配置数据，这里先用Account代替
        String query = 'select id,Ext_ID__c from LocalProduct__c';
        return Database.getQueryLocator(query);
    }

/**
*  @method: STY-13807 : execute
*  @description: this method will process the queried records
*  @param: Database.BatchableContext BC, List<Account> scope
*  @return: void
*/  
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
            if(null == scope || scope.isEmpty()){
                return;
            }  
            String fileName = 'Name';
            List<LocalProduct__c> localProducts = (List<LocalProduct__c>)scope;
            ORDMDMScript.syncLocalProducts(fileName,localProducts);
            
    }
    
    global void finish(Database.BatchableContext BC) {

    }

}