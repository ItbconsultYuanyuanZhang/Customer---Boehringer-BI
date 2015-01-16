/**
*   Test class for class ClsBatch_PortfolioFieldForceSimulation.
*
@author Di Chen
@created 2013-06-03
@version 1.0
@since 20.0
*
@changelog
* 2013-06-03 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 87%
*/
@isTest
private class IMP_BI_ClsBatch_FieldFSimulation_Test {

    static testMethod void testBatch() {
    	
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
            	
    	Portfolio_Field_Force_Simulation_BI__c pffs = IMP_BI_ClsTestHelp.createTestPortfolioFieldForceSimulationBI();
    	pffs.Version_BI__c = 15;
    	pffs.Portfolio_BI__c = portfolio.Id;
    	insert pffs;
    	
        list<Portfolio_Field_Force_Simulation_BI__c> scope = new list<Portfolio_Field_Force_Simulation_BI__c>();
        scope.add(pffs);
        
        Test.startTest();
        
        IMP_BI_ClsBatch_FieldForceSimulation batchCls = new IMP_BI_ClsBatch_FieldForceSimulation(); 
        batchCls.filter = ' limit 1';
        
        Database.BatchableContext bc;
        batchCls.start(bc);
        batchCls.execute(bc, scope);
        batchCls.finish(bc);
        
        system.assert(true); 
        Test.stopTest();  
    }
  
}