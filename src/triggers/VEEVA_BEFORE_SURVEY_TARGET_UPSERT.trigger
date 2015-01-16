trigger VEEVA_BEFORE_SURVEY_TARGET_UPSERT on Survey_Target_vod__c (before insert, before update) {
    Set<Id> surveyIds = VEEVA_SURVEY_UTILS.getSurveyIds(Trigger.new);
    List<Survey_vod__c> surveyList = [SELECT Id, Segment_vod__c FROM Survey_vod__c WHERE Id IN :surveyIds];
    Map<Id, Survey_vod__c> surveyMap = VEEVA_SURVEY_UTILS.createIdToSurveyMap(surveyList);
    Map<Id, List<VEEVA_SURVEY_UTILS.Segment>> surveyIdToSegmentsMap = VEEVA_SURVEY_UTILS.createSurveyIdToSegmentsMap(surveyMap);

    Map<Survey_Target_vod__c, Id> targetToAccountIdMap = new Map<Survey_Target_vod__c, Id>();
    for(Survey_Target_vod__c target : Trigger.new) {
        // Create a map of Survey Target to Account Id for filling out Account_Display_Name_vod__c
        if(target.Account_vod__c != null) {
            targetToAccountIdMap.put(target, target.Account_vod__c);
        }

        // Assign Segment
        target.Segment_vod__c = null;
        if(target.Status_vod__c == 'Submitted_vod' || target.Status_vod__c == 'Late_Submission_vod') {
            List<VEEVA_SURVEY_UTILS.Segment> segments = surveyIdToSegmentsMap.get(target.Survey_vod__c);
            if(segments != null && !segments.isEmpty() && target.Score_vod__c != null) {
                for(VEEVA_SURVEY_UTILS.Segment segment : segments) {
                    if(segment.containsScore(target.Score_vod__c)) {
                        target.Segment_vod__c = segment.getName();
                        break;
                    }
                }
            }
        }

        // Logic for deciding between Submitted_vod and Late_Submission_vod statuses
        if('Submitted_vod'.equals(target.Status_vod__c) || 'Late_Submission_vod'.equals(target.Status_vod__c)) {
            Survey_Target_vod__c oldTarget = null;
            if(trigger.oldMap != null) {
                oldTarget = trigger.oldMap.get(target.Id);
            }
            if(oldTarget == null || !('Submitted_vod'.equals(oldTarget.Status_vod__c) || 'Late_Submission_vod'.equals(oldTarget.Status_vod__c))) {
                if(target.End_Date_vod__c < Date.TODAY()) {
                    target.Status_vod__c = 'Late_Submission_vod';
                } else {
                    target.Status_vod__c = 'Submitted_vod';
                }
            }
        }
    }

    Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Formatted_Name_vod__c FROM Account WHERE Id IN :targetToAccountIdMap.values()]);
    for(Survey_Target_vod__c target : targetToAccountIdMap.keySet()) {
        target.Account_Display_Name_vod__c = accounts.get(target.Account_vod__c).Formatted_Name_vod__c;
    }
}