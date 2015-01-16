global class DELETE_TARGET_ACCOUNT implements Database.Batchable<SObject>, Database.Stateful{
  global String query;
  global String filter;
   
  global DELETE_TARGET_ACCOUNT(){
  }
  global Database.QueryLocator start(Database.BatchableContext BC){
    if(query == null || query == '') {
      query = 'SELECT Id ' +
              'FROM Target_Account_BI__c where Portfolio_BI__c = \'a3FJ00000009e7X\' ';
      }
      if(filter != null) query += filter;
    return Database.getQueryLocator(query);
   }
  global void execute(Database.BatchableContext BC, list<Target_Account_BI__c> list_targetDetail){
    list<Target_Account_BI__c> list_total = new list<Target_Account_BI__c>();
    for(Target_Account_BI__c td: list_targetDetail){
        list_total.add(td);      
    }  
    if(!list_total.isEmpty()){
      delete list_total;
    }
  }
     global void finish(Database.BatchableContext BC){    
   }
}