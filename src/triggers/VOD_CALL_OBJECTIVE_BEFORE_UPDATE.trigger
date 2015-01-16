/******************************************************************************
 *                                                                              
 *               Confidentiality Information:
 *
 * This module is the confidential and proprietary information of
 *  Veeva Systems, Inc.; it is not to be copied, reproduced, or transmitted
 * in any form, by any means, in whole or in part, nor is it to be used
 * for any purpose other than that for which it is expressly provided
 * without the written permission of  Veeva Systems, Inc.
 * 
 * Copyright (c) 2010 Veeva Systems, Inc.  All Rights Reserved.
 *
 *******************************************************************************/
trigger VOD_CALL_OBJECTIVE_BEFORE_UPDATE on Call_Objective_vod__c (before update) {
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if(Trigger.new[i].Recurring_vod__c != Trigger.old[i].Recurring_vod__c && Trigger.new[i].Parent_Objective_vod__c == null){
            boolean updRecurringToTrue = Trigger.new[i].Recurring_vod__c && !Trigger.old[i].Recurring_vod__c;  
            boolean updRecurringToFalse = !Trigger.new[i].Recurring_vod__c && Trigger.old[i].Recurring_vod__c;  
            boolean hasCallAssociated = (Trigger.new[i].Call2_vod__c != null); 
            boolean isCompleted = Trigger.new[i].Completed_Flag_vod__c;
            List<Call_Objective_vod__c> cObjs = [select Id, Business_Event_Target_vod__c,Date_vod__c
                                                  from Call_Objective_vod__c
                                                  where Parent_Objective_vod__c = :Trigger.new[i].Id];
            
            boolean hasChild = (cObjs != null && cObjs.size()>0);
            
            if (hasChild && updRecurringToFalse){
                Trigger.new[i].addError(VOD_GET_ERROR_MSG.getErrorMsg('CANNOT_CHANGE_RECURRING', 'CallObjectives'));
                return;
            }
            if (updRecurringToTrue && (hasCallAssociated || isCompleted) ){
                Trigger.new[i].addError(VOD_GET_ERROR_MSG.getErrorMsg('CANNOT_CHANGE_RECURRING', 'CallObjectives'));
                return;
            }    
        } 
    }
}