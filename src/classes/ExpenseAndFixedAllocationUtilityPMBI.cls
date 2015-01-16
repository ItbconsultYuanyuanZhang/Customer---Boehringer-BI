/**
 *  ExpenseAndFixedAllocationUtilityPMBI
 *  Created Date: 13 Feb 2013
 *  Created By: Roman Lerman
 *  Description: This utility class is used to calculate plan actuals.
 */
public without sharing class ExpenseAndFixedAllocationUtilityPMBI{
    public static void rollupExpensesAndFixedAllocations(Set<Id> planIds){
        // Grab all of the expenses for all of the events for the plan
        Map<Id, Decimal> totalCostMap = new Map<Id, Decimal>();
        for(AggregateResult totalCost:[select Plan_BI__c, Sum(Total_Cost_BI__c) totalCost 
                                            from Medical_Event_vod__c where Plan_BI__c in :planIds group by Plan_BI__c]){
            totalCostMap.put((Id) totalCost.get('Plan_BI__c'), (Decimal) totalCost.get('totalCost'));                                   
        }
        
        // Grab all of the event allocations for all of the events for the plan
        Map<Id, Decimal> totalEventAllocationsMap = new Map<Id, Decimal>();
        for(AggregateResult totalEventAllocation: [select Plan_BI__c, Sum(Total_Event_Allocations_BI__c) totEvtAlloc 
                                                        from Medical_Event_vod__c 
                                                        where Plan_BI__c in :planIds group by Plan_BI__c]){
            totalEventAllocationsMap.put((Id) totalEventAllocation.get('Plan_BI__c'), (Decimal) totalEventAllocation.get('totEvtAlloc'));                                             
        }
        
        // Grab all of the plan allocations for all of the plans
        System.debug('Fixed Allocation List: '+Config_Settings_PMBI__c.getOrgDefaults().Fixed_Allocation_Status__c.split(';'));
        Map<Id, Decimal> totalPlanAllocations = new Map<Id, Decimal>();
        for(AggregateResult totalPlanAllocation:[select Plan_BI__c, Sum(Allocated_Amount_BI__c) totPlanAlloc 
                                                        from Fixed_Allocation_BI__c
                                                        where Plan_BI__c in :planIds 
                                                                and Status_BI__c in :Config_Settings_PMBI__c.getOrgDefaults().Fixed_Allocation_Status__c.split(';') 
                                                                group by Plan_BI__c]){
            totalPlanAllocations.put((Id) totalPlanAllocation.get('Plan_BI__c'), (Decimal) totalPlanAllocation.get('totPlanAlloc'));                   
        }
        
        List<Plan_BI__c> plans = new List<Plan_BI__c>();
        for(Id planId:planIds){
           Decimal totalCost = totalCostMap.get(planId) == null ? 0 : totalCostMap.get(planId);
           Decimal totalEventAllocation = totalEventAllocationsMap.get(planId) == null ? 0 : totalEventAllocationsMap.get(planId);
           Decimal totalPlanAllocation = totalPlanAllocations.get(planId) == null ? 0 : totalPlanAllocations.get(planId);
           
           System.debug('Total Cost: '+totalCost);
           System.debug('Total Event Allocation: '+totalEventAllocation);
           System.debug('Total Plan Allocation: '+totalPlanAllocation);
           
           Decimal actualsAmount =  (totalCost - totalEventAllocation) + totalPlanAllocation;
           
           System.debug('Actuals Amount: '+actualsAmount);
           
           plans.add(new Plan_BI__c(Id = planId, Actuals_Total_Amount_BI__c = actualsAmount)); 
        }   
        
        if(plans != null && plans.size() > 0){
            update plans;
        }                                     
    }
}