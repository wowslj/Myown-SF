trigger AccountUpdateEventTrigger on Account_Update__e (after insert) {
    List<Account> UpdateAccList = new List<Account>();
    Set<String> accIdSet = new Set<String>();
    for(Account_Update__e accEvent:Trigger.new){
        accIdSet.add(accEvent.Account_Id__C);
    }
    UpdateAccList = [Select Id,Name From Account where id in:accIdSet];
    if(!UpdateAccList.isEmpty()){
        for(Account acc:UpdateAccList){
            acc.Event_Str_Apex__c = 'from apex event str';
        }
        update UpdateAccList;
    }
}