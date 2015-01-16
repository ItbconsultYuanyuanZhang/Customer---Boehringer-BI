/*


TO RUN: 
VEEVA_BI_BATCH_Address_Preferred_flag b = new VEEVA_BI_BATCH_Address_Preferred_flag (); database.executebatch(b,100);

Created by: Viktor 2013-05-17

*/
global class VEEVA_BI_BATCH_Address_Preferred_flag implements Database.Batchable<sObject>{
    String country = null;
    
    global VEEVA_BI_BATCH_Address_Preferred_flag () {
        system.debug('BI_BATCH_Address_Preferred_flag STARTED');
    }
    
    global VEEVA_BI_BATCH_Address_Preferred_flag (String country) {
        system.debug('BI_BATCH_Address_Preferred_flag STARTED with country');
        this.country = country;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // This is the base query that dirves the chunking.
        
        String query = ' SELECT id, BI_Preferred_Address_BI__c ' + 
                        ' FROM Address_vod__c '+
                        ' where Primary_vod__c = true  ' + 
                        ' and BI_Preferred_Address_BI__c != true ' +
                        ' and lastmodifiedbyId in ( \'005d0000001t6MCAAY\' , \'005J0000000yTyBIAU\', \'005K0000001dSGyIAM\' ) '
               ;  
        // Country_Code_BI__c = \'CA\'
        
        if(country!=null) 
        	query += 'and Country_Code_BI__c = \'' + country + '\'';
        
        system.debug('query: ' +query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> batch) {
        system.debug('batch process starting');
        system.debug('batch size: ' + batch.size());
   
        List <Address_vod__c> addrs = (List <Address_vod__c>) batch;
        
        if(addrs.size()==0){
            return;
        } 
        
       for (Address_vod__c addr : addrs)
            addr.BI_Preferred_Address_BI__c = true;
  
       update addrs;
        
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('BI_BATCH_Address_Preferred_flag FINISHED');
        // That's all folks!
    }

}