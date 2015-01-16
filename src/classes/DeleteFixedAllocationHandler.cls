/**
 *  DeleteFixedAllocationHandler
 *  Created Date: 18 Feb 2013
 *  Created By: Roman Lerman
 *  Description: This class kicks off the recalculation of plan actuals whenever a fixed allocation is deleted.
 */
public with sharing class DeleteFixedAllocationHandler implements TriggersBI.HandlerInterface
{   
    public void execute(list<Fixed_Allocation_BI__c> oldFixedAllocations)
    {
        System.debug('Entering the delete trigger');
        Set<Id> planIds = new Set<Id>();
        for(Fixed_Allocation_BI__c fixedAllocation:oldFixedAllocations){
            if(fixedAllocation.Plan_BI__c != null){
                planIds.add(fixedAllocation.Plan_BI__c);
            }
        }
        System.debug('Plan Ids List');
        if(planIds != null && planIds.size() > 0){
            System.debug('Deleting the fixed allocation');
            ExpenseAndFixedAllocationUtilityPMBI.rollupExpensesAndFixedAllocations(planIds);   
        }
    }
    
    public void handle() 
    {
        execute((list<Fixed_Allocation_BI__c>) trigger.old);
    } 
}