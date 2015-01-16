global without sharing class VEEVA_BI_ABM_CALL_BATCH implements Database.batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC)   
    {
        string selStmt = '';
        
        selStmt = 'SELECT ID, Call_Date_vod__c, OwnerID, Of_Details_BI__c, Coaching_BI__c FROM Call2_vod__c ';
        selStmt = selStmt + ' WHERE Status_vod__c = \'Submitted_vod\' and Parent_Call_vod__c = null '  ; 
        selStmt = selStmt + ' AND LastModifiedDate = yesterday  '  ;  //2013.09.18.
        //selStmt = selStmt + ' AND LastModifiedDate != today  '  ;
        //selstmt = selstmt + ' and OwnerID = \'005J00000010y4X\' ';  
        //selStmt = selStmt + ' AND Call_Date_vod__c >= 2013-07-01  '  ;     
        //selStmt = selStmt + ' AND Call_Date_vod__c <= 2013-09-21  '  ;   
        //selStmt = selStmt + ' AND LastModifiedDate != today  '  ;    
        selStmt = selStmt + ' limit 5000000  ';      
        //selStmt = selStmt + ' AND OwnerID = \'005J0000001FXUs\'  '  ;    
        
        //selStmt = selStmt + ' AND ID in (\'a1DJ00000001uWKMAY\',\'a1DJ00000001uWPMAY\')';       
        
        System.Debug('SQLu = ' + selStmt);
        
        return Database.getQueryLocator(selStmt);     
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> batch)  
    {
        List<Call2_vod__c> CallRecords = (List<Call2_vod__c>) batch;
        
        
        integer batchSize = batch.size();
        system.Debug('Batch size = ' + batchsize);  
        
        for(integer i=0; i<batchSize; i++)
        {
            
            Date datum = CallRecords[i].Call_Date_vod__c;
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
                    continue;
                }
            }
            
        
            //get user information
            ID  UserID = NULL; 
            
            if (UserId == NULL)
                UserID = CallRecords[i].OwnerId; 
            if (UserID == NULL)
               continue;
               //trigger.new[0].addError('No User ifentified');
               
            User Useru = [select Name, Country_Code_BI__c from User where ID = :UserID limit 1];
              
            if (Useru.Country_Code_BI__c == NULL)
            {
                //trigger.new[0].addError('No User Country code');
                System.Debug('No country code for User: ' + Useru.Name);
                continue;
            }
        
            //get country code
            Country_Codu = Useru.Country_Code_BI__c;   
      
            String WD_Name = Useru.Country_Code_BI__c + '_' + theYear; 
            System.debug('CSABA: country identified: ' + Country_Codu + ' WorkDayName: ' + WD_Name); 
            Working_Day_BI__c[] WDs = [ select  ID, Name 
                                        from    Working_Day_BI__c
                                        where   Name = :WD_Name
                                        and     Country_Code_BI__c = :Useru.Country_Code_BI__c ]; 
            
            if (WDs == NULL)
            {
                System.Debug('CSABA: Missing WD  record');
                //trigger.new[0].addError('Missing WD  record');  
                continue;
            }
      
            if (WDs.size() == 0)
            {  
                System.debug('CSABA: Missing WD  record');
                //trigger.new[0].addError('Missing WD  record');  
                continue;       
            }
     
            if (WDs.size() > 1)  
            {
                system.Debug('CSABA: Multiple WD record');
                //trigger.new[0].addError('Multiple WD record');
                continue;  
            }
           
            system.Debug('CSABA: Working day record identified for ' +  WD_Name + ' and User: ' + Useru.Country_Code_BI__c);  
            
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
            Activity_Benchmark_BI__c[] ABs = [  select  id, 
                                                        Activity_Count_BI__c, 
                                                        Coaching_Activity_Count_BI__c,
                                                        Details_in_Period_BI__c,
                                                        Name, 
                                                        Comment__c, 
                                                        Quarter_BI__c, 
                                                        LastModifiedDate,
                                                        Activity_count_Daily_BI__c,   //new request from David 2013.05.27.
                                                        CallSubmitdaysList__c       //new request from David 2013.06.07.
                                                from    Activity_Benchmark_BI__c
                                                where   User_BI__c = :UserId
                                                and     Year_of_Activity_BI__c = :String.valueOf(IYear)    
                                                and     Month_BI__c = :currentCallMonth ]; 
                                        
            Decimal ProdDetailCount = CallRecords[i].of_Details_BI__c;
            
            System.debug('CSABA: Detected  Activity Benchmark reovcrd size = ' + ABs.size());
                                        
            if (ABs.size() == 0)
            {

                VEEVA_HLP_WorkingDay MyWD = new VEEVA_HLP_WorkingDay();
                Integer WD = MyWD.GetWorkingDay(Country_Codu,theYear,currentCallMonth);
                
                 system.debug('CSABA.2.10 Create new Act_Benchmark  record for UserID: ' +UserId +  
                              ' month: ' + currentCallMonth +  ' CallDay = ' +  CallDateDAY + ' WD = ' + WD + ' ProdDetailCount = ' +  ProdDetailCount);
                                    
                Activity_Benchmark_BI__c ABM = new Activity_Benchmark_BI__c();
                ABM.User_BI__c = UserId;
                ABM.OwnerId = UserId;
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
              
                //continue;        
          }
          
          if (ABs.size() == 1)
          { 
            
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
              if (CallRecords[i].Coaching_BI__c == true)       
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
              
                 //add the CallDateDAY  to the  TakenDayList
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
            

        }//end of for
        
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
}