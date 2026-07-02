public class EmailAndNotification{
    
    @InvocableMethod
    public static void SendEmail(List<String> productIds){
        productIds=productIds[0].split(',');
        try{
            List<EmailTemplate> lstEmailTemplate = new List<EmailTemplate>();
            lstEmailTemplate = [select e.Id,e.Name,Subject,Body,HtmlValue from EmailTemplate e where Name='Product Active'];
            if(lstEmailTemplate!=null&& lstEmailTemplate.size()>0){
                String templateId =lstEmailTemplate[0].Id;
            	List<String> lstReceiptEmail = new List<String>();
                List<Product2> lstProduct=[
                    select Id,Account__c,Name,ProductCode,Account__r.Name,Account__r.AccountNumber,Account__r.OwnerId,Account__r.Owner.Email from Product2 where Id IN : productIds
                ];
                System.debug(lstProduct);
                lstReceiptEmail.add('478407250@qq.com');
               	List<Messaging.SingleEmailMessage> lstemails =new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject(lstEmailTemplate[0].Subject);
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                baseUrl += '/'+lstProduct[0].Account__c;
                String strBody=lstEmailTemplate[0].HtmlValue;
                strBody = strBody.replace('{Account Name}',lstProduct[0].Account__r.Name);
                strBody = strBody.replace('{Account Number}',lstProduct[0].Account__r.AccountNumber);
                strBody = strBody.replace('{Product Name}',lstProduct[0].Name);
                strBody = strBody.replace('{Product Code}',lstProduct[0].ProductCode);
                strBody = strBody.replace('{Link}',baseUrl);
                
                
                email.setTargetObjectId(UserInfo.getUserId());
                System.debug(UserInfo.getUserId());
                email.setHtmlBody(strBody);
                email.SetToAddresses(lstReceiptEmail);
                email.setSaveAsActivity(false);
                lstemails.add(email);
                SendNotification(lstProduct[0].Account__c);
            Messaging.SendEmailResult[] results=Messaging.sendEmail(lstemails);
                     
            }}
        
        catch(Exception e){
            e.getMessage();
        }
    }
    
    public static void SendNotification(String objectId){
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        Account acc = [select Name from Account where Id = :objectId];
        notification.setTitle(UserInfo.getName()+'is Update the'+acc.Name+'of ProDuct');
        notification.setBody(acc.Name);
        CustomNotificationType objNotificationType = [select Id from CustomNotificationType where DeveloperName='Product_Active'];
        notification.setNotificationTypeId(objNotificationType.Id);
        notification.setTargetId(objectId);
        List<String> lstUserId = new List<String>();
        List<User> lstUser = [select Id,IsActive,Email from User where IsActive = True];
        Set<String> setSendIds = new Set<String>();
        for(User objUser : lstUser){
            setSendIds.add(objUser.Id);
        }
        notification.send(setSendIds);
         System.debug('发送成功');
    }
}