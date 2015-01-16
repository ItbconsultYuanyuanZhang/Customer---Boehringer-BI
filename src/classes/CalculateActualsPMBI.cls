/**
 *  CalculateActualsPMBI
 *  Created Date: 13 Feb 2013
 *  Created By: Roman Lerman
 *  Description: This class calculates actuals when total expense/allocation amounts are modified.  The rollup summaries on the Medical Event
 *               are used to detect this event.
 */
public without sharing class CalculateActualsPMBI implements TriggersBI.HandlerInterface
{   
    public void execute(list<Medical_Event_vod__c> newMedicalEvents, list<Medical_Event_vod__c> oldMedicalEvents)
    {
        Set<Id> planIds = new Set<Id>();
        for(Integer x=0; x<newMedicalEvents.size(); x++){
            if(Trigger.isInsert || ((newMedicalEvents[x].Total_Cost_BI__c != oldMedicalEvents[x].Total_Cost_BI__c) ||
                (newMedicalEvents[x].Total_Event_Allocations_BI__c != oldMedicalEvents[x].Total_Event_Allocations_BI__c))){
                if(newMedicalEvents[x].Plan_BI__c != null){
                    planIds.add(newMedicalEvents[x].Plan_BI__c);
                }
            }
        }

        if(planIds != null && planIds.size() > 0){
            ExpenseAndFixedAllocationUtilityPMBI.rollupExpensesAndFixedAllocations(planIds);
        }
    }
    
    public void handle() 
    {
        execute((list<Medical_Event_vod__c>) trigger.new, (list<Medical_Event_vod__c>) trigger.old); 
    }
}