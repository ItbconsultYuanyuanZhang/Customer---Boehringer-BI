/****************************************************************************
Get the call date  and identify the Working_Day_BI__c record corresponding 
to the user's country and pass it to the Working_Day_BI__c look-up field.
****************************************************************************/
trigger VEEVA_BI_SetWorkingDay on Call2_vod__c (before insert, before update) 
{
    
    Date datum = trigger.new[0].Call_Date_vod__c;
    String sdatum = String.valueOf(datum);
    
    string CallDateDAY = string.valueOf(datum.day());
    
    String theYear = ''; 
    String theMonth = '';
    
    string Country_Codu = '';
    
    String[] sds = sdatum.split('-');
    for (String s :sds)
    {
        if (s.length() == 4)
        {
            theYear = s;
            break;
        }
    } 
    
    //DateTime datetimele = trigger.new[0].Call_Datetime_vod__c;     
    //String sdatetimele = String.valueOf(datetimele);  
    
       
    ID  UserID = NULL; //trigger.new[0].User_vod__c;
    if (UserId == NULL)
        UserID = trigger.new[0].OwnerId; 
       
    if (UserId == null)
       return;
       //trigger.new[0].addError('No User ifentified');
      
       
    User Useru = [Select Name, Country_Code_BI__c from User where id = :UserID limit 1];
    
      
    if (Useru.Country_Code_BI__c == NULL)
    {
        //trigger.new[0].addError('No User Country code');
        return;
    }

       
    Country_Codu = Useru.Country_Code_BI__c;   
      

     String WD_Name = Useru.Country_Code_BI__c + '_' + theYear; 
     System.debug('CSABA: country identified: ' + Country_Codu + ' WorkDayName: ' + WD_Name); 
     Working_Day_BI__c[] WDs = [Select Id, Name from Working_Day_BI__c
                                where 
                                Name = :WD_Name
                                and Country_Code_BI__c = :Useru.Country_Code_BI__c
                                ]; 
     
     if (WDs == NULL)
        {
            System.Debug('CSABA: Missing WD  record');
         //trigger.new[0].addError('Missing WD  record');  
         return;
        }
      
      if (WDs.size() == 0)
      {  
         System.debug('CSABA: Missing WD  record');
         //trigger.new[0].addError('Missing WD  record');  
         return;        
      }
 
      if (WDs.size() > 1)  
      {
        system.Debug('CSABA: Multiple WD record');
        //trigger.new[0].addError('Multiple WD record');
        return;  
      }
       
      
      system.Debug('CSABA: Working day record identified for ' +  WD_Name + ' and User: ' + Useru.Country_Code_BI__c);  
           
       //2012.11.08.  NO LONGER NEEDED trigger.new[0].Working_Day_BI__c = WDs[0].id;
       
       
       //2012.10.30.  New stuff for David
       if (trigger.isInsert == true)
       {
          system.debug('This is a Insert. Do nothing');
          return;
       }  
        
       
       if (trigger.new[0].Status_vod__c <> 'Submitted_vod')
       {
           system.debug('CSABA: This is not a submitted call. Do nothing');
           return;
       }
       
       Integer IYear = datum.year();
       Integer Imonth = datum.month();
       Integer Quoter = Imonth / 3;
       //Quoter = Quoter + 1;
       
       //2013.06.07. correct quoter calculation"
       Integer Remainder = math.mod(Imonth,3);
       if(Remainder > 0)
          Quoter = Quoter + 1;
       
       
       theYear = String.valueOf(IYear);
       
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
                   
      String currentCallMonth = ms[Imonth - 1];             
        
      //identify the right Activity_Benchmark_BI__c  record  and increment the Activity_Count_BI__c
      Activity_Benchmark_BI__c[] ABs = [Select id, Activity_Count_BI__c,Coaching_Activity_Count_BI__c,
                                        Details_in_Period_BI__c,
                                        Name, Comment__c, Quarter_BI__c, LastModifiedDate,
                                        Activity_count_Daily_BI__c   //new request from David 2013.05.27.
                                        ,CallSubmitdaysList__c       //new request from David 2013.06.07.
                                        from Activity_Benchmark_BI__c
                                        where 
                                        User_BI__c = :UserId
                                        and
                                        Year_of_Activity_BI__c = :String.valueOf(IYear)    
                                        and 
                                        Month_BI__c = :currentCallMonth
                                        ]; 
                                        
      Decimal ProdDetailCount = trigger.new[0].of_Details_BI__c;
      
      
      System.debug('CSABA: Detected  Activity Benchmark reovcrd size = ' + ABs.size());
                                        
      if (ABs.size() == 0)
      {
      system.debug('Create new Act_Benchmark  record for UserID: ' + UserId + ' month: ' + currentCallMonth);
      VEEVA_HLP_WorkingDay MyWD = new VEEVA_HLP_WorkingDay();
      Integer WD = MyWD.GetWorkingDay(Country_Codu,theYear,currentCallMonth);
            
      Activity_Benchmark_BI__c ABM = new Activity_Benchmark_BI__c();
      ABM.User_BI__c = UserId;
      ABM.Month_BI__c = currentCallMonth;
      ABM.Quarter_BI__c =  'Quarter ' + String.valueOf(Quoter);
      ABM.Year_of_Activity_BI__c = String.valueof(IYear);        
      ABM.Working_Days_in_Period_BI__c = WD;
      ABM.Activity_Count_BI__c = 1; 
      ABM.Coaching_Activity_Count_BI__c = 1;
      ABM.Details_in_Period_BI__c = ProdDetailCount; 
      ABM.Activity_count_Daily_BI__c = 1;  //2013.05.27.
      //2013.06.07.
      ABM.CallSubmitdaysList__c = CallDateDAY + ';'; 
       
      system.Debug('CSABA: We are going to insert ABM  record');          
      insert ABM;  
      
      return;        
      }
        
      if (ABs.size() == 1)
      { 
      //detect double trigger on call *******
      Datetime LMT = ABs[0].LastModifiedDate;
      Datetime nowu = System.now();        
      LMT = LMT.addSeconds(5);      
      if (LMT > nowu )
      {
      System.debug('Csaba:  double trigger detection. Return.');    
      return;
      }
      //detect double trigger on call *******
        
      system.debug('CSABA: sizu: ' + String.valueOf(ABs.size()) + '  yearu: ' + String.valueOf(IYear) + '  month: ' + currentCallMonth +  '. Quarter ' + String.valueOf(Quoter)); 
      
      ABs[0].Quarter_BI__c =  'Quarter ' + String.valueOf(Quoter); 
      
      //UPDATE Activity_Count_BI__c ******************************** 
      Integer countu =  Integer.valueof(ABs[0].Activity_Count_BI__c);  
      if (countu == NULL)
          ABs[0].Activity_Count_BI__c = 1;
      else
          ABs[0].Activity_Count_BI__c = countu + 1; 
       //UPDATE Activity_Count_BI__c ******************************** 
       
      //UPDATE Coaching_Activity_Count_BI__c **********************  
      if (trigger.new[0].Coaching_BI__c == true)       
      {  
      Decimal CoachingCount = ABs[0].Coaching_Activity_Count_BI__c;   
      if (CoachingCount == NULL)
         ABs[0].Coaching_Activity_Count_BI__c = 1;
      else
         ABS[0].Coaching_Activity_Count_BI__c = CoachingCount + 1;   
      }       
      //UPDATE Coaching_Activity_Count_BI__c **********************  
      
      //UPDATE Details_in_Period_BI__c  *******************************************
      Decimal CurrentProddetcount = ABs[0].Details_in_Period_BI__c;
      if (CurrentProddetcount == NULL)
         ABs[0].Details_in_Period_BI__c = ProdDetailCount; 
      else
         ABs[0].Details_in_Period_BI__c = CurrentProddetcount + ProdDetailCount;   
      //UPDATE Details_in_Period_BI__c  *******************************************   
      
      
      //2013.05.27. ********** update Activity_count_Daily_BI__c *********************
      String TakenDayList = ABs[0].CallSubmitdaysList__c;
      if(TakenDayList == NULL)   
         TakenDayList = '';
      
      if(TakenDayList.contains(CallDateDAY + ';'))
      {
         system.debug('we already incremented the counter for day ' + CallDateDAY);         
      }
      else
      {
        System.Debug('CSABA: first submitted call for day  ' + CallDateDAY + '. Increment  counter');    
        Decimal CurrentACDaily = ABs[0].Activity_count_Daily_BI__c;  
        if(CurrentACDaily == NULL)
           ABs[0].Activity_count_Daily_BI__c = 1;
        else
           ABs[0].Activity_count_Daily_BI__c = CurrentACDaily + 1; 
      
      //add the CallDateDAY  to the     TakenDayList
      TakenDayList = TakenDayList + CallDateDAY + ';';
      ABs[0].CallSubmitdaysList__c = TakenDayList;          
      }

      /******************* LOGIC OVERRULED WITH ABOVE 2013.06.07. *********************
      if(ABs[0].LastModifiedDate.Date() != System.Date.today())  
      {
        System.Debug('CSABA: first call for today.  Increment  counter');    
        Decimal CurrentACDaily = ABs[0].Activity_count_Daily_BI__c;  
        if(CurrentACDaily == NULL)
           ABs[0].Activity_count_Daily_BI__c = 1;
        else
           ABs[0].Activity_count_Daily_BI__c = CurrentACDaily + 1;
      }
      else
        system.debug('we already have call today. Ignore Daily counter');
      ******************* LOGIC OVERRULED WITH ABOVE 2013.06.07. *********************/  
        
      //2013.05.27. ********** update Activity_count_Daily_BI__c *********************   
        
      system.debug('Update Act_Benchmark  record ' + ABs[0] + ' for UserID: ' +UserId +  ' month: ' + currentCallMonth);          
      update ABs[0]; 
      }  
}