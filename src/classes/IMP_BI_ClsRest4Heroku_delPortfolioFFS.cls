@RestResource(urlMapping='/delPortfolioFFS/v1/*')
global with sharing class IMP_BI_ClsRest4Heroku_delPortfolioFFS {
	@HttpGet
	global static Response doGet(){
		Response r = new Response();
        try {  
            RestRequest req = RestContext.request;
            
            String ids = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            String portfolioId;
            Integer version;
            
            String[] array_ids = ids.split('itb');
        	portfolioId = ids.split('itb')[0];
            version = Integer.valueOf(ids.split('itb')[1]);
				
			if(portfolioId != null && portfolioId.trim() != ''){
				list<Portfolio_Field_Force_Simulation_BI__c> list_pffs = [SELECT Id, Portfolio_BI__c
																			FROM Portfolio_Field_Force_Simulation_BI__c 
																		   WHERE Portfolio_BI__c = :portfolioId AND Portfolio_BI__r.Version_BI__c = :version
																		   LIMIT 5000];
																		   
				if(list_pffs != null && !list_pffs.isEmpty()){
					r.delSize = list_pffs.size();
					delete list_pffs;
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
        public integer delSize;
        
        public Response() {
            success = true;
            message = '';
            delSize = 0;
        }
   }
}