/******************************************

******************************************/
public with sharing class VEEVA_HLP_UserTOT 
{
    public Integer TotalTOT = 0;
    private String errMsg = '';
    
    public VEEVA_HLP_UserTOT()
    {
        
    }


    /**********************************************
    
    
    public Integer GetTOT(ID UserIDu, Date thedate)
    {
        Integer yearu = thedate.year();
        Integer monthu = thedate.month();
        
        Date nextMonth = Datetime.newInstance(yearu,monthu + 1,0).date();
          
        
        Time_Off_Territory_vod__c[] TOTs = [Select ID, Date_vod__c,Hours_vod__c,Hours_off_vod__c,Start_Time_vod__c,Time_vod__c  
                                            from Time_Off_Territory_vod__c
                                            where OwnerId = :UserIDu
                                            and Date_vod__c < :nextMonth  
                                           ];  
    
        
       for (Time_Off_Territory_vod__c TOTu : TOTs)
       {
        Integer hours = GetRealTOT(TOTu.Date_vod__c,thedate, TOTu.Hours_vod__c ); 
        this.TotalTOT = this.TotalTOT + hours;
       }                                       
                                           
      return -1;                                       
        
    }
    **********************************************/
    
    /*****************************************************************************
    

    private Integer GetRealTOT(Date TOTdate, Date currentDate, Decimal TOTHours)
    {
        
        Datetime TOTStartDatetime = (Datetime)TOTdate;
        system.Debug('datetime: ' + TOTStartDatetime);  

        Datetime TOTendDatetime = TOTStartDatetime.addHours(Integer.valueof(TOTHours));     
        system.Debug('datetime: ' + TOTendDatetime);
        
        
        Datetime CurrentMonthDateTime = (Datetime)currentDate;
        
        Datetime NextMonthDateTime = CurrentMonthDateTime.addMonths(1);
        
        //if the TOTendDatetime  is earlier then the currentDate return 0;
        Integer endMonth = TOTendDatetime.month();
        Integer endYear = TOTendDatetime.year();
        
        Integer currentMonth = CurrentMonthDateTime.month();
        Integer currentyear = CurrentMonthDateTime.year();
        
        if (endYear < currentyear)
        return 0;
        
        if (endYear == currentyear && endMonth < currentMonth)
        return 0;
        
        
        
        
        if (TOTStartDatetime.month() == TOTendDatetime.month())
            return  Integer.valueOf(TOTHours);
         else
            return getDiffHours(TOTStartDatetime,NextMonthDateTime);
        

        
        return 0;
    }
    
    private Integer getDiffHours(Datetime startTime, Datetime nextmonth)
    {
        
        //reset the days to 0
        Integer Yearu = nextmonth.year();
        Integer Monthu = nextmonth.month();
        
        Datetime BeginningofNextMonth = Datetime.newInstance(Yearu, Monthu, 0);
        
        Long StartH = startTime.getTime();
        Long EndH = BeginningofNextMonth.getTime();
        
        Long Res = endH - StartH;
        
        return 0;
    }
        *****************************************************************************/
    
    
    
    
    /********************************************************************************************
    check if the current time  plus TOT period  is in the same month 2012.11.02
    
    public Boolean isSameMonth(Date currentDate, String TOTType, Decimal Hours, String StartTime)
    {
        
        if (TOTType == 'AM' || TOTType == 'PM' || TOTType == 'All Day')
            return true;
        
        if (TOTType.contains('Days') == true)
        {
            Integer TOTDays = Integer.valueOf(Hours / 8);
            
            Date enddate = currentdate.addDays(TOTDays-1);
            Integer CurrentMonth = currentDate.month();
            Integer CurrentYear = currentDate.year();
            
            Integer TOTEndMonth = enddate.month(); 
            Integer TOTendYear = enddate.year();
            
            if (CurrentYear != TOTendYear || (CurrentYear == TOTendYear && CurrentMonth != TOTEndMonth))
            { 
                this.errMsg = 'TOT period overflow the Month.';
                return false;
            }
            else        
                return true;
        }
        else
            return true;
    }
    ********************************************************************************************/
    
    /****************************************************************************
    
    ****************************************************************************/
    public decimal checkOverflow(Date currentDate, String TOTType, Decimal Hours)
    {
        
        if (TOTType == 'AM' || TOTType == 'PM' || TOTType == 'All Day')
            return 0;
            
       if (TOTType.contains('Days') == true)
       {
            Integer TOTDays = Integer.valueOf(Hours / 8);
            
            Date enddate = currentdate.addDays(TOTDays-1);      
            
            Integer TOTEndMonth = enddate.month(); 
            Integer TOTendYear = enddate.year(); 
            
            Integer CurrentMonth = currentDate.month();
            Integer CurrentYear = currentDate.year();
            
            if (CurrentYear != TOTendYear || (CurrentYear == TOTendYear && CurrentMonth != TOTEndMonth))
            {
              return  enddate.day() * 8;    
            }
            else
              return 0;
       }
       else
         return  0;
    }
    
    /********************************************************************************************************************************
    
    ********************************************************************************************************************************/
    public Activity_Benchmark_BI__c SetActivityBenchmark(ID userID,Integer IYear,String currentMonth, String countryCode, Integer Quoter, Decimal TOTDiff, boolean isBulk)   
    {
      System.Debug('CSABA: SetActivityBenchmark UserId = ' + userid + ' Year =' + IYear + ' Month =' + currentMonth + ' Qoater = ' + Quoter + ' TOTDiff = ' + TOTDiff );	
    	
      //identify the right Activity_Benchmark_BI__c  record  and increment the Activity_Count_BI__c
      Activity_Benchmark_BI__c[] ABs = [Select id, TOT_in_Period_BI__c  
                                        from Activity_Benchmark_BI__c
                                        where 
                                        User_BI__c = :UserId
                                        and
                                        Year_of_Activity_BI__c = :String.valueof(IYear)  
                                        and 
                                        Month_BI__c = :currentMonth
                                        ]; 
      if (ABs.size() == 0) 
          {
          //create new record
          VEEVA_HLP_WorkingDay MyWD = new VEEVA_HLP_WorkingDay();
          Integer WD = MyWD.GetWorkingDay(countryCode,String.valueof(IYear),currentMonth);
          
          Activity_Benchmark_BI__c ABM = new Activity_Benchmark_BI__c();
          ABM.User_BI__c = UserId;
          ABM.OwnerId = UserId;  //2013.09.17.
          ABM.Month_BI__c = currentMonth;
          ABM.Quarter_BI__c = 'Quarter ' + String.valueOf(Quoter);  
          ABM.Year_of_Activity_BI__c = String.valueOf(IYear);   
          
          ABM.TOT_in_Period_BI__c = TOTDiff;
          ABM.Working_Days_in_Period_BI__c = WD;
       
          if(isBulk ==  false)
             insert ABM;  
          
          return ABM;       
          }
  
      if (ABs.size() <> 1)
         return null; 
       
      if (ABs.size() == 1) 
         {
         	
         if (ABs[0].TOT_in_Period_BI__c == NULL)
            ABs[0].TOT_in_Period_BI__c = TOTDiff;
         else
         {
         	System.Debug('CSABA TOT BEFORE ' + ABs[0].TOT_in_Period_BI__c);
            ABs[0].TOT_in_Period_BI__c = ABs[0].TOT_in_Period_BI__c + TOTDiff; 
            System.Debug('CSABA TOT AFTER ' + ABs[0].TOT_in_Period_BI__c);  
         }
            
         if(isBulk == false)   
         update ABs[0]; 
         
         return ABs[0];    
         } 
         
         return null;         
    }    

}