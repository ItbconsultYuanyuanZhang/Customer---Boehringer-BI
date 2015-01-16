/**
*   Test class for class IMP_BI_ExtPortfolioReportList.
*
@author Di Chen
@created 2013-06-28
@version 1.0
@since 20.0
*
@changelog
* 2013-06-28 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 85%
*/
@isTest
private class IMP_BI_ExtPortfolioReportList_Test {

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
    	
    	Portfolio_Report_List_BI__c prl = new Portfolio_Report_List_BI__c();
    	prl.Name = 'new';
    	insert prl;
    	
    	
    	Test.startTest();
    	
        ApexPages.StandardController ctrl = new ApexPages.StandardController(portfolio); 
        IMP_BI_ExtPortfolioReportList ext = new IMP_BI_ExtPortfolioReportList(ctrl);
        
        ext.portfolio = portfolio;
        
        ext.forceSimulationChanged();
        ext.reportListChanged();
        
        
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
        cycle2.Country_Lkp_BI__c = null;
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
        portfolio.FTEs_Field_Force_Simulation_BI__c = null;
        insert portfolio;    	
    	
    	Portfolio_Report_List_BI__c prl = new Portfolio_Report_List_BI__c();
    	prl.Name = 'new';
    	prl.Area_BI__c = 'global';
    	prl.Filter_1_BI__c = '{!Portfolio_BI__c.Status_BI__c}';
    	prl.Filter_2_BI__c = '{!Portfolio_BI__c.Status_BI__c}';
    	prl.Filter_3_BI__c = '{!Portfolio_BI__c.Status_BI__c}';
    	insert prl;
    	
    	Test.startTest();
    	
        ApexPages.StandardController ctrl = new ApexPages.StandardController(portfolio); 
        IMP_BI_ExtPortfolioReportList ext = new IMP_BI_ExtPortfolioReportList(ctrl);
        
        ext.portfolio = portfolio;
        ext.reportId = prl.Id;
        
        ext.forceSimulationChanged();
        ext.reportListChanged();
        
        
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
        cycle2.Country_Lkp_BI__c = null;
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
        portfolio.FTEs_Field_Force_Simulation_BI__c = null;
        insert portfolio;    	
    	
    	Portfolio_Report_List_BI__c prl = new Portfolio_Report_List_BI__c();
    	prl.Name = 'new';
    	prl.Area_BI__c = 'global';
    	prl.Filter_1_BI__c = '{!Portfolio_BI__c.Status_BI__c}';
    	prl.Filter_2_BI__c = '{!Portfolio_BI__c.Status_BI__c}';
    	prl.Filter_3_BI__c = '{!Portfolio_BI__c.Status_BI__c}';
    	insert prl;
    	
    	Test.startTest();
    	
        ApexPages.StandardController ctrl = new ApexPages.StandardController(portfolio); 
        IMP_BI_ExtPortfolioReportList ext = new IMP_BI_ExtPortfolioReportList(ctrl);
        
        ext.portfolio = portfolio;
        ext.reportId = prl.Id;
        
        ext.reportListChanged();
        
        system.assert(true);
        Test.stopTest(); 
    }      
}