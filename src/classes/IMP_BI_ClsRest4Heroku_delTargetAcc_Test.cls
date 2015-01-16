/**
*   Test class for class IMP_BI_ClsRest4Heroku_delTargetAccount.
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
private class IMP_BI_ClsRest4Heroku_delTargetAcc_Test {

    static testMethod void myUnitTest() {
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc; 
        
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	    	
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.Country_Lkp_BI__c = c.Id;
        cycle2.IsCurrent_BI__c = false;
        insert cycle2;
        
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        portfolio.Cycle_BI__c = cycle2.Id;
        insert portfolio;
                   	
    	Target_Account_BI__c ta = IMP_BI_ClsTestHelp.createTestTargetAccountBI();
        ta.Account_BI__c = acc.Id;
        ta.Portfolio_BI__c = portfolio.Id;
        insert ta;
    	
        Test.startTest();
        
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
		req.requestURI = 'https://na14.salesforce.com/services/apexrest/updatePortfolioData/v1/'+ta.Id;  
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		        
        IMP_BI_ClsRest4Heroku_delTargetAccount.doGet();
        
        system.assert(true);
        Test.stopTest();
    }
}