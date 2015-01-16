trigger Event_Attendee_Before_Delete on Event_Attendee_vod__c (before delete) {
    
    VOD_ERROR_MSG_BUNDLE bnd = new VOD_ERROR_MSG_BUNDLE ();
    
    for (Event_Attendee_vod__c attendee : Trigger.old) {
        if (attendee.Signature_Datetime_vod__c != null){
            attendee.addError(System.Label.NO_DEL_SIGNED_ATTENDEE, false);
            return;
        }
    }
}