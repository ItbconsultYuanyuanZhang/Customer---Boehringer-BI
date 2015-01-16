/*
*
*TO RUN : 
	VEEVA_BI_BATCH_CYCLE_PLAN_CALC b = new VEEVA_BI_BATCH_CYCLE_PLAN_CALC(); database.executebatch(b,100);
	VEEVA_BI_BATCH_CYCLE_PLAN_CALC_CALLS c = new VEEVA_BI_BATCH_CYCLE_PLAN_CALC_CALLS (); database.executebatch(c,100);
*
*/
global class VEEVA_BI_BATCH_CYCLE_PLAN_CALC implements Database.Batchable<sObject> { 
	private final String initialState;
	String query;
	Integer CP_DAY = Integer.valueOf(System.Label.BI_CP_DAYS);
	global VEEVA_BI_BATCH_CYCLE_PLAN_CALC() {
	
	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
		// This is the base query that dirves the chunking.
		// We are grabbing all the plans are currently active and
		// have a start or end date that is currently in need of calculation.
		
		if(CP_DAY==null) CP_DAY=0;
		
		query = 'SELECT Id,' +
		        '       Cycle_Plan_Target_vod__r.Id,' +
		        '       Cycle_Plan_Target_vod__r.Cycle_Plan_vod__r.Start_Date_vod__c, ' +
		        '       Cycle_Plan_Target_vod__r.Cycle_Plan_vod__r.End_Date_vod__c,' +
		        '       Cycle_Plan_Target_vod__r.Cycle_Plan_vod__r.Territory_vod__c,' +
		        '       Cycle_Plan_Target_vod__r.Cycle_Plan_vod__r.Active_vod__c,' +
		        '       Cycle_Plan_Target_vod__r.Cycle_Plan_Account_vod__c,' + 
		        '       Product_vod__c' + 
		        ' FROM Cycle_Plan_Detail_vod__c ' +
		        ' WHERE Cycle_Plan_Target_vod__r.Cycle_Plan_vod__r.Start_Date_vod__c <= TODAY  '+
		        ' AND  Cycle_Plan_Target_vod__r.Cycle_Plan_vod__r.Close_Out_End_Date_BI__c >= TODAY ' 
		        //' AND  Cycle_Plan_Target_vod__r.Cycle_Plan_vod__r.Active_vod__c = true ' 
		        ;  
		
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext BC, List<sObject> batch) {
		// Loop through all the rows in the batch of Cycle Plan Details
		List <Cycle_Plan_Detail_vod__c> planDetailsToUpdate = new List <Cycle_Plan_Detail_vod__c> ();
		Set<String> setPlansInSet = new Set<String> ();	
		for (sObject obj : batch) {
			Cycle_Plan_Detail_vod__c cycle = (Cycle_Plan_Detail_vod__c)obj;
			
			// Move some of the values from the object into easier to easier to read variables. 
			String account = cycle.Cycle_Plan_Target_vod__r.Cycle_Plan_Account_vod__c;
			String product = cycle.Product_vod__c;
			String territory = cycle.Cycle_Plan_Target_vod__r.Cycle_Plan_vod__r.Territory_vod__c;
			Date dateStart = cycle.Cycle_Plan_Target_vod__r.Cycle_Plan_vod__r.Start_Date_vod__c;
			Date dateEnd = cycle.Cycle_Plan_Target_vod__r.Cycle_Plan_vod__r.End_Date_vod__c;
			Boolean active =   cycle.Cycle_Plan_Target_vod__r.Cycle_Plan_vod__r.Active_vod__c;
            Date tod = 	   	   Date.today();
			
			//MOVED ACTIVE checkbox filter here, to accomodate extra time
            if (!(active || (dateEnd <= tod && tod <=dateEnd.addDays(CP_DAY))))
            	continue;
			
			
			// Loop through the Call2_Detail_vod__c results for what we need here.
			
			System.debug (account + '<->' + product + '<->' + territory + '<->'+dateStart +'<->' +dateEnd );
			Set <Id> haveCalls = new Set<Id> ();
			
			Integer countMyTerr = 0;
			Integer countAll = 0;
			
			Integer counterAllSched = 0;
			Integer counterMyTerrSched = 0;
			
			for (Call2_Detail_vod__c call_det : 
			       [Select Call2_vod__r.Account_vod__c,
			               Call2_vod__r.Status_vod__c,
			               Call2_vod__r.Call_Date_vod__c,
			               Call2_vod__r.Territory_vod__c, 
			               Product_vod__c, 
			               Call2_vod__c
			        FROM Call2_Detail_vod__c 
			        WHERE Call2_vod__r.Account_vod__c = :account
					AND Product_vod__c  = :product
					and Call2_vod__r.Call_Date_vod__c >= :dateStart
					and Call2_vod__r.Call_Date_vod__c <= :dateEnd
					and Call2_vod__r.RecordType.Developername != 'Courtesy_Call_BI'  //added by Viktor - 2013.05.09
					]) {
					
					// if the lookup is null,  no work to do here.  
				    // Probably shouldnt happen but better safe 
				if (call_det.Call2_vod__r == null)
					continue;	
						
				if(call_det.Call2_vod__r.Territory_vod__c == territory) {
					if (call_det.Call2_vod__r.Status_vod__c == 'Planned_vod' || 
//Viktor:				REMOVED ONLY PAST SAVED criteria
					    call_det.Call2_vod__r.Status_vod__c == 'Saved_vod') {
						counterMyTerrSched++;
					} else {
						if(call_det.Product_vod__c != null)	countMyTerr++;
					}
				} 
				
				if (call_det.Call2_vod__r.Status_vod__c == 'Planned_vod' || 
//Viktor:				REMOVED ONLY PAST SAVED criteria
					    call_det.Call2_vod__r.Status_vod__c == 'Saved_vod') {
					counterAllSched++;		
				} else {
					if(call_det.Product_vod__c != null)countAll++;
				}
			}
			
			Cycle_Plan_Detail_vod__c PlanDetail = 
		 		   new Cycle_Plan_Detail_vod__c(ID = cycle.Id, 
		 		                                Actual_Details_vod__c = countMyTerr,
		 		                                Scheduled_Details_vod__c = counterMyTerrSched,
		 		                                Total_Scheduled_Details_vod__c = counterAllSched, 
		 		                                Total_Actual_Details_vod__c =  countAll);
		 		                                
			if (setPlansInSet.contains(cycle.Id) == false) {		 		                                
		 			planDetailsToUpdate.add (PlanDetail);
		 			setPlansInSet.add(cycle.Id);
			}
		}
		
		System.debug (planDetailsToUpdate);
		if (planDetailsToUpdate.size () > 0)
			update planDetailsToUpdate; 
	}
	global void finish(Database.BatchableContext BC) {
		// Access initialState here
	}
}