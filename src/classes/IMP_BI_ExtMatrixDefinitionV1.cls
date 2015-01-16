/**
 *  Contains a set of static methods used in invoice creation triggers and VF pages
 *
 @author    Peng Zhu
 @created   2013-05-24
 @version   1.0
 @since     27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-05-24 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
global with sharing class IMP_BI_ExtMatrixDefinitionV1 {
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	public static final string KEYPREFIX_CYCLE = Schema.SObjectType.Cycle_BI__c.getKeyPrefix();

	public string productId {get; set;}
	public integer specialCounter {get; private set;}
	
	public list<Customer_Attribute_BI__c> list_special {get; private set;}
	public list<Specialty_Grouping_BI__c> list_specialtiesGroup {get; private set;}
	public list<ClsSpecialization> list_clsSpcial {get; private set;}
	
	public Cycle_BI__c cycle {get; private set;}
	
	public list<ClsMatrixEdit> list_cme {get; set;}
	public list<ClsMatrixEdit> list_cmeFinal {get; set;}
	
	public list<SelectOption> list_prods {get; private set;}
	public List<Selectoption> matrixTemplates {get;private set;}
	public String jsonMatrixTemplate {get; private set;}	
	
	private Set<String> typeSetting = IMP_BI_Product_Catalog_Setting__c.getAll().keySet();
	public boolean hasError {get; private set;}
	
	
	/**HTML Select List*/
	public String mtSelectList {get; private set;}
	public String matrixTemplateList {get; private set;}
	
    //for page title
    public String pageTitle {get; private set;}
    public String sectionHeaderTitle {get; private set;}
    public String sectionHeaderSubTitle {get; private set;}
    
    public String calcuUrl {get; private set;}
    
    public list<Matrix_BI__c> list_matrix2Edit {get; set;}
    
    public integer matrixIndex {get; set;}
    public list<String> list_specilIndex {get; set;}
    
    public string jsonMTofLaunch {get; set;}
    
    //public string jsonOfCalcuInfo {get; set;}
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    private map<String, String> map_urlParams;
    private string errMsg = ''; 
    private set<Id> set_usedSpecialIds;
    private Map<String,Matrix_Template_BI__c> mapTemplates; 
    
    map<Id, map<String, String>> map_id_sName_sGroup;
    map<Id,String> map_id_sName;
    map<Id,String> map_id_gName;
    map<String,Integer> map_specialties_accounts;
    
    //private static final set<String> SET_MATRIX_EDIT_STATUS = new set<String>{'Planned', 'Started', 'Work At Risk', 'Staffed'};
    private static final set<String> SET_MATRIX_STATUS_EDIT = new set<String>{'Draft'};
    private static final set<String> SET_MATRIX_STATUS_NON_EDIT = new set<String>{'Ready for NTL', 'Calculated', 'Final', 'Review Needed', 'Archive'};
    private static final set<String> SET_MATRIX_STATUS_SPECIAL = new set<String>{'Archive'};
    private static final String MATRIX_STATUS_FINAL = 'Ready for NTL';
    private static final String MATRIX_STATUS_CALCULATED = 'Calculated';
    private static final String MATRIX_STATUS_DRAFT = 'Draft';
    private static final Integer DEFAULT_SPECIAL_NUM = 3;//Added by Peng Zhu 2013-08-30
    private List<Matrix_Template_BI__c> allMatrixTemplates;
    
    /**For testing countries*/
    public static Country_BI__c countryTest {get;private set;}//TODO:jescobar testing
    
    //jescobar: Edit description
    public boolean showDescription {get; private set;}
    public Matrix_BI__c matrixDescription {get; private set;}
    public String countryCode {get;private set;} //Added by Jefferson Escobar 20-Feb-2014
    public String countryCodeRegion {get;private set;} //Added by Jefferson Escobar 08-Abr-2014
    private Map<String,Specialty_Grouping_Config__c> mapSpecialtyConfig;
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    /////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
   /**
    * The contsructor
    *
    @author  Peng Zhu
    @created 2013-05-24
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @changelog
    * 2013-05-24 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */
    public IMP_BI_ExtMatrixDefinitionV1(ApexPages.standardController stdCtrl) {
    	showDescription = false;
    	init();
        map_urlParams = ApexPages.currentPage().getParameters();
		string retURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        
        Id cycleId;
        if(map_urlParams != null && map_urlParams.containsKey('cId')){
        	cycleId = map_urlParams.get('cId');
        }
        		
		Id matrixId = stdCtrl.getId();
		Matrix_BI__c matrix;
		if(matrixId != null){
			for(Matrix_BI__c m : [SELECT Id, DPA_BI__c, isLaunch_Phase_BI__c, Cycle_BI__c, Product_Catalog_BI__c, Status_BI__c,Matrix_Description_BI__c,Cycle_BI__r.Country_Lkp_BI__r.Country_Code_BI__c,Matrix_Template_BI__c 
								  FROM Matrix_BI__c WHERE Id = :matrixId]){
				cycleId = m.Cycle_BI__c;
				matrix = m;
				
				if(SET_MATRIX_STATUS_NON_EDIT.contains(m.Status_BI__c)){
					hasError = true;
					if(map_urlParams != null && map_urlParams.containsKey('retURL')){
						retURL = map_urlParams.get('retURL');
					}
					else{
						retURL += m.Id;
					}
				}
				
				matrixDescription = m;
			}
		}
		if(!hasError){
			if(cycleId != null){
				for(Cycle_BI__c c : [SELECT Id, Name, Country_Lkp_BI__c, Country_Lkp_BI__r.Name, Country_Lkp_BI__r.Country_Code_BI__c,Country_Lkp_BI__r.Country_Code_Region_BI__c FROM Cycle_BI__c WHERE Id = :cycleId]){
					cycle = c;
					countryCode = c.Country_Lkp_BI__r.Country_Code_BI__c;
					//Get the specialties for countries with geographical region 
    				countryCodeRegion = (c.Country_Lkp_BI__r.Country_Code_Region_BI__c!=null&&c.Country_Lkp_BI__r.Country_Code_Region_BI__c != '') ? c.Country_Lkp_BI__r.Country_Code_Region_BI__c : null;
				}
				
				//used in js
				mtSelectList = generateSelectOfMTByCountry();
				
				if(cycle != null && cycle.Country_Lkp_BI__c != null){
					
					//TODO:jescobar Check if it is a testing country
			        if(IMP_BI_Performance_Testing_Configuration__c.getAll()!=null&&
			        	IMP_BI_Performance_Testing_Configuration__c.getAll().containsKey(cycle.Country_Lkp_BI__c)){
			        	
			        	countryTest=[Select Id,Name, Country_Code_BI__c From Country_BI__c 
			        					where Country_Code_BI__c=:IMP_BI_Performance_Testing_Configuration__c.getAll().get(cycle.Country_Lkp_BI__c).Country_Code__c limit 1];
			        	countryCode = countryTest.Country_Code_BI__c; 
					}
					
					sectionHeaderTitle = cycle.Name;
					list_prods = getProductsByCountry();
			    	if(matrix != null && matrix.Product_Catalog_BI__c !=null) productId = matrix.Product_Catalog_BI__c;
			    	
			    	
			    	mapSpecialtyConfig = Specialty_Grouping_Config__c.getAll(); 
			    	if(countryCode!=null && mapSpecialtyConfig.containsKey(countryCode)){//Load list specialties for USA
	        			//Something to do
	        			list_specialtiesGroup = getListOfSpecializationsUSA();
	        			
	        			if(list_specialtiesGroup != null && !list_specialtiesGroup.isEmpty()){
					    	specialCounter = list_specialtiesGroup.size();
					    	for(integer i = 0; i < list_specialtiesGroup.size(); i++){
					    		list_specilIndex.add('' + i);
					    	}
				    	}else{specialCounter = 0;}
	        
		        	}else{// Load list specialties rest of the world
						list_special = getListOfSpecializations();
						
						if(list_special != null && !list_special.isEmpty()){
					    	specialCounter = list_special.size();
					    	for(integer i = 0; i < list_special.size(); i++){
					    		list_specilIndex.add('' + i);
					    	}
				    	}else{specialCounter = 0;}	        		
				    }
			    	
			    	
			    	//Begin: added by Peng Zhu 2013-07-30 for filter the used speciality
			    	//for(Matrix_BI__c m : [SELECT Id, Specialization_BI__c FROM Matrix_BI__c WHERE Cycle_BI__c = :cycleId AND Specialization_BI__c != NULL]){
			    	//	////////////////////
			    	//	set<string> set_s = new set<string>();
					//	if(m.Specialization_BI__c != null && m.Specialization_BI__c.trim() != ''){
					//		for(string str : m.Specialization_BI__c.split(';')){
					//			if(str.trim() != '') set_s.add(str.trim());
					//		}
					//	}
					//	
					//	set<id> set_sIdExist = new set<id>();
					//	list<ClsMatrixSpecial> list_cms = new list<ClsMatrixSpecial>();
					//	
					//	//map_id_gName
					//	for(Id sId : map_id_sName.keySet()){
					//		if(set_s.contains(map_id_sName.get(sId)) && !set_sIdExist.contains(sId)){
					//			
					//			set_usedSpecialIds.add(sId);
					//			
					//			set_sIdExist.add(sId);
					//		}
					//	}
			    	//	/////////////////
			    	//}
			    	//system.debug('**@@Peng set_usedSpecialIds : ' + set_usedSpecialIds);
			    	//End: added by Peng Zhu 2013-07-30 
			    	
					//Load all the templare records in the country
					allMatrixTemplates = [Select Id,Name, Country_BI__c, Specialties_BI__c,Potential_Data_Label_BI__c,Adoption_Data_Label_BI__c,Product_Catalog_BI__c,Row_BI__c, Column_BI__c,Lifecycle_Template_BI__c, Specialty_Ids_BI__c 
											From Matrix_Template_BI__c where Country_BI__c = :cycle.Country_Lkp_BI__c];
											
 					rerenderEditMatrix();      
			        
				}
				else{
					hasError = true;
					errMsg = 'There is no available Country!';
				}
		    	
		    	if(hasError){
		    		if(cycle != null || cycle.Id != null){
		    			retURL += cycle.Id;
		    		}
		    		else{
		    			retURL += KEYPREFIX_CYCLE;
		    		}
		    		errMsg += ' Click<a href="' + retURL + '">here</a>to return back.'; 
		    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errMsg));
		    	}
			}
			else{
				retURL += KEYPREFIX_CYCLE;
				hasError = true;
				errMsg += 'Invalid Cycle! Click<a href="' + retURL + '">here</a>to return back.'; 
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errMsg));
			}
		}
		else{
			
			showDescription = true;
			
			if(matrix != null && matrix.Status_BI__c != null){
				if(matrix.Status_BI__c == MATRIX_STATUS_CALCULATED){
					errMsg += 'It is not possible to edit a matrix which has already been calculated! It is only possible to modify its description, segmentation and resource allocation. Click<a href="' + retURL + '">here</a>to return back.'; 
				}
				else{
					errMsg += 'It is not possible to edit a matrix with "' + matrix.Status_BI__c + '" status! It is only possible to modify its description. Click<a href="' + retURL + '">here</a>to return back.'; 
				}
			}
			else{
				errMsg += 'It is not possible to edit a matrix which has already been calculated! It is only possible to modify its description. Click<a href="' + retURL + '">here</a>to return back.'; 
			}
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
		}
    }
    /////////////////////////////////// -=END CONSTRUCTOR=- ///////////////////////////////////////
    
    
    //********************************* -=BEGIN public methods=- **********************************
   /**
	* This method is used to get list of Product by country id
	*
	@author  Peng Zhu
	@created 2013-05-24
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return  list_pd	list<SelectOption>
	*
	@changelog
	* 2013-05-24 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public list<SelectOption> getProductsByCountry(){
    	List<SelectOption> list_pd = new List<SelectOption>();
    	list_pd.add(new SelectOption('', '--None--'));
    	if(cycle != null && cycle.Country_Lkp_BI__c != null){
    		
    		//TODO:jescobar If it is a country for testing get the products based on the custom setting
    		if(countryTest!=null&&countryTest.Id!=null){
    			
    			for(Product_vod__c p : [SELECT Id, Name FROM Product_vod__c WHERE Active_BI__c = true 
    										AND Country_BI__r.Country_Code_BI__c = :countryTest.Country_Code_BI__c 
    											AND Product_Type_vod__c in :typeSetting ORDER BY Name]){//get Products from product config 
		        	if(p.Name != null) 
		        		list_pd.add(new SelectOption(p.Id, p.Name));
	    		}
    		}else{
    			for(Product_vod__c p : [SELECT Id, Name FROM Product_vod__c WHERE Active_BI__c = true AND Country_BI__c = :cycle.Country_Lkp_BI__c 
    									AND Product_Type_vod__c in :typeSetting ORDER BY Name]){
		        	//if(productId == null) productId = p.Id; 
		        	if(p.Name != null) 
		        		list_pd.add(new SelectOption(p.Id, p.Name));
	    		}
    		} 
    	}
    	
    	if(list_pd.isEmpty()){
    		if(!hasError){
	    		hasError = true;
    			errMsg = 'There is no available Products for this Cycle!'; 
    		}
    		
	    	list_pd.add(new SelectOption('', '--None--'));
    	}
    	
        return list_pd;
    }

	public void rerenderEditMatrix(){
		   	generateListOfCMENew();
	       	
	       	matrixIndex = 0;
	       	
	       	if(list_cmeFinal != null && !list_cmeFinal.isEmpty()){
	       		matrixIndex += list_cmeFinal.size();
	       	}
	       	
			if(list_cme != null && !list_cme.isEmpty()){
	        	//system.debug('**@@Peng list_cme : ' + list_cme);
	        	matrixIndex += list_cme.size();
	        }
	        
	        //Clear list specialties
	        list_clsSpcial.clear();
	        
	        if(countryCode!=null && mapSpecialtyConfig.containsKey(countryCode)){//Load list specialties for USA
	        	
	        	for(Specialty_Grouping_BI__c spG : list_specialtiesGroup){
	        		ClsSpecialization cs = new ClsSpecialization();
		        	cs.specialGrouping = spG;
		        	cs.Id = spG.Id;
		        	
		        	if(spG.Specialty_Group_BI__c != null && spG.Specialty_Group_BI__c.trim() != ''){
		    			cs.sName = spG.Specialty_Group_BI__c;
		    		}
		    		else if(spG.Name != null && spG.Name.trim() != ''){
		    			cs.sName = spG.Name;
		    		}
		    		
		    		cs.specialtiesAccount = '('+map_specialties_accounts.get(cs.sName)+')';
		        	
					if(set_usedSpecialIds.contains(spG.Id)){
						cs.isAssigned = true;
					}
					list_clsSpcial.add(cs);
	        	}
	        
	        }else{// Load list specialties rest of the world
	        	for(Customer_Attribute_BI__c s : list_special){
		        	ClsSpecialization cs = new ClsSpecialization();
		        	cs.special = s;
		        	cs.Id = s.Id;
		        	
		        	if(s.Group_txt_BI__c != null && s.Group_txt_BI__c.trim() != ''){
		    			cs.sName = s.Group_txt_BI__c;
		    		}
		    		else if(s.Name != null && s.Name.trim() != ''){
		    			cs.sName = s.Name;
		    		}
		    		
		    		cs.specialtiesAccount = '('+map_specialties_accounts.get(cs.sName)+')';
		        	
					if(set_usedSpecialIds.contains(s.Id)){
						cs.isAssigned = true;
					}
					
					list_clsSpcial.add(cs);
				}
	        }
	        
		//Set matrix templates available
		this.matrixTemplates = getMatrixTemplatesByCountry(productId);	
	}
	
   /**
	* This method is used to get list of lifecycle Templates by Country Id
	*
	@author  Peng Zhu
	@created 2013-05-24
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return  list_tp	list<SelectOption>
	*
	@changelog
	* 2013-05-24 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/    
    public list<SelectOption> getTemplatesByCountry(){
    	list<SelectOption> list_tp = new list<SelectOption>();
    	
    	if(cycle != null && cycle.Country_Lkp_BI__c != null){
    		for(Lifecycle_Template_BI__c mt : [SELECT Id, Name,isLaunch_Phase_BI__c FROM Lifecycle_Template_BI__c WHERE 	Country_BI__c = :cycle.Country_Lkp_BI__c AND Active_BI__c = TRUE ORDER BY Name]){
    			if(mt.Name != null) list_tp.add(new SelectOption(mt.Id, mt.Name));
    		}
    	}

    	if(list_tp.isEmpty()){
    		if(!hasError){
	    		hasError = true;
    			errMsg = 'There is no available Lifecycle Templates for this Cycle!'; 
    		}
	    	list_tp.add(new SelectOption('', '--None--'));
    	}
    	
        return list_tp;
    }
    
     /**
	* This method is used to get list of Matrix Templates by Country Id
	*
	@author  Jefferson Escobar
	@created 19-Aug-2014
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return  list_tp	list<SelectOption>
	*
	@changelog
	* 19-Aug-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/    
    public List<SelectOption> getMatrixTemplatesByCountry(String productId){
    	List<SelectOption> matrixTemplates = new List<SelectOption>();
    	matrixTemplates.add(new Selectoption('','--None--'));
    	
    	if(cycle != null && cycle.Country_Lkp_BI__c != null){
    		String query = 'Select Id,Name, Country_BI__c, Specialties_BI__c,Potential_Data_Label_BI__c,Adoption_Data_Label_BI__c,Product_Catalog_BI__c,Row_BI__c, Column_BI__c,Lifecycle_Template_BI__c, Specialty_Ids_BI__c '+
    							'From Matrix_Template_BI__c where Country_BI__c =\''+cycle.Country_Lkp_BI__c+'\' ';
    							
    		if(productId!=null&&productId.trim().length() > 0){
    			query+='And Product_Catalog_BI__c =\''+productId+'\' ';
    		}
    		query+='Order by Name';					
    		matrixTemplateList = '<select name="matrixTemplate" size="1" style="width:104px;" onchange="setMatrixTemplateInfo(this);"> <option value="">--None--</option>';
    		mapTemplates = new Map<String,Matrix_Template_BI__c>();
    		
    		system.debug(':: Query Template: ' + query);
    		for(Matrix_Template_BI__c mt : this.allMatrixTemplates){
    			if(productId != null && productId.equals(mt.Product_Catalog_BI__c)){
    				//Selectoption List
    				matrixTemplates.add(new SelectOption(mt.Id, mt.Name));
    				//Html list
    				matrixTemplateList+='<option value="'+mt.Id+'">' +mt.Name +'</option>';
    				mapTemplates.put(mt.Id,mt);
    			}else if(productId == null || productId.trim().length() == 0) {
    				matrixTemplates.add(new SelectOption(mt.Id, mt.Name));
    				//Html list
    				matrixTemplateList+='<option value="'+mt.Id+'">' +mt.Name +'</option>';
    				mapTemplates.put(mt.Id,mt);
    			}
    		}
    		matrixTemplateList+='</select>';
    	}
    	//Parse object to JSON Structure
    	jsonMatrixTemplate=Json.serialize(mapTemplates);
        
        return matrixTemplates;
    }

   /**
	* This method is used to get available specializations
	*
	@author  Peng Zhu
	@created 2013-05-24
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@changelog
	* 2013-05-24 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public list<Customer_Attribute_BI__c> getListOfSpecializations(){
    	map_id_sName.clear();
    	map_id_gName.clear();
    	map_specialties_accounts.clear();
    	list<Customer_Attribute_BI__c> list_special_temp = new list<Customer_Attribute_BI__c>();
    	set<string> set_group = new set<string>();
    	String s_name;
    	String query;
    	if(cycle != null && cycle.Country_Lkp_BI__c != null){
    	
    		String countryId = (countryTest!=null&&countryTest.Id!=null) ? countryTest.Id : cycle.Country_Lkp_BI__c;//TODO:jescobar
    		//Change the country id if the record belongs to a region zone
	    	if (countryCodeRegion != null && countryCodeRegion != ''){
	    		query='SELECT Id, RecordTypeId, Group_txt_BI__c, Country_BI__c, Country_Code_BI__c, Name,Summary_Specialties_Account_Number_BI__c ' + 
	    				'FROM Customer_Attribute_BI__c where Country_Code_BI__c = \''+countryCodeRegion+'\'';
	    	}else{
	    		query='SELECT Id, RecordTypeId, Group_txt_BI__c, Country_BI__c, Country_Code_BI__c, Name,Summary_Specialties_Account_Number_BI__c ' + 
	    				'FROM Customer_Attribute_BI__c where Country_BI__c = \''+countryId+'\'';
	    	}
	    	
	    	List<Customer_Attribute_BI__c> specialties = Database.query(query);
    		
	    	for(Customer_Attribute_BI__c s : specialties){
	    		s_name = '';
	    		Integer qSpecialtiesAccount = (s.Summary_Specialties_Account_Number_BI__c!=null) ? Integer.valueOf(s.Summary_Specialties_Account_Number_BI__c) : 0;
	    		if(s.Group_txt_BI__c != null && s.Group_txt_BI__c.trim() != ''){
	    			s_name = s.Group_txt_BI__c;
	    		}
	    		else if(s.Name.trim() != ''){
	    			s_name = s.Name;
	    		}
	    		
	    		//Get quantity of specialties by accounts
	    		if(!map_specialties_accounts.containsKey(s_Name)){
	    			map_specialties_accounts.put(s_name,qSpecialtiesAccount);
	    		}else{
	    			map_specialties_accounts.put(s_name,map_specialties_accounts.get(s_name)+qSpecialtiesAccount);
	    		}
	    		
	    		if(s_name != '' && !set_group.contains(s_name)){
		    		if(!map_id_gName.containsKey(s.Id) && s_name != ''){ 
		    			map_id_gName.put(s.Id, s_name);
		    			
		    		}
		    		
		    		if(!map_id_sName.containsKey(s.Id) && s.Name.trim() != ''){
			    		map_id_sName.put(s.Id, s.Name);
		    		}
		    		list_special_temp.add(s);
	    			set_group.add(s_name);
	    		}
	    	}
    	}
    	return list_special_temp;
    }
    
    
    /**
	* This method is used to get available specializations for USA
	*
	@author  Jefferson Escobar
	@created 20-Feb-2014
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@changelog
	* 20-Feb-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
    public list<Specialty_Grouping_BI__c> getListOfSpecializationsUSA(){
    	map_id_sName.clear();
    	map_id_gName.clear();
    	map_specialties_accounts.clear();
    	list<Specialty_Grouping_BI__c> list_special_temp_SPG = new list<Specialty_Grouping_BI__c>();
    	set<string> set_group = new set<string>();
    	String s_name;
    	if(cycle != null && cycle.Country_Lkp_BI__c != null){
    		
    		String countryId = (countryTest!=null&&countryTest.Id!=null) ? countryTest.Id : cycle.Country_Lkp_BI__c; //TODO:jescobar 
    		
	    	for(Specialty_Grouping_BI__c s : [SELECT Id, Name, Specialty_Group_BI__c, Summary_Specialties_Account_BI__c FROM Specialty_Grouping_BI__c WHERE Name != NULL AND Country_BI__c = :countryId ORDER BY Specialty_Group_BI__c, Name]){
	    		s_name = '';
	    		if(s.Specialty_Group_BI__c != null && s.Specialty_Group_BI__c.trim() != ''){
	    			s_name = s.Specialty_Group_BI__c;
	    		}
	    		else if(s.Name.trim() != ''){
	    			s_name = s.Name;
	    		}
	    		
	    		//Get quantity of specialties by accounts
	    		Integer qSpecialtiesAccount = (s.Summary_Specialties_Account_BI__c!=null) ? Integer.valueOf(s.Summary_Specialties_Account_BI__c) : 0;
	    		if(!map_specialties_accounts.containsKey(s_Name)){
	    			map_specialties_accounts.put(s_name,qSpecialtiesAccount);
	    		}else{
	    			map_specialties_accounts.put(s_name,map_specialties_accounts.get(s_name)+qSpecialtiesAccount);
	    		}
	    		
	    		if(s_name != '' && !set_group.contains(s_name)){
		    		if(!map_id_gName.containsKey(s.Id) && s_name != '') map_id_gName.put(s.Id, s_name);
		    		
		    		if(!map_id_sName.containsKey(s.Id) && s.Name.trim() != ''){
			    		map_id_sName.put(s.Id, s.Name);
		    		}
		    		
	    			list_special_temp_SPG.add(s);
	    			set_group.add(s_name);
	    		}
	    	}
    	}
    	
    	system.debug(':: Load Specialty sName ' +  map_id_sName + ' Id gName' + map_id_gName);
    	return list_special_temp_SPG;
    }

   /**
	* This method is used to get available Matrix Template by Country
	*
	@author  Peng Zhu
	@created 2013-05-24
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return	 rtSelect	Matrix Template  Select List
	*
	@changelog
	* 2013-05-24 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public string generateSelectOfMTByCountry(){
    	string rtSelect = '<select name="theMTSelecrList" class="mtSelectListCls" size="1">';
    	boolean hasRecords = false;
    	
    	map<id, ClsLifeCylceTemplate> map_id_clct = new map<id, ClsLifeCylceTemplate>();
    	
    	if(cycle != null && cycle.Country_Lkp_BI__c != null){
    		for(Lifecycle_Template_BI__c mt : [SELECT Id, Name, isLaunch_Phase_BI__c, Row_BI__c, Column_BI__c FROM Lifecycle_Template_BI__c WHERE Country_BI__c = :cycle.Country_Lkp_BI__c AND Active_BI__c = TRUE ORDER BY Name]){
    			rtSelect += '<option value="' + mt.Id + '">' + mt.Name + '</option>';
    			
    			//Begin: this is used in page when user select a template, we need change the rows ans columns values from the template
				ClsLifeCylceTemplate clct = new ClsLifeCylceTemplate();
				clct.lctId = mt.Id;
				if(mt.isLaunch_Phase_BI__c) clct.isLaunch = true;
				if(mt.Row_BI__c != null) clct.lctRow = mt.Row_BI__c.intValue();
				if(mt.Column_BI__c != null) clct.lctColumn = mt.Column_BI__c.intValue();
				
				map_id_clct.put(mt.Id, clct);
				//End: this is used in page when user select a template, we need change the rows ans columns values from the template
				
    			hasRecords = true;
    		}
    	}
    	rtSelect += '</select>';
    	
    	if(!hasRecords && !hasError){
    		hasError = true;
			errMsg = 'There is no available Lifecycle Templates for this Cycle!'; 
    	}
    	
    	jsonMTofLaunch = JSON.serialize(map_id_clct);
    	
    	return rtSelect;
    }

   /**
	* This method is used to cancel back to cycle detail page
	*
	@author  Peng Zhu
	@created 2013-05-24
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return  Pagereference
	*
	@changelog
	* 2013-05-24 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/  	
	public Pagereference cancel(){
		Pagereference page;
		
		if(map_urlParams.containsKey('retURL')){
			page = new Pagereference(map_urlParams.get('retURL'));
		}
		else if(cycle != null && cycle.Id != null){
			page = new Pagereference('/' + cycle.Id);
		}
		else{
			page = new Pagereference('/' + KEYPREFIX_CYCLE);
		}
		
		page.setRedirect(true);
		
		return page;
	}
	
	 /**
	* Update Matrix description
	* @return pageReference
	*/
    public PageReference save(){
		Savepoint sp = Database.setSavepoint();
		try{
			if(matrixDescription.Id != null){
				update matrixDescription;
			}	
		}catch(Exception e){
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage()) );
			system.debug('[ERROR]: ' + e.getMessage());
			Database.rollback(sp);
		}
		
		return new PageReference('/' + matrixDescription.Id);    	
    } 
    
   /**
	* This method is used to cancel back to cycle detail page
	*
	@author  Peng Zhu
	@created 2013-05-24
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return  Pagereference
	*
	@changelog
	* 2013-05-24 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/  	
	public Pagereference calculationMatrix(){
		Pagereference page;
		hasError = false;
		// Retrieve Task values 
		Id orgId = UserInfo.getOrganizationId();
		string matrixCalUrl;
		
		if(IMP_BI_Default_Setting__c.getInstance('Sandbox') != null && IMP_BI_Default_Setting__c.getInstance('Sandbox').Boolean_Value_BI__c == TRUE){
			
			if(IMP_BI_Default_Setting__c.getInstance('Sandbox Heroku Url') != null 
				&& IMP_BI_Default_Setting__c.getInstance('Sandbox Heroku Url').Text_Value_BI__c != null
				&& IMP_BI_Default_Setting__c.getInstance('Sandbox Heroku Url').Text_Value_BI__c.trim() != ''){
				
				matrixCalUrl = IMP_BI_Default_Setting__c.getInstance('Sandbox Heroku Url').Text_Value_BI__c.trim() + 'matrixCalculation/';
			}
			else{
				matrixCalUrl = 'https://boehringer-ingelheim-sandbox.herokuapp.com/itbconsult/queue/matrixCalculation/';
			}
		}
		else{
			if(IMP_BI_Default_Setting__c.getInstance('Production Heroku Url') != null 
				&& IMP_BI_Default_Setting__c.getInstance('Production Heroku Url').Text_Value_BI__c != null
				&& IMP_BI_Default_Setting__c.getInstance('Production Heroku Url').Text_Value_BI__c.trim() != ''){
				
				matrixCalUrl = IMP_BI_Default_Setting__c.getInstance('Production Heroku Url').Text_Value_BI__c.trim() + 'matrixCalculation/';
			}
			else{
				matrixCalUrl = 'https://boehringer-ingelheim.herokuapp.com/itbconsult/queue/matrixCalculation/';
			}
		}
		
		string matrixIds = '';
		
		set<Id> set_pid = new set<Id>();
		set<String> set_special = new set<String>();
		Set<Id> dpaMatrices = new Set<Id>(); 
		
		List<Matrix_BI__c> matricesToCalculate = [SELECT Id, Status_BI__c, DPA_BI__c, Product_Catalog_BI__c, Specialization_BI__c,isLaunch_Phase_BI__c  FROM Matrix_BI__c WHERE Status_BI__c = :MATRIX_STATUS_DRAFT 
								AND Cycle_BI__c = :cycle.Id 
								AND Calculate_BI__c = true];
								
		system.debug(':: Matrices to Calculate: ' + matricesToCalculate);												
		
		//Peng Zhu 2013-10-14
		for(Matrix_BI__c m : matricesToCalculate){
			matrixIds += m.Id + ',';
			
			if(m.Product_Catalog_BI__c != null && !set_pid.contains(m.Product_Catalog_BI__c)) 
				set_pid.add(m.Product_Catalog_BI__c);
			
			if(m.DPA_BI__c){
				dpaMatrices.add(m.Id);
			}
			else if(m.Specialization_BI__c != null){
				for(String str : m.Specialization_BI__c.split(';')){
					if(str != null && str.trim() != ''){
						str = str.trim();
						if(!set_special.contains(str)) set_special.add(str);					
					}
				}
			}
			
			//Set false matrices for being calculated for a next Process
			m.Calculate_BI__c = false;
		}
		//Update matrices for being calculated for a next Process
		Savepoint sp;
		try{
			sp = Database.setSavepoint();
			update matricesToCalculate;
		}catch(DmlException de){
    		Database.rollback(sp);
    		hasError = true;
			errMsg += 'An error has occurred calculating the matrices, please contact your administrator';
			system.debug('[ERROR] - ' + de.getMessage());
    	}
		
		if(matrixIds == null || matrixIds.trim() == ''){
			//add error
			hasError = true;
			errMsg += 'There are no matrices with Status "Draft" and selected to calculate!'; 
		}
		else{
			if(!test.isRunningTest()){
				matrixIds = matrixIds.substring(0, matrixIds.length() - 1);
			}
			
			system.debug(':: Params: ' +cycle.Id +  ' Products  '+ set_pid  + ' Specialties ' + set_special);
			if(set_special!=null && !set_special.isEmpty()){
				map<Id, Cycle_Data_BI__c> map_id_cd = new map<Id, Cycle_Data_BI__c>([SELECT Id, Cycle_BI__c, Product_Catalog_BI__c, Specialty_BI__c FROM Cycle_Data_BI__c 
																					WHERE Cycle_BI__c = :cycle.Id AND Product_Catalog_BI__c IN :set_pid AND Specialty_BI__c IN :set_special limit 1]);
																					
				if(map_id_cd == null || map_id_cd.isEmpty()){//Validate Cycle data NOT DPA Matrices
					hasError = true;
					errMsg = 'There are no available Cycle Data for calculating!';
				
				}
			}
			
			if (dpaMatrices!=null && !dpaMatrices.isEmpty()){//Validate Cycle data NOT DPA Matrices
				for(Matrix_BI__c m : [SELECT Id, (Select Id From Cycle_Data__r limit 1)  FROM Matrix_BI__c WHERE Id = :dpaMatrices]){
					
					if(m.Cycle_Data__r==null || m.Cycle_Data__r.isEmpty()){
						hasError = true;
						errMsg = 'There are no available Cycle Data for calculating!';
						break;					
					}
				}
			}
		} 
		
		string calUrl = matrixCalUrl + orgId +'&' + cycle.Id + '&' + cycle.Country_Lkp_BI__r.Country_Code_BI__c + '&' + matrixIds;
		calcuUrl = '';
		
		page = new Pagereference(calUrl);
		
		page.setRedirect(true);
		
		if(hasError){
			string retURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
			if(cycle != null && cycle.Id != null) retURL += cycle.Id;
			else retURL += KEYPREFIX_CYCLE;
			
			errMsg += ' Click<a href="' + retURL + '">here</a>to return back.'; 
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errMsg));
    		return null;
		}
		else{
			calcuUrl = calUrl;
		}

		//return null;
		return page;
	}
    
    /**
	* This method is used to save matrixs to sfdc
	*
	@author  Peng Zhu
	@created 2013-05-24
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@parm	 finalResult   json string of ClsMatrix object
	*
	@return  string
	*
	@changelog
	* 2013-05-24 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/    
    @RemoteAction
    global static String saveMatrixData(string finalResult){
    	Response r = new Response();
    	Savepoint sp = Database.setSavepoint();
    	
    	try{
	    	ClsMatrix cm = (ClsMatrix)JSON.deserialize(finalResult, ClsMatrix.class);
	    	system.debug(':: Country Id: ' + cm.countryId);
	    	
	    	if(cm != null && cm.list_cm != null && !cm.list_cm.isEmpty() && cm.set_mtIds != null && !cm.set_mtIds.isEmpty()){
	    		set<String> set_sId = new set<String>();
	    		map<Id, String> map_id_nStr = new map<Id, String>();
	    		map<Id, String> map_id_gStr = new map<Id, String>();
	    		map<String, String> map_gStr_nStr = new map<String, String>();
	    		
	    		if(cm.set_sId != null && !cm.set_sId.isEmpty()){
	    			set_sId.addAll(cm.set_sId);
	    		} 
	    		
	    		if(cm.countryId != null && cm.countryId.trim() != ''){
	    			
	    			Map<String,Specialty_Grouping_Config__c> mapSpecialtyConfig = Specialty_Grouping_Config__c.getAll(); 
	    			
	    			if(cm.countryCode!=null && mapSpecialtyConfig.containsKey(cm.countryCode)){
	    				
	    				String countryId = (cm.countryTestId !=null && cm.countryTestId.trim().length() >0) ? cm.countryTestId :  cm.countryId;//TODO:jescobar testing
	    														
	    				for(Specialty_Grouping_BI__c spG : [SELECT Id, Name, Specialty_Group_BI__c FROM Specialty_Grouping_BI__c WHERE Name != NULL AND Country_BI__c = :countryId ORDER BY Specialty_Group_BI__c, Name]){
				    		if(spG.Specialty_Group_BI__c != null && spG.Specialty_Group_BI__c.trim() != ''){
				    			if(set_sId.contains(spG.Id)) map_id_gStr.put(spG.Id, spG.Specialty_Group_BI__c);
				    			
				    			if(!map_gStr_nStr.containsKey(spG.Specialty_Group_BI__c)){
				    				map_gStr_nStr.put(spG.Specialty_Group_BI__c, spG.Name);
				    			}
				    			else{
				    				map_gStr_nStr.put(spG.Specialty_Group_BI__c, (map_gStr_nStr.remove(spG.Specialty_Group_BI__c) + ';' + spG.Name));
				    			}
				    		}
				    		else if(set_sId.contains(spG.Id)){
				    			map_id_nStr.put(spG.Id, spG.Name);
				    		}
				    	}
	    				
	    			}else{
	    				
	    				String query;
	    				String countryId = (cm.countryTestId !=null && cm.countryTestId.trim().length() >0) ? cm.countryTestId :  cm.countryId;//TODO:jescobar testing
	    				//Change the country id if the record belongs to a region zone
				    	if (cm.countryCodeRegion != null && cm.countryCodeRegion != ''){
				    		query='SELECT Id, RecordTypeId, Group_txt_BI__c, Country_BI__c, Country_Code_BI__c, Name ' + 
				    				'FROM Customer_Attribute_BI__c where Country_Code_BI__c = \''+cm.countryCodeRegion+'\'';
				    	}else{
				    		query='SELECT Id, RecordTypeId, Group_txt_BI__c, Country_BI__c, Country_Code_BI__c, Name ' + 
				    				'FROM Customer_Attribute_BI__c where Country_BI__c = \''+countryId+'\'';
				    	}
				    	
				    	List<Customer_Attribute_BI__c> specialties = Database.query(query);
				    				
		    			for(Customer_Attribute_BI__c s : specialties){
				    		if(s.Group_txt_BI__c != null && s.Group_txt_BI__c.trim() != ''){
				    			if(set_sId.contains(s.Id)) map_id_gStr.put(s.Id, s.Group_txt_BI__c);
				    			
				    			if(!map_gStr_nStr.containsKey(s.Group_txt_BI__c)){
				    				map_gStr_nStr.put(s.Group_txt_BI__c, s.Name);
				    			}
				    			else{
				    				map_gStr_nStr.put(s.Group_txt_BI__c, (map_gStr_nStr.remove(s.Group_txt_BI__c) + ';' + s.Name));
				    			}
				    		}
				    		else if(set_sId.contains(s.Id)){
				    			map_id_nStr.put(s.Id, s.Name);
				    		}
				    	}
	    			}
	    		}
	    		
		    	Lifecycle_Template_BI__c mt_temp;
		    	
		    	map<id, Lifecycle_Template_BI__c> map_id_mt;
	    		
	    		//added by Peng Zhu 2013-05-20
	    		map_id_mt = new map<id, Lifecycle_Template_BI__c>([SELECT Id, Row_BI__c, Column_BI__c, Dimension_1_Name_BI__c, Dimension_2_Name_BI__c, Product_LifeCycle_BI__c, Adoption_Weight_Factor_BI__c, Potential_Weight_Factor_BI__c FROM Lifecycle_Template_BI__c WHERE Id IN :cm.set_mtIds]);
		    	
	    		if(map_id_mt != null && !map_id_mt.isEmpty()){
		    			
		    		list<Matrix_BI__c> list_matrix = new list<Matrix_BI__c>();
			    	
			    	//Begin: added by Peng Zhu 2013-05-28 for editing case
			    	set<id> set_mIds = new set<id>();
			    	for(ClsMatrixs cms : cm.list_cm){
			    		if(cms.mid != null && cms.mid.trim() != '' && cms.tid != null && map_id_mt.containsKey(cms.tid)){
							set_mIds.add(cms.mid);
		    			}
		    			else{
		    				continue;
		    			}
			    	}
			    	
		    		//Peng Zhu 2013-10-14
			    	map<id, Matrix_BI__c> map_id_matrix = new map<id, Matrix_BI__c>([SELECT Id, DPA_BI__c, isLaunch_Phase_BI__c, Name_BI__c, Row_BI__c, Column_BI__c, Cycle_BI__c, Dimension_1_Name_BI__c, Dimension_2_Name_BI__c, Lifecycle_Template_BI__c, Product_Catalog_BI__c, Status_BI__c, Specialization_BI__c, Matrix_Template_BI__c FROM Matrix_BI__c WHERE Id IN :set_mIds]);
			    	
			    	//End: added by Peng Zhu 2013-05-28
			    		
			    		
		    		for(ClsMatrixs cms : cm.list_cm){
		    			if(cms.tid != null && map_id_mt.containsKey(cms.tid)){
			    			mt_temp = map_id_mt.get(cms.tid);
		    			}
		    			else{
		    				continue;
		    			}
		    			
		    			Matrix_BI__c m;
		    			if(cms.mid != null && cms.mid.trim() != '' && map_id_matrix != null && map_id_matrix.containsKey(cms.mid)){
		    				m = map_id_matrix.get(cms.mid);
		    			}else{
			    			m = new Matrix_BI__c();
		    			}
		    			
			    		if(cm.cid != null && cm.cid.trim() != '') m.Cycle_BI__c = cm.cid;	
			    		m.Status_BI__c = 'Draft';
		    			if(mt_temp.Id != null) m.Lifecycle_Template_BI__c = mt_temp.Id;
		    			//Begin: copy data from Matrix Template
		    			//if(mt_temp.Row_BI__c != null) m.Row_BI__c = mt_temp.Row_BI__c;
		    			//if(mt_temp.Column_BI__c != null) m.Column_BI__c = mt_temp.Column_BI__c;
		    			if(cms.row != null) m.Row_BI__c =cms.row;
		    			if(cms.column != null) m.Column_BI__c = cms.column;
		    			
		    			if(mt_temp.Dimension_1_Name_BI__c != null) m.Dimension_1_Name_BI__c = mt_temp.Dimension_1_Name_BI__c;
		    			if(mt_temp.Dimension_2_Name_BI__c != null) m.Dimension_2_Name_BI__c = mt_temp.Dimension_2_Name_BI__c;
		    			
		    			//Set matrix template Id
		    			if(cms.matrixTemplateId != null&&cms.matrixTemplateId.trim().length()>0){
		    				m.Matrix_Template_BI__c = cms.matrixTemplateId;
		    			}else{
		    				m.Matrix_Template_BI__c = null;
		    			}
		    			//End: copy data from Matrix Template

		    			if(cm.productId != null && cm.productId.trim() != '') m.Product_Catalog_BI__c = cm.productId;
			    		m.DPA_BI__c = cms.dpa;
			    		if(cms.allCustomers != NULL) m.All_Customers_BI__c = cms.allCustomers;
		    			m.Name_BI__c = cms.name;
		    			
		    			//system.debug(':: Matrix: ' + m.Name_BI__c + ' M Template: ' + m.Matrix_Template_BI__c);
		    			///m.Specialization_BI__c = cms.special;
		    			//Begin: added by Peng Zhu 2013-07-14 for speciality calculation
		    			String s_name;
						if(cms.set_sId != null && !cms.set_sId.isEmpty()){
							for(String str : cms.set_sId){
								if(str != null && str.trim() != ''){
									str = str.trim();
									
									if(map_id_nStr.containsKey(str)){
										if(s_name != null && s_name != ''){
											s_name += ';' + map_id_nStr.get(str);
										}
										else{
											s_name = map_id_nStr.get(str);
										}
									}
									else if(map_id_gStr.containsKey(str) && map_gStr_nStr.containsKey(map_id_gStr.get(str))){
										if(s_name != null && s_name != ''){
											s_name += ';' + map_gStr_nStr.get(map_id_gStr.get(str));
										}
										else{
											s_name = map_gStr_nStr.get(map_id_gStr.get(str));
										}								
									}
								}
							}
						}	
						m.Specialization_BI__c = s_name; 			//Peng Zhu 2013-10-14
						
						//@jescobar: Add field for adoption and potentilas labels
						m.Adoption_Data_Label_BI__c = cms.adoptionLabel; 			
						m.Potential_data_Label_BI__c = cms.potentialLabel; 	
						m.Calculate_BI__c = cms.toCalculate;system.debug(':: To calculate: ' + cms.toCalculate);		
		    			//End: added by Peng Zhu 2013-07-14
		    			list_matrix.add(m);
		    		}
			    		
		    		if(!list_matrix.isEmpty()){
		    			upsert list_matrix;
			    			
			    		for(list<Matrix_Cell_BI__c> list_mc : [SELECT Id FROM Matrix_Cell_BI__c WHERE Matrix_BI__c IN :map_id_matrix.keySet()]){
			    			delete list_mc;
			    		}	
			    		
		    			list<Matrix_Cell_BI__c> list_mc = new list<Matrix_Cell_BI__c>();
		    			decimal potential_weight = 0, adoption_weight = 0;
		    			for(Matrix_BI__c m : list_matrix){
		    				potential_weight = (100.0/m.Row_BI__c).setScale(2);
		    				if(m.Column_BI__c > 1) adoption_weight =  (100.0/(m.Column_BI__c - 1)).setScale(2);
		    				
		    				if(m.Row_BI__c != null && m.Column_BI__c != null){
		    					for(integer i=1; i <= m.Row_BI__c; i++){
		    						for(integer j=0; j < m.Column_BI__c; j++){
		    							//potential_weight = 0;
		    							//adoption_weight = 0;
		    							
		    							Matrix_Cell_BI__c mc = new Matrix_Cell_BI__c();
					    				mc.Matrix_BI__c = m.Id;
		
					    				mc.Row_BI__c = i;
					    				mc.Column_BI__c = j;
					    				mc.Segment_BI__c = 'Blank';
						    			//adoption_weight = 2 - potential_weight;	
						    			
						    			//strategic_weight = potential_weight * i + adoption_weight * j;
						    			if(map_id_mt.containsKey(m.Lifecycle_Template_BI__c) 
						    				&& map_id_mt.get(m.Lifecycle_Template_BI__c).Adoption_Weight_Factor_BI__c != null
						    				&& map_id_mt.get(m.Lifecycle_Template_BI__c).Potential_Weight_Factor_BI__c != null
						    				&& potential_weight != null
						    				&& adoption_weight != null){
						    				
							    			mc.Strategic_Weight_BI__c = map_id_mt.get(m.Lifecycle_Template_BI__c).Potential_Weight_Factor_BI__c * potential_weight * i + map_id_mt.get(m.Lifecycle_Template_BI__c).Adoption_Weight_Factor_BI__c * adoption_weight * j;
						    			}
						    		
					    				list_mc.add(mc);
		    						}
		    					}
		    				}
	    				}	
		    			if(!list_mc.isEmpty()){
		    				insert list_mc;
		    			}
		    		}
	    		}
	    		else{
	    			r.success = false;
	    			r.message = 'The Matrix Template not exist!';
	    			return JSON.serialize(r);
	    		}
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
	* This method is used to initialize the required variable
	*
	@author  Peng Zhu
	@created 2013-05-24
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return  void
	*
	@changelog
	* 2013-05-24 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/ 
    private void init(){
    	productId = '';
        calcuUrl = '';
		hasError = false;
		set_usedSpecialIds = new set<Id>();
        list_specilIndex = new list<String>();
        list_clsSpcial = new list<ClsSpecialization>();
		
		//Picklist by default
		//getMatrixTemplatesByCountry(false,null);
		this.matrixTemplates = new List<Selectoption>();
		this.matrixTemplates.add(new Selectoption('','--None--'));
        
        //initialize the page title
        pageTitle = system.label.Matrix_Creation;
        sectionHeaderTitle = system.label.Matrix_Creation;
        sectionHeaderSubTitle = system.label.Matrix_Creation;
        
        map_id_sName = new map<Id, String>();
        map_id_gName = new map<Id, String>();
        map_specialties_accounts = new Map<String, Integer>();
    }

   /**
	* This method is used to generate the exist matrix list
	*
	@author  Peng Zhu
	@created 2013-05-24
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return  void
	*
	@changelog
	* 2013-05-24 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/ 
    private void generateListOfCMENew(){
    	list_cme = new list<ClsMatrixEdit>();
    	list_cmeFinal = new list<ClsMatrixEdit>();
    	
    	set_usedSpecialIds.clear();
    	////Peng Zhu 2013-10-14
   		String queryStr = ' SELECT Id, Name_BI__c, DPA_BI__c, isLaunch_Phase_BI__c, All_Customers_BI__c, Product_Catalog_BI__c, Adoption_Data_Label_BI__c,Potential_data_Label_BI__c, Status_BI__c, Specialization_BI__c, Row_BI__c, Cycle_BI__c, Column_BI__c, Lifecycle_Template_BI__c, Lifecycle_Template_BI__r.Name,Matrix_Template_BI__c  FROM Matrix_BI__c WHERE Cycle_BI__c = \'' + cycle.Id + '\' AND Status_BI__c IN :SET_MATRIX_STATUS_EDIT ';
   		
   		String queryStrFinal = ' SELECT Id, Name_BI__c, DPA_BI__c, isLaunch_Phase_BI__c , All_Customers_BI__c, Adoption_Data_Label_BI__c,Potential_data_Label_BI__c, Product_Catalog_BI__c, Status_BI__c, Specialization_BI__c, Row_BI__c, Cycle_BI__c, Column_BI__c, Lifecycle_Template_BI__c, Lifecycle_Template_BI__r.Name, Matrix_Template_BI__c  FROM Matrix_BI__c WHERE Cycle_BI__c = \'' + cycle.Id + '\' AND Status_BI__c NOT IN :SET_MATRIX_STATUS_EDIT ';
		
		if(productId != null && productId.trim() != ''){
			queryStr += ' AND Product_Catalog_BI__c = \'' + productId + '\'';
			queryStrFinal += ' AND Product_Catalog_BI__c = \'' + productId + '\'';
		}
		
		//map_id_sName
		//added by Peng Zhu 2013-07-03
		for(Matrix_BI__c m : Database.query(queryStrFinal)){
			
			ClsMatrixEdit cme = new ClsMatrixEdit();
			cme.matrix = m;
			//if(m.Status_BI__c == 'Calculated' || m.Status_BI__c == 'Final') cme.isCalculated = true;
			if(SET_MATRIX_STATUS_NON_EDIT.contains(m.Status_BI__c)) cme.isCalculated = true;
			
			//TODO: split specialization on Matrix
			list<ClsMatrixSpecial> list_cms = new list<ClsMatrixSpecial>();
			
			set<string> set_s = new set<string>();

			//Peng Zhu 2013-10-14
			if(m.Specialization_BI__c != null && m.Specialization_BI__c.trim() != ''){
				for(string str : m.Specialization_BI__c.split(';')){
					if(str.trim() != ''){
						set_s.add(str.trim());
						//ClsMatrixSpecial cms = new ClsMatrixSpecial();
						//cms.sId = 'finalId';
						//cms.sName = str.trim();
						
						//list_cms.add(cms);
					}
				}
				
				set<id> set_sIdExist = new set<id>();
				set<String> set_gName = new set<String>();
				String s_name;
				
				system.debug(':: Map Id sName: ' + map_id_sName.keySet() + ' set_s: ' + set_s );
				
				//map_id_gName
				for(Id sId : map_id_sName.keySet()){
					if(set_s.contains(map_id_sName.get(sId)) && !set_sIdExist.contains(sId)){
						ClsMatrixSpecial cms = new ClsMatrixSpecial();
						cms.sId = sId;
						
						if(map_id_gName.containsKey(sId)){
							if(!set_gName.contains(map_id_gName.get(sId))){
								cms.sName = map_id_gName.get(sId);
								set_gName.add(map_id_gName.get(sId));
							}
							else{
								continue;						
							}
						}
						else{
							cms.sName = map_id_sName.get(sId);
						}
						
						if(!SET_MATRIX_STATUS_SPECIAL.contains(m.Status_BI__c)) set_usedSpecialIds.add(sId);
						
						list_cms.add(cms);
						set_sIdExist.add(sId);
					}
				}
				
			}
			
			if(set_s.size() > specialCounter) specialCounter = set_s.size();
			
			cme.list_cms = list_cms;
			
			list_cmeFinal.add(cme);
		}
		
		for(ClsMatrixEdit cme : list_cmeFinal){
			//placeholder
			if(cme.list_cms.size() < specialCounter){
				for(integer i = cme.list_cms.size(); i < specialCounter; i++){
					ClsMatrixSpecial cms = new ClsMatrixSpecial();
					cms.sId = '';
					cms.sName = '';
					
					cme.list_cms.add(cms);
				}
			}
		}
		
		for(Matrix_BI__c m : Database.query(queryStr)){
			
			ClsMatrixEdit cme = new ClsMatrixEdit();
			cme.matrix = m;
			if(m.Status_BI__c == 'Calculated') cme.isCalculated = true;
			
			//TODO: split specialization on Matrix
			set<string> set_s = new set<string>();

			//Peng Zhu 2013-10-14
			if(m.Specialization_BI__c != null && m.Specialization_BI__c.trim() != ''){
				for(string str : m.Specialization_BI__c.split(';')){
					if(str.trim() != '') set_s.add(str.trim());
				}
			}
			
			
			//TODO: generate list of specialization (id and name) for Matrix
			set<id> set_sIdExist = new set<id>();
			set<String> set_gName = new set<String>();
			list<ClsMatrixSpecial> list_cms = new list<ClsMatrixSpecial>();
			String s_name;
			
			//map_id_gName
			for(Id sId : map_id_sName.keySet()){
				if(set_s.contains(map_id_sName.get(sId)) && !set_sIdExist.contains(sId)){
					ClsMatrixSpecial cms = new ClsMatrixSpecial();
					cms.sId = sId;
					
					if(map_id_gName.containsKey(sId)){
						if(!set_gName.contains(map_id_gName.get(sId))){
							cms.sName = map_id_gName.get(sId);
							set_gName.add(map_id_gName.get(sId));
						}
						else{
							continue;						
						}
					}
					else{
						cms.sName = map_id_sName.get(sId);
					}
					
					////Commented out by Peng Zhu 2013-07-30
					set_usedSpecialIds.add(sId);
					
					list_cms.add(cms);
					set_sIdExist.add(sId);
				}
			}
			/**
			if(list_special != null && !list_special.isEmpty()){
				//warning : here will lost the specialization that not in list_special
				//set<String> set_gName = new set<String>();
				
				for(Customer_Attribute_BI__c s : list_special){
					s_name = '';
					
		    		if(s.Group_txt_BI__c != null && s.Group_txt_BI__c.trim() != ''){
		    			s_name = s.Group_txt_BI__c;
		    		}
		    		else if(s.Name != null && s.Name.trim() != ''){
		    			s_name = s.Name;
		    		}
					
					if(s_name != '' && set_s.contains(s_name) && !set_sIdExist.contains(s.Id)){
						ClsMatrixSpecial cms = new ClsMatrixSpecial();
						cms.sId = s.Id;
						cms.sName = s_name;
						
						set_usedSpecialIds.add(s.Id);
						
						list_cms.add(cms);
						set_sIdExist.add(s.Id);
					}
				}
			}
			**/
			//placeholder
			if(list_cms.size() < specialCounter){
				for(integer i = list_cms.size(); i < specialCounter; i++){
					ClsMatrixSpecial cms = new ClsMatrixSpecial();
					cms.sId = '';
					cms.sName = '';
					
					list_cms.add(cms);
				}
			}
			
			cme.list_cms = list_cms;
			
			list_cme.add(cme);
		}
		
		system.debug(':: list_cme' + list_cme);
		system.debug(':: list_cmeFinal' + list_cmeFinal);
    }
    //********************************* -=END private methods=- ***********************************
    
    
    //********************************* -=BEGIN help functions=- **********************************
    //********************************* -=END help functions=- ************************************
    
    //********************************* -=BEGIN inner classes=- ***********************************
    ///*>>>WrapperClass*/
    public class ClsLifeCylceTemplate{
    	public id lctId;
    	public boolean isLaunch;
    	public integer lctRow;
    	public integer lctColumn;
    	
    	public ClsLifeCylceTemplate(){
    		isLaunch = false;
	    	lctRow = 0;
    		lctColumn = 0;
    	}
    }
    
    public class ClsMatrixEdit{
    	public Matrix_BI__c matrix {get; set;}
    	public list<ClsMatrixSpecial> list_cms {get; set;}
    	public boolean isCalculated {get; set;}
    	
    	public ClsMatrixEdit(){
    		isCalculated = false;
    	}
    }
    
    public class ClsSpecialization{
    	public Customer_Attribute_BI__c special {get; set;}
    	public Specialty_Grouping_BI__c specialGrouping {get; set;}
    	public Id Id {get; set;}
    	public boolean isAssigned {get; set;}
    	public String sName {get; set;}
    	public String specialtiesAccount {get; set;}
    	
		public ClsSpecialization(){
			isAssigned = false;
			sName = '';
		} 
    }

    public class ClsMatrixSpecial{
    	public string sId {get; set;}
    	public string sName {get; set;}
    	
    	public ClsMatrixSpecial(){}
    }
    
    public class ClsMatrix{
    	public string countryId;
    	public String countryCode;
    	public String countryCodeRegion;
    	public String countryTestId;
    	public string productId;
    	public string cid;
    	public string tid;//matrix template id --  added by Peng Zhu 2013-05-13
    	public list<ClsMatrixs> list_cm;
    	public set<String> set_mtIds;
    	public set<String> set_sId;
    	
    	public ClsMatrix(){
    		list_cm = new list<ClsMatrixs>();
    		set_mtIds = new set<String>();
    		set_sId = new set<String>();
    	}
    }
    
    public class ClsMatrixs{
    	public string mid;
    	public string name;
    	public string special;
    	public string lifeCycle;
    	public string tid;
    	public String matrixTemplateId;
    	public integer row;
    	public integer column;
    	public boolean dpa;
    	public boolean allCustomers;
    	public String adoptionLabel;
    	public String potentialLabel;
    	public boolean toCalculate;
    	
    	public set<String> set_sId;
    	
    	public ClsMatrixs(){
    		set_sId = new set<String>();
    		dpa = false;
    		allCustomers = false;
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