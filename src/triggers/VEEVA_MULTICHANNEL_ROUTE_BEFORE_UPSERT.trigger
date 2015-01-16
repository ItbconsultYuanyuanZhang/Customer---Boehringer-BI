trigger VEEVA_MULTICHANNEL_ROUTE_BEFORE_UPSERT on Multichannel_Route_vod__c (before insert, before update) {
    
    for (Multichannel_Route_vod__c route : trigger.new){
        String recordType = route.Record_Type_Name_vod__c;
        String objectName = route.Object_vod__c;
        if(recordType == null){
            route.VExternal_Id_vod__c = objectName + '_' + route.Language_vod__c;
        }
        else{
           route.VExternal_Id_vod__c = objectName + '_' + recordType + '_' + route.Language_vod__c;
        }
    }
}