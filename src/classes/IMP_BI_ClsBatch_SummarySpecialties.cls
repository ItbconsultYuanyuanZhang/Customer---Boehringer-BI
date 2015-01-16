/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Sum up the number of specialties based on the account records
*  @author:         Jefferson Escobar
*  @created:        16-Jul-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			30.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         30-Jul-2014                 jescobar                 	Construction of the class.
*/ 
global class IMP_BI_ClsBatch_SummarySpecialties implements Database.Batchable<SObject>, Database.Stateful{
	
	global Map<Id,Integer> specialtyAccounts = new Map<Id,Integer>();
	
	/** final variables */
	global final String fieldSpecialty;
	global final String query;
	global final Set<Id> specialties;
	
	
	global IMP_BI_ClsBatch_SummarySpecialties(String q,String fieldSpecialty){
		specialties = new Set<Id>();
		for(Customer_Attribute_BI__c c : [Select Id From Customer_Attribute_BI__c where Country_BI__c != null]){
			specialties.add(c.Id);
		}
		this.query=q+' And '+fieldSpecialty+' in :specialties';
		this.fieldSpecialty=fieldSpecialty;
		system.debug(':: Query: '+ query);
	}
	
	
	/**
	* Retrieve the accounts with values for specialties from Customer Attribute
	*
	* @param BC batchable context
	* @return
	*
	* @changelog
	* 16-Jul-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
	}
	
	/**
	* Execute calculation of specialties based on account records
	*
	* @param BC batchable context
	* @param accounts list of account to sum up for each specialty
	* @return
	*
	* @changelog
	* 16-Jul-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	global void execute(Database.BatchableContext BC, List<Account> accounts){
		for(Account acc : accounts){
			Id key = (Id) acc.get(fieldSpecialty);system.debug(':: Id Cust: ' + key);
			if(specialtyAccounts.containsKey(key)){
				specialtyAccounts.put(key,specialtyAccounts.get(key) + 1);
			}else{
				specialtyAccounts.put(key,1);
			}
		}
	}
	
	/**
	* Updating values for specialties
	*
	* @return
	*
	* @changelog
	* 16-Jul-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/ 	
	global void synchronizedSpecialties(){
		Savepoint sp = Database.setSavepoint();
		try{
			if(specialtyAccounts != null && !specialtyAccounts.isEmpty()){
				system.debug(':: Specialty Accounts: ' + specialtyAccounts);
				List<Customer_Attribute_BI__c> specialties = [Select Id,Name From Customer_Attribute_BI__c where Id = :specialties]; 
				for(Customer_Attribute_BI__c cab : specialties){
					cab.Summary_Specialties_Account_Number_BI__c = specialtyAccounts.get(cab.Id); 
			    }
			    //Update values on specialty records
			    update specialties;	
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