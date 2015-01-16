trigger Account_trigger_vod on Account bulk (before delete, after delete) {
            
    VOD_ERROR_MSG_BUNDLE bundle = new VOD_ERROR_MSG_BUNDLE();
    Map <Id,Account> accMap = null;
    if (Trigger.isBefore) { 
        accMap = new Map <Id,Account> ([Select Id, 
                                                (Select Id from Call2_vod__r 
                                                     where Status_vod__c != 'Planned_vod'),
                                                (Select Id from Address_vod__r),
                                                (Select Id From TSF_vod__r),
                                                (Select Id From Affiliation_vod__r),
                                                (Select Id From Affiliation_vod1__r),
                                                (Select Id From Affiliation_vod__pr),
                                                (Select Id From Affiliation_vod1__pr),
                                                (Select Id From Pricing_Rules_vod__r),
                                                (select Id, Child_Account_vod__c from Parent_Account_vod__r),
                                                (select Id, Parent_Account_vod__c from Child_Account_vod__r),
                                                (Select Id From R00NT0000000lj9mMAA__r) // Account_Territory_Loader_vod__c
                                        from Account where ID in :Trigger.old]);             
        VOD_ACCOUNT_TRIG.setDeleteMap (accMap);
    } else {
        accMap =  VOD_ACCOUNT_TRIG.getDeleteMap();                                                 
        Set<Id> TSFList = new Set<Id> ();
        Set<Id> AddressList = new Set<Id> ();
        Set<Id> AffiliationList = new Set<Id> ();
        Set<Id> PriceList = new Set<Id> ();
        Map<String, Child_Account_vod__c> ChildToUpd = new Map<String, Child_Account_vod__c>(); 
        List<Child_Account_vod__c> ChildToDel =  new List<Child_Account_vod__c> (); 
        List<Affiliation_vod__c> affiliationToDel = new List<Affiliation_vod__c> ();
        Set<String> externIds = new Set<String> ();
        String extern;
        Map<Id, String> losingAtlWinningAccountList = new Map<Id, String>();
        for (Id id : accMap.keySet()) {
            Account acct = accMap.get(id);  
            Id masterRecordId = Trigger.oldMap.get(id).masterRecordId;
            if (masterRecordId != null) {
                System.debug ('Adding Master Record ' + masterRecordId);
                for (Address_vod__c primAdd : acct.Address_vod__r) {
                    AddressList.add(primAdd.Id);
                }
                            
                for (Affiliation_vod__c afilRec : acct.Affiliation_vod__r) {
                    AffiliationList.add(afilRec.Id);
                }
                            
                for (Affiliation_vod__c afilRec : acct.Affiliation_vod1__r) {
                    AffiliationList.add(afilRec.Id);
                }
                for (Affiliation_vod__c afilRec : acct.Affiliation_vod__pr) {
                    AffiliationList.add(afilRec.Id);
                }
                for (Affiliation_vod__c afilRec : acct.Affiliation_vod1__pr) {
                    AffiliationList.add(afilRec.Id);
                }
                            
                for (TSF_vod__c tsfRec : acct.Tsf_vod__r) {
                    TSFList.add(tsfRec.Id);
                }
                            
                for (Pricing_Rule_vod__c prc: acct.Pricing_Rules_vod__r) {
                    PriceList.add(prc.Id);
                }
                for (Child_Account_vod__c child: acct.Parent_Account_vod__r) {
                    if (masterRecordId == child.Child_Account_vod__c)
                       ChildToDel.add(new Child_Account_vod__c(Id = child.Id));
                    else {
                        extern = masterRecordId + '__' + child.Child_Account_vod__c;
                        if (externIds.contains(extern))
                            ChildToDel.add(new Child_Account_vod__c(Id = child.Id));
                        else {
                            ChildToUpd.put(extern, new Child_Account_vod__c(Id = child.Id, External_Id_vod__c = ''));
                            externIds.add(extern);
                        }
                    }
                }
                for (Child_Account_vod__c child: acct.Child_Account_vod__r) {
                    if (child.Parent_Account_vod__c == masterRecordId)
                       ChildToDel.add(new Child_Account_vod__c(Id = child.Id));
                    else {
                        extern = child.Parent_Account_vod__c + '__' + masterRecordId;
                        if (externIds.contains(extern))
                            ChildToDel.add(new Child_Account_vod__c(Id = child.Id));
                        else {
                            ChildToUpd.put(extern, new Child_Account_vod__c(Id = child.Id, External_Id_vod__c = ''));
                            externIds.add(extern);
                        }
                    }
                }
                for (Account_Territory_Loader_vod__c tmpAtl : acct.R00NT0000000lj9mMAA__r) {
                	// if for some reason there are multiple ATL records, should really only be 1
                	losingAtlWinningAccountList.put(tmpAtl.Id, masterRecordId);
                }
            }
            else {
                if (acct.Call2_vod__r.size() > 0) {
                    Trigger.oldMap.get(acct.Id).addError(bundle.getErrorMsg('NO_DEL_ACCOUNT'), false);
                }
                else {
                    for (Child_Account_vod__c child: acct.Child_Account_vod__r) 
                        ChildToDel.add(new Child_Account_vod__c(Id = child.Id));
                        
                    for (Affiliation_vod__c afilRec : acct.Affiliation_vod__r) {
                        affiliationToDel.add(new Affiliation_vod__c(Id = afilRec.Id));
                    }
   
                    for (Affiliation_vod__c afilRec : acct.Affiliation_vod__pr) {
                        affiliationToDel.add(new Affiliation_vod__c(Id = afilRec.Id));
                    }
                    
                }
            }
        }
        
        if (externIds.size() > 0)
            for (Child_Account_vod__c child : [select External_Id_vod__c from Child_Account_vod__c where External_Id_vod__c in :externIds]){
                Child_Account_vod__c toRemove = ChildToUpd.remove(child.External_Id_vod__c);
                ChildToDel.add(new Child_Account_vod__c(Id = toRemove.Id));
            }
        
        VOD_Utils.setUpdateAccount(true);
        VOD_Utils.setisMergeAccountProcess(true);
        try {
            delete ChildToDel;
            update ChildToUpd.values();
        } finally {
            VOD_Utils.setUpdateAccount(false);  
            VOD_Utils.setisMergeAccountProcess(false);
        }    
        
        delete affiliationToDel;
            
        // condition check here to reduce the number of @future method invocation
        if ('false'.equalsIgnorecase (System.Label.DISABLE_VEEVA_MERGE_vod) && 
            (TSFList.size() > 0 || AddressList.size() > 0 || AffiliationList.size() > 0 
                || PriceList.size() > 0 || losingAtlWinningAccountList.size() > 0))
            VEEVA_Merge.ProcessAccountMerge(TSFList, AddressList,AffiliationList,PriceList, losingAtlWinningAccountList);
    }
                    
}