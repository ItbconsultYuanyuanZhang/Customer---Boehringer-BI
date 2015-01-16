/************************************************************************************************
*Extension class for the SAP preparation page.

IF viewstate limit is hit, separate into a the "targets" list into a query 
without the detail relationship query and use a transient version for the current one.
It's in the displayData() function.
Also move the outputpanel render variable to the table display one. 
http://salesforce.stackexchange.com/questions/4537/how-to-reduce-a-large-internal-view-state-what-is-in-the-internal-view-state

Version update 1.2

*Lastmod by: Viktor 2014-03-04
************************************************************************************************/
public without sharing class VEEVA_BI_SAP_Preparation_Extension {
	//generic extension level variables
	String Ucc;					//User Country code for generic use
	String OBJcode;				//3 chars of the obj for redirect
	String id;					//Id added as a param in URL
	String save_new;			//value added as a param in URL
	String retURL;				//value added as a param in URL
	String Pid; 				//Preparation start date for remaining comparison
	map<Id, Product_vod__c> prodMap; 				//prodmap for deduplication
	
	//pagination variables
	private integer counter=0;  	//keeps track of the offset
   	private integer list_size=200; 	//sets the page size or number of rows
   	public integer total_size; 		//used to show user the total size of the list
	
	//extension level variables
	transient SavePoint sp;									//Database savepoint to roll back all changes on 3 levels
	transient list<UserTerritory> UTs; 						//for Terr count, picklist
	//transient set<Id> ACCids;								//ALL Account IDs of the User
	transient map<Id,SAP_Target_Preparation_BI__c> TPmap; 	//Account Id - TP map
	transient set<Id> Tids = new set<Id>();					//user's territory ids
	transient set<Id> gIds = new set<Id>();					//user's territory type group ids
	transient set<Id> allTPs = new set<Id>();				//target preparation ids on all pages for current Prep
	transient String filterCriteria; 
	
	//display variables
	public boolean Tpick {get;set;} 	//territory selector is needed?
	public boolean edit {get;set;} 		//edit mode
	public boolean detail {get;set;} 	//detail mode
	
	//data to pass to the page
	public SAP_Preparation_BI__c P {get;set;} 								//the Prep currenty edited
	public list<SAP_Target_Preparation_BI__c> targets {get;set;} 			//the Targets currently edited
	public map<String, SAP_Detail_Preparation_BI__c> detailMap {get;set;}	//details currently edited mapped by external id
	public map<String, Boolean> renderMap {get;set;}						//determines if the
	public map<id,Decimal> TPRemMap {get;set;}								//Remaining value map for Target level
	public map<String,Decimal> DPRemMap	{get;set;}					 		//Remaining value map for Detail level
	public list<Product_vod__c> prods {get;set;} 							//list of products as columns and ids for ext_id creation
	public list<SelectOption> Tnames {get;set;} 							//list of user's territories
	public String Terr {get;set;} 											//selected territory
	
	//filter variables
	public string modified {get; set;}
	public string FieldName {get; set;}
	public string Operator {get; set;}
	public string Value  {get; set;}
	public string FieldName2 {get; set;}
	public string Operator2 {get; set;}
	public string Value2  {get; set;}
	public string FieldName3 {get; set;}
	public string Operator3 {get; set;}
	public string Value3  {get; set;}
	public List<SelectOption> OperatorList {get; set;}
	public List<SelectOption> FieldsSelectOptionList {get; set;} 
	//segment filter
	public string ProductName {get; set;}
	public string SegmentName {get; set;}
	public List<SelectOption> ProductSelectOptionList {get; set;}
	public List<SelectOption> SegmentSelectOptionList {get; set;}
	//filter summary fields
	public integer filterCount {get; set;} 			//calculation added to displayData()
	
	//CONSTRUCTOR
	public VEEVA_BI_SAP_Preparation_Extension(ApexPages.StandardController controller){//constructor w controller
		system.debug('VEEVA_BI_SAP_Preparation_Extension w constructor STARTED');
		
		//initialize generic data
		P = new SAP_Preparation_BI__c();
		this.P = (SAP_Preparation_BI__c) controller.getRecord();
		 
		Ucc = [SELECT Id, Country_code_bi__c FROM User WHERE id = :Userinfo.getUserId() LIMIT 1].Country_code_bi__c;
		system.debug('User country code: '+Ucc);
		OBJcode = SAP_Preparation_BI__c.sObjectType.getDescribe().getKeyPrefix();//get org-specific object code for list URL composition

		//filter start
		FieldsSelectOptionList = new List<SelectOption>();
		OperatorList = new List<SelectOption>();
		ProductSelectOptionList = new List<SelectOption>();
		SegmentSelectOptionList = new List<SelectOption>();
		PopulateFieldsList();
		PopulateOperatorList('Target_Customer_BI__r.Name');
		modified = '';
		ProductName = '';
		SegmentName = '';
		//DECIDE DETAIL/EDIT mode
		//new - https://c.cs9.visual.force.com/apex/VEEVA_BI_SAP_Preparation?retURL=%2Fa3j%3Ffcf%3D00BK0000000OQRI%26rolodexIndex%3D-1%26page%3D1&scontrolCaching=1&sfdc.override=1
		//edit - https://c.cs9.visual.force.com/apex/VEEVA_BI_SAP_Preparation?id=a3jK0000000AEzF&retURL=%2Fa3j%3Ffcf%3D00BK0000000OQRI%26rolodexIndex%3D-1%26page%3D1&sfdc.override=1
		//view - https://c.cs9.visual.force.com/apex/VEEVA_BI_SAP_Preparation?id=a3jK0000000AEzK&sfdc.override=1
		
		id = ApexPages.currentPage().getParameters().get('id');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		save_new = ApexPages.currentPage().getParameters().get('save_new');
		
		if(retURL!=null){
			//edit
			edit = true;
			detail = false;
			terrPicklist(); //when edit, fill up the terrpicklist
		}else{
			//not edit
			edit = false;
			detail = true;
		}
		//if an existing one	
		if(id!=null){
			Pid = id;
			
			Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('SAP_Preparation_BI__c').getDescribe().fields.getMap();
			String selStmt = 'SELECT ';
			
			for(Schema.SObjectField sfield : fieldMap.Values()){
	            schema.describefieldresult dfield = sfield.getDescribe();
	            if(!dfield.getName().equals('null') || dfield.getName() != null){
	                selStmt +=  dfield.getName() + ', '; 
	            }         
		    }
			
			selStmt = selStmt.removeEnd(', ');
			
			selStmt += ' FROM SAP_Preparation_BI__c WHERE Id = \'' + id + '\' LIMIT 1';
			try{
				P = Database.query(selSTmt);
			}catch(QueryException e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SAPP_Error_query_BI));	
			}
		}
		//if approved, no edit is allowed, forward to detail mode
		if(id!=null && retURL!=null && P.Status_BI__c=='Approved'){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.SAPP_Error_approved_BI));
			edit=false;
			detail=true;
			return;
		}
				
	}//END OF CONSTRUCTOR
	
	public void init(){//INIT PROCESS - constructor can't be used for DML
		system.debug('init STARTED');
		//save the db and roll back later if necessary
		sp = Database.setSavepoint();
		
		//IF CREATE MODE
		if(id==null){
			try{
				createPrep();
				loadTargetData();
				loadDetialData();
			}catch(Exception e){
				Database.rollback(sp);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SAPP_Error_targeting_BI + e));			
			}
		}
		//DO THIS ANYWAYS
		//set total size for pagination
		String sizeSelect = 'SELECT count(id) co FROM SAP_Target_Preparation_BI__c WHERE SAP_Header_BI__c = \'' + Pid + '\'' + ' ';
		if(filtercriteria!=null) sizeSelect += filtercriteria;
		total_size = (integer) database.query(sizeSelect)[0].get('co');
		//total_size = [SELECT count() FROM SAP_Target_Preparation_BI__c WHERE SAP_Header_BI__c = :Pid];
		//load remaining columns
		loadRemaining();  			//REMOVE TO HAVE SOME PLACE IN THE DEBUG LOG, ACTIVATE THIS IN LIVE CODE 
		//get rows to display
		displayData();
	}
	
	private void terrPicklist(){
		system.debug('terrPicklist STARTED');
		//DECIDE PICKLIST		
		//Get current user territories
		UTs = [SELECT Id, UserId, TerritoryId FROM UserTerritory WHERE UserId = :Userinfo.getUserId()];
		system.debug('User territory #: ' + UTs.size());
		Tpick = UTs.size()>1 ? true : false;
		
		if(UTs.size()>0){
			for(UserTerritory UT : UTs)
				Tids.add(UT.TerritoryId);
			
			if(Tpick){//has multiple terrs - fill the picklist
				//get terrs of the user
				for(Territory T : [SELECT Id, Name FROM Territory WHERE Id in :Tids]){
					Tnames.add(new SelectOption(T.Name,T.Name));
					Terr = T.Name;
				}
			}else{//single terr - set Territory name
				Terr = [SELECT Id, Name FROM Territory WHERE Id in :Tids LIMIT 1].Name;
			}
		}
		if(Terr==null) Terr = 'NO_TERR';
	}
	
	public void createPrep(){
		system.debug('createPrep STARTED');
		P.Country_Code_BI__c=Ucc;
		P.Territory_BI__c=Terr;
		//load the dates dependent on config
		
		list<SAP_Cycle_BI__c> cycleconfigs = new list<SAP_Cycle_BI__c>();
		//there should be only one record
		cycleconfigs = [SELECT Id, 
								Cycle_1_Start_Date_BI__c, Cycle_1_End_Date_BI__c, 
								Cycle_2_Start_Date_BI__c, Cycle_2_End_Date_BI__c, 
								Cycle_3_Start_Date_BI__c, Cycle_3_End_Date_BI__c, 
								Cycle_4_Start_Date_BI__c, Cycle_4_End_Date_BI__c, 
								Cycle_5_Start_Date_BI__c, Cycle_5_End_Date_BI__c, 
								Cycle_6_Start_Date_BI__c, Cycle_6_End_Date_BI__c, 
								Cycle_7_Start_Date_BI__c, Cycle_7_End_Date_BI__c, 
								Cycle_8_Start_Date_BI__c, Cycle_8_End_Date_BI__c, 
								Cycle_9_Start_Date_BI__c, Cycle_9_End_Date_BI__c, 
								Cycle_10_Start_Date_BI__c, Cycle_10_End_Date_BI__c, 
								Cycle_11_Start_Date_BI__c, Cycle_11_End_Date_BI__c,
								Cycle_12_Start_Date_BI__c, Cycle_12_End_Date_BI__c
								FROM SAP_Cycle_BI__c WHERE Country_Code_BI__c = :Ucc limit 1];
		
		if(cycleconfigs.size()>0){
			Integer days = System.today().dayOfYear();
			set<date> cycles = new set<date>();
			
			SAP_Cycle_BI__c C = new SAP_Cycle_BI__c();
			C = cycleconfigs[0];
			
			if(C.Cycle_1_Start_Date_BI__c!=null) cycles.add(C.Cycle_1_Start_Date_BI__c);
			if(C.Cycle_2_Start_Date_BI__c!=null) cycles.add(C.Cycle_2_Start_Date_BI__c);
			if(C.Cycle_3_Start_Date_BI__c!=null) cycles.add(C.Cycle_3_Start_Date_BI__c);
			if(C.Cycle_4_Start_Date_BI__c!=null) cycles.add(C.Cycle_4_Start_Date_BI__c);
			if(C.Cycle_5_Start_Date_BI__c!=null) cycles.add(C.Cycle_5_Start_Date_BI__c);
			if(C.Cycle_6_Start_Date_BI__c!=null) cycles.add(C.Cycle_6_Start_Date_BI__c);
			if(C.Cycle_7_Start_Date_BI__c!=null) cycles.add(C.Cycle_7_Start_Date_BI__c);
			if(C.Cycle_8_Start_Date_BI__c!=null) cycles.add(C.Cycle_8_Start_Date_BI__c);
			if(C.Cycle_9_Start_Date_BI__c!=null) cycles.add(C.Cycle_9_Start_Date_BI__c);
			if(C.Cycle_10_Start_Date_BI__c!=null) cycles.add(C.Cycle_10_Start_Date_BI__c);
			if(C.Cycle_11_Start_Date_BI__c!=null) cycles.add(C.Cycle_11_Start_Date_BI__c);
			if(C.Cycle_12_Start_Date_BI__c!=null) cycles.add(C.Cycle_12_Start_Date_BI__c);
			
			Integer position = 1;
			
			if(cycles.size()>0){
				for(Date D : cycles){
					if(days>=D.dayOfYear()){
						position++;
					}
				}
				if(position>cycles.size()) position  =  1;
				
				Date startdate = (date) C.get('Cycle_'+position+'_Start_Date_BI__c');
				Date enddate = (date) C.get('Cycle_'+position+'_End_Date_BI__c');
				
				P.Start_Date_BI__c =  date.newinstance(System.today().year(), startdate.month(), startdate.day() );
				P.End_Date_BI__c =  date.newinstance(System.today().year(), enddate.month(), enddate.day() );
			}
			
		}else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.SAPP_Error_cycle_BI ));	
		
		insert P;
		Pid = P.id;
		system.debug('inserted preparation id: '+P.Id);
	}
	
	public void loadTargetData(){
		system.debug('loadTargetData STARTED');
		
		for(Group G : [SELECT Id FROM Group WHERE RelatedId in :Tids])
			gIds.add(G.Id);

		//Select all the Targeted accounts in the SET, and grab their Target numbers, and ids (map?)
		TPmap = new map<Id,SAP_Target_Preparation_BI__c>();
		
		for(Target_Account_BI__c TA : [SELECT Id, Account_BI__c, Target_Calls_BI__c, NTL_Value_BI__c
										FROM Target_Account_BI__c 
										WHERE Account_BI__c in (SELECT AccountId FROM AccountShare WHERE UserOrGroupId = :gIds)
										AND Target_Calls_BI__c > 0 
										AND Version_Comparison_BI__c = 'Active'
										AND Portfolio_BI__r.Active_SAP__c = true
										LIMIT 2000]){
			SAP_Target_Preparation_BI__c TP = new SAP_Target_Preparation_BI__c(Target_Customer_BI__c = TA.Account_BI__c,
																				Planned_Interactions_BI__c = TA.Target_Calls_BI__c,
																				Adjusted_Interactions_BI__c = TA.Target_Calls_BI__c,
																				NTL_Value_BI__c = TA.NTL_Value_BI__c,
																				SAP_Header_BI__c = P.Id,
																				Country_Code_BI__c = Ucc,
																				External_ID_BI__c = TA.Account_BI__c + '_' + Terr + '_' + P.Id);
			TPmap.put(TA.Account_BI__c, TP);
			
		}	
		//load to object
		system.debug('TPmap.size: '+TPmap.size());
		Database.upsert(TPmap.values(), SAP_Target_Preparation_BI__c.Fields.External_ID_BI__c, false);
	}
	
	public void loadDetialData(){
		system.debug('loadDetialData STARTED');
		transient set<Id> Prods = new set<Id>();
		//get the products from my setup
		for(My_Setup_Products_vod__c MS : [SELECT Id, Product_vod__c 
											FROM My_Setup_Products_vod__c 
											WHERE OwnerId = :Userinfo.getUserId()
											AND Product_vod__r.No_Cycle_Plans_vod__c = false
											ORDER BY Name])
			Prods.add(MS.Product_vod__c);
		system.debug('Prods.size: '+Prods.size());
		//Grab all the Target detials related to those accounts and my products
		map<String,SAP_Detail_Preparation_BI__c> DPmap = new map<String,SAP_Detail_Preparation_BI__c>();
		
		for(Target_Detail_BI__c TD : [SELECT Id, Account_BI__c, Product_Catalog_BI__c, Target_Details_BI__c, Segment_BI__c, Column_BI__c, Row_BI__c
										FROM Target_Detail_BI__c 
										WHERE Account_BI__c in (SELECT AccountId FROM AccountShare WHERE UserOrGroupId = :gIds)
										AND Product_Catalog_BI__c in :Prods  //REMOVED FOR TESTING ONLY, ADD THIS LINE FROM LIVE CODE
										//AND Target_Details_BI__c > 0  //Removed upon request by David 2014-03-12
										AND Version_Comparison_BI__c = 'Active'
										AND Portfolio_BI__r.Active_SAP__c = true
										]){
			if(TPmap.containsKey(TD.Account_BI__c)){
				SAP_Detail_Preparation_BI__c DP = new SAP_Detail_Preparation_BI__c(Country_Code_BI__c=Ucc,
																				Planned_Details_BI__c=TD.Target_Details_BI__c,
																				Adjusted_Details_BI__c=TD.Target_Details_BI__c,
																				Column_BI__c=TD.Column_BI__c,
																				Product_BI__c=TD.Product_Catalog_BI__c,
																				Segment_BI__c=TD.Segment_BI__c,
																				Row_BI__c=TD.Row_BI__c,
																				Target_Customer_BI__c=TPmap.get(TD.Account_BI__c).Id,
																				External_ID_BI__c=TPmap.get(TD.Account_BI__c).External_ID_BI__c + '_' + TD.Product_Catalog_BI__c);
				DPmap.put(DP.External_ID_BI__c, DP);
			}
		}
		//load to object
		system.debug('DPmap.size: '+DPmap.size());
		Database.upsert(DPmap.values(), SAP_Detail_Preparation_BI__c.Fields.External_ID_BI__c, false);
	}
	
	public void loadRemaining(){
		//NEED TO DIFFERENTIATE BETWEEN CYCLE PLANS- CANT DO IT WITHOUT THAT -- CAN Version_BI__c BE USED?
		TPRemMap = new map<id,Decimal>();
		allTPs = new set<Id>();
		
		for(SAP_Target_Preparation_BI__c TP : [SELECT Id, Target_Customer_BI__c, Planned_Interactions_BI__c, Adjusted_Interactions_BI__c FROM SAP_Target_Preparation_BI__c WHERE SAP_Header_BI__r.Start_Date_BI__c = :P.Start_Date_BI__c ] ){
			decimal planned = TP.Planned_Interactions_BI__c == null ? 0 : TP.Planned_Interactions_BI__c;
			decimal adjusted = TP.Adjusted_Interactions_BI__c == null ? 0 : TP.Adjusted_Interactions_BI__c;
			decimal current = TPRemMap.get(TP.Target_Customer_BI__c);
			
			if(current==null) TPRemMap.put(TP.Target_Customer_BI__c, planned - adjusted);
			else TPRemMap.put(TP.Target_Customer_BI__c, current - adjusted);
			
			allTPs.add(TP.Id);			
		}
		
		DPRemMap = new map<String,Decimal>();
		
		for(SAP_Detail_Preparation_BI__c DP : [SELECT Id, Target_Customer_BI__r.Target_Customer_BI__c, Product_BI__c, Planned_Details_BI__c, Adjusted_Details_BI__c FROM SAP_Detail_Preparation_BI__c WHERE Target_Customer_BI__r.SAP_Header_BI__r.Start_Date_BI__c = :P.Start_Date_BI__c]){
			decimal planned = DP.Planned_Details_BI__c == null ? 0 : DP.Planned_Details_BI__c;
			decimal adjusted = DP.Adjusted_Details_BI__c == null ? 0 : DP.Adjusted_Details_BI__c;
			String concatkey = DP.Target_Customer_BI__r.Target_Customer_BI__c + '_' + DP.Product_BI__c;
			decimal current = DPRemMap.get(concatkey);
			
			if(current==null) DPRemMap.put(concatkey, planned - adjusted);
			else DPRemMap.put(concatkey, current - adjusted);
		}
	}
	public map<String, Integer> filterPlanned {get;set;}
	public map<String, Integer> filterAdjusted {get;set;}
	
	public void displayData(){
		system.debug('Getting Targets');
		detailMap = new map<String, SAP_Detail_Preparation_BI__c>();
		prods = new list<Product_vod__c>();
		prodMap = new map<Id, Product_vod__c>();
		renderMap = new map<String, Boolean>();
		string sortFullExp = sortExpression  + ' ' + sortDirection;
		string targetselect = ' ';
		targetselect += ' SELECT Id, Hospital_BI__c, Primary_Parent_BI__c, NTL_Value_BI__c, Primary_Specialty_BI__c, Total_Adjusted_Details_BI__c, Total_Planned_Details_BI__c, Target_Customer_BI__c, Target_Customer_BI__r.Name, Planned_Interactions_BI__c,Remaining_Interactions_BI__c, Adjusted_Interactions_BI__c, External_ID_BI__c, Column_1_BI__c, Column_2_BI__c, ';
		targetselect += ' (SELECT Id, Product_BI__c, Column_BI__c, Row_BI__c, Product_BI__r.Name, Planned_Details_BI__c,Remaining_Details_BI__c, Adjusted_Details_BI__c,Target_Customer_BI__c, Segment_BI__c, Segment_Color_BI__c, Target_Customer_BI__r.Target_Customer_BI__c, External_ID_BI__c  FROM SAP_Details_Preparation__r ORDER BY Product_BI__r.Name) ' ;
		targetselect += ' FROM SAP_Target_Preparation_BI__c WHERE SAP_Header_BI__c = :Pid ';
		if(filterCriteria!=null&&filterCriteria!='') targetselect += filterCriteria;
		targetselect += ' ORDER BY '+ sortFullExp + ' NULLS LAST LIMIT :list_size OFFSET :counter' ;
		System.debug('Target query: ' + targetselect);
		targets = database.query(targetselect);
		
		//FILTER COLLECTION
		filterPlanned = new map<String, Integer>();
		filterAdjusted = new map<String, Integer>();
		
		String filterSelect = '';
		filterselect += ' SELECT SUM(Target_Customer_BI__r.Adjusted_Interactions_BI__c) targetAdj, SUM(Target_Customer_BI__r.PLanned_Interactions_BI__c) targetPlan, SUM(Planned_Details_BI__c) detailPlan, SUM(Adjusted_Details_BI__c) detailAdj, Product_BI__r.Name pName FROM SAP_Detail_Preparation_BI__c WHERE Target_Customer_BI__r.SAP_Header_BI__c = :Pid ';
		if(filterCriteria!=null&&filterCriteria!=''){
			system.debug('filterCriteria BEFORE: ' + filterCriteria);
			filterCriteria = filterCriteria.replaceAll('AND ', 'AND Target_Customer_BI__r.');
			system.debug('filterCriteria AFTER: ' + filterCriteria);
			filterselect += filterCriteria;
		}
		filterselect += ' GROUP BY Product_BI__r.Name';
		
		for(AggregateResult AR : database.query(filterselect)){
			//TARGET ADJUSTED
			Integer targetAdj = 0;
			String targetKey = 'Targets';
			if(filterAdjusted.containsKey(targetKey)) targetAdj += filterAdjusted.get(targetKey);
			targetAdj += Integer.valueOf(AR.get('targetAdj'));
			filterAdjusted.put(targetKey, targetAdj);
			
			//TARGET PLANNED
			Integer targetPlan = 0;
			if(filterPlanned.containsKey(targetKey)) targetPlan += filterPlanned.get(targetKey);
			targetPlan += Integer.valueOf(AR.get('targetPlan'));
			filterPlanned.put(targetKey, targetPlan);
			
			//PRODUCT ADJUSTED
			String productName = '';
			productName += AR.get('pName');  
			filterAdjusted.put(productName, Integer.valueOf(AR.get('detailAdj')));
			
			//PRODUCT PLANNED  
			filterPlanned.put(productName, Integer.valueOf(AR.get('detailPlan')));
		}
		//filterCount = (integer) database.query(filterselect)[0].get('sum');
		//system.debug('filterCount: ' + filterCount);
		
		system.debug('Targets got: ' + targets.size());

		if(targets.size()>0){
			for(SAP_Target_Preparation_BI__c TP : targets){
				for(SAP_Detail_Preparation_BI__c DP : TP.SAP_Details_Preparation__r){
					detailMap.put(TP.External_ID_BI__c+'_'+DP.Product_BI__c, DP);
					//system.debug('product ref: ' + DP.Product_BI__c);
					//system.debug('product added: ' + DP.Product_BI__r);
					renderMap.put(TP.External_ID_BI__c+'_'+DP.Product_BI__c,true);
					prodMap.put(DP.Product_BI__c, DP.Product_BI__r);
				}
			}
			prods.addAll(prodMap.values());
			//add the product filter
			if(ProductSelectOptionList.size()<2){
				for(Product_vod__c P : prods)
					ProductSelectOptionList.add(new SelectOption(P.Id, P.Name));
			}
				
		}
		//go through every target/product and build a complete map to define if a detail should be rendered (to avoid VF crash and burn like the Reistag)
		for(SAP_Target_Preparation_BI__c TP : targets){
			for(Id ProdId : prodMap.keySet()){
				if(renderMap.containsKey(TP.External_ID_BI__c+'_'+ProdId)==false){
					 //system.debug('Rendermap adding false: ' + TP.External_ID_BI__c+'_'+ProdId);
					 renderMap.put(TP.External_ID_BI__c+'_'+ProdId, false) ;
				}
			}
		}
		system.debug('Rendermap: ' + renderMap);
	}
	
	//PAGINATION FUNCTIONS
	public PageReference Beginning() { //user clicked beginning
      if(edit)saverecord();
      if(validateError) return null;
      counter = 0;
      displayData();
      return null;
   }
 
   public PageReference Previous() { //user clicked previous button
      if(edit)saverecord();
      if(validateError) return null;
      counter -= list_size;
      displayData();
      return null;
   }
 
   public PageReference Next() { //user clicked next button
      if(edit)saverecord();
      if(validateError) return null;
      counter += list_size;
      displayData();
      return null;
   }
 
   public PageReference End() { //user clicked end
      if(edit)saverecord();
      if(validateError) return null;
      counter = total_size - math.mod(total_size, list_size);
      displayData();
      return null;
   }
 
   public Boolean getDisablePrevious() { 
      //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
   }
 
   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter + list_size < total_size) return false; else return true;
   }
 
   public Integer getTotal_size() {
      return total_size;
   }
 
   public Integer getPageNumber() {
      return counter/list_size + 1;
   }
 
   public Integer getTotalPages() {
      if (math.mod(total_size, list_size) > 0) {
         return total_size/list_size + 1;
      } else {
         return (total_size/list_size);
      }
   }
   
   boolean validateError = false;
    
   //Save method that can be used
   public void saverecord(){
   		system.debug('saverecord STARTED');
   		//VALIDATE ADJUSTED VALUES
   		validateError=false;
   		for(SAP_Target_Preparation_BI__c T : targets){
   			if(T.Adjusted_Interactions_BI__c<0){
   				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.SAPP_Below_Zero_BI));
   				validateError=true;
   				return;
   			}
   		}
   		for(SAP_Detail_Preparation_BI__c D :detailMap.values()){
   			if(D.Adjusted_Details_BI__c<0){
   				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.SAPP_Below_Zero_BI));
   				validateError=true;
   				return;
   			}
   		}
   		
   		system.debug('P: '+P);
		system.debug('targets: '+targets.size());
		system.debug('details: '+detailMap.size());
		update P;
		update targets;
		update detailMap.values();
   }
   
	
	public pageReference saveedit(){
		system.debug('saveedit STARTED');
		//save on all3 levels
		saverecord();
		if(validateError) return null;
		//go to detail mode
		else return new PageReference('/'+ P.Id);
	}
	
	public pageReference editPrep(){
		system.debug('editPrep STARTED');
		edit = true;
		detail = false;
		return null;
	}
	
	public pageReference canceledit(){
		system.debug('canceledit STARTED');
		//if new Prep record
		if(id==null){
			//delete master object and standard SFDC cascade delete will take care of the rest
			delete P;
			//return to list
			return new PageReference('/'+OBJcode);
		}else{
			//go to detail mode
			return new PageReference('/'+P.id);
		}
	}
	
	public pageReference returntolist(){
		system.debug('returntolist STARTED');
		return new PageReference('/'+OBJcode);
	}

	public pageReference createSAP(){
		system.debug('createSAP STARTED');
		
		
		sp = Database.setSavepoint();
		try{
			list<Cycle_Plan_vod__c> SAPs = new list<Cycle_Plan_vod__c>();
			String SAPname = '';
			SAPname = P.Territory_BI__c +'_'+ P.Start_Date_BI__c.format();
			SAPs = [SELECT Id, Name FROM Cycle_Plan_vod__c WHERE Name = :SAPname LIMIT 1];
			if(SAPs.size() > 0){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.SAPP_Error_sap_create_BI ));
				return null;	
			}
			//IF 0 is the Adjusted value then don't take the line
			//Create the CP, CP target, CP detail based on the Adjusted fields
			Cycle_Plan_vod__c CP = new Cycle_Plan_vod__c(	Name = SAPname,
															End_Date_vod__c = P.End_Date_BI__c,
															Start_Date_vod__c = P.Start_Date_BI__c,
															Territory_vod__c = P.Territory_BI__c,
															OwnerId = P.CreatedbyId);
			insert CP;
			system.debug('CP created: ' + CP.Id);
			//go through target preps
			map<Id, Cycle_Plan_Target_vod__c> CPTmap = new map<Id, Cycle_Plan_Target_vod__c>();
			for(SAP_Target_Preparation_BI__c TP : [SELECT Id,  
														Target_Customer_BI__c,
														Target_Customer_BI__r.Specialty_BI__c,
														Adjusted_Interactions_BI__c
														FROM SAP_Target_Preparation_BI__c 
														WHERE SAP_Header_BI__c = :Pid
														AND Adjusted_Interactions_BI__c != 0 
														AND Adjusted_Interactions_BI__c != null] ){
				//skip if not planned
				//if(TP.Adjusted_Interactions_BI__c == 0 || TP.Adjusted_Interactions_BI__c == null) continue; //added to soql criteria
				//otherwise add
				Cycle_Plan_Target_vod__c CPT = new Cycle_Plan_Target_vod__c(Cycle_Plan_vod__c = CP.id,
																			Cycle_Plan_Account_vod__c = TP.Target_Customer_BI__c,
																			Planned_Calls_vod__c = TP.Adjusted_Interactions_BI__c//,zvod_ACCOUNT_Specialty_BI__c = TP.Target_Customer_BI__r.Specialty_BI__c
																			); 
				CPTmap.put(TP.id,CPT);
			}
			insert CPTmap.values();
			system.debug('CPTs created: ' + CPTmap.values());
			//go through the details
			list<Cycle_Plan_Detail_vod__c> CPDs = new list<Cycle_Plan_Detail_vod__c>();
			for(SAP_Detail_Preparation_BI__c DP : [SELECT Id, 
															Product_BI__c,
															Adjusted_Details_BI__c,
															Target_Customer_BI__c, 
															Segment_BI__c
															FROM SAP_Detail_Preparation_BI__c
															WHERE Target_Customer_BI__c in :CPTmap.keySet()
															AND Adjusted_Details_BI__c != 0 
															AND Adjusted_Details_BI__c != null ] ){
				//skip if not planned
				//if(DP.Adjusted_Details_BI__c == 0 || DP.Adjusted_Details_BI__c == null) continue; //added to soql criteria
				//otherwise add
				Cycle_Plan_Detail_vod__c CPD = new Cycle_Plan_Detail_vod__c(Cycle_Plan_Target_vod__c = CPTmap.get(DP.Target_Customer_BI__c).Id,
																			Product_vod__c = DP.Product_BI__c,
																			Planned_Details_vod__c = DP.Adjusted_Details_BI__c,
																			zvod_PM_Segmentation_BI__c = DP.Segment_BI__c );
				CPDs.add(CPD);
			}
			insert CPDs;
			system.debug('CPDs created: ' + CPDs);
			//set the status to approved
			P.Status_BI__c = 'Approved';
			update P;
			//return to CP edit mode - url: https://c.cs9.visual.force.com/apex/Edit_Cycle_Plan_vod?id=a1NK0000000ukVQMAY&sfdc.override=1
			return new PageReference('/apex/View_Cycle_Plan_vod?id=' + CP.Id + '&sfdc.override=1');
			
		}catch(Exception e){
			system.debug('Insert unsuccessful.');
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SAPP_Error_targeting_BI));	
			return null;		
		}
	}//end of create SAP
	
	//COLUMN SORTING
	private String sortDirection = 'ASC';
   	private String sortExp = 'Target_Customer_BI__r.Name';
	public String sortExpression{
     get{return sortExp;}
     set{
       //if the column is clicked on then switch between Ascending and Descending modes
       //save the record
       if(edit)saverecord();
       //switch mode
       if (value == sortExp)
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       else
         sortDirection = 'ASC';
       sortExp = value;
     }
    }
    public String getSortDirection(){
	    //if not column is selected 
	    if (sortExpression == null || sortExpression == '')
	      return 'ASC';
	    else
	     return sortDirection;
	 }
	 public void setSortDirection(String value){  
	   sortDirection = value;
	 }
	
	//EDITABLE
	public boolean getShowEdit(){
		String pName = [SELECT Id, Name FROM Profile WHERE Id = :Userinfo.getProfileId()].Name;
		
		if(P.Status_BI__c=='Approved' &&  pName != 'System Administrator') return false;
		else return true;
	}
	
	//FILTERING
	private String starts='';
	private String ends='';
	private boolean numfield=false;
	private boolean error=false;
	list<Id> detailedTargetIds;
	
	public pagereference filtertable(){
		error=false;
		if(edit)saverecord();
		if(validateError) return null;
		filterCriteria='';
		detailedTargetIds = new list<Id>();
		
		//add variables to query
		oped(FieldName, Operator); 
		if(error) return null;
		
		Value=Value.trim();
		Value=String.escapeSingleQuotes(Value);
		Value2=Value2.trim();
		Value2=String.escapeSingleQuotes(Value2);
		Value3=Value3.trim();
		Value3=String.escapeSingleQuotes(Value3);
		if(ProductName!=null){
			ProductName=ProductName.trim();
			ProductName=String.escapeSingleQuotes(ProductName);
		}
		if(SegmentName!=null){
			SegmentName=SegmentName.trim();
			SegmentName=String.escapeSingleQuotes(SegmentName);
		}
		
		if(FieldName!='' && Value!='' && Value!=null) filterCriteria += ' AND ' + FieldName +' '+ Operator + starts + Value + ends;
		
		oped(FieldName2, Operator2); 
		if(error) return null;
		if(FieldName2!='' && Value2!='' && Value2!=null) filterCriteria += ' AND ' + FieldName2 +' '+ Operator2 + starts + Value2 +ends;
		
		oped(FieldName3, Operator3); 
		if(error) return null;
		if(FieldName3!='' && Value3!='' && Value3!=null) filterCriteria += ' AND ' + FieldName3 +' '+ Operator3 + starts + Value3 +ends;
		
		if(modified!=null&&modified!='') filterCriteria += ' AND Modified_Adjusted_BI__c = ' + modified;
		
		
		if(ProductName!=null&&ProductName!=''&&SegmentName!=null&&SegmentName!='') {
			for(SAP_Detail_Preparation_BI__c SAPD : [SELECT Target_Customer_BI__c 
														FROM SAP_Detail_Preparation_BI__c 
														WHERE Product_BI__c = :ProductName 
														AND Segment_BI__c = :SegmentName 
														AND Target_Customer_BI__r.Sap_Header_BI__c = :Pid])
				detailedTargetIds.add(SAPD.Target_Customer_BI__c);
			
			filterCriteria += ' AND Id in :detailedTargetIds ';
		}
			
			
		system.debug('Filter criteria: ' + filterCriteria);
		
		String sizeSelect = 'SELECT count(id) co FROM SAP_Target_Preparation_BI__c WHERE SAP_Header_BI__c = \'' + Pid + '\'' + ' ';
		if(filtercriteria!=null) sizeSelect += filtercriteria;
		total_size = (integer) database.query(sizeSelect)[0].get('co');
		
		displayData();
		return null;
	}
	public pagereference clearFilterTable(){
		if(edit)saverecord();
		if(validateError) return null;
		FieldName = '';
		FieldName2 = '';
		FieldName3 = '';
		Value = '';
		Value2 = '';
		Value3 = '';
		modified = '';
		ProductName = '';
		SegmentName = '';
		
		String sizeSelect = 'SELECT count(id) co FROM SAP_Target_Preparation_BI__c WHERE SAP_Header_BI__c = \'' + Pid + '\'' + ' ';
		if(filtercriteria!=null) sizeSelect += filtercriteria;
		total_size = (integer) database.query(sizeSelect)[0].get('co');
		
		system.debug('Filter criteria after clearfilter: ' + filterCriteria);
		displayData();
		return null;
	}
	
	
	private void oped(String selectedfield, String op){
		//add field based logic		
		if(op==' = ' || op==' != '){
			if((selectedfield=='Target_Customer_BI__r.Name'
				||selectedfield=='Primary_Parent_BI__c'
				||selectedfield=='Hospital_BI__c'
				||selectedfield=='Column_1_BI__c'
				||selectedfield=='Column_2_BI__c'
				||selectedfield=='Primary_Specialty_BI__c')){
				starts = ' \'';
				ends = '\' ';
			}else{
				starts='';
				ends='';
			}
		}else if(op=='like'){
			if((selectedfield=='Target_Customer_BI__r.Name'
				||selectedfield=='Primary_Parent_BI__c'
				||selectedfield=='Hospital_BI__c'
				||selectedfield=='Column_1_BI__c'
				||selectedfield=='Column_2_BI__c'
				||selectedfield=='Primary_Specialty_BI__c')){
				starts = ' \'%';
				ends = '%\' ';
			}else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.SAPP_Error_op1_BI));
				error=true;
				return;	
			}
		}else if(op==' > ' || op==' < '){
			if((selectedfield=='Target_Customer_BI__r.Name'
				||selectedfield=='Primary_Parent_BI__c'
				||selectedfield=='Hospital_BI__c'
				||selectedfield=='Column_1_BI__c'
				||selectedfield=='Column_2_BI__c'
				||selectedfield=='Primary_Specialty_BI__c')){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.SAPP_Error_op2_BI));
				error=true;
				return;
			}else{
				starts='';
				ends='';
			}
		}
		
	}
	
	
	private void PopulateFieldsList() {
		system.debug('PopulateFieldsList started');
		FieldsSelectOptionList.clear();
		SegmentSelectOptionList.clear();
		
		FieldsSelectOptionList.add(new SelectOption('', Label.Common_None_vod));
		FieldsSelectOptionList.add(new SelectOption('Target_Customer_BI__r.Name', Schema.Sobjecttype.SAP_Target_Preparation_BI__c.fields.Target_Customer_BI__c.label));
		FieldsSelectOptionList.add(new SelectOption('Primary_Parent_BI__c', Schema.Sobjecttype.SAP_Target_Preparation_BI__c.fields.Primary_Parent_BI__c.label));
		FieldsSelectOptionList.add(new SelectOption('Hospital_BI__c', Schema.Sobjecttype.SAP_Target_Preparation_BI__c.fields.Hospital_BI__c.label));
		FieldsSelectOptionList.add(new SelectOption('Primary_Specialty_BI__c', Schema.Sobjecttype.SAP_Target_Preparation_BI__c.fields.Primary_Specialty_BI__c.label));
		FieldsSelectOptionList.add(new SelectOption('NTL_Value_BI__c', Schema.Sobjecttype.SAP_Target_Preparation_BI__c.fields.NTL_Value_BI__c.label));
		FieldsSelectOptionList.add(new SelectOption('Planned_Interactions_BI__c', Schema.Sobjecttype.SAP_Target_Preparation_BI__c.fields.Planned_Interactions_BI__c.label));
		FieldsSelectOptionList.add(new SelectOption('Adjusted_Interactions_BI__c', Schema.Sobjecttype.SAP_Target_Preparation_BI__c.fields.Adjusted_Interactions_BI__c.label));
		FieldsSelectOptionList.add(new SelectOption('Total_Adjusted_Details_BI__c', Schema.Sobjecttype.SAP_Target_Preparation_BI__c.fields.Total_Adjusted_Details_BI__c.label));
		FieldsSelectOptionList.add(new SelectOption('Column_1_BI__c', Schema.Sobjecttype.SAP_Target_Preparation_BI__c.fields.Column_1_BI__c.label));
		FieldsSelectOptionList.add(new SelectOption('Column_2_BI__c', Schema.Sobjecttype.SAP_Target_Preparation_BI__c.fields.Column_2_BI__c.label));
		
		ProductSelectOptionList.add(new SelectOption('', Label.Common_None_vod));
		SegmentSelectOptionList.add(new SelectOption('', Label.Common_None_vod));
		
		Schema.DescribeFieldResult F = SAP_Detail_Preparation_BI__c.Segment_BI__c.getDescribe();
		system.debug('F: ' + F);
		system.debug('getPicklistValues: ' + F.getPicklistValues());
		for(Schema.PicklistEntry PE : F.getPicklistValues())
			SegmentSelectOptionList.add(new SelectOption(PE.getValue(), PE.getLabel()));
		
	} // PopulateFieldsList
	
	public PageReference PopulateOperatorList1() {
		PopulateOperatorList(FieldName);
		return null;
	}
	public PageReference PopulateOperatorList2() {
		PopulateOperatorList(FieldName2);
		return null;
	}
	public PageReference PopulateOperatorList3() {
		PopulateOperatorList(FieldName3);
		return null;
	}
	
	private void PopulateOperatorList(String selectedfield) {
		OperatorList.add(new SelectOption(' = ',Label.SAPP_Equals_BI));
		OperatorList.add(new SelectOption(' != ',Label.SAPP_not_equal_to_BI));
		OperatorList.add(new SelectOption('like',Label.SAPP_Contains_BI));
		OperatorList.add(new SelectOption(' > ',Label.SAPP_Greater_BI));
		OperatorList.add(new SelectOption(' < ',Label.SAPP_Smaller_BI));
		

		
	}

}