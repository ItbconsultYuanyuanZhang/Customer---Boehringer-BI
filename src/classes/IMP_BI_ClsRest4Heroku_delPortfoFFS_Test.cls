/**
*   Test class for class IMP_BI_ClsRest4Heroku_delPortfolioFFS.
*
@author Di Chen
@created 2013-08-16
@version 1.0
@since 20.0
*
@changelog
* 2013-08-16 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 80%
*/
@isTest
private class IMP_BI_ClsRest4Heroku_delPortfoFFS_Test {

    static testMethod void testRest() {
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
                
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        insert cd;  
        
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        portfolio.Cycle_BI__c = cycle2.Id;
        insert portfolio;
        
        Strategic_Brand_Weight_BI__c sb = new Strategic_Brand_Weight_BI__c();
        sb.Portfolio_BI__c = portfolio.Id;
        sb.Matrix_BI__c = ma.Id;
        insert sb;
                
        Target_Account_BI__c ta = IMP_BI_ClsTestHelp.createTestTargetAccountBI();
        ta.Account_BI__c = acc.Id;
        ta.Portfolio_BI__c = portfolio.Id;
        insert ta;
        
        Target_Detail_BI__c td = new Target_Detail_BI__c();
        td.Account_BI__c = acc.Id;
        td.Target_Account_BI__c = ta.Id;
        td.Portfolio_BI__c = portfolio.Id;
        insert td;
        
    	Portfolio_Field_Force_Simulation_BI__c pffs = IMP_BI_ClsTestHelp.createTestPortfolioFieldForceSimulationBI();
    	pffs.Version_BI__c = 15;
    	pffs.Portfolio_BI__c = portfolio.Id;
    	insert pffs;
    	
        Test.startTest();

	
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
		req.requestURI = 'https://na14.salesforce.com/services/apexrest/delPortfolioFFS/v1/'+pffs.Id;  
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		        
        IMP_BI_ClsRest4Heroku_delPortfolioFFS.doGet();
        
        system.assert(true);
        Test.stopTest();    	
    }
}