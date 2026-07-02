@RestResource(urlMapping = '/api/v1.0/test/*')
global with sharing class TestRestApiController {
    

    // @HttpGet
    // global static String receiveMessage(){
    //     RestRequest rest = RestContext.request;
    //     String body = rest.params.get('body');
    //     if(null == body || String.isBlank(body)){
    //         System.debug('--------------------收到的消息为空---------------------');
    //         return 'no message';
    //     }else{
    //         my_Test_Obj1__c testObj = new my_Test_Obj1__c();
    //         testObj.OwnerId = UserInfo.getUserId();
    //         testObj.MessageBody__c = body;
    //         testObj.name = 'test receive name';
    //         insert testObj;
    //         System.debug('--------------------收到消息,body: '+body);
    //     }
    //     //收到消息之后的处理逻辑  TODO
    //     return 'message body = '+body;
    // }

    
    @HttpPost
    global static String receiveMessage(String body){
        // RestRequest rest = RestContext.request;
        // String body = rest.params.get('body');
        if(null == body || String.isBlank(body)){
            System.debug('--------------------收到的消息为空---------------------');
            return 'no message';
        }else{
            my_Test_Obj1__c testObj = new my_Test_Obj1__c();
            testObj.OwnerId = UserInfo.getUserId();
            testObj.MessageBody__c = body;
            testObj.name = 'test receive name';
            insert testObj;
            System.debug('--------------------收到消息,body: '+body);
        }
        //收到消息之后的处理逻辑  TODO
        return 'message body = '+body;
    }
}