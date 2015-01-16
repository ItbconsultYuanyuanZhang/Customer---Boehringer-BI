/**
 * Account_Plan_Percentage_Update
 * Updates the percentage of a plan complete when an action step is added/modified/deleted/undeleted
 * 
 * Author: Raphael Krausz <raphael.krausz@veevasystems.com>
 * Date: 2013-03-14
 *
 * Updated to accomodate deleting all tactics by Viktor.
 * Date: 2013-05-13
 */

trigger Account_Plan_Percentage_Update on Account_Tactic_vod__c (after insert, after update, after delete, after undelete) {

	Set<Id> plan_ids = new Set<Id>();
	
	Set<Account_Tactic_vod__c> theTactics = new Set<Account_Tactic_vod__c>();

	// If this is a delete, then Trigger.new will be null
	// If this is an insert, then Trigger.old will be null
	// If this is an upsert, then the tactic may have moved plans, so both should captured.
	// We use sets, to avoid duplicates
	
	if (Trigger.old != null) theTactics.addAll(Trigger.old);
	if (Trigger.new != null) theTactics.addAll(Trigger.new);
	
	for(Account_Tactic_vod__c tactic : theTactics) {
		plan_ids.add(tactic.Account_Plan_vod__c);
	}
	
	List<Account_Plan_vod__c> plans = [
		SELECT Id, Percent_Complete_vod__c
		FROM Account_plan_vod__c
		WHERE Id in :plan_ids
	];
	
	List<Account_Tactic_vod__c> tactics = [
		SELECT Id, Account_Plan_vod__c, Complete_vod__c
		FROM Account_Tactic_vod__c
		WHERE Account_Plan_vod__c in :plan_ids
		AND IsDeleted = false
	];
	

	Map<Id, Integer> totals 	= new Map<Id, Integer>();
	Map<Id, Integer> completed	= new Map<Id, Integer>();
	
	
	for (Account_Plan_vod__c plan : plans) {
		totals.put(plan.Id, 0);
		completed.put(plan.Id, 0);
	}
	if(totals.size()>0){
		for (Account_Tactic_vod__c tactic : tactics) {
			Id plan = tactic.Account_Plan_vod__c;
			totals.put(plan, totals.get(plan)+1);
			if (tactic.Complete_vod__c)
				completed.put(plan, completed.get(plan)+1);
		}
	
		for (Integer i = 0; i < plans.size(); i++) {
			Integer total = totals.get(plans[i].Id);
			Integer complete = completed.get(plans[i].Id);
			Integer percent_complete = 0;
			// Adding the 0.5 at the end of the calculation ensures the number is rounded correctly when casting back to an Integer
			if(total>0){
				percent_complete = (Integer) (100.0 * (Double) complete / (Double) total + 0.5);
				plans[i].Percent_Complete_vod__c = percent_complete;
			}
			else if(total==0 || total==null){
				plans[i].Percent_Complete_vod__c = percent_complete;
			}
		}
	}
	
	
	update plans;
}