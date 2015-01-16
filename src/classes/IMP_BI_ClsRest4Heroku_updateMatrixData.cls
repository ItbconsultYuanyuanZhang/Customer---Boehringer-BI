@RestResource(urlMapping='/updateMatrixData/v1/*')
global with sharing class IMP_BI_ClsRest4Heroku_updateMatrixData { 

    @HttpGet
    global static Response doGet() {	
        Response r = new Response();
        try {  
            RestRequest req = RestContext.request;
            //RestResponse res = Restcontext.response;
            Id mId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            r = IMP_BI_ClsRest4HerokuUtil.getMatrixCalculationData(mId);	
            //set<Id> set_matrixIds = new set<Id>();
            //set_matrixIds.add(mId);
            //r = ClsRest4HerokuUtil.getMatrixCalculationData(set_matrixIds);
            
        }	
        catch(exception e) {
            r.success = false;
            r.message = e.getMessage();
        }
        return r;
    }
    
    @HttpPost
    global static Response doPost(Matrix_BI__c inputMT, list<Matrix_Cell_BI__c> inputMC){
        Response r = new Response();
        try {
        	update inputMT;
            update inputMC;
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
        
        public IMP_BI_ClsRest4Heroku crh;
        public Matrix_BI__c outputMT;
        public list<Matrix_Cell_BI__c> outputMC;
        
        public Response() {
            success = true;
            message = '';
        }
   }
}