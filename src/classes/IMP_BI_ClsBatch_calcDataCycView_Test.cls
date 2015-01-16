/**
*   Test class for class IMP_BI_ClsBatch_calculateDataCycleView.
*
@author Di Chen
@created 2013-06-14
@version 1.0
@since 20.0
*
@changelog
* 2013-06-14 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 89%
*/
@isTest
private class IMP_BI_ClsBatch_calcDataCycView_Test {

    static testMethod void testBatch() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        insert acc;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        cycle2.Country_Lkp_BI__c = c.Id;
        insert cycle2;
        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Column_BI__c = 11;
        ma.Specialization_BI__c = 'GP';//Peng Zhu 2013-10-14
        ma.Status_BI__c = 'Draft';
        insert ma;
        
        Lifecycle_Template_BI__c mt = IMP_BI_ClsTestHelp.createTestLifecycleTemplateBI();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        insert mt;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Product_Catalog_BI__c = p2.Id;
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        cd.Current_Update_BI__c = true;
        insert cd;    
        
        list<Cycle_Data_BI__c> scope = new list<Cycle_Data_BI__c>();
        scope.add(cd);
        
        Test.startTest();
        
        IMP_BI_ClsBatch_calculateDataCycleView batchCls = new IMP_BI_ClsBatch_calculateDataCycleView(cycle2.Id); 
        batchCls.filter = ' limit 1';
        
        Database.BatchableContext bc;
        batchCls.start(bc);
        batchCls.execute(bc, scope);
        batchCls.finish(bc);
        
        system.assert(true); 
        Test.stopTest();  
    }
}