/*********************************************************
When a job is finished  and its  status  is updated to
COMPLETED  this  trigger  calculates the next pair  of
Current/Next  job  and sends an emaill with  this info
The email  is handled  by a dedicated class  and initiates
a new job
This trigger is not supposed  to change. 
(unless a new job needs to be added)

Lastmod by Viktor 2013-05-30 Country specific job support
*********************************************************/ 
trigger ExecuteNextJob on V2OK_Batch_Job__c (after update) 
{
    
      private String Country;
      
      for (V2OK_Batch_Job__c batchJob : Trigger.new)      
      {
        //
        Data_Connect_Setting__c connectSettings = Data_Connect_Setting__c.getInstance('ToEmailService');
        String veeva2OKBatchEndpoint = connectSettings.Value__c; 
        String strSubject = '';
        
        if(batchJob.Process_Name__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_SYNCH_ADDRESS &&
            batchJob.Status__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.STATUS_COMPLETED && 
            batchJob.Next_Batch_Process__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_SYNCH_INDVIDUAL_ADDRESS)
        {
            //Kick Off the next set of Jobs - Current Job : Next Job
            //2012.;09.21 ORIGINAL strSubject = VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_SYNCH_INDVIDUAL_ADDRESS + ':' + VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_CLEAN_UP_ADDRESS;       
            strSubject = VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_SYNCH_INDVIDUAL_ADDRESS + ':' + VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_SYNCH_INDVIDUAL_ADDRESS_EXT;  
        }
        /********************************** 2012.09.21. ************************************************/ 
         else if(batchJob.Process_Name__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_SYNCH_INDVIDUAL_ADDRESS &&
                 batchJob.Status__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.STATUS_COMPLETED && 
                 batchJob.Next_Batch_Process__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_SYNCH_INDVIDUAL_ADDRESS_EXT)
        {
            //strSubject = VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_SYNCH_INDVIDUAL_ADDRESS_EXT + ':' + VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_CLEAN_UP_ADDRESS;
            strSubject = VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_SYNCH_INDVIDUAL_ADDRESS_EXT + ':' + VEEVA_BATCH_ONEKEY_BATCHUTILS.VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR;
        } 
         else if(batchJob.Process_Name__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_SYNCH_INDVIDUAL_ADDRESS_EXT &&
                 batchJob.Status__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.STATUS_COMPLETED && 
                 batchJob.Next_Batch_Process__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR)
        {
            strSubject = VEEVA_BATCH_ONEKEY_BATCHUTILS.VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR + ':' + VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_CLEAN_UP_ADDRESS;
        } 

         else if(batchJob.Process_Name__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.VEEVA_BATCH_ONEKEY_DELETE_INACTIVE_ADDR &&
                 batchJob.Status__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.STATUS_COMPLETED && 
                 batchJob.Next_Batch_Process__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_CLEAN_UP_ADDRESS)
        {
            strSubject = VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_CLEAN_UP_ADDRESS + ':' + VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_RUN_DELETES;
        }               
        /********************************** 2012.09.21 *************************************************/
        else if(batchJob.Process_Name__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_CLEAN_UP_ADDRESS &&
                 batchJob.Status__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.STATUS_COMPLETED && 
                 batchJob.Next_Batch_Process__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_RUN_DELETES)
        {    
           strSubject = VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_RUN_DELETES + ':' + VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_PROCESS_DCR_RESP; //2012.03.24.    
        }
         //CSABA 2012.03.24.  add the DataChangeRequest Response batch to the chain
         else if(batchJob.Process_Name__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_RUN_DELETES &&
                 batchJob.Status__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.STATUS_COMPLETED && 
                 batchJob.Next_Batch_Process__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_PROCESS_DCR_RESP)
         {           
         //2012.05.08. strSubject = VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_PROCESS_DCR_RESP + ':';  
         strSubject = VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_PROCESS_DCR_RESP + ':' + VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_PROCESS_UPDATE_DMMY_WKP_NAME;
         }  
         //CSABA 2012.05.08.  add the JOB_PROCESS_UPDATE_DMMY_WKP_NAME batch to the chain
         else if(batchJob.Process_Name__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_PROCESS_DCR_RESP &&
                 batchJob.Status__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.STATUS_COMPLETED && 
                 batchJob.Next_Batch_Process__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_PROCESS_UPDATE_DMMY_WKP_NAME)
         {             
         //2013.05.23. strSubject = VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_PROCESS_UPDATE_DMMY_WKP_NAME + ':';
         strSubject = VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_PROCESS_UPDATE_DMMY_WKP_NAME + ':' + VEEVA_BATCH_ONEKEY_BATCHUTILS.VEEVA_BI_BATCH_Address_Preferred_flag;
         }         
         //VIKTOR 2013.05.23.  add the VEEVA_BI_BATCH_Address_Preferred_flag batch to the chain
         else if(batchJob.Process_Name__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.JOB_PROCESS_UPDATE_DMMY_WKP_NAME &&
                 batchJob.Status__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.STATUS_COMPLETED && 
                 batchJob.Next_Batch_Process__c == VEEVA_BATCH_ONEKEY_BATCHUTILS.VEEVA_BI_BATCH_Address_Preferred_flag)
         {             
         strSubject = VEEVA_BATCH_ONEKEY_BATCHUTILS.VEEVA_BI_BATCH_Address_Preferred_flag + ':';
         }          

         
        //if the string is not empty send an email. The email service handler class will create new JOB record
        //and BATCH UTILITY class will run again upon BAtchJOB insert
        
        System.Debug('NEXT JOB: ' + strSubject);
        
        if(strSubject != '')
        {
            //VIKTOR 2013-05-30 Added country specific email settings
            Country = trigger.new[0].OK_Country__c;
            if(Country == null || Country == ' ') VEEVA_BATCH_ONEKEY_BATCHUTILS.sendEmail(veeva2OKBatchEndpoint, strSubject);
            else if(Country != null) VEEVA_BATCH_ONEKEY_BATCHUTILS.sendEmail_EXT(veeva2OKBatchEndpoint, strSubject, Country); 
        
        }
      }//end of for
      
      

}