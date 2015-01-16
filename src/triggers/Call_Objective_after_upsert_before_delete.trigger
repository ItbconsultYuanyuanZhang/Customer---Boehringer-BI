trigger Call_Objective_after_upsert_before_delete on Call_Objective_vod__c (after insert, after update, before delete) {
    if (VEEVA_CALL_OBJECTIVE_TRIG.invoked)
    {
        //It is coming from Business_Event_Target trigger
        return;
    }
    VEEVA_CALL_OBJECTIVE_TRIG.invoked = true;
    
    Map<Id, RecordType> recTypes = new Map<Id, RecordType>(
        [select Id, Name
         from RecordType
         where SobjectType in ('Business_Event_Target_vod__c', 'Call_Objective_vod__c')
         and Name in ('EPPV', 'PI')
         and IsActive=true]);
    
    List<Id> betIds = new List<Id>();
    Set<Id> deletedIds = new Set<Id>();
    boolean[] skip = new boolean[Trigger.size];
    for (Integer idx = 0; idx < Trigger.size; idx++)
    {
        skip[idx] = false;
        if (Trigger.isDelete)
        {
            if (!recTypes.containsKey(Trigger.old[idx].RecordTypeId))
            {
                skip[idx] = true;
                continue;
            }
            deletedIds.add(Trigger.old[idx].Id);
        }
        else if (!recTypes.containsKey(Trigger.new[idx].RecordTypeId))
        {
            skip[idx] = true;
            continue;
        }
        else
        {
            if (Trigger.new[idx].Business_Event_Target_vod__c == null ||
                Trigger.new[idx].Business_Event_vod__c == null ||
                Trigger.new[idx].Account_vod__c == null ||
                Trigger.new[idx].Date_vod__c == null)
            {
                Trigger.new[idx].addError((Trigger.new[idx].Name + ' [Business_Event_vod__c, Business_Event_Target_vod__c, Account_vod__c and Date_vod__c] ' + VOD_GET_ERROR_MSG.getErrorMsg('REQUIRED', 'Common')), false);
                return;
            }
        }
        betIds.add(Trigger.isDelete ? Trigger.old[idx].Business_Event_Target_vod__c : Trigger.new[idx].Business_Event_Target_vod__c);
    }
    
    Map<Id, Business_Event_Target_vod__c> bets = new Map<Id, Business_Event_Target_vod__c>(
        [select Id, RecordTypeId from Business_Event_Target_vod__c where Id in :betIds and RecordTypeId in :recTypes.keySet()]);
       
    for (Integer idx = 0; idx < Trigger.size; idx++)
    {
        if (skip[idx])
        {
            continue;
        }
        Id betId = Trigger.isDelete ? Trigger.old[idx].Business_Event_Target_vod__c : Trigger.new[idx].Business_Event_Target_vod__c;

        if (betId != null)
        {           
            Business_Event_Target_vod__c bet = bets.get(betId);
            if (!Trigger.isDelete && bet == null)
            {
                Trigger.new[idx].addError(('Call_Objective ' + Trigger.new[idx].Name + ' ' + VOD_GET_ERROR_MSG.getErrorMsg('Invalid', 'TABLET')  + ' Business_Event_Target_vod__c = ' + betId), false);
                return;
            }

            if (!Trigger.isDelete)
            {            
                RecordType coRecType = recTypes.get(Trigger.new[idx].RecordTypeId);
                RecordType betRecType = recTypes.get(bet.RecordTypeId);
                
                if (coRecType == null || betRecType == null)
                {
                    Trigger.new[idx].addError('RecordType must not be null', false);
                    return;
                }
                else if (!coRecType.Name.equals(betRecType.Name))
                {
                    Trigger.new[idx].addError('Call Objective must be the same RecordType as Business_Event_Target_vod__c', false);
                    return;
                }
            }
            
            bet.Next_Visit_Date_vod__c = null;
            bet.Remaining_Calls_vod__c = 0;                    
            
            boolean updBET = Trigger.isUpdate && Trigger.new[idx].Completed_Flag_vod__c && !Trigger.old[idx].Completed_Flag_vod__c;       
            
            if (Trigger.isDelete)
            {
                if (Trigger.old[idx].Pre_Explain_Flag_vod__c)
                {
                    System.Debug('trying to reset pre_explain bet ' + bet.Id);
                    bet.Pre_Explain_Date_vod__c = null;
                }
                bets.put(betId, bet);                
            }
            else if (Trigger.new[idx].Pre_Explain_Flag_vod__c)
            {
                // this is Pre_Explain Call Objective
                if (updBET  || (Trigger.isInsert && Trigger.new[idx].Completed_Flag_vod__c))
                {
                    // update BET if update status to completed from incompleted, Or insert a new completed            
                    bet.Pre_Explain_Date_vod__c = Trigger.new[idx].Date_vod__c.date();
                    bets.put(Trigger.new[idx].Business_Event_Target_vod__c, bet);
                }
            }
            else if (updBET || (Trigger.isInsert && !Trigger.new[idx].Completed_Flag_vod__c))
            {
                // update count if update status to completed from incompleted, Or insert a new incompleted            
                if (!bets.containsKey(Trigger.new[idx].Business_Event_Target_vod__c))
                {                
                    bets.put(Trigger.new[idx].Business_Event_Target_vod__c, bet);                 
                }
            }
        }
    }
    
    // Query Call_Objective_vod to set next visit date and number of remaining calls for the corresponding Business_Event_Target_vod
    for (List<Call_Objective_vod__c> cObjs : [select Id, Business_Event_Target_vod__c,Date_vod__c
                                              from Call_Objective_vod__c
                                              where Completed_Flag_vod__c = false and
                                                    RecordTypeId in :recTypes.keySet() and
                                                    Business_Event_Target_vod__c in :bets.keySet()])
     {         
         for (Call_Objective_vod__c cObj : cObjs)
         {         
             if (deletedIds.contains(cObj.Id) || cObj.Business_Event_Target_vod__c == null)
             {
                 continue;
             }
             Business_Event_Target_vod__c bet = bets.get(cObj.Business_Event_Target_vod__c);
             if (bet != null)
             {
                 if (bet.Next_Visit_Date_vod__c == null || bet.Next_Visit_Date_vod__c > cObj.Date_vod__c.date())
                 {
                     bet.Next_Visit_Date_vod__c = cObj.Date_vod__c.date();
                 }
                 bet.Remaining_Calls_vod__c++;
             }
         }
     }
     
     if (bets.size() > 0)
     {
         // update Business Event Target with the new remaining count and next visit date
         // and skip all triggers
         VEEVA_BUSINESS_EVENT_TARGET_TRIG.invoked = true;         
         update(bets.values());                                                    
     }
}