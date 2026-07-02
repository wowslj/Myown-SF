public with sharing class LwcStudyOrderList {

    @AuraEnabled
    public static String OrderList(){
        // 查询所有salesOrder
        List<Sales_Order__c> OrderList = [SELECT 
        Id,
        Name,
        Order_Type__c,
        Price__c,
        Approval_Status__c
        FROM Sales_Order__c ];   
        String str = JSON.serialize(OrderList);
        return str;
    }

    @AuraEnabled
    public static String OrderSerch(String name,String type,String price,String approvalStatus){
        String querySql = 'select Id,Name,Order_Type__c,Price__c,Approval_Status__c from Sales_Order__c';
        String queryFitler = '';
       if(String.isNotBlank(name)){
           String nameStr = '%'+name+'%';
           queryFitler += ' and Name like :nameStr'; 
       }
       if(String.isNotBlank(type)){
        queryFitler += ' and Order_Type__c =:type';
       }
       if(String.isNotBlank(price)){       
        Decimal price2 = Decimal.valueOf(price);
        queryFitler += ' and Price__c =:price2';
       }
       if(String.isNotBlank(approvalStatus)){
        queryFitler += ' and Approval_Status__c =:approvalStatus';
       }
       if(String.isNotBlank(queryFitler)){
           querySql += ' WHERE ' + queryFitler.removeStart(' and ');
       }
       System.debug(querySql);
       List<Sales_Order__c> OrderList = Database.Query(querySql);
       System.debug(OrderList);
       String str = JSON.serialize(OrderList);
        return str;
    }
}