/*
 * Used to generate data for test classes. 
 * setupDataAzure can be used in the setupData method that has @testSetup. This will allow for easily creating data for 
 * various test classes. Note that @testSetup does not allow for code coverage so you still need to have separate test class
 * for that one. 
 */ 
public with sharing class AzureDataFactory {

    private static Integer SOURCEMDM_TYPE = 1;
    private static Integer CES_TYPE = 2;

    //需要保存的消息
    // private static Set<String> SAVE_EVENTYPE_MESSAGES = new Set<String>{'PartyEntityReevaluationCompleted','PartyEntitySupplementalDataChanged','PARTY VERIFICATION MODIFIED'};
    

    //CES UAT 对于SFOA UAT
    // private static final String CES_AZURE_SERVICE_BUS_CONNECTION_STRING = 'Endpoint=sb://YOUR_NAMESPACE.servicebus.windows.net/;SharedAccessKeyName=YOUR_POLICY_NAME;SharedAccessKey=YOUR_SHARED_ACCESS_KEY;EntityPath=YOUR_QUEUE_NAME';
    // static String CES_nameSpace = 'wezvmmncassb002';
    // static final String CES_defaultQueueName = 'queue-ces-sfoa';
    // static String CES_quePolicyName = 'queue-ces-sfoa-listen';
    // static String CES_quePolicKey = 'YOUR_SHARED_ACCESS_KEY';
    // static final String CES_UriPreFix = 'https://'+CES_nameSpace+'.servicebus.windows.net/';

     //SOURCE OB 对于SFOA UAT
    //  private static final String SOURCE_AZURE_SERVICE_BUS_CONNECTION_STRING = 'Endpoint=sb://YOUR_NAMESPACE.servicebus.windows.net/;SharedAccessKeyName=YOUR_POLICY_NAME;SharedAccessKey=YOUR_SHARED_ACCESS_KEY;EntityPath=YOUR_QUEUE_NAME';
    //  static final String SOURCE_nameSpace = 'wezjvtixassb001';
    //  static final String SOURCE_defaultQueueName = 'q-sourcemdm-sfoa';
    //  static String SOURCE_quePolicyName = 'q-sourcemdm-sfoa-listen';
    //  static String SOURCE_quePolicKey = 'YOUR_SHARED_ACCESS_KEY';
    //  static final String SOURCE_UriPreFix = 'https://'+SOURCE_nameSpace+'.servicebus.windows.net/';


    //部署的类：AzureDataFactory，AuzreServiceMessageBatch，AzureGenerateToken，ReceiveAlMessageScheduler
    //创建对象：AL_Message_Receive__c，AL_Message_Config__c，同时给AL_Message_Config__c添加数据接收消息
    //
    //添加remote site：Setup->Security->Remote site settings  添加：SourceMDM:https://wezjvtixassb002.servicebus.windows.net CES:https://wezvmmncassb002.servicebus.windows.net  UAT环境


    private static String getAlEndPointByName(String name,String connectString){
        List<String> strs = connectString.split(';');
        if(name.equals('nameSpace')){
            String str = strs.get(0).replace('Endpoint=sb://', '');
            return str.substring(0,str.indexOf('.'));
        }else {
            for(String str:strs){
                List<String> str1s = str.split('=');
                if(str1s.get(0).equals(name)){
                   return str.substring(str.indexOf('=')+1,str.length());
                }
            }
        }
        return '';
    }
















    public static HttpRequest buildHttpSend (Integer sourceType,String queueName){
        HttpRequest req = new HttpRequest();
        //resourceUri这里按规则拼接，根据是发送到Queue和Topic不同 在UriPreFix后追加对应的queueName和TopicName
        String resourceUri = '';
        //从Azure Service Bus的Shared access policies中取对应的policyName，一般不会改变，后期可以加入到配置数据中获得 这里先hard code
        String policyName = '';
        //同上，取对应policyName的Primary Key,后期可以加入到配置数据中获得 这里先hard code
        String policyKey = '';
        String nameSpace = '';
        String connectString = '';
        if(null != sourceType && sourceType == CES_TYPE){
            connectString = 'Endpoint=sb://YOUR_NAMESPACE.servicebus.windows.net/;SharedAccessKeyName=YOUR_POLICY_NAME;SharedAccessKey=YOUR_SHARED_ACCESS_KEY;EntityPath=YOUR_QUEUE_NAME';
            // queueName = queueName == null || queueName == ''?CES_defaultQueueName:queueName;
            // nameSpace = CES_nameSpace;
            // resourceUri = CES_UriPreFix+queueName;
            // policyName = CES_quePolicyName;
            // policyKey = CES_quePolicKey;
        }else if(null != sourceType && sourceType == SOURCEMDM_TYPE){
            connectString = 'Endpoint=sb://YOUR_NAMESPACE.servicebus.windows.net/;SharedAccessKeyName=YOUR_POLICY_NAME;SharedAccessKey=YOUR_SHARED_ACCESS_KEY;EntityPath=YOUR_QUEUE_NAME';
            // queueName = queueName == null || queueName == ''?SOURCE_defaultQueueName:queueName;
            // resourceUri = SOURCE_UriPreFix+queueName;
            // policyName = SOURCE_quePolicyName;
            // policyKey = SOURCE_quePolicKey;
            // nameSpace = SOURCE_nameSpace;
        }
            // System.debug(connectString);
            queueName = queueName == null || queueName == ''?getAlEndPointByName('EntityPath',connectString):queueName;
            // System.debug(queueName);
            nameSpace = getAlEndPointByName('nameSpace',connectString);
            // System.debug(nameSpace);
            resourceUri = 'https://'+nameSpace+'.servicebus.windows.net/'+queueName;
            // System.debug(resourceUri);
            policyName = getAlEndPointByName('SharedAccessKeyName',connectString);
            // System.debug(policyName);
            policyKey = getAlEndPointByName('SharedAccessKey',connectString);
            // System.debug(policyKey);
        String token = AzureGenerateToken.generateSasToken(resourceUri,policyName,policyKey);
        System.debug('token--->: '+token);
        req.setEndpoint(resourceUri+'/messages/head');
        req.setMethod('DELETE');
        req.setHeader('Authorization', token);
        req.setHeader('Host', nameSpace+'.servicebus.windows.net');
        req.setHeader('Content-Length', '0');
        return req;
    }




     // 从Azure Service Bus Queue接收消息   有个问题 一次调用只能消费掉一条消息 如果队列里都多条消息需要重复调用，直到消费完全
     public static String receiveMessageFromQueue(String queueName,Boolean saveMessage,Integer sourceType) {
        String messageBody = '';
        HttpRequest req = buildHttpSend(sourceType,queueName);
        
        Http http = new Http();
        HttpResponse res = http.send(req);

        // 处理响应逻辑
        if (res.getStatusCode() == 200) {
            String responseBody = res.getBody();
            if(saveMessage){
                AL_Message_Receive__c item = saveMessageToObj(responseBody,sourceType);
                if(null != item){
                    insert item;
                }
            }
            // 这里可以添加处理接收到的消息的逻辑
            messageBody = responseBody;
        }else if(res.getStatusCode() == 204){
            System.debug('no message received: ' + res.getStatusCode());
            //队列或主题中已无消息
        } else {
            System.debug('Failed to receive message. Status code: ' + res.getStatusCode());
        }
        return messageBody;
    }

    public static List<String> receiveAllMessageFromQueue(String queueName,Integer recevieNum,Integer sourceType){
        List<String> result = new List<String>();
        String message = '';
        for(Integer i=0;i<recevieNum;i++){
            message = receiveMessageFromQueue(queueName,false,sourceType);
            if(null != message && message.length() > 0){
                result.add(message);
            }else {
                break;
            }
        }
        return result;
    }

    //接受100条AL消息
    public static void receiveAndSave100EnitytUpdateMessages(String sourceTypeStr,Boolean saveMessage){
        if(null == sourceTypeStr || String.isBlank(sourceTypeStr)){
            System.debug('未指定接收消息的AL类型');
            return;
        }
        Integer sourceType = null;
        if(sourceTypeStr.equals('SourceMDM')){
           sourceType = SOURCEMDM_TYPE;
        }else if(sourceTypeStr.equals('CES')){
           sourceType = CES_TYPE;
        }
        if(null == sourceType){
           return;
        }
        List<String> messages = receiveAllMessageFromQueue(null,100,sourceType);
        if(saveMessage && !messages.isEmpty()){
            List<AL_Message_Receive__c> MessageSaveList = new List<AL_Message_Receive__c>();
            AL_Message_Receive__c item;
            for(String messageBody:messages){
                item = saveMessageToObj(messageBody,sourceType);
                if(null != item){
                    MessageSaveList.add(item);
                }
            }
            if(!MessageSaveList.isEmpty()){
                insert MessageSaveList;
            }
        }
    }


    // 发送消息到 Azure Service Bus Queue
    // public static void sendMessageToQueue(String messageBody,String queueName) {
    //     if(null == messageBody || String.isEmpty(messageBody)){
    //         return;
    //     }
    //     queueName = queueName == null?defaultQueueName:queueName;
    //     HttpRequest req = new HttpRequest();

    //     //resourceUri这里按规则拼接，根据是发送到Queue和Topic不同 在UriPreFix后追加对应的queueName和TopicName
    //     String resourceUri = UriPreFix+queueName;
    //     //从Azure Service Bus的Shared access policies中取对应的policyName，一般不会改变，后期可以加入到配置数据中获得 这里先hard code
    //     String policyName = quePolicyName;
    //     //同上，取对应policyName的Primary Key,后期可以加入到配置数据中获得 这里先hard code
    //     String policyKey = quePolicKey;
    //     //调用方法生成sasToken  用于http调用的安全验证
    //     String token = AzureGenerateToken.generateSasToken(resourceUri,policyName,policyKey);
        
    //     req.setEndpoint(resourceUri+'/messages');
    //     req.setMethod('POST');
    //     req.setHeader('Authorization', token);
    //     req.setHeader('Content-Type', 'application/json');
    //     req.setBody(messageBody);
        
    //     Http http = new Http();
    //     HttpResponse res = http.send(req);

    //     //成功返回的code是201
    //     if (res.getStatusCode() == 201) {
    //             System.debug('send message success,message=: ' + messageBody);
    //             // 这里可以添加处理消息发送成功的逻辑
    //         } else {
    //             System.debug('Failed to send message. Status code: ' + res.getStatusCode());
    //         }
    //     // 处理响应逻辑
    // }



    public static AL_Message_Receive__c saveMessageToObj(String messageBody,Integer sourceType){           
            // try{                
            //     if(null != messageBody && messageBody.length() > 0){
            //         String messageId = '';
            //         Map<String, Object> jsonDataMap = (Map<String, Object>)JSON.deserializeUntyped(messageBody);
            //         String eventType = '';
            //         String sourceTypeStr = '';
            //         if(null != sourceType && sourceType == SOURCEMDM_TYPE){
            //             Map<String, Object> messageMap = (Map<String, Object>) jsonDataMap.get('message');
            //             eventType = (String)messageMap.get('eventType');
            //             sourceTypeStr = 'SourceMDM';
            //             messageId = (String)messageMap.get('messageId');
            //         }else if(null != sourceType && sourceType == CES_TYPE){
            //             eventType = (String)jsonDataMap.get('eventType');
            //             sourceTypeStr = 'CES';
            //             messageId = (String)jsonDataMap.get('messageId');
            //         }
            //         if(String.isBlank(sourceTypeStr)){
            //             return null;
            //         }
            //         // if(!SAVE_EVENTYPE_MESSAGES.contains(eventType)){
            //         //     return null;
            //         // }
            //         AL_Message_Receive__c item = new AL_Message_Receive__c();
            //         item.Source_Type__c = sourceTypeStr;
            //         item.MessageBody__c = messageBody;
            //         item.Event_Type__c = eventType;
            //         item.Completed_Status__c = 3;//新增待处理
            //         item.Retry_Times__c = 0;//重试次数0
            //         item.messageId__c = messageId;
            //         return item;
            //     }
            // }catch(Exception e){
            //     System.debug('---解析和保存messagee失败: '+e.getMessage());
            // }
            return null;
    }

}
