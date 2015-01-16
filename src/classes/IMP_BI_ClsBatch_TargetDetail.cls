/**
 *  This batch class is used to cleans the Target Detail which identifies if the version is identical with the one on Portfolio.
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
global class IMP_BI_ClsBatch_TargetDetail implements Database.Batchable<SObject>, Database.Stateful{
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
	global IMP_BI_ClsBatch_TargetDetail(){
	}
	global Database.QueryLocator start(Database.BatchableContext BC){
		if(query == null || query == '') {
			query = 'SELECT Account_BI__c, CreatedById, CreatedDate, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, Portfolio_BI__c, Product_Catalog_BI__c, Id, Segment_BI__c, Strategic_Brand_Weight_BI__c, SystemModstamp, Target_Account_BI__c, Name, Target_Details_BI__c, Version_BI__c, Version_Comparison_BI__c,Portfolio_BI__r.Version_BI__c ' +
			        'FROM Target_Detail_BI__c where IsDeleted = false ';
	  	}
	  	if(filter != null) query += filter;
		return Database.getQueryLocator(query);
   }
	global void execute(Database.BatchableContext BC, list<Target_Detail_BI__c> list_targetDetail){
		list<Target_Detail_BI__c> list_total = new list<Target_Detail_BI__c>();
		for(Target_Detail_BI__c td: list_targetDetail){
			if(td.Version_BI__c != null &&  td.Portfolio_BI__r.Version_BI__c != null && td.Version_BI__c != td.Portfolio_BI__r.Version_BI__c){
				list_total.add(td);	
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