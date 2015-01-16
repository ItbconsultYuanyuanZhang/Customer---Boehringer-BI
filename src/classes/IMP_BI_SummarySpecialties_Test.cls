/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Test for IMP_BI_ClsBatch_SummarySpecialties and IMP_BI_ClsScheduler_SummarySpecialties classes
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
private class IMP_BI_SummarySpecialties_Test {

    static testMethod void testSpecialtiesJob() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	c.Country_Code_BI__c = 'Z0';
    	insert c;
    	
    	Customer_Attribute_BI__c cab = new Customer_Attribute_BI__c(Name='Specialty_Test',Country_BI__c = c.Id);
    	insert cab; 
    	
    	Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        acc.Specialty_BI__c = cab.Id;
        insert acc;
    	
    	IMP_BI_Specialty_Field_Setting__c specialtyConfig = new IMP_BI_Specialty_Field_Setting__c(Name='Specialty_BI__c');
    	insert specialtyConfig;
        
        Test.startTest();

      	// Schedule the test job
      	String jobId = System.schedule('Manage specialties',
      	'0 0 0 3 9 ? 2050', 
        new IMP_BI_ClsScheduler_SummarySpecialties());

      	// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
        NextFireTime
        FROM CronTrigger WHERE id = :jobId];

      	// Verify the job has not run
      	System.assertEquals(0, ct.TimesTriggered);
   		Test.stopTest();
    }
    
    static testMethod void testSpecialtiesBatch() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	c.Country_Code_BI__c = 'Z0';
    	insert c;
    	
    	Customer_Attribute_BI__c cab = new Customer_Attribute_BI__c(Name='Specialty_Test',Country_BI__c = c.Id);
    	insert cab; 
    	
    	Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        acc.Specialty_BI__c = cab.Id;
        insert acc;
    	
    	IMP_BI_Specialty_Field_Setting__c specialtyConfig = new IMP_BI_Specialty_Field_Setting__c(Name='Specialty_BI__c');
    	insert specialtyConfig;
        
        Test.startTest();
        
        //Run Batch
		Map<String,IMP_BI_Specialty_Field_Setting__c> fieldSettingSP = IMP_BI_Specialty_Field_Setting__c.getAll();
		String query;
		String fieldSpecialty;
		
		if(fieldSettingSP!=null && !fieldSettingSP.isEmpty()){
		    //Build query
		    fieldSpecialty = fieldSettingSP.values().get(0).Name; 
		    query = 'Select Id,'+fieldSpecialty+' From Account where '+fieldSpecialty+' <> null ' ;
		}
        //Run batch apex class
		Database.executebatch(new IMP_BI_ClsBatch_SummarySpecialties(query,  fieldSpecialty));
			      	
   		Test.stopTest();
    
    }
}