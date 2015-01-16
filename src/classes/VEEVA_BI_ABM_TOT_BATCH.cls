global without sharing class VEEVA_BI_ABM_TOT_BATCH implements Database.batchable<sObject>
{
    
    public Map<Id,string> mapUserCountries;  //2013.09.10.
    List<String> Ms;                         //2013.09.10.
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string selStmt = '';
        
        selStmt = 'SELECT ID, Reason_vod__c, OwnerID, Status_vod__c, Date_vod__c, Time_vod__c,isdeleted, Hours_vod__c FROM Time_Off_Territory_vod__c ';
        selStmt = selStmt + ' WHERE Status_vod__c in (\'Approved\',\'SUBMITTED\') ';  
        selStmt = selStmt + ' AND Reason_vod__c <> \'Field Coaching\'  and Time_vod__c != NULL ';   
        selStmt = selStmt + ' AND LastModifiedDate <= yesterday  '  ;
        //USE FOR GO LIVE MOMENTUM ONLY selStmt = selStmt + ' AND LastModifiedDate <= yesterday';
        //selStmt = selStmt + ' AND LastModifiedDate >= 2013-09-18T00:00:00.000Z';  
        //selStmt = selStmt + 'and id in (\'a02J000000CDZCkIAP\',\'a02J000000CDYvNIAX\',\'a02J000000CDYR6IAP\')';
        //PUT it Back  selStmt = selStmt + ' AND LastModifiedDate >= today';  //CSABA 2013.09.12.  put it back
        //selStmt = selStmt + ' and OwnerID = \'005J00000010W0Q\' ';  
        selStmt = selStmt + ' limit 5000000  ';
        //PUT IT BACK  selStmt = selStmt + ' ALL ROWS';  
        
        System.Debug('SQLu = ' + selStmt);
        
        return Database.getQueryLocator(selStmt);   
    }
    
    
    //constructor *****************
    public VEEVA_BI_ABM_TOT_BATCH()    
    {
        
        
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> batch)
    {


        List<Time_Off_Territory_vod__c> TotRecords = (List<Time_Off_Territory_vod__c>) batch;   
        system.Debug('TOT Batch size = ' + TotRecords.size());  
        
        mapUserCountries = new Map<Id,String>();
            
        Ms = new List<String>
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
        
        /******************* 2013.09.10.take this out from the Loop **************************************/
        List<Time_Off_Territory_vod__c> DeletedTOTs = new List<Time_Off_Territory_vod__c>();  //2013.09.10.
        
                    
            Set<ID> UserIDs = new set<ID>();
            
            for(Time_Off_Territory_vod__c TOT :TotRecords)
                UserIDs.add(TOT.OwnerId);
                
            System.Debug('UserID size = ' + UserIDs.size());    
                  
            User[] Us = [Select id, Name, Country_Code_BI__c from User where id in :UserIDs];
            System.Debug('User record size = ' + Us.size());
            
            for(User U :Us)
            {
                system.debug('UserName: ' + U.Name + '  Country = ' + U.Country_Code_BI__c);
                mapUserCountries.put(U.id,U.Country_Code_BI__c);
            }
                                
        /******************* 2013.09.10.take this out from the Loop ***********************************/  
        
        
        integer batchSize = batch.size();
        
        
        for(integer i=0; i<batchSize; i++)  
        {
            /********  2013.09.10. **********/
            if(TotRecords[i].isdeleted == true)
            {
                System.Debug('CSABA Record ID ' + TotRecords[i].id + ' was deleted. TOT need adjustment');    
                DeletedTOTs.add(TotRecords[i]);
                continue;
            }
            /********  2013.09.10. **********/
           
            
            if(TotRecords[i].Time_vod__c == NULL)
            continue;  //CSABA  avoid  crash in case  integration missed this field
            
            String theYear = '';  
       
            List<Activity_Benchmark_BI__c> ABM_toCreate = new List<Activity_Benchmark_BI__c>();
            List<Activity_Benchmark_BI__c> ABM_toUpdate = new List<Activity_Benchmark_BI__c>();
    
         
            //get the first User just to retrieve the country   
            ID  UserID = NULL; 
          
            if (UserID == NULL)
               UserID = TotRecords[i].OwnerId;    
        
            if (UserID == null)
               continue;
               
            //take it out from the For loop User Useru = [Select Name, Country_Code_BI__c from User where id = :UserID limit 1];
            
            //take it out from loop if (Useru.Country_Code_BI__c == NULL)
            //    continue;
        
            //take it out from loop String CurrentCountry = Useru.Country_Code_BI__c;
            //get the first User just to retrieve the country 
            
            String CurrentCountry = mapUserCountries.get(UserID);   //CSABA 2013.09.10.  
            if(CurrentCountry == NULL)
               continue;
            else
               System.Debug('CSABA Currentcountry: ' + CurrentCountry);   
            
            Date datum = TotRecords[i].Date_vod__c;

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
         
            System.Debug('CSABA1 Datum: ' +  datum + ' Quoter =' + Quoter  + ' Year = ' +  IYear + ' UserId: ' + UserID);                   
       
            VEEVA_HLP_UserTOT myTOT = new VEEVA_HLP_UserTOT();
      
            //check if the TOt overflap 2 months (max period is 5 days)
            Decimal overflow = myTOT.checkOverflow(datum, TotRecords[i].Time_vod__c, TotRecords[i].Hours_vod__c);
            system.Debug('CSABA2 datum: ' + datum + ' Time =' + TotRecords[i].Time_vod__c + ' hours = ' + TotRecords[i].Hours_vod__c + ' overflow = ' + overflow + ' Useru: ' + TotRecords[i].OwnerId);
                   
            String currentMonth = ms[Imonth - 1];                           
      
            Decimal NewHours = TotRecords[i].Hours_vod__c;
            Decimal  TOTDiff = NewHours - overflow; 
     
            //ID userID,Integer IYear,String currentMonth, String countryCode, Integer Quoter, Decimal TOTDiff
            Activity_Benchmark_BI__c ABM_item = myTOT.SetActivityBenchmark(TotRecords[i].OwnerId, IYear, currentMonth,CurrentCountry,Quoter,TOTDiff,true);  
     
            if(ABM_item == NULL)
               continue;  //2013.09.20.    
     
            if(ABM_item.id  == NULL)
            {
                ABM_toCreate.add(ABM_item);
                system.debug('CSABA3.1 We are inserting  ABM: ' + ABM_item.TOT_in_Period_BI__c   + ' for user: ' + ABM_item.User_BI__c + ' month: ' + ABM_item.Month_BI__c);
                insert ABM_item;
            }
            else
            {
                ABM_toUpdate.add(ABM_item);
                system.debug('CSABA3.2 We are updating  ABM: ' + ABM_item.TOT_in_Period_BI__c);
                update ABM_item;
            }
            
            
            //set the ABM  for the next months becaue overflow
            if (overflow > 0)
            {
                if(Imonth + 1 > 12)
                {
                    Quoter = 1;
                    Imonth = 0;        //CSABA added  2013.09.11. to avoid exception 
                    IYear = IYear + 1; //CSABA 2013.09.11
                }
                else  
                {
                    Quoter = (Imonth+1) / 3;
                    
                    Remainder = math.mod(Imonth+1,3);
                    if(Remainder > 0)
                        Quoter = Quoter + 1;        
                }//end of inner ifelse
               
                Activity_Benchmark_BI__c ABM_item1 = myTOT.SetActivityBenchmark(TotRecords[i].OwnerId, IYear, ms[Imonth],CurrentCountry,Quoter,overflow,true); 
                if(ABM_item1.id  == NULL)
                {
                    ABM_toCreate.add(ABM_item1);
                    system.debug('CSABA4 Overflow: We are inserting  ABM: ' + ABM_item1.TOT_in_Period_BI__c   + ' for user: ' + ABM_item.User_BI__c + ' month: ' + ABM_item.Month_BI__c);
                    insert ABM_item1;
                }
                else
                {
                    ABM_toUpdate.add(ABM_item1);
                    system.debug('CSABA4 Overflow: We are updating  ABM: ' + ABM_item1.TOT_in_Period_BI__c);
                    update ABM_item1; 
                } 
                
            }//end of if overflow
            
            
            
        }//end of for
        
        //Csaba call Delete handler
        if(DeletedTOTs != NULL)
           HandleDeletion(DeletedTOTs);  
        else
           system.Debug('CSABA no deleted  TOTs.');   
        
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        VEEVA_BI_ABM_COACHING_BATCH b = new VEEVA_BI_ABM_COACHING_BATCH(); 
        database.executebatch(b,10); 
    }
    
    
    /**************************************************************
    
    
    **************************************************************/
    global void  HandleDeletion(Time_Off_Territory_vod__c[] DelTOTs)
    {
        if(DelTOTs == NULL)
           return;
           
        System.Debug('Deleted TOTs = ' + DelTOTs.size());

        
        for(Time_Off_Territory_vod__c TOT :DelTOTs)
        {
            Date datum = TOT.Date_vod__c;

            String theYear = String.Valueof(datum.year());   
       
            Integer IYear = datum.year();
            Integer Imonth = datum.month();
            Integer Quoter = Imonth / 3;
      
            Integer Remainder = math.mod(Imonth,3); 
            if(Remainder > 0)
                Quoter = Quoter + 1;    
                
            VEEVA_HLP_UserTOT myTOT = new VEEVA_HLP_UserTOT();
      
            //check if the TOt overflap 2 months (max period is 5 days)
            Decimal overflow = myTOT.checkOverflow(datum, TOT.Time_vod__c, TOT.Hours_vod__c);  
            
            system.debug('Date = ' + datum + ' TOT_time = ' + TOT.Time_vod__c + ' TOT_Hours = ' + TOT.Hours_vod__c +  'OverFlow = ' + overflow);            
 
            String currentMonth = ms[Imonth - 1];                        
      
            Decimal NewHours = TOT.Hours_vod__c;  
            Decimal  TOTDiff = NewHours - overflow;  
            
            ID UserId = TOT.ownerId;
            
            Decimal  TOTu;
            
            Activity_Benchmark_BI__c[] ABs;

               ABs = [Select id, TOT_in_Period_BI__c  
                                        from Activity_Benchmark_BI__c
                                        where 
                                        User_BI__c = :UserId   
                                        and
                                        Year_of_Activity_BI__c = :String.valueof(IYear)  
                                        and 
                                        Month_BI__c = :currentMonth
                                        ];
                
               if(ABs.size() == 1)
               {                         
               TOTu = ABs[0].TOT_in_Period_BI__c; 
               Decimal Oldtot = TOTu;  
               TOTu = TOTu - TOTdiff;
               ABs[0].TOT_in_Period_BI__c = TOTu;
               System.Debug('CSABA Updating AB record ' + ABs[0].id + ' from OLD = ' + oldtot + ' to ' + TOTu + ' for month '+ currentMonth);
               update ABs[0];
               }
               else
               {
               system.Debug('CSABA Nothing to Delete/adjust for current month');  
               }                      

            
            if(overflow > 0)
            {    
                Integer OverflowYear = IYear; 
                if(Imonth == 12)
                {
                   OverflowYear = OverflowYear + 1;
                   Imonth = 0;  
                }
                 
                ABs = [Select id, TOT_in_Period_BI__c  
                                        from Activity_Benchmark_BI__c
                                        where 
                                        User_BI__c = :UserId
                                        and
                                        Year_of_Activity_BI__c = :String.valueOf(OverflowYear)  
                                        and 
                                        (Month_BI__c = :ms[Imonth])
                                        ];
                                        
               if(ABs.size() == 1)   
               {                         
               TOTu = ABs[0].TOT_in_Period_BI__c; 
               Decimal oldTot = TOTu;
               TOTu = TOTu - overflow;
               ABs[0].TOT_in_Period_BI__c = TOTu;
               System.Debug('CSABA updating AB record ID = ' + ABs[0].id + ' from oldTOT = ' + oldTot + ' to ' + TOTu +  ' for month ' +  ms[Imonth]);
               update ABs[0];
               }
               else
               System.Debug('CSABA nothing to delete/adjust for overflown month');    
                
            }  
            


            
                        
        }
        
    }

}