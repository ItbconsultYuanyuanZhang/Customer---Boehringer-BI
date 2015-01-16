trigger VEEVA_BI_ME_APPROVED_LOCK on Medical_Event_vod__c (before update, before delete) {
    
    /*Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
    set<Id> MEs = new set<Id>();
    
    for (Integer i = 0; i < Trigger.size; i++) {
        if(trigger.isDelete==false && trigger.new[i].Event_Status_BI__c == 'Approved'){
            MEs.add(trigger.new[i].Id);
        }
    }
    
    for (Event_Team_Member_BI__c ETM : [SELECT id from Event_Team_Member_BI__c where Event_Management_BI__c in :MEs])
    {
        app.setObjectId(ETM.Id);
        Approval.ProcessResult result = Approval.process(app);
    }*/
    //check for profile and possibly skip it all
	String profileName = [SELECT Id, Name FROM Profile WHERE Id = :Userinfo.getProfileId() LIMIT 1].Name;
	System.debug('profile: '+profileName);
	if(profileName.toUpperCase().contains('DATA')||
	   profileName.toUpperCase().contains('ADMIN')||
	   profileName.toUpperCase().contains('MARKETING')){
	   	system.debug('returning');
		return;
	}
	//or do what you have to do 
    if(trigger.isUpdate||trigger.isDelete){
    	Map <String, Schema.SObjectField> Setting = Schema.getGlobalDescribe().get('Medical_Event_vod__c').getDescribe().fields.getMap();
    	
    	for (Integer i = 0; i < Trigger.size; i++) {
	        if(trigger.old[i].Event_Status_BI__c == 'Approved'){
	        	if(Trigger.isUpdate){
	        		if((trigger.old[i].Total_of_Attendees_BI__c == trigger.new[i].Total_of_Attendees_BI__c) &&
	        			(trigger.old[i].Total_of_Invitees_BI__c == trigger.new[i].Total_of_Invitees_BI__c)){
	        				for(Schema.SObjectField sfield : Setting.Values()){
	        					String fname = sfield.getDescribe().getName();
	        					//if(sfield.getDescribe().isPermissionable()) continue;
	        					if(sfield.getDescribe().isUpdateable()==false) continue;
	        					if(fname=='Completed_BI__c') continue;
	        					if(fname=='Event_Status_BI__c') continue;
	        					
	        					if(trigger.old[i].get(fname)!=trigger.new[i].get(fname)){
	        						system.debug('Adding error for: '+fname + ' details: '+sfield);
	        						trigger.new[i].addError( System.Label.Medical_Event_Locked );
	        					}
	        				}//end of field for	        				
	        			}
	        	}else{
	        		trigger.old[i].addError( System.Label.Medical_Event_Locked );
	        	}
	        	
	        }else if(trigger.old[i].Event_Status_BI__c == 'Completed / Closed'){
	        	if(Trigger.isUpdate) trigger.new[i].addError( System.Label.Medical_Event_Locked );
	        	else trigger.old[i].addError( System.Label.Medical_Event_Locked );
	        }
	    }
    }
	
    
}