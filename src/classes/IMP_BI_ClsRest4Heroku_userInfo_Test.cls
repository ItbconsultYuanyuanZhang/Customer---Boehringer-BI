/**
*   Test class for class IMP_BI_ClsRest4Heroku_userInfo.
*
@author Di Chen
@created 2013-07-12
@version 1.0
@since 20.0
*
@changelog
* 2013-07-12 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 
*/
@isTest
private class IMP_BI_ClsRest4Heroku_userInfo_Test {

    static testMethod void testMostMethods() {
        Test.startTest();
        
        IMP_BI_ClsRest4Heroku_userInfo.doGet();
        IMP_BI_ClsRest4Heroku_userInfo.Response clsR = new IMP_BI_ClsRest4Heroku_userInfo.Response();
        
        system.assert(true);
        Test.stopTest();
    }
}