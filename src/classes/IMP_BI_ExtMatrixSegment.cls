/**
 *      extension class for matrix
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
public class IMP_BI_ExtMatrixSegment {
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    public Matrix_BI__c matrix {get; set;}
    public map<Integer, list<Matrix_Cell_BI__c>> map_matrixCell {get; set;}     
    
    public integer maxWidth {get; private set;}
    public integer realWidth {get; private set;}
    public integer realHeight {get; private set;}
    public boolean isMatrixOlRendered {get; private set;}
    
    public string pageTitle {get; private set;}
    public string sectionHeaderTitle {get; private set;}
    public string sectionHeaderSubTitle {get; private set;}
    
    public string matrixDrillDownReportUrl {get; private set;}
    public boolean isMarketShareShow {get; private set;}
    
    public ClsFinalResultConfig cfrc {get; private set;}
    public boolean isFinal {get; private set;}
    
    public String cycleDataId { get; set;}
    public String matrixCellIds { get; set;}
    public String matrixSelected { get; set;}
    public list<Schema.FieldSetMember> list_fsm { get; set;}
    public list<Cycle_Data_BI__c> list_CD { get; set;}
    //public String lastCDId { get; set; }
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    private final ApexPages.standardController controller;
    private map<Id, Channel_BI__c> map_channels = new map<Id, Channel_BI__c>(); 
    //Begin: added by Peng Zhu
    private static final Integer MATRIX_CELL_WIDTH = 58;
    private static final Integer MATRIX_CELL_HEIGHT = 48;
    private static final String MATRIX_STATUS_FINAL = 'Ready for NTL';
    
    private final String objectAPI = 'Cycle_Data_BI__c';
    private final String fieldSetName = 'Individual_Filter';
    
    public list<String> list_ptntlSts {get; private set;}
    public list<String> list_adptnSts {get; private set;}
    public boolean isLaunch {get; private set;}
    
    
    //End: added by Peng Zhu
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=-   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    /////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
    public IMP_BI_ExtMatrixSegment(ApexPages.standardController sc){
        this.controller = sc;
        
        this.matrixSelected = '';
        this.matrixCellIds = '';
        this.cycleDataId = '';
        //this.lastCDId = '';
        
        Id matrixId = sc.getId();
        map_matrixCell = new map<Integer, list<Matrix_Cell_BI__c>>();
        map_channels = IMP_BI_ClsMatrixUtil.getAllChannels();  //Product_Catalog_BI__r.Name_BI__c
        
        isFinal = false;
        
        matrix = [Select Cycle_BI__c, Country_BI__c, Intimacy_Levels_BI__c, Name, Name_BI__c, Potential_Levels_BI__c, Channel_1_BI__c, Channel_2_BI__c, Channel_3_BI__c, Channel_4_BI__c, Channel_5_BI__c, Channel_6_BI__c, Channel_7_BI__c, Channel_8_BI__c, Channel_9_BI__c, Channel_10_BI__c,  
                        Product_Catalog_BI__c, Product_Catalog_BI__r.Name, Id, Size_BI__c, Specialization_BI__c, Status_BI__c, Cycle_BI__r.Country_BI__c, Cycle_BI__r.Name, Cycle_BI__r.End_Date_BI__c, Cycle_BI__r.IsCurrent_BI__c, Cycle_BI__r.OwnerId, Cycle_BI__r.Start_Date_BI__c,
                        //Begin: added by Peng Zhu 2013-05-10 to add two new fields
                        Dimension_1_Name_BI__c, Dimension_2_Name_BI__c, Row_BI__c, Column_BI__c, Matrix_Description_BI__c, Cycle_BI__r.Country_Lkp_BI__r.Name,Cycle_BI__r.Country_Lkp_BI__r.Country_Code_BI__c,Potential_data_Label_BI__c,Adoption_Data_Label_BI__c,
                        Segment_1_Label_BI__c, Segment_2_Label_BI__c, Segment_3_Label_BI__c, Segment_4_Label_BI__c, Segment_5_Label_BI__c, Cycle_BI__r.Country_Lkp_BI__r.Matrix_Drill_Down_Report_ID_BI__c,
                        Lifecycle_Template_BI__c, Lifecycle_Template_BI__r.isLaunch_Phase_BI__c, Lifecycle_Template_BI__r.Adoption_Status_01_BI__c, Lifecycle_Template_BI__r.Adoption_Status_02_BI__c, 
                        Lifecycle_Template_BI__r.Adoption_Status_03_BI__c, Lifecycle_Template_BI__r.Adoption_Status_04_BI__c, Lifecycle_Template_BI__r.Adoption_Status_05_BI__c, 
                        Lifecycle_Template_BI__r.Potential_Status_01_BI__c, Lifecycle_Template_BI__r.Potential_Status_02_BI__c, Lifecycle_Template_BI__r.Potential_Status_03_BI__c, 
                        Lifecycle_Template_BI__r.Potential_Status_04_BI__c, Lifecycle_Template_BI__r.Potential_Status_05_BI__c,
                        //End: added by Peng Zhu
                        //Begin: added by Yuanyuan Zhang 2015-01-05
                        Current_BI__c, First_Scenario_BI__c, Scenario_BI__c, Account_Matrix_BI__c,
                        //End
                        Threshold_1_BI__c,Threshold_2_BI__c,Threshold_3_BI__c,Threshold_4_BI__c,Threshold_5_BI__c,Threshold_6_BI__c,Threshold_7_BI__c,Threshold_8_BI__c,Threshold_9_BI__c,Threshold_10_BI__c  FROM Matrix_BI__c WHERE Id =:matrixId][0];
        map_matrixCell = IMP_BI_ClsMatrixUtil.queryMatrixCellsByMatrixId(matrix.Id); 
        //Begin: added by Peng Zhu 2013-05-10 for initializing some variable
        if(matrix.Status_BI__c == MATRIX_STATUS_FINAL) isFinal = true;
                        
        cfrc = new ClsFinalResultConfig();
        if(matrix != null && matrix.Country_BI__c != null && matrix.Country_BI__c.trim() != ''){
                if(IMP_BI_Final_Result_Config__c.getInstance(matrix.Country_BI__c.trim()) != null && IMP_BI_Final_Result_Config__c.getInstance(matrix.Country_BI__c.trim()).Active_BI__c){
                        cfrc.phys = IMP_BI_Final_Result_Config__c.getInstance(matrix.Country_BI__c.trim()).Phys_BI__c;
                        cfrc.marketRx = IMP_BI_Final_Result_Config__c.getInstance(matrix.Country_BI__c.trim()).Market_Rx_BI__c;
                        cfrc.productRx = IMP_BI_Final_Result_Config__c.getInstance(matrix.Country_BI__c.trim()).Product_Rx_BI__c;
                        cfrc.marketShare = IMP_BI_Final_Result_Config__c.getInstance(matrix.Country_BI__c.trim()).Market_Share_BI__c;
                }
        }
        
        initPageWidthFields();  
        initPageHeightFields();
        initIsMatrixOlRendered();       
        
        list_ptntlSts = new list<String>();
        list_adptnSts = new list<String>();
        
        isLaunch = false;
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
        
        pageTitle = system.label.Matrix_Segm_Page_Title_BI;
        sectionHeaderTitle = matrix.Name_BI__c;
        sectionHeaderSubTitle = system.label.Matrix_Segm_Sub_Title_BI;
        
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
            //End: added by Peng Zhu
            
        this.list_fsm = new list<Schema.FieldSetMember>();
        String fieldSetAPIName = this.fieldSetName;
        for (Cycle_Data_Fieldset__c cdf : Cycle_Data_Fieldset__c.getAll().values()) {
            if (cdf.Country__c == matrix.Cycle_BI__r.Country_Lkp_BI__r.Country_Code_BI__c) {
                fieldSetAPIName = cdf.Field_Set__c;
                break;
            }
        }
        
        this.list_fsm = Schema.getGlobalDescribe().get(this.objectAPI).getDescribe().fieldSets.getMap().get(fieldSetAPIName).getFields();
        this.list_CD = new list<Cycle_Data_BI__c>();
    }
    /////////////////////////////////// -=END CONSTRUCTOR=- /////////////////////////////////////
    
    @remoteaction
    @readonly
    public static string calculateKPI (String matrixId) {
        map<id, List<kpiClass>> map_cellId_list_selAndDesel = new map<Id, List<kpiClass>>();
        set<String> set_cellId = new set<String>();
        for (Matrix_Cell_BI__c mc : [select id from Matrix_Cell_BI__c where Matrix_BI__c = :matrixId]) {
            set_cellId.add(mc.Id);
            
        }
        
        
        for (Cycle_Data_BI__c cd : [Select Id, Selected_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_1_BI__c, 
                                        Matrix_Cell_3_BI__c, Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c, Intimacy_BI__c,
                                        Potential_BI__c 
                                    From Cycle_Data_BI__c where Matrix_Cell_1_BI__c IN :set_cellId 
                                    OR Matrix_Cell_2_BI__c IN :set_cellId OR Matrix_Cell_3_BI__c IN :set_cellId OR Matrix_Cell_4_BI__c IN :set_cellId
                                    OR Matrix_Cell_5_BI__c IN :set_cellId]) {
            for (Integer i = 1 ; i < 6; i++) {
                object cellValue = cd.get('Matrix_Cell_' + String.valueOf(i) + '_BI__c');
                if (cellValue == null) {
                    continue;
                }
                Id cellId = (Id)cellValue;
                if (set_cellId.contains(cellId)) {
                    if (!map_cellId_list_selAndDesel.containsKey(cellId)) {
                        List<kpiClass> list_kpi = new List<kpiClass>();
                        kpiClass kc1 = new kpiClass();
                        kpiClass kc2 = new kpiClass();
                        list_kpi.add(kc1);
                        list_kpi.add(kc2);
                        map_cellId_list_selAndDesel.put(cellId, list_kpi);
                    }
                    kpiClass kc = cd.Selected_BI__c ? map_cellId_list_selAndDesel.get(cellId).get(0) : map_cellId_list_selAndDesel.get(cellId).get(1);
                    kc.noOfCust += 1;
                    kc.marketRx += cd.Potential_BI__c;
                    kc.prodRx += cd.Intimacy_BI__c;
                }
            }
        }
        
        /*
        public kpiClass () {
            this.noOfCust = 0;
            //this.perOfCust = 0;
            this.marketRx = 0; //Potential
            //this.perOfmarketRx = 0;
            this.prodRx = 0; //Intimacy
            //this.perOfprodRx = 0;
            //this.perOfmarketshare = 0;
            //this.average = 0;
        }
        */
        
        return JSON.serialize(map_cellId_list_selAndDesel);
    }
    
    public void saveCD () {
        if (this.list_CD.size() > 0) {
            update this.list_CD;
        }
    }
    
    public void getFilterCDData(){
        
        if (this.matrixCellIds != '') {
            this.list_CD.clear();
            set<String> set_cellId = new set<String>();
            set_cellId.addAll(this.matrixCellIds.split(','));
            String q = 'SELECT ';
            for(Schema.FieldSetMember f : this.list_fsm) {
                String s = f.getFieldPath();
                q += (s.toLowerCase() == 'id' ? '' : s+',');
            }
            
            q += ' id FROM Cycle_Data_BI__c WHERE (Matrix_Cell_1_BI__c IN :set_cellId ' + 
                             'OR Matrix_Cell_2_BI__c IN :set_cellId OR Matrix_Cell_3_BI__c IN :set_cellId OR Matrix_Cell_4_BI__c IN :set_cellId ' + 
                             'OR Matrix_Cell_5_BI__c IN :set_cellId) Order by Id Limit 500';
            /*
            q += ' id FROM Cycle_Data_BI__c Limit 500';    
            */             
            for (Cycle_Data_BI__c cd : database.query(q)) {
                this.list_CD.add(cd);
            }
        }
        
    }
    
    public void updateMatrixCellSelected () {
        if (this.matrixCellIds != '' && this.matrixSelected != '') {
            Boolean isSelected = this.matrixSelected == 'selected' ? true : false;
            set<String> set_cellId = new set<String>();
            set_cellId.addAll(this.matrixCellIds.split(','));
            
            List<Matrix_Cell_BI__c> list_mc2update = new List<Matrix_Cell_BI__c>();
            for (list<Matrix_Cell_BI__c> list_mc : map_matrixCell.values()) {
                for (Matrix_Cell_BI__c mc : list_mc) {
                    if (set_cellId.contains(mc.Id)) {
                        mc.Selected_BI__c = isSelected;
                        list_mc2update.add(mc);
                    }
                }
                
            }
            
            if (list_mc2update.size() > 0) {
                update list_mc2update;
            }
            if (!isSelected) {
                updateCycleData();
            }
        }
    }
    
    public void updateCycleData () {
        set<String> set_cellId = new set<String>();
        set_cellId.addAll(this.matrixCellIds.split(','));
        String queryString = 'SELECT Id, Selected_BI__c FROM Cycle_Data_BI__c WHERE (Matrix_Cell_1_BI__c IN :set_cellId ' + 
                             'OR Matrix_Cell_2_BI__c IN :set_cellId OR Matrix_Cell_3_BI__c IN :set_cellId OR Matrix_Cell_4_BI__c IN :set_cellId ' + 
                             'OR Matrix_Cell_5_BI__c IN :set_cellId) AND Id > :cycleDataId Order by Id Limit 2000';
                              
        List<Cycle_Data_BI__c> list_cdb = new List<Cycle_Data_BI__c>();
        for (Cycle_Data_BI__c cdb : database.query(queryString)) {
            cdb.Selected_BI__c = false;
            list_cdb.add(cdb);
        }
        
        if (list_cdb.size() > 0) {
            update list_cdb;
            if (list_cdb.size() == 2000) {
                this.cycleDataId = list_cdb.get(list_cdb.size() - 1).Id;
            } else {
                //this.matrixSelected = '';
                //this.matrixCellIds = '';
                this.cycleDataId = '';
            }
        }
    }    
        
        
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
    @return list of integer
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
    @return list of integer
    *
    @changelog
    * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
    * - Created
    */      
        public List<Integer> getColumns(){
                List<Integer> list_tmp = new list<Integer>();
                Integer r = 10;
                try{
                        if(matrix != null){
                                if(matrix.Intimacy_Levels_BI__c != null){
                                        r = Integer.valueOf(matrix.Intimacy_Levels_BI__c);              
                                }
                                else if(matrix.Size_BI__c != null){
                                        r = Integer.valueOf(matrix.Size_BI__c.substringAfter('x'));     
                                }
                        }
                }catch(Exception e){}
                
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
    @return list of channels
    *
    @changelog
    * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
    * - Created
    */              
    public List<Channel_BI__c> getChannels(){
                return map_channels.values();           
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
    @return list of channels
    *
    @changelog
    * 2013-05-21 Peng Zhu <peng.zhu@itbconsult.com>
    * - Modified for update field Matrix.Matrix_Description_BI__c
    *
    * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
    * - Created
    */              
    public pageReference saveMatrix(){
            system.debug('**@@Peng In save matrix : ' + matrix.Matrix_Description_BI__c);
            Savepoint sp = Database.setSavepoint(); 
            list<Matrix_Cell_BI__c> list_matrixCells2Update = new list<Matrix_Cell_BI__c>();
            try{
                    for(Integer i : map_matrixCell.keySet()) {
                            list_matrixCells2Update.addAll(map_matrixCell.get(i));
                    }
                    if(!list_matrixCells2Update.isEmpty()) update list_matrixCells2Update;
                    
                    //Begin: added by Peng Zhu 2013-05-21 for update field Matrix.Matrix_Description_BI__c
                    update matrix;
                    //End: added by Peng Zhu 2013-05-21
            }catch(DmlException ex){
                    ApexPages.addMessages(ex); 
                    Database.rollback(sp);
                    return null;    
            }       
            return new PageReference('/'+matrix.Id);        
    }
    
    /**
    * This method is to cancel the matrix cells modification
    *
    @author Bin Yu
    @created 2013-02-21
    @version 1.0
    @since 26.0 (Force.com ApiVersion)
    *
    *
    @return matrix page reference
    *
    @changelog
    * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
    * - Created
    */              
    public pageReference cancelMatrix(){
            return new PageReference('/'+matrix.Id);        
    }
                
    //********************************* -=END public methods=- **************************************
        
        
    //********************************* -=BEGIN private methods=- ************************************
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
            
            r = (r + 2)*MATRIX_CELL_WIDTH;
            realWidth = r;
            if(r > 746) maxWidth = r;
            else maxWidth = 746;
    }
        
    public void initPageHeightFields(){
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
        
        realHeight = (r + 2) * MATRIX_CELL_HEIGHT + 4;
    }
        
    private void initIsMatrixOlRendered(){
        if((matrix.Intimacy_Levels_BI__c != null || matrix.Size_BI__c != null || matrix.Column_BI__c != null) && (matrix.Potential_Levels_BI__c != null || matrix.Size_BI__c != null || matrix.Row_BI__c != null)){
                isMatrixOlRendered = true;
        }else{
                isMatrixOlRendered = false;
        }
    }
    //********************************* -= End private methods=- ************************************
    
    //********************************* -=BEGIN inner classes=- **************************************
    public class ClsFinalResultConfig{
            public boolean phys {get; private set;}
            public boolean marketRx {get; private set;}
            public boolean productRx {get; private set;}
            public boolean marketShare {get; private set;}
            
            public ClsFinalResultConfig(){
                    phys = true;
                    marketRx = true;
                    productRx = true;
                    marketShare = true;
            }
    }
    
    public class kpiClass {
        public Integer noOfCust { get; set; }
        //public decimal perOfCust { get; set; }
        public decimal marketRx { get; set; }
        //public decimal perOfmarketRx { get; set; }
        public decimal prodRx { get; set; }
        //public decimal perOfprodRx { get; set; }
        //public decimal perOfmarketshare { get; set; }
        //public decimal average { get; set; }
        
        public kpiClass () {
            this.noOfCust = 0;
            //this.perOfCust = 0;
            this.marketRx = 0;
            //this.perOfmarketRx = 0;
            this.prodRx = 0;
            //this.perOfprodRx = 0;
            //this.perOfmarketshare = 0;
            //this.average = 0;
        }
    }
    //********************************* -=END inner classes=- ****************************************      
}