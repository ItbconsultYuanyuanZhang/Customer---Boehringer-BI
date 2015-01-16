/**
 *	Controller class used in IMP_BI_ExtMatrixUpdateStrategicWeight VF page
 *
 @author 	Peng Zhu
 @created 	2013-07-12
 @version 	1.0
 @since 	27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-07-12 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
public with sharing class IMP_BI_ExtMatrixUpdateStrategicWeight {
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	public Boolean hasError {get; set;}
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    /**
	 * map to store global describtion due to limit on describe methodes.
	 */
	private map<String, String> map_urlParams;
	private Matrix_BI__c matrix;
	private String errMsg;
	private String retURL;
	private list<Matrix_Cell_BI__c> list_mc2Update;
	
    private static final set<String> SET_MATRIX_STATUS_EDITABLE = new set<String>{'Draft','Calculated','Ready for NTL'};
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
    public IMP_BI_ExtMatrixUpdateStrategicWeight(ApexPages.standardController stdCtrl) {
    	map_urlParams = ApexPages.currentPage().getParameters();
    	hasError = false;
    	errMsg = '';
    	
    	list_mc2Update = new list<Matrix_Cell_BI__c>();
    	
    	Id mId = stdCtrl.getId();
    	
    	if(mId != null){
	    	for(Matrix_BI__c m : [SELECT Id, Status_BI__c, Row_BI__c, Column_BI__c, Lifecycle_Template_BI__c FROM Matrix_BI__c WHERE Id = :mId]){
	    		matrix = m;
	    		if(!SET_MATRIX_STATUS_EDITABLE.contains(m.Status_BI__c)){
	    			hasError = true;
	    			errMsg = system.label.IMP_BI_ErrMsg_Update_MC_SW;
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
    public Pagereference updateMatrixCellStrategicWeight(){
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
				if(matrix != null && matrix.Id != null){
					decimal potential_weight = 0, adoption_weight = 0, potential_weight_factor = 0, adoption_weight_factor = 0;
					
					if(matrix.Row_BI__c != null && matrix.Row_BI__c != 0) potential_weight = (100.0/matrix.Row_BI__c).setScale(2);
					if(matrix.Column_BI__c != null && matrix.Column_BI__c > 1) adoption_weight = (100.0/(matrix.Column_BI__c-1)).setScale(2);
					
					if(matrix.Lifecycle_Template_BI__c != null){
						for(Lifecycle_Template_BI__c lt : [SELECT Id, Adoption_Weight_Factor_BI__c, Potential_Weight_Factor_BI__c FROM Lifecycle_Template_BI__c WHERE Id = :matrix.Lifecycle_Template_BI__c]){
							if(lt.Adoption_Weight_Factor_BI__c != null) adoption_weight_factor = lt.Adoption_Weight_Factor_BI__c;
							if(lt.Potential_Weight_Factor_BI__c != null) potential_weight_factor = lt.Potential_Weight_Factor_BI__c;
						}
					}
					potential_weight = potential_weight * potential_weight_factor;
					adoption_weight = adoption_weight * adoption_weight_factor;
					
					for(Matrix_Cell_BI__c mc : [SELECT Id, Row_BI__c, Column_BI__c, Strategic_Weight_BI__c FROM Matrix_Cell_BI__c WHERE Matrix_BI__c = :matrix.Id]){
						if(mc.Row_BI__c != null && mc.Column_BI__c != null) mc.Strategic_Weight_BI__c = potential_weight * mc.Row_BI__c + adoption_weight * mc.Column_BI__c;
						else mc.Strategic_Weight_BI__c = 0;
						list_mc2Update.add(mc);
					}
					
					if(!list_mc2Update.isEmpty()) update list_mc2Update;
				}
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