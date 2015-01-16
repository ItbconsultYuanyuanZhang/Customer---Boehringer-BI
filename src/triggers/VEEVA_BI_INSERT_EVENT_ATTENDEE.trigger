/**
 * VEEVA_BI_INSERT_EVENT_ATTENDEE
 * When an event team member is added, deleted or modified on a medical event, that member is also added, deleted or modified on the attendees list.
 * 
 * Caveat: If a team member is changed (i.e. different user) then the replacement team member in the attendees list will have a staus reset to 'Planned'.
 *
 * Author: Raphael Krausz <raphael.krausz@veevasystems.com>
 * Date:   2013-03-14
 *
 */

trigger VEEVA_BI_INSERT_EVENT_ATTENDEE on Event_Team_Member_BI__c (after insert, after delete, after update) {

    List<Event_Team_Member_BI__c> toInsert;
    List<Event_Team_Member_BI__c> toDelete;

    if (Trigger.isInsert) toInsert = Trigger.new;
    if (Trigger.isDelete) toDelete = Trigger.old;
    if (Trigger.isUpdate) {
        toInsert = new List<Event_Team_Member_BI__c>();
        toDelete = new List<Event_Team_Member_BI__c>();
        for (Integer i = 0; i < Trigger.old.size(); i++) {
            if (Trigger.old[i].User_BI__c != Trigger.new[i].User_BI__c) {
                toInsert.add(Trigger.new[i]);
                toDelete.add(Trigger.old[i]);
            }
        }
    }
    

    if (Trigger.isInsert || (Trigger.isUpdate && toInsert.size() > 0)) {
        List<Event_Attendee_vod__c> attendees = new List<Event_Attendee_vod__c>();
        for (Event_Team_Member_BI__c member : toInsert) {
            Event_Attendee_vod__c attendee = new Event_Attendee_vod__c();
            attendee.Medical_Event_vod__c = member.Event_Management_BI__c;
            attendee.User_vod__c = member.User_BI__c;
            attendee.Status_vod__c = 'Planned';
            attendees.add(attendee);
        }
        insert attendees;
    }
    
    if (Trigger.isDelete || (Trigger.isUpdate && toDelete.size() > 0)) {
        // Attendee is identified by Medical_Event_vod__c and User_vod__c
        String SqlString = 'SELECT Id FROM Event_Attendee_vod__c';
        Boolean started = false;
        for (Event_Team_Member_BI__c member : toDelete) {
            SqlString += (started) ? ' OR ' : ' WHERE ';
            started = true;
            SqlString += '(Medical_Event_vod__c = \''
                + member.Event_Management_BI__c
                + '\' AND User_vod__c = \''
                + member.User_BI__c
                + '\')'
                ;
        }
        List<Event_Attendee_vod__c> attendees = Database.query(SqlString);
        delete attendees;       
    }
}