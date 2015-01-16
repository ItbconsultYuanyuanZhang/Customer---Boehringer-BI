/*****************************************************************************************************
Batch assure that there are no multiple Prinary addresses for a account and deletes the addr. with 'D'
Not supposed  to change.
*****************************************************************************************************/
global without sharing class VEEVA_BATCH_ONEKEY_CLEANUP_ADDRESS 
implements Database.Batchable<SObject>, Database.Stateful //Viktor added stateful
{

	private Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	private static String constSELECT = 'SELECT ';  
	        
	global Integer  SuccessNumber = 0;
  	global Integer  FailureNumber = 0;
  	global Integer  totalNumber = 0; 
	
	
	
	private final Id jobId;
	private final Datetime lastRunTime;
	private final String country;
		
	
	// Raphael added country - 2013-03-19
    
	public VEEVA_BATCH_ONEKEY_CLEANUP_ADDRESS()
    {
        
    }
    
    public VEEVA_BATCH_ONEKEY_CLEANUP_ADDRESS(Id JobId,Datetime lastRunTime) 
    {
       this();
       this.jobId = JobId;
       this.lastRunTime = lastRunTime;
       this.country = null;
    }
    
    public VEEVA_BATCH_ONEKEY_CLEANUP_ADDRESS(Id JobId,Datetime lastRunTime, String country) 
    {
       this();
       this.jobId = JobId;
       this.lastRunTime = lastRunTime;
       this.country = country;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
   
    String selStmt = '';
    // Create base query
    Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Address_vod__c').getDescribe().fields.getMap();
    system.debug(fieldMap);
    
    Map <String,String> StageFieldMap = new Map <String,String>();

    for(Schema.SObjectField sfield : fieldMap.Values())
    {
            schema.describefieldresult dfield = sfield.getDescribe();
            if(!dfield.getName().equals('null') || dfield.getName() != null)
            {
            	system.debug('dfield: ' + dfield.getName());
                selStmt = selStmt + dfield.getName() + ',';
            }            
    }
    
   //Complete SOQL
   //Remove the last comma
   //selStmt = selStmt.substring(0,selStmt.length() - 1);
   // Keep the last comma - Raphael - 2013-03-24
   
   // We need the Primary parent account's ID - Raphael - 2013-03-24
   selStmt += ' Account_vod__r.Primary_Parent_vod__c, Account_vod__r.RecordType.DeveloperName, Account_vod__r.OK_External_ID_BI__c ';
   
   
   // Raphael added in LastModifiedDate - 2013-03-24
   selStmt = constSELECT + selStmt
	+ ' FROM  Address_vod__c'
	+ ' WHERE LastModifiedDate >= ' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.\'000Z\'')
	+ ' AND OK_External_ID_BI__c != \'\''
	// Use this instead of the above 2 lines if you want every (professional) address checked
	//+ ' WHERE OK_External_ID_BI__c != \'\''
	;
	
	if (country != null) {
		selStmt += ' AND (Country_Code_BI__c = \''
			+ country
			+ '\' OR Country_vod__c =\''
			+ country
			+ '\')'
			;
	}
	
   // This limit should /ALWAYS/ be zero during testing.     
	//selStmt += ' Order By  Account_vod__c, Primary_vod__c DESC, LastModifiedDate DESC  Limit 50000000';  //2012.07.18. 50000000
   
	// With kludge by Raphael 2013-03-24
   	//selStmt += ' Order By  Account_vod__c, Primary_vod__c DESC, LastModifiedDate DESC, CreatedDate DESC  Limit 50000000';  //2012.07.18. 50000000
   
   selStmt += ' ORDER BY Account_vod__c LIMIT 50000000';
   
	system.debug('Select statement for batch: ' + selStmt);
    
    return Database.getQueryLocator(selStmt);
    
  }
  
    global void execute(Database.BatchableContext BC, List<sObject> batch) 
    {
       
       List<Address_vod__c> addressRecords = (List<Address_vod__c>) batch;
       
       List<Address_vod__c> AddressToUpdate = new List<Address_vod__c>();
       List<Address_vod__c> addressToDel = new List<Address_vod__c> ();
       Id CurrentAccount = null;

 
            //********************************************************************************************
            //Loop through the addresses  and assure that 1 account has only 1 primary  address
            //not sure is needed.  Veeva vod triggers clear  the previous primary flag when another is set  
            /** Removed by Raphael - this is handled by the 
            for(Address_vod__c addresslp : addressRecords)
            {
                CurrentAccount = addresslp.Account_vod__c;
                if(PreviousAccount== null || CurrentAccount != PreviousAccount)
                {    
                        //Ignore to update
                        if(addresslp.Primary_vod__c == FALSE && addresslp.Name != 'N/A')
                        {
                            
                                Address_vod__c addToUpdate = new Address_vod__c(
                                                         Id =   addresslp.Id,
                                                         Primary_vod__c = TRUE);
                                //Add to Primary
                                AddressToUpdate.add(addToUpdate);
                        }       
                }
                else
                {
                        //Set the non-primary
                         Address_vod__c addToUpdate = new Address_vod__c(Id = addresslp.Id,
                                                         Primary_vod__c = FALSE);
                         AddressToUpdate.add(addToUpdate);
                        
                }
                    
                PreviousAccount = CurrentAccount;
                

            }
            
            **/
            
            
            // Added by Raphael 2013-03-24
            // Ensure only the address which matches the primary parent is selected
            // Move PreviousAccount marker here
            String PrimaryAddress_OK_External_Id;
            Id PreviousAccount;
            Boolean address_ok = true;
            
            for (Address_vod__c address : addressRecords) {
            	// We only want to look at professional addresses that have a primary parent
            	if (address.Account_vod__r.RecordType.DeveloperName != 'Professional_vod' || address.Account_vod__r.Primary_Parent_vod__c == null) continue;
            	
            	system.debug('address id: ' + address.Id);
            	CurrentAccount = address.Account_vod__c;
            	system.debug('Account id: ' + CurrentAccount);
            	
            	//system.debug('Account name: ' + CurrentAccount.Name);
            	if (CurrentAccount != PreviousAccount) {
            		Id parentAccount = address.Account_vod__r.Primary_Parent_vod__c;
            		Boolean error_found = false;
            		Address_vod__c primaryAccountAddress;
            		try {
            			primaryAccountAddress = [
            				SELECT Id, OK_External_ID_BI__c
	            			FROM Address_vod__c
	            			WHERE Account_vod__c = :parentAccount
	            			AND Primary_vod__c = true
	            		];
	            		
	            		if (primaryAccountAddress == null) throw new NoDataFoundException();
            		} catch (Exception e) {
            			address_ok = false;
            			error_found = true;
            			// If there's an error - e.g. we can't find a primary address,
            			// then lets just skip to the next iteration.
            		}
            		
            		if (!error_found) {
            			address_ok = true;
            			List<String> addOKId = primaryAccountAddress.OK_External_ID_BI__c.split('_');
            			PrimaryAddress_OK_External_Id = addOKId[1] + address.Account_vod__r.OK_External_ID_BI__c;
            			system.debug('Primary address OK External ID: ' + PrimaryAddress_OK_External_Id);
            		}
            	}

            	PreviousAccount = CurrentAccount; // For the next iteration
            	
            	if (!address_ok) continue; // if the address isn't ok
            	
            	if (PrimaryAddress_OK_External_Id == address.OK_External_ID_BI__c) {
            		if (address.Primary_vod__c != true) {
            			address.Primary_vod__c = true;
            			AddressToUpdate.add(address);
            			
            		}
            	} else {
            		if (address.Primary_vod__c != false) {
            			address.Primary_vod__c = false;
            			AddressToUpdate.add(address);
            		}
            	}
            	totalNumber = totalNumber + 1;  
            	
            }
            
            
            //**************************************************************************************/

      /***********************************************************************************************
   	  //2012.09.14. Get custom setting.         In some case we are creating  Only primary addresses  
      Data_Connect_Setting__c dcSettings = Data_Connect_Setting__c.getInstance('OnlyPrimaryAddress');
      String OnlyPrimaryAddress = dcSettings.Value__c;   	
      system.Debug('OnlyPrimaryAddress = ' + OnlyPrimaryAddress);     
     
       for(Address_vod__c address : addressRecords)
       {     
       	    if (OnlyPrimaryAddress == 'True')
       	    {
             if(address.OK_PROCESS_CODE__C == 'D' || 
                address.OK_PROCESS_CODE__C == 'D1' || 
                address.OK_PROCESS_CODE__C == 'D2'  ||
                address.OK_PROCESS_CODE__C == 'D10' ||
                address.OK_PROCESS_CODE__C == 'D11' ||
                address.OK_PROCESS_CODE__C == 'D22' ||
                address.OK_PROCESS_CODE__C == 'D20'
                )    
                    {         
                    addressToDel.add(address); 
                    }            
       	    }
            else
            {
            if(address.OK_PROCESS_CODE__C == 'D' || 
               address.OK_PROCESS_CODE__C == 'D10' ||
               address.OK_PROCESS_CODE__C == 'D20' 
               )    
                    {        
                    addressToDel.add(address);    
                    }        	     	    	
            }
       }
         
         System.Debug('Addresses to delete= ' + addressToDel.size());
       ***************************************************************************************************/  
          
        //**********************************************************************************************************************                                                                       
        if(!AddressToUpdate.isEmpty())
        {
            
            Database.SaveResult[] updresults = Database.update(AddressToUpdate);
            String upErrorMessage = 'AddressToUpdate:';
            if(updresults != null){
                 for(Database.SaveResult result : updresults)
                 {
                        if(!result.isSuccess())
                        {
                             Database.Error[] errs = result.getErrors();
                             for(Database.Error err: errs)
                             {
                                upErrorMessage = upErrorMessage + err.getStatusCode() + ' : ' + err.getMessage() + '\r';
                             }
                             FailureNumber = FailureNumber + 1;          
                        }
                        else
                        SuccessNumber = SuccessNumber + 1;  
                        
                 }
                 
                 if(upErrorMessage.length() > 16)
                 {   
                    VEEVA_BATCH_ONEKEY_BATCHUTILS.setErrorMessage(jobId, upErrorMessage);
                 } 
            }     
        }
        //***********************************************************************************************************************/
        
        /****************************************************************************
        if(!addressToDel.isEmpty())
        {
            
                Database.DeleteResult[] delresults = Database.delete(addressToDel);
                String delErrorMessage = 'AddressToDelete:';
                if(delresults != null){
                    
                    for(Database.DeleteResult result : delresults)
                    {
                        if(!result.isSuccess())
                        {
                             Database.Error[] errs = result.getErrors();
                             for(Database.Error err: errs)
                             {
                                delErrorMessage = delErrorMessage + err.getStatusCode() + ' : ' + err.getMessage() + '\r';
                             }      
                        }
                        else  //CSABA 2012.03.23.  clear the err str otherwise it will isert into Batch error object.
                          delErrorMessage = '';
                    }
                    
                    if(delErrorMessage.length() > 1)
                    {   
                          VEEVA_BATCH_ONEKEY_BATCHUTILS.setErrorMessage(jobId, delErrorMessage);
                    } 
 
                }
         
        }
        ******************************************************************************************************/
                
    }
    
    
    /*************************************************
    setting the job  as completed  will generate an 
    email  and a new job. 
    *************************************************/
    global void finish(Database.BatchableContext BC)
    {
           //VEEVA_BATCH_ONEKEY_BATCHUTILS.setCompleted(jobId,lastRunTime); 
            VEEVA_BATCH_ONEKEY_BATCHUTILS.setErrorMessage(jobId, 'TotalBatchSize =' + this.totalNumber + ' Success Upsert = ' + this.SuccessNumber + ' Failed Upsert = ' + this.FailureNumber);    
           setCompleted(jobId,lastRunTime);    
    }   


/******************************* 2012.11.21. ********************************************/
/* Add this here from batchutil class  only  to avoid cross-refference deployment error */
   /*******************************************
    Updates the job status to STATUS_COMPLETED 
    and populates the end time with the current
    system date/time.
    This  function will initiate a trigger which
    will  kick of the next  job  later
    *******************************************/
    public static void setCompleted(Id jobId, DateTime LRT) 
    {
        if (jobId != null) 
        {
            List<V2OK_Batch_Job__c> jobs = [SELECT Id FROM V2OK_Batch_Job__c 
                                            WHERE Id = :jobId
                                            ];
            if (!jobs.isEmpty()) 
            {
                V2OK_Batch_Job__c job = jobs.get(0);
                job.Status__c = 'Completed';
                job.End_Time__c = Datetime.now();
                job.LastRunTime__c = LRT;   
                update job;
            }
        }
    }
    
     /***********************************************************
     insert a record  into a custom object:   Batch_Job_Error__c
     ***********************************************************/
     public static void setErrorMessage(Id jobId, String Message) 
     {
        if (jobId != null) 
        {
            //Create an error message  
                Batch_Job_Error__c jobError = new Batch_Job_Error__c();
                jobError.Error_Message__c = Message;
                jobError.Veeva_To_One_Key_Batch_Job__c = jobId;
                jobError.Date_Time__c = Datetime.now();
                insert jobError;        
        }
    }
/* Add this here from batchutil class  only  to avoid cross-refference deployment error */    
/******************************* 2012.11.21. ********************************************/
}