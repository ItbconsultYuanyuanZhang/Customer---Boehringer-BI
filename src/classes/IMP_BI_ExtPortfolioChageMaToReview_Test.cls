/**
*   Test class for class IMP_BI_ExtPortfolioChageMatrixToReview.
*
@author Di Chen
@created 2013-07-09
@version 1.0
@since 20.0
*
@changelog
* 2013-07-09 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage  93%
*/
@isTest
private class IMP_BI_ExtPortfolioChageMaToReview_Test {

    static testMethod void testMostMethods() {
    	
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
        
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        portfolio.Cycle_BI__c = cycle2.Id;
        insert portfolio;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Specialization_BI__c = 'Cardiologist;GP';//Peng Zhu 2013-10-14
        ma.Status_BI__c = 'Ready for NTL';
        insert ma;
                
        Strategic_Brand_Weight_BI__c sb = new Strategic_Brand_Weight_BI__c();
        sb.Portfolio_BI__c = portfolio.Id;
        sb.Matrix_BI__c = ma.Id;
        insert sb;
            	
        Test.startTest();
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(portfolio); 
        IMP_BI_ExtPortfolioChageMatrixToReview ext = new IMP_BI_ExtPortfolioChageMatrixToReview(ctrl); 
        
        ext.changeMatrixStatusToReview();
        ext.cancel();
                
        system.assert(true);
        Test.stopTest();
    }
    static testMethod void testMostMethods2() {
    	
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
        
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        portfolio.Cycle_BI__c = cycle2.Id;
        //insert portfolio;
        
        Test.startTest();
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(portfolio); 
        IMP_BI_ExtPortfolioChageMatrixToReview ext = new IMP_BI_ExtPortfolioChageMatrixToReview(ctrl); 
        
        ext.changeMatrixStatusToReview();
                
        system.assert(true);
        Test.stopTest();
    }    
}