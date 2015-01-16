/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Set a portfolio active for a country
*  @author:         Jefferson Escobar
*  @created:        07-Mar-2014
*  @version:        1.0
*  @see:            Salesforce GAM
*  @since:			29.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         07-Mar-2014                 jescobar                 	Construction of the class.
*/ 

public class IMP_BI_SetPortfolioActive {
	
	/** Public memebers */
	public Boolean hasError {get; set;}
	
	
	/** Private memebers */	
	private map<String, String> map_urlParams;
	private Portfolio_BI__c portfolio;
	private String errMsg;
	private Id pId;
	private String retURL;
	private List<Portfolio_BI__c> porfoliosCountry;
	
	
	/**
	* Standard Controller Constructor
	*
	@author:  Jefferson Escobar
	@created: 07-Mar-2014
	@version 1.0
	@since   29.0 (Force.com ApiVersion)
	*
	@changelog
	* 07-Mar-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	public IMP_BI_SetPortfolioActive(ApexPages.standardController ctr){
		map_urlParams = ApexPages.currentPage().getParameters();
    	hasError = false;
    	errMsg = '';
    	
    	pId = ctr.getId();
    	
    	if(pId != null){
    		portfolio = [Select Id,Name,Cycle_BI__c,Cycle_BI__r.Country_Lkp_BI__c,Active_SAP__c From Portfolio_BI__c where Id = :pId limit 1];
    		porfoliosCountry = [Select Id,Name,Active_SAP__c From Portfolio_BI__c where Cycle_BI__r.Country_Lkp_BI__c = :portfolio.Cycle_BI__r.Country_Lkp_BI__c and Id <> :pId];
    		system.debug(':: Portfolio country: ' + porfoliosCountry);
    	}
    	else{
    		hasError = true;
    		errMsg = 'Invalid Portfolio Id!';
    	}
    	
    	if(hasError){
    		String pf = '/' + Portfolio_BI__c.SObjectType.getDescribe().getKeyPrefix();
			if(pId != null) pf = '/' + String.valueOf(pId).substring(0, 15);
			retURL = pf;
    		errMsg += ' Click<a href="' + retURL + '">here</a>to return back.'; 
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errMsg));
    	}
	}
	
	/**
	* Creating group of especialties just for USA 
	*
	@author Jefferson Escobar
	@created 20-Feb-2014
	@version 1.0
	@since 29.0 (Force.com ApiVersion)
	*
	*
	@changelog
	* 20-Feb-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/ 	
	
	public PageReference action_setPorfotlioActive(){
		errMsg = '';
		String pf = '/' + Portfolio_BI__c.SObjectType.getDescribe().getKeyPrefix();
		
		if(pId != null){pf = '/' + String.valueOf(pId).substring(0, 15);}
		
		Pagereference page = new Pagereference(pf);
		
		if(map_urlParams.containsKey('retURL')){ page = new Pagereference(map_urlParams.get('retURL'));}
		retURL = pf;
		
		Savepoint sp = Database.setSavepoint();
		try{
			if(!hasError){
				
				if(porfoliosCountry!=null&&!porfoliosCountry.isEmpty()){
					for(Portfolio_BI__c p : porfoliosCountry){
						p.Active_SAP__c = false;
					}
					//Set rest of portfolios inactives for the country
					update porfoliosCountry;
				}
				
				//Set a portfolio active for the country
				portfolio.Active_SAP__c = true;
				update portfolio;
			}
		}
		catch(Exception e){
			Database.rollback(sp);
			hasError = true;
			errMsg = e.getMessage();
		}
		
		if(hasError){
			errMsg += ' Click<a href="' + retURL + '">here</a>to return back.'; 
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
    		return null;
		}
		page.setRedirect(true);
		return page;
	}
	
	/**
	* This method is used to cancel the operate and return back 
	*
	@author  Jefferson Escobar
	@created 07-Mar-2014
	@version 1.0
	@since   29.0 (Force.com ApiVersion)
	*
	@return 	Pagereference
	*
	@changelog
	* 07-Mar-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
    public Pagereference action_cancel(){
		String pf = '/' + Portfolio_BI__c.SObjectType.getDescribe().getKeyPrefix();
		if(pId != null) pf = '/' + String.valueOf(pId).substring(0, 15);
		
		Pagereference page;
		page = new Pagereference(pf);
		if(map_urlParams.containsKey('retURL')) page = new Pagereference(map_urlParams.get('retURL'));
		
		page.setRedirect(true);
		return page;
	}
}