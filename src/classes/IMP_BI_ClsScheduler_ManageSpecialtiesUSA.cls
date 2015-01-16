/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Scheduler class to manage the especialties for USA based on Especialty_1_VOD_field__c on Account object
*  @author:         Jefferson Escobar
*  @created:        20-Feb-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			29.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         20-Feb-2014                 jescobar                 	Construction of the class.
*/ 
 
global class IMP_BI_ClsScheduler_ManageSpecialtiesUSA implements Schedulable{
	
	global void execute(SchedulableContext sc) { 
		//Execute batch apex batch class
		runBatch();
	}
	
	void runBatch(){
		Map<String,Specialty_Grouping_Config__c> mapSpecialtySetting = Specialty_Grouping_Config__c.getAll();
		
		if(mapSpecialtySetting!=null && !mapSpecialtySetting.isEmpty()){
			
			//Build query
			String query = 'Select Id,Country_Code_BI__c,'; 
			String params='';
			String paramConditionals='';
		
			for(Specialty_Grouping_Config__c spConfigu : mapSpecialtySetting.values()){
				params+=spConfigu.Specialty_Field_Account__c+',';
				paramConditionals+=spConfigu.Specialty_Field_Account__c+' <> null or ';			
			}
			
			params=params.substring(0,params.length()-1);
			paramConditionals=paramConditionals.substring(0,paramConditionals.length()-3);
			query='Select Id,Country_Code_BI__c,'+params+' From Account where  Country_Code_BI__c <> null And ('+paramConditionals+')';
					    
		    //Run batch apex class
			if(!test.isRunningTest()){ 
		  		Database.executebatch(new IMP_BI_ManageSpecialtiesUSA(query,  mapSpecialtySetting));
			}
		}
	}
}