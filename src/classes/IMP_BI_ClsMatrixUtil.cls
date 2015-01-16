/**
 *  Contains a set of methods used to calculate matrix data.
 *
 @author Bin Yu
 @created 2013-02-21
 @version 1.0
 @since 26.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-05-21 Peng Zhu <peng.zhu@itbconsult.com>
 * - Modified : method -- getAllChannels()
 *
 * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
 * - Created
 */
public with sharing class IMP_BI_ClsMatrixUtil {
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    public static map<Id, Integer> map_matriceId_oldScenNum;
    public static map<Id, Boolean> map_matriceId_isCurrent;
    public static map<Id, Matrix_BI__c> map_matriceId_updatedMatrix;
    public static set<Id> set_firstScenMatrixId;
    public static boolean runInAfter;
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //private final ApexPages.standardController controllerInfo;
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=-   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    /////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////

    /////////////////////////////////// -=END CONSTRUCTOR=- /////////////////////////////////////
    
    
    
    
    
    
    //********************************* -=BEGIN public methods=- ************************************
    /**
    * This method is to get all related cells by matrixId
    *
    @author Bin Yu
    @created 2013-02-21
    @version 1.0
    @since 26.0 (Force.com ApiVersion)
    *
    *
    @return map of Matrix_Cell_BI__c
    *
    @changelog
    * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
    * - Created
    */  
    public static map<Integer, list<Matrix_Cell_BI__c>> queryMatrixCellsByMatrixId(Id matrixId){
        map<Integer, list<Matrix_Cell_BI__c>> map_matrixCell = new map<Integer, List<Matrix_Cell_BI__c>>();
        for(Matrix_Cell_BI__c mc : [Select Id, Number_of_Doctors_BI__c, Name, Matrix_BI__c,Selected_BI__c, Row_BI__c, Column_BI__c, Channel_3_BI__c,Channel_3_BI__r.Name, Segment_BI__c, Channel_2_BI__c, Channel_2_BI__r.Name, Channel_1_BI__c, Channel_1_BI__r.Name, 
                                        Channel_3_Budget_BI__c, Channel_2_Budget_BI__c, Channel_1_Budget_BI__c, Total_Customers_BI__c,Allocated_Units_Summary_BI__c, Total_Intimacy_BI__c, Total_Market_Share_BI__c, Total_Potential_BI__c
                                From Matrix_Cell_BI__c 
                                where Matrix_BI__c =: matrixId and Row_BI__c != null and Column_BI__c != null order by Row_BI__c, Column_BI__c]){
            Integer r = Integer.valueOf(mc.Row_BI__c);              
            if(!map_matrixCell.containsKey(r)){
                map_matrixCell.put(r, new list<Matrix_Cell_BI__c>());  
            }
            //mc.Total_Customers__c = mc.Total_Customers__c.setScale(0);
            map_matrixCell.get(r).add(mc);
        }
        return map_matrixCell; 
    }   

    /**
    * This method is to get all related cells by matrixId
    *
    @author Bin Yu
    @created 2013-02-21
    @version 1.0
    @since 26.0 (Force.com ApiVersion)
    *
    *
    @return map of Matrix_Cell_BI__c
    *
    @changelog
    * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
    * - Created
    */  
    public static map<Integer, list<MatrixCellInfo>> queryMatrixCellsByMatrixId(Matrix_BI__c matrix, set<Id> set_all){
        map<Integer, list<MatrixCellInfo>> map_matrixCell = new map<Integer, List<MatrixCellInfo>>();
        Set<Id> set_cIds = new Set<Id>();       
        for(Integer i = 1; i<=10; i++){             
            String f = 'Channel_' + String.valueOf(i) + '_BI__c';
            if(matrix.get(f) != null){
                set_cIds.add((Id) matrix.get(f));
            }
        }   
        String otherCIds = '';
        if(set_all.size() > set_cIds.size()){           
            for(Id cId : set_all){
                if(!set_cIds.contains(cId)){
                    otherCIds += cId + ':null_';
                }
            }
            otherCIds = otherCIds.substring(0,otherCIds.length()-1);
        }           
                
        for(Matrix_Cell_BI__c mc : [Select Name, Number_of_Doctors_BI__c, Matrix_BI__c, Selected_BI__c, Row_BI__c, Column_BI__c,Segment_BI__c, Channel_3_Budget_BI__c, Channel_2_Budget_BI__c, Channel_1_Budget_BI__c, Total_Customers_BI__c,Allocated_Units_Summary_BI__c, Total_Intimacy_BI__c, Total_Market_Share_BI__c, Total_Potential_BI__c
                                From Matrix_Cell_BI__c 
                                where Matrix_BI__c = :matrix.Id and Row_BI__c != null and Column_BI__c != null order by Row_BI__c, Column_BI__c]){
            Integer r = Integer.valueOf(mc.Row_BI__c);              
            if(!map_matrixCell.containsKey(r)){
                map_matrixCell.put(r, new list<MatrixCellInfo>());  
            }
            MatrixCellInfo mcInfo = new MatrixCellInfo(mc, matrix);
            if(otherCIds.length() > 0){ 
                if(mcInfo.channels.length() > 0) mcInfo.channels += '_' + otherCIds;
                else mcInfo.channels += otherCIds;
            }
            map_matrixCell.get(r).add(mcInfo);
        }

        
        return map_matrixCell; 
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
    @return map of channels
    *
    @changelog
    * 2013-05-21 Peng Zhu <peng.zhu@itbconsult.com>
    * - Modified -- added a new field in query 'Unit_Label__c'
    *
    * 2013-02-21 Bin Yu <bin.yu@itbconsult.com>
    * - Created
    */      
    public static map<Id, Channel_BI__c> getAllChannels(){
        map<Id, Channel_BI__c> map_tmp = new map<Id, Channel_BI__c>([Select Unit_BI__c, Name, Id, Cost_Rate_BI__c, Total_Budget_BI__c, Unit_Label_BI__c From Channel_BI__c]);
        return map_tmp;     
    }
    //********************************* -=END public methods=- **************************************
    
    
    //********************************* -=BEGIN private methods=- ************************************
    
    //********************************* -=BEGIN inner classes=- **************************************
    public class MatrixCellInfo{
        public Matrix_Cell_BI__c cell {get;set;}
        public String channels {get; set;}
        
        public MatrixCellInfo(Matrix_Cell_BI__c mc, Matrix_BI__c matrix){
            cell = mc;
            channels = '';
            for(Integer i = 1; i<=10; i++){
                
                String f = 'Channel_' + String.valueOf(i) + '_BI__c';
                String cf = 'Channel_' + String.valueOf(i) + '_Budget_BI__c';
                if(matrix.get(f) != null){
                    if(mc.get(cf) != null) channels += matrix.get(f) + ':' + mc.get(cf) + '_';
                    else channels += matrix.get(f) + ':null_';
                }
                
            }
            if(channels.length() > 0) channels = channels.subString(0, channels.length() - 1);
        }
    }
    //********************************* -=END inner classes=- ****************************************  
}