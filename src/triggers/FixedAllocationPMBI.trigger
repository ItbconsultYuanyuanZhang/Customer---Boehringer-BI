trigger FixedAllocationPMBI on Fixed_Allocation_BI__c (after insert, after update, after delete) {
     new TriggersBI()
        .bind(TriggersBI.Evt.afterinsert, new CalculatePlanAllocations())
        .bind(TriggersBI.Evt.afterupdate, new CalculatePlanAllocations())
        .bind(TriggersBI.Evt.afterdelete, new DeleteFixedAllocationHandler())
        .manage();
}