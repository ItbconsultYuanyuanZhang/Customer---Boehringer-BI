/**
 *  TestUtilsPMBI
 *  @author: John Daniel john@mavensconsulting.com
 *  Created Date: 15 JAN 2013
 *  Description: The is a utility test class to aid in the development of other tests for 
 *          the BI Plan Management app.  It is designed to work along side the TestUtilsBI class. 
 * 
 */
@isTest
public class TestUtilsPMBI 
{
    public static Plan_BI__c createPlan()
    {
        return createPlan(null);
    }
    public static Plan_BI__c createPlan(final Plan_BI__c parentPlan)
    {
        Plan_BI__c testPlan = generatePlan(parentPlan);
        system.debug(testPlan);
        insert testPlan;
        return testPlan;
    }

    public static Plan_BI__c generatePlan()
    {
        return generatePlan(null);
    }

    public static Plan_BI__c generatePlan(final Plan_BI__c parentPlan)
    {
        Plan_BI__c testPlan = new Plan_BI__c();

        //testPlan.Actuals_Total_Amount__c
        //testPlan.Budget_Plan_Total_Amount__c = 0;
        testPlan.Country_Code_BI__c = 'CA';
        //testPlan.CurrencyIsoCode
        testPlan.Parent_Plan_BI__c = parentPlan == null ? null : parentPlan.id;
        testPlan.Plan_Year_BI__c = string.valueOf(date.today().year());
        //testPlan.Territory__c
        testPlan.Type_BI__c = 'Product';
        return testPlan;
    }

    public static void setupAllCustomSettings()
    {
        CustomDataSetupPMBI.setupAppSettingsPMBI();
    }
}