trigger VOD_ACCOUNT_TO_TERRITORY_AFTER_TRIGGER on Account_Territory_Loader_vod__c (after insert,after update) {
                
            // find out accounts that need ATL processing,
            // and determine to use async call or not
            Set<Id> acctIds = new Set<Id> ();  
            List<Account_Territory_Loader_vod__c> acctLoaders = new List<Account_Territory_Loader_vod__c>();
            boolean useAsync = false;
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                if (Trigger.new[i].Account_vod__c == null)
                    continue;
                acctIds.add(Trigger.new[i].Account_vod__c);
                
                String terr_vod = Trigger.new[i].Territory_vod__c;              
                if (terr_vod == null || terr_vod.length() == 0)
                    continue; 
                                                              
                acctLoaders.add(Trigger.new[i]);
                               
                // determine to use async call or not           
               if (!useAsync && terr_vod.split(';').size() > 100) 
                    useAsync = true; 
            }                
            
            // If we dont have any changes stop here and return; 
            if (acctIds.size() == 0)  
                return;
            
            // #4442 ATL: Async trigger if any atl rows > 100 
            if (useAsync == false) {
                VOD_ProcessATL.processATL(acctLoaders, acctIds);
            }
            else {
                String xmldoc = VOD_ProcessATL_Asyn.write(acctLoaders);
                VOD_ProcessATL_Asyn.processATL(xmldoc, acctIds);
            } 
        }