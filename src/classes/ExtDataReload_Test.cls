/**
*   Test class for class CtrlBatchCycleData.
*
@author Di Chen
@created 2013-05-27
@version 1.0
@since 20.0
*
@changelog
* 2013-05-27 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 
*/
@isTest
private class ExtDataReload_Test {

    static testMethod void testMostMethods() {
    	
    	Country_BI__c c = new Country_BI__c();
    	c.Name = 'adf';
    	insert c;
    	
        Account acc = ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        //acc.Specialization__c = 'GP';        
        insert acc;

        Cycle_BI__c cycle = ClsTestHelp.createTestCycle();
        insert cycle;
        
        Product_vod__c p2 = ClsTestHelp.createTestProduct();
        //p2.Name_BI__c = '234';
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Matrix_BI__c ma = ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Specialization_BI__c = 'GP';//Peng Zhu 2013-10-14
        insert ma;
        
        Matrix_Cell_BI__c mc = ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        cycle2.Country_Lkp_BI__c = c.Id;
        insert cycle2;
        
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Product_Catalog_BI__c = p2.Id;
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        cd.Current_Update_BI__c = true;
        insert cd;     	
    	
    	Test.startTest();
    	
    	ApexPages.currentPage().getParameters().put('id',cycle2.Id);
    	
        ApexPages.StandardController ctrl = new ApexPages.StandardController(cycle2); 
        //Begin: comment out by Peng Zhu 2013-09-07
        //ExtDataReload ext = new ExtDataReload(ctrl); 
        //
        //ext.cycId = cycle2.Id;
        //ext.productIdString = p2.Id;
        //
        //ext.init(cycle2.Id);
        //ext.cancel();
        //
        //ExtDataReload.ClsCycProd exeCyc = new ExtDataReload.ClsCycProd();
        //
        //ExtDataReload.clearCycData(p2.Id);
        //ExtDataReload.clearMatrixData(p2.Id);
        //ExtDataReload.checkProductHasCd(p2.Id);
        //End: comment out by Peng Zhu 2013-09-07
        system.assert(true);
        Test.stopTest();
    }
}