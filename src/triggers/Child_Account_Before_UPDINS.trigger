trigger Child_Account_Before_UPDINS on Child_Account_vod__c (before insert, before update) {
    
    for (Child_Account_vod__c record : Trigger.new) {        
        record.External_ID_vod__c = record.Parent_Account_vod__c + '__' + record.Child_Account_vod__c;
    }
    
    VOD_SHADOW_ACCOUNT.rejectUnverifiedAccounts(
            Trigger.new, new List<String> {'Parent_Account_vod__c', 'Child_Account_vod__c'});
}