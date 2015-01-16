/**
 *	Controller class used for VF Page IMP_BI_ExtManageSpeciality
 *
 @author 	Peng Zhu
 @created 	2013-07-01
 @version 	1.0
 @since 	27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2014-02-20 Jefferson Escobar <jescobar@omegacrmconsulting.com>
 * - Modified
 */
global class IMP_BI_ExtManageSpeciality {
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	public static final string KEYPREFIX_SPECIALITY = Schema.SObjectType.Customer_Attribute_BI__c.getKeyPrefix();
	public static final string KEYPREFIX_SPECIALITY_GROUPING = Schema.SObjectType.Specialty_Grouping_BI__c.getKeyPrefix();
	public static final string KEYPREFIX_COUNTRY = Schema.SObjectType.Country_BI__c.getKeyPrefix();
	
	public String pageTitle {get; set;}
	public String sectionHeaderTitle {get; set;}
	public String sectionHeaderSubTitle {get; set;}
	
	public list<ClsSpeciality> list_cs {get; set;}
	public list<ClsGroup> list_cg {get; set;}
	
	public String specialityName {get; set;}
	
	public Integer groupIndex {get; set;}
	public Id countryId {get; set;} 
	private String countryCodeRegion;
	public static String countryCode {get; set;}
	public Integer qSpecialties {get;private set;}
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    /**
	 * map to store global describtion due to limit on describe methods.
	 */
	private map<String, String> map_urlParams;
	
	private map<Id, Customer_Attribute_BI__c> map_id_cab;
	private map<String, ClsGroup> map_gName_cg;
	
	//@jescobar: Grouping specialty for USA
	private map<String, ClsGroup> map_gName_sgUSA;
	private Map<String,Specialty_Grouping_Config__c> mapSpecialtyConfig;
	
	/**
	 * map to store global describtion due to limit on describe methods.
	 */
	
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	/////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
   /**
	* The contsructor
	*
	@author Peng Zhu
	@created 2013-07-01
	@version 1.0
	@since 27.0 (Force.com ApiVersion)
	*
	@changelog
	* 2013-07-01 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public IMP_BI_ExtManageSpeciality(ApexPages.standardController stdCtrl) {
    	map_urlParams = ApexPages.currentPage().getParameters();
    	
    	pageTitle = 'Manage Speciality';
    	sectionHeaderTitle = 'Manage Speciality';
    	sectionHeaderSubTitle = '';
    	
    	specialityName = '';
    	groupIndex = 0;
    	
		list_cs = new list<ClsSpeciality>();
		list_cg = new list<ClsGroup>();
    	
    	if(map_urlParams != null && map_urlParams.containsKey('cId')) 
    		countryId = map_urlParams.get('cId');
    	
    	if(countryId != null){
    		
    		mapSpecialtyConfig = Specialty_Grouping_Config__c.getAll();
    		
    		Country_BI__c c = [SELECT Id, Name, Country_Code_BI__c,Country_Code_Region_BI__c FROM Country_BI__c WHERE Id = :countryId];
    		countryCode = c.Country_Code_BI__c;
    		countryCodeRegion = (c.Country_Code_Region_BI__c!=null&&c.Country_Code_Region_BI__c != '') ? c.Country_Code_Region_BI__c : null;
    		sectionHeaderSubTitle = c.Name;
    		
    		if(countryCode!=null&&mapSpecialtyConfig.containsKey(countryCode)){//Get specialties for USA
    			getSpecialtiesUSA();
    		}else{//Get specialties for countries differents to USA
    			getSpecialtiesWorldWide();
    		}
    	}
    }
    
    /////////////////////////////////// -=END CONSTRUCTOR=- ///////////////////////////////////////
    
   
   /**
	* Get specialties rest of the world except USA
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
   public void getSpecialtiesWorldWide(){
   		
   		map_id_cab = new map<Id, Customer_Attribute_BI__c>();
    	map_gName_cg = new map<String, ClsGroup>();
    	String gName;
    	String query;
    	
    	//Change the country id if the record belongs to a region zone
    	if (countryCodeRegion != null && countryCodeRegion != ''){
    		query='SELECT Id, RecordTypeId, Group_txt_BI__c, Country_BI__c, Country_Code_BI__c, Name, Summary_Specialties_Account_Number_BI__c ' + 
    				'FROM Customer_Attribute_BI__c where Country_Code_BI__c = \''+countryCodeRegion+'\'';
    	}else{
    		query='SELECT Id, RecordTypeId, Group_txt_BI__c, Country_BI__c, Country_Code_BI__c, Name, Summary_Specialties_Account_Number_BI__c ' + 
    				'FROM Customer_Attribute_BI__c where Country_BI__c = \''+countryId+'\'';
    	}
    	     
    	List<Customer_Attribute_BI__c> specialites = Database.query(query);
    	qSpecialties = (specialites!=null&&specialites.size()>0) ? specialites.size() : 0;//How many specialties have already been  selected
       		
		for(Customer_Attribute_BI__c cab : specialites){
			map_id_cab.put(cab.Id, cab);
			
			gName = '';
			
			ClsSpeciality cs = new ClsSpeciality();
			Integer qSpecialtiesAccount = (cab.Summary_Specialties_Account_Number_BI__c != null) ? Integer.valueOf(cab.Summary_Specialties_Account_Number_BI__c)  : 0; 
			cs.sId = cab.Id;
			cs.specialtiesAccount = '('+qSpecialtiesAccount+')';
			cs.sName = cab.Name;
			
			if(cab.Group_txt_BI__c != null && cab.Group_txt_BI__c.trim() != ''){
				gName = cab.Group_txt_BI__c.trim();
				cs.hasGroup = true;
				if(!map_gName_cg.containsKey(gName)){
					ClsGroup cg  = new ClsGroup();
					cg.gName = gName;
					cg.list_cs.add(cs);
					map_gName_cg.put(gName, cg);
				}
				else{
					map_gName_cg.get(gName).list_cs.add(cs);
				}
			}
			list_cs.add(cs);
		}
    		    	
    	if(map_gName_cg != null && !map_gName_cg.isEmpty()){
    		list_cg.addAll(map_gName_cg.values());
    	}
    	
    	if(list_cg != null) groupIndex = list_cg.size();
    	system.debug('**@@Peng list_cg.size() : ' + list_cg.size() + ', groupIndex : ' + groupIndex);
    	
    	for(ClsGroup cg : list_cg){
    		if(cg.list_cs.size() < qSpecialties){
    			Integer s = qSpecialties - cg.list_cs.size();
    			for(Integer i = 0; i < s; i++){
		    		cg.list_cs.add(new ClsSpeciality());
    			}
    		}
    	}
   }
   
   	/**
	* Get specialties for USA
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
   public void getSpecialtiesUSA(){
   	
   		map_gName_sgUSA = new map<String, ClsGroup>();
    	String gName;
    	List<Specialty_Grouping_BI__c> specialites = [SELECT Id,Name,Country_BI__c,Country_Code_BI__c,Specialty_Group_BI__c,Summary_Specialties_Account_BI__c FROM Specialty_Grouping_BI__c
											 			where Country_BI__c = :countryId ORDER BY Name];
    	qSpecialties = (specialites!=null&&specialites.size()>0) ? specialites.size() : 0;
       		
		for(Specialty_Grouping_BI__c spG : specialites){
			gName = '';
			ClsSpeciality cs = new ClsSpeciality();
			cs.sId = spG.Id;
			Integer qSpecialtiesAccount = (spG.Summary_Specialties_Account_BI__c != null) ? Integer.valueOf(spG.Summary_Specialties_Account_BI__c) : 0;
			cs.specialtiesAccount = '('+qSpecialtiesAccount+')';
			cs.sName = spG.Name;
			
			if(spG.Specialty_Group_BI__c != null && spG.Specialty_Group_BI__c.trim() != ''){
				gName = spG.Specialty_Group_BI__c.trim();
				cs.hasGroup = true;
				if(!map_gName_sgUSA.containsKey(gName)){
					ClsGroup cg  = new ClsGroup();
					cg.gName = gName;
					cg.list_cs.add(cs);
					map_gName_sgUSA.put(gName, cg);
				}
				else{
					map_gName_sgUSA.get(gName).list_cs.add(cs);
				}
			}
			list_cs.add(cs);
		}
    		    	
    	if(map_gName_sgUSA != null && !map_gName_sgUSA.isEmpty()){
    		list_cg.addAll(map_gName_sgUSA.values());
    	}
    	
    	if(list_cg != null) groupIndex = list_cg.size();
    	system.debug(':: Specialties number : ' + list_cg.size() + ', groupIndex : ' + groupIndex);
    	
    	for(ClsGroup cg : list_cg){
    		if(cg.list_cs.size() < qSpecialties){
    			Integer s = qSpecialties - cg.list_cs.size();
    			for(Integer i = 0; i < s; i++){
		    		cg.list_cs.add(new ClsSpeciality());
    			}
    		}
    	}
   	
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
		else if(countryId != null){
			page = new Pagereference('/' + countryId);
		}
		else{
			page = new Pagereference('/' + KEYPREFIX_COUNTRY);
		}
		
		page.setRedirect(true);
		
		return page;
	}//********************************* -=BEGIN public methods=- **********************************
    
    
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
    global static String saveSpecialityData(string finalResult){
    	Response r = new Response();
    	Savepoint sp = Database.setSavepoint();
    	
    	try{
	    	List<ClsSpecialityJson> list_csj = (list<ClsSpecialityJson>)JSON.deserialize(finalResult, List<ClsSpecialityJson>.class);
	    	
	    	if(list_csj != null && !list_csj.isEmpty()){
	    		
	    		countryCode = list_csj.get(0).cCode;
	    		Map<String,Specialty_Grouping_Config__c> mapSpecialtyConfig = Specialty_Grouping_Config__c.getAll();	
	    	
		    	system.debug('**@@Peng list_csj : ' + list_csj);
		    	system.debug(':: Country Id: ' + countryCode);
		    	
		    	if(countryCode!=null&&mapSpecialtyConfig.containsKey(countryCode)){//Save specialty group for USA
					
					List<Specialty_Grouping_BI__c> list_spGpsert= getSpecialtiesDataUSA(list_csj);
					
					if(!list_spGpsert.isEmpty())
						upsert list_spGpsert; 
					
		    	}else{//Save specialty group rest of the world
		    		
	    			List<Customer_Attribute_BI__c> list_cab2Upsert = getSpecialtiesDataWorldWide(list_csj);//Get the specialties list to save
	    			system.debug(':: Specialties to upsert: ' + list_cab2Upsert);
	    			
	    			if(!list_cab2Upsert.isEmpty()) 
	    				upsert list_cab2Upsert;
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
    
    
	/**
	* This method is used to get records to sfdc for world wide specialties
	*
	@author  Jefferson Escobar
	@created 20-Feb-2014
	@version 1.0
	@since   29.0 (Force.com ApiVersion)
	*
	*
	@return  List customer attribute records to insert/update
	*
	@changelog
	* 20-Feb-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/    
    public static List<Customer_Attribute_BI__c> getSpecialtiesDataWorldWide(List<ClsSpecialityJson> list_csj){
    	
    	map<Id, ClsGroup> map_id_group = new map<Id, ClsGroup>();
		list<Customer_Attribute_BI__c> list_cab2Upsert  = new list<Customer_Attribute_BI__c>();
		
		Id rtId;
		for(RecordType rt : [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Customer_Attribute_BI__c' And DeveloperName = 'OK_International_Attrubite']){
			rtId = rt.Id;
		}
		
		for(ClsSpecialityJson csj : list_csj){
			if(csj.sId != null && csj.sId.trim() != ''){
				if(csj.sId.contains(KEYPREFIX_SPECIALITY)){
					
					if(!map_id_group.containsKey(csj.sId)){
						ClsGroup clsGroup = new ClsGroup();
						clsGroup.gName = csj.sGroup;
						 map_id_group.put(csj.sId, clsGroup);
					}
				}
				else{
					Customer_Attribute_BI__c cab = new Customer_Attribute_BI__c();
					cab.Name = csj.sName;
					cab.Group_txt_BI__c = csj.sGroup;
					cab.RecordTypeId = rtId;
					cab.Country_BI__c = csj.cId;
					cab.Country_Code_BI__c = csj.cCode;
					list_cab2Upsert.add(cab);
				}
			}
			//KEYPREFIX_SPECIALITY
		}
		
		for(Customer_Attribute_BI__c c : [SELECT Id, Group_txt_BI__c, Name FROM Customer_Attribute_BI__c WHERE Id IN :map_id_group.keySet()]){
			c.Group_txt_BI__c = map_id_group.get(c.Id).gName;
			list_cab2Upsert.add(c);
		}
		
		system.debug(':: Customer Attr to upsert ' + list_cab2Upsert);
		
		return list_cab2Upsert;
    
    }
    
    /**
	* This method is used to get records to sfdc for usa specialties
	*
	@author  Jefferson Escobar
	@created 20-Feb-2014
	@version 1.0
	@since   29.0 (Force.com ApiVersion)
	*
	*
	@return  List specialty grouping records to insert/update
	*
	@changelog
	* 20-Feb-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/    
    public static List<Specialty_Grouping_BI__c> getSpecialtiesDataUSA(List<ClsSpecialityJson> list_csj){
    	
    	map<Id, clsGroup> map_id_group = new map<Id, clsGroup>();
		list<Specialty_Grouping_BI__c> list_spGpsert  = new list<Specialty_Grouping_BI__c>();
		
		for(ClsSpecialityJson csj : list_csj){
			if(csj.sId != null && csj.sId.trim() != ''){
				if(csj.sId.contains(KEYPREFIX_SPECIALITY_GROUPING)){
					if(!map_id_group.containsKey(csj.sId)){
						ClsGroup clsGroup = new ClsGroup();
						clsGroup.gName = csj.sGroup;
						map_id_group.put(csj.sId, clsGroup);
					}
				}
				else{
					Specialty_Grouping_BI__c spGroup = new Specialty_Grouping_BI__c();
					spGroup.Name = csj.sName;
					spGroup.Specialty_Group_BI__c = csj.sGroup;
					spGroup.Country_Code_BI__c = csj.cCode;
					list_spGpsert.add(spGroup);
				}
			}
		}
		
		for(Specialty_Grouping_BI__c c : [SELECT Id, Specialty_Group_BI__c, Name FROM Specialty_Grouping_BI__c WHERE Id IN :map_id_group.keySet()]){
			c.Specialty_Group_BI__c = map_id_group.get(c.Id).gName;
			list_spGpsert.add(c);
		}
		
		return list_spGpsert;
    
    }

    //********************************* -=END public methods=- ************************************
    
    
    //********************************* -=BEGIN private methods=- *********************************
    //********************************* -=END private methods=- ***********************************
    
    
    //********************************* -=BEGIN help functions=- **********************************
    //********************************* -=END help functions=- ************************************
    
    //********************************* -=BEGIN inner classes=- ***********************************
    ///*>>>WrapperClass*/
    public class ClsSpeciality{
    	public String sId {get; set;}
    	public String sName {get; set;}
    	public String specialtiesAccount {get; set;}
    	public boolean hasGroup {get; set;}
    	
    	public ClsSpeciality(){
    		hasGroup = false;
    	}
    }
    
    public class ClsGroup{
    	public String gName {get; set;}
    	public Boolean isNew {get; set;}
    	
    	public list<ClsSpeciality> list_cs {get; set;}
    	
    	public ClsGroup(){
    		isNew = false;
    		list_cs = new list<ClsSpeciality>();
    	}
    }
    
    public class ClsSpecialityJson{
    	public String sId;
    	public String sName;
    	public String sGroup;
    	public String cId;
    	public String cCode;
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