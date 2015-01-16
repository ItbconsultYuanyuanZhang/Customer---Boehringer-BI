public class VEEVA_Merge {

    public static boolean isAddressMerge = false;
    
    @future
    public static void ProcessAccountMerge (Set<Id> tsfIds,  Set<Id> addrIds, Set<Id> affilIds, Set<Id> prIds, Map<Id,String> losingAtlWinningAccountList) {
        
        
        if (affilIds != null) {
            
            Set<String> affDelSet = new Set<String> ();
            List <Affiliation_vod__c> AffilToUpdate = new List<Affiliation_vod__c> ();
            for (Id affilId : affilIds) {
                System.debug('VEEVADEBUG:Processing the affiliation Id =' + affilID);
                Affiliation_vod__c afil  = new Affiliation_vod__c (Id = affilId,
                                                  External_Id_vod__c = '');
                AffilToUpdate.add(afil);
              
            }            

            try {
                VOD_AFFILIATIONS.setMerge(true);
                update AffilToUpdate;
                VOD_AFFILIATIONS.setMerge(false);
            }  catch (System.DmlException e) {
                System.debug('VEEVADEBUG: Entering Error Logic');
                List <Affiliation_vod__c> AffilToDelete = new List<Affiliation_vod__c> ();
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    VOD_AFFILIATIONS.setMerge(false);
                    // Process exception here
                    Id id  = e.getDmlId(i);
                    String codered = e.getDmlStatusCode(i);
                    System.Debug('VEEVADEBUG - Affiliation error- ' + id );                           
                    if (codered  == 'DUPLICATE_VALUE' || codered == 'FIELD_CUSTOM_VALIDATION_EXCEPTION') {
                        Affiliation_vod__c ntsf = new Affiliation_vod__c (Id = id);
                        AffilToDelete.add(ntsf);
                        affDelSet.add(id);
                    } else {
                        System.Debug(codered);  
                        System.Debug('VEEVADEBUG - THROW' + e );  
                        throw e;
                    }
                }
                System.Debug('VEEVADEBUG - Executing Delete' + e );
                try {
                	delete AffilToDelete;
                } catch (System.DmlException e2) {
                	for (Integer i = 0; i < e2.getNumDml(); i++) 
                    {
	                    Id id2  = e2.getDmlId(i);
	                    System.Debug ('VEEVADEBUG - Error deleting Affiliation:' + id2 + e2.getDmlStatusCode(i));
                    }
                	
                }
                System.Debug('VEEVADEBUG - Finished Delete' + e );
                AffilToUpdate.clear();
                for (Id affilId : affilIds) {
                    if (affDelSet.contains(affilId)) {
                        System.Debug('VEEVADEBUG - Skipping Affiliation because it was a dup- ' + affilId );
                       continue;
                    }
                    
                    System.Debug('VEEVADEBUG - Adding this affilID to be updated again :  ' + affilId );
                    Affiliation_vod__c afil  = new Affiliation_vod__c (Id = affilId, External_Id_vod__c = '');
                    AffilToUpdate.add(afil);
              
                }
                
                try {
                   System.Debug('VEEVADEBUG - Affiliation - ' + AffilToUpdate );
                   VOD_AFFILIATIONS.setMerge(true);
                   update AffilToUpdate;
                   VOD_AFFILIATIONS.setMerge(false);
                }  catch (System.DmlException e2) {
                    VOD_AFFILIATIONS.setMerge(false);
                        System.Debug('VEEVADEBUG - throw e2 :  ');
              
                    throw e2;
                }            
        }          
     }  
        
        if (tsfIds != null) {
            Set<String> tsfDelSet = new Set<String> ();
            System.Debug('TSF - ' + tsfIds );
            List <TSF_vod__c> tsfToUpdate = new List<TSF_vod__c> ();
            for (Id tsfid : tsfIds) {
                TSF_vod__c tsf  = new TSF_vod__c (Id = tsfid, 
                                                  External_Id_vod__c = '');
                tsfToUpdate.add(tsf);
            }
             try {
                update tsfToUpdate;
            }  catch ( System.DmlException e) {
                List <TSF_vod__c> tsfToDelete = new List<TSF_vod__c> ();
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Process exception here
                    Id id  = e.getDmlId(i);
                    String codered = e.getDmlStatusCode(i);
                                                
                    if (codered  == 'DUPLICATE_VALUE') {
                        TSF_vod__c ntsf = new TSF_vod__c (Id = id);
                        System.Debug('VEEVADEBUG - Delete the following TSFId- ' + id );
                        tsfToDelete.add(ntsf);
                        tsfDelSet.add(id);
                    } else {  
                        throw e;
                    }
                }
                
                try{
                delete tsfToDelete;  
                } catch (System.DmlException e2) {
                   for (Integer i = 0; i < e2.getNumDml(); i++) 
                   {
                    Id id2  = e2.getDmlId(i);
                    System.Debug ('VEEVADEBUG - Error deleting TSF:' + id2 + e2.getDmlStatusCode(i));
                    }
                }
                
                tsfToUpdate.clear();                
                
               for (Id tsfid : tsfIds) {
                    if (tsfDelSet.contains(tsfid)) {
                        System.Debug('VEEVADEBUG - Skipping TSF because it was a dup- ' + tsfid );
                       continue;
                    }
                    TSF_vod__c tsf  = new TSF_vod__c (Id = tsfid, 
                                                  External_Id_vod__c = '');
                    tsfToUpdate.add(tsf);
               }
             
               try {
                    update tsfToUpdate;
               }  catch ( System.DmlException e2) {
                    throw e2;
               } 
                     
            }
        }                  
                      
        
         if (addrIds != null) {  
            System.Debug('Address - ' + addrIds );  
            List <Address_vod__c> AddressToUpdate = new List<Address_vod__c> ();            
            for (Id addid : addrIds) {                
                Address_vod__c add  = new Address_vod__c (Id = addid,
                                                          Primary_vod__c = false);
                                                                              
               if ('ACTIVE'.equalsIgnoreCase(System.Label.ACCOUNT_ADDRESS_MERGE_BEHAVIOR) == true) {
                add.Inactive_vod__c  = false;
               } else if ('ASIS'.equalsIgnoreCase(System.Label.ACCOUNT_ADDRESS_MERGE_BEHAVIOR) == true) {
                 // do nothing
               }  else {
                    add.Inactive_vod__c  = true;
               }                                                                                                                                       
                AddressToUpdate.add(add);
            }
            
            if (AddressToUpdate.size() > 0) {
                isAddressMerge = true;
                //adding a try catch for capturing if addresses are getting updated 
                try{
                    update AddressToUpdate;
                }
                
                catch (System.DmlException e3) {
                   for (Integer i = 0; i < e3.getNumDml(); i++) 
                   {
                    Id id3  = e3.getDmlId(i);
                    System.Debug ('VEEVADEBUG - Error updating address ' + id3 + e3.getDmlStatusCode(i));
                    }
                } 
                
                isAddressMerge = false;
            }
        } 
        
        if (prIds != null) {   
            System.Debug('PricingToUpdate - ' + prIds );     
            List <Pricing_Rule_vod__c> PricingToUpdate = new List<Pricing_Rule_vod__c> ();            
            for (Id prId : prIds) {               
                Pricing_Rule_vod__c pr  = new Pricing_Rule_vod__c (Id = prId,Active_vod__c = false);
                PricingToUpdate.add(pr);
            }
            
            if (PricingToUpdate.size() > 0) {
                update PricingToUpdate;
            }
        }
        
        List<Account_Territory_Loader_vod__c> updAtls = new List<Account_Territory_Loader_vod__c>();
        List<Account_Territory_Loader_vod__c> delAtls = new List<Account_Territory_Loader_vod__c>();
        if (losingAtlWinningAccountList != null) {
        	Set<String> winningAcctIds = new Set<String>(losingAtlWinningAccountList.values());
			Set<Id> losingAtlIds = new Set<Id>(losingAtlWinningAccountList.keyset());
	        Map<Id, Account> atlData = null;
	        if (winningAcctIds.size() > 0) {
	        	atlData = new Map<Id, Account>([Select Id, (Select Id, Territory_vod__c 
	        			From R00NT0000000lj9mMAA__r) // Account_Territory_Loader_vod__c
	        			From Account  
	        			Where Id In :winningAcctIds]);
	        }
            if (atlData != null) {
	        	for (Id tmpAcctId : atlData.keyset()) {
	        		Account tmpAcctObj = atlData.get(tmpAcctId);
                    // If there is only one ATL between loser and winner, we dont need to combine territories and update/delete
                    if (tmpAcctObj.R00NT0000000lj9mMAA__r.size() > 1)  {

                        Set<String> combinedTerritoryList = new Set<String>();
                        List<Id> tmpUpdAtls = new List<Id>();

                        for (Account_Territory_Loader_vod__c tmpAtlObj : tmpAcctObj.R00NT0000000lj9mMAA__r) {
                            if (tmpAtlObj.Territory_vod__c != null) {
                                combinedTerritoryList.addAll(tmpAtlObj.Territory_vod__c.split(';'));
                            }
                            if (losingAtlIds.contains(tmpAtlObj.Id)) {
                                delAtls.add(new Account_Territory_Loader_vod__c(Id = tmpAtlObj.Id));
                            }
                            else { // in the case there are duplicates we cant resolve
                                tmpUpdAtls.add(tmpAtlObj.Id);
                            }
                        }
                        String combinedTerritoryValue = '';
                        for (String tmpTerr : combinedTerritoryList) {
                            if (tmpTerr.length() > 0) {
                                combinedTerritoryValue += ';' + tmpTerr;
                            }
                        }
                        if (combinedTerritoryValue.length() > 0) {
                            combinedTerritoryValue += ';';
                        }
                        for (Id tmpAtlId : tmpUpdAtls) {
                            updAtls.add(new Account_Territory_Loader_vod__c(Id=tmpAtlId, Territory_vod__c=combinedTerritoryValue));
                        }
                    }
	        	}
	        }
        }
        if (delAtls.size() > 0) {
        	delete delAtls;
        }
        
        if (updAtls.size() > 0) {
			try {
				update updAtls;
			}
			catch (System.DmlException e) {
				for (Integer i = 0; i < e.getNumDml(); i++) {
					Id id  = e.getDmlId(i);
					System.Debug ('VEEVADEBUG - Error updating ATL ' + id + e.getDmlStatusCode(i));
 				}
            } 
        }
    }
}