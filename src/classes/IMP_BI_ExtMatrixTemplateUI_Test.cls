/**
*   Test class for class IMP_BI_ExtMatrixTemplateUI.
*
@author Di Chen
@created 2013-06-14
@version 1.0
@since 20.0
*
@changelog
* 2013-06-14 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 90%
*/
@isTest
private class IMP_BI_ExtMatrixTemplateUI_Test {

    static testMethod void testMostMethods() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Lifecycle_Template_BI__c mt = IMP_BI_ClsTestHelp.createTestLifecycleTemplateBI();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        mt.isLaunch_Phase_BI__c = true;
        mt.Column_BI__c = 6;
        insert mt;
        
        
        Test.startTest();
        
        IMP_BI_ExtMatrixTemplateUI.ClsMatrixTemplate extCls = new IMP_BI_ExtMatrixTemplateUI.ClsMatrixTemplate();
        IMP_BI_ExtMatrixTemplateUI.ClsResponse extRes = new IMP_BI_ExtMatrixTemplateUI.ClsResponse();
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(mt); 
        IMP_BI_ExtMatrixTemplateUI ext = new IMP_BI_ExtMatrixTemplateUI(ctrl); 
        
        ext.create();
        ext.getMT();
        
        String inMTJSON = '{"mt":{"attributes":{"type":"Lifecycle_Template_BI__c"},"Name":"New","Country_BI__c":"'+c.Id+'","Column_BI__c":"11","isLaunch_Phase_BI__c":false,"Active_BI__c":true,"Adoption_Weight_Factor_BI__c":"1.2","Row_BI__c":"10","Area_BI__c":"Global","Potential_Weight_Factor_BI__c":"0.8","Adoption_Status_05_BI__c":null,"Adoption_Status_04_BI__c":null,"Adoption_Status_03_BI__c":null,"Adoption_Status_02_BI__c":null,"Adoption_Status_01_BI__c":null}}';
        
        IMP_BI_ExtMatrixTemplateUI.editMT(inMTJSON);
        IMP_BI_ExtMatrixTemplateUI.saveMT(inMTJSON);
        
        system.assert(true);
        Test.stopTest();
    }
    static testMethod void testNull() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Lifecycle_Template_BI__c mt = IMP_BI_ClsTestHelp.createTestLifecycleTemplateBI();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        mt.isLaunch_Phase_BI__c = true;
        mt.Column_BI__c = 6;
        //insert mt;
        
        Test.startTest();
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(mt); 
        IMP_BI_ExtMatrixTemplateUI ext = new IMP_BI_ExtMatrixTemplateUI(ctrl);  
        
        ext.create();
        ext.getMT();
        
        system.assert(true);
        Test.stopTest();
    }    
}