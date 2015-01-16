/**************************************************************************
    VEEVA_PS_SET_CYCLE_PLAN_STATUS
    October 12, 2013
    Version 1.0

    Summary
    --------------
    Batch process to handle cycle plan activation/inactivation.
    Allows load of cycle plans in advance of the given cycles.
    The routine first performs the inactivation, then the activation.

    How to Run
    --------------
    Option 1. Run manually via the SFDC Developer Console:
    database.executebatch(new VEEVA_PS_SET_CYCLE_PLAN_STATUS (),200); 

    Option 2. Schedule a nightly routine, preferably before the 
    Cycle plan calculation routine. 
    Setup > Develop > Apex Classes > Schedule Apex
**************************************************************************/
global class VEEVA_PS_SET_CYCLE_PLAN_STATUS implements Database.Batchable<sObject>,Schedulable  {
    
    global VEEVA_PS_SET_CYCLE_PLAN_STATUS() {
    
    }
    
    global void execute(SchedulableContext ctx) {       
        database.executebatch(new VEEVA_PS_SET_CYCLE_PLAN_STATUS (),200); 
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    
        String query=  'select Id, Start_Date_vod__c, End_Date_vod__c, Active_vod__c '+
            ' from Cycle_Plan_vod__c  where Active_vod__c = true' + 
            ' or (Active_vod__c = false and Start_Date_vod__c <= TODAY and End_Date_vod__c >= TODAY) ' +
            ' order by Active_vod__c desc';
             
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,  List<sObject> batch){ 
        List<Cycle_Plan_vod__c> listToInactivate = new List<Cycle_Plan_vod__c>();
        List<Cycle_Plan_vod__c> listToActivate = new List<Cycle_Plan_vod__c>();
        
        for (sObject obj : batch) {
            Cycle_Plan_vod__c cp = (Cycle_Plan_vod__c) obj;
            
            if (cp.Active_vod__c && (Date.today() < cp.Start_Date_vod__c || Date.today() > cp.End_Date_vod__c)){
                // 1. Active but not have started (somebody loaded active plans in the future)
                // 2. Active and end date has passed
                cp.Active_vod__c = false;
                listToInactivate.add(cp);
            }
            else if (!cp.Active_vod__c && Date.today() >= cp.Start_Date_vod__c  && Date.today() <= cp.End_Date_vod__c) {
                // 3. Inactive and in the current cycle (activate it)
                cp.Active_vod__c = true;
                listToActivate.add(cp);
            }
        }
        
        if (listToInactivate.size() > 0) update listToInactivate;
        if (listToActivate.size() > 0) update listToActivate;
    }

    global void finish(Database.BatchableContext BC) {}
    
}