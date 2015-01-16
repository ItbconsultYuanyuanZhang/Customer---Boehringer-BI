/**
*   Test class for class IMP_BI_CtrlCopyScenario.
*
@author Yuanyuan Zhang
@created 2014-12-23
@version 1.0
@since 32.0
*
@changelog
* 2014-12-23 Yuanyuan Zhang <Yuanyuan.Zhang@itbconsult.com>
* - Created
*- Test coverage 
*/
@isTest(seealldata=true)
private class IMP_BI_CtrlCopyScenario_Test {
    static testmethod void test1 () {
        Account acc = ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        //acc.Specialization_BI__c = 'wer';        
        insert acc;

        Cycle_BI__c cycle = ClsTestHelp.createTestCycle();
        insert cycle;
        
        Product_vod__c p2 = ClsTestHelp.createTestProduct();
        p2.Name = '234';
        insert p2;
        
        Matrix_BI__c ma = ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Row_BI__c = 10;
        ma.Column_BI__c = 11;
        ma.Specialization_BI__c = 'Cardiologist;GP';
        ma.Scenario_BI__c = '1';
        ma.Current_BI__c = true;
        insert ma;
        
        Matrix_Cell_BI__c mc = ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Matrix_Cell_Detail_BI__c mcdb = new Matrix_Cell_Detail_BI__c();
        mcdb.Matrix_Cell_BI__c = mc.Id;
        insert mcdb;
        
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Product_Catalog_BI__c = p2.Id;
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        cd.Matrix_Cell_1_BI__c = mc.Id;
        cd.Current_Scenario_BI__c = 1;
        insert cd;  
        
        test.startTest();
        IMP_BI_CtrlCopyScenario ibcc = new IMP_BI_CtrlCopyScenario();
        ibcc.matrixId = ma.Id;
        ibcc.isValid = true;
        ibcc.copyScenario();
        ibcc.isValid = false;
        ibcc.matrixId = ma.Id;
        ibcc.copyScenario();
        ibcc.cancel();
        test.stopTest();
    }
}