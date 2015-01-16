/**
 *  PlanFieldStampingTrigPMBI
 *  @author: John M. Daniel john@mavensconsulting.com
 *  Created Date: 24 JAN 2013
 *  Description: This class deals with the field stamping of values to the Plan_BI__c object.  
 * 
 */
public without sharing class PlanFieldStampingTrigPMBI implements TriggersBI.HandlerInterface
{
    public void execute(list<Plan_BI__c> plansToOperateOn)
    {
        Set<Id> parentIds = new Set<Id>();
        
        // Get the parent plan ids for the records in the batch
        for (Plan_BI__c plan : plansToOperateOn)
        {
            if (plan.Parent_Plan_BI__c != null)
            {
                parentIds.add(plan.Parent_Plan_BI__c);   
            }
        }
        // Get the parent plans 
        Map<Id, Plan_BI__c> parentPlans = new Map<Id, Plan_BI__c>([select Id, Country_Code_BI__c, Type_BI__c, Parent_Plan_BI__c, Therapeutic_Area_BI__c, Tier_Bi__c, Name, Product_BI__c, Project_BI__c, Budget_BI__c from Plan_BI__c where Id in: parentIds]);
        Plan_BI__c parentPlan = null;
        
        for (Plan_BI__c plan : plansToOperateOn) 
        {
            // field stamp the plan hierarchy tier number
            if(App_Settings_pm_bi__c.getAll().get(plan.Type_BI__c) != null && plan.Type_BI__c != null){    
                plan.Tier_Bi__c = App_Settings_pm_bi__c.getAll().get(plan.Type_BI__c).Sort_Order__c;
            }
            // If this is the top of the stack then we can just continue on.
            if (plan.Parent_Plan_BI__c == null) continue;

            // field stamp the therapeutic area, product and project fields from the parent record.
            parentPlan = parentPlans.get(plan.Parent_Plan_BI__c); 
            // TODO: The tiers values are hard coded.  Eventually we need to make those dynamic.
            System.debug(parentPlan);
            System.debug(parentPlan.Name);
            if (plan.Tier_Bi__c > Config_Settings_PMBI__c.getOrgDefaults().Tier2Value__c) 
            {
                plan.Therapeutic_Area_BI__c = parentPlan.Tier_Bi__c == Config_Settings_PMBI__c.getOrgDefaults().Tier2Value__c ? parentPlan.Name : parentPlan.Therapeutic_Area_BI__c;
            }
            else
            {
                plan.Therapeutic_Area_BI__c = null;
            }
                
            if (plan.Tier_Bi__c > Config_Settings_PMBI__c.getOrgDefaults().Tier3Value__c)
            {
                plan.Product_BI__c = parentPlan.Tier_Bi__c == Config_Settings_PMBI__c.getOrgDefaults().Tier3Value__c ? parentPlan.Name : parentPlan.Product_BI__c;
            }
            else
            {
                plan.Product_BI__c = null;
            }
            
            if (plan.Tier_Bi__c > Config_Settings_PMBI__c.getOrgDefaults().Tier4Value__c)
            {
                plan.Budget_BI__c = parentPlan.Tier_Bi__c == Config_Settings_PMBI__c.getOrgDefaults().Tier4Value__c ? parentPlan.Name : parentPlan.Budget_BI__c;
            }
            else
            {
                plan.Project_BI__c = null;
            }
            
            if (plan.Tier_Bi__c > Config_Settings_PMBI__c.getOrgDefaults().Tier5Value__c)
            {
                plan.Project_BI__c = parentPlan.Tier_Bi__c == Config_Settings_PMBI__c.getOrgDefaults().Tier5Value__c ? parentPlan.Name : parentPlan.Project_BI__c;
                System.debug('Plan Project: '+ plan.Project_BI__c);
            }
            else
            {
                plan.Project_BI__c = null;
            }
        }
        
        // If this code is executing outside of a trigger
        if ( ! trigger.isExecuting )
        {
            // ...then save the records directly.
           insert plansToOperateOn;
        }
    }
    
    public void handle() 
    {
        execute((list<Plan_BI__c>) trigger.new); 
    }
}