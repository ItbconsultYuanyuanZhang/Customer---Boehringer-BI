/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Deletion Cycle Data Records
*  @author:         Jefferson Escobar
*  @created:        06-Aug-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			30.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         06-Aug-2014                 jescobar                 	Construction of the class.
*/ 
public class IMP_BI_DataDeletion {
	public Matrix_BI__c matrix {get;private set;}
	public String errMsg {get;private set;}
	private Id delMatrixBatchId;
	
	public Id cycId{get; private set;}
	private map<String, String> map_urlParams;
	public List<Cycle_Data_Overview_BI__c> products{get;set;}
	public String products2Del {get;set;}
	
	
	/**Status bar*/
	public Integer progress {get;private set;}
	private Set<Id> batchIds;
	public boolean enableSync {get;private set;}
	public Boolean runBatch {get;private set;}
	
	  /**
    * The contsructor
    *
    @author Jefferson Escobar
    @created 06-Aug-2014
    @version 1.0
    @since 30.0 (Force.com ApiVersion)
    *
    @changelog
    * 06-Aug-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    * - Created
    */
    public IMP_BI_DataDeletion(ApexPages.standardController sc) {
        map_urlParams = ApexPages.currentPage().getParameters();
        
        if(map_urlParams.containsKey('id')){
            cycId = map_urlParams.get('id');
        }
        if(cycId != null){
           init(cycId);
        }
    }
    
    /**
    * This method is used to 
    *
    @author Jefferson Escobar
    @created 06-Aug-2014
    @version 1.0
    @since 26.0 (Force.com ApiVersion)
    *
    *@param id          cycle id
    @changelog
    * 06-Aug-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    * - Created
    */
    
    public void init(Id cyId){
    	//Init bar progress
    	progress = 0;
    	enableSync=false;
    	Cycle_BI__c cyc = [SELECT Country_Lkp_BI__c, Country_Lkp_BI__r.Name FROM Cycle_BI__c WHERE Id =:cyId limit 1];
        List<Id> productIds = new List<Id>();
        this.products = new List<Cycle_Data_Overview_BI__c>();
        
        if(cyc.Country_Lkp_BI__c != null){
            for(Cycle_Data_Overview_BI__c cdo : [SELECT Product_Catalog_BI__c,	Product_Catalog_BI__r.Name,Count_BI__c FROM Cycle_Data_Overview_BI__c WHERE Cycle_BI__c = :cyId order by Product_Catalog_BI__r.Name]){
            	this.products.add(cdo);
            }
        }
    }
	
	/**
	* Return Back to Cycle Page
	* @return Pagereference
	*/
	public pageReference cancel(){
        pageReference pr = new pageReference('/' + cycId);
        pr.setRedirect(true);
        return pr;
    }
    
    /**
	* Return Back to Cycle Page
	* @return Pagereference
	*/
	public pageReference calculateCycleData(){
        pageReference pr = new pageReference('/apex/IMP_BI_CtrlCalculateCycleDataOverview?cycid=' + cycId + '&retUrl=/'+cycId);
        pr.setRedirect(true);
        return pr;
    }
    
    
    /**
	* Delete cycle data records
	*
	* @param Matrix Id
	* @return Pagereference
	*
	* @changelog
	*  04-Aug-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	*  - Created
	*/
	public Pagereference runDeletionProcess () {
    	try{
    		List<String> list_prodIds = new List<String>();
			list_prodIds.addAll(this.products2Del.split(','));
			
			runBatch = runBatch(cycId, list_prodIds);
			system.debug(':: Run Batch: ' + runBatch);
			
			if(runBatch){
				runDeletionBatch(cycId, list_prodIds);
			}else{
				runDeletionOnTheFly(cycId, list_prodIds);
			}
    	}catch(Exception e){
    		system.debug('[ERROR] - ' + e.getMessage());
    		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage()));
    	}
    	
    	return null;
    }
    
    
   /**
   * Validate if the batch process must be executed
   *
   * @param cyCId Cycle Id
   * @param list_prodIds List of producto to be deleted
   * 
   * @return booelan true is the amount of records is higher than 10000
   */
   boolean runBatch (Id cyCId, List<String> list_prodIds){
   		boolean runBatch;
   		Integer countRecords = -1;
   		countRecords=[SELECT count() FROM Cycle_Data_BI__c  WHERE Cycle_BI__c = :cycId AND Product_Catalog_BI__c IN :list_prodIds limit 9001];
   		
   		return countRecords>9000 ? true : false;
   }
    
    /**
	* Run batch process to delete cycle data products
	*
	* @changelog
	*  08-Aug-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	*  - Created
	*/
    public void runDeletionBatch(Id cycId, List<String> list_prodIds){
    	this.batchIds = new Set<Id>();
		//Run batch to delete matrix cell detail records related to the matrix
		IMP_BI_ClsBatch_ClearCycleData batchDelCD = new IMP_BI_ClsBatch_ClearCycleData(cycId, list_prodIds);
		Id batchDelMatrixCellsId = Database.executeBatch(batchDelCD);
		batchIds.add(batchDelMatrixCellsId);
		enableSync=true;
		progress=1;
		system.debug(':: Deleting...    ' + products2Del);
    }
    
    
    /**
	* Run deletion process on the fly
	*
	* @changelog
	*  08-Aug-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	*  - Created
	*/
    public void runDeletionOnTheFly(Id cycId, List<String> list_prodIds){
    	Savepoint sp = Database.setSavepoint();
    	try{
    		
    		//Delete cycle Records
    		system.debug(':: Prodcuts: ' + list_prodIds + ' Cycle: ' + cycId);
    		List<Cycle_Data_BI__c> cds = [SELECT Id FROM Cycle_Data_BI__c  WHERE Cycle_BI__c = :cycId AND Product_Catalog_BI__c IN :list_prodIds];
    		system.debug(':: Cycle Data: ' + cds.size());
    		database.delete(cds);
			//database.emptyRecycleBin(cds);
    		
    		//Delete Matrices related
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
				//database.emptyRecycleBin(list_matrix2del);
            }
            
            this.progress = 100;
            
    	}catch(Exception e){
    		Database.rollback(sp);
			system.debug('[ERROR] - ' + e.getMessage());
    		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage()));
		}
     	
    }
    
    /**
	* Synchronize status of deletion
	* @return Pagereference
	*
	* @changelog
	*  15-Mar-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	*  - Created
	*/
	public Pagereference syncProgressBar(){
		try{
			Double itemsProcessed = 0;
			Double totalItems = 0;
			
			List<AsyncApexJob> jobs = [select TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, Id, CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name From AsyncApexJob 
	        						where Id = :batchIds]; 
			
			//Query the Batch apex jobs
	        for(AsyncApexJob a : jobs){
	            system.debug(':: Total Items: ' + totalItems + ' Items processed: ' + itemsProcessed + ' Status: ' + a.Status);
				itemsProcessed += a.JobItemsProcessed != null ? a.JobItemsProcessed : 0;
				totalItems += a.TotalJobItems != null ? a.TotalJobItems : 0;
	        }
			
			system.debug(':: Progress: ' + progress + ' Total Items: ' + totalItems +' Items Processed: ' + itemsProcessed );
	        
	        if(totalItems == 0){
	            //A little check here as we don't want to divide by 0.
	            progress  = 1;
	        }else{
	            progress  = ((itemsProcessed  / totalItems) * 100.0).intValue();
	        }
	        
	        if(progress>99){
				progress = 100;
				enableSync=false;
			}else if(progress<=0){
				progress = 1;
	        }
        }catch(Exception e){
			system.debug('[ERROR] - ' + e.getMessage());
    		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage()));
		}
        return null;
	}
     
/**
==================================================================================================================================
												Wrapper Classes                                                     
==================================================================================================================================
*/  
	
}