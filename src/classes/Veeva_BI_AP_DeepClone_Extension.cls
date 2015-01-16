public with sharing class Veeva_BI_AP_DeepClone_Extension {
	//added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
     // add the instance for the variables being passed by id on the url
    private Account_Plan_vod__c ap {get;set;}
    // set the id of the record that is created 
    public ID newRecordId {get;set;}
 
    // initialize the controller
    public Veeva_BI_AP_DeepClone_Extension(ApexPages.StandardController controller) {
 
        //initialize the stanrdard controller
        this.controller = controller;
        // load the current record
        ap = (Account_Plan_vod__c)controller.getRecord();
 
    }
 
    // method called from the VF's action attribute to clone the po
    public PageReference cloneWithItems() {
 
         // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();
         Account_Plan_vod__c newAP;
 		
 		//get all the fields
         try {
 			
			Map <String, Schema.SObjectField> Fields = Schema.getGlobalDescribe().get('Account_Plan_vod__c').getDescribe().fields.getMap();
 			system.debug('Fields size: ' + Fields.size());
	    	
	    	String query = 'SELECT ';
	    	
	    	for(Schema.SObjectField sfield : Fields.Values()){
	    		String Fname = sfield.getDescribe().getName();
	    		//EXCLUDE FIELDS HERE YOU DONT WANT CLONED
				if(Fname == 'CreatedById' ||
					Fname == 'CreatedDate' ||
					Fname == 'CurrencyIsoCode' ||
					Fname == 'IsDeleted' ||
					Fname == 'IsLocked' ||
					Fname == 'LastModifiedById' ||
					Fname == 'LastModifiedDate' ||
					Fname == 'SetupOwnerId' ||
					Fname == 'MayEdit' ||
					//Fname == 'Name' ||
					Fname == 'Percent_Complete_vod__c' ||
					Fname == 'Mobile_ID_vod__c' ||
					Fname == 'Id' ||
					Fname == 'SystemModstamp') continue;
				
				query += Fname + ',';

	    	}
	    	//Remove last comma
	    	query = query.removeEnd(',');
	    	query += ' FROM Account_Plan_vod__c WHERE ID = \'' + ap.id + '\' LIMIT 1';
 			system.debug('Query: ' + query);
 			
 			//get the sObject		
 			ap = Database.query(query);
 			//Clone and insert the parent object
            newAP = ap.clone(false);
            insert newAP;
 
            // set the id of the new AP created for further use
            newRecordId = newAP.id;

            //get the fieldlists for them 
            List<String> childs = new List<String>();
            	//ADD THE OBJECTS YOU WANT TO HAVE CLONED HERE
	            childs.add('Outcome_BI__c');
	            childs.add('Drivers_BI__c');
	            childs.add('Barriers_BI__c');
	            childs.add('Critical_Success_Factors_BI__c');
	            childs.add('Additional_Resource_Needed_BI__c');
	            childs.add('Stakeholders_BI__c');

            List<sObject> objs =  new List<sObject>();
            List<sObject> temp =  new List<sObject>();
            
            for(String o : childs){
            	//sharing doesnt work on sobjects, have to check manually if current user can create it
            	if(Schema.getGlobalDescribe().get(o).getDescribe().isCreateable()==false) continue;
            	
            	Map <String, Schema.SObjectField> ChildFields = Schema.getGlobalDescribe().get(o).getDescribe().fields.getMap();
            	system.debug('ChildFields size: ' + ChildFields.size());
            	
            	query = 'SELECT ';
            	for(Schema.SObjectField sfield : ChildFields.Values()){
		    		String Fname = sfield.getDescribe().getName();
		    		//EXCLUDE FIELDS HERE YOU DONT WANT CLONED FROM CHILD OBJECTS
					if(Fname == 'CreatedById' ||
						Fname == 'CreatedDate' ||
						Fname == 'CurrencyIsoCode' ||
						Fname == 'IsDeleted' ||
						Fname == 'IsLocked' ||
						Fname == 'LastModifiedById' ||
						Fname == 'LastModifiedDate' ||
						Fname == 'SetupOwnerId' ||
						Fname == 'MayEdit' ||
						Fname == 'Mobile_ID_vod__c' ||
						//Fname == 'Name' ||
						Fname == 'Id' ||
						Fname == 'SystemModstamp') continue;
					
					query += Fname + ',';
	    		}
	    		query = query.removeEnd(',');
		    	query += ' FROM '+ o + ' WHERE Account_Plan__c = \'' + ap.Id +'\'';
	 			system.debug('Query: ' + query);
	 			
	 			temp = Database.query(query);
	 			system.debug('Temp size: ' + temp.size() + ' for sOBject: ' + o);
	 			objs.addAll(temp);
	 			system.debug('objs size: ' + objs.size());
            }
            
            List<sObject> newObjs =  new List<sObject>();
            												
           	for(sObject so : objs){
           		sObject newSO = so.clone(false);
           		newSO.put('Account_Plan__c',newRecordId);
           		newObjs.add(newSO);
           	}
           	system.debug('newObjs size: ' + newObjs.size());
           	insert newObjs;
 			

         } catch (Exception e){
             // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }
 
        return new PageReference('/'+newAP.id+'/e?retURL=%2F'+newAP.id);
    }
}