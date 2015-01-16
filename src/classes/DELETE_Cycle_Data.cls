global class DELETE_Cycle_Data implements Database.Batchable<SObject>, Database.Stateful{
  global String query;
  global String filter;
   
  global DELETE_Cycle_Data(){
  }
  global Database.QueryLocator start(Database.BatchableContext BC){
    if(query == null || query == '') {
      query = 'SELECT Id ' +
              'FROM Cycle_Data_BI__c where Cycle_BI__c = \'a39J00000004FGg\' ';
      }
      if(filter != null) query += filter;
    return Database.getQueryLocator(query);
   }
  global void execute(Database.BatchableContext BC, list<Cycle_Data_BI__c> list_targetDetail){
    list<Cycle_Data_BI__c> list_total = new list<Cycle_Data_BI__c>();
    for(Cycle_Data_BI__c td: list_targetDetail){
        list_total.add(td);      
    }  
    if(!list_total.isEmpty()){
      delete list_total;
    }
  }
     global void finish(Database.BatchableContext BC){    
   }
}