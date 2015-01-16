/**
 *  CustomDataSetupPMBITest
 *  @author: John Daniel john@mavensconsulting.com
 *  Created Date: 20 JAN 2013
 *  Description: The test class deals with all tests need for the CustomDataSetupPMBI class
 * 
 */
@isTest
private class CustomDataSetupPMBITest 
{
    static testMethod void test()
    {
        CustomDataSetupPMBI.setupAppSettingsPMBI();
        CustomDataSetupPMBI.setupPlanFactoryTypes();
        system.assert([select id from App_Settings_pm_bi__c].size() > 0);
        CustomDataSetupPMBI.setupAppSettingsPMBI();
    }
}