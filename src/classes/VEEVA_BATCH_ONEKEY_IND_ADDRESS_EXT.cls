/*********************************************************************************************************
Class calculate the address of an INDIVIDUAL for those without recent ACTIVITY  **************************
*********************************************************************************************************/
global without sharing class VEEVA_BATCH_ONEKEY_IND_ADDRESS_EXT 
implements Database.Batchable<SObject>, Database.Stateful 
{
    private Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();   
    private static String constSELECT = 'SELECT ';
 
    private final Id jobId;
    private final Datetime lastRunTime; 
    private final String country;
    //Viktor added country - 2013.05.07 
    
    global Integer  SuccessNumber = 0;
  	global Integer  FailureNumber = 0;
  	global Integer  totalNumber = 0; 
  	//Viktor added stateful - 2013.05.06
    
    /********** Empty constructor ************/
    public VEEVA_BATCH_ONEKEY_IND_ADDRESS_EXT() 
    {
    
      
    }
    
    /************************** Constructor *******************************/
    public VEEVA_BATCH_ONEKEY_IND_ADDRESS_EXT(Id JobId,Datetime lastRunTime) 
    {
       this();
       this.jobId = JobId;
       this.lastRunTime = lastRunTime;
       //this.lastRunTime = DateTime.newInstance(1970, 01, 01);
       this.country = null;
       
       System.Debug('CONSTRUCTOR BATCH VEEVA_BATCH_ONEKEY_UPDATE_IND_ADDRESS');  
       System.Debug('without country');  
    }
    public VEEVA_BATCH_ONEKEY_IND_ADDRESS_EXT(Id JobId,Datetime lastRunTime, String country) 
    {
       this();
       this.jobId = JobId;
       this.lastRunTime = lastRunTime;
       //this.lastRunTime = DateTime.newInstance(1970, 01, 01);
       this.country = country;
       
       System.Debug('CONSTRUCTOR BATCH VEEVA_BATCH_ONEKEY_UPDATE_IND_ADDRESS');  
       System.Debug('with country');  
    }
    
    
    
      
    
    /***************************************************************
    
    ***************************************************************/  
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {	
     
    String selStmt=' ';
    String sAddressStage = 'OK_STAGE_ADDRESS__c';
    String sAddressStageRel = 'OK_STAGE_ADDRESS__r';
    String sAddressRel = 'OK_STAGE_ADDRESS_INT__c';
    
    /************************** Create base query *********************************************************/
    Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sAddressStage).getDescribe().fields.getMap();
    Map <String,String> StageFieldMap = new Map <String,String>();
   
    for(Schema.SObjectField sfield : fieldMap.Values())
    {
            schema.describefieldresult dfield = sfield.getDescribe();
            if(!dfield.getName().equals('null') || dfield.getName() != null)
            {
                selStmt = selStmt + sAddressStageRel + '.' + dfield.getName() + ','; 
            }         
    }
    /************************** Create base query *********************************************************/
           
    //Complete SOQL
    //Remove the last comma
    selStmt = constSELECT + selStmt + 'OK_Process_Code__c,External_Id__c, OK_Stage_Workplace__r.Home__c,OK_Stage_Workplace__c, OK_Stage_Workplace__r.Workplace_External_Id__c, OK_Stage_Workplace__r.Workplace_Name__c ';
    selStmt = selStmt + ', OK_Stage_Workplace__r.External_Id__c, OK_Stage_Workplace__r.Individual_Account__c, OK_Stage_Workplace__r.Individual_Account__r.OK_External_ID_BI__c, Primary__c,Billing__c,Mailing__c,Business__c,OK_End_Date__c ';   //CSABA 20121.02.09  ,added OK_End_Date__c
    selStmt = selStmt + ', OK_STAGE_ADDRESS__r.OK_State_Province_BI__r.name ';  // Raphael

    //CSABA 2012.09.20.  selStmt = selStmt + 'FROM  ' + sAddressRel + ' where LastModifiedDate >=' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.\'000Z\'') + '  ORDER BY OK_Process_Code__c ASC Limit 10 ';  //2012.07.18.  50000000
    
    //selStmt = selStmt + 'FROM  ' + sAddressRel + ' where LastModifiedDate >=' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.\'000Z\'') + ' OR OK_STAGE_ADDRESS__r.LastModifiedDate >=' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.\'000Z\'') + '  ORDER BY OK_Process_Code__c ASC Limit 50000000 ';
 
     
    
    selStmt = selStmt + 'FROM  ' + sAddressRel + ' where OK_STAGE_ADDRESS__r.LastModifiedDate >=' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.\'000Z\'');
     
     	
    if (country != null) {
		selStmt += ' AND (OK_STAGE_ADDRESS__r.Country_Code_BI__c = \''
			+ country
			+ '\' OR OK_STAGE_ADDRESS__r.Country_vod__c =\''
			+ country
			+ '\')'
			; 
    }
    
    selStmt += '  ORDER BY OK_Process_Code__c ASC Limit 50000000';
    
    // For testing  - limit 0
    //selStmt = selStmt + 'FROM  ' + sAddressRel + ' where OK_STAGE_ADDRESS__r.LastModifiedDate >=' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.\'000Z\'') + '  ORDER BY OK_Process_Code__c ASC Limit 0';
   
                
    System.Debug('SQLU: ' + selStmt);  
      
    return Database.getQueryLocator(selStmt);   
  }
 
 
   /*********************************************************************
   Execute main logic  of the batch.  Collect all WKP IDs from the batch.
   Collect all OLD ctivities  for these WKPs.  
   *********************************************************************/  
   global void execute(Database.BatchableContext BC, List<sObject> batch) 
   {

      List<OK_STAGE_ADDRESS_INT__c> addressStageRecords = (List<OK_STAGE_ADDRESS_INT__c>) batch;
      
      system.debug('BatchSize = ' + addressStageRecords.size());
      
      Set<Id> StageWkpIds = new Set<Id>();     	
									 
	  for (OK_STAGE_ADDRESS_INT__c WARu : addressStageRecords)
	  {
	  StageWkpIds.add(WARu.OK_Stage_Workplace__c);	
	  }	
	  							 
							 		 
      OK_Stage_Activity__c[] activityStageRecords = [Select Stage_Workplace__r.External_Id__c, OK_Process_Code__c,External_Id__c,Stage_Workplace__c,
                                                     Do_Not_Mail__c, Individual_External_Id__c, Mailing__c, Primary__c ,Active_Status__c, ACT_CORE_OK_Activity_ID__c,OK_Act_Phone__c,OK_Act_Fax__c
                                                     FROM  OK_Stage_Activity__c
				                                     where 
				                                     LastModifiedDate < :lastRunTime  //to exclude the ones already processed
				                                     
				                                     and
				                                     Stage_Workplace__c in: StageWkpIds
				                                     Order by Individual_External_Id__c, Primary__c
				                                    ];
				                                    
	   system.Debug('Last run time: ' + lastRunTime);
	   system.Debug('Work places size = ' + StageWkpIds.size());
       
   	   system.Debug('Batch execute 1: activityStageRecords size = ' + activityStageRecords.size());
       
       List<Address_vod__c> addressRecs = new List<Address_vod__c>();  //Address to UPSERTS
       Map<String,Address_vod__c> mapAddress = new Map<String,Address_vod__c>();
                       
       //iterate  through  all ACTIVITY  records  from the above list.
       for(OK_Stage_Activity__c actvStageRecord : activityStageRecords)
       {
            //For each record, pull out the addresses
            if(actvStageRecord.Individual_External_Id__c != null)
            {
            	  system.Debug('Batch execute 4');
            	
                  for(OK_STAGE_ADDRESS_INT__c aStageAddressRel : addressStageRecords)
                  {
                  	
                  	   system.Debug('Batch execute 5');
                       if(aStageAddressRel.OK_Stage_Workplace__c ==  actvStageRecord.Stage_Workplace__c)
                       {
                       	system.Debug('Batch execute 6');
                       	
                        Account acct = new Account(OK_External_ID_BI__c = actvStageRecord.Individual_External_Id__c);  //TAKE CARE OF THE ExternalId  naming  convention. (here: ACT_CORE_OK_Id__c)

 						totalNumber = totalNumber + 1;
                        
                        //Find the list of addresses associated to the workplace
                        Address_vod__c address = new Address_vod__c(Name = aStageAddressRel.OK_STAGE_ADDRESS__r.Name,
                        									
                                                            Brick_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.Brick_vod__c,
                                                            
                                                            City_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.City_vod__c,
                                                            //Country_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.Country_vod__c,
                                                            Country_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.Country_Code_BI__c,
                                                            // Need to copy the Country Code for BI
                                                            Country_Code_BI__c = aStageAddressRel.OK_STAGE_ADDRESS__r.Country_Code_BI__c,
                                                            Zip_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.Zip_vod__c,   
                                                            //State_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.State_vod__c,
                                                            State_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.OK_State_Province_BI__r.name,
                                                            // The county field isn't used by BI - the Province is stored in the State_vod__c field 
                                                            //ACT_CORE_County__c = aStageAddressRel.OK_STAGE_ADDRESS__r.County__c,                 
                                                            OK_State_Province_BI__c = aStageAddressRel.OK_STAGE_ADDRESS__r.OK_State_Province_BI__c,                                    
                                                            RecordTypeId = aStageAddressRel.OK_STAGE_ADDRESS__r.RecordTypeId__c, 
                                                            Account_vod__r = acct,
                                                            Primary_vod__c = actvStageRecord.Primary__c,  //not true!!
                                                            // Change the Integration Time field to the be the implementation specific one
                                                            OK_IntegrationTime_BI__c = system.now(),
                                                            // Change the External ID to be the implementation specific one.
                                                            //External_ID_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.External_ID_vod__c + actvStageRecord.Individual_External_Id__c,  //2012.07.21.
                                                            OK_External_ID_BI__c = aStageAddressRel.OK_STAGE_ADDRESS__r.External_ID_vod__c + actvStageRecord.Individual_External_Id__c,
                                                            // Change the process code to be the implementation specific one.
                                                            OK_Process_Code_BI__c =  actvStageRecord.Active_Status__c == 'Invalid' ?  'D10' : aStageAddressRel.OK_Process_Code__c  
                                                            );         
                                                                
     
                       address.Billing_vod__c = aStageAddressRel.Billing__c;
                       address.Mailing_vod__c = aStageAddressRel.Mailing__c;
                       address.Business_vod__c = aStageAddressRel.Business__c;
     
                       /**************************************************************/
                       //2012.09.15. NL speccific
                       address.Phone_vod__c = actvStageRecord.OK_Act_Phone__c;
                       address.Fax_vod__c = actvStageRecord.OK_Act_Fax__c;
                        
                       /***********************************************************************************
                       try
                       {
                       	String SACT_ExtID =  actvStageRecord.External_Id__c.split('_')[1];
                       	// Change the OK external ID to the implementation specific one
                       	Child_Account_vod__c CA = new Child_Account_vod__c(External_ID2__c = SACT_ExtID);
                       	// TODO I'm assuming the activity refers to the individual or???
                       	//address.ACT_CORE_OK_Activity__r = CA; 
                       }
                       catch (Exception exu)
                       {
                       	VEEVA_BATCH_ONEKEY_BATCHUTILS.setErrorMessage(jobId, exu.getMessage());    
                       }                    
                       /***********************************************************************************/
                       
                       //some  customers need  to create  only the primary addresses belonging  to INDIVIDUAL's primary parent!                  	                      
	                       if (actvStageRecord.Primary__c == false)
	                       {//non-primary parent
	                       	address.Primary_vod__c = false;
	                       	if (address.OK_Process_Code_BI__c <> 'D10')
	                       	   address.OK_Process_Code_BI__c = 'D11';  //will be delete later
	                       }
	                       else
	                       {//primary  parent
	                       	if (aStageAddressRel.Primary__c == true)
	                       	{
	                    	   	address.Primary_vod__c = true;	
	                       	}
	                       	else
	                       	{
	                       		address.Primary_vod__c = false;
	                       		if (address.OK_Process_Code_BI__c <> 'D10')
	                       	   		address.OK_Process_Code_BI__c = 'D22';
	                       	}
	                   }                     
                       //some  customer  need  to create  only the primary addresses belonging  to INDIVIDUAL's primary parent!
                       
                       
   						//2012.06.21.  Handle  here the situation where the WKP addresses  became INACTIVE
  						if (aStageAddressRel.OK_End_Date__c == 'Inactive')
  						{
  						address.OK_Process_Code_BI__c = 'D20';	
  						}
  						//2012.06.21.  Handle  here the situation where the WKP addresses  became INACTIVE    
  						
  						//2012.09.21 /*******************************************************
  						if (address.OK_Process_Code_BI__c <> 'D10' && 
  						    address.OK_Process_Code_BI__c <> 'D11' &&
  						    address.OK_Process_Code_BI__c <> 'D22' &&
  						    address.OK_Process_Code_BI__c <> 'D20'
  						    )
  						    {
  						    address.OK_Process_Code_BI__c = address.OK_Process_Code_BI__c  + '99';	
  						    }                    
                       //2012.09.21 *******************************************************/
     
                        mapAddress.put(aStageAddressRel.OK_STAGE_ADDRESS__r.External_ID_vod__c + actvStageRecord.Individual_External_Id__c,address);
                           
                           
                       system.Debug('New ADDR: ' + address.Name + ' ProcessCODE: ' + address.OK_Process_Code_BI__c + ' ActStatus: ' + actvStageRecord.Active_Status__c); 
                           
                              //I guess just to avoid to many upsertable addresses
                             if(mapAddress.size() > 9000)
                             {
                                //Loop Through to pull address
                                /**
                                for(String addrExternalId:mapAddress.keyset()){
                                     addressRecs.add(mapAddress.get(addrExternalId));
                                 } 
                                 */
                                 for(Address_vod__c myaddress:mapAddress.values())
                                 {
                                     addressRecs.add(myaddress);
                                 } 
                                
                                //Run the upsert
                                UpserResults(addressRecs);
                                //Reset the list
                                addressRecs = new List<Address_vod__c>();
                                mapAddress = new Map<String,Address_vod__c>();                         
                             }     
                       }
                  }  
            }
       }
       
        //Upsert the last batch
       if(!mapAddress.isEmpty())
       {
                 /**
                 for(String addrExternalId:mapAddress.keyset()){
                       addressRecs.add(mapAddress.get(addrExternalId));
                  } 
                  */
                  for(Address_vod__c myaddress:mapAddress.values())
                  {
                             addressRecs.add(myaddress);
                  }   
                 
                 UpserResults(addressRecs);         
        }        
   }
   
   
   /**********************************************************
   Upsert the addresses passes as parameter in the List obj.
   **********************************************************/
   private void UpserResults(List<Address_vod__c> addressRecs)
   {
       //Upsert Addr.  Identify the existing addresses based on the Address_vod__c.External_ID_vod__c  field.
       //TAKE CARE OF THE NAMING  CONVENTION OF THE EXTERNAL ID
       Database.Upsertresult[] results = Database.upsert(addressRecs,Address_vod__c.OK_External_ID_BI__c,false);  
       
  
                String ErrorMessage = '';
                if(results != null)
                {
                    
                    for(Database.Upsertresult result : results)
                    {
                        if(!result.isSuccess()){
                             Database.Error[] errs = result.getErrors();
                             for(Database.Error err: errs)
                             {
                                ErrorMessage = ErrorMessage + err.getStatusCode() + ' : ' + err.getMessage() + '\r';
                             }
                             FailureNumber = FailureNumber + 1;      
                        }
                        else
                        SuccessNumber = SuccessNumber + 1;  
                    }   
                }
                
            if(ErrorMessage.length() > 1)
            {   
                 VEEVA_BATCH_ONEKEY_BATCHUTILS.setErrorMessage(jobId, ErrorMessage);              
            }   
   } 
   
   
   /***********************************************
   
   ***********************************************/
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