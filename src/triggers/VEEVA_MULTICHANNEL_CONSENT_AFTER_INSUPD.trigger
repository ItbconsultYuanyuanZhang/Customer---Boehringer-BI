trigger VEEVA_MULTICHANNEL_CONSENT_AFTER_INSUPD on Multichannel_Consent_vod__c (after insert, after update) {
    if(Trigger.new.size() == 0){
        return;
    }
    RecordType[] recordTypes = [Select Id, Name from RecordType where SobjectType = 'Multichannel_Consent_vod__c' and Name='Approved_Email_vod'];
    if(recordTypes.size() == 0){
        return;
    }
    String AERecordTypeID = recordTypes[0].Id;
    Set<String> optInAccountIDs = new Set<String>();
    Set<String> optInChannels= new Set<String>();
    Set<String> globalOptOutAccountIDs = new Set<String>();
    Set<String> globalOptOutChannels= new Set<String>();
    for(Multichannel_Consent_vod__c record: Trigger.new){
        if(record.Opt_Type_vod__c == 'Opt_In_vod' && record.RecordTypeId == AERecordTypeID ){
            optInAccountIDs.add(record.Account_vod__c);
            optInChannels.add(record.Channel_Value_vod__c);  
        }
        else if(record.Opt_Type_vod__c == 'Opt_Out_vod' && record.RecordTypeId == AERecordTypeID && record.Product_vod__c==null && record.Detail_Group_vod__c==null){
            globalOptOutAccountIDs .add(record.Account_vod__c);
            globalOptOutChannels.add(record.Channel_Value_vod__c);  
        }
    }
    
    List<Multichannel_Consent_vod__c> toUpdate = new List<Multichannel_Consent_vod__c>();
    
    if(optInAccountIDs.size() > 0){
        String optValue = 'Opt_Out_vod';
        Multichannel_Consent_vod__c [] results = [SELECT Name, Opt_Expiration_Date_vod__c, Account_vod__c, Channel_Value_vod__c, Capture_Datetime_vod__c FROM Multichannel_Consent_vod__c  WHERE RecordTypeId=:AERecordTypeID AND Opt_Type_vod__c=:optValue  AND Opt_Expiration_Date_vod__c=Null AND Account_vod__c IN :optInAccountIDs AND Channel_Value_vod__c IN :optInChannels ORDER BY Capture_Datetime_vod__c DESC];
        for(Multichannel_Consent_vod__c newRecord: Trigger.new){
            if(newRecord.Opt_Type_vod__c == 'Opt_In_vod'){
                String acctID = newRecord.Account_vod__c;
                String channel = newRecord.Channel_Value_vod__c;
                Datetime captureDate = newRecord.Capture_Datetime_vod__c; 
                for(Multichannel_Consent_vod__c oldRecord: results ){
                    if(captureDate > oldRecord.Capture_Datetime_vod__c && acctID.equals(oldRecord.Account_vod__c) && channel.equals(oldRecord.Channel_Value_vod__c)){
                        oldRecord.Opt_Expiration_Date_vod__c = Date.today();
                        toUpdate.add(oldRecord);
                    }
                }
            }     
        }
    }
    
    if(globalOptOutAccountIDs.size() > 0){
        String optValue = 'Opt_In_vod';
        Multichannel_Consent_vod__c [] results = [SELECT Name, Opt_Expiration_Date_vod__c, Account_vod__c, Channel_Value_vod__c, Capture_Datetime_vod__c FROM Multichannel_Consent_vod__c  WHERE RecordTypeId=:AERecordTypeID AND Opt_Type_vod__c=:optValue  AND Opt_Expiration_Date_vod__c=Null AND Account_vod__c IN :globalOptOutAccountIDs AND Channel_Value_vod__c IN :globalOptOutChannels ORDER BY Capture_Datetime_vod__c DESC];
        for(Multichannel_Consent_vod__c newRecord: Trigger.new){
            if(newRecord.Opt_Type_vod__c == 'Opt_Out_vod'){
                String acctID = newRecord.Account_vod__c;
                String channel = newRecord.Channel_Value_vod__c;
                Datetime captureDate = newRecord.Capture_Datetime_vod__c; 
                for(Multichannel_Consent_vod__c oldRecord: results ){
                    if(captureDate > oldRecord.Capture_Datetime_vod__c && acctID.equals(oldRecord.Account_vod__c) && channel.equals(oldRecord.Channel_Value_vod__c)){
                        oldRecord.Opt_Expiration_Date_vod__c = Date.today();
                        toUpdate.add(oldRecord);
                    }
                }
            }     
        }
    }
    update toUpdate;   
}