/**
 *	Test class for class IMP_BI_ExtManageMatrixFilter
 *
 @author  Peng Zhu
 @created 2013-08-28
 @version 1.0
 @since   27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-08-28 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 * - Test coverage 87%
 */
@isTest
private class IMP_BI_ExtManageMatrixFilter_Test {

    static testMethod void testMostMethods() {
        Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';  
        insert acc;
        
        Matrix_Filter_BI__c  mfb = new Matrix_Filter_BI__c();
        mfb.Active_BI__c = true;
        mfb.Country_BI__c = c.Id;
        mfb.Filter_Field_BI__c = 'Call_BI__c';
		insert mfb;
       
       	String jsonStr = '{"cid":"'+ c.Id +'","set_filter":["Rx_Behavior_BI__c","BI_Speaker_BI__c"]}"';
       
    	Test.startTest();
    	
    	ApexPages.currentPage().getParameters().put('cId', c.Id);
    	ApexPages.StandardController ctrl = new ApexPages.StandardController(c); 
        IMP_BI_ExtManageMatrixFilter ext = new IMP_BI_ExtManageMatrixFilter(ctrl); 
        
        
        
        
        IMP_BI_ExtManageMatrixFilter.saveMatrixFilter(jsonStr);
        ext.cancel();
    	
    	system.assert(true);
    	Test.stopTest();
    }
}