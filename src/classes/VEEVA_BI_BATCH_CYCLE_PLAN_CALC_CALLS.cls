/*
*
*TO RUN : 
	VEEVA_BI_BATCH_CYCLE_PLAN_CALC b = new VEEVA_BI_BATCH_CYCLE_PLAN_CALC(); database.executebatch(b,100);
	VEEVA_BI_BATCH_CYCLE_PLAN_CALC_CALLS c = new VEEVA_BI_BATCH_CYCLE_PLAN_CALC_CALLS (); database.executebatch(c,100);
*
*/

global class VEEVA_BI_BATCH_CYCLE_PLAN_CALC_CALLS implements Database.Batchable<sObject> {
    private final String initialState;
    String query;
    Integer CP_DAY = Integer.valueOf(System.Label.BI_CP_DAYS);
    global VEEVA_BI_BATCH_CYCLE_PLAN_CALC_CALLS() {
    
    
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // This is the base query that dirves the chunking.
        // We are grabbing all the plans are currently active and
        // have a start or end date that is currently in need of calculation.
        
        if(CP_DAY==null) CP_DAY=0;
                         
        query = 'SELECT Id,' +
                '       Cycle_Plan_vod__r.Start_Date_vod__c, ' +
                '       Cycle_Plan_vod__r.End_Date_vod__c,' +
                '       Cycle_Plan_vod__r.Territory_vod__c,' +
                '       Cycle_Plan_Account_vod__c,' + 
                '		Cycle_Plan_vod__r.Active_vod__c' +
                ' FROM  Cycle_Plan_Target_vod__c ' +
                ' WHERE Cycle_Plan_vod__r.Start_Date_vod__c <= TODAY  '+ 
                ' AND   Cycle_Plan_vod__r.Close_Out_End_Date_BI__c >= TODAY' 
                //' 		 OR Cycle_Plan_vod__r.End_Date_vod__c <= NEXT_N_DAYS:' + CP_DAY + ' ) '
                //' AND   Cycle_Plan_vod__r.Active_vod__c = true '
                ;  
        system.debug('CALC_CALLS startquery: ' + query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> batch) {
        // Loop through all the rows in the batch of Cycle Plan Details
        List <Cycle_Plan_Target_vod__c> planTargetsToUpdate = new List <Cycle_Plan_Target_vod__c> ();
        Set<String> setPlansInSet = new Set<String> ();	  
        for (sObject obj : batch) {
            Cycle_Plan_Target_vod__c cycle = (Cycle_Plan_Target_vod__c)obj;
            if (cycle.Cycle_Plan_Account_vod__c == null)
            	continue;
                        
            // Move some of the values from the object into easier to easier to read variables. 
            String account =   cycle.Cycle_Plan_Account_vod__c;            
            String territory = cycle.Cycle_Plan_vod__r.Territory_vod__c;
            Date dateStart =   cycle.Cycle_Plan_vod__r.Start_Date_vod__c;
            Date dateEnd =     cycle.Cycle_Plan_vod__r.End_Date_vod__c;
            Boolean active =   cycle.Cycle_Plan_vod__r.Active_vod__c;
            Date tod = 	   	   Date.today();
            
            //MOVED ACTIVE checkbox filter here, to accomodate extra time
            if (!(active || (dateEnd <= tod && tod <=dateEnd.addDays(CP_DAY))))
            	continue;
            
            // Loop through the Call2_Detail_vod__c results for what we need here.
            
            System.debug ('VEEVADEBUG: Processing : "' + account + '" for territrory = "'
                           + territory +'" Date ="'+ dateStart +'" to "' + dateEnd + '"');            
            
            Set <Id> haveCalls = new Set<Id> ();
            Integer calls = 0; 
            Integer teamCalls = 0;
            
            Integer callsSched = 0;
            Integer teamCallsSched = 0;
            
            for (Call2_vod__c call : 
                   [Select Account_vod__c,
                           Territory_vod__c,
                           Call_Date_vod__c,
                           Status_vod__c,
                           Account_vod__r.Country_Code_BI__c,
                           Detailed_Products_vod__c, //added for extra criteria
                           (select id from call2_detail_vod__r)
                    FROM Call2_vod__c 
                    WHERE Account_vod__c = :account
                    and Call_Date_vod__c >= :dateStart
                    and Call_Date_vod__c <= :dateEnd
                    and recordtype.Developername != 'Courtesy_Call_BI'  //added by Viktor - 2013.05.09
                    ]) {
            
             System.debug ('Call: ' + call);        
                	
             if (call.Status_vod__c == 'Planned_vod' || 
             //removed past dates criteria
                   call.Status_vod__c == 'Saved_vod') {
                         	
             	if (territory == call.Territory_vod__c)
             		callsSched++;
             	
             	teamCallsSched++;
             	
             	System.debug (Call.Id + ' is scheduled. SCHED = ' + callsSched + ' TEAM SCHED = ' +teamCallsSched );
             	
             }   else {
         
             	
                if (territory == call.Territory_vod__c && 
                   (call.Detailed_Products_vod__c != null || call.call2_detail_vod__r.size()>0 || call.Account_vod__r.Country_Code_BI__c == 'JP')) //Viktor - new entry criteria: only calls with prod detail can be actual
                   calls++; 
                   
                teamCalls++;
                
                System.debug (Call.Id + ' is actual. Calls = ' + calls + ' TEAM Calls = ' +teamCalls );
            }
            
            System.debug ('END of cycle result- ' + Call.Id + ' is scheduled. SCHED = ' + callsSched + ' TEAM SCHED = ' +teamCallsSched );
            System.debug ('END of cycle result- ' +Call.Id + ' is actual. Calls = ' + calls + ' TEAM Calls = ' +teamCalls );
            
		    }
            Cycle_Plan_Target_vod__c PlanTarget = 
                   new Cycle_Plan_Target_vod__c(ID = cycle.Id, 
                                                Actual_Calls_vod__c = calls,
                                                Total_Actual_Calls_vod__c = teamCalls,
                                                Scheduled_Calls_vod__c = callsSched,
                                                Total_Scheduled_Calls_vod__c = teamCallsSched
                                                );
               if (setPlansInSet.contains(cycle.Id) == false) {
               	   System.debug('3 - PlanTarget - ' + PlanTarget);                                 
                	planTargetsToUpdate.add (PlanTarget);
                	setPlansInSet.add(cycle.Id);
               }
                       
            
        }
        
        if (planTargetsToUpdate.size () > 0 ) {
        	System.debug (planTargetsToUpdate.size());
        	update planTargetsToUpdate;
        } 
    }
    global void finish(Database.BatchableContext BC) {
        // Access initialState here
    }
}