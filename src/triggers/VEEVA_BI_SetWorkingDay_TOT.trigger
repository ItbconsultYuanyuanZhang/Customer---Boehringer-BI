trigger VEEVA_BI_SetWorkingDay_TOT on Time_Off_Territory_vod__c (before insert, before update, before delete) 
{
    
    if (trigger.isDelete)
        return;
        
    //2013.06.07.    
    if (trigger.new[0].Reason_vod__c == 'Field Coaching')
        return;
    //2013.06.07.           
        
    if (trigger.new[0].Status_vod__c <> 'Approved')  
        return;  
        
   
      
    String theYear = '';  
       
    Date datum = trigger.new[0].Date_vod__c;
    String sdatum = String.valueOf(datum);
    
    String[] sds = sdatum.split('-');
    for (String s :sds)
    {
        if (s.length() == 4)
        {
            theYear = s;
            break;
        }
    } 
     
       
    ID  UserID = NULL; 
    if (UserId == NULL)
        UserID = trigger.new[0].OwnerId;  
       
    if (UserId == null)
       return;

       
    User Useru = [Select Name, Country_Code_BI__c from User where id = :UserID limit 1];
    
      
    if (Useru.Country_Code_BI__c == NULL)
        return;
      

     //now identify the proper Working_Day_BI__c record  
     String WD_Name = Useru.Country_Code_BI__c + '_' + theYear; 
     Working_Day_BI__c[] WDs = [Select Id, Name from Working_Day_BI__c
                                where Name = :WD_Name
                                and Country_Code_BI__c = :Useru.Country_Code_BI__c
                                ]; 
     
     if (WDs == NULL)
         return;
        
      if (WDs.size() <> 1)  
         return; 
         
      trigger.new[0].Working_Day_BI__c = WDs[0].id;    
     
     
     //2012.10.30.  David Stuff
     
     //do not allow  TOT  which overflow the current month
      Integer IYear = datum.year();
      Integer Imonth = datum.month();
      Integer Quoter = Imonth / 3;
      //Quoter = Quoter + 1;
      
       //2013.06.07. correct quoter calculation
       Integer Remainder = math.mod(Imonth,3);
       if(Remainder > 0)
         Quoter = Quoter + 1;        
       
      VEEVA_HLP_UserTOT myTOT = new VEEVA_HLP_UserTOT();
      
      Decimal overflow = myTOT.checkOverflow(datum, trigger.new[0].Time_vod__c, trigger.new[0].Hours_vod__c);
 
 
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
      

  
     Decimal NewHours = trigger.new[0].Hours_vod__c;
     Decimal  TOTDiff = NewHours - overflow; 
     
     //ID userID,Integer IYear,String currentMonth, String countryCode, Integer Quoter, Decimal TOTDiff
     myTOT.SetActivityBenchmark(userID, IYear, currentMonth,Useru.Country_Code_BI__c,Quoter,TOTDiff,false);  
     
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
     }
       
     myTOT.SetActivityBenchmark(userID, IYear, ms[Imonth],Useru.Country_Code_BI__c,Quoter,overflow,false); 
     }
       
     
            
}