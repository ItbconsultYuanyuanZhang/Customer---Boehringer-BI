/**
 *  This batch class is used to clean the Target Account which identifies if the version is identical with the one on Portfolio.
 *
 @author Lili Zhao
 @created 2013-05-30
 @version 1.0
 @since 24.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-05-30 Lili Zhao <lili.zhao@itbconsult.com>
 * - Created
 */  
global class IMP_BI_ClsBatch_TargetAccount implements Database.Batchable<SObject>, Database.Stateful{
	global String query;
	global String filter;
  /**
    * The contsructor
    *
    @author Lili Zhao
    @created 2013-05-30
    @version 1.0
    @since 24.0 (Force.com ApiVersion)
    *
    @changelog
    * 2013-05-30 Lili Zhao <lili.zhao@itbconsult.com>
    * - Created
    */    
	global IMP_BI_ClsBatch_TargetAccount(){
	}
	global Database.QueryLocator start(Database.BatchableContext BC){
		if(query == null || query == '') {
			query = 'SELECT Id, Version_BI__c,Portfolio_BI__r.Version_BI__c ' +
			        'FROM Target_Account_BI__c where IsDeleted = false ';
	  	}
	  	if(filter != null) query += filter;
		return Database.getQueryLocator(query);
   }
	global void execute(Database.BatchableContext BC, list<Target_Account_BI__c> list_targetAccount){	
		list<Target_Account_BI__c> list_total = new list<Target_Account_BI__c>();
		for(Target_Account_BI__c ta: list_targetAccount){
			if(ta.Version_BI__c != null  && ta.Portfolio_BI__r.Version_BI__c != null && ta.Version_BI__c != ta.Portfolio_BI__r.Version_BI__c){
				list_total.add(ta);	
			}			
		}
		if(!list_total.isEmpty()){	
			//delete list_total;
			database.delete(list_total);
			database.emptyRecycleBin(list_total);
		}
	}
	   global void finish(Database.BatchableContext BC){	  
   }
}