@isTest
public with sharing class VEEVA_CONCUR_UTILS_TEST {
	
	private static final String SUCCESS = 'SUCCESS', FAILED = 'FAILED';
	
	static testMethod void testIsConcurUpdateNullInputs() {
		Call2_vod__c blankCall = new Call2_vod__c();
		
		List<Call2_vod__c> nullList = null;
		List<Call2_vod__c> emptyList = new List<Call2_vod__c>();
		List<Call2_vod__c> singleItemList = new List<Call2_vod__c>();
		singleItemList.add(blankCall);
		
		System.Test.startTest();
		System.assertEquals(false, VEEVA_CONCUR_UTILS.isConcurUpdate(nullList , nullList));
		System.assertEquals(false, VEEVA_CONCUR_UTILS.isConcurUpdate(emptyList, nullList));
		System.assertEquals(false, VEEVA_CONCUR_UTILS.isConcurUpdate(nullList , emptyList));
		System.assertEquals(false, VEEVA_CONCUR_UTILS.isConcurUpdate(emptyList, emptyList));
		System.assertEquals(false, VEEVA_CONCUR_UTILS.isConcurUpdate(singleItemList, emptyList));
		System.assertEquals(false, VEEVA_CONCUR_UTILS.isConcurUpdate(emptyList, singleItemList));
		System.Test.stopTest();
	}
	
	static testMethod void testIsConcurUpdateFalse() {
		List<Call2_vod__c> oldCalls = new List<Call2_vod__c>();
		List<Call2_vod__c> newCalls = new List<Call2_vod__c>();
		
		Call2_vod__c nullExpensePostStatus = new Call2_vod__c(Expense_Post_Status_vod__c = null);
		Call2_vod__c failedExpensePostStatus = new Call2_vod__c(Expense_Post_Status_vod__c = FAILED);
		Call2_vod__c successExpensePostStatus = new Call2_vod__c(Expense_Post_Status_vod__c = SUCCESS);
		
		
		System.Test.startTest();
		
		oldCalls.clear();
		oldCalls.add(nullExpensePostStatus);
		newCalls.clear();
		newCalls.add(nullExpensePostStatus);
		System.assertEquals(false, VEEVA_CONCUR_UTILS.isConcurUpdate(oldCalls, newCalls));
		
		oldCalls.clear();
		oldCalls.add(failedExpensePostStatus);
		newCalls.clear();
		newCalls.add(nullExpensePostStatus);
		System.assertEquals(false, VEEVA_CONCUR_UTILS.isConcurUpdate(oldCalls, newCalls));
		
		oldCalls.clear();
		oldCalls.add(successExpensePostStatus);
		newCalls.clear();
		newCalls.add(nullExpensePostStatus);
		System.assertEquals(false, VEEVA_CONCUR_UTILS.isConcurUpdate(oldCalls, newCalls));
		
		oldCalls.clear();
		oldCalls.add(failedExpensePostStatus);
		newCalls.clear();
		newCalls.add(failedExpensePostStatus);
		System.assertEquals(false, VEEVA_CONCUR_UTILS.isConcurUpdate(oldCalls, newCalls));
		
		oldCalls.clear();
		oldCalls.add(successExpensePostStatus);
		newCalls.clear();
		newCalls.add(successExpensePostStatus);
		System.assertEquals(false, VEEVA_CONCUR_UTILS.isConcurUpdate(oldCalls, newCalls));
		
		System.Test.stopTest();
	}
	
	static testMethod void testIsConcurUpdateTrue() {
		List<Call2_vod__c> oldCalls = new List<Call2_vod__c>();
		List<Call2_vod__c> newCalls = new List<Call2_vod__c>();
		
		Call2_vod__c nullExpensePostStatus = new Call2_vod__c(Expense_Post_Status_vod__c = null);
		Call2_vod__c failedExpensePostStatus = new Call2_vod__c(Expense_Post_Status_vod__c = FAILED);
		Call2_vod__c successExpensePostStatus = new Call2_vod__c(Expense_Post_Status_vod__c = SUCCESS);
		
		
		System.Test.startTest();
		
		oldCalls.clear();
		oldCalls.add(nullExpensePostStatus);
		newCalls.clear();
		newCalls.add(failedExpensePostStatus);
		System.assert(VEEVA_CONCUR_UTILS.isConcurUpdate(oldCalls, newCalls));
		
		oldCalls.clear();
		oldCalls.add(nullExpensePostStatus);
		newCalls.clear();
		newCalls.add(successExpensePostStatus);
		System.assert(VEEVA_CONCUR_UTILS.isConcurUpdate(oldCalls, newCalls));
		
		System.Test.stopTest();
	}
	
}