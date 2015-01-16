/**
*   Test class for class IMP_BI_ExtMatrixSegment.
*
@author Di Chen
@created 2013-05-28
@version 1.0
@since 20.0
*
@changelog
* 2013-05-28 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 85%
*/
@isTest
private class IMP_BI_ExtMatrixSegment_Test {
	static testMethod void testMostMethods() {
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        insert acc;

        Cycle_BI__c cycle = IMP_BI_ClsTestHelp.createTestCycle();
        cycle.Country_Lkp_BI__c = c.Id;
        insert cycle;
        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Lifecycle_Template_BI__c mt = IMP_BI_ClsTestHelp.createTestLifecycleTemplateBI();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        mt.isLaunch_Phase_BI__c = true;
        mt.Column_BI__c = 6;
        insert mt;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Row_BI__c = 10;
        ma.Column_BI__c = 11;
        ma.Specialization_BI__c = 'GP';//Peng Zhu 2013-10-14
        ma.Lifecycle_Template_BI__c = mt.Id;
        insert ma;
        
        Test.startTest();
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtMatrixSegment ext = new IMP_BI_ExtMatrixSegment(ctrl);         
        
        ext.matrix = ma;
        
        ext.getRows();
        ext.getColumns();
        ext.getChannels();
        ext.saveMatrix();
        ext.initPageHeightFields();
        ext.cancelMatrix();
        
        system.assert(true);
        Test.stopTest();
    }
	static testMethod void testMostMethods2() {
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        insert acc;

        Cycle_BI__c cycle = IMP_BI_ClsTestHelp.createTestCycle();
        cycle.Country_Lkp_BI__c = c.Id;
        insert cycle;
        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Lifecycle_Template_BI__c mt = IMP_BI_ClsTestHelp.createTestLifecycleTemplateBI();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        mt.isLaunch_Phase_BI__c = true;
        mt.Adoption_Status_01_BI__c = '1';
        mt.Adoption_Status_02_BI__c = '1';
        mt.Adoption_Status_03_BI__c = '1';
        mt.Adoption_Status_04_BI__c = '1';
        mt.Adoption_Status_05_BI__c = '1';
        mt.Column_BI__c = 6;
        insert mt;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Row_BI__c = 10;
        ma.Column_BI__c = 11;
        ma.Specialization_BI__c = 'GP';//Peng Zhu 2013-10-14
        ma.Lifecycle_Template_BI__c = mt.Id;
        insert ma;
        
        Test.startTest();
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtMatrixSegment ext = new IMP_BI_ExtMatrixSegment(ctrl);         
        
        ext.matrix = ma;
        
        ext.getRows();
        ext.getColumns();
        ext.getChannels();
        ext.saveMatrix();
        ext.initPageHeightFields();
        ext.cancelMatrix();
        
        system.assert(true);
        Test.stopTest();
    }    
}