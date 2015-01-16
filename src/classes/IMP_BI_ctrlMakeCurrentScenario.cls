/**
 * Make current matrix as current and set other matrix under same scenario as non-current
 * 
 * @author Yuanyuan Zhang
 * @created 2014-12-22
 * @version 1.0
 * @since 32.0
 * 
 * @changelog
 * 2014-12-22 Yuanyuan Zhang <yuanyuan.zhang@itbconsult.com>
 * - Created   
 *
 */
public without sharing class IMP_BI_ctrlMakeCurrentScenario {
    
    public String matrixId {get; set;}
    
    public map<String,String> map_urlParams {get; set;}
    
    public boolean isValid {get; set;}
    
    public IMP_BI_ctrlMakeCurrentScenario () {
        isValid = true;
        map_urlParams = new map<String,String>();
        map_urlParams = apexpages.currentPage().getParameters();
        if (map_urlParams.containsKey('matrixId')) {
            matrixId = map_urlParams.get('matrixId');
            
        } 
        
        if (String.isBlank(matrixId)) {
            this.isValid = false;
        }
        
        if (!this.isValid) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'No Matrix Id, please check'));
        }
    }
    
    public pageReference cancel () {
        pageReference pr = new pageReference('/' + this.matrixId);
        pr.setRedirect(true);
        return pr;
    }
    
    public pageReference makeCurrentScenario() {
        if (!this.isValid) {
            return null;
        }
        Savepoint savep = database.setSavepoint();
        try {
            Set<Id> set_matrixIdsSameScen = new Set<Id>();
            List<Matrix_BI__c> list_matrix = new List<Matrix_BI__c>();
            String preCurrent = '';
            String scenNumberPre = '';
            String scenNumberCurrent = '';
            
            String firstScenId = map_urlParams.containsKey('firstScen') ? map_urlParams.get('firstScen') : '';
            if (String.isBlank(firstScenId)) {
                firstScenId = this.matrixId;
            }
            //get all matrix id for same scenario
            for (Matrix_BI__c mb : [Select Id, Current_BI__c, Scenario_BI__c From Matrix_BI__c WHERE First_Scenario_BI__c = :firstScenId OR Id = :firstScenId]) {
                set_matrixIdsSameScen.add(mb.Id);
                if (mb.Current_BI__c) {
                    preCurrent = mb.Id;
                    scenNumberPre = mb.Scenario_BI__c;
                }
                mb.Current_BI__c = false;
                if (mb.Id == this.matrixId) {
                    mb.Current_BI__c = true;
                    scenNumberCurrent = mb.Scenario_BI__c;
                }
                list_matrix.add(mb);
            }
            //check whether one of matix has batch process
            Set<Id> set_batchId = new Set<Id>();
            for (IMP_BI_Config_Matrix__c cm : [SELECT Matrix_Id__c, Batch_Process_Id__c FROM IMP_BI_Config_Matrix__c WHERE Matrix_Id__c IN :set_matrixIdsSameScen]) {
                set_batchId.add(cm.Batch_Process_Id__c);
            }
            if (!set_batchId.isEmpty()) {
                
                for (AsyncApexJob aaj : [Select Id, Status FROM AsyncApexJob WHERE Id IN :set_batchId]) {
                    if(aaj.Status != 'Completed' && aaj.Status != 'Aborted' && aaj.Status != 'Failed') {
                        this.isValid = false;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'A batch job is already in processing for matrix of same scenario.Please waiting for the end.'));
                        return null;
                    }
                }
            }
            
            
            
            if (list_matrix.size() > 0) {
                update list_matrix;
            }
            //if no actual matrix is current.
            if (String.isBlank(preCurrent)) {
                preCurrent = this.matrixId;
            }
            set<Id> set_matrixCellId = new set<Id>();
            for (Matrix_Cell_BI__c mcb : [select id from Matrix_Cell_BI__c where Matrix_BI__c = :preCurrent]) {
                set_matrixCellId.add(mcb.Id);
            }
            IMP_BI_ClsBatch_updateCycleData cuc = new IMP_BI_ClsBatch_updateCycleData();
            String cellFieldAPI = preCurrent == this.matrixId ? 'Matrix_Cell_' + scenNumberCurrent + '_BI__c' : 'Matrix_Cell_' + scenNumberPre + '_BI__c';
            Integer scenNumberCurrentInt = ((scenNumberCurrent == NULL) ? 1 : Integer.valueOf(scenNumberCurrent));
            Integer scenNumberPreInt = String.isBlank(scenNumberPre) ? 0 : Integer.valueOf(scenNumberPre);
            cuc.query = 'Select Id, Current_Scenario_BI__c, Current_Update_BI__c, Matrix_BI__c, Matrix_Cell_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c From Cycle_Data_BI__c Where ' + cellFieldAPI + ' IN :set_cMatrixCellId';// AND Current_Scenario_BI__c = :oldSenarioNumber
            cuc.currentMatrixId = this.matrixId;
            cuc.set_cMatrixCellId = set_matrixCellId;
            cuc.newSenarioNumber = scenNumberCurrentInt;
            cuc.oldSenarioNumber = scenNumberPreInt;
            cuc.firstScenMatrixId = firstScenId;
            database.executeBatch(cuc);
            /*
            if (!String.isBlank(preCurrent)) {
                set<Id> set_matrixCellId = new set<Id>();
                for (Matrix_Cell_BI__c mcb : [select id from Matrix_Cell_BI__c where Matrix_BI__c = :preCurrent]) {
                    set_matrixCellId.add(mcb.Id);
                }
                IMP_BI_ClsBatch_updateCycleData cuc = new IMP_BI_ClsBatch_updateCycleData();
                String cellFieldAPI = 'Matrix_Cell_' + scenNumberPre + '_BI__c';
                Integer scenNumberCurrentInt = Integer.valueOf(scenNumberCurrent);
                Integer scenNumberPreInt = Integer.valueOf(scenNumberPre);
                cuc.query = 'Select Id, Current_Scenario_BI__c, Current_Update_BI__c, Matrix_BI__c, Matrix_Cell_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c From Cycle_Data_BI__c Where ' + cellFieldAPI + ' IN :set_cMatrixCellId AND Current_Scenario_BI__c = :oldSenarioNumber';
                cuc.currentMatrixId = this.matrixId;
                cuc.set_cMatrixCellId = set_matrixCellId;
                cuc.newSenarioNumber = scenNumberCurrentInt;
                cuc.oldSenarioNumber = scenNumberPreInt;
                cuc.firstScenMatrixId = firstScenId;
                database.executeBatch(cuc);
            }
            */
        } catch (Exception ex) {
            this.isValid = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            Database.rollback(savep);
            return null;
        } 
        pageReference pr = new pageReference('/' + this.matrixId);
        pr.setRedirect(true);
        return pr;
    }
}