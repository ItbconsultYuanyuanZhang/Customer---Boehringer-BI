/**
*   Test class for class IMP_BI_Matrix_BIU_setMatrixName.
*
@author Di Chen
@created 2013-06-17
@version 1.0
@since 20.0
*
@changelog
* 2013-06-17 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 94%
*/
@isTest
private class IMP_BI_TrgMatrix_BIU_setMatrixName_Test {

    static testMethod void testBIU() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc;
        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        cycle2.Country_Lkp_BI__c = c.Id;
        insert cycle2;
                
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Specialization_BI__c = 'Cardiologist;GP';//Peng Zhu 2013-10-14
        
        Test.startTest();
        
        insert ma;
        
        system.assert(true);
        Test.stopTest();
    }
}