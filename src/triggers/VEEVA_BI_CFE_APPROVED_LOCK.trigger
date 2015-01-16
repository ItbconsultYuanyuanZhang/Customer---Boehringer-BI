trigger VEEVA_BI_CFE_APPROVED_LOCK on Coaching_Report_vod__c (after insert, after update) {
	
	Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
	set<Id> cfes = new set<Id>();
		
	for (Integer i = 0; i < Trigger.size; i++) {
		if(trigger.new[i].Status__c == 'Approved'){
			cfes.add(trigger.new[i].Id);
			app.setObjectId(trigger.new[i].Id);
			Approval.ProcessResult result = Approval.process(app);
		}
	}
	
	for (CFE_Report_Behavior_BI__c CRB : [SELECT id from CFE_Report_Behavior_BI__c where Coaching_Report_BI__c in :cfes]){
		app.setObjectId(CRB.Id);
		Approval.ProcessResult result = Approval.process(app);
	}	
	
}