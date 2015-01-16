/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Delete products for a specif cycle
*  @author:         Jefferson Escobar
*  @created:        06-Aug-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			30.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         06-Aug-2014                 jescobar                 	Construction of the class.
*/ 
 
global class IMP_BI_ClsBatch_ClearCycleData implements Database.Batchable<SObject>, Database.Stateful {
	
	global Id cycId;
	global List<String> list_prodIds;
	
	/**
	*Default constructor
	*/ 
	global IMP_BI_ClsBatch_ClearCycleData (Id cycId, List<String> list_prodIds){
		this.cycId = cycId;
		this.list_prodIds = list_prodIds;	
	}
	
	
	/**
	* Retrieve all the cycle data related to a Matrix
	*
	* @param BC batchable context
	* @return
	*
	* @changelog
	* 04-Jul-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator([SELECT Id FROM Cycle_Data_BI__c  WHERE Cycle_BI__c = :cycId AND Product_Catalog_BI__c IN :list_prodIds ]);
	}
	
	
	/**
	* Execute cycle data updating process
	*
	* @param BC batchable context
	* @param cycle data list to be updated
	* @return
	*
	* @changelog
	* 04-Jul-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	global void execute(Database.BatchableContext BC, List<Cycle_Data_BI__c> cycleData){
		database.delete(cycleData);
		database.emptyRecycleBin(cycleData);
	}
	
	/**
	* Send email to user after the updating process
	*
	* @param BC batchable context
	* @return
	*
	* @changelog
	* 04-Jul-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	global void finish(Database.BatchableContext BC){
		
		//Clear data related
		clearMatrixData(list_prodIds);
	}
	
	
	/**
	* Delete all matrices related to the products already deleted
	*
	* @param list_prodIds IDs products deleted
	* @return
	*
	* @changelog
	* 04-Jul-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	public void clearMatrixData(List<String> list_prodIds) {
        Savepoint sp = Database.setSavepoint();
        try{
            List<Matrix_BI__c> list_matrix2del = new List<Matrix_BI__c>();
            for(Matrix_BI__c mat : [SELECT Id 
                                 FROM Matrix_BI__c
                                 WHERE Cycle_BI__c =:cycId
                                 AND Product_catalog_BI__c IN :list_prodIds
                                 AND Status_BI__c = 'Draft']){
                list_matrix2del.add(mat);
            }
            
            if(list_matrix2del.size() != 0){
            	database.delete(list_matrix2del);
				database.emptyRecycleBin(list_matrix2del);
            }
            
        }
        catch(DmlException de){
    		Database.rollback(sp);
    		system.debug('[ERROR] - ' + de.getMessage());
    	}
    }
	
	
}