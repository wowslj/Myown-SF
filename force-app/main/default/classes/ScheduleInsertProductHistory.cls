global with sharing class ScheduleInsertProductHistory implements Schedulable{
    global void execute(SchedulableContext sc) {
        ScheduleBatchTest batch = new ScheduleBatchTest();
        Database.executeBatch(batch,1000);
    }
}