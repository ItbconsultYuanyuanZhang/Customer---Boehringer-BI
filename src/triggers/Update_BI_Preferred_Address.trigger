/******************************************************************************
 * Update_BI_Preferred_Address
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
 * CAVEAT: If you remove the preferred flag from an address, no preferred
 * flag will be set against any addresses.
 * 
 * IMPORTANT CAVEAT: This is designed to work with the current version of Veeva. If the version
 * is upgraded, this code may break and require modifications.
 *
 * N.B. For instructions on how to prevent trigger recursion, see:
 *  http://www.salesforce.com/docs/developer/cookbook/Content/apex_controlling_recursive_triggers.htm 
 *
 * Author: Raphael Krausz <raphael.krausz@veevasystems.com>
 * Created date: 2013-03-28
 *
 * Modified by: Raphael Krausz <raphael.krausz@veevasystems.com>
 * Modified date: 2013-04-02
 * Added functionality to also align the primary flag
 *
 * Modified by: Raphael Krausz
 * Modified date: 2013-04-03
 * Removed all functionality except for after delete, RK_Address_trigger_BI now handles the insert and update functions.
 *
 */

trigger Update_BI_Preferred_Address on Address_vod__c (after delete, before insert, before update) {

    /** **
    //Set<Id> accountSetPreferred     = new Set<Id>();

    List<Address_vod__c> addresses = (Trigger.isDelete) ? Trigger.old : Trigger.new;
    
    for (Address_vod__c address : addresses) {

    //for (Integer i = 0; i < Trigger.size; i++) {

    if (Trigger.isDelete) {
        //Address_vod__c address = Trigger.old[i];
        //for (Address_vod__c address : Trigger.old) {
    
        if ((!address.Primary_vod__c) && address.BI_Preferred_Address_BI__c) {
            // find the primary address and make it preferred.
            system.debug('Setting primary as preferred for account: ' + address.Account_vod__c);
            accountSetPreferred.add(address.Account_vod__c);
        }
    

        List<Address_vod__c> toSetPreferred = new List<Address_vod__c>();

        system.debug('accountSetPreferred size: ' + accountSetPreferred.size());
    if (accountSetPreferred.size() > 0) {
        toSetPreferred = [
            SELECT Id, BI_Preferred_Address_BI__c
            FROM Address_vod__c
            WHERE Account_vod__c IN :accountSetPreferred
            AND Primary_vod__c = true
        ];
        
        for (Integer i = 0; i < toSetPreferred.size(); i++)
            toSetPreferred[i].BI_Preferred_Address_BI__c = true;
    }

    system.debug('Number of address records to update after a delete: ' + toSetPreferred.size());
    if (toSetPreferred.size() > 0) update toSetPreferred;
    } else {
    /** **/
    
    if (TriggerRecursionHelper.hasBiPreferredTriggerStarted())
        return;
    
    /** **
    // We also need to prevent the standard Veeva address trigger(s) from firing
    Boolean VOD_ADDRESS_TRIG_AlreadySet = false;
    
    if (!VOD_ADDRESS_TRIG.getAddressTrig()) {
        VOD_ADDRESS_TRIG.setAddressTrig(true);
        VOD_ADDRESS_TRIG_AlreadySet = true;
    }
    /** **/
    
    TriggerRecursionHelper.setBiPreferredTriggerStarted();

    Set<Id> accountSetPreferred     = new Set<Id>();
    Set<Id> accountRemovePreferred  = new Set<Id>();
    Set<Id> addressExcludePreferred = new Set<Id>();

    //Set<Id> accountSetPrimary     = new Set<Id>();
    Set<Id> accountRemovePrimary    = new Set<Id>();
    Set<Id> addressExcludePrimary   = new Set<Id>();
    

    for (Integer i = 0; i < Trigger.size; i++) {

        Address_vod__c address = (Trigger.isDelete) ? Trigger.old[i] : Trigger.new[i];

        if (Trigger.isDelete && (!address.Primary_vod__c) && address.BI_Preferred_Address_BI__c) {
            // find the primary address and make it preferred.
            system.debug('Setting primary as preferred for account: ' + address.Account_vod__c);
            accountSetPreferred.add(address.Account_vod__c);
        }
        
        if (Trigger.isUpdate && Trigger.old[i].BI_Preferred_Address_BI__c &&  !Trigger.new[i].BI_Preferred_Address_BI__c) // !address.BI_Preferred_Address_BI__c)
            continue;
        
        // if the address is being set to the primary, then also make it the preferred address
        // Also remove the preferred flag from other addresses for this account
        
        //if ((Trigger.isInsert && address.Primary_vod__c) || (Trigger.isUpdate && address.Primary_vod__c && !Trigger.old[i].Primary_vod__c)) {
        if (address.Primary_vod__c && (Trigger.isInsert || (Trigger.isUpdate && !Trigger.old[i].Primary_vod__c))) {
            Trigger.new[i].BI_Preferred_Address_BI__c = true;
            system.debug('Adding primary address for: ' + address.Id);
            system.debug('(Name: ' + address.Name + ')');
            
            accountRemovePrimary.add(address.account_vod__c);
            if (address.Id != null) addressExcludePrimary.add(address.id);
        }
        
        
        if (address.BI_Preferred_Address_BI__c && (Trigger.isInsert || (Trigger.isUpdate && !Trigger.old[i].BI_Preferred_Address_BI__c))) {
            // If the preferred address is being set
            system.debug('Removing preferred flag from account ' + address.account_vod__c + ' addresses.');
            system.debug('...except for address id: ' + address.Id);
            accountRemovePreferred.add(address.account_vod__c);
            if (address.Id != null) addressExcludePreferred.add(address.Id);  //...because this will be null
        }
    }

    List<Address_vod__c> toSetPreferred;
    List<Address_vod__c> toRemovePreferred;
    List<Address_vod__c> toRemovePrimary;
    
   
    system.debug('accountSetPreferred size: ' + accountSetPreferred.size());
    if (accountSetPreferred.size() > 0) {
        toSetPreferred = [
            SELECT Id, BI_Preferred_Address_BI__c
            FROM Address_vod__c
            WHERE Account_vod__c IN :accountSetPreferred
            AND Primary_vod__c = true
        ];
        
        for (Integer i = 0; i < toSetPreferred.size(); i++)
            toSetPreferred[i].BI_Preferred_Address_BI__c = true;
    }


    // system.debug('accountRemovePreferred size: ' + accountRemovePreferred.size());
    if (accountRemovePreferred.size() > 0) {
        toRemovePreferred = [
            SELECT Id, BI_Preferred_Address_BI__c
            FROM Address_vod__c
            WHERE Account_vod__c IN :accountRemovePreferred
            AND (NOT Id IN :addressExcludePreferred)
        ];

        for (Integer i = 0; i < toRemovePreferred.size(); i++) {
            toRemovePreferred[i].BI_Preferred_Address_BI__c = false;
            system.debug('forloop - toRemovePreferred: ' +  toRemovePreferred[i].Id);
        }
    }
    
       if (accountRemovePrimary.size() > 0) {
        toRemovePrimary = [
            SELECT Id, Primary_vod__c
            FROM Address_vod__c
            WHERE Account_vod__c IN :accountRemovePrimary
            AND (NOT Id IN :addressExcludePrimary)
        ];

        for (Integer i = 0; i < toRemovePrimary.size(); i++) {
            toRemovePrimary[i].Primary_vod__c = false;
        }
    }
    
    List<Address_vod__c> toUpdate = new List<Address_vod__c>();
    if (toSetPreferred    != null) toUpdate.addAll(toSetPreferred);
    if (toRemovePreferred != null) toUpdate.addAll(toRemovePreferred);

        
    if (toUpdate.size() > 0) update toUpdate;


    if (toRemovePrimary != null && toRemovePrimary.size() > 0) update toRemovePrimary;


    /** **
    if (!VOD_ADDRESS_TRIG_AlreadySet) {
        VOD_ADDRESS_TRIG.setAddressTrig(false);
    }
    /** **/
}