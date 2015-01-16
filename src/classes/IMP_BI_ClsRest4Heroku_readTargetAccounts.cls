@RestResource(urlMapping='/readTargetAccounts/v1/*')
global with sharing class IMP_BI_ClsRest4Heroku_readTargetAccounts {
	@HttpGet
	global static Response doGet(){
		Response r = new Response();
        try {  
            RestRequest req = RestContext.request;
            //Id mId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            String ids = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            String portfolioId;
            String targetaccountid;
            Integer version;
            String[] array_ids = ids.split('itb');
        	portfolioId = ids.split('itb')[0];
            targetaccountid = ids.split('itb')[1];
            version = Integer.valueOf(ids.split('itb')[2]);
	        
	        r.targetaccounts = new list<Target_Account_bi__c>();
				
        	if(targetaccountid != null && targetaccountid != ''){
            	for(Target_Account_bi__c ta : [select Id, Account_BI__c, FTEs_BI__c, Is_Included_BI__c, NTL_Rank_BI__c, NTL_Value_BI__c, Portfolio_BI__c, Target_Calls_BI__c, Version_BI__c From Target_Account_bi__c where Portfolio_BI__c =: portfolioId  and version_bi__c =: version and id >: targetaccountid order by id asc limit 10000]) {
					r.targetaccounts.add(ta);
					r.targetaccountid = ta.Id;
				}	
        	}
        	else{
        		for(Target_Account_bi__c ta : [select Id, Account_BI__c, FTEs_BI__c, Is_Included_BI__c, NTL_Rank_BI__c, NTL_Value_BI__c, Portfolio_BI__c, Target_Calls_BI__c, Version_BI__c from Target_Account_bi__c where Portfolio_BI__c =: portfolioId  and version_bi__c =: version order by id asc limit 10000]) {
					r.targetaccounts.add(ta);
					r.targetaccountid = ta.Id;
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
        public list<Target_Account_bi__c> targetaccounts;
        public Id targetaccountid;
        public Response() {
            success = true;
            message = '';
        }
   }
}