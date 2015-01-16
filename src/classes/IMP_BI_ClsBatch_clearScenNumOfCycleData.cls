/**
 * Batch job to clear scenario number
 * 
 * @author Yuanyuan Zhang
 * @created 2014-12-24
 * @version 1.0
 * @since 32.0
 * 
 * @changelog
 * 2014-12-24 Yuanyuan Zhang <yuanyuan.zhang@itbconsult.com>
 * - Created   
 *
 */
 
 global class IMP_BI_ClsBatch_clearScenNumOfCycleData implements Database.Batchable<SObject>, Database.Stateful{
     global String query;
     global String filter; 
     global map<String, set<Id>> map_matriCellAPI_set_matrixCellId;
     global set<Id> set_firstScenMatrixId;
     global map<Id, Integer> map_matriceId_oldScenNum;
     global map<Id, Boolean> map_matriceId_isCurrent;
     global map<Id, Matrix_BI__c> map_matriceId_updatedMatrix;
     
     global Database.QueryLocator start(Database.BatchableContext BC){ 
        if(query == null || query == '') {
            
           String idStr = ' (temp) ';
           String idChain = '';
           for (String mId : set_firstScenMatrixId) {
               idChain = idChain == '' ? '\'' + mId + '\'' : idChain + ',' + '\'' + mId + '\'';
           }
           idStr = idStr.replace('temp', idChain); 
           query = 'select Id, Current_Scenario_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, ' + 
                   'Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c,Matrix_Cell_1_BI__r.Matrix_BI__c, Matrix_Cell_2_BI__r.Matrix_BI__c, ' +
                   'Matrix_Cell_3_BI__r.Matrix_BI__c,Matrix_Cell_4_BI__r.Matrix_BI__c,Matrix_Cell_5_BI__r.Matrix_BI__c FROM Cycle_Data_BI__c '; 
           query += 'where';
           for (Integer i = 1; i < 6; i++){
               
               
               query = query.endsWithIgnoreCase('where') ? query + ' Matrix_Cell_' + i + '_BI__c' + ' IN ' : query + ' OR Matrix_Cell_' + i + '_BI__c' + ' IN ';
               
               query += idStr + ' order by id';
           }
           if(filter != null) query += filter;
        }  
        String jobId = BC.getJobId();
        
        //user first scenario matrix id as identify for the whole scenario matrix
        //todo : if first scenario matrix is delete?
        List<IMP_BI_Config_Matrix__c> list_imp = new List<IMP_BI_Config_Matrix__c>();
        
        if (!set_firstScenMatrixId.isEmpty()) {
            for (String fsmId : set_firstScenMatrixId) {
                IMP_BI_Config_Matrix__c ibcm = new IMP_BI_Config_Matrix__c();
                ibcm.Matrix_Id__c = fsmId;
                ibcm.Batch_Process_Id__c = jobId;
                ibcm.Name = fsmId + jobId;
                list_imp.add(ibcm);
            }
            
        }
        upsert list_imp;
        
        return Database.getQueryLocator(query);
     }
     
     global void execute(Database.BatchableContext BC, list<Cycle_Data_BI__c> list_cycleData){
        for (Cycle_Data_BI__c cdb : list_cycleData) {
            cdb.Current_Scenario_BI__c = null;
            
            if (map_matriceId_updatedMatrix.containsKey(cdb.Matrix_Cell_1_BI__r.Matrix_BI__c)) {
                Boolean isCurrent = false;
                if (map_matriceId_isCurrent.containsKey(cdb.Matrix_Cell_1_BI__r.Matrix_BI__c)) {
                    isCurrent = true;
                }
                assignCD(map_matriceId_updatedMatrix.get(cdb.Matrix_Cell_1_BI__r.Matrix_BI__c).Scenario_BI__c, cdb.Matrix_Cell_1_BI__c, cdb,isCurrent);
            }
            
            if (map_matriceId_updatedMatrix.containsKey(cdb.Matrix_Cell_2_BI__r.Matrix_BI__c)) {
                Boolean isCurrent = false;
                if (map_matriceId_isCurrent.containsKey(cdb.Matrix_Cell_2_BI__r.Matrix_BI__c)) {
                    isCurrent = true;
                }
                assignCD(map_matriceId_updatedMatrix.get(cdb.Matrix_Cell_2_BI__r.Matrix_BI__c).Scenario_BI__c, cdb.Matrix_Cell_2_BI__c, cdb,isCurrent);
            }
            if (map_matriceId_updatedMatrix.containsKey(cdb.Matrix_Cell_3_BI__r.Matrix_BI__c)) {
                Boolean isCurrent = false;
                if (map_matriceId_isCurrent.containsKey(cdb.Matrix_Cell_3_BI__r.Matrix_BI__c)) {
                    isCurrent = true;
                }
                assignCD(map_matriceId_updatedMatrix.get(cdb.Matrix_Cell_3_BI__r.Matrix_BI__c).Scenario_BI__c, cdb.Matrix_Cell_3_BI__c, cdb,isCurrent);
            }
            if (map_matriceId_updatedMatrix.containsKey(cdb.Matrix_Cell_4_BI__r.Matrix_BI__c)) {
                Boolean isCurrent = false;
                if (map_matriceId_isCurrent.containsKey(cdb.Matrix_Cell_4_BI__r.Matrix_BI__c)) {
                    isCurrent = true;
                }
                assignCD(map_matriceId_updatedMatrix.get(cdb.Matrix_Cell_4_BI__r.Matrix_BI__c).Scenario_BI__c, cdb.Matrix_Cell_4_BI__c, cdb,isCurrent);
            }
            if (map_matriceId_updatedMatrix.containsKey(cdb.Matrix_Cell_5_BI__r.Matrix_BI__c)) {
                Boolean isCurrent = false;
                if (map_matriceId_isCurrent.containsKey(cdb.Matrix_Cell_5_BI__r.Matrix_BI__c)) {
                    isCurrent = true;
                }
                assignCD(map_matriceId_updatedMatrix.get(cdb.Matrix_Cell_5_BI__r.Matrix_BI__c).Scenario_BI__c, cdb.Matrix_Cell_5_BI__c, cdb,isCurrent);
            }
            
            list_cycleData.add(cdb);
        }
        update list_cycleData;
     }
     
     private void assignCD (String newScen, String value, Cycle_Data_BI__c cdb, boolean isCurrent) {
         String fieldAPI = 'Matrix_Cell_' + newScen + '_BI__c';
         cdb.put(fieldAPI, value);
         if (isCurrent) {
             cdb.Current_Scenario_BI__c = Integer.valueOf(value);
         }
     }
     
     global void finish(Database.BatchableContext BC){
        list<IMP_BI_Config_Matrix__c> list_ibcm = new list<IMP_BI_Config_Matrix__c>();
        for (IMP_BI_Config_Matrix__c cm : [SELECT Matrix_Id__c, Batch_Process_Id__c FROM IMP_BI_Config_Matrix__c WHERE Matrix_Id__c IN :set_firstScenMatrixId]) {
            list_ibcm.add(cm);
        }
        if (list_ibcm.size() > 0) {
            delete list_ibcm;
        }
     }
 }