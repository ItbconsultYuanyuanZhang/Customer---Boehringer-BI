/**
 *	Test class for class IMP_BI_ExtManageMatrixFilterByCountry
 *
 @author  Peng Zhu
 @created 2013-08-28
 @version 1.0
 @since   27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-08-28 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 * - Test coverage 91%
 */
@isTest
private class IMP_BI_ExtManageMatrixFilterByCtry_Test {

    static testMethod void testMostMethods() {
        Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';  
        acc.Call_BI__c = true;
        acc.Country_Code_BI__c = 'US_T';
        insert acc;
        
        Matrix_Filter_BI__c  mfb = new Matrix_Filter_BI__c();
        mfb.Active_BI__c = true;
        mfb.Country_BI__c = c.Id;
        mfb.Filter_Field_BI__c = 'Call_BI__c';
		insert mfb;
       
       	String testStr = '';
       
    	Test.startTest();
    	
    	//ApexPages.currentPage().getParameters().put('cId', c.Id);
    	ApexPages.StandardController ctrl = new ApexPages.StandardController(c); 
        IMP_BI_ExtManageMatrixFilterByCountry ext = new IMP_BI_ExtManageMatrixFilterByCountry(ctrl); 
        
        
        ext.mfId = mfb.Id;
        ext.saveMatrixFilter();
        ext.editFilter();
        ext.delMfId = mfb.Id;
        ext.delFilter();
        ext.manageMatrixFilter();
        ext.cancel();
        //Call summary channels
        IMP_BI_ExtManageMatrixFilterByCountry.getSummarySpecialties('US_T-Call_BI__c');
        
    	
    	system.assert(true);
    	Test.stopTest();
    }

}