/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Manage the espcialties for picklist specialties based on Especialty_VOD_field__c on Account objects
*  @author:         Jefferson Escobar
*  @created:        20-Feb-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			29.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         20-Feb-2014                 jescobar                 	Construction of the class.
*/ 
 
global class IMP_BI_ManageSpecialtiesUSA implements Database.Batchable<SObject>, Database.Stateful{
	global Map<String,Integer> specialtyAccounts = new Map<String,Integer>();
	global Map<String, Country_BI__c> mapCountries;
	global Map<String,Specialty_Grouping_BI__c> mapCurrentSpecialties;
	
	/** final variables */
	global final String query;
	global final Map<String,Specialty_Grouping_Config__c> mapSpecialtySetting;
	
	global IMP_BI_ManageSpecialtiesUSA(String q, Map<String,Specialty_Grouping_Config__c> mapSpecialtySetting){
		this.query = q;
		this.mapSpecialtySetting=mapSpecialtySetting;
		system.debug(':: Query: ' + q + ' SP Setting: ' + mapSpecialtySetting);
		
		mapCountries = new Map<String, Country_BI__c>();
		//Get countries for default
	    for(Country_BI__c c : [Select Id,Country_Code_BI__c From Country_BI__c where Country_Code_BI__c in :mapSpecialtySetting.keySet() ]){
	    	
	    	if(!mapCountries.containsKey(c.Country_Code_BI__c)){
	    		mapCountries.put(c.Country_Code_BI__c,c);		
	    	}
	    }
	    
	    //Get currently specialties to picklist specialties
	    mapCurrentSpecialties = new Map<String,Specialty_Grouping_BI__c>();
	    List<Specialty_Grouping_BI__c> currentSpecialties = [Select Id,Name,Country_Code_BI__c From Specialty_Grouping_BI__c];
	    
	    if(currentSpecialties != null&& !currentSpecialties.isEmpty()){
	    	for(Specialty_Grouping_BI__c spG : currentSpecialties){
	    		mapCurrentSpecialties.put(spG.Country_Code_BI__c+' - '+spG.Name,spG);
	    	} 
	    }
	}
	
	/**
	* Retrieve the accounts with values for specialties in 
	*
	* @param BC batchable context
	* @return
	*
	* @changelog
	* 15-Apr-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	
	/**
	* Execute insertion of specialties
	*
	* @param BC batchable context
	* @param accounts list of account to sum up for each specialty
	* @return
	*
	* @changelog
	* 15-Apr-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	global void execute(Database.BatchableContext BC, List<Account> accounts){
		for(Specialty_Grouping_Config__c spConfigu : mapSpecialtySetting.values()){
			for(Account acc : accounts){
				if(specialtyAccounts.containsKey(acc.Country_Code_BI__c+' - '+acc.get(spConfigu.Specialty_Field_Account__c))){
					specialtyAccounts.put(acc.Country_Code_BI__c+' - '+acc.get(spConfigu.Specialty_Field_Account__c),specialtyAccounts.get(acc.Country_Code_BI__c+' - '+acc.get(spConfigu.Specialty_Field_Account__c))+1);
				}else{
					specialtyAccounts.put(acc.Country_Code_BI__c+' - '+acc.get(spConfigu.Specialty_Field_Account__c),1);
				}
			}
		}
	}
	 
	
	/**
	* Creating group of especialties for picklist specialty cases
	*
	* @return
	*
	* @changelog
	* 20-Feb-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/ 	
	global void synchronizedSpecialties(){
		Savepoint sp = Database.setSavepoint();
		
		try{
			if(mapSpecialtySetting != null && !mapSpecialtySetting.isEmpty()){
				
				List<Specialty_Grouping_BI__c> spGroupsToInsert = new List<Specialty_Grouping_BI__c>();
				List<Specialty_Grouping_BI__c> spGroupsToUpdate = new List<Specialty_Grouping_BI__c>();
				
				system.debug(':: Specialty Accounts: ' + specialtyAccounts);
				
				for(Specialty_Grouping_Config__c spConfigu : mapSpecialtySetting.values()){
					
					//Get all the values for the fields related to specialties on Account object
		    		Schema.sObjectType sObjectType = Account.SObjectType;
					Schema.DescribeSObjectResult sObj = sObjectType.getDescribe();
					Schema.DescribeFieldResult fR = sObj.fields.getMap().get(spConfigu.Specialty_Field_Account__c).getDescribe();
					
					List<Schema.PicklistEntry> specialties =   fR.getPicklistValues();
						
						for(Schema.PicklistEntry specialty : specialties){
					        
					        if(mapCurrentSpecialties!=null&&mapCurrentSpecialties.containsKey(spConfigu.Name+' - '+specialty.getValue())){//if the specialty already exists in Specialty_Grouping__c
					        	Specialty_Grouping_BI__c spGroupU = mapCurrentSpecialties.get(spConfigu.Name+' - '+specialty.getValue());
					        	system.debug(':: Key SPG Update: ' + spConfigu.Name+' - '+spGroupU.Name);
					        	spGroupU.Summary_Specialties_Account_BI__c = specialtyAccounts.get(spConfigu.Name+' - '+spGroupU.Name);
					        	spGroupsToUpdate.add(spGroupU);
					        	continue;
					        }
					        
					        if(specialty.isActive()){
					           	Specialty_Grouping_BI__c spGroupIn = new Specialty_Grouping_BI__c();
					            spGroupIn.Name = specialty.getValue();
					        	spGroupIn.Country_BI__c = mapCountries.get(spConfigu.Name).Id;
					            spGroupIn.Country_Code_BI__c = mapCountries.get(spConfigu.Name).Country_Code_BI__c;
								system.debug(':: Key SPG Insert: ' + spConfigu.Name+' - '+spGroupIn.Name);					            
					            spGroupIn.Summary_Specialties_Account_BI__c = specialtyAccounts.get(spConfigu.Name+' - '+spGroupIn.Name);
					            spGroupsToInsert.add(spGroupIn);
					        }
					    }	
					}
					
					if(spGroupsToInsert!=null&&spGroupsToInsert.size()>0){
				        system.debug(':: # Specialies created: ' + spGroupsToInsert.size());
				        insert spGroupsToInsert;
				    }
				    
				    if(spGroupsToUpdate!=null&&spGroupsToUpdate.size()>0){
				        system.debug(':: # Specialies created: ' + spGroupsToUpdate.size());
				        update spGroupsToUpdate;
				    }
			}	
		}catch(Exception e){
		    Database.rollback(sp);
			system.debug('[ERROR] ' + e.getMessage());
		}
	}
	
	
	/**
	* Set information batch
	*
	* @param BC batchable context
	* @return
	*
	* @changelog
	* 15-Apr-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	global void finish(Database.BatchableContext BC){
		//Update Specialty quantities regarding to the account records
		synchronizedSpecialties();
	}
}