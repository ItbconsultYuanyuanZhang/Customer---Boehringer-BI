/*
* Account_Detect_Knipper_Changes
* Author: Abha Gupta, J. Knipper
* Reviewed: Mark T. Boyer, Veeva Systems - Professional Services
* Date: 2013-04-01
* Summary:
*  This trigger is used to update the AccountModTime field when any of the specified fields are updated.
*  This trigger depends on a custom setting that contains the field list and record types.
*
* Updated by: 
* Date: 
* Summary: 
*/

trigger Account_Detect_Knipper_Changes on Account (before insert, before update) {
    
    //String RTDeveloperNameList = 'Professional_vod,KOL_vod,Staff';
    //String APIFieldNameList = 'FirstName,Middle_vod__c,LastName,ME__c,External_ID_vod__c,Specialty_1_vod__c,Credentials_vod__c,PersonEmail';
   
    Knipper_Settings__c ks = Knipper_Settings__c.getInstance();
    String RTDeveloperNameList = ks.Account_Detect_Changes_Record_Type_List__c;
    String APIFieldNameList = ks.Account_Detect_Change_FieldList__c;
    
    RTDeveloperNameList = '\'' + RTDeveloperNameList.replaceAll(',', '\',\'') + '\'';
    Set<id> ProfRT = new Set<Id>();
    String queryRT = 'SELECT Id FROM RecordType WHERE DeveloperName IN (' + RTDeveloperNameList + ') AND SobjectType = \'Account\' ';
    List<RecordType> RTList = Database.query(queryRT);
    for(RecordType r : RTList) {
        ProfRT.add(r.Id);
    }
 
    List<String> fieldList = APIFieldNameList.split(',', 0);
 
    for (Integer i=0; i < trigger.new.size(); i++) {
      if (trigger.new[i].Country_Code_BI__c == 'US') {
            if (ProfRT.contains(trigger.new[i].recordTypeId)) {
                if (Trigger.IsInsert) {
                    trigger.new[i].AccountModTime__c = system.now();
                }
                else {
                    for(String f : fieldList) {
                        if (trigger.old[i].get(f) != trigger.new[i].get(f)) {
                            trigger.new[i].AccountModTime__c = system.now();
                            continue;
                            }
                    }
                }
            }
        }
    }
}