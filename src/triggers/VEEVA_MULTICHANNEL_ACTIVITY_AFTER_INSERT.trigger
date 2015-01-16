trigger VEEVA_MULTICHANNEL_ACTIVITY_AFTER_INSERT on Multichannel_Activity_vod__c (after insert) {

    Set<id> callIds = new set<id>();
    Map<id,List<Multichannel_Activity_vod__c>> MCAMAP = new Map<id,List<Multichannel_Activity_vod__c>>(); 
    List<Multichannel_Activity_vod__c> inputMA = trigger.new;
 
    if ( inputMA != null && inputMA.size() > 0 ) {
  
        List<Multichannel_Activity_vod__c> tmpMAList = null;
        
        for(Multichannel_Activity_vod__c mac : inputMA) {
        
            if ( mac.Call_vod__c != null ) {
                callIds.add(mac.Call_vod__c); 
                tmpMAList = MCAMAP.get(mac.Call_vod__c);
                
                if ( tmpMAList == null ) {
                    tmpMAList = new List<Multichannel_Activity_vod__c>();
                }
                tmpMAList.add(mac);
                MCAMAP.put(mac.Call_vod__c, tmpMAList);
            }
        }
    }
 
    if ( callIds != null && callIds.size() > 0 ) { 
         List<Call2_vod__c> calls = [ SELECT id, Owner.id ,Cobrowse_MC_Activity_vod__c
                                         FROM Call2_vod__c 
                                         WHERE id in :callIds
                                         and Status_vod__c != 'Submitted_vod'
                                       ];                      
         List<Call2_vod__c> callToUpdate = null;
         List<Multichannel_Activity_vod__c> mcaToUpdate = null;
         if ( calls != null && calls.size() > 0 ) {
               
             callToUpdate = new List<Call2_vod__c>();
             List<Multichannel_Activity_vod__c> MCAList = null; 
             
             for (Call2_vod__c call: calls ) {
                 MCAList = MCAMAP.get(call.id);   
                 if ( MCAList != null && MCAList.size() > 0 ) {
                     for(Multichannel_Activity_vod__c MCA:MCAList) {   //for every activity, stamping owner id from call.
                        Multichannel_Activity_vod__c tmca = new Multichannel_Activity_vod__c(id=MCA.id);
                        tmca.Organizer_vod__c = call.Owner.id;
                        if ( mcaToUpdate == null ) {
                            mcaToUpdate = new List<Multichannel_Activity_vod__c>();
                        }
                        mcaToupdate.add(tmca);
                     } 
                     if ( call.Cobrowse_MC_Activity_vod__c == null ) {
                         for(Multichannel_Activity_vod__c mavc: MCAList) {
                             if (mavc.Account_vod__c != null ) {
                                 call.Cobrowse_MC_Activity_vod__c = mavc.id;
                                 if ( callToUpdate == null ) {
                                    callToupdate = new List<Call2_vod__c>();
                                 }
                                 callToUpdate.add(call);
                                 break;
                             }
                         } 
                         
                    }
                 }               
             }
             
             if (callToUpdate != null && callToUpdate.size() > 0) {
                update callToUpdate;
             }
             
             if (mcaToUpdate != null && mcaToUpdate.size() > 0 ) {
                update mcaToUpdate;
             }
         }
    } 
}