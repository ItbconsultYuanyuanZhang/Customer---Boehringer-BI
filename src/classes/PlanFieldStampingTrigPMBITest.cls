/**
 *  PlanFieldStampingTrigPMB Test Class
 *  @author: Roman Lerman roman@mavensconsulting.com
 *  Created Date: 28 JAN 2013
 *  Description: This is a test class for the PlanFieldStampingTrigPMBTest class.  
 * 
 */
@isTest
private class PlanFieldStampingTrigPMBITest{
    static void checkFields(Plan_BI__c plan, Integer tier, String therapeuticArea, String product, String budget, String project){
        System.assertEquals(plan.Tier_BI__c, tier);
        System.assertEquals(plan.Therapeutic_Area_BI__c, therapeuticArea);
        System.assertEquals(plan.Product_BI__c, product);
        System.assertEquals(plan.Budget_BI__c, budget);
        System.assertEquals(plan.Project_BI__c, project);
    } 
    static testMethod void testStampingOfPlanFields(){
        TestUtilsPMBI.setupAllCustomSettings();
        
        Integer counter = 0;
        Plan_BI__c previousPlan;
        Plan_BI__c temp;
        
        List<Plan_BI__c> planList = new List<Plan_BI__c>();
        List<App_Settings_pm_bi__c> planTiers = [select Name, Sort_Order__c from App_Settings_pm_bi__c order by Sort_Order__c];
        for(App_Settings_pm_bi__c planTier:planTiers){
            if(counter == 0){
                temp = TestUtilsPMBI.generatePlan();
            }else{
                temp = TestUtilsPMBI.generatePlan(previousPlan);   
            }
            temp.Name = planTier.Name;
            temp.Type_BI__c = planTier.Name;
            temp.Project_BI__c = 'Test';
            
            insert temp;
            
            System.debug(temp.Name+' : '+[select Id, Name, Type_BI__c, Tier_BI__c, Therapeutic_Area_BI__c, Product_BI__c, Budget_BI__c, Project_BI__c, Parent_Plan_BI__r.Name 
                                        from Plan_BI__c 
                                        where Id=:temp.Id]);
            
            planList.add(temp);
             
            previousPlan = temp;
            
            if(counter == 19) break;
            
            counter ++;
        }
        
        List<Plan_BI__c> plans = [select Id, Type_BI__c, Tier_BI__c, Therapeutic_Area_BI__c, Product_BI__c, Budget_BI__c, Project_BI__c 
                                        from Plan_BI__c 
                                        where Id in :planList
                                        and (Type_BI__c = 'Therapeutic Area'
                                             or Type_BI__c = 'Product'
                                             or Type_BI__c = 'Budget'
                                             or Type_BI__c = 'Project'
                                             or Type_BI__c = 'Region')];
        
        Map<String, Plan_BI__c> planMap = new Map<String, Plan_BI__c>();                                     
        for(Plan_BI__c plan:plans){
            if(plan.Type_BI__c == 'Therapeutic Area'){
                checkFields(plan, 2, null, null, null, null);
            }else if(plan.Type_BI__c == 'Product'){
                checkFields(plan, 3, 'Therapeutic Area', null, null, null);
            }else if(plan.Type_BI__c == 'Budget'){
                checkFields(plan, 4, 'Therapeutic Area', 'Product', null, null);
            }else if(plan.Type_BI__c == 'Project'){
                System.debug('Plan: '+plan);
                checkFields(plan, 5, 'Therapeutic Area', 'Product', 'Budget', null);
            }else if(plan.Type_BI__c == 'Region'){
                checkFields(plan, 6, 'Therapeutic Area', 'Product', 'Budget', 'Project');
            }
        }                                   
    }   
}