/**
 *  PlanPMBI Trigger
 *  @author: John M. Daniel john@mavensconsulting.com
 *  Created Date: 24 JAN 2013
 *  Description: This trigger handles all trigger needs for the Plan_pm_bi__c object.  It uses a 
 *          "Templated Trigger" design pattern to organize and execute the various logic that 
 *          could be utilized by a trigger for this object.  
 * 
 */
trigger PlanPMBI on Plan_BI__c
    (after insert, after update, before insert, before update) 
{
    new TriggersBI()
        // field stamp and auto data population tasks
        .bind(TriggersBI.Evt.beforeinsert, new PlanFieldStampingTrigPMBI())
        .bind(TriggersBI.Evt.beforeupdate, new PlanFieldStampingTrigPMBI())
        .bind(TriggersBI.Evt.afterupdate, new PlanFieldValidateTrigPMBI())
        .bind(TriggersBI.Evt.afterinsert, new RollUpActualsTrigPMBI())
        .bind(TriggersBI.Evt.afterupdate, new RollUpActualsTrigPMBI())
        .bind(TriggersBI.Evt.afterinsert, new CalculatePlanTotalsTrigPMBI())
        .bind(TriggersBI.Evt.afterupdate, new CalculatePlanTotalsTrigPMBI())
        .bind(TriggersBI.Evt.afterinsert, new CreatePlanSharingRuleTrigPMBI())
        

        // validation related items
        // post insert/update tasks  
        // Done with adding all handlers, lets call the manage method for all binds
        .manage();

}