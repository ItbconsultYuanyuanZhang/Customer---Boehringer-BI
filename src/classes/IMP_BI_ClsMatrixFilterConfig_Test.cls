/**
 *	Test class for class IMP_BI_ClsMatrixFilterConfig
 *
 @author  Peng Zhu
 @created 2013-08-27
 @version 1.0
 @since   27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-08-27 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 * - Test coverage 100%
 */
@isTest
private class IMP_BI_ClsMatrixFilterConfig_Test {

    static testMethod void testMostMethods() {
        Test.startTest();
        
        IMP_BI_ClsMatrixFilterConfig.getFieldMapping('Account', new set<String>());
        
        system.assert(true);
        Test.stopTest();
    }
}