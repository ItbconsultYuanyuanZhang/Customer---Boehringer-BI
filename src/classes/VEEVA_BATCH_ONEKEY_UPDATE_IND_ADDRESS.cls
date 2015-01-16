/*********************************************************************************************************
Class calculate the address of an INDIVIDUAL  based on the ACTIVITY file and WKP_ADDRESS_RELATION file
This  class is ssbject to change.
*********************************************************************************************************/
global without sharing class VEEVA_BATCH_ONEKEY_UPDATE_IND_ADDRESS 
implements Database.Batchable<SObject>, Database.Stateful 
{
      
 private static String constSELECT = 'SELECT ';
 
 private final Id jobId;
 private final Datetime lastRunTime;
 private final String country;
//Viktor added country - 2013.05.07
 
 global Integer  SuccessNumber = 0;
 global Integer  FailureNumber = 0;
 global Integer  totalNumber = 0; 
    
    public VEEVA_BATCH_ONEKEY_UPDATE_IND_ADDRESS()   
    {
    
        
    }
    public VEEVA_BATCH_ONEKEY_UPDATE_IND_ADDRESS(Id JobId,Datetime lastRunTime) 
    {
       this();
       this.jobId = JobId;
       this.lastRunTime = lastRunTime;
       //this.lastRunTime = DateTime.newInstance(1970, 01, 01);
       this.country = null;
       
       System.Debug('CONSTRUCTOR BATCH VEEVA_BATCH_ONEKEY_UPDATE_IND_ADDRESS');
       System.Debug('without country');    
    }
    
    public VEEVA_BATCH_ONEKEY_UPDATE_IND_ADDRESS(Id JobId,Datetime lastRunTime, String country)
	{
       this();
       this.jobId = JobId;
       this.lastRunTime = lastRunTime;
       //this.lastRunTime = DateTime.newInstance(1970, 01, 01);
       this.country = country;
       
       System.Debug('CONSTRUCTOR BATCH VEEVA_BATCH_ONEKEY_UPDATE_IND_ADDRESS'); 
       System.Debug('with country');  
	}  
    
    
      
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
      System.Debug('START BATCH VEEVA_BATCH_ONEKEY_UPDATE_IND_ADDRESS');    //2012.02.25.   
   
     //String selStmt = 'Select Object_Target_API_Name__c From Integration_Object__c Where Active__c = true AND VIntegration_Configuration__r.Direction__c = \'' + sInbound + '\'';
      String selStmt=' ';
      String sAddressStage = 'OK_STAGE_ADDRESS__c';
      String sAddressStageRel = 'OK_STAGE_ADDRESS__r';
      String sAddressRel = 'OK_STAGE_ADDRESS_INT__c';
      
      // Create base query
   
      //Complete SOQL
      //Remove the last comma
      selStmt = 'Select Stage_Workplace__r.External_Id__c, OK_Process_Code__c,External_Id__c,Stage_Workplace__c ';
      selStmt = selStmt + ', Do_Not_Mail__c, Individual_External_Id__c, Mailing__c, Primary__c ,Active_Status__c, ACT_CORE_OK_Activity_ID__c,OK_Act_Phone__c,OK_Act_Fax__c ';   //CSABA 2012.02.09.  added ,Active_Status__c.  2012.09.15  addeed ACT_CORE_OK_Activity_ID__c,OK_Act_Phone__c,OK_Act_Fax__c
      selStmt = selStmt + ', OK_Phone_Extension__c '; // 2013.01.28 for BI
      selStmt = selStmt + 'FROM  OK_Stage_Activity__c where LastModifiedDate >=' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.\'000Z\'') ;  //2012.07.18. 50000000
      //selStmt = selStmt + 'FROM  OK_Stage_Activity__c where Individual_External_Id__c = \'WCAM00086866\'';  
		
      if (country != null) {
		selStmt += ' AND (External_Id__c like \'W'
			+ country
			
			+ '%\')'
			; 
      }
      
      selStmt += '  ORDER BY Individual_External_Id__c, Primary__c, OK_Process_Code__c ASC Limit 50000000';
      
      System.Debug('SQLU: ' + selStmt);  //2012.02.25.
    
      return Database.getQueryLocator(selStmt); 
  }
  
   global void execute(Database.BatchableContext BC, List<sObject> batch) 
   {
    
       //Get a list of ACTIVITIES based o the previous methods SQL      
       List<OK_Stage_Activity__c> activityStageRecords = (List<OK_Stage_Activity__c>) batch;
       
       system.Debug('Batch execute 1:  ActSizu= ' + activityStageRecords.size());
       
       List<Address_vod__c> addressRecs = new List<Address_vod__c>();  //Address to UPSERTS
       Map<String,Address_vod__c> mapAddress = new Map<String,Address_vod__c>();
       Set<Id> StageWkpIds = new Set<Id>();
       
       //Will need both the individual id and wkpid
       for(OK_Stage_Activity__c anAct :activityStageRecords)  
       {
            StageWkpIds.add(anAct.Stage_Workplace__c); //COLLECT ALL WKPs
       }
       
       system.Debug('Batch execute 2: Collected WKPS = ' + StageWkpIds.size());
 
                
        
       //COLLECT all addresses  belonging to the above list of WKPs.  some customer  might  need other fileds  from CEGEDIM ADDRESS file
       //in this case you have  to add new fields to ADDRESS staging  object  and selects them in the below query.
       List<OK_STAGE_ADDRESS_INT__c> addrStageRecords = [Select OK_STAGE_ADDRESS__r.Name,
       															 
                                                                OK_STAGE_ADDRESS__r.Brick_vod__c,  
                                                                OK_STAGE_ADDRESS__r.Brick_Name__c,       
                                                                
                                                                OK_STAGE_ADDRESS__r.City_vod__c,
                                                                OK_STAGE_ADDRESS__r.Country_vod__c,
                                                                OK_STAGE_ADDRESS__r.Country_Code_BI__c,
                                                                OK_STAGE_ADDRESS__r.zip_vod__c,
                                                                //OK_STAGE_ADDRESS__r.State_vod__c, // NOT USED BY BI  
                                                                // OK_STAGE_ADDRESS__r.County__c,   // Not used by BI
                                                                OK_STAGE_ADDRESS__r.OK_State_Province_BI__c,
                                                                OK_STAGE_ADDRESS__r.OK_State_Province_BI__r.name, 
                                                                OK_STAGE_ADDRESS__r.RecordTypeId__c,
                                                                OK_STAGE_ADDRESS__r.External_ID_vod__c,
                                                                /* 
                                                                OK_STAGE_ADDRESS__r.BRICK_1__c,
                                                                OK_STAGE_ADDRESS__r.BRICK_2__c,
                                                                OK_STAGE_ADDRESS__r.BRICK_3__c,
                                                                */
                                                                OK_Stage_Workplace__c,
                                                                OK_Process_Code__c,
                                                                OK_End_Date__c,                
                                                                Primary__c,  Billing__c, Mailing__c, Business__c                       
                                                                from OK_STAGE_ADDRESS_INT__c 
                                                                where OK_Stage_Workplace__c in: StageWkpIds    
                                                                                                                            
                                                          ]; 

//OK_State_Province_BI__c = aStageAddressRel.OK_STAGE_ADDRESS__r.OK_State_Province_BI__c,
                                                          
       system.Debug('Batch execute 3 Collected WARs = ' + addrStageRecords.size());                                                   
                                                               
       
       //iterate  through  all ACTIVITY  records  since the last run
       for(OK_Stage_Activity__c actvStageRecord : activityStageRecords)
       {
            //
        
             //For each record, pull out the addresses
            if(actvStageRecord.Individual_External_Id__c != null)
            {
                  system.Debug('Batch execute 4');
                
                  for(OK_STAGE_ADDRESS_INT__c aStageAddressRel : addrStageRecords)
                  {
                    
                       system.Debug('Batch execute 5');
                       if(aStageAddressRel.OK_Stage_Workplace__c ==  actvStageRecord.Stage_Workplace__c)
                       {
                        system.Debug('Batch execute 6');
                        
                        //Find the list of addresses associated to the workplace
 
                        Account acct = new Account(OK_External_ID_BI__c = actvStageRecord.Individual_External_Id__c);  //TAKE CARE OF THE ExternalId  naming  convention. (here: ACT_CORE_OK_Id__c)
                          
                 		totalNumber = totalNumber + 1;         
                 		
                        Address_vod__c address = new Address_vod__c(Name = aStageAddressRel.OK_STAGE_ADDRESS__r.Name,
                        									
                                                            Brick_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.Brick_vod__c,
                                                           
                                                            City_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.City_vod__c,
                                                            // Country_Code_BI must be copied also
                                                            Country_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.Country_Code_BI__c,
                                                            Country_Code_BI__c = aStageAddressRel.OK_STAGE_ADDRESS__r.Country_Code_BI__c,
                                                            Zip_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.Zip_vod__c,   
                                                            // State_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.State_vod__c,
                                                            // State_vod__c not used for BI OK. 
                                                            // BI Canada uses OK_State_Province_BI__c for Provinces - county's are not used
                                                            OK_State_Province_BI__c = aStageAddressRel.OK_STAGE_ADDRESS__r.OK_State_Province_BI__c,
                                                            State_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.OK_State_Province_BI__r.name,
                                                            //ACT_CORE_County__c = aStageAddressRel.OK_STAGE_ADDRESS__r.County__c,
                                                            RecordTypeId = aStageAddressRel.OK_STAGE_ADDRESS__r.RecordTypeId__c, 
                                                            Account_vod__r = acct,
                                                            //Primary_vod__c = actvStageRecord.Primary__c,  //not true!!
                                                            OK_IntegrationTime_BI__c = system.now(), // Change field name to be installation dependent.    
                                                            OK_External_ID_BI__c = aStageAddressRel.OK_STAGE_ADDRESS__r.External_ID_vod__c + actvStageRecord.Individual_External_Id__c,  //2012.07.21.
                                                            // Change the Process code name to the implementation specific one                                      
                                                            OK_Process_Code_BI__c =  actvStageRecord.Active_Status__c == 'Invalid' ?  'D' : aStageAddressRel.OK_Process_Code__c                                                            
                                                            );     
                                                               
     
                       address.Billing_vod__c = aStageAddressRel.Billing__c;
                       address.Mailing_vod__c = aStageAddressRel.Mailing__c;
                       address.Business_vod__c = aStageAddressRel.Business__c;
     
                       //************************************************************** 
                       //2013.01.28 BI speccific
                       address.Phone_vod__c = actvStageRecord.OK_Act_Phone__c;
                       address.Fax_vod__c = actvStageRecord.OK_Act_Fax__c;
                       address.OK_Phone_Extension_BI__c = actvStageRecord.OK_Phone_Extension__c;
                       
                       
                         
                       /**************************************************************/
                       try
                       {
                       String SACT_ExtID =  actvStageRecord.External_Id__c.split('_')[1];
                       // Change the OK external ID to be the implementation specific one
                       Child_Account_vod__c CA = new Child_Account_vod__c(External_ID2__c = SACT_ExtID); 

                       // TODO: used by BI?
                       //address.ACT_CORE_OK_Activity__r = CA; 
                       }
                       catch (Exception exu)
                       {
                        //VEEVA_BATCH_ONEKEY_BATCHUTILS.setErrorMessage(jobId, exu.getMessage());
                       }                    
                       /**************************************************************/   
                       
                       //some  customers need  to create  only the primary addresses belonging  to INDIVIDUAL's primary parent!                                           
                           if (actvStageRecord.Primary__c == false)
                           {//non-primary parent
                           	system.debug('actvStageRecord.Primary__c is FALSE');
                            address.Primary_vod__c = false;
                            if (address.OK_Process_Code_BI__c <> 'D')
                               address.OK_Process_Code_BI__c = 'D1';  //will be delete later
                           }
                           else
                           {//primary  parent
                           		system.debug('actvStageRecord.Primary__c is True');
                           	
                            if (aStageAddressRel.Primary__c == true)
                            {
                            	system.debug('aStageAddressRel.Primary__c - true');
                            	address.Primary_vod__c = true;  
                            }
                            else
                            {
                            	system.debug('aStageAddressRel.Primary__c - false');
                            	address.Primary_vod__c = false;
                            	if (address.OK_Process_Code_BI__c <> 'D')
                               		address.OK_Process_Code_BI__c = 'D2';
                            }
                           }                     
                       //some  customer  need  to create  only the primary addresses belonging  to INDIVIDUAL's primary parent!
                       
                       // TYS.P, TYS.M, TYS.S
                       
                        //2012.06.21.  Handle  here the situation where the WKP addresses  became INACTIVE
                        if (aStageAddressRel.OK_End_Date__c == 'Inactive')
                        {
                        address.OK_Process_Code_BI__c = 'D';    
                        }
                        //2012.06.21.  Handle  here the situation where the WKP addresses  became INACTIVE                       
                       
     
                        mapAddress.put(aStageAddressRel.OK_STAGE_ADDRESS__r.External_ID_vod__c + actvStageRecord.Individual_External_Id__c,address);
                        
                        System.debug('Map size = ' + mapAddress.size());    
                        
                        system.debug('Address external ID: ' + address.OK_External_ID_BI__c);
                        system.debug('Address primary: ' + address.Primary_vod__c);
                           
                       system.Debug('New ADDR: ' + address.Name + ' AddrOneKey = ' + address.OK_External_ID_BI__c   + ' ProcessCODE: ' + address.OK_Process_Code_BI__c + ' ActStatus: ' + actvStageRecord.Active_Status__c + ', ACCOUNT = ' + actvStageRecord.Individual_External_Id__c); 

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
   The External ID in the ACTELION org is not clear yet.
   **********************************************************/
   private void UpserResults(List<Address_vod__c> addressRecs)
   {
       Integer sizu = addressRecs.size();
       System.Debug('We are going to update: ' + sizu + ' addresses');   
    
       //Upsert Addr.  Identify the existing addresses based on the Address_vod__c.External_ID_vod__c  field.
       Database.Upsertresult[] results = Database.upsert(addressRecs,Address_vod__c.OK_External_ID_BI__c,false);  //TAKE CARE OF THE NAMING  CONVENTION OF THE EXTERNAL ID
       
     
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