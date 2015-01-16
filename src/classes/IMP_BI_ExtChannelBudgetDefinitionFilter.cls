/**
 *  extension class for page "IMP_BI_ExtChannelBudgetDefinitionFilter"
 *
 @author  Peng Zhu
 @created 2013-05-27
 @version 1.0
 @since   27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-05-27 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created : modified base on class "IMP_BI_ExtMatrix.cls"
 */
public class IMP_BI_ExtChannelBudgetDefinitionFilter {
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    public Matrix_BI__c matrix {get; set;}
    
    public map<Integer, list<Matrix_Cell_BI__c>> map_matrixCell {get; set;} 
    public ExtMatrixConfig emConfig{get;set;}
    public static String jsonChannels {get;set;}
    //Added for channel details
    public channelTotalInfo totalChannelInfo {get; set;}
    public list<channelTotalInfo> list_channelDetails {get; set;}

    //Begin: added by Peng Zhu 
    public integer maxWidth {get; private set;}
    public integer realWidth {get; private set;}
    public integer realHeight {get; private set;}
    
    public string pageTitle {get; private set;}
    public string sectionHeaderTitle {get; private set;}
    public string sectionHeaderSubTitle {get; private set;}
    public string theLocale {get; private set;}
    
    //added by Peng Zhu 2013-06-19 for Launch Template
    public list<String> list_adptnSts {get; private set;}
    public boolean isLaunch {get; private set;}
    
    //added by Peng Zhu 2013-06-05 
    public string jsonMatrixFilters {get; set;}
    public string matrixCellCounterMap {get; set;}
    public integer listMCDSize {get; private set;}
    public string matrixDrillDownReportUrl {get; private set;}
    
    //added by Peng Zhu 2013-09-11
    public String json_MatrixFilterCondition {get; set;}
    
    public String filterIndex {get; set;}
    
    public Integer filterSize {get; set;}
    
    public boolean isFinal {get; private set;}
    //End: added by Peng Zhu
    
    //Begin:added by Peng Zhu 2013-07-30 for dynamic filters
    public String filterComb {get; set;}
    //End:added by Peng Zhu 2013-07-30 for dynamic filters
    //Begin: added by Peng Zhu 2013-09-04
    public static string jsonMatrixCellDetails {get; set;}
    public static string jsonCellDetailIds {get; set;}
    public map<Integer, list<SelectOption>> map_idx_filter {get; set;}
    public map<Integer, String> map_idx_filterV {get; set;}
    public set<Integer> set_filterIdx {get; set;}
    public boolean hasError {get; private set;}
    
    //End: added by Peng Zhu 2013-09-04
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    private map<Id, Channel_BI__c> map_id_channel = new map<Id, Channel_BI__c>(); 
    private map<Id, channelTotalInfo> map_channelId_channelInfo = new map<Id, channelTotalInfo>();
    
    //Begin: added by Peng Zhu
    private static final String NO_FILTER_LABEL = '--No Filter--';
    private static final String MATRIX_STATUS_FINAL = 'Ready for NTL';
    
    //added by Peng Zhu 2013-06-17 for filter function
    private list<String> list_filterFields;
    private map<Integer, String> map_index_combinationName;
    private map<String, Integer> map_filterCombi_index;
    private Map<String,String> map_cdApi_acApi;
            
    //For channel table
    private map<Id, map<String, channelTotalInfo>> map_cnlId_index_cnlInfo;
    
    private map<String, String> map_urlParams;
    private Boolean isUsedFilter;
    private map<String, map<String, Integer>> map_mcId_matchKey_accNum;
    //End: added by Peng Zhu
    
    private map<String, String> map_aName_aLabel;//added by Peng Zhu 2013-07-30
    
    private string channelTypeCombination = '';
    
    private map<Id, Budget_Allocation_BI__c> map_chId_bab;
    private Boolean hasValue;
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=-   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    /////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
    public IMP_BI_ExtChannelBudgetDefinitionFilter(ApexPages.standardController sc){
        hasError = false;
        hasValue = false;
        init();
        map_urlParams = ApexPages.currentPage().getParameters();
        
        Id matrixId = sc.getId();
        
        matrix = [SELECT Cycle_BI__c, Matrix_Filter_BI__c , Intimacy_Levels_BI__c, Name, Name_BI__c, Potential_Levels_BI__c, Channel_1_BI__c, Channel_2_BI__c, Channel_3_BI__c, Channel_4_BI__c, Channel_5_BI__c, Channel_6_BI__c, Channel_7_BI__c, Channel_8_BI__c, Channel_9_BI__c, Channel_10_BI__c,Cycle_BI__r.Country_Lkp_BI__c,  
                         Product_Catalog_BI__c, Product_Catalog_BI__r.Name, Id, Size_BI__c, Specialization_BI__c, Status_BI__c, Cycle_BI__r.Country_BI__c, Cycle_BI__r.Name, Cycle_BI__r.End_Date_BI__c, Cycle_BI__r.IsCurrent_BI__c, Cycle_BI__r.OwnerId, Cycle_BI__r.Start_Date_BI__c,Potential_Data_Label_BI__c,Adoption_Data_Label_BI__c,
                         //Begin: added by Peng Zhu 2013-05-10 to add two new fields
                         Dimension_1_Name_BI__c, Dimension_2_Name_BI__c, Row_BI__c, Column_BI__c, Matrix_Description_BI__c, Cycle_BI__r.Country_Lkp_BI__r.Name,
                         Segment_1_Label_BI__c, Segment_2_Label_BI__c, Segment_3_Label_BI__c, Segment_4_Label_BI__c, Segment_5_Label_BI__c, Cycle_BI__r.Country_Lkp_BI__r.Matrix_Drill_Down_Report_ID_BI__c,
                         Lifecycle_Template_BI__c, Lifecycle_Template_BI__r.isLaunch_Phase_BI__c, Lifecycle_Template_BI__r.Adoption_Status_01_BI__c, Lifecycle_Template_BI__r.Adoption_Status_02_BI__c, 
                         Lifecycle_Template_BI__r.Adoption_Status_03_BI__c, Lifecycle_Template_BI__r.Adoption_Status_04_BI__c, Lifecycle_Template_BI__r.Adoption_Status_05_BI__c, 
                         Lifecycle_Template_BI__r.Potential_Status_01_BI__c, Lifecycle_Template_BI__r.Potential_Status_02_BI__c, Lifecycle_Template_BI__r.Potential_Status_03_BI__c, 
                         Lifecycle_Template_BI__r.Potential_Status_04_BI__c, Lifecycle_Template_BI__r.Potential_Status_05_BI__c,
                         Filter_Field_1_BI__c, Filter_Field_2_BI__c, Filter_Field_3_BI__c,
                         Channel_1_BI__r.Name, Channel_2_BI__r.Name, Channel_3_BI__r.Name, Channel_4_BI__r.Name, Channel_5_BI__r.Name, 
                         Channel_6_BI__r.Name, Channel_7_BI__r.Name, Channel_8_BI__r.Name, Channel_9_BI__r.Name, Channel_10_BI__r.Name,
                         //End: added by Peng Zhu
                         //Begin: added by Yuanyuan Zhang 2015-01-05
                         Current_BI__c, First_Scenario_BI__c, Scenario_BI__c,
                          //End
                         Threshold_1_BI__c,Threshold_2_BI__c,Threshold_3_BI__c,Threshold_4_BI__c,Threshold_5_BI__c,Threshold_6_BI__c,Threshold_7_BI__c,Threshold_8_BI__c,Threshold_9_BI__c,Threshold_10_BI__c 
                  FROM Matrix_BI__c WHERE Id =:matrixId][0];

        //Begin: added by Peng Zhu 203-10-25
        if(matrix.Status_BI__c == MATRIX_STATUS_FINAL) isFinal = true;
        
        //get matrix cell info
        map_matrixCell = IMP_BI_ClsMatrixUtil.queryMatrixCellsByMatrixId(matrix.Id); 
        
        //get channel and budget allocation info
        getChannelAndBudgetAllocationInfo();
        checkMatrixCellDetailPrev();

        //get the filter picklist for page
        initFilterPicklist();
        
        //generate the filter combination name
        generateFilterCombinationName();
        
        //generate chennel info
        buldJsonChannelsByFilter();
        //Added for channel total info
        totalChannelInfo = new channelTotalInfo('totalChannel');
        list_channelDetails = getChannelsDetails(); 
        
        //Begin: added by Peng Zhu 
        initAfterAll();
        //End: added by Peng Zhu 
        //system.debug(':: map_idx_filterV: ' + map_idx_filterV);
    }
    /////////////////////////////////// -=END CONSTRUCTOR=- /////////////////////////////////////
    
    //********************************* -=BEGIN public methods=- ************************************
    public List<SelectOption> getChannelPicklist(){
        list<SelectOption> list_so = new list<SelectOption>();
        
        list_so.add(new SelectOption('', '--None--'));
        
        if(map_id_channel != NULL){
            for(Channel_BI__c c : map_id_channel.values()){
                list_so.add(new SelectOption(c.Id, c.Name));
            }
        }
        
        return list_so;
    }
    
    private void checkMatrixCellDetailPrev(){
        if(matrix != null && matrix.Id != null){// && matrix.Matrix_Filter_BI__c == null
            //Boolean hasValue = false;//, hasError = false;
            for(Matrix_Cell_Detail_BI__c mcdb : [SELECT Id, Name, Matrix_Cell_BI__c, Channel_Type_BI__c,Matrix_Cell_BI__r.Matrix_BI__r.Status_BI__c FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__r.Matrix_BI__c = :matrix.Id LIMIT 1 ]){
                hasValue = true;
                
                if(mcdb.Channel_Type_BI__c != channelTypeCombination && !mcdb.Matrix_Cell_BI__r.Matrix_BI__r.Status_BI__c.equalsIgnoreCase(MATRIX_STATUS_FINAL))
                    hasError = true;
            }
            if(hasError){
                String errMsg = 'The Buget Allocation has beed changed. Click<a href="javascript:leavingPage = false; resetMatrixCellDetail();">Reset</a> to reset the Matrix Cell Details. Click<a href="/' + matrix.Id + '">here</a>to return back.'; 

                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errMsg));
            }
           
            if(matrix.Matrix_Filter_BI__c == null) hasValue = true;
        }
    }
    
    public void checkMatrixCellDetail(){
        if(!hasValue){
            createMatrixCellDetailForNoFilter();
        }
        /*
        if(matrix != null && matrix.Id != null && matrix.Matrix_Filter_BI__c == null){
            Boolean hasValue = false;//, hasError = false;
            for(Matrix_Cell_Detail_BI__c mcdb : [SELECT Id, Name, Matrix_Cell_BI__c, Channel_Type_BI__c FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__r.Matrix_BI__c = :matrix.Id LIMIT 1]){
                hasValue = true;
                
                if(mcdb.Channel_Type_BI__c != channelTypeCombination) hasError = true;
            }
            
            if(hasError){
                String errMsg = 'The Buget Allocation has beed changed. Click<a href="javascript:resetMatrixCellDetail();">Reset</a> to reset the Matrix Cell Details. Click<a href="/' + matrix.Id + '">here</a>to return back.'; 

                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errMsg));
                
            //  list<Matrix_Cell_Detail_BI__c> list_mcdb2Update = new list<Matrix_Cell_Detail_BI__c>();
            //  for(Matrix_Cell_Detail_BI__c mcdb : [SELECT Id, Name, Matrix_Cell_BI__c, Channel_Type_BI__c, Channel_1_Quantity_BI__c, Channel_2_Quantity_BI__c, Channel_3_Quantity_BI__c, Channel_4_Quantity_BI__c, Channel_5_Quantity_BI__c FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__r.Matrix_BI__c = :matrix.Id]){
            //      mcdb.Channel_Type_BI__c = channelTypeCombination;
            //      mcdb.Channel_1_Quantity_BI__c = 0;
            //      mcdb.Channel_2_Quantity_BI__c = 0;
            //      mcdb.Channel_3_Quantity_BI__c = 0;
            //      mcdb.Channel_4_Quantity_BI__c = 0;
            //      mcdb.Channel_5_Quantity_BI__c = 0;
            //      
            //      list_mcdb2Update.add(mcdb);
            //  }
            //  
            //  if(!list_mcdb2Update.isEmpty()){
            //      update list_mcdb2Update;
            //      reloadDataAfterApply();
            //  }
            }
           
            if(!hasValue){
                createMatrixCellDetailForNoFilter();
            }
        }
        */
    }
    
    public void resetMatrixCellDetail(){
        if(matrix != NULL && matrix.Id != NULL){
            list<Matrix_Cell_Detail_BI__c> list_mcdb2Update = new list<Matrix_Cell_Detail_BI__c>();
            
            for(Matrix_Cell_Detail_BI__c mcdb : [SELECT Id, Name, Matrix_Cell_BI__c, Channel_Type_BI__c, Channel_1_Quantity_BI__c, Channel_2_Quantity_BI__c, Channel_3_Quantity_BI__c, Channel_4_Quantity_BI__c, Channel_5_Quantity_BI__c FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__r.Matrix_BI__c = :matrix.Id]){
                mcdb.Channel_Type_BI__c = channelTypeCombination;
                mcdb.Channel_1_Quantity_BI__c = 0;
                mcdb.Channel_2_Quantity_BI__c = 0;
                mcdb.Channel_3_Quantity_BI__c = 0;
                mcdb.Channel_4_Quantity_BI__c = 0;
                mcdb.Channel_5_Quantity_BI__c = 0;
                
                list_mcdb2Update.add(mcdb);
            }
            
            if(!list_mcdb2Update.isEmpty()){
                update list_mcdb2Update;
                
                hasError = false;
                
                reloadDataAfterApply();
            }
        }
    }
    
    public void createMatrixCellDetailForNoFilter(){
        if(matrix != null){
                
            list<Matrix_Cell_BI__c> list_mc = new list<Matrix_Cell_BI__c>();
            
            for(list<Matrix_Cell_BI__c> l_mc : map_matrixCell.values()){
                list_mc.addAll(l_mc);
            }
                
                
            set<string> set_channelName = new set<string>();

            list<Matrix_Cell_Detail_BI__c> list_mcd2Insert = new list<Matrix_Cell_Detail_BI__c>();
            
            List<Matrix_Cell_BI__c> set_mcId = new List<Matrix_Cell_BI__c>();

            for(Matrix_Cell_BI__c mc : list_mc){
                set_mcId.add(mc);
            }
            //for now, just need "Face to Face"
            set_channelName.add('Face to Face');
            
            for(Matrix_Cell_BI__c mc : set_mcId){
                for(string cName : set_channelName){

                    Matrix_Cell_Detail_BI__c mcd = new Matrix_Cell_Detail_BI__c();
                    mcd.Matrix_Cell_BI__c = mc.Id;
                    mcd.Channel_BI__c = cName;
                    mcd.Channel_Type_BI__c = channelTypeCombination;
                    mcd.Quantity_BI__c = 0;
                    mcd.Account_Counter_BI__c = (mc.Total_Customers_BI__c == null) ? 0 : mc.Total_Customers_BI__c;
                    mcd.Cycle_Data_Counter_BI__c = 0;
                    
                    list_mcd2Insert.add(mcd);
                }
            }
                
            for(list<Matrix_Cell_Detail_BI__c> list_mcd2Del : [SELECT Id, Matrix_Cell_BI__c FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__c IN :set_mcId]){
                if(list_mcd2Del != null && !list_mcd2Del.isEmpty()) delete list_mcd2Del;
            }
            
            if(!list_mcd2Insert.isEmpty()) insert list_mcd2Insert;
        }
        reloadDataAfterApply();
    }
    
    /**
    * This method is to get rows
    *
    @author  Bin Yu
    @created 2013-02-21
    @version 1.0
    @since   26.0 (Force.com ApiVersion)
    *
    @return  list of integer
    *
    @changelog
    * 2013-11-12 Peng Zhu <peng.zhu@itbconsult.com>
    * - Modified: remove the get column code into a method for invok
    *
    * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
    * - Created
    */  
    public List<Integer> getRows(){
        List<Integer> list_tmp = new list<Integer>();
        
        Integer r = this.getMatrixRow();
        
        for(Integer i = r; i> 0; i--){
            list_tmp.add(i);
        }
        
        return list_tmp;
    }   


   /**
    * This method is to get columns list
    *
    @author  Bin Yu
    @created 2013-02-21
    @version 1.0
    @since   26.0 (Force.com ApiVersion)
    *
    @return list of integer
    *
    @changelog
    * 2013-11-12 Peng Zhu <peng.zhu@itbconsult.com>
    * - Modified: remove the get column code into a method for invok
    *
    * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
    * - Created
    */  
    public List<Integer> getColumns(){
        List<Integer> list_tmp = new list<Integer>();
        
        Integer r = this.getMatrixColumn();
        
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
    @return list of channels
    *
    @changelog
    * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
    * - Created
    */      
    public List<Channel_BI__c> getChannels(){
        return map_id_channel.values();       
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
    @return list of channels
    *
    @changelog
    * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
    * - Created
    */      
    public list<channelTotalInfo> getChannelsDetails(){
        //channelTypeCombination
        map<Id, Decimal> map_chId_usedBudget = new map<Id, Decimal>();
  
        if(channelTypeCombination != NULL && channelTypeCombination.trim() != ''){
            String[] cTypes = channelTypeCombination.split('\\;');
            
            Decimal ch_summary = 0;
            String chId;
            
            for(Matrix_BI__c m : [SELECT Id, Channel_1_BI__c, Product_Catalog_BI__c, Allocated_Units_1_BI__c, Cycle_BI__c, Channel_1_Summary_BI__c, Channel_2_Summary_BI__c, Channel_3_Summary_BI__c, Channel_4_Summary_BI__c, Channel_5_Summary_BI__c FROM Matrix_BI__c WHERE Cycle_BI__c = :matrix.Cycle_BI__c AND Product_Catalog_BI__c = :matrix.Product_Catalog_BI__c AND Channel_1_BI__c IN :cTypes]){
                for(Integer i=0; i < cTypes.size(); i++){
                    chId = cTypes[i];
                    if(chId != NULL && chId.trim() != ''){
                        if(i == 0) ch_summary = m.Channel_1_Summary_BI__c;
                        else if(i == 1) ch_summary = m.Channel_2_Summary_BI__c;
                        else if(i == 2) ch_summary = m.Channel_3_Summary_BI__c;
                        else if(i == 3) ch_summary = m.Channel_4_Summary_BI__c;
                        else if(i == 4) ch_summary = m.Channel_5_Summary_BI__c;
                        
                        
                        if(!map_chId_usedBudget.containsKey(chId)) map_chId_usedBudget.put(chId, ch_summary);
                        else{
                            map_chId_usedBudget.put(chId, (map_chId_usedBudget.get(chId) + ch_summary));
                        }
                    }
                }
            }
        }
        
        //get total available unit from budget allocation by cycle id and product id and channel id(Face to Face)
        id f2fChannelId = getSelectedChannelId();
        double totalUnit = 0, availableUnit = 0, remainingUnit = 0;
        
        //map_cnlId_index_cnlInfo = new map<Id, map<String, channelTotalInfo>>();
        for(Budget_Allocation_BI__c ba : [SELECT Id, Cycle_BI__c, Product_Catalog_BI__c, Channel_BI__c, Budget_BI__c FROM Budget_Allocation_BI__c WHERE Cycle_BI__c = :matrix.Cycle_BI__c AND Product_Catalog_BI__c = :matrix.Product_Catalog_BI__c AND Channel_BI__c = :f2fChannelId]){
            availableUnit = ba.Budget_BI__c;
            totalUnit = ba.Budget_BI__c;
            remainingUnit = ba.Budget_BI__c;
        }
        
        //get all Matrix under this cycle and and link to the same product, sum the Allocated_Units_1__c
        for(Matrix_BI__c m : [SELECT Id, Channel_1_BI__c, Product_Catalog_BI__c, Allocated_Units_1_BI__c, Cycle_BI__c FROM Matrix_BI__c WHERE Allocated_Units_1_BI__c > 0 AND Cycle_BI__c = :matrix.Cycle_BI__c AND Product_Catalog_BI__c = :matrix.Product_Catalog_BI__c AND Channel_1_BI__c = :f2fChannelId]){
            remainingUnit = remainingUnit - m.Allocated_Units_1_BI__c;
        }
        
        availableUnit = totalUnit;
        if(remainingUnit < 0) remainingUnit = 0;
        
        list<channelTotalInfo> list_channelTotal = new list<channelTotalInfo>();
        for(Id cId : map_channelId_channelInfo.keySet()) {
            channelTotalInfo channelTotal = map_channelId_channelInfo.get(cId);
            
            if(map_chId_bab.get(cId) != NULL && map_chId_bab.get(cId).Budget_BI__c != NULL){
                channelTotal.totalUnits = map_chId_bab.get(cId).Budget_BI__c.intValue();
            }
            else{
                channelTotal.totalUnits = 0;
            }  
            //channelTotal.totalUnits = Integer.valueOf(totalUnit);
            
            //channelTotal.availableUnits = Integer.valueOf(map_id_channel.get(cId).Total_Budget_BI__c);
            //channelTotal.availableUnits = Integer.valueOf(availableUnit);
            channelTotal.availableUnits = channelTotal.totalUnits;
            
            channelTotal.channelName = map_id_channel.get(cId).Name;
            
            channelTotal.allocatedUnits = channelTotal.gain + channelTotal.build + channelTotal.defend + channelTotal.observe + channelTotal.maintain;
            channelTotal.remaining = channelTotal.availableUnits - channelTotal.allocatedUnits ;
            
            remainingUnit = channelTotal.totalUnits - (map_chId_usedBudget.get(cId) == NULL ? 0 : map_chId_usedBudget.get(cId));
             if(remainingUnit < 0) remainingUnit = 0;
             
            channelTotal.remainingUnits = Integer.valueOf(remainingUnit);
            
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
            totalChannelInfo.blank += channelTotal.blank;
            totalChannelInfo.remaining += channelTotal.remaining;
            totalChannelInfo.remainingUnits += channelTotal.remainingUnits;
            if(totalChannelInfo.totalUnits != 0 ) {
                totalChannelInfo.planned = decimal.valueOf(totalChannelInfo.allocatedUnits).divide(decimal.valueOf(totalChannelInfo.totalUnits), 5) * 100;
            }
        }
        return list_channelTotal;
    }

   /**
    * This method is to save the matrix cell details -- New of filter
    *
    @author  Peng Zhu
    @created 2013-06-18
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @return list of channels
    *
    @changelog
    * 2013-06-18 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */      
    public void saveChannelBudgetByFilter(){
        Savepoint sp = Database.setSavepoint();
        try{
            String f2fId = String.valueOf(getSelectedChannelId());
            
            map<String, map<String, Integer>> map_mcdId_chId_qty = new map<String, map<String, Integer>>();
           
            list<MatrixCellChannel> list_mcc = (list<MatrixCellChannel>) JSON.deserialize(jsonChannels, list<MatrixCellChannel>.class);
           
            for(MatrixCellChannel mcc : list_mcc){
                for(ClsMatrixCellDetailObj cmcdo : mcc.map_index_cmcdo.values()){
                    if(cmcdo.mcdId != null){
                        if(map_mcdId_chId_qty.get(cmcdo.mcdId) == NULL) map_mcdId_chId_qty.put(cmcdo.mcdId, new map<String, Integer>());
                         
                        map_mcdId_chId_qty.get(cmcdo.mcdId).put(mcc.channelId, cmcdo.qty);
                    }
                }
            }
            
            if(!map_mcdId_chId_qty.isEmpty()){
                map<String, String> map_type_field = new map<String, String>();
               
                //List<Matrix_Cell_Detail_BI__c> list_mcdb2Update = new List<Matrix_Cell_Detail_BI__c>();
                
                //Group cell details for saving by Batch
                Integer index = 0, counter = 0;
                map<Integer, list<Matrix_Cell_Detail_BI__c>> map_idx_mcds = new map<Integer, list<Matrix_Cell_Detail_BI__c>>();
                
                for(Matrix_Cell_Detail_BI__c mcdb : [SELECT Id, Channel_Type_BI__c, Channel_1_Quantity_BI__c, Channel_2_Quantity_BI__c, Channel_3_Quantity_BI__c, Channel_4_Quantity_BI__c, Channel_5_Quantity_BI__c, Quantity_BI__c FROM Matrix_Cell_Detail_BI__c WHERE Id IN :map_mcdId_chId_qty.keySet()]){
                    if(mcdb.Channel_Type_BI__c != NULL){
                        if(map_type_field.isEmpty()){
                            String[] cTypes = mcdb.Channel_Type_BI__c.split('\\;');
                             
                            for(Integer i=0; i<cTypes.size(); i++){
                                if(cTypes[i] != ''){
                                    if(i == 0){
                                        map_type_field.put(cTypes[i], 'Channel_1_Quantity_BI__c');
                                    }
                                    else if(i == 1){
                                        map_type_field.put(cTypes[i], 'Channel_2_Quantity_BI__c');
                                    }
                                    else if(i == 2){
                                        map_type_field.put(cTypes[i], 'Channel_3_Quantity_BI__c');
                                    }
                                    else if(i == 3){
                                        map_type_field.put(cTypes[i], 'Channel_4_Quantity_BI__c');
                                    }
                                    else if(i == 4){
                                        map_type_field.put(cTypes[i], 'Channel_5_Quantity_BI__c');
                                    }
                                }
                            }
                        }
                        
                        if(map_mcdId_chId_qty.containsKey(mcdb.Id)){
                            for(String chId : map_mcdId_chId_qty.get(mcdb.Id).keySet()){
                                if(map_type_field.containsKey(chId)){
                                    mcdb.put(map_type_field.get(chId), map_mcdId_chId_qty.get(mcdb.Id).get(chId));
                                    if(f2fId != NULL && chId == f2fId){
                                        mcdb.put('Quantity_BI__c', map_mcdId_chId_qty.get(mcdb.Id).get(chId));
                                    }
                                }
                            }
                        }
                        //list_mcdb2Update.add(mcdb);
                        
                        //Add in Batch
                        counter ++;
                        if(counter > 2000){//1000
                            counter = 1;
                            index++;
                        }
                        
                        if(map_idx_mcds.get(index) == null) 
                            map_idx_mcds.put(index, new list<Matrix_Cell_Detail_BI__c>());
                        
                        map_idx_mcds.get(index).add(mcdb);
                    }
                }
                
                
                //Parse channel budget for saving by batch
                 jsonMatrixCellDetails = JSON.serialize(map_idx_mcds); 
                /**
                if(!list_mcdb2Update.isEmpty()){
                    system.debug(':: list_mcdb2Update: ' + list_mcdb2Update.size() );
                    update list_mcdb2Update;
                }*/
                //Update Matrix
                //update matrix;
            }
        }
        catch(DmlException de){
            Database.rollback(sp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, de.getMessage()));
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        initFilterPicklist();
    }
    
    
    /**
    * This Remote Action method is used to update matrix cell details in batch
    *
    @author  Jefferson Escobar
    @created 15-Oct-2014
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @param   resultString
    *
    @return  String
    *
    @changelog
    * 15-Oct-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    * - Created
    */
    @RemoteAction
    public static String updtMatrixCellDetailsInBatch(String resultString){
        ClsResponse r = new ClsResponse();
        r.status = 'SUCCESS';
        r.message = '';
        
        try{
            List<Matrix_Cell_Detail_BI__c> list_mcd = (List<Matrix_Cell_Detail_BI__c>) JSON.deserialize(resultString, list<Matrix_Cell_Detail_BI__c>.class);
            if(list_mcd != null && !list_mcd.isEmpty()){
                //system.debug(':: updating cell details: ' + list_mcd.size());
                update list_mcd;
            }
        }
        catch(Exception e){
            r.status = 'ERROR';
            r.message = e.getMessage();
        }
        
        return JSON.serialize(r);
    }
    
    
   /**
    * Save all the changes on Matrix
    *
    @author  Jefferson Escobar
    @created 15-Oct-2014
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @return  String to id
    *
    @changelog
    * 15-Oct-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    * - Created
    */ 
    public Pagereference saveMatrix(){
        Savepoint sp = Database.setSavepoint();
        try{
            update matrix;
            initFilterPicklist();
        }catch(DmlException de){
            Database.rollback(sp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, de.getMessage()));
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        
        return new Pagereference ('/'+matrix.Id);
    }

   /**
    * This method is get the less-than sign
    *
    @author  Minghao Li
    @created 2013-03-04
    @version 1.0
    @since   26.0 (Force.com ApiVersion)
    *
    @return  String to id
    *
    @changelog
    * 2013-03-04 Minghao Li <minghao.li@itbconsult.com>
    * - Created
    */     
    public String getLt(){
        return '<';
    } 
    
   /**
    * This method is get the greater-than sign
    *
    @author  Minghao Li
    @created 2013-03-04
    @version 1.0
    @since   26.0 (Force.com ApiVersion)
    *
    @return  String to id
    *
    @changelog
    * 2013-03-04 Minghao Li <minghao.li@itbconsult.com>
    * - Created
    */   
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
    @return String to id
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
    

   /**
    * This method is used to generate matrix cell detail for new filter function
    *
    @author  Peng Zhu
    @created 2013-07-29
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @changelog
    * 2013-07-29 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */ 
    public void genAndSaveMatrixCellDetailNew(){
        Savepoint sp = Database.setSavepoint();
        try{
            list<ClsMatrixCellDetail> list_cmcd = (list<ClsMatrixCellDetail>)JSON.deserialize(jsonMatrixFilters, list<ClsMatrixCellDetail>.class);
            map<String, map<String, Integer>> map_mcId_matchKey_counter = (map<String, map<String, Integer>>)JSON.deserialize(matrixCellCounterMap, map<String, map<String, Integer>>.class);
                
            //TODO: get matrix cell
            if(matrix != null){// && !list_cmcd.isEmpty()
                
                set<string> set_channelName = new set<string>();
                
                List<Matrix_Cell_BI__c> set_mcId = new List<Matrix_Cell_BI__c>();
                Set<String> setCellIds = new Set<String>();
                for(Matrix_Cell_BI__c mc : [SELECT Id, Matrix_BI__c,Total_Customers_BI__c FROM Matrix_Cell_BI__c WHERE Matrix_BI__c = :matrix.Id]){
                    set_mcId.add(mc);
                    setCellIds.add(mc.Id);
                }
                //for now, just need "Face to Face"
                //set_channelName.clear();
                set_channelName.add('Face to Face');
                
                String matchKey = '';
                
                //Begin: added by Peng Zhu 2013-09-04
                Integer index = 0, counter = 0;
                map<Integer, list<Matrix_Cell_Detail_BI__c>> map_idx_mcds = new map<Integer, list<Matrix_Cell_Detail_BI__c>>();
                //End: added by Peng Zhu 2013-09-04
                //system.debug(':: Matrix Cell ' + list_cmcd.size());
                for(Matrix_Cell_BI__c mc : set_mcId){
                    for(ClsMatrixCellDetail cmcd : list_cmcd){
                        
                        matchKey = '';
                        Matrix_Cell_Detail_BI__c mcd = new Matrix_Cell_Detail_BI__c();
                        mcd.Matrix_Cell_BI__c = mc.Id;
                        
                        mcd.Channel_BI__c = 'Face to Face';
                        mcd.Matrix_Filter_Value_BI__c = cmcd.filterValue;
                        mcd.Channel_Type_BI__c = channelTypeCombination;
                        
                        matchKey = mcd.Matrix_Filter_Value_BI__c;
                        
                        mcd.Quantity_BI__c = 0;
                        
                        if(map_mcId_matchKey_counter.containsKey(mc.Id) && map_mcId_matchKey_counter.get(mc.Id).containsKey(matchKey)){
                            mcd.Account_Counter_BI__c = map_mcId_matchKey_counter.get(mc.Id).get(matchKey);
                        }
                        else if(mcd.Matrix_Filter_Value_BI__c == null || mcd.Matrix_Filter_Value_BI__c.trim().length() == 0) {
                            mcd.Account_Counter_BI__c = mc.Total_Customers_BI__c; // Set customer total if there are no filters
                        }else{
                            mcd.Account_Counter_BI__c = 0;
                        }
                        
                        //add by Peng Zhu 2013-06-25 for counter cycle datas
                        mcd.Cycle_Data_Counter_BI__c = cmcd.cycleDataCounter;
                        counter ++;
                        if(counter > 2000){//1000
                            counter = 1;
                            index++;
                        }
                        
                        if(map_idx_mcds.get(index) == null) map_idx_mcds.put(index, new list<Matrix_Cell_Detail_BI__c>());
                        
                        map_idx_mcds.get(index).add(mcd);
                        
                    }
                }
                
                jsonMatrixCellDetails = JSON.serialize(map_idx_mcds);
                jsonCellDetailIds = JSON.serialize(setCellIds);
                
                /**for(list<Matrix_Cell_Detail_BI__c> list_mcd2Del : [SELECT Id, Matrix_Cell_BI__c FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__c IN :set_mcId]){
                    if(list_mcd2Del != null && !list_mcd2Del.isEmpty()) delete list_mcd2Del;
                }*/

                //if(!map_idx_mcds.isEmpty()){
                    String filterCd = '', filterTemp = '';
                    Integer filterCombCounter = 0;
                    if(filterComb != null && filterComb != ''){
                        for(String str : filterComb.split(';')){
                            filterCombCounter ++;
                            if(map_cdApi_acApi.containsKey(str)){
                                filterTemp = map_cdApi_acApi.get(str);
                            }
                            else filterTemp = str;
                            if(filterCd == '') filterCd = filterTemp;
                            else filterCd += ';' + filterTemp;
                        }
                    }
                    
                    //system.debug(':: Filters: ' + filterCd + ' Filter API: ' + map_cdApi_acApi);
                    matrix.Matrix_Filter_BI__c = filterCd;
                    matrix.Matrix_Filter_Counter_BI__c = filterCombCounter;
                //}
                update matrix;

            }
        }
        catch(DmlException de){
            Database.rollback(sp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, de.getMessage()));
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }
    
    
    /**
    * This Remote Action method is used to delete matrix cell details in batch action
    *
    @author  Jefferson Escobar
    @created 13-Oct-2014
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @return  String
    *
    @changelog
    * 13-Oct-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    * - Created
    */  
    @RemoteAction
    public static String delCellDetailsInBatch(String jsonCellDetails){
        Savepoint sp = Database.setSavepoint();
        ClsResponse r = new ClsResponse();
        r.status = 'SUCCESS';
        
        try{
            List<String> setCellDetails = (List<String>) JSON.deserialize(jsonCellDetails, List<String>.class);
            List<Matrix_Cell_Detail_BI__c> cellDetails = [SELECT Id, Matrix_Cell_BI__c FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__c IN :setCellDetails limit 4000];
            
            if(cellDetails!=null && cellDetails.size()==4000){
                r.goToNext = 'goToNext';
            }
            
            //Delete matrix cell details            
            if(cellDetails!=null && !cellDetails.isEmpty()){
                delete cellDetails; 
            }
        }
        catch(Exception e){
            r.status = 'ERROR';
            r.message = e.getMessage();
            system.debug('[ERROR] ' + e.getMessage());
        }
        return JSON.serialize(r);
    }    


   /**
    * This Remote Action method is used to save matrix cell detail in batch
    *
    @author  Peng Zhu
    @created 2013-07-24
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @param   resultString
    *
    @return  String
    *
    @changelog
    * 2013-07-01 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */
    @remoteAction
    public static String saveMatrixCellDetailsInBatch(String resultString){
        ClsResponse r = new ClsResponse();
        r.status = 'SUCCESS';
        r.message = '';
        
        try{
            List<Matrix_Cell_Detail_BI__c> list_mcd = (List<Matrix_Cell_Detail_BI__c>) JSON.deserialize(resultString, list<Matrix_Cell_Detail_BI__c>.class);
            if(list_mcd != null && !list_mcd.isEmpty()){
                system.debug('**## Peng list_mcd size : ' + list_mcd.size());
                insert list_mcd;
            }
        }
        catch(Exception e){
            r.status = 'ERROR';
            r.message = e.getMessage();
        }
        
        return JSON.serialize(r);
    }

   /**
    * This Remote Action method is used to generate matrix cell detail partition and count the account numbers
    *
    @author  Peng Zhu
    @created 2013-07-24
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @return  String
    *
    @changelog
    * 2013-07-01 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */  
    @RemoteAction
    public static String generateMatrixCellDetailsNew(string filterString){
        ClsMatrixFilterNew cmf;
        try{
            cmf = (ClsMatrixFilterNew)JSON.deserialize(filterString, ClsMatrixFilterNew.class);
            
            
            if(cmf.matrixId != null){
                list<ClsMatrixCellDetail> list_cmcd = new list<ClsMatrixCellDetail>();
                if(cmf.filterStr != null && cmf.filterStr.trim() != ''){
                    string queryStr = 'SELECT Id , Matrix_Cell_BI__c ';
                        
                    list<String> list_cField = new list<String>();
                    
                    //Mapping filter field from Accout to Cycle Data    
                    for(String str : cmf.filterStr.split(';')){
                        if(str != null && (str = str.trim()) != ''){
                            list_cField.add(str);
                            queryStr += ', Account_BI__r.' + str + ' ';
                            //system.debug(':: Fiilter: ' + 'Account_BI__r.'+str);
                        }
                    }   
                    
                    if(cmf.cycleDataId != null && cmf.cycleDataId.trim() != ''){
                        queryStr += ' FROM Cycle_Data_BI__c WHERE Id > \'' + cmf.cycleDataId + '\' AND Matrix_BI__c = \'' + cmf.matrixId + '\' ';
                    }
                    else{
                        queryStr += ' FROM Cycle_Data_BI__c WHERE Matrix_BI__c = \'' + cmf.matrixId + '\' ';
                    }
                    
                    //Get limit of query by custom setting
                    Integer limitRecords = IMP_BI_Limit_Queries__c.getAll().get('New_Cell_Details') != null ? Integer.valueOf(IMP_BI_Limit_Queries__c.getAll().get('New_Cell_Details').Limit_BI__c) : 5000; 
                    queryStr += ' ORDER BY Id LIMIT ' + limitRecords;
                    //queryStr += ' ORDER BY Id';
                    
                    system.debug(':: Query Filters: ' + queryStr);
                    
                    map<String, ClsMatrixCellDetail> map_matchKey_cmcd;
                    map<String, map<String, Integer>> map_mcId_matchKey_counter;
                    
                    if(cmf.map_matchKey_cmcd != null){
                        map_matchKey_cmcd = cmf.map_matchKey_cmcd;
                    }
                    else{
                        map_matchKey_cmcd = new map<String, ClsMatrixCellDetail>();
                    }
                    
                    if(cmf.map_mcId_matchKey_counter != null){
                        map_mcId_matchKey_counter = cmf.map_mcId_matchKey_counter;
                    }
                    else{
                        map_mcId_matchKey_counter = new map<String, map<String, Integer>>();
                    }
                    
                    String matchKey = '';
                    String cycleDataId = '';
                    boolean isEnd = true;
                    String mcId;
                    String value = '';
                    
                    //Get field map from Account
                    Map<String, Schema.SObjectField> fieldMap= Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
                    
                    Integer iCycle=0;
                    for(Cycle_Data_BI__c cd : Database.query(queryStr)){
                        isEnd = false;
                        value = '';
                        ClsMatrixCellDetail cmcd = new ClsMatrixCellDetail();
                        
                        cycleDataId = cd.Id;
                        
                        mcId = cd.Matrix_Cell_BI__c;
                        if(!map_mcId_matchKey_counter.containsKey(mcId)) map_mcId_matchKey_counter.put(mcId, new map<String, Integer>());
                        
                        for(String str : list_cField){
                            Account acc = (Account) cd.getSObject('Account_BI__r');
                            //system.debug(':: Filter: ' + acc.get(str) + ' Type: ' + fieldMap.get(str).getDescribe().getType());
                            
                            String fieldType = String.valueOf(fieldMap.get(str).getDescribe().getType());
                            String fieldValue;
                            
                            //Lead check field values
                            if(fieldType.equalsIgnoreCase('BOOLEAN')){
                                if(acc.get(str) == true){
                                    fieldValue = 'yes';
                                }else{
                                    fieldValue = 'no';
                                }
                            }else{//Lead Text and Picklist field values
                                if(acc.get(str) == null || String.valueOf(acc.get(str)).trim().length() == 0){
                                    fieldValue = 'not available';
                                }else{
                                    fieldValue = String.valueOf(acc.get(str)).toLowerCase();
                                }
                            }
                            
                            //Get literal values and group by filter
                            if(value == '') 
                                value = fieldValue;
                            else{
                                value += ';' + fieldValue;
                            }
                        }
                        
                        cmcd.filterValue = value;
                        
                        matchKey = value;
                            
                        if(!map_mcId_matchKey_counter.get(mcId).containsKey(matchKey)){
                            map_mcId_matchKey_counter.get(mcId).put(matchKey, 1);
                        }
                        else{
                            map_mcId_matchKey_counter.get(mcId).put(matchKey, map_mcId_matchKey_counter.get(mcId).remove(matchKey) + 1);
                        }
                        
                        if(!map_matchKey_cmcd.containsKey(matchKey)){
                            cmcd.cycleDataCounter = 1;
                            map_matchKey_cmcd.put(matchKey, cmcd);
                        }
                        else{
                            cmcd.cycleDataCounter = map_matchKey_cmcd.remove(matchKey).cycleDataCounter + 1;
                            map_matchKey_cmcd.put(matchKey, cmcd);
                        }
                        iCycle++;
                    }
                    
                    //system.debug(':: Cycles >>> ' + iCycle + ' Query: ' +queryStr);
                    cmf.cycleDataId = cycleDataId;
                    cmf.isEnd = isEnd;
                    cmf.map_matchKey_cmcd = map_matchKey_cmcd;
                    cmf.map_mcId_matchKey_counter = map_mcId_matchKey_counter;
                    
                    if(isEnd){
                        list_cmcd.addAll(map_matchKey_cmcd.values());
                        cmf.list_cmcd = list_cmcd;
                        cmf.listCmcdSize = list_cmcd.size();
                        //system.debug(':: list_cmcd: ' + list_cmcd);
                    }
                }
                else{
                    cmf.isEnd = true;
                    ClsMatrixCellDetail cmcd = new ClsMatrixCellDetail();

                    cmcd.filterValue = '';
                    list_cmcd.add(cmcd);
                    cmf.list_cmcd = list_cmcd;
                    cmf.listCmcdSize = list_cmcd.size();
                    cmf.map_matchKey_cmcd = new map<String, ClsMatrixCellDetail>();
                    cmf.map_mcId_matchKey_counter = new map<String, map<String, Integer>>();
                }
            }
        }
        catch(Exception e){
        }
        return JSON.serialize(cmf);
    }

   /**
    * This method is used to get filter combination SelectOption
    *
    @author  Peng Zhu
    @created 2013-06-17
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @return  list_so  list<SelectOption>
    *
    @changelog
    * 2013-06-17 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */  
    public list<SelectOption> getFilterCombinationName (){
        list<SelectOption> list_so = new list<SelectOption>();
        list_so.add(new SelectOption('', '--Show All--'));
        
        if(map_index_combinationName != null && !map_index_combinationName.isEmpty()){
            for(Integer i : map_index_combinationName.keySet()){
                if(map_index_combinationName.get(i) != null) {
                    list_so.add(new SelectOption(String.valueOf(i), map_index_combinationName.get(i)));   
                }
             }
        }
        return list_so;
    }
    
   /**
    * This method is used to reload data after apply the fiter
    *
    @author  Peng Zhu
    @created 2013-06-18
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @return  void
    *
    @changelog
    * 2013-06-18 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */  
    public void reloadDataAfterApply(){
        filterIndex = '';
        initFilterPicklist();
        generateFilterCombinationName();
        buldJsonChannelsByFilter();
        totalChannelInfo = new channelTotalInfo('totalChannel');
        list_channelDetails = getChannelsDetails();     
    }
    //********************************* -=END public methods=- **************************************
    
    
    //********************************* -=BEGIN private methods=- ************************************
   /**
    * This method is used to initialize the required variables
    *
    @author  Peng Zhu
    @created 2013-06-17
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @changelog
    * 2013-06-17 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */  
    private void init(){
        emConfig = new ExtMatrixConfig();
        map_matrixCell = new map<Integer, list<Matrix_Cell_BI__c>>();
        
        isFinal = false;
        
        isUsedFilter = false;
        
        filterIndex = '';
        
        theLocale = UserInfo.getLocale();
        
        pageTitle = system.label.Matrix_Res_Page_Title_BI;
        sectionHeaderSubTitle = system.label.Matrix_Res_Sub_Title_BI;
        
        
        list_filterFields = new list<String>();
        map_index_combinationName = new map<Integer, String>();
        
        map_filterCombi_index = new map<String, Integer>();
        
        map_cnlId_index_cnlInfo = new map<Id, map<String, channelTotalInfo>>();
        
        map_mcId_matchKey_accNum = new map<String, map<String, Integer>>();
        
        //Begin: added by Peng Zhu 2013-07-30 for dynamic filters

        map_idx_filter = new map<Integer, list<SelectOption>>();
        map_idx_filterV = new map<Integer, String>();
        set_filterIdx = new set<Integer>();
        //End: added by Peng Zhu 2013-07-30 for dynamic filters
    }

   /**
    * This method is used to initialize the variables after all other required variables 
    *
    @author  Peng Zhu
    @created 2013-06-19
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @changelog
    * 2013-06-19 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */
    private void initAfterAll(){
        //Begin: added by Peng Zhu 2013-09-11
        ClsMatrixFilterCondition cmfc = new ClsMatrixFilterCondition();
        cmfc.mId = matrix.Id;
        cmfc.mFilter = matrix.Matrix_Filter_BI__c;
        cmfc.map_filterCombi_index = map_filterCombi_index;
        cmfc.isUsedFilter = isUsedFilter;
        //cmfc.map_mcId_cnlName_index_cmcdo = map_mcId_cnlName_index_cmcdo;
        
        json_MatrixFilterCondition = JSON.serialize(cmfc);
        //End: added by Peng Zhu 2013-09-11
        
        isLaunch = false;
        list_adptnSts = new list<String>();
        
        if(matrix.Lifecycle_Template_BI__c != null && matrix.Lifecycle_Template_BI__r.isLaunch_Phase_BI__c){
            isLaunch = true;
            
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
                
        initPageHeightAndWidth();
        
        sectionHeaderTitle = matrix.Name_BI__c;
        jsonMatrixFilters = Json.serialize(new list<ClsMatrixCellDetail>());
        jsonMatrixCellDetails = JSON.serialize(new map<Integer, list<Matrix_Cell_Detail_BI__c>>());
        
        matrixCellCounterMap = Json.serialize(new map<String, map<String, Integer>>());
        
                
        //report url
        matrixDrillDownReportUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        if(matrix.Cycle_BI__r.Country_Lkp_BI__r.Matrix_Drill_Down_Report_ID_BI__c != null && matrix.Cycle_BI__r.Country_Lkp_BI__r.Matrix_Drill_Down_Report_ID_BI__c.trim() != ''){
            matrixDrillDownReportUrl += '/' + matrix.Cycle_BI__r.Country_Lkp_BI__r.Matrix_Drill_Down_Report_ID_BI__c;
        }
        else if(IMP_BI_Default_Setting__c.getInstance('Country specific drill down report id') != null 
                    && IMP_BI_Default_Setting__c.getInstance('Country specific drill down report id').Id_Value_BI__c != null
                    && IMP_BI_Default_Setting__c.getInstance('Country specific drill down report id').Id_Value_BI__c.trim() != ''){
            //begin to assign value
            matrixDrillDownReportUrl += '/' + IMP_BI_Default_Setting__c.getInstance('Country specific drill down report id').Id_Value_BI__c;
        }
        
    }    

   /**
    * This method is used to get the channel and budget allocation information
    *
    @author  Peng Zhu
    @created 2013-11-08
    @version 1.0
    @since   28.0 (Force.com ApiVersion)
    *
    @return  row 
    *
    @changelog
    * 2013-11-08 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */     
    private void getChannelAndBudgetAllocationInfo(){
        //set to hold the Channel Id
        set<Id> set_cIds = new set<Id>();
        map<Id, Budget_Allocation_BI__c> map_id_bab = new map<Id, Budget_Allocation_BI__c>();
        map_chId_bab = new map<Id, Budget_Allocation_BI__c>();
        
        //if Cycle_BI__c and Product_Catalog_BI__c exist, query channel id from Budget_Allocation_BI__c
        if(matrix.Cycle_BI__c != NULL && matrix.Product_Catalog_BI__c != NULL){
            Boolean hasF2F = false;
            Integer channelSize = 4;
            for(Budget_Allocation_BI__c bab : [SELECT Id, Budget_BI__c, Channel_BI__c, Channel_BI__r.Name, Cycle_BI__c, Product_Catalog_BI__c FROM Budget_Allocation_BI__c WHERE Cycle_BI__c = :matrix.Cycle_BI__c AND Product_Catalog_BI__c = :matrix.Product_Catalog_BI__c AND Channel_BI__c != NULL AND Channel_BI__r.Name != NULL AND Channel_BI__r.Name != '' ORDER BY Channel_BI__r.Name]){
                if(!hasF2F && bab.Channel_BI__r.Name == 'Face to Face'){
                    channelSize = 5;
                    hasF2F = true;
                }
                
                if(set_cIds.size() < channelSize){
                    set_cIds.add(bab.Channel_BI__c);
                    map_id_bab.put(bab.Id, bab);
                    
                    map_chId_bab.put(bab.Channel_BI__c, bab);
                }
                
                if(hasF2F && set_cIds.size() == channelSize) break;
            }
        }
        
        //get channel info
        for(Channel_BI__c cb : [SELECT Name, Cost_Rate_BI__c, Total_Budget_BI__c, Unit_BI__c, Unit_Label_BI__c, Id FROM Channel_BI__c WHERE Id IN :set_cIds OR Name = 'Face to Face' ORDER BY NAME LIMIT 5]){
            map_id_channel.put(cb.Id, cb);
            channelTypeCombination += cb.Id + ';';  
        }
        if(channelTypeCombination.trim() != '') channelTypeCombination = channelTypeCombination.substring(0, channelTypeCombination.lastIndexOf(';'));
        //End: added by Peng Zhu 203-10-25    
    }
    
   /**
    * This method is used to get matrix row
    *
    @author  Peng Zhu
    @created 2013-11-08
    @version 1.0
    @since   28.0 (Force.com ApiVersion)
    *
    @return  row 
    *
    @changelog
    * 2013-11-08 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */  
    private Integer getMatrixRow(){
        Integer r = 10;
        
        if(matrix != NULL){
            if(matrix.Row_BI__c != NULL && matrix.Row_BI__c > 0){
                r = matrix.Row_BI__c.intValue();
            }
            else if(matrix.Potential_Levels_BI__c != NULL){
                r = Integer.valueOf(matrix.Potential_Levels_BI__c);     
            }
        }
        
        return r;
    }
    
   /**
    * This method is used to get matrix column
    *
    @author  Peng Zhu
    @created 2013-11-08
    @version 1.0
    @since   28.0 (Force.com ApiVersion)
    *
    @return  row 
    *
    @changelog
    * 2013-11-08 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */  
    private Integer getMatrixColumn(){
        Integer r = 10;
        
        if(matrix != NULL){
            if(matrix.Column_BI__c != NULL && matrix.Column_BI__c > 0){
                r = matrix.Column_BI__c.intValue();
            }
            else if(matrix.Intimacy_Levels_BI__c != NULL){
                r = Integer.valueOf(matrix.Intimacy_Levels_BI__c);     
            }
        }
        
        return r;
    }

   /**
    * This method is used to initialize the filter picklist
    *
    @author  Peng Zhu
    @created 2013-07-30
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @changelog
    * 2013-07-30 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */      
    private void initFilterPicklist(){
        //map to hold the field api name, key : lowerCase , value : normalCase
        /**map<String, String> map_nL_nU = new map<String, String>();
            
        for(String str : IMP_BI_ClsMatrixFilterConfig.SET_ACCOUNT_FIELD_FILTER){
            if(str != null && (str = str.trim()) != '' && !map_nL_nU.containsKey(str.toLowerCase())){
                map_nL_nU.put(str.toLowerCase(), str);
            }
        }*/
        //map<String, String>, key : account field api name, value : accout field label name
        //map_aName_aLabel = IMP_BI_ClsMatrixFilterConfig.getFieldMapping('Account', map_nL_nU.keySet());
        List<Matrix_Filter_BI__c> filterLabels = [Select Filter_Field_BI__c,Filter_Label_BI__c From Matrix_Filter_BI__c where Country_BI__c = :matrix.Cycle_BI__r.Country_Lkp_BI__c];
        
        if(filterLabels!=null&&!filterLabels.isEmpty()){
            map_aName_aLabel =new Map<String, String>();
            
            for(Matrix_Filter_BI__c mf : filterLabels){
                map_aName_aLabel.put(mf.Filter_Field_BI__c,mf.Filter_Label_BI__c);
            }
        }
        
        
          //IMP_BI_ClsMatrixFilterConfig.getFieldMapping('Account', map_nL_nU.keySet());
        
            
        list<SelectOption> list_so = new list<SelectOption>();      
        list_so.add(new SelectOption('', '--None--'));
        
        String temp_filter;
        Integer filter_size = 0;
        map_cdApi_acApi = new Map<String,String>();
        //get total available filter belong the country
        for(Matrix_Filter_BI__c m : [SELECT Id, Filter_Field_BI__c,Filter_Label_BI__c, Active_BI__c, Country_BI__c FROM  Matrix_Filter_BI__c WHERE Active_BI__c = true AND Filter_Field_BI__c != null AND Country_BI__c = :matrix.Cycle_BI__r.Country_Lkp_BI__c ORDER BY Filter_Field_BI__c]){
            temp_filter = m.Filter_Field_BI__c;
            
            //Map filter Country
            map_cdApi_acApi.put(m.Filter_Field_BI__c, m.Filter_Field_BI__c);
            
            if(map_aName_aLabel.containsKey(temp_filter)){
                list_so.add(new SelectOption(m.Filter_Field_BI__c, m.Filter_Label_BI__c));//map_aName_aLabel.get(temp_filter)
                filter_size ++;
            }
        }   
        
        map<Integer, String> map_idx_mFilter = new map<Integer, String>();
        Integer filterCounter = 0;
        
        //we use the account field as filter, but we store the cycle data field on the matrix filter field, here need change
        if(matrix.Matrix_Filter_BI__c != null && matrix.Matrix_Filter_BI__c != ''){
            for(String str : matrix.Matrix_Filter_BI__c.split(';')){
                if(map_cdApi_acApi.get(str) != NULL){
                    map_idx_mFilter.put(filterCounter, map_cdApi_acApi.get(str));
                }
                else{
                    map_idx_mFilter.put(filterCounter, str);
                } 
                filterCounter++;
            }
        }
        
        //this three map or set will be used in the page for display the filter picklist
        map_idx_filter.clear();
        map_idx_filterV.clear();
        set_filterIdx.clear();
        
        for(Integer i=0; i < filter_size; i++){
            set_filterIdx.add(i);
            map_idx_filter.put(i, list_so.clone());
            
            if(map_idx_mFilter.get(i) != NULL) map_idx_filterV.put(i ,map_idx_mFilter.get(i));
            else map_idx_filterV.put(i, '123');//why is 123?
        }
        //End: added by Peng Zhu 2013-07-30 for dynamic filters
    }
   /**
    * This method is used to generate all possible filter combination name
    *
    @author  Peng Zhu
    @created 2013-06-17
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @changelog
    * 2013-06-17 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */  
    private void generateFilterCombinationName(){
        String combinationName = '';
        String filterCombiName = '';
        Boolean hasInitFilterList = false;
        Integer counter = 0;
        
        list_filterFields.clear();
        map_index_combinationName.clear();
        map_filterCombi_index.clear();
        
        if(matrix != null && matrix.Id != null){
            map<Integer, String> map_idx_mFilter = new map<Integer, String>();
            Integer fCounter = 0;
            if(matrix.Matrix_Filter_BI__c != null && matrix.Matrix_Filter_BI__c != ''){
                for(String str : matrix.Matrix_Filter_BI__c.split(';')){
                    if(map_aName_aLabel.containsKey(str)){
                    
                        map_idx_mFilter.put(fCounter, map_aName_aLabel.get(str));
                    }
                    else{
                        map_idx_mFilter.put(fCounter, str);
                    }
                    fCounter ++;
                }
            }
            
            //this is used to get all possible combination filter name
            for(Matrix_Cell_Detail_BI__c mcdb : [SELECT Id, Matrix_Cell_BI__c, Matrix_Filter_Value_BI__c, Cycle_Data_Counter_BI__c, Channel_BI__c, Filter_Field_Value_1_BI__c, Filter_Field_Value_2_BI__c, Filter_Field_Value_3_BI__c, Matrix_Cell_BI__r.Matrix_BI__r.Filter_Field_1_BI__c,  Matrix_Cell_BI__r.Matrix_BI__r.Filter_Field_2_BI__c, Matrix_Cell_BI__r.Matrix_BI__r.Filter_Field_3_BI__c 
                                                    FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__r.Matrix_BI__c = :matrix.Id AND Matrix_Cell_BI__r.Row_BI__c = 1 AND Matrix_Cell_BI__r.Column_BI__c = 0]){
                combinationName = '';
                filterCombiName = '';
                //get filter fields 
                if(!hasInitFilterList && list_filterFields.isEmpty()){
                    if(mcdb.Matrix_Filter_Value_BI__c != null && mcdb.Matrix_Filter_Value_BI__c != ''){
                        isUsedFilter = true;
                    }
                    else{
                        list_filterFields.add('[0] ' + NO_FILTER_LABEL);
                        map_index_combinationName.put(0, list_filterFields.get(0));
                        map_filterCombi_index.put('[0] ' + NO_FILTER_LABEL, 0);
                        isUsedFilter = false;
                    }
                    
                    hasInitFilterList = true;
                }
                //get combination string
                if(isUsedFilter){
                    fCounter = 0;
                    
                    map<Integer, String> map_idx_mfValue = new map<Integer, String>();
                    
                    for(String str : mcdb.Matrix_Filter_Value_BI__c.split(';')){
                        map_idx_mfValue.put(fCounter, str);
                        fCounter ++;
                    }
                    
                    for(Integer i = 0; i < fCounter; i++){
                        if(i == 0){
                            combinationName = '[' + mcdb.Cycle_Data_Counter_BI__c + '] ' + map_idx_mFilter.get(i) + ' = "' + map_idx_mfValue.get(i) + '"';
                            filterCombiName = '[' + mcdb.Cycle_Data_Counter_BI__c + '] ' + map_idx_mfValue.get(i);
                        }
                        else{
                            combinationName += ' & ' + map_idx_mFilter.get(i) + ' = "' + map_idx_mfValue.get(i) + '"';
                            filterCombiName += '&' + map_idx_mfValue.get(i);
                        }
                    }
                    
                    system.debug(':: Combination: ' + combinationName + ' Counter: ' + counter  +  '  Filter: ' + filterCombiName);
                    map_index_combinationName.put(counter, combinationName);
                    
                    map_filterCombi_index.put(filterCombiName, counter);
                }
                counter++;
            }//End of for
        }
        if(map_index_combinationName != null){
            filterSize = map_index_combinationName.size();
        }else{
            filterSize = 0;
        }
    }

   /**
    * This method is used to generate the width and height for mantrix data div
    *
    @author  Peng Zhu
    @created 2013-06-18
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @changelog
    * 2013-06-18 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */     
    private void initPageHeightAndWidth(){
        //Integer r = 0, CELL_WIDTH = 86, CELL_HEIGHT = 34;
        Integer r = 0, CELL_WIDTH = 43, CELL_HEIGHT = 34;
        //init height -- matrix row or potential level
        r = this.getMatrixRow();
        
        realHeight = (r + 1) * (CELL_HEIGHT + 2) + 2;
        
        
        //init width
        r = this.getMatrixColumn();
        
        //realWidth = r * (CELL_WIDTH + 2 + 1) + (43 + 2) + 2;
        realWidth = r * (CELL_WIDTH + 2) + (43 + 2) + 2;
        
        if(realWidth > 900) maxWidth = realWidth;
        else maxWidth = 900;
    }
/*    
    @RemoteAction
    public static String buildJsonChannelByFilter(String matrixStr){
        ClsMatrixFilterCondition cmfc;
        try{
            cmfc = (ClsMatrixFilterCondition) JSON.deserialize(matrixStr, ClsMatrixFilterCondition.class);
            system.debug('##@@Peng buildJsonChannelByFilter cmfc : ' + cmfc);
            
            map<String, map<string, map<String, ClsMatrixCellDetailObj>>> map_mcId_cnlName_index_cmcdo = cmfc.map_mcId_cnlName_index_cmcdo;
            map<String, Integer> map_filterCombi_index = cmfc.map_filterCombi_index;
            String matrixId = cmfc.mId, mcId = cmfc.mcdId, mFilter = cmfc.mFilter;
            //
            String filterCombiName = '';
            Boolean isUsedFilter = cmfc.isUsedFilter;
            
            
            String queryStr = 'SELECT Id, Matrix_Cell_BI__c, Matrix_Filter_Value_BI__c, Account_Counter_BI__c, Cycle_Data_Counter_BI__c, Filter_Field_Value_1_BI__c, Filter_Field_Value_2_BI__c, Filter_Field_Value_3_BI__c, Channel_BI__c, Quantity_BI__c FROM Matrix_Cell_Detail_BI__c WHERE Id != NULL ';
            
            if(mcId != NULL && mcId.trim() != '') queryStr += ' AND Id > :mcId ';
            
            queryStr += ' AND Matrix_Cell_BI__r.Matrix_BI__c = :matrixId ORDER BY Id LIMIT 5000';
            
            Integer mcdbCounter = 0;
            for(Matrix_Cell_Detail_BI__c mcdb : Database.query(queryStr)){
                mcdbCounter++;
                mcId = mcdb.Id;
                
                ClsMatrixCellDetailObj cmcdo = new ClsMatrixCellDetailObj();
                cmcdo.mcdId = mcdb.Id;
                if(mcdb.Quantity_BI__c != null) cmcdo.qty = mcdb.Quantity_BI__c.intValue();
                if(mcdb.Cycle_Data_Counter_BI__c != null) cmcdo.cycleDateCounter = mcdb.Cycle_Data_Counter_BI__c.intValue();
                if(mcdb.Account_Counter_BI__c != null){
                    cmcdo.accountCounter = mcdb.Account_Counter_BI__c.intValue();
                    cmcdo.accountNum = mcdb.Account_Counter_BI__c.intValue();
                }
                
                
                filterCombiName = '[0] ' + NO_FILTER_LABEL;
                Integer counter = 0;
                if(isUsedFilter){//isUsedFilter
                    for(String str : mcdb.Matrix_Filter_Value_BI__c.split(';')){
                        if(counter == 0){
                            filterCombiName = '[' + mcdb.Cycle_Data_Counter_BI__c + '] ' + str;
                        }
                        else{
                            filterCombiName += '&' + str;
                        }
                        counter++;
                    }
                }
                else{
                    cmcdo.cycleDateCounter = 1;
                    cmcdo.accountNum = 1;
                }
                
                if(map_filterCombi_index.containsKey(filterCombiName) && mcdb.Channel_BI__c != null && mcdb.Channel_BI__c.trim() != ''){
                    if(!map_mcId_cnlName_index_cmcdo.containsKey(mcdb.Matrix_Cell_BI__c))  map_mcId_cnlName_index_cmcdo.put(mcdb.Matrix_Cell_BI__c, new map<string, map<String, ClsMatrixCellDetailObj>>());
                    
                    if(!map_mcId_cnlName_index_cmcdo.get(mcdb.Matrix_Cell_BI__c).containsKey(mcdb.Channel_BI__c)) map_mcId_cnlName_index_cmcdo.get(mcdb.Matrix_Cell_BI__c).put(mcdb.Channel_BI__c, new map<String, ClsMatrixCellDetailObj>());
                    
                    map_mcId_cnlName_index_cmcdo.get(mcdb.Matrix_Cell_BI__c).get(mcdb.Channel_BI__c).put(String.valueOf(map_filterCombi_index.get(filterCombiName)), cmcdo);
    
                }
            }
            if(mcdbCounter < 5000 && mcdbCounter > 0) cmfc.isEnd = false;
            else cmfc.isEnd = true;
            
            cmfc.mcdId = mcId;
            cmfc.map_mcId_cnlName_index_cmcdo = map_mcId_cnlName_index_cmcdo;
        }
        catch(Exception e){
            system.debug('##@@Peng buildJsonChannelByFilter Error!');
        }
        return JSON.serialize(cmfc);
    }
*/
   /**
    * This method is used to build channel cell json
    *
    @author  Peng Zhu
    @created 2013-06-18
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @changelog
    * 2013-06-18 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */    
    private void buldJsonChannelsByFilter(){
        
        map<Id, MatrixCellChannel> map_cnlId_mcc = new map<Id, MatrixCellChannel>();
        list<MatrixCellChannel> list_mcc = new list<MatrixCellChannel>();

        for(Channel_BI__c ch :map_id_channel.values()){
            MatrixCellChannel mcc = new MatrixCellChannel(ch.Id);
            map_cnlId_mcc.put(ch.Id, mcc);
        }
        
        //Begin: get --show all-- data
        map<String, map<String, Integer>> map_mcId_cnlName_qty = new map<String, map<String, Integer>>(); 
        
        String mcId, cnlName, qty;
        for(AggregateResult ar : [Select Sum(Quantity_BI__c) Quantity, Channel_BI__c Channel, Matrix_Cell_BI__c MatrixCell from Matrix_Cell_Detail_BI__c where Matrix_Cell_BI__r.Matrix_BI__c = :matrix.Id Group By Matrix_Cell_BI__c, Channel_BI__c]){
            if(ar.get('Channel') != null && String.valueOf(ar.get('Channel')).trim() != ''){
                mcId = String.valueOf(ar.get('MatrixCell')).trim();
                cnlName = String.valueOf(ar.get('Channel')).trim();
                if(ar.get('Quantity') != null && String.valueOf(ar.get('Quantity')) != null) qty = String.valueOf(ar.get('Quantity')).trim();
                else qty = '0';
                
                if(!map_mcId_cnlName_qty.containsKey(mcId)) map_mcId_cnlName_qty.put(mcId, new map<String, Integer>());
                
                if(!map_mcId_cnlName_qty.get(mcId).containsKey(cnlName)){
                    map_mcId_cnlName_qty.get(mcId).put(cnlName, Decimal.valueOf(qty).intValue());
                }
            }           
        }
        
        map<String, map<string, map<Integer, Integer>>> map_mcId_cnlName_index_qty = new map<String, map<string, map<Integer, Integer>>>();
        //map<String, map<string, map<Integer, ClsMatrixCellDetailObj>>> map_mcId_cnlName_index_cmcdo = new map<String, map<string, map<Integer, ClsMatrixCellDetailObj>>>();
        map<String, map<string, map<String, ClsMatrixCellDetailObj>>> map_mcId_cnlName_index_cmcdo = new map<String, map<string, map<String, ClsMatrixCellDetailObj>>>();
        
        map<String, map<string, map<String, ClsMatrixCellDetailObj>>> map_mcId_cnlId_index_cmcdo = new map<String, map<string, map<String, ClsMatrixCellDetailObj>>>();
        //map_filterCombi_index
        //
        String filterCombiName = '';
        for(Matrix_Cell_Detail_BI__c mcdb : [SELECT Id, Channel_Type_BI__c, Allocation_Summary_BI__c,Channel_1_Quantity_BI__c, Channel_2_Quantity_BI__c, Channel_3_Quantity_BI__c, Channel_4_Quantity_BI__c, 
                                                        Channel_5_Quantity_BI__c, Matrix_Cell_BI__c, Matrix_Filter_Value_BI__c, Account_Counter_BI__c, Cycle_Data_Counter_BI__c, Filter_Field_Value_1_BI__c, Filter_Field_Value_2_BI__c, Filter_Field_Value_3_BI__c, Channel_BI__c, Quantity_BI__c FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__r.Matrix_BI__c = :matrix.Id] ){
            //check channel type
            if(mcdb.Channel_Type_BI__c != NULL && mcdb.Channel_Type_BI__c.trim() != ''){
                String[] cTypes = mcdb.Channel_Type_BI__c.split('\\;');
                
                for(Integer i=0; i < cTypes.size(); i++){
                    
                    String cId = cTypes[i];
                    if(cId != NULL && cId.trim() != ''){
                        Integer quantity = 0;
                        if(i == 0 && mcdb.Channel_1_Quantity_BI__c != NULL) quantity = mcdb.Channel_1_Quantity_BI__c.intValue();
                        else if(i == 1 && mcdb.Channel_2_Quantity_BI__c != NULL) quantity = mcdb.Channel_2_Quantity_BI__c.intValue();
                        else if(i == 2 && mcdb.Channel_3_Quantity_BI__c != NULL) quantity = mcdb.Channel_3_Quantity_BI__c.intValue();
                        else if(i == 3 && mcdb.Channel_4_Quantity_BI__c != NULL) quantity = mcdb.Channel_4_Quantity_BI__c.intValue();
                        else if(i == 4 && mcdb.Channel_5_Quantity_BI__c != NULL) quantity = mcdb.Channel_5_Quantity_BI__c.intValue();
                        
                        
                        ClsMatrixCellDetailObj cmcdo = new ClsMatrixCellDetailObj();
                        cmcdo.mcdId = mcdb.Id;
                        cmcdo.qty = quantity;
                        if(mcdb.Cycle_Data_Counter_BI__c != null) cmcdo.cycleDateCounter = mcdb.Cycle_Data_Counter_BI__c.intValue();
                        
                        if(mcdb.Account_Counter_BI__c != null){
                            cmcdo.accountCounter = mcdb.Account_Counter_BI__c.intValue();
                            cmcdo.accountNum = mcdb.Account_Counter_BI__c.intValue();
                            cmcdo.allocatedUnits = mcdb.Allocation_Summary_BI__c.intValue();
                        }
                        
                        
                        filterCombiName = '[0] ' + NO_FILTER_LABEL;
                        Integer counter = 0;
                        
                        if(isUsedFilter){
                            for(String str : mcdb.Matrix_Filter_Value_BI__c.split(';')){
                                if(counter == 0){
                                    filterCombiName = '[' + mcdb.Cycle_Data_Counter_BI__c + '] ' + str;
                                }
                                else{
                                    filterCombiName += '&' + str;
                                }
                                counter++;
                            }
                        }
                        else{
                            cmcdo.cycleDateCounter = 1;
                            //cmcdo.accountNum = 1;
                        }
                        
                        if(map_filterCombi_index.containsKey(filterCombiName) && mcdb.Channel_BI__c != null && mcdb.Channel_BI__c.trim() != ''){
                            if(!map_mcId_cnlId_index_cmcdo.containsKey(mcdb.Matrix_Cell_BI__c))  map_mcId_cnlId_index_cmcdo.put(mcdb.Matrix_Cell_BI__c, new map<string, map<String, ClsMatrixCellDetailObj>>());
                            
                            if(!map_mcId_cnlId_index_cmcdo.get(mcdb.Matrix_Cell_BI__c).containsKey(cId)) map_mcId_cnlId_index_cmcdo.get(mcdb.Matrix_Cell_BI__c).put(cId, new map<String, ClsMatrixCellDetailObj>());
                            
                            map_mcId_cnlId_index_cmcdo.get(mcdb.Matrix_Cell_BI__c).get(cId).put(String.valueOf(map_filterCombi_index.get(filterCombiName)), cmcdo);
            
                        }
                    }
                    
                }
            }
        }
        
        //for each matrix cell
        for(Integer i : map_matrixCell.keySet()){
            for(Matrix_Cell_BI__c mc :map_matrixCell.get(i)){
                for(Id cId: map_cnlId_mcc.keySet()){
//++--------------  //Here maybe need to add a filter function 
                    //question: the relationship between matrix and channel
                    
                    MatrixCellChannel mcc = map_cnlId_mcc.get(cId).clone();
                    mcc.cellRow = String.valueOf(mc.Row_BI__c);
                    mcc.cellColumn = String.valueOf(mc.Column_BI__c);
                    mcc.segment = mc.Segment_BI__c;
                    
                    mcc.customers = '0';
                    mcc.allocatedUnits = '0';
                    mcc.intimacy = '0';
                    mcc.potential = '0';
                    
                    Integer customers = 0;
                    Integer allocatedUnits = 0;
                    
                    if(mc.Total_Customers_BI__c != null && mc.Total_Customers_BI__c > 0){
                        customers = mc.Total_Customers_BI__c.intValue();
                        mcc.customers = String.valueOf(customers);
                    }
                    
                    if(mc.Allocated_Units_Summary_BI__c != null && mc.Allocated_Units_Summary_BI__c > 0){
                        allocatedUnits = mc.Allocated_Units_Summary_BI__c.intValue();
                        mcc.allocatedUnits = String.valueOf(allocatedUnits);
                    }
                    
                    if(mc.Total_Intimacy_BI__c != null){
                        mcc.intimacy = String.valueOf(mc.Total_Intimacy_BI__c.intValue());
                    }
                    
                    if(mc.Total_Potential_BI__c != null){
                        mcc.potential = String.valueOf(mc.Total_Potential_BI__c.intValue());
                    }
                    
                    if(map_mcId_cnlName_qty.containsKey(mc.Id) && map_mcId_cnlName_qty.get(mc.Id).containsKey(map_id_channel.get(cId).Name)){
                        if(allocatedUnits > 0){
                            allocatedUnits = map_mcId_cnlName_qty.get(mc.Id).get(map_id_channel.get(cId).Name) / allocatedUnits;
                        }
                        mcc.channelBudget = String.valueOf(allocatedUnits);
                    }
                    
                    if(map_mcId_cnlId_index_cmcdo.containsKey(mc.Id) && map_mcId_cnlId_index_cmcdo.get(mc.Id).containsKey(cId)){
                        mcc.map_index_cmcdo = map_mcId_cnlId_index_cmcdo.get(mc.Id).get(cId);
                        
                        //for budget overview table on page
                        if(!map_channelId_channelInfo.containsKey(cId)) 
                            map_channelId_channelInfo.put(cId, new channelTotalInfo(cId));
                    }
                    list_mcc.add(mcc);
                }
            }
        }
        
        jsonChannels = (Json.serialize(list_mcc));  
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
        
        //Begin: added by Peng Zhu 2013-06-18 for filter function
        public String customers {get; set;}
        public String allocatedUnits {get; set;}
        public String intimacy {get; set;}
        public String potential {get; set;}
                
        public String segment {get; set;}
        
        public map<String, ClsMatrixCellDetailObj> map_index_cmcdo {get; set;}
        //End: added by Peng Zhu 2013-06-18 for filter function

        public MatrixCellChannel(String cId){
            channelId = cId;
            channelBudget = 'null';
            cellRow = 'null';
            cellColumn = 'null';
            
            //Begin: added by Peng Zhu 2013-06-18 for filter function
            customers = 'null';
            allocatedUnits = 'null';
            intimacy = 'null';
            potential = 'null';
            
            segment = 'null';
            
            map_index_cmcdo = new map<String, ClsMatrixCellDetailObj>();
            //End: added by Peng Zhu 2013-06-18 for filter function
        }
    }   

    public class channelTotalInfo{
        public String channelId {get; set;}
        public String channelName {get; set;}
        public Integer availableUnits {get; set;}
        public Integer allocatedUnits {get; set;}
        public Integer remainingUnits {get; set;}//Added by Peng Zhu 2013-06-28
        public Integer remaining {get;set;}
        public Integer gain {get; set;}
        public Integer build {get; set;}
        public Integer defend {get; set;}
        public Integer observe {get; set;} 
        public Integer maintain {get; set;}
        public Integer blank {get; set;}
        public decimal planned {get; set;}
        
        public Integer totalUnits {get; set;}
        
        public channelTotalInfo(String cId){
            channelId = cId;
            availableUnits = 0;
            allocatedUnits = 0;
            remainingUnits = 0;//Added by Peng Zhu 2013-06-28
            remaining = 0;
            gain = 0;
            build = 0;
            defend = 0;
            observe = 0;
            maintain = 0;
            blank = 0;
            
            totalUnits= 0;
        }
    }   
    
    
    //added by Peng Zhu 2013-06-05
    public class ClsMatrixFilter{
        public string matrixId;
        public string cycleDataId;
        public string filterField1;
        public string filterField2;
        public string filterField3;
        public boolean isEnd;
        public map<String, ClsMatrixCellDetail> map_matchKey_cmcd;
        public map<String, map<String, Integer>> map_mcId_matchKey_counter;
        public list<ClsMatrixCellDetail> list_cmcd;
        public Integer listCmcdSize;
        
        public ClsMatrixFilter(){
            isEnd = false;
            map_matchKey_cmcd = new map<String, ClsMatrixCellDetail>();
            list_cmcd = new list<ClsMatrixCellDetail>();
            map_mcId_matchKey_counter = new map<String, map<String, Integer>>();
            listCmcdSize = 0;
        }
    }
    
    //added by Peng Zhu 2013-07-24
    public class ClsMatrixFilterNew{
        public string matrixId;
        public string cycleDataId;
        public boolean isEnd;
        public map<String, ClsMatrixCellDetail> map_matchKey_cmcd;
        public map<String, map<String, Integer>> map_mcId_matchKey_counter;
        public list<ClsMatrixCellDetail> list_cmcd;
        public Integer listCmcdSize;
        
        public set<String> set_filter;
        public String filterStr;
        
        public ClsMatrixFilterNew(){
            isEnd = false;
            map_matchKey_cmcd = new map<String, ClsMatrixCellDetail>();
            list_cmcd = new list<ClsMatrixCellDetail>();
            map_mcId_matchKey_counter = new map<String, map<String, Integer>>();
            listCmcdSize = 0;
            
            set_filter = new set<String>();
        }
    }
    
    //added by Peng Zhu 2013-06-05
    public class ClsMatrixCellDetail{
        public string channel;
        public string filterField1;
        public string filterField2;
        public string filterField3;
        public integer cycleDataCounter;
        public string filterValue;
        
        public ClsMatrixCellDetail(){
            cycleDataCounter = 0;
        }
    }
    
    //added by Peng Zhu 2013-06-18
    public class ClsMatrixCellDetailObj{
        public Id mcdId {get; set;}
        public Integer qty {get; set;}
        public Integer cycleDateCounter {get; set;}
        public Integer accountCounter {get; set;}
        public Integer accountNum {get; set;}
        public Integer allocatedUnits {get;set;}
        
        public ClsMatrixCellDetailObj(){
            qty = 0; 
            cycleDateCounter= 0;
            accountCounter = 0;
            accountNum = 0;
            allocatedUnits=0;
        }
    }
    
    //added by Peng Zhu 2013-09-11
    public class ClsMatrixFilterCondition{
        public String mId;
        public String mFilter;
        public String mcdId;
        public Boolean isEnd;
        public Boolean isUsedFilter;
        public map<String, Integer> map_filterCombi_index;
        public map<String, map<string, map<String, ClsMatrixCellDetailObj>>> map_mcId_cnlName_index_cmcdo;
        
        public ClsMatrixFilterCondition(){
            isEnd = false;
            isUsedFilter = false;
            map_filterCombi_index = new map<String, Integer>();
            map_mcId_cnlName_index_cmcdo = new map<String, map<string, map<String, ClsMatrixCellDetailObj>>>();
        }
    }
    
    public class ClsResponse{
        public string status {get;set;} //SUCCESS or ERROR
        public string message {get;set;} //error message for ERROR
        public String goToNext {get;set;} //if the process is over
    }
    //********************************* -=END inner classes=- ****************************************  
}