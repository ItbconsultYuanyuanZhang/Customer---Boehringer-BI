/**
*   Test class for class IMP_BI_ClsBatch_clearScenNumOfCycleData.
*
@author Yuanyuan Zhang
@created 2014-12-24
@version 1.0
@since 32.0
*
@changelog
* 2014-12-24 Yuanyuan Zhang <Yuanyuan.Zhang@itbconsult.com>
* - Created
*- Test coverage 
*/
@isTest
private class IMP_BI_ClsBatch_clearSNOfCYD_Test {
    static testmethod void test1 () {
        Account acc = ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        //acc.Specialization_BI__c = 'wer';        
        insert acc;
        
        Account acc1 = ClsTestHelp.createTestAccount();
        acc.Name = '34tf34f';
        //acc.Specialization_BI__c = 'wer';        
        insert acc1;

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
        ma.Current_BI__c = false;
        insert ma;
        
        Matrix_BI__c ma1 = ClsTestHelp.createTestMatrix();
        ma1.Cycle_BI__c = cycle.Id;
        ma1.Product_Catalog_BI__c = p2.Id;
        ma1.Intimacy_Levels_BI__c = 11;
        ma1.Potential_Levels_BI__c = 10;
        ma1.Size_BI__c = '10x11';
        ma1.Row_BI__c = 10;
        ma1.Column_BI__c = 11;
        ma1.Specialization_BI__c = 'Cardiologist;GP';
        ma1.Scenario_BI__c = '2';
        ma1.Current_BI__c = true;
        ma1.First_Scenario_BI__c = ma.Id;
        insert ma1;
        
        Matrix_Cell_BI__c mc = ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Matrix_Cell_BI__c mc1 = ClsTestHelp.createTestMatrixCell();
        mc1.Matrix_BI__c = ma1.Id;
        insert mc1;
        
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Product_Catalog_BI__c = p2.Id;
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        cd.Matrix_Cell_1_BI__c = mc.Id;
        cd.Matrix_Cell_2_BI__c = mc1.Id;
        cd.Current_Scenario_BI__c = 2;
        //cd.UniqueKey_BI__c = 'aaaaaaaaaaaefewf34gerwgbg34sss';
        insert cd;  
        
        Cycle_Data_BI__c cd1 = new Cycle_Data_BI__c();
        cd1.Product_Catalog_BI__c = p2.Id;
        cd1.Account_BI__c = acc1.Id;
        cd1.Cycle_BI__c = cycle.Id;
        cd1.Matrix_Cell_1_BI__c = mc.Id;
        cd1.Matrix_Cell_2_BI__c = mc1.Id;
        cd1.Current_Scenario_BI__c = 2;
        //cd1.UniqueKey_BI__c = 'bbbbbbbbbb454h56u76idfbsttj';
        insert cd1; 
        
        test.startTest();
        delete ma1;
        test.stopTest();
    }
}