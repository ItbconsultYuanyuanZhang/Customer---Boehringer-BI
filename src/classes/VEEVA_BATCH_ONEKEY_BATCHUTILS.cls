/*****************************************************************
Contains methods for executing and monitoring batch job processes.
FRAMEWORK class  which  is not suppossed to be changed unless new
jobs  are not needed.  

Lastmod by Viktor 2013-05-30 Country specific job support 
	sendEmail_EXT void
 ****************************************************************/
public without sharing class VEEVA_BATCH_ONEKEY_BATCHUTILS 
{   
    // Constants  
    private static final Integer DEFAULT_BATCH_SIZE = 200;         
    
    //define  constants  with the JOB names  
    public static final String JOB_SYNCH_ADDRESS = 'SynchronizeAddress';
    public static final String JOB_SYNCH_INDVIDUAL_ADDRESS = 'Synchronize_Individual_Address';
    
    public static final String JOB_SYNCH_INDVIDUAL_ADDRESS_EXT = 'Synchronize_Individual_Address_extended';   //2012.09.20

    public static final String JOB_RUN_DELETES = 'RunDeletes';
    public static final String JOB_CLEAN_UP_ADDRESS = 'Clean_and_Update_Primary_Address';
    public static final String JOB_SET_DCR_SENT = 'Set_DCR_Sent';  
    public static final String JOB_PROCESS_DCR_RESP = 'Process_DCR_Response';  
    public static final String JOB_PROCESS_UPDATE_DMMY_WKP_NAME = 'Process_WKP_DUMMY_NAME';  //CSABA 2012.05.08.       
    public static final String VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR = 'VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR';        
    public static final String VEEVA_BI_BATCH_Address_Preferred_flag = 'VEEVA_BI_BATCH_Address_Preferred_flag';       
          
    //define  constants  for Job  status 
    public static final String STATUS_SUBMITTED = 'Submitted';
    public static final String STATUS_STARTED = 'Started';   
    public static final String STATUS_RUNNING = 'Running';
    public static final String STATUS_COMPLETED = 'Completed';
    
    //TODO pass country code to appropriate job - onekey cleanup address
    //Viktor added country specific pass along for every job - 2013.05.07
       
    
    /**
     * Executes a batch job.
     */
     
    // Added polymorphic signatures to handle country - Raphael - 2013-03-19
    public static void execute(Set<Id> jobIds, String theProcessName)   
    {
    	execute(jobIds, theProcessName, null);
    }
    
    public static void execute(Set<Id> jobIds, String theProcessName, String country) {   
        Datetime LastRunTime = Datetime.now();
        //Datetime LastRunTime = datetime.newInstance(1970, 2, 20); //FOR INITIAL TESTING ONLY
        
        
        /**************** Identify  the time when the Connecotr  last run ****************************/   
        List<V2OK_Batch_Job__c> BatchJobLastModified = [Select LastModifiedDate from V2OK_Batch_Job__c 
                                                        where Status__c = 'Completed' 
                                                        and First_Process__c = TRUE 
                                                        Order By LastModifiedDate DESC];  
 
        if(BatchJobLastModified.size() > 0)
        {
            LastRunTime = BatchJobLastModified[0].LastModifiedDate;  
           
            if(BatchJobLastModified.size() > 1 && theProcessName <> 'SynchronizeAddress') 
            {
                //Always pick the previous run time
                LastRunTime = BatchJobLastModified[1].LastModifiedDate;
            }  
                  
        }        
        
        System.debug('Last Run Time ' + LastRunTime);
        /**************** Identify  the time when the Connector  last run ****************************/        
        
        //Identify  the current batch  job to run
        for (V2OK_Batch_Job__c job : [SELECT Id, Process_Name__c
                                      FROM V2OK_Batch_Job__c
                                      WHERE Id IN :jobIds]) 
        {
            Database.Batchable<SObject> batchable = null;
            Integer batchSize = DEFAULT_BATCH_SIZE;
            
            
            if (JOB_SYNCH_ADDRESS.equalsIgnoreCase(job.Process_Name__c)) 
            {
                if (country == null) 	batchable = new VEEVA_BATCH_ONEKEY_UPDATE_ADDRESS(job.Id, LastRunTime);
            	else					batchable = new VEEVA_BATCH_ONEKEY_UPDATE_ADDRESS(job.Id, LastRunTime, country);
                batchSize = 10000;
            } 
            else if (JOB_SYNCH_INDVIDUAL_ADDRESS.equalsIgnoreCase(job.Process_Name__c)) 
            {
				if (country == null) 	batchable = new VEEVA_BATCH_ONEKEY_UPDATE_IND_ADDRESS(job.Id, LastRunTime);
            	else					batchable = new VEEVA_BATCH_ONEKEY_UPDATE_IND_ADDRESS(job.Id, LastRunTime, country);
                batchSize = 500;
            }
            else if(JOB_RUN_DELETES.equalsIgnoreCase(job.Process_Name__c))
            {
                 if (country == null) 	batchable = new VEEVA_BATCH_ONEKEY_RUNDELETES(job.Id, LastRunTime);
            	 else					batchable = new VEEVA_BATCH_ONEKEY_RUNDELETES(job.Id, LastRunTime, country);
                 batchSize = 1000;
                 
            }
            else if(JOB_CLEAN_UP_ADDRESS.equalsIgnoreCase(job.Process_Name__c))
            {
            	if (country == null) 	batchable = new VEEVA_BATCH_ONEKEY_CLEANUP_ADDRESS(job.Id, LastRunTime);
            	else					batchable = new VEEVA_BATCH_ONEKEY_CLEANUP_ADDRESS(job.Id, LastRunTime, country);
                
                //batchSize = 2000;
                batchSize = 140;
                // Batch size reduced by Raphael - 2013-03-24
                
                /*
                // TODO remove below once testing has been done - skips VEEVA_BATCH_ONEKEY_CLEANUP_ADDRESS 
              	if (country == null) 	batchable = new VEEVA_UPDATE_DCR_SENT(job.Id, LastRunTime);
            	else 					batchable = new VEEVA_UPDATE_DCR_SENT(job.Id, LastRunTime, country);
                batchSize = 2000;
                */   
            }
            else if(JOB_SET_DCR_SENT.equalsIgnoreCase(job.Process_Name__c))   
            {
				if (country == null) 	batchable = new VEEVA_UPDATE_DCR_SENT(job.Id, LastRunTime);
            	else 					batchable = new VEEVA_UPDATE_DCR_SENT(job.Id, LastRunTime, country);
                batchSize = 2000;              
            }
            else if(JOB_PROCESS_DCR_RESP.equalsIgnoreCase(job.Process_Name__c))   
            {
                    
                 if (country == null) 	batchable = new VEEVA_BATCH_PROCESS_DCR_RESPONSE(job.Id, LastRunTime);
            	 else 					batchable = new VEEVA_BATCH_PROCESS_DCR_RESPONSE(job.Id, LastRunTime, country);
                 batchSize = 100;   
            }    
           else if(JOB_PROCESS_UPDATE_DMMY_WKP_NAME.equalsIgnoreCase(job.Process_Name__c))   
            {    
            	 if (country == null) 	batchable = new VEEVA_BATCH_Update_DummyWKP_Name(job.Id, LastRunTime);
            	 else 					batchable = new VEEVA_BATCH_Update_DummyWKP_Name(job.Id, LastRunTime, country);
                 batchSize = 1000;   
            }
            /********************************** 2012.09.20 ******************************/                                   
            else if(JOB_SYNCH_INDVIDUAL_ADDRESS_EXT.equalsIgnoreCase(job.Process_Name__c))   
            {    
                 if (country == null) 	batchable = new VEEVA_BATCH_ONEKEY_IND_ADDRESS_EXT(job.Id, LastRunTime);
            	 else 					batchable = new VEEVA_BATCH_ONEKEY_IND_ADDRESS_EXT(job.Id, LastRunTime, country);
                 batchSize = 100;   
            }           
            /********************************** 2012.09.20 ******************************/  
             else if(VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR.equalsIgnoreCase(job.Process_Name__c))
            {
            	if (country == null) 	batchable = new VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR(job.Id, LastRunTime);
            	else 					batchable = new VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR(job.Id, LastRunTime, country);
				batchSize = 500;   
            }
            /********************************** 2013.05.23 ******************************/  
             else if(VEEVA_BI_BATCH_Address_Preferred_flag.equalsIgnoreCase(job.Process_Name__c))
            {
            	if (country == null) 	batchable = new VEEVA_BI_BATCH_Address_Preferred_flag();
            	else 					batchable = new VEEVA_BI_BATCH_Address_Preferred_flag(country);
				batchSize = 200;   
            }
            
                
                                    
            //if batch  jb  was identified start it *******   
            if (batchable != null) 
            {
                Database.executeBatch(batchable, batchSize);
                
                job.Status__c = STATUS_STARTED;
                job.Start_Time__c = Datetime.now();
                update job;
            }
            //if batch  jb  was identified start it *******
        }
    }
     
    /**
     * Updates the job status to STATUS_RUNNING.
     */
    public static void setRunning(Id jobId) 
    {
        if (jobId != null) 
        {
            List<V2OK_Batch_Job__c> jobs = [SELECT Id FROM V2OK_Batch_Job__c WHERE Id = :jobId];
            if (!jobs.isEmpty()) 
            {
                V2OK_Batch_Job__c job = jobs.get(0);
                job.Status__c = STATUS_RUNNING;
                update job;
            }
        }
    }
    
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
            List<V2OK_Batch_Job__c> jobs = [SELECT Id FROM V2OK_Batch_Job__c WHERE Id = :jobId];
            if (!jobs.isEmpty()) 
            {
                V2OK_Batch_Job__c job = jobs.get(0);
                job.Status__c = STATUS_COMPLETED;
                job.End_Time__c = Datetime.now();
                job.LastRunTime__c = LRT; //2012.09.23.    
                update job;
            }
        }
    }
    
     /***********************************************************
     insert a record  into a custom object
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
    
    
    /*************************************************************
    Send an email.  the email will be handled  by a dedicated class
    that class  will insert a new record  into the Batch job  obj.
    and  kick off a new job 
    *************************************************************/
    public static void sendEmail(String toAddress, String Subject) 
    {
    	System.Debug('Sending email to: ' + toAddress + '  with Subject: ' + Subject); //2012.02.25.
    	
        if (toAddress != null && Subject != null) 
        {
           
           //Get EmailReplyTo  from the custom settings
           Data_Connect_Setting__c dcSettings = Data_Connect_Setting__c.getInstance('EmailReplyTo');
           String strReplyTo = dcSettings.Value__c;
           dcSettings = Data_Connect_Setting__c.getInstance('EmailSenderName');
           String strSenderName = dcSettings.Value__c;
           
           Messaging.reserveSingleEmailCapacity(5);
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           
           String[] toAddresses = new String[] {toAddress};
           
           
           mail.setToAddresses(toAddresses);
           mail.setReplyTo(strReplyTo);
           
           // Specify the name used as the display name.
           mail.setSenderDisplayName(strSenderName);
           
           mail.setSubject(Subject);
           
           // Specify the text content of the email.
           mail.setPlainTextBody(Subject);
           
           
           System.Debug('Email: ' + mail);
           
           
           // Send the email you have created.
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });          
        }
        System.Debug('Email sent.'); //2013.05.06
    }
    
    /***********************************************************************************
    Viktor - 2013.05.30.  - New Email sending function that includes country in the body
    ************************************************************************************/    
    public static void sendEmail_EXT(String toAddress, String Subject, String Body) 
    {
    	System.Debug('Sending email to: ' + toAddress + '  with Subject: ' + Subject); //2012.02.25.
    	
        if (toAddress != null && Subject != null) 
        {
           //Send Email
           //Get EmailReplyTo
           Data_Connect_Setting__c dcSettings = Data_Connect_Setting__c.getInstance('EmailReplyTo');  
           String strReplyTo = dcSettings.Value__c;
           dcSettings = Data_Connect_Setting__c.getInstance('EmailSenderName');
           String strSenderName = dcSettings.Value__c;
           
           Messaging.reserveSingleEmailCapacity(5);
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           
           String[] toAddresses = new String[] {toAddress};
                      
           mail.setToAddresses(toAddresses);
           mail.setReplyTo(strReplyTo);
           
           // Specify the name used as the display name.
           mail.setSenderDisplayName(strSenderName);
           
           mail.setSubject(Subject);
           
           // Specify the text content of the email.
           //2012.09.19 check if needed mail.setPlainTextBody(Subject);              
            mail.setPlainTextBody(Body);  //2012.09.19.
           
           // Send the email you have created.
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });          
        }
    } 
   
    
}