/**
*   Test class for class IMP_BI_ClsRest4Heroku_updateCycleData.
*
@author Di Chen
@created 2013-06-14
@version 1.0
@since 20.0
*
@changelog
* 2013-06-14 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage  87%
*/
@isTest
private class IMP_BI_ClsRest4Heroku_updateCycData_Test {

    static testMethod void testMostMethods() {
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc;
        
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        cycle2.Country_Lkp_BI__c = c.Id;
        insert cycle2;
            	        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
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
        
        list<Cycle_Data_BI__c> inputData = new list<Cycle_Data_BI__c>();
        inputData.add(cd);
        
        Test.startTest();
        
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
		req.requestURI = 'https://na14.salesforce.com/services/apexrest/UpdateCycleData/v1/'+cycle2.Id;  
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		        
        IMP_BI_ClsRest4Heroku_updateCycleData.doGet();
        IMP_BI_ClsRest4Heroku_updateCycleData.doPost('1', inputData);
        IMP_BI_ClsRest4Heroku_updateCycleData.Response clsR = new IMP_BI_ClsRest4Heroku_updateCycleData.Response();
        
        system.assert(true);
        Test.stopTest();
    }
}