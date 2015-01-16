/*
 * Created By:   Roman Lerman
 * Created Date: 7/13/2012
 * Description:  Handler for Account Before Delete event.  Handles the Account merge scenarios.
 */
global class BeforeMergeTriggerMVN implements TriggersMVN.HandlerInterface 
{
    global string name()
    {
        return 'BeforeMergeTriggerMVN';
    }
    
    global void handle() 
    {
        List<TSF_vod__c> tsfs = [select Id, Merged_MVN__c, Account_vod__c from TSF_vod__c where Account_vod__c in :Trigger.oldMap.keyset()];
        for(TSF_vod__c tsf:tsfs){
            tsf.Merged_MVN__c = true;
        }
        
        List<Account_Territory_Loader_vod__c> atls = [select Id, Merged_MVN__c from Account_Territory_Loader_vod__c 
                                                        where Account_vod__c in :Trigger.oldMap.keyset()];  
        for(Account_Territory_Loader_vod__c atl:atls){
            atl.Merged_MVN__c = true;
        }
        
        if(tsfs != null && tsfs.size() > 0){
            update tsfs;
        }
        
        if(atls != null && atls.size() > 0){
            update atls;
        }
    }
}