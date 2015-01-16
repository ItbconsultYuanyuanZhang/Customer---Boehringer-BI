/****************************************************************************************************
This class  iterates through  the address records  in the system, and where it find name = id 
it updates the name to ‘No Street Address Available’. Not scheduled.

TO RUN:
VEEVA_BATCH_ONEKEY_UPD_MISSING_ADDRESS b = new VEEVA_BATCH_ONEKEY_UPD_MISSING_ADDRESS(); database.executebatch(b,50); 

Lastmod: Viktor
Lastmoddate: 2013.04.23
****************************************************************************************************/
global without sharing class VEEVA_BATCH_ONEKEY_UPD_MISSING_ADDRESS implements Database.Batchable<SObject>{
	
	global VEEVA_BATCH_ONEKEY_UPD_MISSING_ADDRESS()   
    {
  
    }
	
	
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
    {
	     System.Debug('START BATCH VEEVA_BATCH_ONEKEY_UPD_MISSING_ADDRESS');
	     
	     list<Address_vod__c> addrs = [SELECT ID, Name FROM Address_vod__c WHERE Name like 'a%' order by ID];
	     System.Debug('addrs size: ' + addrs.size());
	     System.Debug('addrs: ' + addrs);
	     
	     list<Address_vod__c> updateAddr = new list<Address_vod__c>();
	     //String ide;
	     String name;	
	
	    for(Integer i = 0; i < addrs.size(); i++ ){
	    		System.Debug('i: ' + i);
	     		
	     		Address_vod__c oneid = addrs[i];
	     			     		
	     		//ide = oneid.id;
	     		name = oneid.Name;
	     		
	     		//System.Debug('ide: ' + ide);
	     		System.Debug('name: ' + name);
	     		
	     		if(!(name.containsWhitespace())){
	     			System.Debug('Match found for: ' + oneid);
	     			updateAddr.add(oneid);
	     			
	     		}
	      }
         System.Debug('updateAddr size: ' + updateAddr.size());
         System.Debug('updateAddr: ' + updateAddr);
       	 return Database.getQueryLocator([SELECT id from Address_vod__c Where id in :updateAddr] );
    }
    
	 global void execute(Database.BatchableContext BC, List<sObject> batch) 
    {  
    	System.Debug('EXECUTION BATCH VEEVA_BATCH_ONEKEY_UPD_MISSING_ADDRESS');
    	
    	list<Address_vod__c> addresses = ( list<Address_vod__c> ) batch;
    	
    	for(Integer i = 0; i < addresses.size(); i++ ){
    		addresses[i].Name = 'No Street Address Available';
    	}
    	
    	update addresses;
    }
    
     global void finish(Database.BatchableContext BC)
    {       	
            System.Debug('END BATCH VEEVA_BATCH_ONEKEY_UPD_MISSING_ADDRESS');
    }   
    
    
}