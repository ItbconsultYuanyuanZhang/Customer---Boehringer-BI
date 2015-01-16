/**
 *  PlanViewSummaryControllerPMBITest
 *  @author: John Daniel john@mavensconsulting.com
 *  Created Date: 19 JAN 2013
 *  Description: The test class deals with all tests need for the PlanViewSummaryControllerPMBI class
 * 
 */
@isTest
private class PlanViewSummaryControllerPMBITest 
{
    static Plan_BI__c plan;
    static Plan_BI__c plan2;   

    static {
        TestUtilsPMBI.setupAllCustomSettings();
        plan = TestUtilsPMBI.createPlan();
        plan2 = TestUtilsPMBI.createPlan(plan);
    }
    
    static testMethod void testControllerAttributes()
    {
   
        Test.startTest(); 
            TestUtilsPMBI.createPlan();
            TestUtilsPMBI.createPlan();
            TestUtilsPMBI.createPlan();
        Test.stopTest();
        
        PlanViewSummaryControllerPMBI controller = new PlanViewSummaryControllerPMBI();
        
        System.assert(controller.planYearsAvailable.size() == 11);
        System.assert(controller.planYearsAvailable[0].getValue() == String.valueOf(Date.today().year()-5));
        
        controller.selectedPlanYear = controller.planYearsAvailable[0].getValue();
        System.assert(controller.showYTDActuals);
        controller.selectedPlanYear = controller.planYearsAvailable[5].getValue();
        System.assert(controller.showYTDActuals);
        System.assertEquals(3, controller.maximumDepthToShow);
        System.assertEquals(true, controller.hasPlanBeenFound);
        //System.assertEquals(false, controller.showYTDPlan);
        controller.toggleEditMode();
        //System.assert(!controller.showYTDPlan);
        controller.toggleEditMode();
        System.assert(!controller.hasError);        
        System.assert(!controller.hasMessages);
        System.assert(controller.getThis() == controller);
        System.assert(!controller.getStatusOptions().isEmpty());        
    }

    static testMethod void testExerciseDynamicVisualforceCreation()
    {
        System.currentPageReference().getParameters().put('id', plan.Id);

        PlanViewSummaryControllerPMBI controller = new PlanViewSummaryControllerPMBI();
    
        Test.startTest();
            //exercise the code
            controller.getThePanel();
            controller.toggleEditMode();
            controller.getThePanel();            
        Test.stopTest();
        
        //make sure the parenthierarchy gets created correctly
        System.currentPageReference().getParameters().put('id', plan2.Id);
        controller.refreshData();
        System.assert(controller.parentPlanHierarchy.size() == 1);
        System.assert(controller.parentPlanHierarchy[0].id == plan.id);

    } 

    static testMethod void testUpdateDataUpdatesDatabase() {
        plan.Plan_Total_Amount_BI__c   = 10;
        plan.Unallocated_Amount_BI__c  = 5;
        plan2.Plan_Total_Amount_BI__c  = 5;
        plan2.Unallocated_Amount_BI__c = 5;
        
        Test.startTest();
            update plan;
            update plan2;
        Test.stopTest();
                
        System.currentPageReference().getParameters().put('id', plan.Id);
        PlanViewSummaryControllerPMBI controller = new PlanViewSummaryControllerPMBI();            
        
        controller.tempParentPlanId = plan.id;
        controller.tempPlanId = plan2.id;
        controller.tempPlanAmount = '10';
        controller.savePlan();

        System.assertEquals(0, [select Unallocated_Amount_BI__c from Plan_BI__c where Id = :plan.id].Unallocated_Amount_BI__c);     
    }
    
    static testMethod void testBadPlanTotalAmount() {
        plan.Plan_Total_Amount_BI__c   = 10;
        plan.Unallocated_Amount_BI__c  = 5;
        plan2.Plan_Total_Amount_BI__c  = 5;
        plan2.Unallocated_Amount_BI__c = 5;
        
        Test.startTest();
            update plan;
            update plan2;
        Test.stopTest();
        
        System.currentPageReference().getParameters().put('id', plan.Id);
        PlanViewSummaryControllerPMBI controller = new PlanViewSummaryControllerPMBI();            
        
        controller.tempParentPlanId = plan.id;
        controller.tempPlanId = plan2.id;
        controller.tempPlanAmount = 'abc';
        controller.savePlan();

        System.assertEquals(5, [select Plan_Total_Amount_BI__c from Plan_BI__c where Id = :plan2.id].Plan_Total_Amount_BI__c);    
    }

    static testMethod void testUnallocatedUnderZeroFails() {
        plan.Plan_Total_Amount_BI__c   = 10;
        plan.Unallocated_Amount_BI__c  = 5;
        plan2.Plan_Total_Amount_BI__c  = 5;
        plan2.Unallocated_Amount_BI__c = 5;
        
        Test.startTest();
            update plan;
            update plan2;
        Test.stopTest();
        
        plan2.Plan_Total_Amount_BI__c = 11;
        try {
            update plan2;
        } catch(System.DMLException e) {                
            System.assert(e.getMessage().contains('Amount entered would make the unallocated amount for'));
            return;
        }
        System.assert(false, 'error was not thrown');
    }

    static testMethod void testCreateNewFundRequest() {
        System.currentPageReference().getParameters().put('id', plan.Id);
        PlanViewSummaryControllerPMBI controller = new PlanViewSummaryControllerPMBI();

        controller.planId = plan.Id;
        controller.amountRequested = '1';
        controller.details = 'some details';

        Test.startTest();
            controller.saveFundRequest();
        Test.stopTest();

        List<Fund_Request_BI__c> reqs = [select Id
                                            from Fund_Request_BI__c 
                                            where Plan__c = :plan.Id 
                                                AND Amount_Requested__c = 1];
        System.assert(reqs.size() == 1);        
    }

    static testMethod void testUpdateFundRequest() {
        Fund_Request_BI__c req = new Fund_Request_BI__c(Plan__c=plan.id, Amount_Requested__c=1, Details__c='some details');
        insert req;

                
        PlanViewSummaryControllerPMBI controller = new PlanViewSummaryControllerPMBI();

        controller.fundRequestId = req.Id;
        controller.amountRequested = '2';
        controller.status = 'Approved';

        Test.startTest();
            controller.updateFundRequest();
        Test.stopTest(); 

        List<Fund_Request_BI__c> reqs = [select Id 
                                            from Fund_Request_BI__c 
                                            where Id = :req.Id 
                                                AND Amount_Requested__c = 1                                                 
                                                AND Status__c = 'Approved'];
        System.assert(reqs.size() == 1); 
    }

    static testMethod void updateTopLevelPlan() {
        
        System.currentPageReference().getParameters().put('id', plan.id);
        PlanViewSummaryControllerPMBI controller = new PlanViewSummaryControllerPMBI();

        controller.tempParentPlanId = null;
        controller.tempPlanId = plan.id;
        controller.tempPlanAmount = '1';
            
        Test.startTest();
            controller.savePlan();
        Test.stopTest();
        List<Plan_BI__c> plans = [select id
                                     from Plan_BI__c
                                     where Id = :plan.id
                                        AND Plan_Total_Amount_BI__c = 1];
        System.assert(plans.size() == 1);
    }

    static testMethod void savePlanWithBadValueErrors () {
                   
        PlanViewSummaryControllerPMBI controller = new PlanViewSummaryControllerPMBI();

        controller.tempParentPlanId = plan.id;
        controller.tempPlanId = plan2.id;
        controller.tempPlanAmount = '999999999';

        Test.startTest();   
            controller.savePlan();
        Test.stopTest();
            
        System.assert(controller.errorMessage.startsWith('Amount entered would make the unallocated amount'));
    }

    static testMethod void saveFundRequestWithBadValueErrors () {        
        PlanViewSummaryControllerPMBI controller = new PlanViewSummaryControllerPMBI();
        controller.amountRequested = '-1';
        controller.details = 'some details';
        controller.planId = plan.id;
        controller.tempPlanOwnerId = UserInfo.getUserId();
        
        Test.startTest();
            controller.saveFundRequest();            
        Test.stopTest();
        
        System.assert(controller.hasError);            
    }

    static testMethod void updateFundRequestWithBadValueErrors () {        
        Fund_Request_BI__c req = new Fund_Request_BI__c(Plan__c=plan.id, Amount_Requested__c=1, Details__c='some details');
        insert req;

        PlanViewSummaryControllerPMBI controller = new PlanViewSummaryControllerPMBI();
        controller.fundRequestId = req.id;
        controller.amountGranted = '-1';
        controller.status = 'Approved';
        
        Test.startTest();
            controller.updateFundRequest();            
        Test.stopTest();

        System.assert(controller.hasError);            
    }
}