trigger VOD_MC_ACTIVITY_BEFORE_INSERT on Multichannel_Activity_vod__c(before insert) {
    
    if(Schema.sObjectType.Multichannel_Activity_vod__c.fields.Territory_vod__c.isCreateable() && Schema.sObjectType.Sent_Email_vod__c.fields.Territory_vod__c.isAccessible()){

        Set<Id> sentEmailIds = new Set<Id>();
        for(Multichannel_Activity_vod__c mca: Trigger.new){
            if(mca.Territory_vod__c == null && mca.Sent_Email_vod__c != null){
                sentEmailIds.add(mca.Sent_Email_vod__c);
            }
        }
        
        if(sentEmailIds.size() > 0){
        
            Map<Id, Sent_Email_vod__c> sentEmails = new Map<Id, Sent_Email_vod__c>([Select Id, Territory_vod__c FROM Sent_Email_vod__c WHERE Id IN :sentEmailIds]);
            
            for(Multichannel_Activity_vod__c mca: Trigger.new){
                if(mca.Territory_vod__c == null && mca.Sent_Email_vod__c != null){
                    Sent_Email_vod__c se = sentEmails.get(mca.Sent_Email_vod__c);
                    mca.Territory_vod__c = se.Territory_vod__c;
                }
            }
        
        }
    
    }

}