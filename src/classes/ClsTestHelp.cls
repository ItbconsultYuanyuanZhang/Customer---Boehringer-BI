/**
*   This class is a help class.
*
@author Di Chen
@created 2013-03-01
@version 1.0
@since 20.0
*
@changelog
* 2013-03-01 Di Chen <di.chen@itbconsult.com>
* - Created
*
*/
@isTest
public class ClsTestHelp {
    
    public static Account createTestAccount() {
        Account acc = new Account();
        //acc.Specialization_BI__c = 'Cardiologist;GP';
        acc.Name = 'nisdj';
        return acc;
    }
    
    public static Cycle_BI__c createTestCycle() {
        Cycle_BI__c cycle = new Cycle_BI__c();
        cycle.Country_BI__c = 'USA';
        cycle.Start_Date_BI__c = date.today() - 1;
        cycle.End_Date_BI__c = date.today() + 1;
        cycle.IsCurrent_BI__c = true;
        return cycle;
    }
    
    public static Product_vod__c createTestProduct() {
        Product_vod__c p = new Product_vod__c();
        //p.Name_BI__c = 'erwe';
        //p.Country_BI__c = 'USA';
        return p;
    }

    public static Matrix_Cell_BI__c createTestMatrixCell() {
        Matrix_Cell_BI__c mc = new Matrix_Cell_BI__c();
        mc.Row_BI__c = 11;
        mc.Column_BI__c = 12;
        return mc;
    }
                
    public static Matrix_BI__c createTestMatrix() {
        Matrix_BI__c ma = new Matrix_BI__c();
        ma.Specialization_BI__c = 'Cardiologist;GP';//Peng Zhu 2013-10-14
        ma.Potential_Levels_BI__c = 12;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Name_BI__c = 'good';
        ma.Potential_Levels_BI__c = 11;
        return ma;
    }
    
    public static Cycle_Data_BI__c createTestCycleData() {
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();   
        cd.Potential_BI__c = 1;
        cd.Intimacy_BI__c = 2;
        return cd;
    }
}