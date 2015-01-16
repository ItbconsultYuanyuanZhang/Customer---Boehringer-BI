/**
 *  CustomDataSetupPMBI
 *  Created Date: 20 JAN 2013
 *  Created By: John Daniel
 *  Description: This class as a way to seed data into Pulse related Custom Setting objects.
 *      The intent of this class is to provide a way to quickly establish data in a new ORG 
 *      environment.
 * 
 */
public class CustomDataSetupPMBI
{
    private static integer nameCounter = null;

    public static void setupAppSettingsPMBI()
    {
        delete [select id from App_Settings_pm_bi__c];
        
        setupPlanFactoryTypes();
        setupConfigDefaultTypes();
    }

    public static void setupConfigDefaultTypes() {
        if([select count() from Config_Settings_PMBI__c] == 0) {
            Config_Settings_PMBI__c newSetting = new Config_Settings_PMBI__c();
            insert newSetting;
        }
    }

    public static void setupPlanFactoryTypes()
    {
        delete [select id from App_Settings_pm_bi__c];

        list<App_Settings_pm_bi__c> settingsToInsert = new list<App_Settings_pm_bi__c>();
        App_Settings_pm_bi__c newSetting = null;
        newSetting = new App_Settings_pm_bi__c();
        newSetting.name = 'Country';
        newSetting.Sort_Order__c = 0;
        settingsToInsert.add(newSetting);
        newSetting = new App_Settings_pm_bi__c();
        newSetting.name = 'PMD';
        newSetting.Sort_Order__c = 1;
        settingsToInsert.add(newSetting);
        newSetting = new App_Settings_pm_bi__c();
        newSetting.name = 'Therapeutic Area';
        newSetting.Sort_Order__c = 2;
        settingsToInsert.add(newSetting);
        newSetting = new App_Settings_pm_bi__c();
        newSetting.name = 'Product';
        newSetting.Sort_Order__c = 3;
        settingsToInsert.add(newSetting);
        newSetting = new App_Settings_pm_bi__c();
        newSetting.name = 'Budget';
        newSetting.Sort_Order__c = 4;
        settingsToInsert.add(newSetting);
        newSetting = new App_Settings_pm_bi__c();
        newSetting.name = 'Project';
        newSetting.Sort_Order__c = 5;
        settingsToInsert.add(newSetting);
        newSetting = new App_Settings_pm_bi__c();
        newSetting.name = 'Region';
        newSetting.Sort_Order__c = 6;
        settingsToInsert.add(newSetting);
        newSetting = new App_Settings_pm_bi__c();
        newSetting.name = 'District';
        newSetting.Sort_Order__c = 7;
        settingsToInsert.add(newSetting);
        newSetting = new App_Settings_pm_bi__c();
        newSetting.name = 'Territory';
        newSetting.Sort_Order__c = 8;
        settingsToInsert.add(newSetting);
        insert settingsToInsert;
    }
}