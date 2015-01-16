public with sharing class IMP_BI_ClsRest4HerokuUtil {
	
	public static final decimal DEFAULT_ROW = 10; 
    public static final decimal DEFAULT_COL = 11; 
    
    public static IMP_BI_ClsRest4Heroku_updateMatrixData.Response getMatrixCalculationData(id mId) {
        IMP_BI_ClsRest4Heroku_updateMatrixData.Response r = new IMP_BI_ClsRest4Heroku_updateMatrixData.Response();
        r.crh = new IMP_BI_ClsRest4Heroku();
        //Peng Zhu 2013-10-14
        for(Matrix_BI__c m: [select Account_Matrix_BI__c, Account_Matrix_Split_BI__c, Scenario_BI__c, External_ID_vod__c, DPA_BI__c, isLaunch_Phase_BI__c, Id, Name, Cycle_BI__c, Product_Catalog_BI__c, Row_BI__c, Column_BI__c, Dimension_1_Name_BI__c, Dimension_2_Name_BI__c, Specialization_BI__c, Product_Lifecyle_BI__c, CycleDataTotal_BI__c, CycleDataQuantity_BI__c, Status_BI__c from Matrix_BI__c where id =: mId limit 10]) {
            //Cycle_BI__r.Country_Lkp__r.name, 
            
            if(m.Row_BI__c == null || m.Row_BI__c < 1) m.Row_BI__c = DEFAULT_ROW;
            if(m.Column_BI__c == null || m.Column_BI__c < 2) m.Column_BI__c = DEFAULT_COL;
            
            r.outputMT = m;
            r.crh.sf_id = m.id;
            //r.crh.country = m.Cycle_BI__r.Country_Lkp__r.name;
            r.crh.sf_name = m.name;
            string spec = '(';
            
            ////Peng Zhu 2013-10-14
            if(m.Specialization_BI__c != null) {
               for(string sp: m.Specialization_BI__c.split(';')) {
                    spec += '\'' + sp + '\',';
                }
            }
            
            if(spec.endsWith(',')) spec = spec.substring(0, spec.length() - 1);
            spec += ')';
            r.crh.parameters = '<parameters>' + 
                                '<specializations>' + spec + '</specializations>' + 
                                '<cycleid>' + m.Cycle_BI__c + '</cycleid>' + 
                                '<productid>' + m.Product_Catalog_BI__c + '</productid>' + 
                                '<matrixcols>' + string.valueOf(m.Row_BI__c.intValue()) + '</matrixcols>' + 
                                '<matrixrows>' + string.valueOf(m.Column_BI__c.intValue()) + '</matrixrows>' + 
                                '</parameters>';
        }
        if(r.outputMT != null) {
            r.outputMC = new list<Matrix_Cell_BI__c>();
            map<decimal, set<decimal>> map_row_column = new map<decimal, set<decimal>>();
            list<Matrix_Cell_BI__c> list_mc2D = new list<Matrix_Cell_BI__c>();
            list<Matrix_Cell_BI__c> list_mc2I = new list<Matrix_Cell_BI__c>();
            for(Matrix_Cell_BI__c mc: [select Id, Channel_1_Budget_BI__c, Matrix_BI__c, name, Row_BI__c, Column_BI__c, Segment_BI__c, Segments_by_Scenario_BI__c, Strategic_Weight_BI__c, Total_Customers_BI__c, Total_Potential_BI__c, Total_Intimacy_BI__c from Matrix_Cell_BI__c where Matrix_BI__c =: mId]) {
                if(mc.Row_BI__c == null || mc.Column_BI__c == null || mc.Row_BI__c < 1 || mc.Row_BI__c > r.outputMT.Row_BI__c || mc.Column_BI__c < 0 || mc.Column_BI__c >= r.outputMT.Column_BI__c) list_mc2D.add(mc);
                else if(map_row_column.containsKey(mc.Row_BI__c) && map_row_column.get(mc.Row_BI__c).contains(mc.Column_BI__c)) list_mc2D.add(mc);
                else {
                    r.outputMC.add(mc);
                    if(!map_row_column.containsKey(mc.Row_BI__c)) map_row_column.put(mc.Row_BI__c, new set<decimal>());
                    if(!map_row_column.get(mc.Row_BI__c).contains(mc.Column_BI__c)) map_row_column.get(mc.Row_BI__c).add(mc.Column_BI__c);
                }
            }
            
            for(decimal row = 1; row <= r.outputMT.Row_BI__c; row++) {
                for(decimal col = 0; col < r.outputMT.Column_BI__c - 1; col++) {
                    if(!map_row_column.containsKey(row) || !map_row_column.get(row).contains(col)) {
                        Matrix_Cell_BI__c mc = new Matrix_Cell_BI__c();
                        mc.Matrix_BI__c = mId;
                        mc.Row_BI__c = row;
                        mc.Column_BI__c = col;
                        
                        list_mc2I.add(mc);
                        r.outputMC.add(mc);
                    }
                }
            }
            
            if(!list_mc2D.isEmpty()) delete list_mc2D;
            if(!list_mc2I.isEmpty()) insert list_mc2I;
        }
        else {
            r.success = false;
            r.message = 'No matrix found';
        }
        
        return r;
    }
    
}