/**
 *  CreatePlanSharingRuleTrigPMBI
 *  Created Date: 11 Feb 2013
 *  Created By: Roman Lerman
 *  Description: This class creates a sharing rule to provide Read Only access to a plan directly above in the hierarchy to a plan a user owns.
 */
public with sharing class CreatePlanSharingRuleTrigPMBI implements TriggersBI.HandlerInterface
{   
    public void execute(list<Plan_BI__c> newPlans)
    {
        List<Plan_BI__Share> planShareRecords = new List<Plan_BI__Share>();
        for(Plan_BI__c plan:newPlans){
            if(plan.Parent_Plan_BI__c != null){
                Plan_BI__Share planShare = new Plan_BI__Share();
                planShare.ParentId = plan.Parent_Plan_BI__c;
                planShare.UserOrGroupId = plan.OwnerId;
                planShare.AccessLevel = Config_Settings_PMBI__c.getOrgDefaults().Access_Level_Read__c;
                
                planShareRecords.add(planShare);
            }
        }
        
        if(planShareRecords != null && planShareRecords.size() > 0){
            // If the person trying to be given manual access of the parent record is already the owner of the parent record
            // this will fail, but that's ok since they already have access
            // Allowing partial success here for that reason
            
            Database.SaveResult[] lsr = Database.insert(planShareRecords, false);
            // Iterate through the Save Results
            for(Database.SaveResult sr:lsr){
               if(!sr.isSuccess())
                  System.debug('Sharing Rule Intert Error: '+sr.getErrors());
                }
            }
    }
    
    public void handle() 
    {
        execute((list<Plan_BI__c>) trigger.new); 
    }
}