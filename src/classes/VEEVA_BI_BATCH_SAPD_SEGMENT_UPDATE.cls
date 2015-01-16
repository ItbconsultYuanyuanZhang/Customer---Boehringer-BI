/*
Updates Cycle_Plan_Detail_vod__c zvod_PM_Segmentation_BI__c field to the Segmentation_BI__c of the related Product_Metrics_vod__c

TO RUN: 
VEEVA_BI_BATCH_SAPD_SEGMENT_UPDATE b = new VEEVA_BI_BATCH_SAPD_SEGMENT_UPDATE(); database.executebatch(b,100);

Created by: Viktor 2013-05-16

*/
global class VEEVA_BI_BATCH_SAPD_SEGMENT_UPDATE implements Database.Batchable<sObject>{
    
    global VEEVA_BI_BATCH_SAPD_SEGMENT_UPDATE() {
        //system.debug('VEEVA_BI_BATCH_SAPD_SEGMENT_UPDATE STARTED');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // This is the base query that dirves the chunking.
        
        String query = ' SELECT Id,' +
                ' Cycle_Plan_Target_vod__c, ' + 
                ' Cycle_Plan_Target_vod__r.Cycle_Plan_Account_vod__c, '+
                ' Product_vod__c, ' +
                ' zvod_PM_Segmentation_BI__c ' +     
                ' FROM  Cycle_Plan_Detail_vod__c ' + 
                ' WHERE zvod_PM_Segmentation_BI__c = null'
               ;   
         
        //system.debug('query: ' +query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> batch) {
        //system.debug('batch process starting');
        // Loop through all the rows in the batch of Cycle Plan Details
        List <Cycle_Plan_Detail_vod__c> SAPDs = new List <Cycle_Plan_Detail_vod__c> ();
        set<id> accIDs = new set<id>();
        
        //system.debug('batch size: ' + batch.size());
        
        
        //get SAPD and related SAPT
        for (sObject obj : batch) {
            Cycle_Plan_Detail_vod__c detail = (Cycle_Plan_Detail_vod__c)obj;
            SAPDs.add(detail);
            accIDs.add(detail.Cycle_Plan_Target_vod__r.Cycle_Plan_Account_vod__c);   
    
        }
        //system.debug('SAPDs size: ' +SAPDs.size());
        //system.debug('SAPDs: ' +SAPDs);
        //system.debug('accIDs size: ' +accIDs.size());
        
        if(SAPDs.size()==0){
            //system.debug('SAPDs size: ' +SAPDs.size()+ 'Nothing to update.');
            return;
        } 
        
                
        Product_Metrics_vod__c[] PMs = [select id, Account_vod__c, Products_vod__c, Segmentation_BI__c from Product_Metrics_vod__c where Account_vod__c in : accIDs];
        //system.debug('PMs size: ' +PMs.size());
        
        if(PMs.size()==0){
            system.debug('PMs size: ' +SAPDs.size()+ 'Nothing to get values from.');
            return;
        } 
                
        set<Cycle_Plan_Detail_vod__c> toUpdate = new set<Cycle_Plan_Detail_vod__c>();
        //set<id> toUpdate = new set<id>();
        
        for (Cycle_Plan_Detail_vod__c SAPD : SAPDs){
                        
            for(Product_Metrics_vod__c PM : PMs){
                //system.debug('Pairing (SAPD-PM): ' + SAPD + '-' + PM);
                if(PM.Account_vod__c != SAPD.Cycle_Plan_Target_vod__r.Cycle_Plan_Account_vod__c) 
                    continue;
                    
                if(PM.Products_vod__c != SAPD.Product_vod__c)
                    continue;
                
                //system.debug('SAPD-PM match found: ' + SAPD.id + '-' + PM.id + ' Segmentation: ' + PM.Segmentation_BI__c);
                SAPD.zvod_PM_Segmentation_BI__c = PM.Segmentation_BI__c;
                        
                //system.debug('SAPD: ' +SAPD); 
                toUpdate.add(SAPD);
                                
            }
                
            
        }
        
        
        
        //System.debug ('Afterprocess toUpdate.size: ' + toUpdate.size());
             
         
        if (toUpdate.size () > 0 ) {
            //list<Cycle_Plan_Detail_vod__c> finalupdate = new list<Cycle_Plan_Detail_vod__c>();
            //finalupdate.addAll(toUpdate);
            //System.debug ('final finalupdate.size: ' + finalupdate.size());
            //update finalupdate;
            
            Database.SaveResult[] srList = Database.update(SAPDs, false);
	
			//Log results for easy tracking, debugging 
			for (Database.SaveResult sr : srList) {
	 		   if (sr.isSuccess()) {
			        System.debug('Successfully updated: ' + sr.getId());
			    }
			    else {     
			        for(Database.Error err : sr.getErrors()) {
			            System.debug('The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('Fields that affected this error: ' + err.getFields());
			        }
			    }
			}//end of results
            
            
            
        }else{
            //System.debug ('final toUpdate.size: ' + toUpdate.size() + 'No matches. Nothing to update.');
        }
   
    }
    
    
    global void finish(Database.BatchableContext BC) {
        System.debug('SEGMENT BATCH FINISHED');
        // That's all folks!
    }

}