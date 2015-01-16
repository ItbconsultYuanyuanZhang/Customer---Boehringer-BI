/**
 * 
 @changelog
 * 2015-01-08 Peng Zhu <peng.zhu@itbconsult.com>
 * - Modified: added 3 new fields in Matrix Query --  Account_Matrix_BI__c, Account_Matrix_Split_BI__c, Scenario_BI__c
 */

@RestResource(urlMapping='/listMatrixs/v1/*')
global with sharing class IMP_BI_ClsRest4Heroku_listMatrixs {
	@HttpGet
	global static Response doGet(){
		Response r = new Response();
        try {  
            RestRequest req = RestContext.request;
            Id mId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            //Peng Zhu 2013-10-14
            for(Matrix_BI__c m: [select  Id, Account_Matrix_BI__c, Account_Matrix_Split_BI__c, Scenario_BI__c, Name, Name_BI__c, Cycle_BI__c, Product_Catalog_BI__c, Row_BI__c, Column_BI__c, Specialization_BI__c from Matrix_BI__c where id =: mId ]) {
				r.outputMatrix = m;
			}
        }	
        catch(exception e) {
            r.success = false;
            r.message = e.getMessage();
        }
        return r;
	}
	global class Response{		
        public boolean success;
        public string message;
        public Matrix_BI__c outputMatrix;
        public Response() {
            success = true;
            message = '';
        }
   }
}