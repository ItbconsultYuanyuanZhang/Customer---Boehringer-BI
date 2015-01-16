/**
 *
 @changelog
 * 2015-01-08 Peng Zhu <peng.zhu@itbconsult.com>
 * - Modified: 1. added some new fields in cycle data query -- Selected_BI__c, Current_Scenario_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c
 * 			   2. when ntl, only query the "selected" cycle data
 */
@RestResource(urlMapping='/readCycleDatas/v1/*')
global with sharing class IMP_BI_ClsRest4Heroku_readCycleDatas {
	@HttpGet
	global static Response doGet(){
		Response r = new Response();
        try {  
            RestRequest req = RestContext.request;
            //Id mId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            String ids = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            String cycleId;
            String cycleDataId;
            String productId;
            String specialities;
            String matrixIds;
            String gettype;
            set<Id> set_matrixIds = new set<Id>();
            set<String> set_specialities = new set<String>();
            String[] array_ids = ids.split('itb');
        	cycleId = ids.split('itb')[0];
            cycleDataId = ids.split('itb')[1];
            productId = ids.split('itb')[2];
            specialities = ids.split('itb')[3];
	        matrixIds = ids.split('itb')[4];
	        gettype = ids.split('itb')[5];
	        
	        if(specialities != null && specialities != ''){
		        for(String s : specialities.split(';')){
		        	if(s != '') set_specialities.add(s);
		        }	
	        }
	        if(matrixIds != null && matrixIds != ''){
	        	for(String matrixId : matrixIds.split(';')){
		        	if(matrixId != '') set_matrixIds.add(matrixId);
		        }
	        }
	        
	        r.cycledatas = new list<Cycle_Data_BI__c>();
	        
            if(gettype == 'ntl'){
            	if(cycleDataId != null && cycleDataId != ''){
		            for(Cycle_Data_BI__c c: [select  id, Account_BI__r.isPersonAccount, Selected_BI__c, Current_Scenario_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c, matrix_bi__c, call_bi__c, face_to_face_bi__c, account_bi__c, adoption_market_share_calc_bi__c, column_bi__c, cycle_bi__c, intimacy_bi__c, matrix_cell_bi__c, potential_bi__c, product_catalog_bi__c, row_bi__c, type_bi__c, calculation_bi__c from Cycle_Data_BI__c where Selected_BI__c = TRUE AND matrix_bi__c in: set_matrixIds and id >: cycleDataId order by id asc  limit 10000 ]) {
						r.cycledatas.add(c);
						r.cycledataid = c.Id;
					}		
            	}
            	else{
            		for(Cycle_Data_BI__c c: [select  id, Account_BI__r.isPersonAccount, Selected_BI__c, Current_Scenario_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c, matrix_bi__c, call_bi__c, face_to_face_bi__c, account_bi__c, adoption_market_share_calc_bi__c, column_bi__c, cycle_bi__c, intimacy_bi__c, matrix_cell_bi__c, potential_bi__c, product_catalog_bi__c, row_bi__c, type_bi__c, calculation_bi__c from Cycle_Data_BI__c where Selected_BI__c = TRUE AND matrix_bi__c in: set_matrixIds order by id asc  limit 10000]) {
						r.cycledatas.add(c);
						r.cycledataid = c.Id;
					}
            	}
            }
            else if(gettype == 'matrix'){
            	if(cycleDataId != null && cycleDataId != ''){
	            	for(Cycle_Data_BI__c c: [select  id, Account_BI__r.isPersonAccount, Selected_BI__c, Current_Scenario_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c, matrix_bi__c, call_bi__c, face_to_face_bi__c, account_bi__c, adoption_market_share_calc_bi__c, column_bi__c, cycle_bi__c, intimacy_bi__c, matrix_cell_bi__c, potential_bi__c, product_catalog_bi__c, row_bi__c, type_bi__c, calculation_bi__c from Cycle_Data_BI__c where cycle_bi__c =: cycleId and Specialty_BI__c in: set_specialities and id >: cycleDataId order by id asc  limit 10000]) {
						r.cycledatas.add(c);
						r.cycledataid = c.Id;
					}	
            	}
            	else{
            		for(Cycle_Data_BI__c c: [select  id, Account_BI__r.isPersonAccount, Selected_BI__c, Current_Scenario_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c, matrix_bi__c, call_bi__c, face_to_face_bi__c, account_bi__c, adoption_market_share_calc_bi__c, column_bi__c, cycle_bi__c, intimacy_bi__c, matrix_cell_bi__c, potential_bi__c, product_catalog_bi__c, row_bi__c, type_bi__c, calculation_bi__c from Cycle_Data_BI__c where cycle_bi__c =: cycleId and Specialty_BI__c in: set_specialities order by id asc  limit 10000]) {
						r.cycledatas.add(c);
						r.cycledataid = c.Id;
					}
            	}
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
        public list<Cycle_Data_BI__c> cycledatas;
        public Id cycledataid;
        public Response() {
            success = true;
            message = '';
        }
   }
}