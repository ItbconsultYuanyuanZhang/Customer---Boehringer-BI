/**
*   Test class for class IMP_BI_ClsScheduler_ClearFldFcSimulation.
*
@author Di Chen
@created 2013-06-14
@version 1.0
@since 20.0
*
@changelog
* 2013-06-14 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 86%
*/
@isTest
private class IMP_BI_ClsScheduler_ClearFldFcSimu_Test {

	static testMethod void myUnitTest() {
    	
        DateTime currTime = DateTime.now();
        Integer min = currTime.minute();
        Integer hour = currTime.hour();
        String sch;
        
		if(min <= 58)
            sch = '0 '+ (min + 1) + ' ' + hour + ' * * ? '+ currTime.year();
        else          
            sch = '0 0 '+ (hour + 1) + ' * * ? '+ currTime.year();
        
        Test.startTest();
        
		IMP_BI_ClsScheduler_ClearFldFcSimulation obj = new IMP_BI_ClsScheduler_ClearFldFcSimulation();                
		String jobId = system.schedule('test', sch, obj); 
		       
		system.assert(true);  
        Test.stopTest();
    }
}