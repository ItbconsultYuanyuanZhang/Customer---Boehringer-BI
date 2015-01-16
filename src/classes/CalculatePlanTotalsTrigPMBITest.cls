/**
 *  CalculatePlanTotalsTrigPMBITest
 *  Created Date: 11 Feb 2013
 *  Created By: Roman Lerman
 *  Description: This is a test class for the CalculatePlanTotalsTrigPMBI class.
 */
@isTest
private class CalculatePlanTotalsTrigPMBITest { 
    static List<Plan_BI__c> plans = new List<Plan_BI__c>();
    static String refreshQuery = 'select Id, Plan_Total_Amount_BI__c, Unallocated_Amount_BI__c, Parent_Plan_BI__c, Type_BI__c from Plan_BI__c where Id IN :plans ORDER BY ID';
    static {
        TestUtilsPMBI.setupAllCustomSettings();

        for (Integer i=0; i<200; i++) {
            Integer initialAmount = i < 50 ? 90000 : 0 ;
            plans.add(
                new Plan_BI__c(
                        Name                  = 'Test Plan '+i, 
                        Plan_Total_Amount_BI__c  = initialAmount, 
                        Unallocated_Amount_BI__c = initialAmount,
                        Country_Code_BI__c       = 'CA',
                        Type_BI__c               = 'Therapeutic Area',
                        Plan_Year_BI__c          = String.valueOf( Date.today().year() )
                )
            );
        }
        insert plans;
        plans = Database.query(refreshQuery);
    }

    @isTest static void test_insert_plans_with_no_children_has_no_adverse_affects() {
        
        for (Integer i=0; i<plans.size(); i++) {
            Integer testAmount = i < 50 ? 90000 : 0 ;
            System.assert(plans[i].Plan_Total_Amount_BI__c == testAmount, 'Something changed the Plan Total Amount of this record.');
            System.assert(plans[i].Unallocated_Amount_BI__c == testAmount, 'Something changed the Unallocated Amount of this record.');
        }
    }

    @isTest static void test_insert_child_plans_updates_parent_plans() {
        Integer parentIndex = 0;
        
        //for records 50-199, assign them as children of records 0-49 in triplets
        //set the value of one record to 0 and other two to 45k. this should total
        //up to 90k setting the unallocatead value of the parent records to 0       
        for (Integer i=50; i<200; i=i+3) {
            plans[i].Parent_Plan_BI__c        = plans[parentIndex].id;
            plans[i].Type_BI__c               = 'Product';
            plans[i].Plan_Total_Amount_BI__c  = 0;
            plans[i].Unallocated_Amount_BI__c = 0;

            plans[i+1].Parent_Plan_BI__c        = plans[parentIndex].id;
            plans[i+1].Type_BI__c               = 'Product';
            plans[i+1].Plan_Total_Amount_BI__c  = 45000;
            plans[i+1].Unallocated_Amount_BI__c = 45000;

            plans[i+2].Parent_Plan_BI__c        = plans[parentIndex].id;
            plans[i+2].Type_BI__c               = 'Product';
            plans[i+2].Plan_Total_Amount_BI__c  = 45000;
            plans[i+2].Unallocated_Amount_BI__c = 45000;

            parentIndex++;
        }

        Test.startTest();
        {
            update plans;
        }

        plans = Database.query(refreshQuery);

        //now that we have updated the queries, the first 50 records should have unallocated amounts of 0
        for (Integer i=0; i<50; i++) {
            System.assert(plans[i].Unallocated_Amount_BI__c == 0, 'Unallocated Amount was not calculated correctly. Value is : ' + plans[i].Unallocated_Amount_BI__c);
        }
    }
}