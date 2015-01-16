trigger VEEVA_BI_CoachingReport on Coaching_Report_vod__c (before insert, before update) 
{



	DateTime datum = trigger.new[0].Review_Date__c; 
	String Duration = trigger.new[0].Coaching_Duration_BI__c;
	
	string CallDateDAY = string.valueOf(datum.day());
	
	Integer IDuration = 0;
	if (Duration == 'AM' || Duration == 'PM')
		IDuration = 1;
	else
		IDuration = 2;
		
    if (Duration == 'Two Days')
       IDuration = 4;


	
    Integer IYear = datum.year();
    Integer Imonth = datum.month();
    Integer Quoter = Imonth / 3;
    //Quoter = Quoter + 1;
    
    //2013.06.07. correct quoter calculation
    Integer Remainder = math.mod(Imonth,3);
    if(Remainder > 0)
      Quoter = Quoter + 1;    
      
       
    String theYear = String.valueOf(IYear);
	
	ID  UserID = NULL;
	if (UserId == NULL)
		UserID = trigger.new[0].CreatedById;
		
	
	   
	if (UserId == null)
	{
	   UserID = trigger.new[0].Manager_vod__c;  
	   //return;
	}
	
	
	   	   
	User Useru = [Select Name, Country_Code_BI__c from User where id = :UserID limit 1];
		       
	if (Useru.Country_Code_BI__c == NULL)
	    return;
	
    

	string Country_Codu = '';	    
	Country_Codu = Useru.Country_Code_BI__c; 
		
     String WD_Name = Useru.Country_Code_BI__c + '_' + theYear; 
     Working_Day_BI__c[] WDs = [Select Id, Name from Working_Day_BI__c
                                where 
                                Name = :WD_Name
                                and Country_Code_BI__c = :Useru.Country_Code_BI__c
                                ]; 
     
     if (WDs == NULL)    	
       	 return;
      
      if (WDs.size() == 0)
       	 return;      	
 
      if (WDs.size() > 1)  
        return;  
        
	         
       
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
                   
      String currentMonth = ms[Imonth - 1]; 	

      //identify the right Activity_Benchmark_BI__c  record  and increment the Activity_Count_BI__c
      Activity_Benchmark_BI__c[] ABs = [Select id, Activity_Count_BI__c,Coaching_Activity_Count_BI__c,
                                        Details_in_Period_BI__c,
                                        Name, Comment__c, Quarter_BI__c, LastModifiedDate
                                        ,Activity_count_Daily_BI__c   //new request from David 2013.05.27.
                                        ,CallSubmitdaysList__c        //new request from David 2013.06.07.
                                        from Activity_Benchmark_BI__c
                                        where 
                                        User_BI__c = :UserId
                                        and
                                        Year_of_Activity_BI__c = :theYear    
                                        and 
                                        Month_BI__c = :currentMonth
                                        ];
                                        
      system.Debug('Monmth: ' + currentMonth + ' Eary: ' + theYear + ' userID: ' + UserId + ' ID= ' + ABs[0].id);                                 
       

      if (ABs.size() == 0)
      {
      	    	   	
      //create new record
      VEEVA_HLP_WorkingDay MyWD = new VEEVA_HLP_WorkingDay();
      Integer WD = MyWD.GetWorkingDay(Country_Codu,theYear,currentMonth);
            
      Activity_Benchmark_BI__c ABM = new Activity_Benchmark_BI__c();
      ABM.User_BI__c = UserId;
      ABM.Month_BI__c = currentMonth;
      ABM.Quarter_BI__c =  'Quarter ' + String.valueOf(Quoter);
      ABM.Year_of_Activity_BI__c = theYear;        
      ABM.Working_Days_in_Period_BI__c = WD;
      ABM.Activity_Count_BI__c = IDuration; 
      //ASK DAVID   ABM.Coaching_Activity_Count_BI__c = 1;
      
      ABM.CallSubmitdaysList__c = CallDateDAY + ';';   
               
      insert ABM;  
      
      return;        
      }
      
      if (ABs.size() == 1)
      {
       system.Debug('We already have a record  Month: ' + currentMonth + ' Eary: ' + theYear + ' userID: ' + UserId + ' ID= ' + ABs[0].id);                                 
       //return;      
     
      //UPDATE Activity_Count_BI__c ******************************** 
      Integer countu =  Integer.valueof(ABs[0].Activity_Count_BI__c);  
 
      if (countu == NULL)
          ABs[0].Activity_Count_BI__c = IDuration;
      else
          ABs[0].Activity_Count_BI__c = countu + IDuration; 
       //UPDATE Activity_Count_BI__c ********************************    
       
       
      //2013.05.27. ********** update Activity_count_Daily_BI__c *********************

      String TakenDayList = ABs[0].CallSubmitdaysList__c;
      if(TakenDayList == NULL)   
         TakenDayList = '';
      
      if(TakenDayList.contains(CallDateDAY + ';'))
         system.debug('we already incremented the counter for day ' + CallDateDAY);     	
      else
      {
      	System.Debug('CSABA: first recorded coaching for day  ' + CallDateDAY + '. Increment  counter');    
      	Decimal CurrentACDaily = ABs[0].Activity_count_Daily_BI__c;  
      	if(CurrentACDaily == NULL)
      	   ABs[0].Activity_count_Daily_BI__c = 1;
      	else
      	   ABs[0].Activity_count_Daily_BI__c = CurrentACDaily + 1; 
      
      //add the CallDateDAY  to the 	TakenDayList
      TakenDayList = TakenDayList + CallDateDAY + ';';
      ABs[0].CallSubmitdaysList__c = TakenDayList;        	
      }
      //2013.05.27. ********** update Activity_count_Daily_BI__c *********************          	

      update ABs[0];       	
      }
      
      	
}