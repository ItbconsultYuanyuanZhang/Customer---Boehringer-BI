trigger Event_Attendee_vod on Event_Attendee_vod__c (before update, before insert) {
        
        	Set<String> accountIds = new Set<String>();
        	Set<String> contactIds = new Set<String>();
        	Set<String> userIds = new Set<String>();
        	// assumption is we will only get one of the below values per record
        	for (Integer i=0; i < Trigger.new.size(); i++) {
        		if (Trigger.new[i].Account_vod__c != null) {
        			accountIds.add(Trigger.new[i].Account_vod__c);
        		}
        		else if (Trigger.new[i].Contact_vod__c != null) {
        			contactIds.add(Trigger.new[i].Contact_vod__c);
        		}
        		else if (Trigger.new[i].User_vod__c != null) {
        			userIds.add(Trigger.new[i].User_vod__c);
        		}
        	}
        	
        	Map<ID,Account> accounts = null;
        	if (accountIds.size() > 0) {
        		accounts = new Map<ID,Account>([Select Id,Name From Account Where Id In :accountIds]);
        	}
        	Map<ID,Contact> contacts = null;
        	if (contactIds.size() > 0) {
        		contacts = new Map<ID,Contact>([Select Id,Name From Contact Where Id In :contactIds]);
        	}
        	Map<ID,User> users = null;
        	if (userIds.size() > 0) {
        		users = new Map<ID,User>([Select Id,Name From User Where Id In :userIds]);
        	}
        	
        	for (Integer i=0; i < Trigger.new.size(); i++) {
        		String attendeeName = '';
        		if (Trigger.new[i].Account_vod__c != null) {
        			Account acct = accounts.get(Trigger.new[i].Account_vod__c);
        			if (acct != null)
        				attendeeName = acct.Name;
        		}
        		else if (Trigger.new[i].Contact_vod__c != null) {
        			Contact ctct = contacts.get(Trigger.new[i].Contact_vod__c);
        			if (ctct != null)
        				attendeeName = ctct.Name;
        		}
        		else if (Trigger.new[i].User_vod__c != null) {
        			User usr = users.get(Trigger.new[i].User_vod__c);
        			if (usr != null)
        				attendeeName = usr.Name;
        		}
        		Trigger.new[i].Attendee_vod__c = attendeeName;
        	}
        }