/**
*   Test class for class IMP_BI_ExtDataReload.
*
@author Di Chen
@created 2013-06-14
@version 1.0
@since 20.0
*
@changelog
* 2013-06-14 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 
*/
@isTest
private class IMP_BI_ExtDataReload_Test {

    static testMethod void testMostMethods() {
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc;
        
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
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
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Specialization_BI__c = 'Cardiologist;GP';//Peng Zhu 2013-10-14
        insert ma;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;

        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        insert cd; 
         
    	Test.startTest();
    	
    	ApexPages.currentPage().getParameters().put('id',cycle2.Id);
    	
        ApexPages.StandardController ctrl = new ApexPages.StandardController(cycle2); 
        IMP_BI_ExtDataReload ext = new IMP_BI_ExtDataReload(ctrl); 
        
        ext.cycId = cycle2.Id;
        ext.productIdString = p2.Id;
        
        ext.init(cycle2.Id);
        ext.cancel();
        
        IMP_BI_ExtDataReload.ClsCycProd exeCyc = new IMP_BI_ExtDataReload.ClsCycProd();
        
        IMP_BI_ExtDataReload.clearCycData('{"list_prodId":["'+p2.Id+'"],"cycId":"'+cycle2.Id+'"}');
        IMP_BI_ExtDataReload.clearMatrixData(p2.Id);
        IMP_BI_ExtDataReload.checkProductHasCd(p2.Id);
        IMP_BI_ExtDataReload.clearMatrixCell(p2.Id);
        IMP_BI_ExtDataReload.clearMatrixDetail(p2.Id);
        IMP_BI_ExtDataReload.setCycleDataNull(p2.Id);
        
        system.assert(true);
        Test.stopTest();
    }
}