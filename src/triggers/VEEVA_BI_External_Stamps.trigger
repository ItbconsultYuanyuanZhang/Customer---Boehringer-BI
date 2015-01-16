/*******************************************************************************
Veeva_BI_External_Stamps trigger on Call2_vod__c before insert, before update

The trigger updates Concur stamp fields from the related account's address on the call.

Created by: Raphael Krausz, Viktor Fasi
Last modified date: 2013.04.18
Last modification: Code cleanup and optimization
********************************************************************************/

trigger VEEVA_BI_External_Stamps on Call2_vod__c (before insert, before update) {
    system.debug('VEEVA_BI_External_Stamps trigger started.');
    Call2_vod__c[]      calls       = new List<Call2_vod__c>();
    Id[]                call_accs   = new List<Id>();
    Id[]                account_ids = new List<Id>();
    
    Id[] parent_ids = new List<Id>();
    Map<Id, Call2_vod__c> parentIdParent = new Map<Id, Call2_vod__c>();
    
    Id[] childAccIds = new List<Id>();
    //Map<Id, String> parentAccIds = new List<Id>();
    List<Call2_vod__c> parentCalls = new List<Call2_vod__c>();
    
    system.debug('Trigger size: ' + Trigger.size);
    Integer k = -1;
    id id1 = userinfo.getProfileId();
    profile p = [select Name from profile where id = :id1 limit 1];
    String username = userinfo.getUserName();
 
 /**********************************************************************/      
 /*************************ENTRY CRITERIA*******************************/    
 /**********************************************************************/   
 
    for (Integer i = 0; i < Trigger.size; i++) {
        //system.debug('Cycle number: ' + i);
        // If the call was not just submitted, then do nothing
        if(Trigger.isInsert){
            if (!(Trigger.new[i].status_vod__c == 'Submitted_vod')) {
                System.debug('Not submitted, skipping.'); continue;
            }   
        }
        if(Trigger.isUpdate){
            if (!(Trigger.new[i].status_vod__c == 'Submitted_vod' && Trigger.old[i].status_vod__c != 'Submitted_vod')) {
                System.debug('Not submitted, skipping.'); continue;
            }   
        }
        
        
        //only activate for US or Sysadmin profiles
        if (  (!(p.name.contains('US'))) &&  
        		(!(p.name.contains('SP'))) &&
        		(!(p.name.contains('FR'))) &&  
        		(!(p.name.contains('JP'))) && 
        		(!(p.name == 'System Administrator')))  {
        //if ( !(p.name.contains('US')) )  {
            System.debug('Not US, FR, SP or SysAdmin, skipping.(' + p.name +')' ); continue;
        }
        
       //skip "Admin User"
         if (username.contains('vadmin@bi'))  {
            System.debug('User is the data loading Admin User.(' + username +')' ); continue;
        }
        
        
        //if the attendee is a user, skip the trigger, won't have concur data anyways
        if (Trigger.new[i].account_vod__c == null) {
            System.debug('Child call attendee is a User, skipping. CallID: ' + Trigger.new[i].Id); continue;
        }
            
        //if (expense amount on call is 0 - skip too)
        //expense amount on Irep recorded child calls doesn't get filled with the parents', adding an exception
        if ((Trigger.new[i].Expense_Amount_vod__c == 0 || Trigger.new[i].Expense_Amount_vod__c == null ) && Trigger.new[i].Is_Parent_Call_vod__c == 1 ) {
            System.debug('No Expense, skipping.'); continue;
        }
         
        calls.add(Trigger.new[i]);
        //add variable k, because trigger i might not equal number of calls already added
        k++;
        //system.debug('Call number: ' + k);
        call_accs.add(calls[k].Account_vod__c);
        
        if (calls[k].Is_Parent_Call_vod__c == 0) {
            // if it's a child, we just grab the primary address of it's account, so we'll store it's account here.
            account_ids.add(calls[k].Account_vod__c);
        } else {
            parentCalls.add(calls[k]);
        }
    }
    
    // If there weren't any submitted calls, then quit
    system.debug('call size: ' + calls.size());
    if (calls.size() == 0) return;
    
 /**********************************************************************/      
 /*************************PARENT CALLS*********************************/    
 /**********************************************************************/    

    
    // NB Use the for...each loop to build the WHERE clause 
    Map<Call2_vod__c, Address_vod__c> parentAddressMap = new Map<Call2_vod__c, Address_vod__c>();
    
    if(parentCalls.size()>0){
      
        String addressQuery = 'SELECT Id, Account_vod__c, External_ID_vod__c, Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Country_Code_BI__c FROM Address_vod__c';
        Boolean started = false;
        
        for (Call2_vod__c call : parentCalls) {
            if (call.Address_Line_1_vod__c != null && call.Address_Line_1_vod__c != '' && call.Address_Line_1_vod__c != ' ' && call.Address_Line_1_vod__c != 'null' ){
               
                if (started) addressQuery += ' ) OR ( ';
                else { addressQuery += ' WHERE  ( '; started = true; }
                
                addressQuery += ' Name = \'' + call.Address_Line_1_vod__c + '\'';
            }
        }
        
        if(started){
            AddressQuery += ' )';
        }
        
        
        system.debug('AddressQuery: ' + addressQuery);
        List<Address_vod__c> addresses = new List<Address_vod__c>() ;
        
        try{
            if(started){
                addresses = Database.query(addressQuery); 
                system.debug('Address size: ' + addresses.size());
            }
        } catch(Exception e){
            System.debug('The address can\'t be queried, please check if it is not empty.');
        }
        
        if(parentCalls.size() > 0 && addresses.size()>0){
            for (Call2_vod__c call : parentCalls) {
                for (Address_vod__c a : addresses){
                              if(addresses.size()>0
                            && (a.Account_vod__c == call.Account_vod__c) 
                            && (a.Name == call.Address_Line_1_vod__c) 
                           // && (a.Address_Line_2_vod__c == call.Address_Line_2_vod__c) //Addess line 2 contains a space instead of a null value sometimes, causes a lot of errors
                                 ){
                                   System.debug('We got to addressMap :)');
                                   parentAddressMap.put(call, addresses[0]);
                                  }
                 }   
            }
            
        }     
        
    }
 /**********************************************************************/      
 /********************CHILD CALLS & RELATED ACCOUNTS********************/    
 /**********************************************************************/    

    Map<Id, Account> callAccountMap = new Map<Id, Account>();
    Address_vod__c[] childAddresses;
    Account[] call_accounts;
    Map<Id, Address_vod__c> childAddressMap = new Map<Id, Address_vod__c>();
    
    try {

        childAddresses = [
            SELECT Id, Account_vod__c, External_ID_vod__c,
            Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Country_Code_BI__c
            FROM Address_vod__c
            WHERE Account_vod__c IN :account_ids
            // AND Primary_vod__c = true
            order BY Primary_vod__c desc
        ];

        call_accounts = [ SELECT Id, Name, External_ID_vod__c FROM Account WHERE Id in :call_accs ];

    } catch(system.QueryException e) {
        //Trigger.new[0].addError('Unable to find a matching address for the call in the database!', true);
        system.debug('Unable to find a matching address for the call in the database!');
        //return;
    }
    
    
    if(childAddresses.size() > 0){
        
        for (Address_vod__c address : childAddresses) {
            // Only add the first instance (which should be the primary)
            if ( ! childAddressMap.containsKey(address.Account_vod__c) ) 
                childAddressMap.put(address.Account_vod__c, address);
        }
        
    }

    for (Account acc : call_accounts) {
        callAccountMap.put(acc.Id, acc);
    }

    system.debug('Calculations done');
 
 /**********************************************************************/      
 /**************************UPDATES*************************************/    
 /**********************************************************************/  
      
    for (Integer i = 0; i < calls.size(); i++) {
        Account theAccount = callAccountMap.get( calls[i].Account_vod__c );
        
        if (theAccount == null) {
            System.debug('Problem finding Account.');
            return;
        }
        
        Address_vod__c theAddress = (calls[i].Is_Parent_Call_vod__c == 0) ? childAddressMap.get(theAccount.Id) : parentAddressMap.get(calls[i]);
        
        if (theAddress == null) {
            //Trigger.new[i].addError('The address on the call can not be matched to one on the account. Check if both exists. Account id: ' + theAccount.Id + 'Call id: ' + calls[i].Id, true);
            //System.debug('Address not found for account: ' + theAccount.Id + ', ' + theAccount.Name);
            //System.debug('Address not found in case of call: ' + calls[i].Id + ', ' + calls[i].Name + '. That is a parent call: ' + calls[i].Is_Parent_Call_vod__c);
            //System.debug('Address not found in case of call for child calls:' + childAddressMap.get(theAccount.Id));
            //System.debug('Address not found in case of call for parent calls:' + parentAddressMap.get(calls[i]) + ' Call address line 1: ' + calls[i].Address_Line_1_vod__c + ' Call address: ' + calls[i].Address_vod__c); 
            //System.debug('Address not found in case of call from  parentaddressmap: ' + parentAddressMap);
            system.debug('Filling fields without address!');
            // Update the fields
            calls[k].Override_Lock_vod__c = true;
            calls[i].C1__c  = 'V' + theAccount.External_ID_vod__c;
            
            return;
        }
        
        system.debug('Processing call: ' + calls[i].Id);
        
        calls[k].Override_Lock_vod__c = true;
        
        // Update the fields
        calls[i].C1__c  = 'V' + theAccount.External_ID_vod__c + theAddress.External_ID_vod__c;
        calls[i].C2__c  = theAddress.Name;
        calls[i].C3__c  = theAddress.Address_line_2_vod__c;
        calls[i].C4__c  = theAddress.City_vod__c;
        calls[i].C5__c  = theAddress.State_vod__c;
        calls[i].C6__c  = theAddress.Zip_vod__c;
        calls[i].C7__c  = theAddress.Country_Code_BI__c;
        
    }
}