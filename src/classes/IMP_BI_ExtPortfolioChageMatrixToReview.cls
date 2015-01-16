/**
 *	Controller class for IMP_BI_ExtPortfolioChageMatrixToReview VF page
 *
 @author 	Peng Zhu
 @created 	2013-07-08
 @version 	1.0
 @since 	27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-07-08 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
public class IMP_BI_ExtPortfolioChageMatrixToReview {
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	public Boolean hasError {get; set;}
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    /**
	 * map to store global describtion due to limit on describe methodes.
	 */
	private Id pId;
	private String errMsg;
	private String retURL;
	private list<Matrix_BI__c> list_matrix2Update;
	private Portfolio_BI__c portfolio;
	private map<String, String> map_urlParams;
	
    private static final String MATRIX_STATUS_FINAL = 'Ready for NTL';
    private static final String MATRIX_STATUS_REVIEW = 'Review Needed';
    private static final String PORTFOLIO_STATUS_DRAFT = 'Draft';
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	/////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
   /**
	* The contsructor
	*
	@author  Peng Zhu
	@created 2013-07-08
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@changelog
	* 2013-07-08 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public IMP_BI_ExtPortfolioChageMatrixToReview(ApexPages.standardController stdCtrl) {
    	
    	map_urlParams = ApexPages.currentPage().getParameters();
    	hasError = false;
    	errMsg = '';
    	
    	pId = stdCtrl.getId();
    	
    	if(pId != null){
    		set<Id> set_mIds = new set<Id>();
    		list_matrix2Update = new list<Matrix_BI__c>();
    		
    		for(Portfolio_BI__c p : [SELECT Id, Status_BI__c FROM Portfolio_BI__c WHERE Id = :pId]){
				portfolio = p;
				portfolio.Status_BI__c = PORTFOLIO_STATUS_DRAFT;
    		}
    		
    		for(Strategic_Brand_Weight_BI__c s : [SELECT Id, Portfolio_BI__c, Matrix_BI__c, Matrix_BI__r.Status_BI__c FROM Strategic_Brand_Weight_BI__c WHERE Portfolio_BI__c = :pId AND Matrix_BI__c != NULL AND Matrix_BI__r.Status_BI__c = :MATRIX_STATUS_FINAL]){
    			set_mIds.add(s.Matrix_BI__c);
    		}
    		
    		if(!set_mIds.isEmpty()){
    			for(Matrix_BI__c m : [SELECT Id, Status_BI__c FROM Matrix_BI__c WHERE Id IN :set_mIds AND Status_BI__c = :MATRIX_STATUS_FINAL]){
    				m.Status_BI__c = MATRIX_STATUS_REVIEW;
    				list_matrix2Update.add(m);
    			}
    		}
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
	/////////////////////////////////// -=END CONSTRUCTOR=- ///////////////////////////////////////
    
    
    //********************************* -=BEGIN public methods=- **********************************
   /**
	* This method is used to change the Matrix status from 'Ready for NTL' to 'Review Needed'
	*
	@author  Peng Zhu
	@created 2013-07-08
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return 	Pagereference
	*
	@changelog
	* 2013-07-08 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public Pagereference changeMatrixStatusToReview(){
    	errMsg = '';
		String pf = '/' + Portfolio_BI__c.SObjectType.getDescribe().getKeyPrefix();
		if(pId != null) pf = '/' + String.valueOf(pId).substring(0, 15);
		Pagereference page;
		page = new Pagereference(pf);
		if(map_urlParams.containsKey('retURL')) page = new Pagereference(map_urlParams.get('retURL'));
		retURL = pf;
		
		Savepoint sp = Database.setSavepoint();
		try{
			if(!hasError){
				if(portfolio != null) update portfolio;
				
				if(list_matrix2Update != null && !list_matrix2Update.isEmpty()) update list_matrix2Update;
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
	@author  Peng Zhu
	@created 2013-07-08
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return 	Pagereference
	*
	@changelog
	* 2013-07-08 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public Pagereference cancel(){
		String pf = '/' + Portfolio_BI__c.SObjectType.getDescribe().getKeyPrefix();
		if(pId != null) pf = '/' + String.valueOf(pId).substring(0, 15);
		
		Pagereference page;
		page = new Pagereference(pf);
		if(map_urlParams.containsKey('retURL')) page = new Pagereference(map_urlParams.get('retURL'));
		
		page.setRedirect(true);
		return page;
	}
    //********************************* -=END public methods=- ************************************
    
    
    //********************************* -=BEGIN private methods=- *********************************
    //********************************* -=END private methods=- ***********************************
    
    
    //********************************* -=BEGIN help functions=- **********************************
    //********************************* -=END help functions=- ************************************
    
    //********************************* -=BEGIN inner classes=- ***********************************
    ///*>>>WrapperClass*/
	///*<<<WrapperClass*/
    //********************************* -=END inner classes=- *************************************
}