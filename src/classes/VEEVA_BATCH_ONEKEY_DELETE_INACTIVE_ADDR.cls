global without sharing class VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR 
implements Database.Batchable<SObject>, Database.Stateful
{
  
 private Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        
 private final Id jobId;
 private final Datetime lastRunTime;
 private final String country;
 
 //Viktor added country - 2013.05.07
 
 global Integer  SuccessNumber = 0;
 global Integer  FailureNumber = 0;
 global Integer  totalNumber = 0; 
    
    public VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR() 
    {
       
    
    }
    public VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR(Id JobId,Datetime lastRunTime) 
    {
       this();
       this.jobId = JobId;
       this.lastRunTime = lastRunTime;
       this.country = null;
    }
	
	public VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR(Id JobId,Datetime lastRunTime, String country) 
    {
       this();
       this.jobId = JobId;
       this.lastRunTime = lastRunTime;
       this.country = country;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
    String selStmt = '';
    
    selStmt = 'Select ID,OK_Process_Code_BI__c from Address_vod__c where (OK_Process_Code_BI__c like \'D%\') ';
    
    if (country != null) {
		selStmt += ' AND (Country_Code_BI__c = \''
			+ country
			+ '\' OR Country_vod__c =\''
			+ country
			+ '\' ) limit 50000000'
			;
	}
    
    return Database.getQueryLocator(selStmt);        	
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> batch) 
    {
       List<Address_vod__c> addressRecords = (List<Address_vod__c>) batch;
       
       List<Address_vod__c> addressToDel = new List<Address_vod__c> ();

      Data_Connect_Setting__c dcSettings = Data_Connect_Setting__c.getInstance('OnlyPrimaryAddress');
      String OnlyPrimaryAddress = dcSettings.Value__c;   	
      system.Debug('OnlyPrimaryAddress = ' + OnlyPrimaryAddress); 
       
       for(Address_vod__c address : addressRecords)
         {
       	    if (OnlyPrimaryAddress == 'True')
       	    {
             if(address.OK_Process_Code_BI__c == 'D' ||      //INACTIVR Addresses of Individuals
                address.OK_Process_Code_BI__c == 'D1' ||     //non-primary parent primary addr
                address.OK_Process_Code_BI__c == 'D2' ||     //non primary address of non-primary parent             
                address.OK_Process_Code_BI__c == 'D3' ||     //non-primary parent secondary address
                address.OK_Process_Code_BI__c == 'D0' ||     //Non-primary addresses of WKP 
                address.OK_Process_Code_BI__c == 'D11' ||    //non-primary parent primary addr
                address.OK_Process_Code_BI__c == 'D22' ||    //non primary address of non-primary parent
                address.OK_Process_Code_BI__c == 'D33' ||    //non-primary parent secondary address
                address.OK_Process_Code_BI__c == 'D20'       //IND addresses from INACTIVE Addresses of Workplaces 
                )           
                    addressToDel.add(address);     
                    integer iu = 0;          
       	    }
            else
            {
            if(address.OK_Process_Code_BI__c == 'D' ||       //INACTIVE ADDRESSES
               address.OK_Process_Code_BI__c == 'D20'        //IND addresses from INACTIVE Addresses of Workplaces 
               )            
                    addressToDel.add(address);  
                     integer iw = 0;             	     	    	
            }
            totalNumber = totalNumber + 1;               	
            	
         }//end for loop  
              
        if(!addressToDel.isEmpty())
        {
  
         Database.DeleteResult[] delresults = Database.delete(addressToDel);
         String delErrorMessage = 'AddressToDelete:';
         if(delresults != null)
         {          
            for(Database.DeleteResult result : delresults)
            {
             if(!result.isSuccess())
                {
                 Database.Error[] errs = result.getErrors();
                 for(Database.Error err: errs)
                     {
                     delErrorMessage = delErrorMessage + err.getStatusCode() + ' : ' + err.getMessage() + '\r';
                     } 
                    FailureNumber = FailureNumber + 1;         
                 }
                 else  {
                 	//CSABA 2012.03.23.  clear the err str otherwise it will isert into Batch error object.
                    delErrorMessage = '';
                    SuccessNumber = SuccessNumber + 1;  
                 }  
            }
                    
          if(delErrorMessage.length() > 1)   
               VEEVA_BATCH_ONEKEY_BATCHUTILS.setErrorMessage(jobId, delErrorMessage); 
          }
        }
    }  
  
    /*************************************************
    setting the job  as completed  will generate an 
    email  and a new job. 
    *************************************************/
    global void finish(Database.BatchableContext BC)
    {
            VEEVA_BATCH_ONEKEY_BATCHUTILS.setErrorMessage(jobId, 'TotalBatchSize =' + this.totalNumber + ' Success Upsert = ' + this.SuccessNumber + ' Failed Upsert = ' + this.FailureNumber);  
            VEEVA_BATCH_ONEKEY_BATCHUTILS.setCompleted(jobId,lastRunTime);      
    }     
       
}