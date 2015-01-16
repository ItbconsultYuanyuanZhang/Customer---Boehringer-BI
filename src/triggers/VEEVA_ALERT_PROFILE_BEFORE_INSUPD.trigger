trigger VEEVA_ALERT_PROFILE_BEFORE_INSUPD on Alert_Profile_vod__c (before insert, before update) {
    for (Alert_Profile_vod__c ap : Trigger.new) {
        ap.External_Id_vod__c = ap.Alert_vod__c + '__' + ap.Profile_vod__c;
    }
}