/**************************************************
*Veeva batch update apex class
*
* Updates all without change to trigger triggers 
* 
* 
*TO RUN enter in dev console: 
	TEST_BI_batch_call_update batch = new TEST_BI_batch_call_update();
	Id batchId = Database.executeBatch(batch, 10);
*
*LastModifiedDate: 18.04.2013
*LastModifiedBy: Viktor
***************************************************/

global class TEST_BI_batch_call_update implements Database.Batchable<sObject> {
  global TEST_BI_batch_call_update() {

  }
 
  global Database.QueryLocator start(Database.BatchableContext BC){
 
 
    return Database.getQueryLocator([select id from Call2_vod__c limit 50]);   
 
  }
 
  global void execute(Database.BatchableContext BC, List<sObject> scope){   
 	
    //Just update the records.  That's all folks!
    update scope;
 
     }
 
  global void finish(Database.BatchableContext BC){
 
      System.debug('Batch Process Complete');
 
  }
 
}