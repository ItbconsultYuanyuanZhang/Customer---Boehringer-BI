/***********************************************************************************
Trigger assumes that the bulk operation affects only users  for the same country!!!
***********************************************************************************/
trigger VEEVA_BI_BulkTOT on Time_Off_Territory_vod__c (before insert, before update) 
{

    if (trigger.isDelete)
        return;
        
        
    //2013.06.07.    
    if (trigger.new[0].Reason_vod__c == 'Field Coaching')
        return;
    //2013.06.07.           
    
    //2013.07.17 Viktor included submitted status by Levi's request    
    if (trigger.new[0].Status_vod__c <> 'Approved' || trigger.new[0].Status_vod__c <> 'SUBMITTED' )  
        return;  
        
   
      
    String theYear = '';  
       

    List<Activity_Benchmark_BI__c> ABM_toCreate = new List<Activity_Benchmark_BI__c>();
    List<Activity_Benchmark_BI__c> ABM_toUpdate = new List<Activity_Benchmark_BI__c>();
    
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
    
        
    //get the first User just to retrieve the country   
    ID  UserID = NULL; 
    
    for(Integer i = 0; i < trigger.new.size(); i++)
    {
    if (UserId == NULL)
        UserID = trigger.new[i].OwnerId;  
       
    if (UserId == null)
       continue;        
    }

    if (UserId == null)
       return;
       
    User Useru = [Select Name, Country_Code_BI__c from User where id = :UserID limit 1];
    
    if (Useru.Country_Code_BI__c == NULL)
        return;

    String CurrentCountry = Useru.Country_Code_BI__c;
    //get the first User just to retrieve the country 
    

     /*****************************************************************************************************
     set<String> countryYear = new set<String>();
     for(Integer j = 0; j < trigger.new.size(); j++)
     {
      Date datum = trigger.new[j].Date_vod__c;

      theYear = String.Valueof(datum.year()); 
      
      countryYear.add(CurrentCountry + '_' + theYear);
     }    

     //now identify the proper Working_Day_BI__c records 
     String WD_Name = CurrentCountry + '_' + theYear; 

     Working_Day_BI__c[] WDs = [Select Id, Name from Working_Day_BI__c
                                where Name in :countryYear
                                and Country_Code_BI__c = :CurrentCountry
                                ]; 
     
     if (WDs == NULL)
         return;
        
     if (WDs.size() == 0)  
         return;
         
      //now try to macyth the TOt recotrd with its corresponding WDs
      //for(Integer j = 0; j < trigger.new.size(); j++)
      //{
      //    String currentYearu = String.Valueof(trigger.new[j].Date_vod__c.year());
      //    currentYearu = CurrentCountry + '_' + currentYearu;
      //    for(Working_Day_BI__c WD :WDs)
      //    {
      //    if(WD.Name == currentYearu) 
      //       trigger.new[j].Working_Day_BI__c = WD.id;       
      //    }
      //}   
      //trigger.new[0].Working_Day_BI__c = WDs[0].id;    
      ************************************************************************************************/  

     for(Integer j = 0; j < trigger.new.size(); j++)
     {
      Date datum = trigger.new[j].Date_vod__c;


      theYear = String.Valueof(datum.year());   
       
       //do not allow  TOT  which overflow the current month
      Integer IYear = datum.year();
      Integer Imonth = datum.month();
      Integer Quoter = Imonth / 3;
      //Quoter = Quoter + 1;
      
       //2013.06.07. correct quoter calculation
       Integer Remainder = math.mod(Imonth,3);
       if(Remainder > 0)
         Quoter = Quoter + 1; 
         
      System.Debug('CSABA1 Datum: ' +  datum + ' Quoter =' + Quoter);                   
       
      VEEVA_HLP_UserTOT myTOT = new VEEVA_HLP_UserTOT();
      
      //check if the TOt overflap 2 months (max period is 5 days)
      Decimal overflow = myTOT.checkOverflow(datum, trigger.new[j].Time_vod__c, trigger.new[j].Hours_vod__c);
      system.Debug('CSABA2 datum: ' + datum + ' Time =' + trigger.new[j].Time_vod__c + ' hours = ' + trigger.new[j].Hours_vod__c);
                   
      String currentMonth = ms[Imonth - 1];                           
      
      Decimal NewHours = trigger.new[j].Hours_vod__c;
      Decimal  TOTDiff = NewHours - overflow; 
     
      //ID userID,Integer IYear,String currentMonth, String countryCode, Integer Quoter, Decimal TOTDiff
      Activity_Benchmark_BI__c ABM_item = myTOT.SetActivityBenchmark(trigger.new[j].OwnerId, IYear, currentMonth,CurrentCountry,Quoter,TOTDiff,true);  
     
      if(ABM_item.id  == NULL)
      {
        ABM_toCreate.add(ABM_item);
        System.debug('CSABA3 We are inserting  ABM: ' + ABM_item.TOT_in_Period_BI__c);
        insert ABM_item;
      }
      else
      {
        ABM_toUpdate.add(ABM_item);
        System.debug('CSABA3 We are updating  ABM: ' + ABM_item.TOT_in_Period_BI__c);
        update ABM_item;
      }
      
      
      //set the ABM  for the next months becaue overflow
      if (overflow > 0)
      {
          if(Imonth + 1 > 12)
             Quoter = 1;
          else  
          {
           Quoter = (Imonth+1) / 3;
           
           Remainder = math.mod(Imonth+1,3);
           if(Remainder > 0)
              Quoter = Quoter + 1;        
          }//end of inner ifelse
           
         Activity_Benchmark_BI__c ABM_item1 = myTOT.SetActivityBenchmark(trigger.new[j].OwnerId, IYear, ms[Imonth],CurrentCountry,Quoter,overflow,true); 
          if(ABM_item1.id  == NULL)
          {
            ABM_toCreate.add(ABM_item1);
            System.debug('CSABA4 Overflow: We are inserting  ABM: ' + ABM_item1.TOT_in_Period_BI__c);
            insert ABM_item1;
          }
          else
          {
            ABM_toUpdate.add(ABM_item1);
            System.debug('CSABA4 Overflow: We are updating  ABM: ' + ABM_item1.TOT_in_Period_BI__c);
            update ABM_item1; 
          } 
            
     }//end of if overflow            
        
     }//end of for
     
  

}