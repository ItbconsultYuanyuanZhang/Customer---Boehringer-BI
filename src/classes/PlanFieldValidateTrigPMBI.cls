/**
 *  PlanFieldValidateTrigPMBI
 *  @author: Roman Lerman roman@mavensconsulting.com
 *  Created Date: 6 FEB 2013
 *  Description: This class throws a custom exception if the unallocated amount on a plan becomes negative.  
 * 
 */
public class PlanFieldValidateTrigPMBI implements TriggersBI.HandlerInterface
{   
    class CustomException extends Exception{}
    public void execute(list<Plan_BI__c> plansToOperateOn)
    {
        for(Plan_BI__c plan:plansToOperateOn){
            if(plan.Unallocated_Amount_BI__c < 0){
                throw new CustomException(System.Label.BI_PAGE_UNALLOCATED_AMOUNT_ERROR.replace('{0}', plan.Name + ' ' + plan.Unallocated_Amount_BI__c));
            }
        }
    }
    
    public void handle() 
    {
        execute((list<Plan_BI__c>) trigger.new); 
    }
}