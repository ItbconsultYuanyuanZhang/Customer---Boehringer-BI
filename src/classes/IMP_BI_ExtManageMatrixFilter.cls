/**
 *	Controller class used for VF Page IMP_BI_ExtManageMatrixFilter
 *
 @author 	Peng Zhu
 @created 	2013-07-22
 @version 	1.0
 @since 	27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-07-22 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
global class IMP_BI_ExtManageMatrixFilter {
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	public list<ClsFilterField> list_cff {get; set;}
	public list<ClsMatrixFilter> list_cmf {get; set;}
	//Showing up all the filters from Account
	public List<ClsFilterField> allFilters {get;set;}
	
	public string pageTitle {get; private set;}
	public string sectionHeaderTitle {get; private set;}
	public string sectionHeaderSubTitle {get; private set;}
	
	public Id countryId {get; private set;}
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	private static final string KEYPREFIX_COUNTRY = Schema.SObjectType.Country_BI__c.getKeyPrefix();
	
	
	public Account account {get;set;}
	
    /**
	 * map to store global describtion due to limit on describe methodes.
	 */
	private map<String, String> map_urlParams;
	
	private static final set<String> SET_FILTER_FIELD_TYPE = new set<String>{'PICKLIST', 'BOOLEAN','STRING'};
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
    public IMP_BI_ExtManageMatrixFilter(ApexPages.standardController stdCtrl) {
    	list_cff = new list<ClsFilterField>();
    	list_cmf = new list<ClsMatrixFilter>();
    	
		pageTitle = 'Manage Matrix Filter';
		sectionHeaderTitle = 'Manage Matrix Filter';
		sectionHeaderSubTitle = 'Manage Matrix Filter';
    	
    	map_urlParams = ApexPages.currentPage().getParameters();
    	
    	Id cid;
    	if(map_urlParams != null && map_urlParams.containsKey('cId')) cid = map_urlParams.get('cId');
    	
    	set<String> set_usedField = new set<String>();
    	
		
		//map<String, String> map_aName_aLabel = getFieldMapping('Account', map_nL_nU.keySet());
		Map<String,String> mapFilterFields = getFields();
		
    	if(cid != null){
    		for(Country_BI__c c : [SELECT Id, Name FROM Country_BI__c WHERE Id = :cid]){
    			sectionHeaderSubTitle = c.Name;
    			countryId = c.Id;
    		}
    		
    		String filter_name;
    		for(Matrix_Filter_BI__c m : [SELECT Id, Filter_Label_BI__c, Filter_Field_BI__c, Active_BI__c, Country_BI__c FROM  Matrix_Filter_BI__c WHERE Active_BI__c = true AND Filter_Field_BI__c != null AND Country_BI__c = :cid Order by Filter_Label_BI__c]){
    			filter_name = m.Filter_Field_BI__c;
    			
    			//if(m.Filter_Field_BI__c != null && (filter_name = filter_name.trim()) != '' && map_aName_aLabel.containsKey(filter_name.toLowerCase())){
	    			ClsMatrixFilter cmf = new ClsMatrixFilter();
	    			cmf.id = m.Filter_Field_BI__c;
    				cmf.name = mapFilterFields.get(m.Filter_Field_BI__c);
    				cmf.label = m.Filter_Label_BI__c;
    				cmf.apiName = m.Filter_Field_BI__c;
    				
	    			set_usedField.add(m.Filter_Field_BI__c);
	    			
	    			list_cmf.add(cmf);
    			//}
    		}
    	}
    	    	
    	for(String str : mapFilterFields.keySet()){
    		if(str != null && (str = str.trim()) != ''){
    			if(!set_usedField.contains(str)){
    				//system.debug(':: apiName: ' + str + ' filter: ' + mapFilterFields.get(str));
	    			ClsFilterField cff = new ClsFilterField();
	    			cff.id = str;
	    			cff.name = mapFilterFields.get(str);//map_aName_aLabel.get(str.toLowerCase());
	    			cff.apiName = str;
	    			
	    			if(set_usedField.contains(str)) cff.isAssigned = true;
	    			
	    			list_cff.add(cff);
    			}
    		}
    	}
    	
    	
    	/**place holder
    	Integer cmfSize = list_cmf.size();
    	if(cmfSize < 3){
    		for(Integer i = 0; i < (3-cmfSize); i++){
    			ClsMatrixFilter cmf = new ClsMatrixFilter();
    			cmf.id = '';
    			cmf.name = '';
    			
    			list_cmf.add(cmf);
    		}
    	}*/
    	
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
	* This method is used to save matrix filter to sfdc
	*
	@author  Peng Zhu
	@created 2013-07-23
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@parm	 finalResult   json string of ClsMatrix object
	*
	@return  json string
	*
	@changelog
	* 2013-07-23 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/     
    @RemoteAction
    global static String saveMatrixFilter(String finalResult){
    	Response r = new Response();
    	Savepoint sp = Database.setSavepoint();
    	
    	try{
	    	ClsMatrixFilterReq cmfr = (ClsMatrixFilterReq)JSON.deserialize(finalResult, IMP_BI_ExtManageMatrixFilter.ClsMatrixFilterReq.class);	
	    	
	    	system.debug('cmfr : ' + cmfr);
	    	
	    	if(cmfr != null && cmfr.cid != null && cmfr.cid.trim() != '' && cmfr.set_filter != null){
	    		
	    		Map<String,String> mapFilterFields = getFields();
	    		set<string> set_filter = cmfr.set_filter;
	    		if(set_filter == null) set_filter = new set<string>();
	    		
				list<Matrix_Filter_BI__c> list_mf2Del = new list<Matrix_Filter_BI__c>();
				list<Matrix_Filter_BI__c> list_mf2Ins = new list<Matrix_Filter_BI__c>();	    		
	    		
	    		for(Matrix_Filter_BI__c m : [SELECT Id, Filter_Field_BI__c, Country_BI__c, Active_BI__c FROM Matrix_Filter_BI__c 
	    										WHERE Active_BI__c = true AND Filter_Field_BI__c != null AND Country_BI__c = :cmfr.cid]){
	    			
	    			if(set_filter.contains(m.Filter_Field_BI__c)) 
	    				set_filter.remove(m.Filter_Field_BI__c);
	    			else 
	    				list_mf2Del.add(m);
	    		}
	    			    		
	    		if(!set_filter.isEmpty()){
	    			for(String str : set_filter){
	    				if(str != null && (str = str.trim()) != ''){
	    					Matrix_Filter_BI__c mf = new Matrix_Filter_BI__c();
	    					mf.Country_BI__c = cmfr.cid;
	    					mf.Filter_Field_BI__c = str;
	    					mf.Filter_Label_BI__c = mapFilterFields.get(str);//map_aName_aLabel.get(str.toLowerCase()); 
	    					list_mf2Ins.add(mf);
	    				}
	    			}
	    		}
	    		
	    		if(!list_mf2Del.isEmpty()) delete list_mf2Del; 
	    		if(!list_mf2Ins.isEmpty()) insert list_mf2Ins; 
	    		
	    		//system.debug('**@@Peng list_mf2Del : ' + list_mf2Del);
	    		//system.debug('**@@Peng list_mf2Ins : ' + list_mf2Ins);
	    	}
    	}
    	catch(DmlException de){
    		Database.rollback(sp);
    		r.success = false;
			r.message = de.getMessage();
			return JSON.serialize(r);
    	}
    	catch(Exception e){
    		r.success = false;
			r.message = e.getMessage();
			return JSON.serialize(r);
    	}
    	
		r.success = true;
		r.message = 'OK';
		return JSON.serialize(r);
    }
    //********************************* -=END public methods=- ************************************
    
    
    //********************************* -=BEGIN private methods=- *********************************
    
    /**
	* This method is used to get all the field filters from Account object
	*
	@author  Jefferson Escobar
	@created 06-Nov-2014
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	*
	@return  mapFilters a map, key is Field Api Name and value id Field Label Name
	*
	@changelog
	* 06-Nov-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	private static Map<String,String> getFields(){
		
		Map<String,String> mapFilters = new Map<String,String>();
		Map<String, Schema.SObjectField> fieldMap= Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
		
		for(String fieldName: fieldMap.keySet()){
			if(SET_FILTER_FIELD_TYPE.contains(String.valueOf(fieldMap.get(fieldName).getDescribe().getType()).toUpperCase())){
				//system.debug(':: Acc Filter: ' + fieldMap.get(fieldName).getDescribe().getName());
				mapFilters.put(fieldMap.get(fieldName).getDescribe().getName(),fieldMap.get(fieldName).getDescribe().getLabel());
			}
		} 
        
        return mapFilters;
    }
    //********************************* -=END private methods=- ***********************************
    
    
    //********************************* -=BEGIN help functions=- **********************************
    //********************************* -=END help functions=- ************************************
    
    //********************************* -=BEGIN inner classes=- ***********************************
    ///*>>>WrapperClass*/
    public class ClsFilterField{
    	public string id {get; set;}
    	public string name {get; set;}
    	public string apiName {get; set;}
    	public boolean isAssigned {get; set;}
    	
    	public ClsFilterField(){
    		isAssigned = false;
    	}
    }
    
    public class ClsMatrixFilter{
    	public string id {get; set;}
    	public string name {get; set;}
    	public string apiName {get; set;}
    	public string label {get; set;}
    	
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