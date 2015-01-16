trigger MedicalEventPMBI on Medical_Event_vod__c
    (after update) 
{
    new TriggersBI()
        .bind(TriggersBI.Evt.afterupdate, new CalculateActualsPMBI())
        .manage();

}