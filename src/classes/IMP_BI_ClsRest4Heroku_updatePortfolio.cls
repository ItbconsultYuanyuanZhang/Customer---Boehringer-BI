@RestResource(urlMapping='/updatePortfolioData/v1/*')
global with sharing class IMP_BI_ClsRest4Heroku_updatePortfolio{
    
    @HttpGet
    global static Response doGet(){
        Response r = new Response();
        try{
            RestRequest req = RestContext.request;
            //RestResponse res = Restcontext.response;
            Id pId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            //TODO: get data
            for(Portfolio_BI__c p: [SELECT Id, Name, Number_of_FTEs_BI__c, Number_of_calls_per_day_BI__c, Number_of_days_in_the_field_BI__c, Numbers_of_details_per_call_BI__c, Version_BI__c, Offset_Field_Force_Simulation_Perc_BI__c FROM Portfolio_BI__c WHERE Id = :pId]){
                r.outputPF = p;
            }
            
            //TODO: get Strtegic product weight
            r.list_sbw = new list<Strategic_Brand_Weight_BI__c>();
            //r.list_sbw = [SELECT Id, Matrix_BI__c, Strategic_Weight_BI__c, First_detail_priority_BI__c FROM Strategic_Brand_Weight_BI__c WHERE Portfolio_BI__c = :pId]; 
            set<id> set_mId = new set<id>();
            for(Strategic_Brand_Weight_BI__c sbw : [SELECT Full_Coverage_BI__c, Id, Matrix_BI__c, Strategic_Weight_BI__c, First_detail_priority_BI__c FROM Strategic_Brand_Weight_BI__c WHERE Portfolio_BI__c = :pId]){
                if(sbw.Matrix_BI__c != null) set_mId.add(sbw.Matrix_BI__c);
                r.list_sbw.add(sbw);
            }
            //TODO: get matrix cell
            MatrixWarpper matrix = getMatrixCalculationData(set_mId);
            if(matrix.outputMC != null) r.outputMC = matrix.outputMC;
            else r.outputMC = new list<Matrix_Cell_BI__c>();
            if(matrix.outputMT != null)  r.outputMT = matrix.outputMT;
            else r.outputMT = new list<Matrix_BI__c>();
            if(matrix.outputMD != null)  r.outputMD = matrix.outputMD;
            else r.outputMD = new list<Matrix_Cell_Detail_BI__c>();
            
            //TODO: get orgId
            for(Organization org : [SELECT Id, Name FROM Organization]){
                r.orgId = org.Id;
            }
        }catch(Exception e){
            r.success = false;
            r.message = e.getMessage();
        }
        
        return r;
    }
    
    @HttpPost
    global static Response doPost(list<Target_Account_BI__c> targetAccount, list<Target_Detail_BI__c> targetDetail, list<Portfolio_Field_Force_Simulation_BI__c> fieldForce, Portfolio_BI__c portfolio){
        Response r = new Response();
        try {   
            System.debug('targetAccounttargetAccount::'+targetAccount);
            if(targetAccount != null) upsert targetAccount;
            if(targetDetail != null) upsert targetDetail;
            if(fieldForce != null) upsert fieldForce;
            if(portfolio != null) update portfolio;
        }
        catch(exception e) {    
            r.success = false;
            r.message = e.getMessage();
        }
        return r;
   }
   
    
    global class Request{
        Target_Account_BI__c inputTA;
        list<Target_Detail_BI__c> list_td;
    }
    
    global class Response{
        boolean success;
        string message;
        string orgId;
        Portfolio_BI__c outputPF;
        list<Strategic_Brand_Weight_BI__c> list_sbw;
        
        public list<Matrix_BI__c> outputMT;
        public list<Matrix_Cell_BI__c> outputMC;
        public list<Matrix_Cell_Detail_BI__c> outputMD;
        
        public Response(){
            success = true;
            message = '';
        }
    }
    
    global class MatrixWarpper{
        public list<Matrix_BI__c> outputMT;
        public list<Matrix_Cell_BI__c> outputMC;
        public list<Matrix_Cell_Detail_BI__c> outputMD;
    }
    
    
    private static MatrixWarpper getMatrixCalculationData(set<id> set_matrixId) {
        decimal DEFAULT_ROW = 10; 
        decimal DEFAULT_COL = 11; 
        
        MatrixWarpper r = new MatrixWarpper();
        
        map<Id, Matrix_BI__c> map_matrixIds_matrix = new map<Id, Matrix_BI__c>();
        
        //Peng Zhu 2013-10-14
        for(Matrix_BI__c m: [select External_ID_vod__c, Matrix_Filter_Counter_BI__c, Matrix_Filter_BI__c, Id, Filter_Field_1_BI__c, Filter_Field_2_BI__c, Filter_Field_3_BI__c, name, Cycle_BI__c,  Product_Catalog_BI__c, Row_BI__c, Column_BI__c, Dimension_1_Name_BI__c, Dimension_2_Name_BI__c, Specialization_BI__c, Product_Lifecyle_BI__c, CycleDataTotal_BI__c, CycleDataQuantity_BI__c, Status_BI__c from Matrix_BI__c where id in: set_matrixId ]) {
            //Cycle__r.Country_Lkp__r.name,
            
            if(m.Row_BI__c == null || m.Row_BI__c < 1) m.Row_BI__c = DEFAULT_ROW;
            if(m.Column_BI__c == null || m.Column_BI__c < 2) m.Column_BI__c = DEFAULT_COL;
            
            //r.outputMT = m;
            map_matrixIds_matrix.put(m.Id, m);
            
        }
        //if(r.outputMT != null) {
        if(!map_matrixIds_matrix.isEmpty()) {   
            r.outputMC = new list<Matrix_Cell_BI__c>();
            
            //map<decimal, set<decimal>> map_row_column = new map<decimal, set<decimal>>();
            map<Id, map<decimal, set<decimal>>> map_matrixId_row_column = new map<Id, map<decimal, set<decimal>>>();
            
            list<Matrix_Cell_BI__c> list_mc2D = new list<Matrix_Cell_BI__c>();
            list<Matrix_Cell_BI__c> list_mc2I = new list<Matrix_Cell_BI__c>();
            
            set<Id> set_cellIds = new set<Id>();
            
            for(Matrix_Cell_BI__c mc: [select Id, Channel_1_Budget_BI__c, Matrix_BI__c, name, Row_BI__c, Column_BI__c, Segment_BI__c, Segments_by_Scenario_BI__c, Strategic_Weight_BI__c, Total_Customers_BI__c, Total_Potential_BI__c, Total_Intimacy_BI__c from Matrix_Cell_BI__c where Matrix_BI__c in: map_matrixIds_matrix.keySet()]) {// =: mId
                Matrix_BI__c mTemp = map_matrixIds_matrix.get(mc.Matrix_BI__c);
                if(mc.Row_BI__c == null || mc.Column_BI__c == null || mc.Row_BI__c < 1 || mc.Row_BI__c > mTemp.Row_BI__c || mc.Column_BI__c < 0 || mc.Column_BI__c >= mTemp.Column_BI__c) {
                    list_mc2D.add(mc);
                }
                else if(map_matrixId_row_column.containsKey(mc.Matrix_BI__c) && map_matrixId_row_column.get(mc.Matrix_BI__c).containsKey(mc.Row_BI__c) && map_matrixId_row_column.get(mc.Matrix_BI__c).get(mc.Row_BI__c).contains(mc.Column_BI__c)) {
                    list_mc2D.add(mc);
                }
                else {
                    r.outputMC.add(mc);
                    set_cellIds.add(mc.Id);
                    
                    
                    if(!map_matrixId_row_column.containsKey(mc.Matrix_BI__c)){
                        map_matrixId_row_column.put(mc.Matrix_BI__c, new map<decimal, set<decimal>>());
                    }
                    
                    if(!map_matrixId_row_column.get(mc.Matrix_BI__c).containsKey(mc.Row_BI__c)) 
                        map_matrixId_row_column.get(mc.Matrix_BI__c).put(mc.Row_BI__c, new set<decimal>());
                        
                    if(!map_matrixId_row_column.get(mc.Matrix_BI__c).get(mc.Row_BI__c).contains(mc.Column_BI__c)) map_matrixId_row_column.get(mc.Matrix_BI__c).get(mc.Row_BI__c).add(mc.Column_BI__c);
                }
            }
            
            for(Matrix_BI__c matrix : map_matrixIds_matrix.values()){
                for(decimal row = 1; row <= matrix.Row_BI__c; row++) {
                    for(decimal col = 0; col < matrix.Column_BI__c - 1; col++) {
                        if(!map_matrixId_row_column.containsKey(matrix.Id)){
                            map_matrixId_row_column.put(matrix.Id, new map<decimal, set<decimal>>());
                        } 
                        
                        if(!map_matrixId_row_column.get(matrix.Id).containsKey(row) || !map_matrixId_row_column.get(matrix.Id).get(row).contains(col)) {
                            Matrix_Cell_BI__c mc = new Matrix_Cell_BI__c();
                            mc.Matrix_BI__c = matrix.Id;
                            mc.Row_BI__c = row;
                            mc.Column_BI__c = col;
                            list_mc2I.add(mc);
                            r.outputMC.add(mc);
                        }
                    }
                }
            }
                
            if(!list_mc2D.isEmpty()) delete list_mc2D;
            if(!list_mc2I.isEmpty()) insert list_mc2I;
            
            r.outputMT = new list<Matrix_BI__c>();
            r.outputMT.addAll(map_matrixIds_matrix.values());
            
            
            
            r.outputMD = new list<Matrix_Cell_Detail_BI__c>();
            for(Matrix_Cell_Detail_BI__c detail : [select Matrix_Filter_Value_BI__c, Id, Channel_BI__c, Filter_Field_Value_1_BI__c, Filter_Field_Value_2_BI__c, Filter_Field_Value_3_BI__c, Matrix_Cell_BI__c, Quantity_BI__c from Matrix_Cell_Detail_BI__c where Matrix_Cell_BI__c in: set_cellIds]){
                r.outputMD.add(detail);
            }
            
            
        }
        
        
        return r;
    }
    
}