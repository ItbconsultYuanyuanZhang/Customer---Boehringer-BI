global class DELETE_TARGET_DETAIL implements Database.Batchable<SObject>, Database.Stateful{
  global String query;
  global String filter;
   
  global DELETE_TARGET_DETAIL(){
  }
  global Database.QueryLocator start(Database.BatchableContext BC){
    if(query == null || query == '') {
      query = 'SELECT Account_BI__c, CreatedById, CreatedDate, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, Portfolio_BI__c, Product_Catalog_BI__c, Id, Segment_BI__c, Strategic_Brand_Weight_BI__c, SystemModstamp, Target_Account_BI__c, Name, Target_Details_BI__c, Version_BI__c, Version_Comparison_BI__c,Portfolio_BI__r.Version_BI__c ' +
              'FROM Target_Detail_BI__c where Portfolio_BI__c = \'a3FJ00000009dvR\' ';
      }
      if(filter != null) query += filter;
    return Database.getQueryLocator(query);
   }
  global void execute(Database.BatchableContext BC, list<Target_Detail_BI__c> list_targetDetail){
    list<Target_Detail_BI__c> list_total = new list<Target_Detail_BI__c>();
    for(Target_Detail_BI__c td: list_targetDetail){
        list_total.add(td);      
    }  
    if(!list_total.isEmpty()){
      delete list_total;
    }
  }
     global void finish(Database.BatchableContext BC){    
   }
}