trigger VEEVA_SENT_EMAIL_AFTER_INSERT on Sent_Email_vod__c (after insert) {
    
    
    for (Sent_Email_vod__c se : trigger.new){   
        Id templateID = se.Approved_Email_Template_vod__c; 
        String fragments = se.Email_Fragments_vod__c;
        List<Sent_Fragment_vod__c> sentFragments = new List<Sent_Fragment_vod__c>();
        if(fragments != null){
            String[] fragmentList = fragments.split(',');
            for(String fragmentId: fragmentList){
                Sent_Fragment_vod__c fragment = new Sent_Fragment_vod__c();
                fragment.Sent_Fragment_vod__c = fragmentId;
                fragment.Email_Template_vod__c = templateID;
                fragment.Sent_Email_vod__c = se.Id;
                fragment.Account_vod__c = se.Account_vod__c;
                sentFragments.add(fragment);
            }
            try {
                insert sentFragments;
            } catch( Exception e ) {
                 
            }         
        }
        
    }  
   
}