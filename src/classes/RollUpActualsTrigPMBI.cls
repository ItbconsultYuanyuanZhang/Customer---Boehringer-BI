/**
 *  RollUpActualsTrigPMBI
 *  @author: John Daniel john@mavensconsulting.com
 *  Created Date: 11 FEB 2013
 *  Description: This class rolls up the actuals from the child plans to the parent plan.
 * 
 */
public class RollUpActualsTrigPMBI implements TriggersBI.HandlerInterface
{  
    public void execute(list<Plan_BI__c> newPlans, list<Plan_BI__c> oldPlans)
    {
        System.debug('Roll up actuals');
        Set<Id> parentPlans = new Set<Id>();
        for(Integer x=0; x<newPlans.size(); x++){
            if(Trigger.isInsert || newPlans[x].Actuals_Total_Amount_BI__c != oldPlans[x].Actuals_Total_Amount_BI__c){
                System.debug('Parent Plan: '+newPlans[x].Parent_Plan_BI__c);
                if(newPlans[x].Parent_Plan_BI__c != null){
                    parentPlans.add(newPlans[x].Parent_Plan_BI__c);
                }
            }
        }
        
        System.debug('Parent Plans: '+parentPlans);
        if(parentPlans != null && parentPlans.size() > 0){
            List<Plan_BI__c> plans = [select Id, Actuals_Total_Amount_BI__c, Unallocated_Amount_BI__c, (select Id, Actuals_Total_Amount_BI__c from Sub_Plans__r) from Plan_BI__c where Id in :parentPlans];
            
            System.debug('Plans: '+plans);
            for(Plan_BI__c parentPlan:plans){
                Decimal total = 0;
                for(Plan_BI__c childPlan:parentPlan.Sub_Plans__r){
                    total += childPlan.Actuals_Total_Amount_BI__c;
                } 
                System.debug('Roll up total: '+total);
                parentPlan.Actuals_Total_Amount_BI__c = total;   
            }
            
            update plans;
        }
    }
    
    public void handle() 
    {
        execute((list<Plan_BI__c>) trigger.new, (list<Plan_BI__c>) trigger.old); 
    }
}