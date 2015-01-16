/**
 *
 @changelog
 * 2015-01-08 Peng Zhu <peng.zhu@itbconsult.com>
 * - Modified: added some new fields in cycle data query -- Selected_BI__c, Current_Scenario_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c
 */
@RestResource(urlMapping='/UpdateCycleData/v1/*')
global with sharing class IMP_BI_ClsRest4Heroku_updateCycleData {
	
	
	@HttpGet 
	global static Response doGet() {
		Response r = new Response();
		RestRequest req = RestContext.request;
        Id cycleId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        system.debug('@@@###:cycleId: ' + cycleId);
		r.list_data = [select id, name, Selected_BI__c, Current_Scenario_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, Account_BI__c, Account_BI__r.isPersonAccount, Product_Catalog_BI__c, Intimacy_BI__c, Matrix_Cell_BI__c, Potential_BI__c, Segment_BI__c, Cycle_BI__c from Cycle_Data_BI__c  where Cycle_BI__c =: cycleId order by name limit 10000];
		r.dataSize = r.list_data.size();
		return r;
	}
	  
	
	/*  
	@HttpGet   	
	global static Response doGet() {
		Response r = new Response();
		Matrix__c matrix;
		RestRequest req = RestContext.request;
		Id mId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
		for(Matrix__c m: [select id, name, Cycle__c, Product__c, Row__c, Column__c, Dimension_1_Name__c, Dimension_2_Name__c, Specialization__c, Product_Lifecyle__c, CycleDataTotal__c, CycleDataQuantity__c, Status__c from Matrix__c where id =: mId]) {
			matrix = m;
		}
		r.list_data = [select id, name,  Product__c, Cycle__c from Cycle_Data__c where Product__c=:matrix.Product__c and Cycle__c=:matrix.Cycle__c  order by name limit 10];
		//r.list_data = [select name from Cycle_Data__c where Product__c=:matrix.Product__c and Cycle__c=:matrix.Cycle__c  order by name limit 10];
		r.dataSize = r.list_data.size();
		return r;
	}
	*/
	
   @HttpPost
    global static Response doPost(string inputString, list<Cycle_Data_BI__c> inputData){
    	Response r = new Response();
    	try {
			r.message += inputString + '|';
			r.message += 'record count: ' + string.valueOf(inputData.size());
			update inputData;
    	}
    	catch(exception e) {
    		r.success = false;
    		r.message = e.getMessage();
    	}
        return r;
   }
   
	global class Response{
		boolean success;
		string message;
		list<Cycle_Data_BI__c> list_data;
		integer dataSize;
		
		
		public Response() {
			success = true;
			message = '';
			list_data = new list<Cycle_Data_BI__c>();
			dataSize = 0;
		}
   }
}