/**
 *  CalculatePlanAllocations
 *  Created Date: 13 Feb 2013
 *  Created By: Roman Lerman
 *  Description: This class kicks off a utility that recalculates Plan actuals whenever a Fixed Allocation amount is changed or a fixed allocation is
 *               associated with another plan.
 */
public with sharing class CalculatePlanAllocations implements TriggersBI.HandlerInterface
{   
    public void execute(list<Fixed_Allocation_BI__c> newFixedAllocations, list<Fixed_Allocation_BI__c> oldFixedAllocations)
    {
        Set<Id> planIds = new Set<Id>();
        for(Integer x=0; x<newFixedAllocations.size(); x++){
            if((Trigger.isInsert 
                && newFixedAllocations[x].Status_BI__c != null 
                && Config_Settings_PMBI__c.getOrgDefaults().Fixed_Allocation_Status__c.contains(newFixedAllocations[x].Status_BI__c))){
                  if(newFixedAllocations[x].Plan_BI__c != null){
                    planIds.add(newFixedAllocations[x].Plan_BI__c);
                  }
            }
            if(Trigger.isUpdate && (
                        (newFixedAllocations[x].Plan_BI__c != oldFixedAllocations[x].Plan_BI__c) ||
                        (newFixedAllocations[x].Status_BI__c != oldFixedAllocations[x].Status_BI__c) ||
                        (newFixedAllocations[x].Allocated_Amount_BI__c != oldFixedAllocations[x].Allocated_Amount_BI__c))){
                  if(newFixedAllocations[x].Plan_BI__c != null){
                    planIds.add(newFixedAllocations[x].Plan_BI__c);
                  }
                  
                  if(newFixedAllocations[x].Plan_BI__c != oldFixedAllocations[x].Plan_BI__c){
                      if(oldFixedAllocations[x].Plan_BI__c != null){
                          planIds.add(oldFixedAllocations[x].Plan_BI__c);
                      }
                  }
            }
        }
        if(planIds != null && planIds.size() > 0){
            ExpenseAndFixedAllocationUtilityPMBI.rollupExpensesAndFixedAllocations(planIds);
        }
    }
    
    public void handle() 
    {
        execute((list<Fixed_Allocation_BI__c>) trigger.new, (list<Fixed_Allocation_BI__c>) trigger.old);
    }
}