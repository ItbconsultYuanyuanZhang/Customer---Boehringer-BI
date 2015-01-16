/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Test for IMP_BI_ManageSpecialtiesUSA and IMP_BI_ClsScheduler_ManageSpecialtiesUSA classes
*  @author:         Jefferson Escobar
*  @created:        24-Feb-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			29.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         20-Feb-2014                 jescobar                 	Construction of the class.
*/ 
@isTest
private class IMP_BI_ManageSpecialtiesUSA_Test {

    static testMethod void testSpecialtiesUSAJob() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	c.Country_Code_BI__c = 'Z0';
    	insert c;
    	
    	Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        insert acc;
    	
    	Specialty_Grouping_BI__c sp = new Specialty_Grouping_BI__c(Name = 'T-Specialty', Country_BI__c = c.Id,Country_Code_BI__c = c.Country_Code_BI__c);
    	insert sp;
    	
    	Specialty_Grouping_Config__c specialtyConfig = new Specialty_Grouping_Config__c(Name = 'Z0', Specialty_Field_Account__c = 'Specialty_1_vod__c');
    	insert specialtyConfig;
        
        Test.startTest();

      	// Schedule the test job
      	String jobId = System.schedule('Manage specialties for USA',
      	'0 0 0 3 9 ? 2050', 
        new IMP_BI_ClsScheduler_ManageSpecialtiesUSA());

      	// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
        NextFireTime
        FROM CronTrigger WHERE id = :jobId];

      	// Verify the job has not run
      	System.assertEquals(0, ct.TimesTriggered);
   		Test.stopTest();
    }
    
    static testMethod void testSpecialtiesUSABatch() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	c.Country_Code_BI__c = 'Z0';
    	insert c;
    	
    	Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        acc.Country_Code_BI__c = 'Z0';
        acc.Specialty_1_vod__c = 'T-Specialty';
        insert acc;
    	
    	Specialty_Grouping_BI__c sp = new Specialty_Grouping_BI__c(Name = 'T-Specialty', Country_BI__c = c.Id,Country_Code_BI__c = c.Country_Code_BI__c);
    	insert sp;
    	
    	Specialty_Grouping_Config__c specialtyConfig = new Specialty_Grouping_Config__c(Name = 'Z0', Specialty_Field_Account__c = 'Specialty_1_vod__c');
    	insert specialtyConfig;
        
        Test.startTest();
        
        Map<String,Specialty_Grouping_Config__c> mapSpecialtySetting = Specialty_Grouping_Config__c.getAll();
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
		query='Select Id,Country_Code_BI__c,'+params+' From Account where  Country_Code_BI__c <> null And ('+paramConditionals+') limit 1';
		
		//Run batch apex class
		Database.executebatch(new IMP_BI_ManageSpecialtiesUSA(query,  mapSpecialtySetting));
			      	
   		Test.stopTest();
    
    }
}