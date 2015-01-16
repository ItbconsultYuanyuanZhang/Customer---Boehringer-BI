/********************************************************************************************
class used to fix errors  in CALL  ABM  batch.  The  code  fill a new filed on ABM oject to
store the good  value  for CALL  count
********************************************************************************************/
global without sharing class VEEVA_ABM_CALL_CORRECTION implements Database.batchable<sObject>
{

    String theYear;
    String theMonth;
    Integer theIMonth;
     
    public VEEVA_ABM_CALL_CORRECTION()        
    {
     
    
    }
    
    public VEEVA_ABM_CALL_CORRECTION(String theY, Integer theIM)        
    {
     this.theYear = theY;
     this.theIMonth = theIM;
     
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
    
    this.theMonth = ms[theIM - 1];
    System.Debug('Month = ' + this.theMonth);
    }    


global Database.QueryLocator start(Database.BatchableContext BC)   
    {
        
        String SelStmt = 'SELECT ID,Month_BI__c, Year_of_Activity_BI__c, User_BI__c, User_Country_BI__c, CallSubmitdaysList__c, Activity_count_Daily_BI__c,Repair_Helper_BI__c ';
        SelStmt = selStmt + ' FROM Activity_Benchmark_BI__c ';
        SelStmt = SelStmt + 'where Year_of_Activity_BI__c = \'' + this.theYear + '\'  and Month_BI__c = \'' + this.theMonth + '\'';
        //selStmt = selStmt + ' and User_BI__c= \'00590000001ChJJAA0\' '; 
        selStmt = SelStmt + ' order by User_BI__c ';  //redundant
        SelStmt = SelStmt + ' Limit 5000000 ';
        
        System.Debug('SQLU = ' + selStmt);
        
        return Database.getQueryLocator(selStmt);          
        
    }
    
    
global void execute(Database.BatchableContext BC, List<sObject> batch)  
{
        
        List<Activity_Benchmark_BI__c> ABMs = (List<Activity_Benchmark_BI__c>) batch;
        
        Set<ID> OwnerIDs = new Set<ID>();
        
        for(Activity_Benchmark_BI__c ABM :ABMs)
        {
            OwnerIDs.add(ABM.User_BI__c);
        }
        System.Debug('CSABA Owners = ' + OwnerIds.size());
    
         Integer Yeru = Integer.ValueOf(this.theYear);
         //Integer Montu = Integer.ValueOf(this.theMonth);
         Date Dstart = date.newInstance(Yeru,this.theIMonth,01);
         Date Dend = Dstart.addMonths(1);
        
         AggregateResult[] groupedCalls  = [SELECT Call_Date_vod__c, ownerid, count(ID) nrofcalls  
                                           FROM Call2_vod__c
                                           where ownerid in :OwnerIDs
                                           and Status_vod__c = 'Submitted_vod' and Parent_Call_vod__c = null
                                           //and Call_Date_vod__c = LAST_MONTH  
                                           and Call_Date_vod__c >= :Dstart 
                                           and Call_Date_vod__c < :Dend
                                           GROUP BY ownerid, Call_Date_vod__c
                                           order by ownerid
                                           ];


Map<ID,Integer> mapu = new Map<ID,Integer>(); 

Integer counteru = 0; 
ID  currentOwner = NULL; 
ID  prevOwner = NULL;                                     
for (AggregateResult ar : groupedCalls)  
    {
        
     currentOwner = (ID)ar.get('ownerid');  
     System.Debug('CSABA:  CurrentOwneru ' + currentOwner + ' prevOwner ' + prevOwner + ' counteru = ' +  counteru + ' Mapsize = ' + mapu.size());
     if(prevOwner == NULL || currentOwner == prevOwner)
        {
            counteru = counteru + 1;
        }
     else
        {
             counteru = 1;
        }   
     prevOwner = currentOwner;
     mapu.put(prevOwner,counteru);

    }
//now we have to call counter /  User lets  update ABM
List<Activity_Benchmark_BI__c> ABM_2Update = new List<Activity_Benchmark_BI__c>();
for (Activity_Benchmark_BI__c ABM :ABMs)
    {
    decimal currentCounter = ABM.Activity_count_Daily_BI__c;
    decimal calculatedCount = mapu.get(ABM.User_BI__c); 
    //if(currentCounter != calculatedCount)
    //   {
       System.Debug('useru = ' + ABM.User_BI__c + 'ABM Id = ' + ABM.ID + '  CC = ' +  currentCounter + ' RC = ' + calculatedCount);   
       ABM.Activity_count_Daily_BI__c = calculatedCount;
       ABM.Repair_Helper_BI__c = calculatedCount;
       ABM_2Update.add(ABM);
    //   }
    }   

if(ABM_2Update.size() > 0)
   update ABM_2Update;
        
}   
    
    
global void finish(Database.BatchableContext BC)
    {
        
    }   

}