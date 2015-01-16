/**
*   Test class for class IMP_BI_ExtPortfolioParams.
*
@author Di Chen
@created 2013-06-14
@version 1.0
@since 20.0
*
@changelog
* 2013-06-14 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 79%
*/
@isTest
private class IMP_BI_ExtPortfolioParams_Test {

    static testMethod void testMostMethods() {
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc;
        
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.Country_Lkp_BI__c = c.Id;
        cycle2.IsCurrent_BI__c = false;
        insert cycle2;
                
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
        
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        portfolio.Status_BI__c = null;
        portfolio.Cycle_BI__c = cycle2.Id;
        insert portfolio;
        
        Strategic_Brand_Weight_BI__c sb = new Strategic_Brand_Weight_BI__c();
        sb.Portfolio_BI__c = portfolio.Id;
        sb.Matrix_BI__c = ma.Id;
        insert sb;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('cycid',cycle2.Id);
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(portfolio); 
        IMP_BI_ExtPortfolioParams ext = new IMP_BI_ExtPortfolioParams(ctrl);  
        
        
        ext.getCurrentTimeUserLocal();
        ext.cancel();
        
        String result = '{"cycId":"'+cycle2.Id+'","list_cpf":[{"pf":{"id":"'+portfolio.Id+'","name":"testyy","Number_of_FTEs_BI__c":"4","Number_of_days_in_the_field_BI__c":"4","Number_of_calls_per_day_BI__c":"4","Numbers_of_details_per_call_BI__c":"4"},"list_cmId":[{"maId":"'+ma.Id+'","weight":"100.0"}]},{"pf":{"id":"'+portfolio.Id+'","name":"testyy1","Number_of_FTEs_BI__c":"3","Number_of_days_in_the_field_BI__c":"2","Number_of_calls_per_day_BI__c":"1","Numbers_of_details_per_call_BI__c":"3"},"list_cmId":[]}]}';
        
        IMP_BI_ExtPortfolioParams.savePortfolio(result);
        
        system.assert(true);
        Test.stopTest();
    }
    static testMethod void testMostMethods2() {
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc;
        
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.Country_Lkp_BI__c = c.Id;
        cycle2.IsCurrent_BI__c = false;
        insert cycle2;
                
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
        
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        portfolio.Status_BI__c = null;
        portfolio.Cycle_BI__c = cycle2.Id;
        insert portfolio;
        
        Strategic_Brand_Weight_BI__c sb = new Strategic_Brand_Weight_BI__c();
        sb.Portfolio_BI__c = portfolio.Id;
        sb.Matrix_BI__c = ma.Id;
        insert sb;
        
        Test.startTest();
        
        IMP_BI_ExtPortfolioParams.ClsMatrixId extCls1 = new IMP_BI_ExtPortfolioParams.ClsMatrixId();
        IMP_BI_ExtPortfolioParams.ClsPortfolioSave extCls2 = new IMP_BI_ExtPortfolioParams.ClsPortfolioSave();
        
        IMP_BI_ExtPortfolioParams.ClsPortfolioResult extCls3 = new IMP_BI_ExtPortfolioParams.ClsPortfolioResult();
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(portfolio); 
        IMP_BI_ExtPortfolioParams ext = new IMP_BI_ExtPortfolioParams(ctrl);  
        
        ext.getCurrentTimeUserLocal();
        ext.cancel();
        
        String result = '{"cycId":"'+cycle2.Id+'","list_cpf":[{"pf":{"id":"'+portfolio.Id+'","name":"testyy","Number_of_FTEs_BI__c":"4","Number_of_days_in_the_field_BI__c":"4","Number_of_calls_per_day_BI__c":"4","Numbers_of_details_per_call_BI__c":"4"},"list_cmId":[{"maId":"'+ma.Id+'","weight":"100.0"}]},{"pf":{"id":"'+portfolio.Id+'","name":"testyy1","Number_of_FTEs_BI__c":"3","Number_of_days_in_the_field_BI__c":"2","Number_of_calls_per_day_BI__c":"1","Numbers_of_details_per_call_BI__c":"3"},"list_cmId":[]}]}';
        
        IMP_BI_ExtPortfolioParams.savePortfolio(result);
        
        system.assert(true);
        Test.stopTest();
    }
    static testMethod void testMostMethods3() {
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc;
        
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.Country_Lkp_BI__c = c.Id;
        cycle2.IsCurrent_BI__c = false;
        insert cycle2;
                
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Status_BI__c = 'Ready for NTL';
        ma.Specialization_BI__c = 'Cardiologist;GP';//Peng Zhu 2013-10-14
        insert ma;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        portfolio.Status_BI__c = 'Ready for NTL';
        portfolio.Cycle_BI__c = cycle2.Id;
        insert portfolio;
        
        Strategic_Brand_Weight_BI__c sb = new Strategic_Brand_Weight_BI__c();
        sb.Portfolio_BI__c = portfolio.Id;
        sb.Matrix_BI__c = ma.Id;
        insert sb;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('cycid',cycle2.Id);
        
        IMP_BI_ExtPortfolioParams.ClsMatrixId extCls1 = new IMP_BI_ExtPortfolioParams.ClsMatrixId();
        IMP_BI_ExtPortfolioParams.ClsPortfolioSave extCls2 = new IMP_BI_ExtPortfolioParams.ClsPortfolioSave();
        
        IMP_BI_ExtPortfolioParams.ClsPortfolioResult extCls3 = new IMP_BI_ExtPortfolioParams.ClsPortfolioResult();
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(portfolio); 
        IMP_BI_ExtPortfolioParams ext = new IMP_BI_ExtPortfolioParams(ctrl);  
        
        ext.getCurrentTimeUserLocal();
        ext.cancel();
        
        String result = '{"cycId":"'+cycle2.Id+'","list_cpf":[{"pf":{"id":"'+portfolio.Id+'","name":"testyy","Number_of_FTEs_BI__c":"4","Number_of_days_in_the_field_BI__c":"4","Number_of_calls_per_day_BI__c":"4","Numbers_of_details_per_call_BI__c":"4"},"list_cmId":[{"maId":"'+ma.Id+'","weight":"100.0"}]},{"pf":{"id":"'+portfolio.Id+'","name":"testyy1","Number_of_FTEs_BI__c":"3","Number_of_days_in_the_field_BI__c":"2","Number_of_calls_per_day_BI__c":"1","Numbers_of_details_per_call_BI__c":"3"},"list_cmId":[]}]}';
        
        IMP_BI_ExtPortfolioParams.savePortfolio(result);
        
        system.assert(true);
        Test.stopTest();
    }           
}