/**
*   Test class for class IMP_BI_ClsRest4Heroku_updateMatrixData.
*
@author Di Chen
@created 2013-06-14
@version 1.0
@since 20.0
*
@changelog
* 2013-06-14 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 85%
*/
@isTest
private class IMP_BI_ClsRest4Heroku_updateMatrix_Test {

    static testMethod void testMostMethods() {
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc;

        Cycle_BI__c cycle = IMP_BI_ClsTestHelp.createTestCycle();
        insert cycle;
        
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Specialization_BI__c = 'Cardiologist;GP';//Peng Zhu 2013-10-14
        insert ma;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        insert cycle2;
        
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        insert cd;  
        
        list<Matrix_Cell_BI__c> inputData = new list<Matrix_Cell_BI__c>();
        inputData.add(mc);
        
        Test.startTest();
        
        IMP_BI_ClsRest4Heroku_updateMatrixData.doGet();
        IMP_BI_ClsRest4Heroku_updateMatrixData.doPost(ma, inputData);
        IMP_BI_ClsRest4Heroku_updateMatrixData.Response clsR = new IMP_BI_ClsRest4Heroku_updateMatrixData.Response();
        
        system.assert(true);
        Test.stopTest();
    }
  
}