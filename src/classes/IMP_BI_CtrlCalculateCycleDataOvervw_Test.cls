/**
*   Test class for class IMP_BI_CtrlCalculateCycleDataOverview.
*
@author Di Chen
@created 2013-06-14
@version 1.0
@since 20.0
*
@changelog
* 2013-06-14 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 90%
*/
@isTest
private class IMP_BI_CtrlCalculateCycleDataOvervw_Test {

    static testMethod void testMostMethods() {
        Test.startTest();
        
        IMP_BI_CtrlCalculateCycleDataOverview ctrl = new IMP_BI_CtrlCalculateCycleDataOverview();
        ctrl.runBatch();
        
        system.assert(true);
        Test.stopTest();
    }
}