/**
 * Batch job to update matrix lookup, matrix cell lookup, matrix number with given matrix id
 * 
 * @author Yuanyuan Zhang
 * @created 2014-12-23
 * @version 1.0
 * @since 32.0
 * 
 * @changelog
 * 2014-12-23 Yuanyuan Zhang <yuanyuan.zhang@itbconsult.com>
 * - Created   
 *
 */
 
 global class IMP_BI_ClsBatch_updateCycleData implements Database.Batchable<SObject>, Database.Stateful{
     global String query;
     global String filter; 
     global String currentMatrixId;
     global set<Id> set_cMatrixCellId;
     global String matrixCellId;
     global Integer newSenarioNumber;
     global Integer oldSenarioNumber;
     global Id firstScenMatrixId;
     
     global Database.QueryLocator start(Database.BatchableContext BC){ 
         if(query == null || query == '') {
            query = 'Select Id, Current_Scenario_BI__c, Current_Update_BI__c, Matrix_BI__c, Matrix_Cell_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c From Cycle_Data_BI__c ';
            if(filter != null) query += filter;
        }  
        String jobId = BC.getJobId();
        
        IMP_BI_Config_Matrix__c ibcm;
        for (IMP_BI_Config_Matrix__c cm : [SELECT Matrix_Id__c, Batch_Process_Id__c FROM IMP_BI_Config_Matrix__c WHERE Matrix_Id__c = :firstScenMatrixId]) {
            ibcm = cm;
            ibcm.Batch_Process_Id__c = jobId;
        }
        if (ibcm == null) {
            ibcm = new IMP_BI_Config_Matrix__c();
            ibcm.Matrix_Id__c = firstScenMatrixId;
            ibcm.Batch_Process_Id__c = jobId;
            ibcm.Name = jobId;
        }
        upsert ibcm;
        
        return Database.getQueryLocator(query);
     }
     
     global void execute(Database.BatchableContext BC, list<Cycle_Data_BI__c> list_cycleData){
        for (Cycle_Data_BI__c cdb : list_cycleData) {
            String cellFieldAPI = 'Matrix_Cell_' + newSenarioNumber + '_BI__c';
            if (matrixCellId != null) {//for copy matrix
                cdb.Matrix_Cell_BI__c = matrixCellId;
                if (newSenarioNumber != null) {
                    cdb.put(cellFieldAPI, matrixCellId);
                }
                
            } else {
                cdb.Matrix_Cell_BI__c = (String)cdb.get(cellFieldAPI);
            }
            
            cdb.Current_Scenario_BI__c = newSenarioNumber;
            cdb.Matrix_BI__c = currentMatrixId;
            
        }
        update list_cycleData;
     }
     
     global void finish(Database.BatchableContext BC){
        list<IMP_BI_Config_Matrix__c> list_ibcm = new list<IMP_BI_Config_Matrix__c>();
        for (IMP_BI_Config_Matrix__c cm : [SELECT Matrix_Id__c, Batch_Process_Id__c FROM IMP_BI_Config_Matrix__c WHERE Matrix_Id__c = :firstScenMatrixId]) {
            list_ibcm.add(cm);
        }
        if (list_ibcm.size() > 0) {
            delete list_ibcm;
        }
     }
 }