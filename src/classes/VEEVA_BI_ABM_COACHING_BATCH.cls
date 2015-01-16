global without sharing class VEEVA_BI_ABM_COACHING_BATCH implements Database.batchable<sObject>{

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		string selStmt = '';
		
		selStmt = 'SELECT ID, CreatedByID, Coaching_Duration_BI__c, Review_Date__c, Manager_vod__c , ownerid FROM Coaching_Report_vod__c ';
		selStmt = selStmt + ' WHERE Status__c = \'Approved\' '  ;  
		selStmt = selStmt + ' AND LastModifiedDate <= yesterday  '  ;
		//selStmt = selStmt + ' AND LastModifiedDate <= yesterday  '  ;
		//selStmt = selStmt + ' AND LastModifiedDate >= 2013-09-18T00:00:00.000Z'  ;
		//selStmt = selStmt + ' AND LastModifiedDate <= 2013-06-01 '  ;
		//selStmt = selStmt + ' and Manager_vod__c = \'005J0000001FXUs\' ';  
		//selStmt = selStmt + ' AND ID in (\'a1DJ00000001uWKMAY\',\'a1DJ00000001uWPMAY\')';     
		selStmt = selStmt + ' limit 5000000  ';
		
		System.Debug('SQLu = ' + selStmt);
		
		return Database.getQueryLocator(selStmt);   
		
	}   
	
	global void execute(Database.BatchableContext BC, List<sObject> batch)
	{
		List<Coaching_Report_vod__c> CoachingRecords = (List<Coaching_Report_vod__c>) batch;

        system.Debug('CSABA 1 CR Batch size = ' + CoachingRecords.size());

		
		integer batchSize = batch.size();
		
		for(integer i=0; i<batchSize; i++)
		{

			date datum = CoachingRecords[i].Review_Date__c; 
			string Duration = CoachingRecords[i].Coaching_Duration_BI__c;
			string CallDateDAY = string.valueOf(datum.day());
			
			//calculate duration
			integer IDuration = 0;
			
				
			if (Duration == 'Two Days')
				IDuration = 2;
			else
				IDuration = 1; 
				
			//get quarter info
			integer IYear = datum.year();  
		    integer Imonth = datum.month();
		    integer Quoter = Imonth / 3;
		    //Quoter = Quoter + 1;
		    
		    //2013.06.07. correct quoter calculation
		    integer Remainder = math.mod(Imonth,3);
		    if(Remainder > 0)
		      Quoter = Quoter + 1;    
		       
		    String theYear = String.valueOf(IYear);
		    
		    String NextYear = String.valueOf(IYear + 1); //used only  for Overflow
		    
		    //get user info
			id  UserID = NULL;
			
			//if (UserID == NULL)
			//	UserID = CoachingRecords[i].OwnerId;
				//2013.09.15. replaced by above UserID = CoachingRecords[i].CreatedById;
			   
			if (UserId == null)
			   	UserID = CoachingRecords[i].Manager_vod__c;  

			User Useru = [select Name, Country_Code_BI__c from User where ID = :UserID limit 1];
		       
			if (Useru.Country_Code_BI__c == NULL)
			{
				System.Debug('CSABA -1 Missing Cocuntry code');
			    continue;
			}
			    
			
			//get country code    
			string Country_Codu = '';	    
			Country_Codu = Useru.Country_Code_BI__c; 
		
			//get working day info
		    String WD_Name = Useru.Country_Code_BI__c + '_' + theYear; 
		    
		    string Next_WD_Name = Useru.Country_Code_BI__c + '_' + NextYear;   //2013.09.16.
		    
		    Working_Day_BI__c[] WDs = [	select 	Id, Name 
		    						   	from 	Working_Day_BI__c
		                               	where	(Name = :WD_Name or Name = :Next_WD_Name) 
		                                and 	Country_Code_BI__c = :Useru.Country_Code_BI__c 
		                                order by Name asc ]; 
		     
		    if (WDs == NULL)    	
		    	continue;
		      
		    if (WDs.size() == 0)
		    	continue;      	
		 
		   	//2013.09.16. if (WDs.size() > 1)  
		    //               continue;  //inconsistent data do not handle
			
			List<String> Ms = new List<String>
		                  {
		                  'January',
		                  'February',
		                  'March',
		                  'April',
		                  'May',
		                  'June',
		                  'July',
		                  'August',
		                  'September',
		                  'October',
		                  'November',
		                  'December'
		                  };   
                   
      		string currentMonth = ms[Imonth - 1];
      		
			System.Debug('CSABA 1.0 CR datum ' + datum + ' duration = ' +  IDuration + ' OwnerID = ' + UserID);      		
      		
      		//2013.09.16.  handle oveflow
      		Integer CurrMonthDuration = IDuration;
      		Integer NextMonthDuration = 0;   //use it only in case is Overflow
      		
      		String CurrYear = theYear;
      		    //use it only in case is Overflow 
      		
      		String CurrMonth = currentMonth;
      		String NextMonth;   //use it only in case is Overflow
      		
      		Integer CurrentQuater = Quoter;
      		Integer NextQuater; //use it only in case is Overflow
      		
      		Boolean b_isOverflow = false;
      		if(IDuration == 2)
      		{
      			Date isOverflow = datum.addDays(1);
      			if(datum.month() != isOverflow.month())     
      			{
      				b_isOverflow = true;
      				CurrMonthDuration = IDuration - 1;
      				NextMonthDuration = 1;
      				//check if is the same yaer or Not
      				if(datum.year()  != isOverflow.year())
      				{
      					NextYear = String.valueOf(IYear + 1);
      					NextMonth = ms[0];
      					NextQuater = 1;
      				}
      				else
      				{
      					NextMonth = ms[Imonth];
                        NextYear = String.valueOf(IYear);
                        
                        NextQuater = (Imonth+1) / 3;
                    
                        Remainder = math.mod(Imonth+1,3);
                        if(Remainder > 0)
                           NextQuater = NextQuater + 1;    
      				}
      			}
      			else
      			{
      				//do nothing
      			}
      		}
      		//2013.09.16. handle overflow
      		
      		//identify the right Activity_Benchmark_BI__c  record  and increment the Activity_Count_BI__c
	      	Activity_Benchmark_BI__c[] ABs = [ select 	id, 
	      												Activity_Count_BI__c,
		      											Coaching_Activity_Count_BI__c,
		                                        		Details_in_Period_BI__c,
		                                        		Name, 
		                                        		Comment__c, 
		                                        		Quarter_BI__c, 
		                                        		LastModifiedDate,
		                                        		Activity_count_Daily_BI__c,   //new request from David 2013.05.27.
		                                        		CallSubmitdaysList__c        //new request from David 2013.06.07.
		                                        from 	Activity_Benchmark_BI__c
		                                        where 	User_BI__c = :UserId
		                                        and		Year_of_Activity_BI__c = :theYear    
		                                        and 	Month_BI__c = :currentMonth ];
		                                        
		    if (ABs.size() == 0)
      		{	   	
		      	//create new record
		      	VEEVA_HLP_WorkingDay MyWD = new VEEVA_HLP_WorkingDay();
		      	integer WD = MyWD.GetWorkingDay(Country_Codu,theYear,currentMonth);
		            
		      	Activity_Benchmark_BI__c ABM = new Activity_Benchmark_BI__c();
		      	ABM.User_BI__c = UserId;
		      	ABM.OwnerId = UserId;  //2013.09.17.  
		      	ABM.Month_BI__c = currentMonth;
		      	ABM.Quarter_BI__c =  'Quarter ' + String.valueOf(Quoter);
		      	ABM.Year_of_Activity_BI__c = theYear;        
		      	ABM.Working_Days_in_Period_BI__c = WD;
		      	ABM.Activity_Count_BI__c = CurrMonthDuration; //2013.09.16. IDuration; 
		      	//ABM.Activity_count_Daily_BI__c = 1;  //2013.09.17.
		      	ABM.Activity_count_Daily_BI__c = CurrMonthDuration;  //2013.09.17.
		      
		      	ABM.CallSubmitdaysList__c = CallDateDAY + ';';   
		        System.Debug('CSABA 3.09  Inserting new AB record for User ' + UserId);        
		      	insert ABM;  
		      
		      	//2013.09.16.  continue;        
	      	}
	      	
	      	
	      	if (ABs.size() == 1)
      		{
				system.Debug('We already have a record  Month: ' + currentMonth + ' year: ' + theYear + ' userID: ' + UserId + ' ID= ' + ABs[0]);                                     
     
		      	//UPDATE Activity_Count_BI__c ******************************** 
		      	Integer countu =  Integer.valueof(ABs[0].Activity_Count_BI__c);  
		      	System.Debug('CSABA 3.10 CurrentCcount = ' + countu + ' CurrMonthDuration = ' +  CurrMonthDuration);
		 
		      	if (countu == NULL)
		        	ABs[0].Activity_Count_BI__c = CurrMonthDuration;  //2013.09.13 IDuration;
		      	else
		        	ABs[0].Activity_Count_BI__c = countu + CurrMonthDuration;  //2013.09.16. IDuration; 
		       	//UPDATE Activity_Count_BI__c ********************************    
                System.Debug('CSABA 3.11 CurrentCcount = ' + ABs[0].Activity_Count_BI__c);
       
		      	//2013.05.27. ********** update Activity_count_Daily_BI__c *********************
		
		      	String TakenDayList = ABs[0].CallSubmitDaysList__c;
		      	if(TakenDayList == NULL)   
		        	TakenDayList = '';
		      
		      	if(TakenDayList.contains(';' + CallDateDAY + ';'))
		        	system.debug('we already incremented the counter for day ' + CallDateDAY);    
		        else if(TakenDayList.startsWith(CallDateDAY + ';'))
		        	system.debug('we already incremented the counter for day ' + CallDateDAY);   	
		      	else
		      	{
		      		system.Debug('CSABA: first recorded coaching for day  ' + CallDateDAY + '. Increment  counter');    
		      		Decimal CurrentACDaily = ABs[0].Activity_count_Daily_BI__c;  
		      		
			      	if(CurrentACDaily == NULL)
			      	   //ABs[0].Activity_count_Daily_BI__c = 1;
			      	   ABs[0].Activity_count_Daily_BI__c = CurrMonthDuration;
			      	else
			      	   //ABs[0].Activity_count_Daily_BI__c = CurrentACDaily + 1;   //
			      	   ABs[0].Activity_count_Daily_BI__c = CurrentACDaily + CurrMonthDuration;
		      
			      	//add the CallDateDAY  to the 	TakenDayList
			      	TakenDayList = TakenDayList + CallDateDAY + ';';
			      	ABs[0].CallSubmitdaysList__c = TakenDayList;        	
			  	}
		      	//2013.05.27. ********** update Activity_count_Daily_BI__c *********************     
		      	
		      	system.Debug('CSABA 3.12 Updating AB = ' + ABs[0]);
      			update ABs[0];       	
      		}
      		
      		
 		    //2013.09.16.handle here the overflow
		    if(b_isOverflow == true)  	
		    {
		    System.Debug('CSABA Overflow: Year = ' + NextYear + ' Month = ' + NextMonth + ' User = ' +  UserId);	
	      	ABs = [ select 	id, Activity_Count_BI__c,
		      				Coaching_Activity_Count_BI__c,
		                    Details_in_Period_BI__c,
		                    Name, 
		                    Comment__c, 
		                    Quarter_BI__c, 
		                    LastModifiedDate,
		                    Activity_count_Daily_BI__c,  
		                    CallSubmitdaysList__c        
		            from 	Activity_Benchmark_BI__c
		            where 	User_BI__c = :UserId
		            and		Year_of_Activity_BI__c = :NextYear    
		            and 	Month_BI__c = :NextMonth 
		         ];		
		                                        
		    if (ABs.size() == 0)
			    {
			      	//create new record
			      	VEEVA_HLP_WorkingDay MyWD = new VEEVA_HLP_WorkingDay();
			      	integer WD = MyWD.GetWorkingDay(Country_Codu,NextYear,NextMonth);
			            
			      	Activity_Benchmark_BI__c ABM = new Activity_Benchmark_BI__c();
			      	ABM.User_BI__c = UserId;
			      	ABM.Month_BI__c = NextMonth;
			      	ABM.Quarter_BI__c =  'Quarter ' + String.valueOf(NextQuater);
			      	ABM.Year_of_Activity_BI__c = NextYear;        
			      	ABM.Working_Days_in_Period_BI__c = WD;
			      	ABM.Activity_Count_BI__c = NextMonthDuration; //2013.09.16. IDuration; 
			      	ABM.Activity_count_Daily_BI__c = 1;  //2013.09.17.
			      
			      	//in case of overflow  this is the first day ABM.CallSubmitdaysList__c = CallDateDAY + ';'; 
			      	ABM.CallSubmitdaysList__c = '01;';  
			               
			      	insert ABM;			    	
			    } 
			    else
			    {
					system.Debug('We already have a record  Month: ' + NextMonth + ' Eary: ' + NextYear + ' userID: ' + UserId + ' ID= ' + ABs[0].id);                                 
    
	     
			      	//UPDATE Activity_Count_BI__c ******************************** 
			      	Integer countu =  Integer.valueof(ABs[0].Activity_Count_BI__c);  
			      	System.Debug('CSABA 3.31 CurrentCcount = ' + countu + ' CurrMonthDuration = ' +  NextMonthDuration);
			 
			      	if (countu == NULL)
			        	ABs[0].Activity_Count_BI__c = NextMonthDuration;  //2013.09.13 IDuration;
			      	else
			        	ABs[0].Activity_Count_BI__c = countu + NextMonthDuration;  //2013.09.16. IDuration; 
			       	//UPDATE Activity_Count_BI__c ********************************    
	                System.Debug('CSABA 3.32 CurrentCcount = ' + ABs[0].Activity_Count_BI__c);
	       
			      	//2013.05.27. ********** update Activity_count_Daily_BI__c *********************
			
			      	String TakenDayList = ABs[0].CallSubmitDaysList__c;
			      	if(TakenDayList == NULL)   
			        	TakenDayList = '';
			      
			      	if(TakenDayList.contains(';01;'))
			        	system.debug('we already incremented the counter for day 01');    
			        else if(TakenDayList.startsWith('01;'))
			        	system.debug('we already incremented the counter for day ' + CallDateDAY);   	
			      	else
			      	{
			      		system.Debug('CSABA: first recorded coaching for day  01. Increment  counter');       
			      		Decimal CurrentACDaily = ABs[0].Activity_count_Daily_BI__c;  
			      		
				      	if(CurrentACDaily == NULL)
				      	   ABs[0].Activity_count_Daily_BI__c = 1;
				      	else
				      	   ABs[0].Activity_count_Daily_BI__c = CurrentACDaily + 1; 
			      
				      	//add the CallDateDAY  to the 	TakenDayList
				      	TakenDayList = TakenDayList + '01;';
				      	ABs[0].CallSubmitdaysList__c = TakenDayList;        	
				  	}
			      	//2013.05.27. ********** update Activity_count_Daily_BI__c *********************     
			      	
			      	system.Debug('CSABA 3.33 We are updating AB =' +  ABs[0]);
	      			update ABs[0];			    	
				    }
		                                                                              	
		    }
		      	
		    //2013.09.16. handle here the overflow     		
      		
		}//end of for
			
		
	}
	
	global void finish(Database.BatchableContext BC)
	{
		VEEVA_BI_ABM_CALL_BATCH b = new VEEVA_BI_ABM_CALL_BATCH(); 
		database.executebatch(b,10); 
	}

}