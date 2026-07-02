/**********************************************************************
 *
 *
 * @url: /services/apexrest/CCM_RestService_DealQualifierInfo
 * @data:[{
 "QUALIFIER_ORACLE_ID": "003",
  "MODIFIER_NUMBER": "MO000001",
 "MODIFIER_LINE_NUMBER": "11",
 "QUALIFIER_GROUP": "12",
 "QUALIFIER_CONTEXT": "CUSTOMER",
 "QUALIFIER_ATTRIBUTE": "Customer Name",
 "VALUE_FROM": "ceshiFrom",
 "VALUE_TO": "CeshiTo",
 "START_DATE": "2018-01-01",
 "END_DATE": "2018-01-02",
 "UNION_BATCH": "001",
 "TOTAL_NUM": "10",
 "ATTRIBUTE1": "",
 "ATTRIBUTE2": ""
 }]
 *
 *************************************************************************/
@RestResource(urlMapping = '/product/add')
global with sharing class HttpApiCase2{
    @HttpPost
    global static List<LogItem> doPost(){
        //获取请求体数据
        RestRequest req = RestContext.request;
        List<ReqestObj> reqObjList = new List<ReqestObj>();
        String resStr = req.requestBody.toString();
        List<LogItem> logItems = new List<LogItem>();
        System.debug('*** req.requestBody.toString(): ' + req.requestBody.toString());
        if (!resStr.startsWith('[')){
            resStr = '[' + resStr + ']';
        }
        reqObjList = parse(resStr);
        System.debug('*** req.requestBody(): ' + reqObjList);
        
        //根据客户名称获取关联的客户id
        Map<String,String> accountNameAndIdMap = new Map<String,String>();
        if (reqObjList != null && reqObjList.size() > 0){
            Set<String> accountNameSet = new Set<String>();
            for(ReqestObj reqObj : reqObjList){
                if(reqObj.ACCOUNT_NAME != null){
                    accountNameSet.add(reqObj.ACCOUNT_NAME);
                }
            }
            List<Account> accounts = new List<Account>();
            System.debug('*** start to querry account---->' + accountNameAndIdMap);
            accounts = [select id,name from Account where name in:accountNameSet];
            System.debug('*** querry account result:---> ' + accounts);
            
            if(accounts.size()>0){
                for(Account acc:accounts){
                    accountNameAndIdMap.put(acc.name,String.valueOf(acc.id));
                }               
            }
            
            List<Product2> insertProducts = new List<Product2>();
            for (ReqestObj reqObj : reqObjList){
                Product2 product = new Product2();
                if(reqObj.PRODUCT_NAME == null){
                    saveLog(false,'PRODUCT_NAME is empty','PRODUCT_NAME must be valued');
                    continue;
                }
                if(reqObj.RECORD_TYPE == null){
                    saveLog(false,'RECORD_TYPE is empty','RECORD_TYPE must be valued');
                    continue;
                }
                product.Name = String.isNotBlank(reqObj.PRODUCT_NAME)?String.valueOf(reqObj.PRODUCT_NAME):null;
                product.Brand__c = String.isNotBlank(reqObj.BRAND)?String.valueOf(reqObj.BRAND):null;
                product.Description__c = String.isNotBlank(reqObj.DESCRIPTION)?String.valueOf(reqObj.DESCRIPTION):null;
                product.Product_Status__c = String.isNotBlank(reqObj.PRODUCT_STATUS)?String.valueOf(reqObj.PRODUCT_STATUS):null;
                String recordType = reqObj.RECORD_TYPE;
                Id recordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
                product.RecordTypeId = recordTypeId;
                //获取recordTypeId
                
                if(reqObj.ACCOUNT_NAME != null && accountNameAndIdMap.containsKey(reqObj.ACCOUNT_NAME)){
                    product.Account__c = (ID)accountNameAndIdMap.get(reqObj.ACCOUNT_NAME);
                }
                insertProducts.add(product);
            }
            Database.SaveResult[] resList = Database.insert(insertProducts,false);
            System.debug('return result----->'+resList);
            //保存日志
            
            for (Integer i = 0; i < resList.size(); i++){
                LogItem logitem = new LogItem();
                if (!resList.get(i).isSuccess()){
                    //保存失败
                    Database.Error[] err = resList.get(i).getErrors();
                    logitem.Status = 'Fail';
                    logitem.ErrorMessage = 'This Qualifier was failed saving in Salesforce';
                    logitem.ErrorDetail = '***The following error has occurred***' + err.get(0).getStatusCode() + ' : ' + err.get(0).getMessage();
                }else {
                    //保存成功
                    logitem.Status = 'Success';
                }
                logItems.add(logitem);
            }
            saveLogs(logItems);
        
        //     System.debug(LoggingLevel.INFO, '*** : ' + JSON.serialize(resObj));
        // } else{
        //     resObj.Process_Status = 'Fail';
        //     ReturnItem empty = new ReturnItem();
        //     empty.Error_Message = 'Empty JSON';
        //     empty.Error_Detail = 'Empty JSON';
        //     resObj.Process_Result.add(empty);

        //     String logId = Util.logIntegration('Qualifier Exception', 'CCM_RestService_DealQualifiertInfo', 'POST', JSON.serialize(resObj.Process_Result), resStr, JSON.serialize(resObj));
        //     Util.pushExceptionEmail('Accept Qualifier Info', logId, getMailErrorMessage(resObj));
        // }
        // } catch (Exception e){

        //     resObj.Process_Status = 'Fail';

        //     ReturnItem request = new ReturnItem();

        //     request.Error_Message = 'This Qualifier was failed saving in Salesforce';

        //     request.Error_Detail = '*** e.getMessage(): ' + e.getLineNumber() + ' line e.getMessage(): ' + e.getMessage();

        //     resObj.Process_Result.add(request);

        //     System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getLineNumber() + ' line e.getMessage(): ' + e.getMessage());

        //     String logId = Util.logIntegration('Qualifier Exception', 'CCM_RestService_DealQualifierInfo', 'POST', JSON.serialize(resObj.Process_Result), resStr, JSON.serialize(resObj));

        //     Util.pushExceptionEmail('Accept Qualifier Info', logId, getMailErrorMessage(resObj));

        //     return resObj;

        // }
        // System.debug(LoggingLevel.INFO, '*** resObj: ' + resObj);
    }
    return logItems;
}

global class ReqestObj{
        global String PRODUCT_NAME;

        global String BRAND;

        global String DESCRIPTION;

        global String PRODUCT_STATUS;    

        global String ACCOUNT_NAME;

        global String RECORD_TYPE;

    }


global static List<ReqestObj> parse(String jsonStr){
        return (List<ReqestObj>)JSON.deserialize(jsonStr, List<ReqestObj>.class);
    }

global class LogItem{
        global String Status;

        global String ErrorMessage;

        global String ErrorDetail;

    }
global static void saveLogs(List<LogItem> logItems){
        if(logItems != null && logItems.size() > 0){
            List<Log__c> logs = new List<Log__c>();
            Log__c log;
            for(LogItem item:logItems){
                log = new Log__c();
                log.Process_Status__c = item.Status;
                if(item.Status == 'Fail'){
                    log.Error_Message__c = item.ErrorMessage;
                    log.Error_Detail__c = item.ErrorDetail;
                }
                logs.add(log);
            }
            Database.insert(logs,false);
        }  
    }
global static void saveLog(boolean success,String errorMeaasge,String errorDetail){
        List<LogItem> logItems = new List<LogItem>();
        LogItem item = new LogItem();
        if(success){
            item.Status = 'Success';
            logItems.add(item);
        }else {
            if(!String.isBlank(errorMeaasge) && !String.isBlank(errorDetail)){
                if(String.isBlank(errorMeaasge)){
                    errorMeaasge = errorDetail;
                }
                if(String.isBlank(errorDetail)){
                    errorDetail = errorDetail;
                }
                item.Status = 'Fail';
                item.ErrorDetail = errorDetail;
                item.ErrorMessage = errorMeaasge;
        }
        logItems.add(item);
        if(logItems.size()>0){
            saveLogs(logItems);
        }             
        }      
    }

}