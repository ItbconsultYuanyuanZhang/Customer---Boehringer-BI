/*************************************************************************************************
This class DELETEs  the records which were marked having OK_PROCESS_CODE = 'D' or state 'INACTIVE'
*************************************************************************************************/
global without sharing class VEEVA_BATCH_ONEKEY_RUNDELETES implements Database.Batchable<SObject>
{
    
private final String initialState;
private final static String sInbound = 'Inbound';
  

private final Id jobId;
private final Datetime lastRunTime;
private final String country;
//Viktor added country - 2013.05.07
    
public VEEVA_BATCH_ONEKEY_RUNDELETES()   
{
    
    
}

public VEEVA_BATCH_ONEKEY_RUNDELETES(Id JobId,Datetime lastRunTime) 
{
       this();
       this.jobId = JobId;
       this.lastRunTime = lastRunTime;
       this.country = null;
}  

public VEEVA_BATCH_ONEKEY_RUNDELETES(Id JobId,Datetime lastRunTime, String country)
{
       this();
       this.jobId = JobId;
       this.lastRunTime = lastRunTime;
       //this.lastRunTime = DateTime.newInstance(1970, 01, 01);
       this.country = country;
       
       System.Debug('with country');  
}  

//collect the records to be deleted ****************************
global Database.QueryLocator start(Database.BatchableContext BC) 
{ 
    // Create base query
    String selStmt = 'Select ID From Child_Account_vod__c where (OK_Process_Code_BI__c = \'D\' or OK_Active_Status_BI__c = \'Invalid\' or OK_Active_Status_BI__c = \'STA.9\') ';  //2012.07.18
    
    if (country != null) {
		selStmt += ' AND (OK_Country_Code_BI__c = \''
			+ country
			+ '\') limit 50000000'
			; 
    }
    
    system.debug('Batch select statement: ' + selStmt);
    return Database.getQueryLocator(selStmt);
  
}
  


/*********************************************************************
Delete records having OK_PROCESS_CODE = 'D' from the following objects
Child_Account_vod__c and sometimes (Account)

//Address_vod__c  was handled separatelly
*********************************************************************/
global void execute(Database.BatchableContext BC, List<sObject> batch) 
{

         List<Child_Account_vod__c> CAsTODelete = (List<Child_Account_vod__c>) batch;
         delete CAsTODelete;
         
         return;

		/**
        //sometimes  Inactive accounts need to be deleted  but as a base rule we are not deleting  accounts
        List<String> myDistObj = new List<String>();
        
        myDistObj.add('Account');

        //Generate a list of queries for each object
        for(String objName: myDistObj)
        {                      
                String sSOQL = 'Select Id from ' + objName + ' where OK_Process_Code_BI__c = \'D\' ';
                List<sObject> s = Database.query(sSOQL);
                delete s;  
        }
        **/
        
} 

/***********************************************
fire an update trigger o Batch Job  object which
kick of the Next job.
***********************************************/
global void finish(Database.BatchableContext BC)
{      
   //VEEVA_BATCH_ONEKEY_BATCHUTILS.setCompleted(jobId,lastRunTime); 
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