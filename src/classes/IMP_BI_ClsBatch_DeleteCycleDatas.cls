global class IMP_BI_ClsBatch_DeleteCycleDatas implements Database.Batchable<SObject>, Database.Stateful{
	/*
	IMP_BI_ClsBatch_DeleteCycleDatas d = new IMP_BI_ClsBatch_DeleteCycleDatas();
	d.set_ids = new set<Id>{'a39J00000004FxA'};
	database.executebatch(d);
	*/
	public set<id> set_ids;
	public boolean useValidation = false;

    global Database.QueryLocator start(Database.BatchableContext BC){
		String query = 'SELECT Id, Intimacy_BI__c,Potential_BI__c  FROM Cycle_Data_BI__c';
		if(set_ids != null) query += ' where Cycle_BI__c in: set_ids ';
		else query += ' where id = null ';
	    return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Cycle_Data_BI__c> list_cycleData){
    	
    	if(useValidation) {
	        list<Cycle_Data_BI__c> list_2delete = new list<Cycle_Data_BI__c>();
		    for(Cycle_Data_BI__c cd: list_cycleData){
		    	if(cd.Intimacy_BI__c < 0) list_2delete.add(cd);   
		    	if(cd.Potential_BI__c < cd.Intimacy_BI__c) list_2delete.add(cd);   
		        if(cd.Potential_BI__c <= 0) list_2delete.add(cd);      
		        if(cd.Intimacy_BI__c >100000000 || cd.Potential_BI__c >100000000) list_2delete.add(cd);  
		    }  
		    if(!list_2delete.isEmpty()) {
		    	Database.delete(list_2delete, false);
		    	Database.emptyRecycleBin(list_2delete);
		    }
    	}
    	else {
	    	Database.delete(list_cycleData, false);
	    	Database.emptyRecycleBin(list_cycleData);
    	}
    }

    global void finish(Database.BatchableContext BC){
    }
}