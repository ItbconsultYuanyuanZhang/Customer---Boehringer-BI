/**
 *  This batch class is used to clean the Portfolio FieldForce Simulation which identifies if the version is not identical with the one on Portfolio.
 *
 @author Lili Zhao
 @created 2013-06-04
 @version 1.0
 @since 27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-06-04 Lili Zhao <lili.zhao@itbconsult.com>
 * - Created
 */  
global class IMP_BI_ClsBatch_FieldForceSimulation implements Database.Batchable<SObject>, Database.Stateful{
	global String query;
	global String filter;
  /**
    * The contsructor
    *
    @author Lili Zhao
    @created 2013-06-04
    @version 1.0
    @since 27.0 (Force.com ApiVersion)
    *
    @changelog
    * 2013-06-04 Lili Zhao <lili.zhao@itbconsult.com>
    * - Created
    */    
	global IMP_BI_ClsBatch_FieldForceSimulation(){
	}
	global Database.QueryLocator start(Database.BatchableContext BC){
		if(query == null || query == '') {
			query = 'SELECT Id, Version_BI__c,Portfolio_BI__r.Version_BI__c ' +
			        'FROM Portfolio_Field_Force_Simulation_BI__c ' + 
			        'where IsDeleted = false ';
	  	}	
	  	if(filter != null) query += filter;
		return Database.getQueryLocator(query);
   }
	global void execute(Database.BatchableContext BC, list<Portfolio_Field_Force_Simulation_BI__c> list_portfolioFieldForceSimulation){	
		list<Portfolio_Field_Force_Simulation_BI__c> list_total = new list<Portfolio_Field_Force_Simulation_BI__c>();
		for(Portfolio_Field_Force_Simulation_BI__c pffs: list_portfolioFieldForceSimulation){
			if(pffs.Version_BI__c != null  && pffs.Portfolio_BI__r.Version_BI__c != null && pffs.Version_BI__c != pffs.Portfolio_BI__r.Version_BI__c){
				list_total.add(pffs);	
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