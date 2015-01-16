/***************************************************************
This  trigger jsut  starts the Batch  job  by calling an utility
class  method 
***************************************************************/
trigger ExecuteOneKeyBatch on V2OK_Batch_Job__c (after insert) 
{  
	String ProcessName 	= trigger.new[0].Process_Name__c;
	String Country		= trigger.new[0].OK_Country__c;
	if (Country == null) 	VEEVA_BATCH_ONEKEY_BATCHUTILS.execute(Trigger.newMap.keySet(), ProcessName);
	else  					VEEVA_BATCH_ONEKEY_BATCHUTILS.execute(Trigger.newMap.keySet(), ProcessName, Country);
}