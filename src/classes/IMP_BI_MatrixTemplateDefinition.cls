/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      New/Edit Matrix Template Page
*  @author:         Jefferson Escobar
*  @created:        21-May-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			30.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         21-May-2014                 jescobar                 	Construction of the class.
*/ 

public class IMP_BI_MatrixTemplateDefinition {
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	public static final string KEYPREFIX_COUNTRY = Schema.SObjectType.Country_BI__c.getKeyPrefix();

	public Integer specialCounter {get; private set;}
	public Matrix_Template_BI__c matrixTemplate {get;private set;}
	
	public List<Customer_Attribute_BI__c> list_special {get; private set;}
	public List<Specialty_Grouping_BI__c> list_specialtiesGroup {get; private set;}
	public List<ClsSpecialization> list_clsSpcial {get; private set;}
	
	public Country_BI__c country {get; private set;}
	
	
	/**Select List*/
	public List<SelectOption> products {get; private set;}
	public List<SelectOption> cycleTemplates {get; private set;}
	public String jsonMTofLaunch {get; private set;}
	 
	private Set<String> typeSetting = IMP_BI_Product_Catalog_Setting__c.getAll().keySet();
	public boolean hasError {get; private set;}
	public String mtSelectList {get; private set;}
	
	
	//Paramerters to load specialties based on Country
	public String countryCode {get; private set;}
	public String countryCodeRegion {get; private set;}
	private map<Id, Customer_Attribute_BI__c> map_id_cab;
	private Map<String,Specialty_Grouping_Config__c> mapSpecialtyConfig;
	public  Set<String> mapSpecialties;
	private Set<String> set_Specialties;
    
    //for page title
    public static final String LABEL_MATRIX_TEMPLATE = Schema.SObjectType.Matrix_Template_BI__c.getLabel();
    public String pageTitle {get; private set;}
    public String sectionHeaderTitle {get; private set;}
    public String sectionHeaderSubTitle {get; private set;}
    
    public String calcuUrl {get; private set;}
    
    //public string jsonOfCalcuInfo {get; set;}
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    private Map<String, String> map_urlParams;
    private String errMsg = ''; 
     
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    /////////////////////////////////// -=BEGIN CONSTRUCTOR=- ////////////////////////////////////
    
    
    /**
    * Standard controller constructor
    */
    public IMP_BI_MatrixTemplateDefinition(ApexPages.standardController ctr){
    	hasError=false;
    	mapSpecialtyConfig = Specialty_Grouping_Config__c.getAll();//Load specialty settings
    	
    	if(ctr.getId()!=null){//Edit Matrix Template
    		//Load matrix template record
    		matrixTemplate = [Select Id,Name, Country_BI__c, Specialties_BI__c,Specialty_Ids_BI__c ,Potential_Data_Label_BI__c,Adoption_Data_Label_BI__c,Product_Catalog_BI__c,Row_BI__c, Column_BI__c,Lifecycle_Template_BI__c 
    							From Matrix_Template_BI__c where Id = :ctr.getId()];
    		 
    		country = [Select Id,Name,Country_Code_BI__c,Country_Code_Region_BI__c From Country_BI__c where Id = :matrixTemplate.Country_BI__c];
    		countryCode = country.Country_Code_BI__c;
    		countryCodeRegion = (country.Country_Code_Region_BI__c!=null&&country.Country_Code_Region_BI__c != '') ? country.Country_Code_Region_BI__c : null;
    		
    		//Get select options 		
			products = getProductsByCountry(country.Id);
			cycleTemplates = getCycleTemplatesByCountry(country.Id);
			
			//Set specialties selected at the matrix template
			if(matrixTemplate.Specialties_BI__c != null && matrixTemplate.Specialties_BI__c.trim().length()>0){
				set_Specialties = new Set<String>();
				for(String s : matrixTemplate.Specialties_BI__c.replace('&','').split(';')){
					set_Specialties.add(s);
				}
			} 
    		
    		sectionHeaderSubTitle = matrixTemplate.Name;
		    sectionHeaderTitle = LABEL_MATRIX_TEMPLATE + ' Edit';
		    pageTitle = LABEL_MATRIX_TEMPLATE + ' ' + sectionHeaderTitle;
		    
		    //Load Specialties by Country
		    if(countryCode!=null&&mapSpecialtyConfig.containsKey(countryCode)){//Get specialties for USA
    			getSpecialtiesUSA();
    		}else{//Get specialties for countries differents to USA
    			getSpecialtiesWorldWide();
    		}
    	
    	}else{// Create a new Matrix Template
			
    		//initialize the page title
		    sectionHeaderSubTitle = 'New ' + LABEL_MATRIX_TEMPLATE;
		    sectionHeaderTitle = LABEL_MATRIX_TEMPLATE + ' Edit';
		    pageTitle = LABEL_MATRIX_TEMPLATE + ' ' + sectionHeaderTitle;
		    
		    //Get URL parameters and load country parent record	    		
    		map_urlParams = ApexPages.currentPage().getParameters();
    		Id idCountry = (map_urlParams != null && map_urlParams.containsKey('cId')) ? map_urlParams.get('cId') : null;
    		
    		if(idCountry!=null){
    			country = [Select Id,Name,Country_Code_BI__c,Country_Code_Region_BI__c From Country_BI__c where Id = :idCountry];
    			countryCode = country.Country_Code_BI__c;
    			countryCodeRegion = (country.Country_Code_Region_BI__c!=null&&country.Country_Code_Region_BI__c != '') ? country.Country_Code_Region_BI__c : null;
    			
    			matrixTemplate = new Matrix_Template_BI__c(Country_BI__c = country.Id);
    			
    			//fill out values from Matrix definition
    			String specialties = (map_urlParams.get('specialties')!=null && map_urlParams.get('specialties').length()>0) ? map_urlParams.get('specialties') : null;
    			matrixTemplate.Product_Catalog_BI__c= (map_urlParams.get('pId')!=null && map_urlParams.get('pId').length()>0) ? map_urlParams.get('pId') : null;
    			matrixTemplate.Lifecycle_Template_BI__c=(map_urlParams.get('lctId')!=null && map_urlParams.get('lctId').length()>0) ? map_urlParams.get('lctId') : null;
    			matrixTemplate.Row_BI__c = (map_urlParams.get('row')!=null && map_urlParams.get('row').length()>0) ? Integer.valueOf(map_urlParams.get('row')) : null;
    			matrixTemplate.Column_BI__c=(map_urlParams.get('col')!=null && map_urlParams.get('col').length()>0) ? Integer.valueOf(map_urlParams.get('col')) : null;
    			matrixTemplate.Potential_Data_Label_BI__c=(map_urlParams.get('ptLabel')!=null && map_urlParams.get('ptLabel').length()>0) ? map_urlParams.get('ptLabel') : null;
    			matrixTemplate.Adoption_Data_Label_BI__c=(map_urlParams.get('adtpLabel')!=null && map_urlParams.get('adtpLabel').length()>0) ? map_urlParams.get('adtpLabel') : null;
    			
    			//Set specialties selected at the matrix template
				if(specialties != null && specialties.trim().length()>0){
					set_Specialties = new Set<String>();
					for(String s : specialties.split(';')){
						set_Specialties.add(s);
					}
				}
				
				system.debug(':: Specialties URL:  ' + specialties + ' Ids: ' + set_Specialties);
    			
    			//Get select options 		
				products = getProductsByCountry(country.Id);
				cycleTemplates = getCycleTemplatesByCountry(country.Id);
				
				//Load Specialties by Country
				if(countryCode!=null&&mapSpecialtyConfig.containsKey(countryCode)){//Get specialties for USA
	    			getSpecialtiesUSA();
	    		}else{//Get specialties for countries differents to USA
	    			getSpecialtiesWorldWide();
	    		}
				
    		}else{
    			hasError=true;
    		}
    		
    	}
    	
    	//if any error
    	if(hasError){
			errMsg += 'Invalid Country  Click<a href=/' + KEYPREFIX_COUNTRY + '>here</a>to return back.'; 
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errMsg));
    	}
    }
    
    
    /**
	* Load product list based on Country Id and Custom Setting Product catalog
	*
	@author  Jefferson Escobar
	@created 21-May-2014
	@version 1.0
	@since   30.0 (Force.com ApiVersion)
	*
	@return  products	List<SelectOption>
	*
	@changelog
	* 21-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
    public List<SelectOption> getProductsByCountry(String idCountry){
    	List<SelectOption> products = new List<SelectOption>();
    	products.add(new SelectOption('', '--None--'));
		
		for(Product_vod__c p : [SELECT Id, Name FROM Product_vod__c WHERE Active_BI__c = true AND Country_BI__c = :idCountry AND Product_Type_vod__c in :typeSetting ORDER BY Name]){
	        if(p.Name != null) 
	        	products.add(new SelectOption(p.Id, p.Name));
    	}
        return products;
    }
    
    
    /**
	* Load lifecycle templates list based on Country Id
	*
	@author  Jefferson Escobar
	@created 18-Aug-2014
	@version 1.0
	@since   30.0 (Force.com ApiVersion)
	*
	@return  cycleTemplates	List<SelectOption>
	*
	@changelog
	* 18-Aug-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
    public List<SelectOption> getCycleTemplatesByCountry(String idCountry){
    	List<SelectOption> cycleTemplates = new List<SelectOption>();
    	cycleTemplates.add(new SelectOption('', '--None--'));
    	Map<String,Lifecycle_Template_BI__c> mapCycleTemplates = new Map<String,Lifecycle_Template_BI__c>();
    	
		for(Lifecycle_Template_BI__c mt : [SELECT Id, Name,isLaunch_Phase_BI__c,Row_BI__c, Column_BI__c FROM Lifecycle_Template_BI__c WHERE Country_BI__c = :idCountry AND Active_BI__c = true ORDER BY Name]){
	        if(mt.Name != null){
	        	mapCycleTemplates.put(mt.Id,mt);
		        cycleTemplates.add(new SelectOption(mt.Id, mt.Name));
	        } 
	        	
    	}
    	
    	jsonMTofLaunch = Json.serialize(mapCycleTemplates);
    	
    	return cycleTemplates;
     }
    
    /**
	* Get specialties for particulars countries like USA
	*
	@author Jefferson Escobar
	@created 27-May-2014
	@version 1.0
	@since 30.0 (Force.com ApiVersion)
	*
	*
	@changelog
	* 27-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/ 	
   public void getSpecialtiesUSA(){
   		list_clsSpcial = new List<ClsSpecialization>();
   		mapSpecialties = new Set<String>();
   		
   		for(Specialty_Grouping_BI__c spG : [SELECT Id,Name,Country_BI__c,Country_Code_BI__c,Specialty_Group_BI__c FROM Specialty_Grouping_BI__c
											 			where Country_BI__c = :this.country.Id ORDER BY Name]){
			ClsSpecialization cs = new ClsSpecialization();
			//Set assigned status if the item is already selected
			String sName = (spG.Specialty_Group_BI__c != null && spG.Specialty_Group_BI__c.trim().length()>0) ? spG.Specialty_Group_BI__c : spG.Name;
			cs.isAssigned = (set_Specialties != null && (set_Specialties.contains(sName.replace('&',''))||set_Specialties.contains(spG.Name.replace('&','')))) ? true : false;

			if(mapSpecialties.contains(sName)){
				continue;
			}else{
				cs.Id = spG.Id;
				cs.sName = sName;
				mapSpecialties.add(sName);
				list_clsSpcial.add(cs);
			}
		}
   }
   
   /**
	* Get specialties rest of the world except USA
	*
	@author Jefferson Escobar
	@created 27-May-2014
	@version 1.0
	@since 30.0 (Force.com ApiVersion)
	*
	*
	@changelog
	* 27-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/ 	
   public void getSpecialtiesWorldWide(){
   		list_clsSpcial = new List<ClsSpecialization>();
   		mapSpecialties = new Set<String>();
   		String query;
    	
    	//Change the country id if the record belongs to a region zone
    	if (countryCodeRegion != null && countryCodeRegion != ''){
    		query='SELECT Id, RecordTypeId, Group_txt_BI__c, Country_BI__c, Country_Code_BI__c, Name ' + 
    				'FROM Customer_Attribute_BI__c where Country_Code_BI__c = \''+this.country.Country_Code_BI__c+'\' order by Name';
    	}else{
    		query='SELECT Id, RecordTypeId, Group_txt_BI__c, Country_BI__c, Country_Code_BI__c, Name ' + 
    				'FROM Customer_Attribute_BI__c where Country_BI__c = \''+this.country.Id+'\' order by Name';
    	}
    	     
    	List<Customer_Attribute_BI__c> specialites = Database.query(query);
    		
		for(Customer_Attribute_BI__c cab : specialites){
			ClsSpecialization cs = new ClsSpecialization();
			
			//Set assigned status if the item is already selected
			String sName = (cab.Group_txt_BI__c != null && cab.Group_txt_BI__c.trim().length()>0) ? cab.Group_txt_BI__c : cab.Name;
			cs.isAssigned = (set_Specialties != null && (set_Specialties.contains(sName.replace('&','')) || set_Specialties.contains(cab.Name.replace('&','')))) ? true : false;
			
			system.debug(':: SP Id: ' + cab.Id + '  specialties: ' + set_Specialties + ' Assigned: ' + cs.isAssigned + ' sName: ' + sName);
			
			if(mapSpecialties.contains(sName)){
				continue;
			}else{
				cs.Id = cab.Id;
				cs.sName = sName;
				mapSpecialties.add(sName);
			}
			list_clsSpcial.add(cs);
		}
   }
   
   /**
	* This method is used to cancel back to the country detail page
	*
	@author  Jefferson Escobar
	@created 27-May-2014
	@version 1.0
	@since   30.0 (Force.com ApiVersion)
	*
	@return  Pagereference
	*
	@changelog
	* 27-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/  	
	public Pagereference cancel(){
		Pagereference page;
		
		if(country != null && country.Id != null){
			page = new Pagereference('/' + country.Id);
		}
		else{
			page = new Pagereference('/' + KEYPREFIX_COUNTRY);
		}
		page.setRedirect(true);
		return page;
	}
	
	/**
	* Save a new budget allocation
	*
	@author  Jefferson Escobar
	@created 27-May-2014
	@version 1.0
	@since   30.0 (Force.com ApiVersion)
	*
	@param mTemplateJSON JSON Matrix Template Object
	*
	@return  Pagereference
	*
	@changelog
	* 27-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	@RemoteAction  	
	public static String saveMatixTemplate(String mTemplateJSON){
		Response r = new Response();
		SavePoint sp;
        try{
        	sp = Database.setSavepoint();
        	ClsMatrixTemplate clsMTemplate = (ClsMatrixTemplate)JSON.deserialize(mTemplateJSON, ClsMatrixTemplate.class);
        	Matrix_Template_BI__c matrixTemplate = new Matrix_Template_BI__c();
        	matrixTemplate.Id = (clsMTemplate.Id !=null && clsMTemplate.Id != '') ? clsMTemplate.Id : null;
        	
        	if(clsMTemplate.Id == null || clsMTemplate.Id == '')
        		matrixTemplate.Country_BI__c = clsMTemplate.countryId;
        		
        	matrixTemplate.Product_Catalog_BI__c = clsMTemplate.productId;
        	matrixTemplate.Lifecycle_Template_BI__c = clsMTemplate.cycleTemplateId;
        	matrixTemplate.Name = clsMTemplate.name;
        	matrixTemplate.Row_BI__c = clsMTemplate.row;
        	matrixTemplate.Column_BI__c = clsMTemplate.column;
        	matrixTemplate.Potential_Data_Label_BI__c = clsMTemplate.potentialLabel;
        	matrixTemplate.Adoption_Data_Label_BI__c = clsMTemplate.adoptionLabel;
        	
        	String countryId = clsMTemplate.countryId;
        	String countryCode = clsMTemplate.countryCode;
        	String countryCodeRegion = clsMTemplate.countryCodeRegion;
        	
        	if(clsMTemplate.specialties!=null && !clsMTemplate.specialties.isEmpty()){
        		Map<String,String> lstSpecialties;
	        	Map<String,Specialty_Grouping_Config__c> mapSpecialtyConfig = Specialty_Grouping_Config__c.getAll();//Load specialty settings;
	        	
	        	//Load Specialties by Country
				if(countryCode!=null&&mapSpecialtyConfig.containsKey(countryCode)){//Get specialties for USA
	    			lstSpecialties=getSpecialtiesUSA(countryId, clsMTemplate.specialties);
	    		}else{//Get specialties for countries differents to USA
	    			lstSpecialties=getSpecialtiesWorld(countryId, countryCode, countryCodeRegion, clsMTemplate.specialties);
	    		}
	        	 
	        	String specialties='';
	        	String specialtyIds='';
	        	
	        	for(String s : lstSpecialties.values()){
	        		specialties += s + ';';
	        	}
	        	
	        	for(String sId : lstSpecialties.keySet()){
	        		specialtyIds += sId + ';';
	        	}
	        	
	        	matrixTemplate.Specialties_BI__c = specialties.substring(0,specialties.length()-1);
	        	matrixTemplate.Specialty_Ids_BI__c = specialtyIds.substring(0,specialtyIds.length()-1);
        	}else{
        		matrixTemplate.Specialties_BI__c = null;
        		matrixTemplate.Specialty_Ids_BI__c = null;
        	}
        	
        	//Insert/Update record object
        	upsert matrixTemplate; 
        	
        }catch(DmlException de){
    		Database.rollback(sp);
    		r.success = false;
			r.message = de.getMessage();
			system.debug('[ERROR] - ' + de.getMessage());
			return JSON.serialize(r);
    	}
    	catch(Exception e){
    		r.success = false;
			r.message = e.getMessage();
			system.debug('[ERROR] - ' + e.getMessage());
			return JSON.serialize(r);
    	}
    	
		r.success = true;
		r.message = 'OK';
		return JSON.serialize(r);
	}
	
	/**
	* Get specialties for particulars countries like USA
	*
	@param countryId Id Country
	@param sp List of Specialties Selected
	@return Set Name of specialties pre-selected 
	*
	@author Jefferson Escobar
	@created 30-May-2014
	@version 1.0
	@since 30.0 (Force.com ApiVersion)
	*
	*
	@changelog
	* 30-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/ 
	public static Map<String,String> getSpecialtiesUSA(String countryId, Set<String> sp){
		Map<String,String> specialties = new Map<String,String>();
		
		for(Specialty_Grouping_BI__c spG : [Select Id,Name From Specialty_Grouping_BI__c where Country_BI__c = :countryId and (Name in :sp or Specialty_Group_BI__c in :sp)  order by Name]){
			specialties.put(spG.Id,spG.Name);	
		}
		return specialties;
	}
	
	
	/**
	* Get specialties Name rest of the world except USA
	*
	@param countryId Id Country
	@para countryCode Country code
	@param sp List of Specialties Selected
	@return Set Name of specialties pre-selected 
	*
	@author Jefferson Escobar
	@created 30-May-2014
	@version 1.0
	@since 30.0 (Force.com ApiVersion)
	*
	*
	@changelog
	* 30-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	public static Map<String,String> getSpecialtiesWorld(String countryId, String countryCode,String countryCodeRegion, Set<String> sp){
		Map<String,String> specialties = new Map<String,String>();
		String specialtiesStr='';
		String query;
		
		for(String s : sp){
			specialtiesStr+= '\''+ s + '\',';
		}
		if(specialtiesStr.trim().length()>0)
			specialtiesStr=specialtiesStr.substring(0,specialtiesStr.length()-1);
			
    	//Change the country id if the record belongs to a region zone
    	if (countryCodeRegion != null && countryCodeRegion != ''){
    		query='SELECT Id, RecordTypeId, Group_txt_BI__c, Country_BI__c, Country_Code_BI__c, Name ' + 
    				'FROM Customer_Attribute_BI__c where Country_Code_BI__c = \''+countryCode+'\' and (Name in ('+ specialtiesStr +') or Group_txt_BI__c in ('+ specialtiesStr +'))  order by Name';
    	}else{
    		query='SELECT Id, RecordTypeId, Group_txt_BI__c, Country_BI__c, Country_Code_BI__c, Name ' + 
    				'FROM Customer_Attribute_BI__c where Country_BI__c = \''+countryId+'\' and (Name in ('+ specialtiesStr +') or Group_txt_BI__c in ('+ specialtiesStr +'))  order by Name';
    	}
    	
    	system.debug(':: Query: ' + query);
    	     
		for(Customer_Attribute_BI__c ca : Database.query(query)){
			specialties.put(ca.Id,ca.Name);	
		}
		return specialties;
	}
    
/**
==================================================================================================================================
												Wrapper Classes                                                     
==================================================================================================================================
*/

	public class ClsMatrixTemplate{
		public String Id {get;set;}
		public String name {get;set;}
		public String productId {get;set;}
		public String cycleTemplateId {get;set;}
		public Integer row {get;set;}
		public Integer column {get;set;}
		public String potentialLabel {get;set;}
		public String adoptionLabel {get;set;}
		public String countryId {get;set;}
		public String countryCode;
    	public String countryCodeRegion; 
		public Set<String> specialties;
	}

	public class ClsSpecialization{
    	public Customer_Attribute_BI__c specialty {get; set;}
    	public Specialty_Grouping_BI__c specialtyGrouping {get; set;}
    	public Id Id {get; set;}
    	public boolean isAssigned {get; set;}
    	public String sName {get; set;}
    	
    	public ClsSpecialization(){
			isAssigned = false;
			sName='';
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
}