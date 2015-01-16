trigger VEEVA_Samples_State_Settings_vod on Samples_State_Settings_vod__c (before update, before insert) {
    for (Samples_State_Settings_vod__c sss : Trigger.new) {
        sss.External_ID_vod__c = sss.Name;
    }

}