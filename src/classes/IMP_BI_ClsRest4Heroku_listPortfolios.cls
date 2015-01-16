@RestResource(urlMapping='/listPortfolios/v1/*')
global with sharing class IMP_BI_ClsRest4Heroku_listPortfolios {
	@HttpGet
	global static Response doGet(){
		Response r = new Response();
        try {  
            RestRequest req = RestContext.request;
            //Id mId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            String portfolioIds = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            set<String> set_ids = new set<String>();
            for(String portfolioId : portfolioIds.split(',')){
            	if(portfolioId != '') set_ids.add(portfolioId);
            }
            r.outputPortfolios = new list<Portfolio_BI__c>();
            for(Portfolio_BI__c portfolio: [select  Id, Name, Country_Code_BI__c from Portfolio_BI__c where id in: set_ids ]) {
				r.outputPortfolios.add(portfolio);
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
        public list<Portfolio_BI__c> outputPortfolios;
        public Response() {
            success = true;
            message = '';
        }
   }
}