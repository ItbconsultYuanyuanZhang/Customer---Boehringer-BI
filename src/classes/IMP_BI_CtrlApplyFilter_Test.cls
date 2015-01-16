/**
 *
 */
@isTest
private class IMP_BI_CtrlApplyFilter_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
    }
    
    static testMethod void test_getFullId() {
    	Id fakeAccountId = generateFakeId(Account.sObjectType);
    	
    	system.assertEquals(null, IMP_BI_CtrlApplyFilter.getFullId(null));
    	system.assertEquals(null, IMP_BI_CtrlApplyFilter.getFullId(''));
    	system.assertEquals(null, IMP_BI_CtrlApplyFilter.getFullId('InvalidId'));
    	system.assertEquals(fakeAccountId, IMP_BI_CtrlApplyFilter.getFullId(String.valueOf(fakeAccountId)));
    }

    //********************************* -=BEGIN test help functions=- **********************************	    
	private static Integer fakeIdCount = 0;
	private static final String ID_PATTERN = '000000000000';
	
	/**
	 * Generate a fake Salesforce Id for the given sObjectType
	 */
	public static Id generateFakeId(Schema.sObjectType sObjectType) {
		String keyPrefix = sObjectType.getDescribe().getKeyPrefix();
		
		fakeIdCount++;

		String fakeIdPrefix = ID_PATTERN.substring(0, 12 - fakeIdCount.format().length());

		return Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
	} 
    //********************************* -=END test help functions=- ************************************	   
}