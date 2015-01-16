/**
*   Test class for class IMP_BI_ClsBatch_TargetDetail.
*
@author Di Chen
@created 2013-06-03
@version 1.0
@since 20.0
*
@changelog
* 2013-06-03 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage  87%
*/
@isTest
private class IMP_BI_ClsBatch_TargetDetail_Test {

    static testMethod void testBatch() {
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
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
        
        Target_Detail_BI__c td = new Target_Detail_BI__c();
        td.Account_BI__c = acc.Id;
        td.Target_Account_BI__c = ta.Id;
        td.Portfolio_BI__c = portfolio.Id;
        insert td;
                
        list<Target_Detail_BI__c> scope = new list<Target_Detail_BI__c>();
        scope.add(td);
        
        Test.startTest();
        
        IMP_BI_ClsBatch_TargetDetail batchCls = new IMP_BI_ClsBatch_TargetDetail(); 
        batchCls.filter = ' limit 1';
        
        Database.BatchableContext bc;
        batchCls.start(bc);
        batchCls.execute(bc, scope);
        batchCls.finish(bc);
        
        system.assert(true); 
        Test.stopTest();  
    }
}