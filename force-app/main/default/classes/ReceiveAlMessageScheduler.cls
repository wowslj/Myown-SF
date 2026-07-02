global without sharing class ReceiveAlMessageScheduler implements Schedulable{
    global void execute(SchedulableContext ctx){
        AuzreServiceMessageBatch batch = new AuzreServiceMessageBatch();
        database.executebatch(batch,1);
     }
}