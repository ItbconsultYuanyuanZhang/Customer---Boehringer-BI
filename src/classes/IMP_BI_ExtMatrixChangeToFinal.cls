/**
 *	Contains a set of static methods used in invoice creation triggers and VF pages
 *
 @author 	Peng Zhu
 @created 	2013-06-27
 @version 	1.0
 @since 	27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-06-27 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
public class IMP_BI_ExtMatrixChangeToFinal {
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	public Boolean hasError {get; set;}
	public String finalStatus {get; private set;}
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    /**
	 * map to store global describtion due to limit on describe methodes.
	 */
	private map<String, String> map_urlParams;
	private Matrix_BI__c matrix;
	private String errMsg;
	private String retURL;
	
    private static final set<String> SET_MATRIX_STATUS_EDITABLE = new set<String>{'Calculated', 'Review Needed'};
    private static final String MATRIX_STATUS_FINAL = 'Ready for NTL';
    private static final String MATRIX_STATUS_CALCULATED = 'Calculated';
    private static final String MATRIX_STATUS_DRAFT = 'Draft';
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	/////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
   /**
	* The contsructor
	*
	@author  Peng Zhu
	@created 2013-06-27
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@changelog
	* 2013-06-27 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public IMP_BI_ExtMatrixChangeToFinal(ApexPages.standardController stdCtrl) {
    	
    	finalStatus = MATRIX_STATUS_FINAL;
    	
    	map_urlParams = ApexPages.currentPage().getParameters();
    	hasError = false;
    	errMsg = '';
    	
    	Id mId = stdCtrl.getId();
    	
    	if(mId != null){
	    	for(Matrix_BI__c m : [SELECT Id, Status_BI__c FROM Matrix_BI__c WHERE Id = :mId]){
	    		matrix = m;
	    		if(!SET_MATRIX_STATUS_EDITABLE.contains(m.Status_BI__c)){
	    			hasError = true;
	    			errMsg = system.label.IMP_BI_ErrMsg_Matrix_Status_Final;
	    		}
	    		else{
	    			matrix.Status_BI__c = MATRIX_STATUS_FINAL;
	    		}
	    	}
    	}
    	else{
    		hasError = true;
    		errMsg = 'Invalid Matrix Id!';
    	}
    	
    	if(hasError){
    		String pf = '/' + Matrix_BI__c.SObjectType.getDescribe().getKeyPrefix();
			if(matrix != null && matrix.Id != null) pf = '/' + String.valueOf(matrix.Id).substring(0, 15);
			if(map_urlParams.containsKey('retURL') && map_urlParams.get('retURL') != null) pf = map_urlParams.get('retURL');
			retURL = pf;
    		errMsg += ' Click<a href="' + retURL + '">here</a>to return back.'; 
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errMsg));
    	}
    }
	/////////////////////////////////// -=END CONSTRUCTOR=- ///////////////////////////////////////
    
    
    //********************************* -=BEGIN public methods=- **********************************
   /**
	* This method is used to 
	*
	@author  Peng Zhu
	@created 2013-06-27
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return 	Pagereference
	*
	@changelog
	* 2013-06-27 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public Pagereference changeMatrixStatusToFinal(){
    	errMsg = '';
		String pf = '/' + Matrix_BI__c.SObjectType.getDescribe().getKeyPrefix();
		if(matrix != null && matrix.Id != null) pf = '/' + String.valueOf(matrix.Id).substring(0, 15);
		if(map_urlParams.containsKey('retURL') && map_urlParams.get('retURL') != null) pf = map_urlParams.get('retURL');
		Pagereference page;
		page = new Pagereference(pf);
		//if(map_urlParams.containsKey('retURL')) page = new Pagereference(map_urlParams.get('retURL'));
		retURL = pf;
		try{
			if(!hasError){
				if(matrix != null) update matrix;
			}
		}
		catch(Exception e){
			hasError = true;
			errMsg = e.getMessage();
		}
		
		if(hasError){
			errMsg += ' Click<a href="' + retURL + '">here</a>to return back.'; 
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errMsg));
    		return null;
		}
		page.setRedirect(true);
		return page;
	}
	
	
   /**
	* This method is used to cancel the operate and return back 
	*
	@author  Peng Zhu
	@created 2013-06-27
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return 	Pagereference
	*
	@changelog
	* 2013-06-27 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public Pagereference cancel(){
		String pf = '/' + Matrix_BI__c.SObjectType.getDescribe().getKeyPrefix();
		if(matrix != null && matrix.Id != null) pf = '/' + String.valueOf(matrix.Id).substring(0, 15);
		if(map_urlParams.containsKey('retURL') && map_urlParams.get('retURL') != null) pf = map_urlParams.get('retURL');
		
		Pagereference page;
		page = new Pagereference(pf);
		//if(map_urlParams.containsKey('retURL')) page = new Pagereference(map_urlParams.get('retURL'));
		
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