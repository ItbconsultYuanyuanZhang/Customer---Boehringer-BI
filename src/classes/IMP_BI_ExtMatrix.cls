/**
 *	extension class for matrix
 *
 @author Bin Yu
 @created 2013-02-21
 @version 1.0
 @since 26.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
 * - Created
 */
public class IMP_BI_ExtMatrix {
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	public Matrix_BI__c matrix {get; set;}
	public map<Integer, list<IMP_BI_ClsMatrixUtil.MatrixCellInfo>> map_matrixCellInfo {get; set;}	
	public map<Integer, list<Matrix_Cell_BI__c>> map_matrixCell {get; set;}	
	public ExtMatrixConfig emConfig{get;set;}
	public String jsonChannels {get;set;}
	//Added for channel details
	public channelTotalInfo totalChannelInfo {get; set;}
	public list<channelTotalInfo> list_channelDetails {get; set;}


	public integer maxWidth {get; private set;}
	public integer realWidth {get; private set;}
	public integer realHeight {get; private set;}
	
	public string pageTitle {get; private set;}
	public string sectionHeaderTitle {get; private set;}
	public string sectionHeaderSubTitle {get; private set;}
	public Boolean isF2F {get; private set;}
	
	public list<String> list_adptnSts {get; private set;}
	public boolean isLaunch {get; private set;}
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	private final ApexPages.standardController controller;
	private map<Id, Channel_BI__c> map_channels = new map<Id, Channel_BI__c>(); 
	private	map<Id, channelTotalInfo> map_channelId_channelInfo = new map<Id, channelTotalInfo>();
	
	private Integer CELL_WIDTH;
	private Integer CELL_HEIGHT;
	
	private map<String, String> map_urlParams;
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=-   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	/////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
	public IMP_BI_ExtMatrix(ApexPages.standardController sc){
		this.controller = sc;
		Id matrixId = sc.getId();
		map_urlParams = ApexPages.currentPage().getParameters();
		
		if(map_urlParams != null && map_urlParams.containsKey('F2F')){
			if(map_urlParams.get('F2F') != null && map_urlParams.get('F2F').equalsIgnoreCase('true')){
				isF2F = true;
			}else{
				isF2F = false;
			}
		}
		else{
			isF2F = false;
		}
		
		emConfig = new ExtMatrixConfig();
		//Begin:added by Peng Zhu 2013-05-21
		
		
		if(isF2F){
			CELL_WIDTH = 46;
			CELL_HEIGHT = 36;
		}
		else{
			CELL_WIDTH = 90;
			CELL_HEIGHT = 36;
		}
		//End:added by Peng Zhu 2013-05-21

		map_matrixCell = new map<Integer, list<Matrix_Cell_BI__c>>();
		map_matrixCellInfo = new map<Integer, list<IMP_BI_ClsMatrixUtil.MatrixCellInfo>>();
		map_channels = IMP_BI_ClsMatrixUtil.getAllChannels(); 
		
		//Begin: added by Peng Zhu 2013-05-21 for filter channel to leave only "Face to Face"
		if(isF2F){
			map_channels = filterChannelForF2F(map_channels);
		}
		//Begin: added by Peng Zhu 2013-05-21
		
		//Peng Zhu 2013-10-14
		matrix = [Select Cycle_BI__c, Intimacy_Levels_BI__c, Name, Name_BI__c, Potential_Levels_BI__c, Channel_1_BI__c, Channel_2_BI__c, Channel_3_BI__c, Channel_4_BI__c, Channel_5_BI__c, Channel_6_BI__c, Channel_7_BI__c, Channel_8_BI__c, Channel_9_BI__c, Channel_10_BI__c,  
				Product_Catalog_BI__c, Product_Catalog_BI__r.Name, Id, Size_BI__c, Specialization_BI__c, Status_BI__c, Cycle_BI__r.Country_BI__c, Cycle_BI__r.Name, Cycle_BI__r.End_Date_BI__c, Cycle_BI__r.IsCurrent_BI__c, Cycle_BI__r.OwnerId, Cycle_BI__r.Start_Date_BI__c,
				//Begin: added by Peng Zhu 2013-05-10 to add two new fields
				Dimension_1_Name_BI__c, Dimension_2_Name_BI__c, Row_BI__c, Column_BI__c, Matrix_Description_BI__c, Cycle_BI__r.Country_Lkp_BI__r.Name,
				Segment_1_Label_BI__c, Segment_2_Label_BI__c, Segment_3_Label_BI__c, Segment_4_Label_BI__c, Segment_5_Label_BI__c, Cycle_BI__r.Country_Lkp_BI__r.Matrix_Drill_Down_Report_ID_BI__c,
				Lifecycle_Template_BI__c, Lifecycle_Template_BI__r.isLaunch_Phase_BI__c, Lifecycle_Template_BI__r.Adoption_Status_01_BI__c, Lifecycle_Template_BI__r.Adoption_Status_02_BI__c, 
				Lifecycle_Template_BI__r.Adoption_Status_03_BI__c, Lifecycle_Template_BI__r.Adoption_Status_04_BI__c, Lifecycle_Template_BI__r.Adoption_Status_05_BI__c, 
				Lifecycle_Template_BI__r.Potential_Status_01_BI__c, Lifecycle_Template_BI__r.Potential_Status_02_BI__c, Lifecycle_Template_BI__r.Potential_Status_03_BI__c, 
				Lifecycle_Template_BI__r.Potential_Status_04_BI__c, Lifecycle_Template_BI__r.Potential_Status_05_BI__c,
				//End: added by Peng Zhu
				Threshold_1_BI__c,Threshold_2_BI__c,Threshold_3_BI__c,Threshold_4_BI__c,Threshold_5_BI__c,Threshold_6_BI__c,Threshold_7_BI__c,Threshold_8_BI__c,Threshold_9_BI__c,Threshold_10_BI__c  FROM Matrix_BI__c WHERE Id =:matrixId][0];
				
		map_matrixCell = IMP_BI_ClsMatrixUtil.queryMatrixCellsByMatrixId(matrix.Id);  
		//map_matrixCellInfo = IMP_BI_ClsMatrixUtil.queryMatrixCellsByMatrixId(matrix, map_channels.keySet()); 
		buldJsonChannels();
		
		isLaunch = false;
		list_adptnSts = new list<String>();
		if(matrix.Lifecycle_Template_BI__c != null && matrix.Lifecycle_Template_BI__r.isLaunch_Phase_BI__c){
			isLaunch = true;
			
			//list_ptntlSts.add(matrix.Lifecycle_Template_BI__r.Potential_Status_01_BI__c);
			//list_ptntlSts.add(matrix.Lifecycle_Template_BI__r.Potential_Status_02_BI__c);
			//list_ptntlSts.add(matrix.Lifecycle_Template_BI__r.Potential_Status_03_BI__c);
			//list_ptntlSts.add(matrix.Lifecycle_Template_BI__r.Potential_Status_04_BI__c);
			//list_ptntlSts.add(matrix.Lifecycle_Template_BI__r.Potential_Status_05_BI__c);
			
			if(matrix.Lifecycle_Template_BI__r.Adoption_Status_01_BI__c != null && matrix.Lifecycle_Template_BI__r.Adoption_Status_01_BI__c.trim() != ''){
				list_adptnSts.add(matrix.Lifecycle_Template_BI__r.Adoption_Status_01_BI__c);
			}else{
				list_adptnSts.add('0');
			}
			
			if(matrix.Lifecycle_Template_BI__r.Adoption_Status_02_BI__c != null && matrix.Lifecycle_Template_BI__r.Adoption_Status_02_BI__c.trim() != ''){
				list_adptnSts.add(matrix.Lifecycle_Template_BI__r.Adoption_Status_02_BI__c);
			}else{
				list_adptnSts.add('1');
			}
			
			if(matrix.Lifecycle_Template_BI__r.Adoption_Status_03_BI__c != null && matrix.Lifecycle_Template_BI__r.Adoption_Status_03_BI__c.trim() != ''){
				list_adptnSts.add(matrix.Lifecycle_Template_BI__r.Adoption_Status_03_BI__c);
			}else{
				list_adptnSts.add('2');
			}
			
			if(matrix.Lifecycle_Template_BI__r.Adoption_Status_04_BI__c != null && matrix.Lifecycle_Template_BI__r.Adoption_Status_04_BI__c.trim() != ''){
				list_adptnSts.add(matrix.Lifecycle_Template_BI__r.Adoption_Status_04_BI__c);
			}else{
				list_adptnSts.add('3');
			}
			
			if(matrix.Lifecycle_Template_BI__r.Adoption_Status_05_BI__c != null && matrix.Lifecycle_Template_BI__r.Adoption_Status_05_BI__c.trim() != ''){
				list_adptnSts.add(matrix.Lifecycle_Template_BI__r.Adoption_Status_05_BI__c);
			}else{
				list_adptnSts.add('4');
			}
			
			if(matrix.Column_BI__c > 5){
				for(Integer i = 5; i < matrix.Column_BI__c.intValue(); i++){
					list_adptnSts.add(String.valueOf(i));
				}
			}
		}
		//Added for channel total info
		totalChannelInfo = new channelTotalInfo('totalChannel');
		list_channelDetails = getChannelsDetails();	
		initPageWidthFields();
		initPageHeightFields();
		
		pageTitle = system.label.Matrix_Res_Page_Title_BI;
		sectionHeaderTitle = matrix.Name_BI__c;
		sectionHeaderSubTitle = system.label.Matrix_Res_Sub_Title_BI;
		
	}
	/////////////////////////////////// -=END CONSTRUCTOR=- /////////////////////////////////////
	
	
	
	//********************************* -=BEGIN public methods=- ************************************
	/**
	* This method is to get rows
	*
	@author Bin Yu
	@created 2013-02-21
	@version 1.0
	@since 26.0 (Force.com ApiVersion)
	*
	*
	@return	list of integer
	*
	@changelog
	* 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
	* - Created
	*/ 	
	public List<Integer> getRows(){
		List<Integer> list_tmp = new list<Integer>();
		Integer r = 10;
		if(matrix.Potential_Levels_BI__c != null){
			r = Integer.valueOf(matrix.Potential_Levels_BI__c);		
		}
		else if(matrix.Size_BI__c != null){
			r = Integer.valueOf(matrix.Size_BI__c.substringBefore('x'));	
		}
		
		//Begin: added by Peng Zhu 2013-05-10 to replace size by Row_BI__c
		if(matrix.Row_BI__c != null && matrix.Row_BI__c > 0){
			r = matrix.Row_BI__c.intValue();
		}
		//End: added by Peng Zhu
		
		for(Integer i = r; i> 0; i--){
			list_tmp.add(i);
		}
		return list_tmp;
	}	


	/**
	* This method is to get columns
	*
	@author Bin Yu
	@created 2013-02-21
	@version 1.0
	@since 26.0 (Force.com ApiVersion)
	*
	*
	@return	list of integer
	*
	@changelog
	* 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
	* - Created
	*/ 	
	public List<Integer> getColumns(){
		List<Integer> list_tmp = new list<Integer>();
		Integer r = 10;
		if(matrix.Intimacy_Levels_BI__c != null){
			r = Integer.valueOf(matrix.Intimacy_Levels_BI__c);		
		}
		else if(matrix.Size_BI__c != null){
			r = Integer.valueOf(matrix.Size_BI__c.substringAfter('x'));	
		}

		//Begin: added by Peng Zhu 2013-05-10 to replace size by Column_BI__c
		if(matrix.Column_BI__c != null && matrix.Column_BI__c > 0){
			r = matrix.Column_BI__c.intValue();
		}
		//End: added by Peng Zhu
		
		for(Integer i = 0; i<r ; i++){
			list_tmp.add(i);
		}
		return list_tmp;
	}	

	/**
	* This method is to get the list of channels by matrixId
	*
	@author Bin Yu
	@created 2013-02-21
	@version 1.0
	@since 26.0 (Force.com ApiVersion)
	*
	*
	@return	list of channels
	*
	@changelog
	* 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
	* - Created
	*/ 		
	public List<Channel_BI__c> getChannels(){
		return map_channels.values();		
	}
	
	/**
	* This method is to get the list of channels by matrixId
	*
	@author Bin Yu
	@created 2013-02-21
	@version 1.0
	@since 26.0 (Force.com ApiVersion)
	*
	*
	@return	list of channels
	*
	@changelog
	* 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
	* - Created
	*/ 		
	public list<channelTotalInfo> getChannelsDetails(){
		//get total available unit from budget allocation by cycle id and product id and channel id(Face to Face)
		id f2fChannelId = getSelectedChannelId();
		double availableUnit = 0;
		double totalUnit = 0;
		for(Budget_Allocation_BI__c ba : [SELECT Id, Cycle_BI__c, Product_Catalog_BI__c, Channel_BI__c, Budget_BI__c FROM Budget_Allocation_BI__c WHERE Cycle_BI__c = :matrix.Cycle_BI__c AND Product_Catalog_BI__c = :matrix.Product_Catalog_BI__c AND Channel_BI__c = :f2fChannelId]){
			availableUnit = ba.Budget_BI__c;
			totalUnit = ba.Budget_BI__c;
		}
		
		//get all Matrix under this cycle and and link to the same product, sum the Allocated_Units_1__c
		for(Matrix_BI__c m : [SELECT Id, Channel_1_BI__c, Product_Catalog_BI__c, Allocated_Units_1_BI__c, Cycle_BI__c FROM Matrix_BI__c WHERE Allocated_Units_1_BI__c > 0 AND Cycle_BI__c = :matrix.Cycle_BI__c AND Product_Catalog_BI__c = :matrix.Product_Catalog_BI__c AND Channel_1_BI__c = :f2fChannelId]){
			availableUnit = availableUnit - m.Allocated_Units_1_BI__c;
		}
		
		if(availableUnit < 0) availableUnit = 0;
		
		list<channelTotalInfo> list_channelTotal = new list<channelTotalInfo>();
		for(Id cId : map_channelId_channelInfo.keySet()) {
			channelTotalInfo channelTotal = map_channelId_channelInfo.get(cId);
			//channelTotal.availableUnits = Integer.valueOf(map_channels.get(cId).Total_Budget_BI__c);
			channelTotal.availableUnits = Integer.valueOf(availableUnit);
			
			channelTotal.totalUnits = Integer.valueOf(totalUnit);
			
			channelTotal.channelName = map_channels.get(cId).Name;
			
			channelTotal.allocatedUnits = channelTotal.gain + channelTotal.build + channelTotal.defend + channelTotal.observe + channelTotal.maintain ;
			channelTotal.remaining = channelTotal.availableUnits - channelTotal.allocatedUnits ;
			if(channelTotal.totalUnits != 0 ) {
				channelTotal.planned = decimal.valueOf(channelTotal.allocatedUnits).divide(decimal.valueOf(channelTotal.totalUnits), 5) * 100;
			}
			list_channelTotal.add(channelTotal);
			//get total channel detail info
			totalChannelInfo.allocatedUnits += channelTotal.allocatedUnits;
			totalChannelInfo.totalUnits += channelTotal.totalUnits;
			totalChannelInfo.availableUnits += channelTotal.availableUnits;
			totalChannelInfo.gain += channelTotal.gain;
			totalChannelInfo.build += channelTotal.build;
			totalChannelInfo.defend += channelTotal.defend;
			totalChannelInfo.observe += channelTotal.observe;
			totalChannelInfo.maintain += channelTotal.maintain;
			totalChannelInfo.remaining += channelTotal.remaining;
			if(totalChannelInfo.totalUnits != 0 ) {
				totalChannelInfo.planned = decimal.valueOf(totalChannelInfo.allocatedUnits).divide(decimal.valueOf(totalChannelInfo.totalUnits), 5) * 100;
			}		
		}
		
		//Begin: added by Peng Zhu 2013-05-24 for avoiding the empty table and empty bar chart
		if(list_channelTotal.isEmpty() && isF2F){
			for(Channel_BI__c c : map_channels.values()){
				channelTotalInfo channelTotal = new channelTotalInfo(c.Id);
				channelTotal.channelName = c.Name;
				//channelTotal.availableUnits = Integer.valueOf(c.Total_Budget_BI__c);
				channelTotal.totalUnits = Integer.valueOf(totalUnit);
				channelTotal.availableUnits = Integer.valueOf(availableUnit);
				channelTotal.allocatedUnits = channelTotal.gain + channelTotal.build + channelTotal.defend + channelTotal.observe + channelTotal.maintain;
				
				channelTotal.remaining = channelTotal.availableUnits - channelTotal.allocatedUnits;
				if(channelTotal.totalUnits != 0 ) {
					channelTotal.planned = decimal.valueOf(channelTotal.allocatedUnits).divide(decimal.valueOf(channelTotal.totalUnits), 5) * 100;
				}
				list_channelTotal.add(channelTotal);
				
				totalChannelInfo.allocatedUnits += channelTotal.allocatedUnits;
				totalChannelInfo.availableUnits += channelTotal.availableUnits;
				totalChannelInfo.totalUnits += channelTotal.totalUnits;
				totalChannelInfo.gain += channelTotal.gain;
				totalChannelInfo.build += channelTotal.build;
				totalChannelInfo.defend += channelTotal.defend;
				totalChannelInfo.observe += channelTotal.observe;
				totalChannelInfo.maintain += channelTotal.maintain;
				totalChannelInfo.remaining += channelTotal.remaining;
				if(totalChannelInfo.totalUnits != 0 ) {
					totalChannelInfo.planned = decimal.valueOf(totalChannelInfo.allocatedUnits).divide(decimal.valueOf(totalChannelInfo.totalUnits), 5) * 100;
				}
			}
		}
		//End: added by Peng Zhu 2013-05-24
		system.debug('Total : ' + totalChannelInfo);
		system.debug('List : ' + list_channelTotal);
		return list_channelTotal;
	}
	
	/**
	* This method is to save the matrix cells
	*
	@author Bin Yu
	@created 2013-02-21
	@version 1.0
	@since 26.0 (Force.com ApiVersion)
	*
	*
	@return	list of channels
	*
	@changelog
	* 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
	* - Created
	*/ 		
	public pageReference saveMatrix(){
		Savepoint sp = Database.setSavepoint(); 
		try{
			update map_channels.values();
		}catch(DmlException ex){
			ApexPages.addMessages(ex); 
		 	Database.rollback(sp);
		 	return null;	
		}	
		return new PageReference('/'+matrix.Id);	
	}
	
	/**
	* This method is to save the matrix cells
	*
	@author Bin Yu
	@created 2013-02-21
	@version 1.0
	@since 26.0 (Force.com ApiVersion)
	*
	*
	@return	list of channels
	*
	@changelog
	* 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
	* - Created
	*/ 		
	public list<MatrixCellChannel> parserJSON(){
		list<MatrixCellChannel> list_info = new list<MatrixCellChannel>();
		JSONParser parser = JSON.createParser(jsonChannels);

   		while(parser.nextToken() != null) {
         	if(parser.getCurrentToken() == JSONToken.START_ARRAY) { // Start at the array of invoices. 
              	while(parser.nextToken() != null) {
                  	if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                      	MatrixCellChannel s = (MatrixCellChannel) parser.readValueAs(IMP_BI_ExtMatrix.MatrixCellChannel.class);
                      	list_info.add(s);
                      	parser.skipChildren();
                  	}
              	}
         	}
   		}
		return list_info;
	}
	
	/**
	* This method is to save the matrix cells
	*
	@author Bin Yu
	@created 2013-02-21
	@version 1.0
	@since 26.0 (Force.com ApiVersion)
	*
	*
	@return	list of channels
	*
	@changelog
	* 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
	* - Created
	*/ 		
	public void saveChannelBudget(){
		list<Matrix_Cell_BI__c> list_matrixCell2Update = new list<Matrix_Cell_BI__c>();
		map<Id, map<Integer, decimal>> map_mcId_map_channelNumber_budgetValue = new map<Id, map<Integer, decimal>>();
		map<Id, Integer> map_channelId_channelNumber = new map<Id, Integer>();
		map<Integer, Id> map_channelNumber_channelId = new map<Integer, Id>();
		
		//Get matrix cell channel data from json
		list<MatrixCellChannel> list_info = new list<MatrixCellChannel>();
		list_info = parserJSON();
		
		//Test Method, need be deleted
		/*
		//system.debug('List size @@@@@: ' + list_info);
		//for(Integer i = 0; i < list_info.size(); i++) {
		//	Integer cc = math.mod(i, 3);
		//	if(cc == 0) {
				list_info[i].channelId = 'a022000000HwBxaAAF';
				list_info[i].channelBudget = '1';
			}
			if(cc == 1) {
				list_info[i].channelId = 'a022000000HwBxzAAF';
				list_info[i].channelBudget = '2';
			}
			if(cc == 2) {
				list_info[i].channelId = 'a022000000HwBxkAAF';
				list_info[i].channelBudget = '3';
			}
			
			
		}
		system.debug('Updated list : ' + list_info);
		*/
		//End Test Method
		
		
		Integer channelCounter = 1;
		Savepoint sp = Database.setSavepoint(); 
		try{
			for(MatrixCellChannel mcChannel : list_info) {
				Integer mcRow = Integer.valueOf(mcChannel.cellRow);
				Integer mcColumn = Integer.valueOf(mcChannel.cellColumn);
				if(mcChannel.channelBudget != 'null') {
					//update channel counter to get current channel amounts
					if(!map_channelId_channelNumber.containsKey(mcChannel.channelId)) {
						map_channelId_channelNumber.put(mcChannel.channelId, channelCounter);
						map_channelNumber_channelId.put(channelCounter, mcChannel.channelId);
						channelCounter ++;
					}
					//store matrix cell budget value in map
					Matrix_Cell_BI__c mc = map_matrixCell.get(mcRow)[mcColumn];
					if(!map_mcId_map_channelNumber_budgetValue.containsKey(mc.Id)) {
						map_mcId_map_channelNumber_budgetValue.put(mc.Id, new map<Integer, decimal>());
					}
					if(map_mcId_map_channelNumber_budgetValue.get(mc.Id).containsKey(map_channelId_channelNumber.get(mcChannel.channelId))) {
						system.debug('Data error : ' +mc.Id + ' ssss ' + map_channelId_channelNumber.get(mcChannel.channelId));
					}
					map_mcId_map_channelNumber_budgetValue.get(mc.Id).put(map_channelId_channelNumber.get(mcChannel.channelId), Decimal.valueOf(mcChannel.channelBudget));
				}
			}
			system.debug('Map size @@@ ' + map_mcId_map_channelNumber_budgetValue.values());
			if(!map_channelNumber_channelId.isEmpty()) {
				//Reset Matrix all channel field
				for(Integer cnlCounter = 1; cnlCounter <=10 ; cnlCounter ++) {
					matrix.put('Channel_' + cnlCounter + '_BI__c', null);
				}
				for(Integer i : map_channelNumber_channelId.keySet()) {
					//update matrix channel field
					matrix.put('Channel_' + i + '_BI__c', map_channelNumber_channelId.get(i));
				}
				//reset Matrix cell all channel budget field
				for(Integer row : map_matrixCell.keySet()) {
					for(Matrix_Cell_BI__c mc : map_matrixCell.get(row)) {
						for(Integer channelNo = 1; channelNo <= 10; channelNo++) {
							mc.put('Channel_' + channelNo + '_Budget_BI__c', null);
						}
					}
				}				
				//Update matrix cell
				for(Integer row : map_matrixCell.keySet()) {
					for(Matrix_Cell_BI__c mc : map_matrixCell.get(row)) {
						if(map_mcId_map_channelNumber_budgetValue.containsKey(mc.Id)) {
							for(Integer channelNo : map_mcId_map_channelNumber_budgetValue.get(mc.Id).keySet()) {
								mc.put('Channel_' + channelNo + '_Budget_BI__c', map_mcId_map_channelNumber_budgetValue.get(mc.Id).get(channelNo));
							}
							list_matrixCell2Update.add(mc);
						}
					}
				}
			}
			update matrix;
			if(!list_matrixCell2Update.isEmpty()) update list_matrixCell2Update;
		}catch(DmlException ex){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex+''));
		// 	Database.rollback(sp);
		}	
	//	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, list_info+''));
	}
	public String getLt(){
		return '<';
	}	
	public String getGt(){
		return '>';
	}
	/**
	* This method is get "Face to Face" channel id
	*
	@author Minghao Li
	@created 2013-03-04
	@version 1.0
	@since 26.0 (Force.com ApiVersion)
	*
	*
	@return	String to id
	*
	@changelog
	* 2013-03-04 Minghao Li <minghao.li@itbconsult.com>
	* - Created
	*/ 
	public String getSelectedChannelId(){
		list<Channel_BI__c> list_cnannel = getChannels();
		Id channel_id = null;
		for(Channel_BI__c c : list_cnannel){
			if(c.Name == 'Face to Face'){
				channel_id = c.Id;
				break;
			}
		}
		return channel_id;
	}
	//********************************* -=END public methods=- **************************************
	
	
	//********************************* -=BEGIN private methods=- ************************************
	/**
	* This method is used to remove channel except "Face to Face" channel
	*
	@author  Peng Zhu
	@created 2013-05-21
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	*
	@return  map_channels	map<Id, Channel_BI__c>
	*
	@changelog
	* 2013-05-21 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/ 
	public map<Id, Channel_BI__c> filterChannelForF2F(map<Id, Channel_BI__c> map_id_channel){
		map<Id, Channel_BI__c> map_id_channelRt = new map<Id, Channel_BI__c>();
		if(map_id_channel != null && !map_id_channel.isEmpty()){
			for(Channel_BI__c c : map_id_channel.values()){
				if(c.Name == 'Face to Face'){
					map_id_channelRt.put(c.Id, c);
					break;
				}
			}
		}
		return map_id_channelRt;
	}
	
	private void initPageWidthFields(){
		Integer r = 10;
		if(matrix.Intimacy_Levels_BI__c != null){
			r = Integer.valueOf(matrix.Intimacy_Levels_BI__c);		
		}
		else if(matrix.Size_BI__c != null){
			r = Integer.valueOf(matrix.Size_BI__c.substringAfter('x'));	
		}

		//Begin: added by Peng Zhu 2013-05-10 to replace size by Column_BI__c
		if(matrix.Column_BI__c != null && matrix.Column_BI__c > 0){
			r = matrix.Column_BI__c.intValue();
		}
		
		r = (r + 1) * CELL_WIDTH + 2;
		realWidth = r;
		if(r > 746) maxWidth = r;
		else maxWidth = 746;
	}
	
	private void initPageHeightFields(){
		Integer r = 10;
		if(matrix.Potential_Levels_BI__c != null){
			r = Integer.valueOf(matrix.Potential_Levels_BI__c);		
		}
		else if(matrix.Size_BI__c != null){
			r = Integer.valueOf(matrix.Size_BI__c.substringBefore('x'));	
		}
		
		//Begin: added by Peng Zhu 2013-05-10 to replace size by Row_BI__c
		if(matrix.Row_BI__c != null && matrix.Row_BI__c > 0){
			r = matrix.Row_BI__c.intValue();
		}
		
		realHeight = (r + 1) * CELL_HEIGHT + 2;
	}
	
	private void buldJsonChannels(){
		Map<Id, MatrixCellChannel> map_cellChannels = new map<Id, MatrixCellChannel>();
		list<MatrixCellChannel> list_matrixCellChannels = new list<MatrixCellChannel>();

		
		for(Channel_BI__c ch :map_Channels.values()){
			MatrixCellChannel mcc = new MatrixCellChannel(ch.Id);
			map_cellChannels.put(ch.Id, mcc);

		}
		Map<Id, String> map_channelId_fields = new Map<Id, String>();		
		set<String> set_fields = new set<String>();
		for(Integer i = 1; i<=10; i++){				
			String f = 'Channel_' + String.valueOf(i) + '_BI__c';
			String cf = 'Channel_' + String.valueOf(i) + '_Budget_BI__c';
			if(matrix.get(f) != null){
				map_channelId_fields.put((Id) matrix.get(f), cf);
				set_fields.add(cf);
			}
		}	
		for(Integer i : map_matrixCell.keySet()){				
			for(Matrix_Cell_BI__c mc :map_matrixCell.get(i)){
				for(Id cId: map_cellChannels.keySet()){
					MatrixCellChannel mcc = map_cellChannels.get(cId).clone();
					mcc.cellRow = String.valueOf(mc.Row_BI__c);
					mcc.cellColumn = String.valueOf(mc.Column_BI__c);
					if(map_channelId_fields.containsKey(cId) && mc.get(map_channelId_fields.get(cId)) != null){ 
						mcc.channelBudget = String.valueOf(Integer.valueOf(mc.get(map_channelId_fields.get(cId))));
						//Added to get channel total budget
						if(!map_channelId_channelInfo.containsKey(cId)) map_channelId_channelInfo.put(cId, new channelTotalInfo(cId));
						channelTotalInfo channelTotalInfo = map_channelId_channelInfo.get(cId);
						if(mc.Segment_BI__c == 'Observe') channelTotalInfo.observe += Integer.valueOf(mc.get(map_channelId_fields.get(cId)));
						if(mc.Segment_BI__c == 'Defend') channelTotalInfo.defend += Integer.valueOf(mc.get(map_channelId_fields.get(cId)));
						if(mc.Segment_BI__c == 'Gain') channelTotalInfo.gain += Integer.valueOf(mc.get(map_channelId_fields.get(cId)));
						if(mc.Segment_BI__c == 'Build') channelTotalInfo.build += Integer.valueOf(mc.get(map_channelId_fields.get(cId)));
						if(mc.Segment_BI__c == 'Maintain') channelTotalInfo.maintain += Integer.valueOf(mc.get(map_channelId_fields.get(cId)));	
						//End						
					}
					list_matrixCellChannels.add(mcc);
				}
			}
		}
		system.debug('Channel Map : ' + map_channelId_channelInfo.values());
		jsonChannels = (Json.serialize(list_matrixCellChannels));		
	}
	
	//********************************* -=BEGIN inner classes=- **************************************
	public class ExtMatrixConfig{
		public String jsPath {get; set;}
		public String locale {get; set;}
		public ExtMatrixConfig(){
			this.locale= Userinfo.getLocale();
			try{
				List<String> list_s = locale.split('_');
				this.locale = list_s[0]+'-'+list_s[1];
			}catch(Exception e){
				this.locale = 'de-DE';
			} 
			this.jsPath = '/glob-cultures/cultures/globalize.culture.'+locale+'.js';
		}
		
	}
	
	public class MatrixCellChannel{
		public String channelId {get;set;}
		public String channelBudget {get;set;}
		public String cellRow {get;set;}
		public String cellColumn {get;set;}

		public MatrixCellChannel(String cId){
			channelId = cId;
			channelBudget = 'null';
			cellRow = 'null';
			cellColumn = 'null';
		}
	}	

	public class channelTotalInfo{
		public String channelId {get; set;}
		public String channelName {get; set;}
		public Integer availableUnits {get; set;}
		public Integer allocatedUnits {get; set;}
		public Integer remaining {get;set;}
		public Integer gain {get; set;}
		public Integer build {get; set;}
		public Integer defend {get; set;}
		public Integer observe {get; set;} 
		public Integer maintain {get; set;}
		public decimal planned {get; set;}
		
		public Integer totalUnits {get; set;}
		
		public channelTotalInfo(String cId){
			channelId = cId;
			availableUnits = 0;
			allocatedUnits = 0;
			remaining = 0;
			gain = 0;
			build = 0;
			defend = 0;
			observe = 0;
			maintain = 0;
			
			totalUnits= 0;
		}
	}	
	//********************************* -=END inner classes=- ****************************************	
}