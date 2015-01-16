trigger Address_before_del_vod on Address_vod__c bulk (before delete) {
            
            
            String ProfileId = UserInfo.getProfileId();
            VOD_ERROR_MSG_BUNDLE bundle = new VOD_ERROR_MSG_BUNDLE();
            Profile pr = [Select Id, PermissionsModifyAllData From Profile where Id = :ProfileId];
            boolean modAllData = false;
            if (pr != null && pr.PermissionsModifyAllData)
                modAllData = true;
        
        
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Address_vod__c.fields.getMap();
            Schema.SObjectField Lock_vod = fieldMap.get('Lock_vod__c');
            Boolean lock = false;
            if (Lock_vod != null) {
               lock = true;
            }
        
        
            
            Map <Id,Address_vod__c> addMap = new Map <Id,Address_vod__c> ([Select Id, (Select Id from Controlling_Address_vod__r), (Select Id from Call2_vod__r 
                                   where Status_vod__c = 'Submitted_vod' or Status_vod__c = 'Saved_vod') 
                                   from Address_vod__c where ID in :Trigger.old]);
                                   
                                   
            for (Integer k =0; k < Trigger.old.size(); k++) {
                boolean isError = false;
                 if (modAllData == false && 
                     Trigger.old[k].Controlling_Address_vod__c != null && 
                     VOD_ADDRESS_TRIG.getChildAccount() == false) {
                     
                        Trigger.old[k].Name.addError(bundle.getErrorMsg ('ADDRESS_DEL_LOCK_MSG'), false);
                        isError = true;
                 }
                  
                 if (modAllData == false && Trigger.old[k].DEA_Address_vod__c == true) {
                     Trigger.old[k].Name.addError(bundle.getErrorMsg ('NO_DEL_DEA_ADDRESS'), false);
                     isError = true;
                 }
                 
                 if (lock == true && modAllData == false) {
             
                     SObject obj = Trigger.old[k];
        
                     Boolean checkLock = (Boolean)obj.get('Lock_vod__c');
                     if (checkLock == true)
                         Trigger.old[k].Name.addError(bundle.getErrorMsg ('ADDRESS_DEL_LOCK_MSG'), false);
                         isError = true;
                     }
        
                if (isError == false) {
                    Address_vod__c myAddItem = addMap.get(Trigger.old[k].Id);
                    if (myAddItem != null) {
                        for (Address_vod__c myChildren : myAddItem.Controlling_Address_vod__r) {
                            VOD_ADDRESS_TRIG.addDelSet(myChildren.Id);
                        }
                    }
                }
            }
        }