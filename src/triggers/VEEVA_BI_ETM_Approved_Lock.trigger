trigger VEEVA_BI_ETM_Approved_Lock on Event_Team_Member_BI__c (before delete, before insert, before update) {
	//check for profile and possibly skip it all
	String profileName = [SELECT Id, Name FROM Profile WHERE Id = :Userinfo.getProfileId() LIMIT 1].Name;
	
	if(profileName.toUpperCase().contains('DATA')||
	   profileName.toUpperCase().contains('ADMIN')||
	   profileName.toUpperCase().contains('MARKETING')) return;
	
	//or do what you have to do
	map<Id, String> MEmap = new map<Id, String>();
	if(Trigger.isDelete||Trigger.isUpdate){
		for(Event_Team_Member_BI__c ETM : Trigger.old){
			MEmap.put(ETM.Event_Management_BI__c, '');
		}
	}else{
		for(Event_Team_Member_BI__c ETM : Trigger.new){
			MEmap.put(ETM.Event_Management_BI__c, '');
		}
	}
	
	
	for(Medical_Event_vod__c ME : [SELECT Id, Event_Status_BI__c FROM Medical_Event_vod__c WHERE Id in :MEmap.keySet()]){
		MEmap.put(ME.Id,Me.Event_Status_BI__c);
	}
	
	for (Integer i = 0; i < Trigger.size; i++) {
        if(Trigger.isInsert){
			if(MEmap.get(trigger.new[i].Event_Management_BI__c) == 'Approved'){
            	trigger.new[i].addError(System.Label.Medical_Event_Locked);
        	}
		}else{
			if(MEmap.get(trigger.old[i].Event_Management_BI__c) == 'Approved'){
            	trigger.old[i].addError(System.Label.Medical_Event_Locked);
        	}
		}
        
    }


}