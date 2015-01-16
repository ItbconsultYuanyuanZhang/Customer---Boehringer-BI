trigger VEEVA_BI_ME_Approved_Lock_v2 on Medical_Event_vod__c (before delete, before update) {
    
    //check for profile and possibly skip it all
    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :Userinfo.getProfileId() LIMIT 1].Name;
    System.debug('profile: '+profileName);
    if(profileName.toUpperCase().contains('DATA')||
       profileName.toUpperCase().contains('ADMIN')||
       profileName.toUpperCase().contains('MARKETING')||
       profileName.toUpperCase().contains('HQ')){
        system.debug('returning');
        return;
    }
    //or do what you have to do 
    Map <String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Medical_Event_vod__c').getDescribe().fields.getMap();
    
    //get the custom setting values (all fields'), add them to a set
    Map <String, Schema.SObjectField> settingFields = Schema.getGlobalDescribe().get('Event_Management_Lock_Settings__c').getDescribe().fields.getMap();
    Event_Management_Lock_Settings__c EL = Event_Management_Lock_Settings__c.getInstance();
    set<String> excludedApprovedFields = new set<String>();
    set<String> excludedCompletedFields = new set<String>();
    
    for(Schema.SObjectField sfield : settingFields.Values()){
        String fname = sfield.getDescribe().getName();
        String settingValue;
        
        settingValue = string.valueOf(EL.get(fname));
        if(settingValue!=null){
            if(fname.contains('Approved')) excludedApprovedFields.addAll(settingValue.split(','));
            if(fname.contains('Completed')) excludedCompletedFields.addAll(settingValue.split(','));
        }
    }
    
    system.debug('excludedApprovedFields: '+excludedApprovedFields);
    system.debug('excludedCompletedFields: '+excludedCompletedFields);
    
    for (Integer i = 0; i < Trigger.size; i++) {
        if(trigger.old[i].Event_Status_BI__c == 'Approved'||trigger.old[i].Event_Status_BI__c == 'Completed / Closed'){
            if(Trigger.isUpdate){
                //go through all the fields, and match them
                for(Schema.SObjectField sfield : objectFields.Values()){
                    String fname = sfield.getDescribe().getName();
                    //exclude system fields
                    //if(sfield.getDescribe().isUpdateable()==false) continue;
                    //exclude fields defined in the settings
                    if((trigger.old[i].Event_Status_BI__c == 'Approved')&&excludedApprovedFields.contains(fname)) continue;                       
                    if(trigger.old[i].Event_Status_BI__c == 'Completed / Closed'&&excludedCompletedFields.contains(fname)) continue;   
                    
                    if(trigger.old[i].get(fname)!=trigger.new[i].get(fname)){
                        //throw error message
                        system.debug('Adding error for: '+fname + ' details: '+sfield);
                        trigger.new[i].addError( System.Label.Medical_Event_Locked );
                    }
                }
                
            }else{
                trigger.old[i].addError( System.Label.Medical_Event_Locked );
            }
        }
    }
    
}