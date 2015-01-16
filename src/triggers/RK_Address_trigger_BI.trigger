/******************************************************************************
 * RK_Address_trigger_BI
 *
 * Updates the BI Preferred Address field on the address object to the primary
 * when the primary flag is set, or sets it to the primary if the address is
 * deleted.
 * 
 * That is, the BI Preferred address should be set to be the primary, however
 * it should allow the user to change it.
 * When a new primary is set, it should also be set to the preferred address.
 * If the preferred address is deleted, the primary should be set as the
 * preferred.
 * 
 * Additionally, do all the work that Address_trigger_vod trigger would also do.
 * (IMPORTANT! Code copied. See caveats.)
 *
 * CAVEAT:
 * If you remove the preferred flag from an address, no preferred
 * flag will be set against any addresses.
 *
 * You must inactivate the Address_trigger_vod trigger and activate this one.
 * 
 * IMPORTANT CAVEAT: This is designed to work with the current version of Veeva. If the version
 * is upgraded, this code may break and require modifications.
 *
 * N.B. For instructions on how to prevent trigger recursion, see:
 *  http://www.salesforce.com/docs/developer/cookbook/Content/apex_controlling_recursive_triggers.htm 
 *
 * Author: Raphael Krausz <raphael.krausz@veevasystems.com>
 * Created date: 2013-04-03
 *
 */

trigger RK_Address_trigger_BI on Address_vod__c bulk (before update, before insert) {
    public enum LicenseInfoAction { NONE, PUSH, PULL, RESET, PUSH_NULL }
    
    if (VOD_ADDRESS_TRIG.getAddressTrig() == true)
        return;
        
    //Set<Id> toProcess = new Set<Id>(Trigger.newMap.keySet());
    Set<Id> toProcess = new Set<Id>();
    for(Address_vod__c address : Trigger.new) toProcess.add(address.Id);
    toProcess.removeAll(VOD_Utils.getAddresses());
    if (toProcess.isEmpty())
        return;
    VOD_Utils.getAddresses().addAll(toProcess);
    
    Set<Id> accountsToPush = new Set<Id>();
    Set<Id> accIds = new Set<Id>();
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if (toProcess.contains(Trigger.new[i].Id))
            accIds.add(Trigger.new[i].Account_vod__c);
    }
    
    List<Address_vod__c> primAddList = new List<Address_vod__c>{};
    Map<Id, Address_vod__c> updMap = new Map<Id, Address_vod__c>();

    // Added by Raphael    
    List<Address_vod__c> prefAddList = new List<Address_vod__c>{};
    
    Map<Id,Account> accounts = null;
    Set<String> updateLicenses = new Set<String>();
    Map<Id, Address_vod__c> updLic = new Map<Id, Address_vod__c>();
    
    String isRealTime = System.Label.ENABLE_REALTIME_ADDRESS_PUSH;
    accounts = new Map<Id,Account>([
        Select Id,
            (
                Select Id,
                Account_vod__c,
                Primary_vod__c,
                License_Expiration_date_vod__c,
                License_Status_vod__c,
                License_Valid_to_Sample_vod__c,
                License_vod__c,
                State_vod__c,
                Country_vod__c,
                BI_Preferred_Address_BI__c
                From Address_vod__r
            )
        From Account Where Id In :accIds]);
    
    for (Account tempAcct : accounts.values()) {
        for (Address_vod__c tempAddr : tempAcct.Address_vod__r) {
            if (tempAddr.Primary_vod__c == true) {
                primAddList.add(tempAddr);
            }
            /* */
            if (tempAddr.BI_Preferred_Address_BI__c == true || tempAddr.Primary_vod__c == true) {
            	system.debug('Account: ' + tempAcct.id + ' - Adress: ' + tempAddr.Id);
                // Added by Raphael
                prefAddList.add(tempAddr);
            }
            /* */
        }
    }
    
    for (Integer i = Trigger.new.size() - 1 ; i >= 0 ; i--) {
        // deal with license synching
        // For US addresses, license information is shared across the state.
        // For CAN addresses, license information is shared across the entire country.
        if (!toProcess.contains(Trigger.new[i].Id))
            continue;
        System.debug ('VEEVADEBUG -' + Trigger.new[i]);
        if (VOD_ADDRESS_TRIG.isCopySetFalse(Trigger.new[i].Id) == false && VOD_ADDRESS_TRIG.getPush() == false) {
            accountsToPush.add(Trigger.new[i].Account_vod__c);  
        }
        
        String key = Trigger.new[i].Account_vod__c;
        String keyCode;
        String oldKeyCode;
        if (Trigger.new[i].Country_vod__c == 'ca') { // Canada
            keyCode = Trigger.new[i].Country_vod__c;
            if (Trigger.isUpdate)
                oldKeyCode = Trigger.old[i].Country_vod__c;
        }
        else {
            keyCode = Trigger.new[i].State_vod__c;
            if (Trigger.isUpdate)
                oldKeyCode = Trigger.old[i].State_vod__c;
        }
        key += '-' + keyCode;
        System.debug('key - ' + key);
        if (updateLicenses.contains(key) == false) {
            Account acct = accounts.get(Trigger.new[i].Account_vod__c);
            if (acct != null) {
                Boolean keyMatchFound = false;
                for (Address_vod__c addr : acct.Address_vod__r) {
                    LicenseInfoAction action = LicenseInfoAction.NONE;
                    // look for same state matches but ignore itself
                    String addrKeyCode;
                    if (Trigger.new[i].Country_vod__c == 'ca') // Canada 
                        addrKeyCode = addr.Country_vod__c;
                    else
                        addrKeyCode = addr.State_vod__c;
                    if ((addrKeyCode == keyCode) && 
                        (addr.Id != Trigger.new[i].Id)) {
                            keyMatchFound = true;
                            if (Trigger.isUpdate && (oldKeyCode != keyCode) &&
                                Trigger.old[i].License_Expiration_date_vod__c == Trigger.new[i].License_Expiration_date_vod__c &&
                                Trigger.old[i].License_Status_vod__c == Trigger.new[i].License_Status_vod__c &&
                                Trigger.old[i].License_vod__c == Trigger.new[i].License_vod__c) {
                                    System.debug('Pull license info from first matching state/country');
                                    action = LicenseInfoAction.PULL;
                                }
                            else {
                                if (Trigger.new[i].License_Valid_to_Sample_vod__c == 'Valid') {
                                    System.debug('Push valid license info to other same-state/country addresses');
                                    action = LicenseInfoAction.PUSH;
                                }
                                else {  // handle cases where the trigger address contains invalid license info
                                    // Handle cases when no license information is provided or it has been nulled out
                                    if ((Trigger.new[i].License_vod__c == null) || (Trigger.new[i].License_vod__c == '')) {
                                        if (Trigger.isInsert) {
                                            if (addr.License_Valid_to_Sample_vod__c == 'Valid') {
                                                System.debug('Pull valid license info from a same state/country address (after insert, no license info)');
                                                action = LicenseInfoAction.PULL;
                                            }
                                        }
                                        else if (Trigger.isUpdate) {
                                            // The license info for the address has not been touched and remains blank
                                            if ((Trigger.old[i].License_vod__c == null) || (Trigger.old[i].License_vod__c  == '')) {
                                                if (addr.License_Valid_to_Sample_vod__c == 'Valid') {
                                                    System.debug('Pull valid license info from a same state/country address (after update, no license info before/after)');
                                                    action = LicenseInfoAction.PULL;
                                                }
                                            }
                                            else { // The license info was intentionally nulled out by the user
                                                System.debug('Push null license info values to other same state/country addresses');
                                                action = LicenseInfoAction.PUSH_NULL;
                                            }
                                        }
                                    }
                                    else { // handle cases when license information is populated and the user wants to invalidate license
                                        if (Veeva_Merge.isAddressMerge == true) {
                                            System.debug('Switching to PULL action for merge.');
                                            action = LicenseInfoAction.PULL;
                                        } else if (Trigger.isInsert || Trigger.isUpdate) {
                                            System.debug('Push invalid license info to other same state/country addresses');
                                            action = LicenseInfoAction.PUSH;
                                        }
                                    }
                                }
                            }
                        }
                    // set values on record(s)
                    if (action == LicenseInfoAction.PUSH) {
                        Address_vod__c addrObj = updLic.get(addr.Id); 
                        if (addrObj == null)
                            addrObj = new Address_vod__c(ID=addr.Id);
                        addrObj.License_Expiration_date_vod__c = Trigger.new[i].License_Expiration_date_vod__c;
                        addrObj.License_Status_vod__c = Trigger.new[i].License_Status_vod__c;
                        addrObj.License_vod__c = Trigger.new[i].License_vod__c;
                        System.debug('PUSH: License - ' + addrObj.License_vod__c + ', ExpDate -  ' + addrObj.License_Expiration_date_vod__c + ', Status - ' + addrObj.License_Status_vod__c);
                        updLic.put(addr.Id, addrObj);
                    }
                    else if (action == LicenseInfoAction.PUSH_NULL) {
                        Address_vod__c addrObj = updLic.get(addr.Id); 
                        if (addrObj == null)
                            addrObj = new Address_vod__c(ID=addr.Id);
                        addrObj.License_Expiration_date_vod__c = null;
                        addrObj.License_Status_vod__c = null;
                        addrObj.License_vod__c = null;
                        System.debug('PUSH_NULL: License - ' + addrObj.License_vod__c + ', ExpDate -  ' + addrObj.License_Expiration_date_vod__c + ', Status - ' + addrObj.License_Status_vod__c);
                        updLic.put(addr.Id, addrObj);
                    }
                    else if (action == LicenseInfoAction.PULL) {
                        Address_vod__c addrObj = updLic.get(Trigger.new[i].Id);
                        if (addrObj == null)
                            addrObj = new Address_vod__c(ID=Trigger.new[i].Id);
                        addrObj.License_Expiration_date_vod__c=addr.License_Expiration_date_vod__c;
                        addrObj.License_Status_vod__c=addr.License_Status_vod__c;
                        addrObj.License_vod__c=addr.License_vod__c;
                        updLic.put(Trigger.new[i].Id, addrObj);
                        System.debug('PULL: License - ' + addrObj.License_vod__c + ', ExpDate -  ' + addrObj.License_Expiration_date_vod__c + ', Status - ' + addrObj.License_Status_vod__c);
                        break;
                    }
                    else if (action == LicenseInfoAction.RESET) {
                        Address_vod__c addrObj = updLic.get(Trigger.new[i].Id);
                        if (addrObj == null)
                            addrObj = new Address_vod__c(ID=Trigger.new[i].Id);
                        addrObj.License_Expiration_date_vod__c=null;
                        addrObj.License_Status_vod__c=null;
                        addrObj.License_vod__c=null;
                        updLic.put(Trigger.new[i].Id, addrObj);
                        System.debug('RESET: License - ' + addrObj.License_vod__c + ', ExpDate -  ' + addrObj.License_Expiration_date_vod__c + ', Status - ' + addrObj.License_Status_vod__c);
                        break;
                    }
                    else if (action != LicenseInfoAction.NONE) {
                        System.debug('Unhandled action: ' + action);
                    }
                }
                // handle case when only state was changed but no matching state address was found
                if (!keyMatchFound && Trigger.isUpdate && 
                    (oldKeyCode != keyCode) &&
                    Trigger.old[i].License_Expiration_date_vod__c == Trigger.new[i].License_Expiration_date_vod__c &&
                    Trigger.old[i].License_Status_vod__c == Trigger.new[i].License_Status_vod__c &&
                    Trigger.old[i].License_vod__c == Trigger.new[i].License_vod__c) {
                        Address_vod__c addrObj = updLic.get(Trigger.new[i].Id);
                        if (addrObj == null)
                            addrObj = new Address_vod__c(ID=Trigger.new[i].Id);
                        addrObj.License_Expiration_date_vod__c=null;
                        addrObj.License_Status_vod__c=null;
                        addrObj.License_vod__c=null;
                        updLic.put(Trigger.new[i].Id, addrObj);
                        System.debug('RESET - state/country changed: License - ' + addrObj.License_vod__c + ', ExpDate -  ' + addrObj.License_Expiration_date_vod__c + ', Status - ' + addrObj.License_Status_vod__c);
                        break;
                    }
            }
            updateLicenses.add(key);
        }
        else
            System.debug('Object found in updateLicense list');
        
        // deal with primary address flag
        Address_vod__c add_c_new =  Trigger.new[i];
        if  (add_c_new.Primary_vod__c == true) { // && (Trigger.isInsert || Trigger.old[i].Primary_vod__c == false)) {
            // Added by Raphael
            if (Trigger.isInsert || Trigger.old[i].Primary_vod__c == false)
                add_c_new.BI_Preferred_Address_BI__c = true;
                
            for (Integer k = 0; k < primAddList.size(); k++){
                if (primAddList[k].Account_vod__c == add_c_new.Account_vod__c && primAddList[k].Id != add_c_new.Id) {
                    Address_vod__c  addr = new Address_vod__c(Id = primAddList[k].Id);
                    addr.Primary_vod__c = false;
                    if (add_c_new.BI_Preferred_Address_BI__c) addr.BI_Preferred_Address_BI__c = false;
                    updMap.put(primAddList[k].Id,addr);
                }
            }       
        }
        
        /* */
        if (add_c_new.BI_Preferred_Address_BI__c == true) { // && (Trigger.isInsert || Trigger.old[i].BI_Preferred_Address_BI__c == false)) { 
            //&& (add_c_new.Primary_vod__c == false || (add_c_new.Primary_vod__c == true && Trigger.old[i].Primary_vod__c == true)) {
            // Added by Raphael
            // deal with removing preferred addresses
            for (Integer k = 0; k < prefAddList.size(); k++) {
               	system.debug('Looking at address id: ' + prefAddList[k].Id);
                if (prefAddList[k].Account_vod__c == add_c_new.Account_vod__c && prefAddList[k].Id != add_c_new.Id) {
                	system.debug('Removing preferred from address id: ' + prefAddList[k].Id);
                    if (updMap.containsKey(prefAddList[k].Id)) {
                        updMap.get(prefAddList[k].Id).BI_Preferred_Address_BI__c = false;
                    } else {
                       Address_vod__c  addr = new Address_vod__c(Id = prefAddList[k].Id);
                        addr.BI_Preferred_Address_BI__c = false;
                        updMap.put(prefAddList[k].Id,addr);
                    }
                }
            }
        }
        /* */
        
    }  
    
    List<Address_vod__c> theList = updLic.values();  
    if (theList.size() > 0) {
        
        for (Address_vod__c addr : theList) {
            if (updMap.containsKey(addr.Id)) {
                addr.Primary_vod__c = false;
                updMap.remove(addr.Id);
            }
        }
        try {
            VOD_Utils.getAddresses().addAll(updLic.keySet());
            update theList;
        }   catch (System.DmlException e) {
            Integer numErrors = e.getNumDml();
            String error = '';
            for (Integer i = 0; i < numErrors; i++) {
                Id thisId = e.getDmlId(i);
                if (thisId != null)  {
                    error += thisId + ' - ' + e.getDmlMessage(i) + '<br>';
                }
            }
            
            for (Address_vod__c errorRec : Trigger.new) {
                errorRec.Id.addError(error);    
            }
        }
    }
    
    if (updMap.size() > 0) {
        try {
            VOD_Utils.getAddresses().addAll(updMap.keySet());
            update updMap.values();
        }catch (System.DmlException e) {
            Integer numErrors = e.getNumDml();
            String error = '';
            for (Integer i = 0; i < numErrors; i++) {
                Id thisId = e.getDmlId(i);
                if (thisId != null)  {
                    error += thisId + ' - ' + e.getDmlMessage(i) + '\n';
                }
            }
            
            for (Address_vod__c errorRec : Trigger.new) {
                errorRec.Id.addError(error);    
            }                   
        }
    }
    
    if ('TRUE'.equalsIgnoreCase(isRealTime)) { 
        System.debug ('VEEVADEBUG - accountsToPush ' + accountsToPush);
        if (accountsToPush.size() > 0) {
            String accountids = '';
            Integer nCount = 0;
            for (Id accId : accountsToPush) {
                if (nCount > 0) {
                    accountids += ',';
                }
                accountids += '\'' + accId + '\'';
                nCount++;
            }
            System.debug ('VEEVADEBUG - accountsToPush ID ' + accountids);
            VEEVA_ASYNC_ADDRESS_PUSH.start(accountids);
        }
    }
}