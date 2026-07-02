global with sharing class ScheduleBatchTest implements Database.Batchable<SObject>,Database.Stateful{
    
    private List<Product2> allProducts = new List<Product2>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        //查询所有INACT的products aaa
        String str = 'INACT';
        String queryString = 'select id,Name,ProductCode,Product_Status__c from Product2 where Product_Status__c=:str';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC,List<Product2> scope){
        Savepoint sp = Database.setSavepoint();
       if(scope != null && scope.size()>0){
        allProducts.addAll(scope);
        try{
            for(Product2 it:scope){
                it.Product_Status__c = 'ACT';
            }
            update scope;
           }catch(Exception ex){
                Database.rollback(sp);
           }
       }
    }

    global void finish(Database.BatchableContext BC){
        List<Product_History__c> insertHistoryLists = new List<Product_History__c>();
        for(Product2 it:allProducts){
            Product_History__c item = new Product_History__c();
            String productCode = it.productCode;
            if(productCode == null){
                productCode = it.Name;
            }
            item.PNO__c = productCode;
            insertHistoryLists.add(item);
        }
        insert insertHistoryLists;
    }
}