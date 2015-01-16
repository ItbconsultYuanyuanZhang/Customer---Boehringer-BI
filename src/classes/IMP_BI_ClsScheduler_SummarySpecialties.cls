/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Scheduler class to Sum up the number of specialties based on the account records
*  @author:         Jefferson Escobar
*  @created:        17-Jul-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			30 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         17-Jul-2014                 jescobar                 	Construction of the class.
*/ 

global class IMP_BI_ClsScheduler_SummarySpecialties implements Schedulable{
	
	global void execute(SchedulableContext sc) { 
		//Execute batch apex batch class
		runBatch();
	}
	
	void runBatch(){
		Map<String,IMP_BI_Specialty_Field_Setting__c> fieldSettingSP = IMP_BI_Specialty_Field_Setting__c.getAll();
		String query;
		String fieldSpecialty;
		
		if(fieldSettingSP!=null && !fieldSettingSP.isEmpty()){
			//Build query
			fieldSpecialty = fieldSettingSP.values().get(0).Name; 
			query = 'Select Id,'+fieldSpecialty+' From Account where '+fieldSpecialty+' <> null' ;
			
			if(!test.isRunningTest()){
				Database.executeBatch(new IMP_BI_ClsBatch_SummarySpecialties(query,fieldSpecialty)); 
			} 
		}
	} 
}