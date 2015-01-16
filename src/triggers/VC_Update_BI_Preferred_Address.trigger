trigger VC_Update_BI_Preferred_Address on Address_vod__c (after delete, before insert, before update) {

    
    if (TriggerRecursionHelper.hasBiPreferredTriggerStarted())
        return;
    
    TriggerRecursionHelper.setBiPreferredTriggerStarted();




     //FIRST CASE DELETE
    Set<Id> add4acc2recalculate= new Set<Id>();
    List<Address_vod__c> adds2update = new List<Address_vod__c>();
    //check on deletes to flag preferred as primary
    if(Trigger.isDelete){
        for(Address_vod__c ad: Trigger.old){
            if(ad.BI_Preferred_Address_BI__c){
                add4acc2recalculate.add(ad.Account_vod__c);
            }   
        }
        if(!add4acc2recalculate.isEmpty())
        adds2update = [Select Id, BI_Preferred_Address_BI__c from Address_vod__c where Account_vod__c IN : add4acc2recalculate];

    }

    Set<Id> excludedAddresses = Trigger.newMap.keySet();
    //SECOND CASE
    IF(Trigger.isInsert || Trigger.isUpdate){
        for(Address_vod__c ad: Trigger.new){
            if (ad.Primary_vod__c && (Trigger.isInsert || ad.Primary_vod__c != Trigger.oldMap.get(ad.Id).Primary_vod__c)) {
                add4acc2recalculate.add(ad.Account_vod__c);
            }
        }

        if(!add4acc2recalculate.isEmpty())
        adds2update = [Select Id, BI_Preferred_Address_BI__c,Primary_vod__c from Address_vod__c where Account_vod__c IN :add4acc2recalculate AND (NOT Id IN: excludedAddresses)];
    }


    

    for(Address_vod__c ad: adds2update){
        ad.BI_Preferred_Address_BI__c= ad.Primary_vod__c;
    }
    if(!add4acc2recalculate.isEmpty())
            update adds2update; //can be checked and create a list only if changes in primary and preferred 


}