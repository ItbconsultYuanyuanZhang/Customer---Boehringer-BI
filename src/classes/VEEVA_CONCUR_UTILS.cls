public with sharing class VEEVA_CONCUR_UTILS {
	
	
	public static boolean isConcurUpdate(List<Call2_vod__c> oldCalls, List<Call2_vod__c> newCalls) {
		if (oldCalls == null || oldCalls.size() == 0 || newCalls == null || newCalls.size() == 0) {
			return false;
		}
		
		Call2_vod__c firstOldCall = oldCalls[0];
		Call2_vod__c firstNewCall = newCalls[0];
		
		// If the calls originally didn't have Expense_Post_Status_vod populated but now do, assume this trigger
		// was called from the Concur Sync batch job.
		return firstOldCall != null && firstNewCall != null
				 &&	firstOldCall.Expense_Post_Status_vod__c == null
				 && firstNewCall.Expense_Post_Status_vod__c != null;
	}
}