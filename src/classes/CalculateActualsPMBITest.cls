/**
 *  CalculateActualsPMBITest
 *  Created Date: 13 Feb 2013
 *  Created By: Roman Lerman
 *  Description: This is a test class for the CalculateActualsPMBITest class.
 */
@isTest
private class CalculateActualsPMBITest 
{
    static Plan_BI__c parentPlan;
    static Plan_BI__c plan;
    static Plan_BI__c plan2;
    static Event_Expenses_BI__c eventExpenses = new Event_Expenses_BI__c();
    static Event_Expenses_BI__c eventExpenses2 = new Event_Expenses_BI__c();
    static Event_Expenses_BI__c eventExpenses3 = new Event_Expenses_BI__c();
    static Event_Expenses_BI__c eventExpenses4 = new Event_Expenses_BI__c();  
    static Fixed_Allocation_BI__c fixedAllocation = new Fixed_Allocation_BI__c();
    static Fixed_Allocation_BI__c fixedAllocation2 = new Fixed_Allocation_BI__c();
    static Cheque_Request_BI__c chequeRequest = new Cheque_Request_BI__c();
    static Cheque_Request_BI__c chequeRequest2 = new Cheque_Request_BI__c(); 

    static {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User usr = new User(Alias = 'veevabi', Email='stusveevabi@bi.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='stusveevabi@bi.com');
        User usr2 = new User(Alias = 'veevabi2', Email='stusveevabi2@bi.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='stusveevabi2@bi.com');
        User usr3 = new User(Alias = 'veevabi3', Email='stusveevabi3@bi.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='stusveevabi3@bi.com');
        User usr4 = new User(Alias = 'veevabi4', Email='stusveevabi4@bi.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='stusveevabi4@bi.com');
        
        insert usr;
        insert usr2;
        insert usr3;
        insert usr4;
        
        TestUtilsPMBI.setupAllCustomSettings();
        parentPlan = TestUtilsPMBI.createPlan();
        plan = TestUtilsPMBI.createPlan();
        plan2 = TestUtilsPMBI.createPlan();
        
        plan.Parent_Plan_BI__c = parentPlan.Id;
        plan2.Parent_Plan_BI__c = parentPlan.Id;
        
        update plan;
        update plan2;
        
        Test.setCurrentPage(Page.PlanViewSummaryPMBI);
        
        Medical_Event_vod__c event = new Medical_Event_vod__c();
        Medical_Event_vod__c event2 = new Medical_Event_vod__c();
        
        event.Plan_BI__c  = plan.Id;
        event2.Plan_BI__c = plan2.Id;
        
        insert event;
        insert event2;
        
        Event_Team_Member_BI__c eventTeamMember = new Event_Team_Member_BI__c();
        Event_Team_Member_BI__c eventTeamMember2 = new Event_Team_Member_BI__c();
        Event_Team_Member_BI__c eventTeamMember3 = new Event_Team_Member_BI__c();
        Event_Team_Member_BI__c eventTeamMember4 = new Event_Team_Member_BI__c();
        
        eventTeamMember.Event_Management_BI__c = event.Id;
        eventTeamMember2.Event_Management_BI__c = event.Id;
        eventTeamMember3.Event_Management_BI__c = event2.Id;
        eventTeamMember4.Event_Management_BI__c = event2.Id;
        
        eventTeamMember.User_BI__c = usr.Id;
        eventTeamMember2.User_BI__c = usr2.Id;
        eventTeamMember3.User_BI__c = usr3.Id;
        eventTeamMember4.User_BI__c = usr4.Id;
        
        insert eventTeamMember;
        insert eventTeamMember2;
        insert eventTeamMember3;
        insert eventTeamMember4;
        
        eventExpenses.Event_Team_Member_BI__c = eventTeamMember.Id;
        eventExpenses2.Event_Team_Member_BI__c = eventTeamMember2.Id;
        eventExpenses3.Event_Team_Member_BI__c = eventTeamMember3.Id;
        eventExpenses4.Event_Team_Member_BI__c = eventTeamMember4.Id;
        
        eventExpenses.Amount_BI__c = 1000;
        eventExpenses2.Amount_BI__c = 1000;
        eventExpenses3.Amount_BI__c = 1000;
        eventExpenses4.Amount_BI__c = 1000;
        
        insert eventExpenses;
        insert eventExpenses2;
        insert eventExpenses3;
        insert eventExpenses4;
        
        system.assertEquals(2000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :plan.Id].Actuals_Total_Amount_BI__c);
        
        chequeRequest.Status_BI__c = 'Paid';
        chequeRequest.Cancelled_BI__c = false;
        chequeRequest.Request_Amount_BI__c = 1000;
        chequeRequest.Event_Team_Member_BI__c = eventTeamMember2.Id;
        
        chequeRequest2.Status_BI__c = 'Paid';
        chequeRequest2.Cancelled_BI__c = false;
        chequeRequest2.Request_Amount_BI__c = 1000;
        chequeRequest2.Event_Team_Member_BI__c = eventTeamMember4.Id;
        
        fixedAllocation.Allocated_Amount_BI__c = 1000;
        fixedAllocation2.Allocated_Amount_BI__c = 1000;
        
        fixedAllocation.Plan_BI__c = plan2.Id;
        
        fixedAllocation.Event_Team_Member_BI__c = eventTeamMember2.Id;
        fixedAllocation2.Event_Team_Member_BI__c = eventTeamMember4.Id;
        
        fixedAllocation.Status_BI__c = 'Paid';
        fixedAllocation2.Status_BI__c = 'Paid';
        
        insert fixedAllocation;
        insert fixedAllocation2;
             
        insert chequeRequest;
        insert chequeRequest2;
    }
    static testMethod void testActualsInsertCalculation()
    {
        Test.startTest();
            Set<Id> plans = new Set<Id>();
            
            plans.add(plan.Id);
            plans.add(plan2.Id);
            plans.add(parentPlan.Id);
            
            Map<Id, Plan_BI__c> mapOfPlans = new Map<Id, Plan_BI__c>([select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :plans]);
            System.assertEquals(2000, mapOfPlans.get(plan.Id).Actuals_Total_Amount_BI__c);
            System.assertEquals(3000, mapOfPlans.get(plan2.Id).Actuals_Total_Amount_BI__c);
            System.assertEquals(5000, mapOfPlans.get(parentPlan.Id).Actuals_Total_Amount_BI__c);
        Test.stopTest();
    }
    static testMethod void testActualsUpdateCalculation()
    {
        Test.startTest();
            eventExpenses.Amount_BI__c = 3000;
            fixedAllocation.Allocated_Amount_BI__c = 2000;
            
            update eventExpenses;
            update fixedAllocation;
    
            System.assertEquals(3000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :plan.Id].Actuals_Total_Amount_BI__c);
            System.assertEquals(4000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :plan2.Id].Actuals_Total_Amount_BI__c);
            System.assertEquals(7000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :parentPlan.Id].Actuals_Total_Amount_BI__c);
        Test.stopTest();
    }
    static testMethod void testActualsUpdateStatusCalculation()
    {
        Test.startTest();
            fixedAllocation.Status_BI__c = 'Planned';
        
            update fixedAllocation;
        
            System.assertEquals(3000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :plan.Id].Actuals_Total_Amount_BI__c);
            System.assertEquals(2000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :plan2.Id].Actuals_Total_Amount_BI__c);
            System.assertEquals(5000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :parentPlan.Id].Actuals_Total_Amount_BI__c);
        Test.stopTest();
    }
    static testMethod void testActualsUpdatePlanCalculation()
    {
        Test.startTest();
            fixedAllocation2.Plan_BI__c = plan.Id;
        
            update fixedAllocation2;
        
            System.assertEquals(3000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :plan.Id].Actuals_Total_Amount_BI__c);
            System.assertEquals(3000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :plan2.Id].Actuals_Total_Amount_BI__c);
            System.assertEquals(6000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :parentPlan.Id].Actuals_Total_Amount_BI__c);
        Test.stopTest();
    }
    static testMethod void testActualsDeleteCalculation()
    {
        Test.startTest();
            delete fixedAllocation;
        
            System.assertEquals(3000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :plan.Id].Actuals_Total_Amount_BI__c);
            System.assertEquals(2000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :plan2.Id].Actuals_Total_Amount_BI__c);
            System.assertEquals(5000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :parentPlan.Id].Actuals_Total_Amount_BI__c);
        Test.stopTest();
    }
    static testMethod void testMoveFixedAllocation()
    {
        Test.startTest();
            fixedAllocation.Plan_BI__c = plan.Id;
            
            update fixedAllocation;
        
            System.assertEquals(3000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :plan.Id].Actuals_Total_Amount_BI__c);
            System.assertEquals(2000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :plan2.Id].Actuals_Total_Amount_BI__c);
            System.assertEquals(5000, [select Actuals_Total_Amount_BI__c from Plan_BI__c where Id = :parentPlan.Id].Actuals_Total_Amount_BI__c);
        Test.stopTest();
    }
}