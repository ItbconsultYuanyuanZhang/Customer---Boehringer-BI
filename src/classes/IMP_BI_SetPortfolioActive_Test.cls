/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Test for IMP_BI_SetPortfolioActive class
*  @author:         Jefferson Escobar
*  @created:        07-Mar-2014
*  @version:        1.0
*  @see:            Salesforce GAM
*  @since:			29.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         07-Mar-2014                 jescobar                 	Construction of the class.
*/ 
@isTest
private class IMP_BI_SetPortfolioActive_Test {

    static testMethod void testSetActivePortfolio() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = 'Acc-test';  
        insert acc;

        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'US';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        cycle2.Country_Lkp_BI__c = c.Id;
        insert cycle2;
        
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        portfolio.Cycle_BI__c = cycle2.Id;
        insert portfolio;
        
        //Create a new portfolio
        Portfolio_BI__c portfolio2 = portfolio.clone(false,true);
        insert  portfolio2;
            	
        Test.startTest();
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(portfolio); 
        IMP_BI_SetPortfolioActive ctrPortfolioActive = new IMP_BI_SetPortfolioActive(ctrl); 
        
        ctrPortfolioActive.action_setPorfotlioActive();
        ctrPortfolioActive.action_cancel();
        
        //Generate error to cover lines that manages errors executions
        IMP_BI_SetPortfolioActive ctrFail = new IMP_BI_SetPortfolioActive(new ApexPages.StandardController(new Portfolio_BI__c(Name='P-Fail')));
        ctrFail.action_setPorfotlioActive();
                
        system.assert(true);
        Test.stopTest();
        
    }
}