public with sharing class VOD_SHADOW_ACCOUNT {
	
	public static boolean isShadowAccount(Account account) {
		// "Customer Master Status" on an Account: i.e., our flag for whether or not this Account is a
    	// "Shadow Account". "Shadow Accounts" are simply unverified Network Accounts.
		String customerMasterStatus = account != null ? account.Customer_Master_Status_vod__c : null;
		
		return 'Under_Review_vod'.equals(customerMasterStatus) || 'Rejected_vod'.equals(customerMasterStatus);
	}
	
	public static void rejectUnverifiedAccounts(List<Sobject> sobjects, List<String> accountIdFields) {
		String shadowAccountErrorMessage = VOD_GET_ERROR_MSG.getErrorMsgWithDefault('ENDPOINT_NOT_VALID', 'NETWORK', 
				'Cannot create record because one or both of the referenced accounts have not been validated');
	
		List<Id> accountsToQueryFor = new List<Id>();
		
		// Iterate once through the Child Accounts that we're about to insert/update, aggregating a list of Account
		// objects to query for (can't perform a relationship query without the Id of the Child_Account_vod__c record,
		// since the Child Account record doesn't exist yet).
	    for (Sobject record : sobjects) {
	    	
	    	// Add the Parent and Child Accounts to the list of Account payloads to query for later.        
	    	for (String accountIdField : accountIdFields) {
	    		accountsToQueryFor.add((Id) record.get(accountIdField));
	    	}
	    }
	    
	    // Do one giant query for all of the Account payloads.
	    Map<Id, Account> accountPayloads = new Map<Id, Account>([select Id, Name, Customer_Master_Status_vod__c 
	    							   							from Account where Id IN :accountsToQueryFor]);
	    			
	    // Iterate a second time through the Child Accounts that we're about to insert/update, checking to see if any 
	    // of the Accounts are unverified. If so, bounce that Child Account record.
	    for (Sobject record : sobjects) {
	    	for (String accountIdField : accountIdFields) {
	    		Account account = accountPayloads.get((Id) record.get(accountIdField));
	    		
	    		// Bounce any Child Account records that attempt to affiliate unverified Accounts.
	    		if (VOD_SHADOW_ACCOUNT.isShadowAccount(account)) {
	    			record.addError(shadowAccountErrorMessage);
	    		}
	    	}
	    }
	}
}