/**
 *  CalculatePlanTotalsTrigPMBI
 *  Created Date: 7 Feb 2013
 *  Created By: Roman Lerman
 *  Description: This class calculates the unallocated amount for a plan based on the plan total amounts of its children.
 */
public class CalculatePlanTotalsTrigPMBI implements TriggersBI.HandlerInterface
{  
    public void execute(list<Plan_BI__c> newPlans, list<Plan_BI__c> oldPlans)
    {

        Set<Id> parentPlans = new Set<Id>();
        for(Integer x=0; x<newPlans.size(); x++){
            if(Trigger.isInsert || newPlans[x].Plan_Total_Amount_BI__c != oldPlans[x].Plan_Total_Amount_BI__c){
                if(newPlans[x].Parent_Plan_BI__c != null){
                    parentPlans.add(newPlans[x].Id);
                    parentPlans.add(newPlans[x].Parent_Plan_BI__c);
                }
            }
        }
        
        if(parentPlans != null && parentPlans.size() > 0){
            List<Plan_BI__c> plans = [select Id, Plan_Total_Amount_BI__c, Unallocated_Amount_BI__c, (select Id, Plan_Total_Amount_BI__c from Sub_Plans__r) from Plan_BI__c where Id in :parentPlans];
            
            for(Plan_BI__c parentPlan:plans){
                Decimal total = 0;
                for(Plan_BI__c childPlan:parentPlan.Sub_Plans__r){
                    total += childPlan.Plan_Total_Amount_BI__c;
                } 
                parentPlan.Unallocated_Amount_BI__c = parentPlan.Plan_Total_Amount_BI__c - total;   
            }
            
            update plans;
        }
     
    }
    
    public void handle() 
    {
        execute((list<Plan_BI__c>) trigger.new, (list<Plan_BI__c>) trigger.old); 
    }
}