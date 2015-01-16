/******************************************************************************************************
This class updates the stage addresses with the Cegedim Best Office times 
from the stage activities.

Should run before the other OK or address inheritance jobs.

TO RUN:
VEEVA_BATCH_ONEKEY_BESTOFFICETIMES b = new VEEVA_BATCH_ONEKEY_BESTOFFICETIMES ('DE'); database.executebatch(b,100);

Created by: Viktor, 2013.07.15
************************* *****************************************************************************/
global without sharing class VEEVA_BATCH_ONEKEY_BESTOFFICETIMES implements Database.Batchable<SObject>, Database.Stateful {
 
 
 global Integer  SuccessNumber = 0;
 global Integer  FailureNumber = 0;
 global Integer  totalNumber = 0; 
 
 
 
 private final Id jobId;
 private final Datetime lastRunTime;
 private final String country;


	public VEEVA_BATCH_ONEKEY_BESTOFFICETIMES()   
    {
    	//this.lastRunTime = DateTime.newInstance(1970, 01, 01);
    }
    
    public VEEVA_BATCH_ONEKEY_BESTOFFICETIMES(String country)   
    {
	    this.lastRunTime = DateTime.newInstance(1970, 01, 01);
	    this.country = country;
    }

	public VEEVA_BATCH_ONEKEY_BESTOFFICETIMES(Id JobId,Datetime lastRunTime) 
    {
       this();
       this.jobId = JobId;
       this.lastRunTime = lastRunTime;
       //this.lastRunTime = DateTime.newInstance(1970, 01, 01);
       this.country = null; 
       
       System.Debug('CONSTRUCTOR BATCH VEEVA_BATCH_ONEKEY_BESTOFFICETIMES');  
    }
    
    public VEEVA_BATCH_ONEKEY_BESTOFFICETIMES(Id JobId,Datetime lastRunTime, String country)
	{
       this();
       this.jobId = JobId;
       this.lastRunTime = lastRunTime;
       //this.lastRunTime = DateTime.newInstance(1970, 01, 01);
       this.country = country;
       
       System.Debug('CONSTRUCTOR BATCH VEEVA_BATCH_ONEKEY_BESTOFFICETIMES with country');  
	}  
    /***************************************************************************************
            BATCH START  
    /***************************************************************************************/
    
    global Database.QueryLocator start(Database.BatchableContext BC){
     System.Debug('START BATCH VEEVA_BATCH_ONEKEY_BESTOFFICETIMES');
     
  	  String selStmt=' ';
      String sAddressStage = 'OK_STAGE_ADDRESS__c';
      String sAddressStageRel = 'OK_STAGE_ADDRESS__r';
      String sAddressRel = 'OK_STAGE_ADDRESS_INT__c';
      
      // Create base query
      //basic fields
      selStmt = 'SELECT Id, Individual_External_Id__c, OK_Stage_Activity__c.Stage_Workplace__c, ';
      //BOT fields
      selStmt += ' OK_Fr_1_Available__c, OK_Fr_1_Close__c, OK_Fr_1_Open__c, OK_Fr_2_Available__c, OK_Fr_2_Close__c, OK_Fr_2_Open__c, OK_Fr_3_Available__c, OK_Fr_3_Close__c, OK_Fr_3_Open__c, OK_Mo_1_Available__c, OK_Mo_1_Close__c, OK_Mo_1_Open__c, OK_Mo_2_Available__c, OK_Mo_2_Close__c, OK_Mo_2_Open__c, OK_Mo_3_Available__c, OK_Mo_3_Close__c, OK_Mo_3_Open__c, OK_Phone_Extension__c, OK_Sa_1_Available__c, OK_Sa_1_Close__c, OK_Sa_1_Open__c, OK_Sa_2_Available__c, OK_Sa_2_Close__c, OK_Sa_2_Open__c, OK_Sa_3_Available__c, OK_Sa_3_Close__c, OK_Sa_3_Open__c, OK_Su_1_Available__c, OK_Su_1_Close__c, OK_Su_1_Open__c, OK_Su_2_Available__c, OK_Su_2_Close__c, OK_Su_2_Open__c, OK_Su_3_Available__c, OK_Su_3_Close__c, OK_Su_3_Open__c, OK_Th_1_Available__c, OK_Th_1_Close__c, OK_Th_1_Open__c, OK_Th_2_Available__c, OK_Th_2_Close__c, OK_Th_2_Open__c, OK_Th_3_Available__c, OK_Th_3_Close__c, OK_Th_3_Open__c, OK_Tu_1_Available__c, OK_Tu_1_Close__c, OK_Tu_1_Open__c, OK_Tu_2_Available__c, OK_Tu_2_Close__c, OK_Tu_2_Open__c, OK_Tu_3_Available__c, OK_Tu_3_Close__c, OK_Tu_3_Open__c, OK_We_1_Available__c, OK_We_1_Close__c, OK_We_1_Open__c, OK_We_2_Available__c, OK_We_2_Close__c, OK_We_2_Open__c, OK_We_3_Available__c, OK_We_3_Close__c, OK_We_3_Open__c ';
      //suffix
      selStmt += ' FROM  OK_Stage_Activity__c WHERE LastModifiedDate >=' + lastRunTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.\'000Z\'') ;  
      
      if (country != null) {
		selStmt += ' AND (External_Id__c like \'W'
			+ country
			
			+ '%\')'
			;  
      }
      
      selStmt += ' AND (';
		selStmt += '  OK_Fr_1_Available__c = \'Y\' OR ';
		selStmt += '  OK_Fr_2_Available__c = \'Y\' OR ';
		selStmt += '  OK_Fr_3_Available__c = \'Y\' OR ';
		selStmt += '  OK_Mo_1_Available__c = \'Y\' OR ';
		selStmt += '  OK_Mo_2_Available__c = \'Y\' OR ';
		selStmt += '  OK_Mo_3_Available__c = \'Y\' OR ';
		selStmt += '  OK_Sa_1_Available__c = \'Y\' OR ';
		selStmt += '  OK_Sa_2_Available__c = \'Y\' OR ';
		selStmt += '  OK_Sa_3_Available__c = \'Y\' OR ';
		selStmt += '  OK_Su_1_Available__c = \'Y\' OR ';
		selStmt += '  OK_Su_2_Available__c = \'Y\' OR ';
		selStmt += '  OK_Su_3_Available__c = \'Y\' OR ';
		selStmt += '  OK_Th_1_Available__c = \'Y\' OR ';
		selStmt += '  OK_Th_2_Available__c = \'Y\' OR ';
		selStmt += '  OK_Th_3_Available__c = \'Y\' OR ';
		selStmt += '  OK_Tu_1_Available__c = \'Y\' OR ';
		selStmt += '  OK_Tu_2_Available__c = \'Y\' OR ';
		selStmt += '  OK_Tu_3_Available__c = \'Y\' OR ';
		selStmt += '  OK_We_1_Available__c = \'Y\' OR ';
		selStmt += '  OK_We_2_Available__c = \'Y\' OR ';
		selStmt += '  OK_We_3_Available__c = \'Y\' ';
     selStmt += ')';
      
      
      selStmt += ' Limit 50000000';
      
      System.Debug('SQLU: ' + selStmt);  //2012.02.25.
    
      return Database.getQueryLocator(selStmt); 
   }
    /***************************************************************************************
            BATCH EXECUTE  
    /***************************************************************************************/

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
       List<OK_STAGE_ADDRESS_INT__c> addrStageRecords = [Select OK_Stage_Workplace__c,
                                                                OK_Process_Code__c,
                                                                OK_End_Date__c,                
                                                                Primary__c,  Billing__c, Mailing__c, Business__c,
                                                                OK_STAGE_ADDRESS__r.External_ID_vod__c                       
                                                                from OK_STAGE_ADDRESS_INT__c 
                                                                where OK_Stage_Workplace__c in: StageWkpIds    
                                                                                                                            
                                                          ]; 
       
       
       //iterate  through  all ACTIVITY  records  since the last run
       for(OK_Stage_Activity__c actvStageRecord : activityStageRecords)
       {
            /******************************************************************************************************************
            	START BEST OFFICE TIME FORMAT CONVERSION
            /******************************************************************************************************************/
            List<string> s1o = new List<String>();
            List<string> s1c = new List<String>();
            List<string> s2o = new List<String>();
            List<string> s2c = new List<String>();
            List<string> s3o = new List<String>();
            List<string> s3c = new List<String>();
            
            //formatting
            String preMo = '&m=';
            String preTu = '&tu=';
            String preWe = '&w=';
            String preTh = '&th=';
            String preFr = '&f=';
            String preSa = '&sa=';
            String preSu = '&su=';
            
            //EG: &m=480,540&tu=360,495&w=525,630&th=1200,1260&f=1200,1260
            String bot = ''; //BestOfficeTime
            
            //Mo
            	Boolean botMo = false;
            	//S1
            	String MoS1o = '';
            	String MoS1c = '';
            	s1o = new List<String>();
            	s1c = new List<String>();
            	            	
            	if(actvStageRecord.OK_Mo_1_Available__c=='Y'){
            		//open   		
            		s1o = actvStageRecord.OK_Mo_1_Open__c.split(':');
                    MoS1o = string.valueof( (integer.valueOf(s1o[0])*60) + (integer.valueOf(s1o[1]))  );
                    //close
                    s1c = actvStageRecord.OK_Mo_1_Close__c.split(':');
                    MoS1c = string.valueof( (integer.valueOf(s1c[0])*60) + (integer.valueOf(s1c[1]))  );
                    //set bot
                    if(botMo == true){
                    	bot+=';';
                    }else{
                    	bot += preMo;
                    }
                    bot += MoS1o + ',' + MoS1c; 
                    botMo = true;
            	}
            	//S2
                String MoS2o = '';
            	String MoS2c = '';
            	s2o = new List<String>();
            	s2c = new List<String>();
            	
            	if(actvStageRecord.OK_Mo_2_Available__c=='Y'){
            		//open   		
            		s2o = actvStageRecord.OK_Mo_2_Open__c.split(':');
                    MoS2o = string.valueof( (integer.valueOf(s2o[0])*60) + (integer.valueOf(s2o[1]))  );
                    //close
                    s2c = actvStageRecord.OK_Mo_2_Close__c.split(':');
                    MoS2c = string.valueof( (integer.valueOf(s2c[0])*60) + (integer.valueOf(s2c[1]))  );
                    //set bot
                    if(botMo == true){
                    	bot+=';';
                    }else{
                    	bot += preMo;
                    }
                    bot += MoS2o + ',' + MoS2c; 
                    botMo = true;
            	}
            	//S3
                String MoS3o = '';
            	String MoS3c = '';
            	s3o = new List<String>();
            	s3c = new List<String>();
            	
            	if(actvStageRecord.OK_Tu_3_Available__c=='Y'){
            		//open   		
            		s3o = actvStageRecord.OK_Tu_3_Open__c.split(':');
                    MoS3o = string.valueof( (integer.valueOf(s3o[0])*60) + (integer.valueOf(s3o[1]))  );
                    //close
                    s3c = actvStageRecord.OK_Tu_3_Close__c.split(':');
                    MoS3c = string.valueof( (integer.valueOf(s3c[0])*60) + (integer.valueOf(s3c[1]))  );
                    //set bot
                    if(botMo == true){
                    	bot+=';';
                    }else{
                    	bot += preMo;
                    }
                    bot += MoS3o + ',' + MoS3c; 
                    botMo = true;
            	}
            //Tu
            	Boolean botTu = false;
            	//S1
            	String TuS1o = '';
            	String TuS1c = '';
            	s1o = new List<String>();
            	s1c = new List<String>();
            	            	
            	if(actvStageRecord.OK_Tu_1_Available__c=='Y'){
            		//open   		
            		s1o = actvStageRecord.OK_Tu_1_Open__c.split(':');
                    TuS1o = string.valueof( (integer.valueOf(s1o[0])*60) + (integer.valueOf(s1o[1]))  );
                    //close
                    s1c = actvStageRecord.OK_Tu_1_Close__c.split(':');
                    TuS1c = string.valueof( (integer.valueOf(s1c[0])*60) + (integer.valueOf(s1c[1]))  );
                    //set bot
                    if(botTu == true){
                    	bot+=';';
                    }else{
                    	bot += preTu;
                    }
                    bot += TuS1o + ',' + TuS1c; 
                    botTu = true;
            	}
            	//S2
                String TuS2o = '';
            	String TuS2c = '';
            	s2o = new List<String>();
            	s2c = new List<String>();
            	
            	if(actvStageRecord.OK_Tu_2_Available__c=='Y'){
            		//open   		
            		s2o = actvStageRecord.OK_Tu_2_Open__c.split(':');
                    TuS2o = string.valueof( (integer.valueOf(s2o[0])*60) + (integer.valueOf(s2o[1]))  );
                    //close
                    s2c = actvStageRecord.OK_Tu_2_Close__c.split(':');
                    TuS2c = string.valueof( (integer.valueOf(s2c[0])*60) + (integer.valueOf(s2c[1]))  );
                    //set bot
                    if(botTu == true){
                    	bot+=';';
                    }else{
                    	bot += preTu;
                    }
                    bot += TuS2o + ',' + TuS2c; 
                    botTu = true;
            	}
            	//S3
                String TuS3o = '';
            	String TuS3c = '';
            	s3o = new List<String>();
            	s3c = new List<String>();
            	
            	if(actvStageRecord.OK_Tu_3_Available__c=='Y'){
            		//open   		
            		s3o = actvStageRecord.OK_Tu_3_Open__c.split(':');
                    TuS3o = string.valueof( (integer.valueOf(s3o[0])*60) + (integer.valueOf(s3o[1]))  );
                    //close
                    s3c = actvStageRecord.OK_Tu_3_Close__c.split(':');
                    TuS3c = string.valueof( (integer.valueOf(s3c[0])*60) + (integer.valueOf(s3c[1]))  );
                    //set bot
                    if(botTu == true){
                    	bot+=';';
                    }else{
                    	bot += preTu;
                    }
                    bot += TuS3o + ',' + TuS3c; 
                    botTu = true;
            	}
            //We
            	Boolean botWe = false;
            	//S1
            	String WeS1o = '';
            	String WeS1c = '';
            	s1o = new List<String>();
            	s1c = new List<String>();
            	            	
            	if(actvStageRecord.OK_We_1_Available__c=='Y'){
            		//open   		
            		s1o = actvStageRecord.OK_We_1_Open__c.split(':');
                    WeS1o = string.valueof( (integer.valueOf(s1o[0])*60) + (integer.valueOf(s1o[1]))  );
                    //close
                    s1c = actvStageRecord.OK_We_1_Close__c.split(':');
                    WeS1c = string.valueof( (integer.valueOf(s1c[0])*60) + (integer.valueOf(s1c[1]))  );
                    //set bot
                    if(botWe == true){
                    	bot+=';';
                    }else{
                    	bot += preWe;
                    }
                    bot += WeS1o + ',' + WeS1c; 
                    botWe = true;
            	}
            	//S2
                String WeS2o = '';
            	String WeS2c = '';
            	s2o = new List<String>();
            	s2c = new List<String>();
            	
            	if(actvStageRecord.OK_We_2_Available__c=='Y'){
            		//open   		
            		s2o = actvStageRecord.OK_We_2_Open__c.split(':');
                    WeS2o = string.valueof( (integer.valueOf(s2o[0])*60) + (integer.valueOf(s2o[1]))  );
                    //close
                    s2c = actvStageRecord.OK_We_2_Close__c.split(':');
                    WeS2c = string.valueof( (integer.valueOf(s2c[0])*60) + (integer.valueOf(s2c[1]))  );
                    //set bot
                    if(botWe == true){
                    	bot+=';';
                    }else{
                    	bot += preWe;
                    }
                    bot += WeS2o + ',' + WeS2c; 
                    botWe = true;
            	}
            	//S3
                String WeS3o = '';
            	String WeS3c = '';
            	s3o = new List<String>();
            	s3c = new List<String>();
            	
            	if(actvStageRecord.OK_We_3_Available__c=='Y'){
            		//open   		
            		s3o = actvStageRecord.OK_We_3_Open__c.split(':');
                    WeS3o = string.valueof( (integer.valueOf(s3o[0])*60) + (integer.valueOf(s3o[1]))  );
                    //close
                    s3c = actvStageRecord.OK_We_3_Close__c.split(':');
                    WeS3c = string.valueof( (integer.valueOf(s3c[0])*60) + (integer.valueOf(s3c[1]))  );
                    //set bot
                    if(botWe == true){
                    	bot+=';';
                    }else{
                    	bot += preWe;
                    }
                    bot += WeS3o + ',' + WeS3c; 
                    botWe = true;
            	}
            //Th
            	Boolean botTh = false;
            	//S1
            	String ThS1o = '';
            	String ThS1c = '';
            	s1o = new List<String>();
            	s1c = new List<String>();
            	            	
            	if(actvStageRecord.OK_Th_1_Available__c=='Y'){
            		//open   		
            		s1o = actvStageRecord.OK_Th_1_Open__c.split(':');
                    ThS1o = string.valueof( (integer.valueOf(s1o[0])*60) + (integer.valueOf(s1o[1]))  );
                    //close
                    s1c = actvStageRecord.OK_Th_1_Close__c.split(':');
                    ThS1c = string.valueof( (integer.valueOf(s1c[0])*60) + (integer.valueOf(s1c[1]))  );
                    //set bot
                    if(botTh == true){
                    	bot+=';';
                    }else{
                    	bot += preTh;
                    }
                    bot += ThS1o + ',' + ThS1c; 
                    botTh = true;
            	}
            	//S2
                String ThS2o = '';
            	String ThS2c = '';
            	s2o = new List<String>();
            	s2c = new List<String>();
            	
            	if(actvStageRecord.OK_Th_2_Available__c=='Y'){
            		//open   		
            		s2o = actvStageRecord.OK_Th_2_Open__c.split(':');
                    ThS2o = string.valueof( (integer.valueOf(s2o[0])*60) + (integer.valueOf(s2o[1]))  );
                    //close
                    s2c = actvStageRecord.OK_Th_2_Close__c.split(':');
                    ThS2c = string.valueof( (integer.valueOf(s2c[0])*60) + (integer.valueOf(s2c[1]))  );
                    //set bot
                    if(botTh == true){
                    	bot+=';';
                    }else{
                    	bot += preTh;
                    }
                    bot += ThS2o + ',' + ThS2c; 
                    botTh = true;
            	}
            	//S3
                String ThS3o = '';
            	String ThS3c = '';
            	s3o = new List<String>();
            	s3c = new List<String>();
            	
            	if(actvStageRecord.OK_Th_3_Available__c=='Y'){
            		//open   		
            		s3o = actvStageRecord.OK_Th_3_Open__c.split(':');
                    ThS3o = string.valueof( (integer.valueOf(s3o[0])*60) + (integer.valueOf(s3o[1]))  );
                    //close
                    s3c = actvStageRecord.OK_Th_3_Close__c.split(':');
                    ThS3c = string.valueof( (integer.valueOf(s3c[0])*60) + (integer.valueOf(s3c[1]))  );
                    //set bot
                    if(botTh == true){
                    	bot+=';';
                    }else{
                    	bot += preTh;
                    }
                    bot += ThS3o + ',' + ThS3c; 
                    botTh = true;
            	}
            //Fr
            	Boolean botFr = false;
            	//S1
            	String FrS1o = '';
            	String FrS1c = '';
            	s1o = new List<String>();
            	s1c = new List<String>();
            	            	
            	if(actvStageRecord.OK_Fr_1_Available__c=='Y'){
            		//open   		
            		s1o = actvStageRecord.OK_Fr_1_Open__c.split(':');
                    FrS1o = string.valueof( (integer.valueOf(s1o[0])*60) + (integer.valueOf(s1o[1]))  );
                    //close
                    s1c = actvStageRecord.OK_Fr_1_Close__c.split(':');
                    FrS1c = string.valueof( (integer.valueOf(s1c[0])*60) + (integer.valueOf(s1c[1]))  );
                    //set bot
                    if(botFr == true){
                    	bot+=';';
                    }else{
                    	bot += preFr;
                    }
                    bot += FrS1o + ',' + FrS1c; 
                    botFr = true;
            	}
            	//S2
                String FrS2o = '';
            	String FrS2c = '';
            	s2o = new List<String>();
            	s2c = new List<String>();
            	
            	if(actvStageRecord.OK_Fr_2_Available__c=='Y'){
            		//open   		
            		s2o = actvStageRecord.OK_Fr_2_Open__c.split(':');
                    FrS2o = string.valueof( (integer.valueOf(s2o[0])*60) + (integer.valueOf(s2o[1]))  );
                    //close
                    s2c = actvStageRecord.OK_Fr_2_Close__c.split(':');
                    FrS2c = string.valueof( (integer.valueOf(s2c[0])*60) + (integer.valueOf(s2c[1]))  );
                    //set bot
                    if(botFr == true){
                    	bot+=';';
                    }else{
                    	bot += preFr;
                    }
                    bot += FrS2o + ',' + FrS2c; 
                    botFr = true;
            	}
            	//S3
                String FrS3o = '';
            	String FrS3c = '';
            	s3o = new List<String>();
            	s3c = new List<String>();
            	
            	if(actvStageRecord.OK_Fr_3_Available__c=='Y'){
            		//open   		
            		s3o = actvStageRecord.OK_Fr_3_Open__c.split(':');
                    FrS3o = string.valueof( (integer.valueOf(s3o[0])*60) + (integer.valueOf(s3o[1]))  );
                    //close
                    s3c = actvStageRecord.OK_Fr_3_Close__c.split(':');
                    FrS3c = string.valueof( (integer.valueOf(s3c[0])*60) + (integer.valueOf(s3c[1]))  );
                    //set bot
                    if(botFr == true){
                    	bot+=';';
                    }else{
                    	bot += preFr;
                    }
                    bot += FrS3o + ',' + FrS3c; 
                    botFr = true;
            	}
            //Sa
            	Boolean botSa = false;
            	//S1
            	String SaS1o = '';
            	String SaS1c = '';
            	s1o = new List<String>();
            	s1c = new List<String>();
            	            	
            	if(actvStageRecord.OK_Sa_1_Available__c=='Y'){
            		//open   		
            		s1o = actvStageRecord.OK_Sa_1_Open__c.split(':');
                    SaS1o = string.valueof( (integer.valueOf(s1o[0])*60) + (integer.valueOf(s1o[1]))  );
                    //close
                    s1c = actvStageRecord.OK_Sa_1_Close__c.split(':');
                    SaS1c = string.valueof( (integer.valueOf(s1c[0])*60) + (integer.valueOf(s1c[1]))  );
                    //set bot
                    if(botSa == true){
                    	bot+=';';
                    }else{
                    	bot += preSa;
                    }
                    bot += SaS1o + ',' + SaS1c; 
                    botSa = true;
            	}
            	//S2
                String SaS2o = '';
            	String SaS2c = '';
            	s2o = new List<String>();
            	s2c = new List<String>();
            	
            	if(actvStageRecord.OK_Sa_2_Available__c=='Y'){
            		//open   		
            		s2o = actvStageRecord.OK_Sa_2_Open__c.split(':');
                    SaS2o = string.valueof( (integer.valueOf(s2o[0])*60) + (integer.valueOf(s2o[1]))  );
                    //close
                    s2c = actvStageRecord.OK_Sa_2_Close__c.split(':');
                    SaS2c = string.valueof( (integer.valueOf(s2c[0])*60) + (integer.valueOf(s2c[1]))  );
                    //set bot
                    if(botSa == true){
                    	bot+=';';
                    }else{
                    	bot += preSa;
                    }
                    bot += SaS2o + ',' + SaS2c; 
                    botSa = true;
            	}
            	//S3
                String SaS3o = '';
            	String SaS3c = '';
            	s3o = new List<String>();
            	s3c = new List<String>();
            	
            	if(actvStageRecord.OK_Sa_3_Available__c=='Y'){
            		//open   		
            		s3o = actvStageRecord.OK_Sa_3_Open__c.split(':');
                    SaS3o = string.valueof( (integer.valueOf(s3o[0])*60) + (integer.valueOf(s3o[1]))  );
                    //close
                    s3c = actvStageRecord.OK_Sa_3_Close__c.split(':');
                    SaS3c = string.valueof( (integer.valueOf(s3c[0])*60) + (integer.valueOf(s3c[1]))  );
                    //set bot
                    if(botSa == true){
                    	bot+=';';
                    }else{
                    	bot += preSa;
                    }
                    bot += SaS3o + ',' + SaS3c; 
                    botSa = true;
            	}            
            //Su
            	Boolean botSu = false;
            	//S1
            	String SuS1o = '';
            	String SuS1c = '';
            	s1o = new List<String>();
            	s1c = new List<String>();
            	            	
            	if(actvStageRecord.OK_Su_1_Available__c=='Y'){
            		//open   		
            		s1o = actvStageRecord.OK_Su_1_Open__c.split(':');
                    SuS1o = string.valueof( (integer.valueOf(s1o[0])*60) + (integer.valueOf(s1o[1]))  );
                    //close
                    s1c = actvStageRecord.OK_Su_1_Close__c.split(':');
                    SuS1c = string.valueof( (integer.valueOf(s1c[0])*60) + (integer.valueOf(s1c[1]))  );
                    //set bot
                    if(botSu == true){
                    	bot+=';';
                    }else{
                    	bot += preSu;
                    }
                    bot += SuS1o + ',' + SuS1c; 
                    botSu = true;
            	}
            	//S2
                String SuS2o = '';
            	String SuS2c = '';
            	s2o = new List<String>();
            	s2c = new List<String>();
            	
            	if(actvStageRecord.OK_Su_2_Available__c=='Y'){
            		//open   		
            		s2o = actvStageRecord.OK_Su_2_Open__c.split(':');
                    SuS2o = string.valueof( (integer.valueOf(s2o[0])*60) + (integer.valueOf(s2o[1]))  );
                    //close
                    s2c = actvStageRecord.OK_Su_2_Close__c.split(':');
                    SuS2c = string.valueof( (integer.valueOf(s2c[0])*60) + (integer.valueOf(s2c[1]))  );
                    //set bot
                    if(botSu == true){
                    	bot+=';';
                    }else{
                    	bot += preSu;
                    }
                    bot += SuS2o + ',' + SuS2c; 
                    botSu = true;
            	}
            	//S3
                String SuS3o = '';
            	String SuS3c = '';
            	s3o = new List<String>();
            	s3c = new List<String>();
            	
            	if(actvStageRecord.OK_Su_3_Available__c=='Y'){
            		//open   		
            		s3o = actvStageRecord.OK_Su_3_Open__c.split(':');
                    SuS3o = string.valueof( (integer.valueOf(s3o[0])*60) + (integer.valueOf(s3o[1]))  );
                    //close
                    s3c = actvStageRecord.OK_Su_3_Close__c.split(':');
                    SuS3c = string.valueof( (integer.valueOf(s3c[0])*60) + (integer.valueOf(s3c[1]))  );
                    //set bot
                    if(botSu == true){
                    	bot+=';';
                    }else{
                    	bot += preSu;
                    }
                    bot += SuS3o + ',' + SuS3c; 
                    botSu = true;
            	}
            	
        	//check results
        	System.debug('BOT for ACT(' + actvStageRecord.Id + '): ' + bot );
            //TODO: Add error if longer than 400 chars
           
            /******************************************************************************************************************
            	END BEST OFFICE TIME FORMAT CONVERSION
            /******************************************************************************************************************/
            
            
             //if ACT loaded correctly proceed
            if(actvStageRecord.Individual_External_Id__c != null)
            {
                  //Go throught all the ADDR-WKP relations               
                  for(OK_STAGE_ADDRESS_INT__c aStageAddressRel : addrStageRecords)
                  {
                    	
                    	//IF it's for the WKP in the current ACT then proceed to address level
                       if(aStageAddressRel.OK_Stage_Workplace__c ==  actvStageRecord.Stage_Workplace__c)
                       {
                       //Addresses level
                       	
                 		totalNumber = totalNumber + 1;
                 		       
                 		Address_vod__c address = new Address_vod__c();
                 		
                 		address = new Address_vod__c(
						   							 Best_Times_vod__c = bot, //ADD BESTOFICCETIME
						   							 //External_ID_vod__c = aStageAddressRel.OK_STAGE_ADDRESS__r.External_ID_vod__c //use this when inserting to stg_address
						   							 OK_External_ID_BI__c = aStageAddressRel.OK_STAGE_ADDRESS__r.External_ID_vod__c + actvStageRecord.Individual_External_Id__c
                                                     ); 
                 		                       
                       mapAddress.put(aStageAddressRel.OK_STAGE_ADDRESS__r.External_ID_vod__c,address);
                      
                       system.Debug('NEW ADDRESS: Id = ' + address.Id + ', OK_External_ID_BI__c = ' + address.OK_External_ID_BI__c + ', Best_Times_vod__c size: ' + address.Best_Times_vod__c.length()); 
					   System.debug('Map size = ' + mapAddress.size());
					   
                              //I guess just to avoid to many upsertable addresses
                             if(mapAddress.size() > 9000)
                             {
                                //Loop Through to pull address
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
                 
                  for(Address_vod__c myaddress:mapAddress.values())
                  {
                             addressRecs.add(myaddress);
                  }   
                 
                 UpserResults(addressRecs);         
        }        
   }
   /************************************************************
  	STATEFUL UPSERT 
   *************************************************************/
   
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
    /***************************************************************************************
            BATCH FINISH  
    /***************************************************************************************/  
   
   global void finish(Database.BatchableContext BC)
   {
        System.Debug('FINISH BATCH VEEVA_BATCH_ONEKEY_BESTOFFICETIMES');  
        VEEVA_BATCH_ONEKEY_BATCHUTILS.setErrorMessage(jobId, 'TotalBatchSize =' + this.totalNumber + ' Success Upsert = ' + this.SuccessNumber + ' Failed Upsert = ' + this.FailureNumber);    
         setCompleted(jobId,lastRunTime);
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


}