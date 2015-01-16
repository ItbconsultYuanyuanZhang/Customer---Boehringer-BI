/**
 *	Controller class used for VF Page IMP_BI_ExtManageMatrixFilterByCountry
 *
 @author 	Peng Zhu
 @created 	2013-07-23
 @version 	1.0
 @since 	27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-07-23 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
global class IMP_BI_ExtManageMatrixFilterByCountry {
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	public list<ClsFilterField> list_cff {get; set;}
	public list<ClsMatrixFilter> list_cmf {get; set;}
	
	public string pageTitle {get; private set;}
	public string sectionHeaderTitle {get; private set;}
	public string sectionHeaderSubTitle {get; private set;}
	public Matrix_Filter_BI__c matrix {get;set;}
	
	public Id countryId {get; private set;}
	public String countryCode {get; private set;}
	
	public String mfId {get; set;}
	public String delMfId {get; set;}
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	private static final string KEYPREFIX_COUNTRY = Schema.SObjectType.Country_BI__c.getKeyPrefix();
	private static final set<String> SET_FILTER_FIELD_TYPE = new set<String>{'PICKLIST', 'BOOLEAN','STRING'};
	
	
    /**
	 * map to store global describtion due to limit on describe methodes.
	 */
	private map<String, String> map_urlParams;
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	/////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
   /**
	* The contsructor
	*
	@author  Peng Zhu
	@created 2013-07-22
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@changelog
	* 2013-07-22 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public IMP_BI_ExtManageMatrixFilterByCountry(ApexPages.standardController stdCtrl) {
    	list_cff = new list<ClsFilterField>();
    	list_cmf = new list<ClsMatrixFilter>();
    	matrix = new Matrix_Filter_BI__c();
    	
		pageTitle = 'Manage Matrix Filter';
		sectionHeaderTitle = 'Manage Matrix Filter';
		sectionHeaderSubTitle = 'Manage Matrix Filter';
    	
    	map_urlParams = ApexPages.currentPage().getParameters();
    	
    	Id cid = stdCtrl.getId();
    	//if(map_urlParams != null && map_urlParams.containsKey('cId')) cid = map_urlParams.get('cId');
    	
    	set<String> set_usedField = new set<String>();
    	
    	if(cid != null){
    		for(Country_BI__c c : [SELECT Id, Name,Country_Code_BI__c FROM Country_BI__c WHERE Id = :cid]){
    			sectionHeaderSubTitle = c.Name;
    			countryId = c.Id;
    			countryCode = c.Country_Code_BI__c;
    		}
    		
    		//Get description object to Account
			Map<String, Schema.SObjectField> fieldMap= Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
    		
    		for(Matrix_Filter_BI__c m : [SELECT Id, Filter_Field_BI__c,Filter_Label_BI__c, Active_BI__c, Country_BI__c FROM  Matrix_Filter_BI__c WHERE Active_BI__c = true AND Filter_Field_BI__c != null AND Country_BI__c = :cid Order by Filter_Label_BI__c]){
    			ClsMatrixFilter cmf = new ClsMatrixFilter();
    			cmf.id = m.Id;
    			cmf.lName = fieldMap.get(m.Filter_Field_BI__c).getDescribe().getLabel();
    			cmf.mf = m;
				list_cmf.add(cmf);
    			
    		}
    	}
    }
	/////////////////////////////////// -=END CONSTRUCTOR=- ///////////////////////////////////////
    
    
    //********************************* -=BEGIN public methods=- **********************************
   /**
	* This method is used to cancel back to country page
	*
	@author  Peng Zhu
	@created 2013-07-23
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return  Pagereference
	*
	@changelog
	* 2013-07-23 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/  	
	public Pagereference cancel(){
		Pagereference page;
		
		system.debug(':: Cancel action..... ::');
		
		if(map_urlParams.containsKey('retURL')){
			page = new Pagereference(map_urlParams.get('retURL'));
		}
		else if(countryId != null){
			page = new Pagereference('/' + countryId);
		}
		else{
			page = new Pagereference('/' + KEYPREFIX_COUNTRY);
		}
		
		page.setRedirect(true);
		
		return page;
	}
	
   /**
	* This method is used to cancel back to country page
	*
	@author  Peng Zhu
	@created 2013-07-23
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return  Pagereference
	*
	@changelog
	* 2013-07-23 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/  	
	public Pagereference editFilter(){
		Pagereference page;
		
		String paramUrl = '/'; 
		
		if(mfId != null && (mfId = mfId.trim()) != '' && countryId != null){
			mfId = mfId.substring(0, 15);
			
			paramUrl += mfId + '/e?retURL=' + String.valueOf(countryId).substring(0, 15);
			
			page = new Pagereference(paramUrl);
			
			page.setRedirect(true);
			
			return page;
		}
		return null;
	}
	
	public void delFilter(){
		
		system.debug('**@@Peng delMfId : ' + delMfId);
		
		if(delMfId != null && (delMfId = delMfId.trim()) != ''){
			list<Matrix_Filter_BI__c> list_mf = [SELECT Id, Name FROM Matrix_Filter_BI__c WHERE Id = :delMfId];
			
			//system.debug('**@@Peng list_mf : ' + list_mf);
			if(!list_mf.isEmpty()) delete list_mf;
		}
	}

   /**
	* This method is used to redirect to manage matrix filter page
	*
	@author  Peng Zhu
	@created 2013-07-23
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return  Pagereference
	*
	@changelog
	* 2013-07-23 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/  	
	public Pagereference manageMatrixFilter(){
		Pagereference page;
		
		String paramUrl = '/apex/IMP_BI_ExtManageMatrixFilter?cId='; 
		
		if(countryId != null){
			
			paramUrl += countryId;
			
			page = new Pagereference(paramUrl);
			
			page.setRedirect(true);
			
			return page;
		}
		return null;
	}	

   /**
	* This method is used to save matrix filter to sfdc
	*
	@author  Jefferson Escobar
	@created 14-Mar-2014
	@version 1.0
	@since   29.0 (Force.com ApiVersion)
	*
	*
	@return  PageReference
	*
	@changelog
	* 14-Mar-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/  
    
    public Pagereference saveMatrixFilter(){
    	Savepoint sp;
    	try{
    		sp = Database.setSavepoint();
    		 
    		 if(list_cmf!=null&&!list_cmf.isEmpty()){
    		 	
    		 	List<Matrix_Filter_BI__c> matrixFilters = new List<Matrix_Filter_BI__c>();
    		 	
    		 	for(ClsMatrixFilter m : list_cmf){
    		 		matrixFilters.add(m.mf); 
    		 	}
    		 	update matrixFilters;
    		 	
    		 	return new Pagereference ('/'+countryId);  
    		 }else{
    		 	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please manage a matrix filter at least'));
    		 } 
    	}catch(DMLException de){
    		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, de.getMessage()) );
    		Database.rollback(sp);

    	}catch(Exception de){
    		system.debug('[ERROR]: ' + de.getMessage());
    	}
    	
    	return null;
    }
  
    //********************************* -=END public methods=- ************************************
    
    
    //********************************* -=BEGIN private methods=- *********************************
   
    
    @RemoteAction
    @ReadOnly
	public static List<ClsFilterSummary> getSummarySpecialties(String params){
		
		//Get parametrs for querying
		String countryCode = params.split('-')[0];
		String channel = params.split('-')[1];
		
		List<ClsFilterSummary> fSummries = new List<ClsFilterSummary>();
		String query = 'Select '+channel+' Channel, Count(Id) Quantity From Account where '+channel+' <> null and Country_Code_BI__c = \'' + countryCode + '\' group by '+channel;
		
		for(AggregateResult c : (List<AggregateResult>) Database.query(query)){
			ClsFilterSummary fs = new ClsFilterSummary();
			fs.channel = c.get('Channel')!=null ? String.valueOf(c.get('Channel')) : '';
			fs.quantity = c.get('Quantity')!=null ? Integer.valueOf(c.get('Quantity')) : 0;
			fSummries.add(fs);
		}
		return fSummries;
	}
	
    //********************************* -=END private methods=- ***********************************
    
    
    //********************************* -=BEGIN help functions=- **********************************
    //********************************* -=END help functions=- ************************************
    
    //********************************* -=BEGIN inner classes=- ***********************************
    ///*>>>WrapperClass*/
    public class ClsFilterField{
    	public string id {get; set;}
    	public string name {get; set;}
    	public boolean isAssigned {get; set;}
    	
    	public ClsFilterField(){
    		isAssigned = false;
    	}
    }
    
    public class ClsFilterSummary{
    	public String channel {get; set;}
    	public Integer quantity {get; set;}
    	public boolean success;
    	public string message;
    }
    
    public class ClsMatrixFilter{
    	public string id {get; set;}
    	public string name {get; set;}
    	public string aName {get; set;}
    	public string lName {get; set;}
    	public Matrix_Filter_BI__c mf {get; set;}
    	
    	public ClsMatrixFilter(){}
    }
    
    public class ClsMatrixFilterReq{
    	public string cid;
    	
    	public set<string> set_filter;
    	
    	public ClsMatrixFilterReq(){
    		set_filter = new set<string>();
    	}
    }
    
    public class Response{
    	public boolean success;
    	public string message;
    	
    	public Response(){
    		success = true;
    		message = '';
    	}
    }
	///*<<<WrapperClass*/
    //********************************* -=END inner classes=- *************************************
}