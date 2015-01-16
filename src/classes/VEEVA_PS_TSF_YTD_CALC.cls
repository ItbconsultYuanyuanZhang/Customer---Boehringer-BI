global class VEEVA_PS_TSF_YTD_CALC implements Database.Batchable<sObject>,Schedulable  {

    /**************************************************************************
        VEEVA_PS_TSF_YTD_CALC
        December 5, 2013
        Version 1.0
        
        Summary
        --------------
        Two routines are available to handle new year for the YTD activity flag:
        1. VEEVA_PS_TSF_YTD_RESET - zero out the TSF YTD Activity field (run on Dec 31st or Jan 1st)
        2. VEEVA_PS_TSF_YTD_CALC - zero out and re-calculate the TSF YTD Activity field  for current calendar year (can be run at any time in the year)
            
        VEEVA_PS_TSF_YTD_CALC may take long time to complete for large TSF volume.
        VEEVA_PS_TSF_YTD_RESET will run faster than VEEVA_PS_TSF_YTD_CALC as it does not have call2_vod__c queries.
        
        How to Run
        --------------
        Option 1. Run manually via the SFDC Developer Console:
        database.executebatch(new VEEVA_PS_TSF_YTD_CALC(),200); 
        
        Option 2. Schedule a nightly routine to run on Dec 31st or Jan 1st.
        Setup > Develop > Apex Classes > Schedule Apex
    **************************************************************************/
    
    global VEEVA_PS_TSF_YTD_CALC(){

    
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('select Id, Account_vod__c, Territory_vod__c, External_Id_vod__c, YTD_Activity_vod__c from TSF_vod__c where Account_vod__c != null and Territory_vod__c != null');
    }

    global void execute(SchedulableContext ctx) { 
        database.executebatch(new VEEVA_PS_TSF_YTD_CALC(),200); 
    } 

    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        Map<String, TSF_vod__c> tsf = new Map<String, TSF_vod__c>();   
        Set<Id> setAccount = new Set<Id>();
        Set<String> setTerritory = new Set<String>();
        
        for(TSF_vod__c t : (List<TSF_vod__c>) scope) {
                        
            t.YTD_Activity_vod__c = 0;            
            tsf.put(t.External_Id_vod__c,t);
            
            setAccount.add(t.Account_vod__c);
            setTerritory.add(t.Territory_vod__c);
        }
        
        for ( AggregateResult results :  [Select Account_vod__c, Territory_vod__c, Count(Id) totCalls
                                     From Call2_vod__c where Account_vod__c in :setAccount and Territory_vod__c in :setTerritory                        
                                     AND Status_vod__c != 'Planned_vod'
                                     AND Call_Date_vod__c = THIS_YEAR
                                     AND Call_Date_vod__c <= TODAY
                                     GROUP BY Account_vod__c, Territory_vod__c ]) {                    
            String territory = (String)results.get('Territory_vod__c');
            String accountid = (String)results.get('Account_vod__c');
            Integer callsYTD = (Integer)results.get('totCalls');
                
            TSF_vod__c t = tsf.get(accountid + '__' + territory);
            if (t != null) {                   
                t.YTD_Activity_vod__c = callsYTD;                            
            }
        }          
        
        // run the updates  
        if (tsf.size() > 0 ) {          
            try {
                update tsf.values();
            } catch (DMLException e) { 
                System.debug(e.getMessage()); 
            }
        }  
    }

    global void finish(Database.BatchableContext BC) {}
}