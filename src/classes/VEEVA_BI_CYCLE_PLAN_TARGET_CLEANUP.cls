/* 
Deletes all the Cycle_Plan_Target_vod__c -s where the cycle_plan_account_vod__c is empty,
due to the account merges done by cap.

TO RUN:
VEEVA_BI_CYCLE_PLAN_TARGET_CLEANUP b = new VEEVA_BI_CYCLE_PLAN_TARGET_CLEANUP(); database.executebatch(b,200);
*/

global class VEEVA_BI_CYCLE_PLAN_TARGET_CLEANUP implements Database.Batchable<SObject>, Schedulable {
  
   global void execute(SchedulableContext sc) {
      VEEVA_BI_CYCLE_PLAN_TARGET_CLEANUP b = new VEEVA_BI_CYCLE_PLAN_TARGET_CLEANUP(); 
      database.executebatch(b,200);
   }
    
    global VEEVA_BI_CYCLE_PLAN_TARGET_CLEANUP () {
        system.debug('VEEVA_BI_CYCLE_PLAN_TARGET_CLEANUP STARTED');
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        
        query = ' SELECT id, cycle_plan_account_vod__c FROM Cycle_Plan_Target_vod__c WHERE cycle_plan_account_vod__c = null '; 
       
        //system.debug('query: ' +query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> batch) {
        //system.debug('VEEVA_BI_CYCLE_PLAN_TARGET_CLEANUP batch process starting');
        system.debug('queried batch size: ' + batch.size());
        
        delete batch;
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('VEEVA_BI_CYCLE_PLAN_TARGET_CLEANUP FINISHED');
        // That's all folks!
    }
}