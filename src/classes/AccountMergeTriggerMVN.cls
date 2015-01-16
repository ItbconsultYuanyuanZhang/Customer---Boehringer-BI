/*
 * Created By:   Roman Lerman, Jennifer Wyher
 * Created Date: 7/13/2012
 * Description:  Handler for Account Before Delete event.  Handles the Account merge scenarios.
 *                  1.  Territories from child ATL records be concatenated into ATL of winning account
 *                  2.  Orphan ATL records get deleted
 *                  3.  TSF "YTD Activities" aggregate (prior to loser delete)
 *                  4.  TSF "Last Activity Date" updates to max of the values on the records prior to merge (prior to loser delete)
 */
global class AccountMergeTriggerMVN implements TriggersMVN.HandlerInterface 
{
    global string name()
    {
        return 'AccountMergeTriggerMVN';
    }
    
    global string createTerritoryList(Set<string> territorySet)
    {
        String territoryList = '';
        for(String terr:territorySet){
            if(terr != null){
                territoryList += terr.replaceAll(';','') + ';';
            }
        }
        
        return territoryList;
    }
    
    global void handle() 
    {   
        Set<Id> masterRecordIds = new Set<Id>();
        Set<Id> deletedAccountIds = new Set<Id>();
        for(Account deletedAccount:(List<Account>) Trigger.old){
            if(deletedAccount.MasterRecordId != null){
                masterRecordIds.add(deletedAccount.MasterRecordId);
                deletedAccountIds.add(deletedAccount.Id);
            }
        }
        
        List<Account> winningAccounts = [select Id, 
                                            (select Id, Territory_vod__c, Account_vod__c, External_Id_vod__c, Merged_MVN__c from R00NT0000000lj9mMAA__r),
                                            (select Id, YTD_Activity_vod__c, Last_Activity_Date_vod__c, Account_vod__c, Merged_MVN__c, 
                                            External_Id_vod__c, Territory_vod__c from TSF_vod__r) 
                                        from Account where Id in :masterRecordIds];                                 
        
        Map<Id, Account_Territory_Loader_vod__c> atlMapToUpdate = new Map<Id, Account_Territory_Loader_vod__c>();
        Map<String, TSF_vod__c> tsfMapToUpdate = new Map<String, TSF_vod__c>();
        
        List<Id> mergedTSFList = new List<Id>();
        List<Id> mergedATLList = new List<Id>();
        
        for(Account acct:winningAccounts){
            
            // put together all the losing ATL records
            Set<String> territorySet = new Set<String>();
            Account_Territory_Loader_vod__c winningATL = null;
            for(Account_Territory_Loader_vod__c atl:acct.R00NT0000000lj9mMAA__r){
                // if it is a losing ATL
                if(atl != null && atl.Account_vod__c == acct.Id && atl.Merged_MVN__c && atl.Territory_vod__c != null){
                    List<String> initialTerritoryList = atl.Territory_vod__c.split(';');
                    territorySet.addAll(initialTerritoryList);
                    mergedATLList.add(atl.Id); // flag for deletion
                // if it is the winning ATL
                } else if (atl != null && atl.Account_vod__c == acct.Id && !atl.Merged_MVN__c) {
                    winningATL = atl;
                    if (atl.Territory_vod__c != null) {
                        territorySet.addAll(atl.Territory_vod__c.split(';'));
                    }
                }
            }
            
            if (winningATL == null) {
                winningATL = new Account_Territory_Loader_vod__c(Account_vod__c=acct.Id);
            }
            winningATL.Territory_vod__c = createTerritoryList(territorySet);
            atlMapToUpdate.put(acct.Id, winningATL);
        
        
            Map<String,TSF_vod__c> totalTSFsMap = new Map<String, TSF_vod__c>(); // sum of the TSF records to merge
            Map<String, TSF_vod__c> winningTSFsMap = new Map<String, TSF_vod__c>(); // the winning ones to update
            for(TSF_vod__c tsf:acct.TSF_vod__r){
                if(tsf.Account_vod__c != null && tsf.Territory_vod__c != null){
                    if(tsf.YTD_Activity_vod__c == null) { tsf.YTD_Activity_vod__c = 0; }
                    
                    if (!tsf.Merged_MVN__c) {
                        winningTSFsMap.put(tsf.Account_vod__c+'__'+tsf.Territory_vod__c, tsf);
                    } else {
                        mergedTSFList.add(tsf.Id);
                    }
                    
                    if(totalTSFsMap.get(tsf.Account_vod__c+'__'+tsf.Territory_vod__c) == null){
                        totalTSFsMap.put(tsf.Account_vod__c+'__'+tsf.Territory_vod__c, tsf);
                    } else {
                        TSF_vod__c totalTSF = totalTSFsMap.get(tsf.Account_vod__c+'__'+tsf.Territory_vod__c);
                    
                        if(tsf.Last_Activity_Date_vod__c > totalTSF.Last_Activity_Date_vod__c){
                            totalTSF.Last_Activity_Date_vod__c = tsf.Last_Activity_Date_vod__c;
                        }
                         
                        totalTSF.YTD_Activity_vod__c += tsf.YTD_Activity_vod__c;
                        totalTSFsMap.put(tsf.Account_vod__c+'__'+tsf.Territory_vod__c,totalTSF);
                    }
                }
            }
            
            // update the winning records (create one if it didn't exist)
            for (String acctTerr: totalTSFsMap.keySet()) {
                TSF_vod__c tsf = totalTSFsMap.get(acctTerr);
                TSF_vod__c winningTSF = winningTSFsMap.get(acctTerr);
                if (winningTSF==null) {
                    winningTSF = new TSF_vod__c();
                    winningTSF.Account_vod__c=tsf.Account_vod__c;
                    winningTSF.Name=tsf.Territory_vod__c;
                    winningTSF.Territory_vod__c=tsf.Territory_vod__c;
                }
                winningTSF.Last_Activity_Date_vod__c = tsf.Last_Activity_Date_vod__c;
                winningTSF.YTD_Activity_vod__c = tsf.YTD_Activity_vod__c;
                
                tsfMapToUpdate.put(acctTerr, winningTSF);
            }
        }
        
        System.debug('MergedATLList: ' + mergedATLList);
        System.debug('MergedTSFList: ' + mergedTSFList);
        
        if(atlMapToUpdate != null && atlMapToUpdate.size() > 0){
            upsert atlMapToUpdate.values();
        }
        
        if(deletedAccountIds != null && deletedAccountIds.size() > 0){
            List<Account_Territory_Loader_vod__c> atlsToDelete = [select Id from Account_Territory_Loader_vod__c where External_Id_vod__c in :deletedAccountIds];   
            if(atlsToDelete != null && atlsToDelete.size() > 0){
                delete atlsToDelete;
            }                       
        }
        
        updateMergedATLAndTSFLists(mergedATLList, mergedTSFList, tsfMapToUpdate.values() != null ? JSON.serialize(tsfMapToUpdate.values()) : '');
    }
    
    @future
    global static void updateMergedATLAndTSFLists(List<Id> mergedATLList, List<Id> mergedTSFList, String tsfValues){
        List<Account_Territory_Loader_vod__c> atlList = new List<Account_Territory_Loader_vod__c>();
        List<TSF_vod__c> tsfList = new List<TSF_vod__c>();
        
        if(tsfValues != null && tsfValues != ''){
            List<TSF_vod__c> tsfValueList = (List<TSF_vod__c>) JSON.deserialize(tsfValues, List<TSF_vod__c>.class);
            List<Database.SaveResult> atlSR = Database.update(tsfValueList, false);
        }
        
        if(mergedATLList != null){
            for(Id atlId:mergedATLList){
                atlList.add(new Account_Territory_Loader_vod__c(Id = atlId, Merged_MVN__c = false));
            }
        }
        
        if(mergedTSFList != null){
            for(Id tsfId:mergedTSFList){
                tsfList.add(new TSF_vod__c(Id = tsfId, Merged_MVN__c = false));
            }
        }
        
        if(atlList != null && atlList.size() > 0){
            List<Database.SaveResult> atlSR = Database.update(atlList, false);
        }
        
        if(tsfList != null && tsfList.size() > 0){
            List<Database.SaveResult> tsfSR = Database.update(tsfList, false);
        }
    }
}