/**
 * Copy matrix and make current matrix as current and set other matrix under same scenario as non-current
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
public without sharing class IMP_BI_CtrlCopyScenario {
    
    public String matrixId {get; set;}
    
    public map<String,String> map_urlParams {get; set;}
    
    public boolean isValid {get; set;}
    
    private static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    
    private final String matrixApi = 'Matrix_BI__c';
    
    private final String matrixCellApi = 'Matrix_Cell_BI__c';
    
    private final String matrixCellDetailApi = 'Matrix_Cell_Detail_BI__c';
    
    public IMP_BI_CtrlCopyScenario () {
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
    
    public pageReference copyScenario() {
        if (!this.isValid) {
            return null;
        }
        
        Savepoint savep = database.setSavepoint();
        try {
        
            Set<Id> set_matrixIdsSameScen = new Set<Id>();
            List<Matrix_BI__c> list_matrix = new List<Matrix_BI__c>();
            String preCurrent = '';
            String scenNumberPre = '';
            String scenNumberCurrent = '0';
            Matrix_BI__c currentMatrix;
            
            String firstScenId = map_urlParams.containsKey('firstScen') ? map_urlParams.get('firstScen') : '';
            Integer maxScenarioNum = 0;
            if (String.isBlank(firstScenId)) {
                firstScenId = this.matrixId;
            }
            //get all matrix id for same scenario
            for (Matrix_BI__c mb : [Select Id, Current_BI__c, Scenario_BI__c From Matrix_BI__c WHERE First_Scenario_BI__c = :firstScenId OR Id = :firstScenId]) {
                if (mb.Scenario_BI__c.equalsIgnoreCase('5')) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'The maximum scenario number (5) is already reached. Operation is not allowed.'));
                    return null;
                }
                set_matrixIdsSameScen.add(mb.Id);
                if (mb.Current_BI__c) {
                    preCurrent = mb.Id;
                    scenNumberPre = mb.Scenario_BI__c;
                }
                mb.Current_BI__c = false;
                if (maxScenarioNum == 0 || maxScenarioNum < Integer.valueOf(mb.Scenario_BI__c)) {
                    maxScenarioNum = Integer.valueOf(mb.Scenario_BI__c);
                } 
                
                if (mb.Id == this.matrixId) {
                    currentMatrix = mb;
                    scenNumberPre = scenNumberPre == '' ? mb.Scenario_BI__c : scenNumberPre;//for case none of actual matrix is set current
                }
                
                list_matrix.add(mb);
            }
            
            scenNumberCurrent = maxScenarioNum + 1 + '';
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
            
            String matrixFields = GetQueryFields(this.matrixApi);
            String matrixCellDtailFields = GetQueryFields(matrixCellDetailApi);
            String matrixCellFields = GetQueryFields(matrixCellApi);
            
            String queryString = 'SELECT ' + matrixFields + ' FROM Matrix_BI__c WHERE Id = \'' + this.matrixId + '\'';
            for (Matrix_BI__c mb : database.query(queryString)) {
                currentMatrix = mb;
            }
            
            if (maxScenarioNum >= 5) {
                this.isValid = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'The maximun of scenario number is reached. Clone is not allowed.'));
                return null;
            }
            
            Matrix_BI__c currentMatrixClone = currentMatrix.clone(false, true);
            currentMatrixClone.First_Scenario_BI__c = firstScenId;
            currentMatrixClone.Scenario_BI__c =  String.valueOf(scenNumberCurrent);
            currentMatrixClone.Current_BI__c = true;
            insert currentMatrixClone;
            
            map<Id, Matrix_Cell_BI__c> map_oldMCId_cloneMC = new map<Id, Matrix_Cell_BI__c>();
            Set<Id> set_oldMCId = new Set<Id>();
            List<Matrix_Cell_Detail_BI__c> list_mcd = new List<Matrix_Cell_Detail_BI__c>();
            
            queryString = 'SELECT ' + matrixCellFields + ' FROM Matrix_Cell_BI__c WHERE Matrix_BI__c = \'' + this.matrixId + '\'';
            
            for (Matrix_Cell_BI__c mc : database.query(queryString)) {
                Matrix_Cell_BI__c mcClone = mc.clone(false, true);
                mcClone.Matrix_BI__c = currentMatrixClone.Id;
                map_oldMCId_cloneMC.put(mc.Id, mcClone);
            }
            
            if (!map_oldMCId_cloneMC.isEmpty()) {
                insert map_oldMCId_cloneMC.values();
                set_oldMCId = map_oldMCId_cloneMC.keySet();
            }
            //todo: if over 50000 records, then batch
            for (Matrix_Cell_Detail_BI__c mcd : database.query('SELECT ' + matrixCellDtailFields + ' FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__c IN :set_oldMCId')) {
                Matrix_Cell_Detail_BI__c mcdClone = mcd.clone(false, true);
                mcdClone.Matrix_Cell_BI__c = map_oldMCId_cloneMC.get(mcd.Matrix_Cell_BI__c).Id;
                list_mcd.add(mcdClone);
            }
            
            if (!list_mcd.isEmpty()) {
                insert list_mcd;
            }
            
            //if no actual matrix is set current
            if (String.isBlank(preCurrent)) {
                preCurrent = this.matrixId;
            }
            set<Id> set_matrixCellId = new set<Id>();
            for (Matrix_Cell_BI__c mcb : [select id from Matrix_Cell_BI__c where Matrix_BI__c = :preCurrent]) {
                set_matrixCellId.add(mcb.Id);
            }
            
            String cellFieldAPI = 'Matrix_Cell_' + currentMatrix.Scenario_BI__c + '_BI__c';
            Integer scenNumberPreInt = Integer.valueOf(scenNumberPre);
            Integer scenNumberCurrentInt = Integer.valueOf(scenNumberCurrent);
            String query = 'Select Id, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c From Cycle_Data_BI__c Where ' + cellFieldAPI + ' IN :set_matrixCellId limit 1';
            String newCellId = '';
            for (Cycle_Data_BI__c cdb : database.query(query)) {
                newCellId = map_oldMCId_cloneMC.get((String)cdb.get(cellFieldAPI)).Id;
            }
            
            IMP_BI_ClsBatch_updateCycleData cuc = new IMP_BI_ClsBatch_updateCycleData();
            
            cellFieldAPI = 'Matrix_Cell_' + scenNumberPreInt + '_BI__c';
            
            cuc.query = 'Select Id, Current_Scenario_BI__c, Current_Update_BI__c, Matrix_BI__c, Matrix_Cell_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c From Cycle_Data_BI__c Where ' + cellFieldAPI + ' IN :set_cMatrixCellId';// AND Current_Scenario_BI__c = :oldSenarioNumber
            cuc.currentMatrixId = currentMatrixClone.Id;
            cuc.set_cMatrixCellId = set_matrixCellId;
            cuc.newSenarioNumber = scenNumberCurrentInt;
            cuc.oldSenarioNumber = scenNumberPreInt;
            cuc.matrixCellId = newCellId;
            cuc.firstScenMatrixId = firstScenId;
            database.executeBatch(cuc);
            
            pageReference pr = new pageReference('/' + currentMatrixClone.Id);
            pr.setRedirect(true);
            return pr;
            /*
            if (!String.isBlank(preCurrent)) {
                set<Id> set_matrixCellId = new set<Id>();
                for (Matrix_Cell_BI__c mcb : [select id from Matrix_Cell_BI__c where Matrix_BI__c = :preCurrent]) {
                    set_matrixCellId.add(mcb.Id);
                }
                //scenNumberPre
                String cellFieldAPI = 'Matrix_Cell_' + scenNumberPre + '_BI__c';
                Integer scenNumberPreInt = Integer.valueOf(scenNumberPre);
                //system.debug('######cellFieldAPI: ' + cellFieldAPI + ' ######scenNumberPreInt: ' + scenNumberPreInt);
                String query = 'Select Id, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c From Cycle_Data_BI__c Where ' + cellFieldAPI + ' IN :set_cMatrixCellId AND Current_Scenario_BI__c = \'' + scenNumberPreInt + '\' limit 1';
                String newCellId = '';
                for (Cycle_Data_BI__c cdb : database.query(query)) {
                    newCellId = map_oldMCId_cloneMC.get((String)cdb.get(cellFieldAPI)).Id;
                }
                
                IMP_BI_ClsBatch_updateCycleData cuc = new IMP_BI_ClsBatch_updateCycleData();
                
                cuc.query = 'Select Id, Current_Scenario_BI__c, Current_Update_BI__c, Matrix_BI__c, Matrix_Cell_BI__c, Matrix_Cell_1_BI__c, Matrix_Cell_2_BI__c, Matrix_Cell_3_BI__c, Matrix_Cell_4_BI__c, Matrix_Cell_5_BI__c From Cycle_Data_BI__c Where ' + cellFieldAPI + ' IN :set_cMatrixCellId AND Current_Scenario_BI__c = :oldSenarioNumber';
                cuc.currentMatrixId = currentMatrixClone.Id;
                cuc.set_cMatrixCellId = set_matrixCellId;
                cuc.newSenarioNumber = Integer.valueOf(scenNumberCurrent);
                cuc.oldSenarioNumber = scenNumberPreInt;
                cuc.matrixCellId = newCellId;
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
        
    }
    
    private String GetQueryFields(String sobjectName) {
        Map<String, Schema.SObjectField> fieldsMap = gd.get(sobjectName).getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldDescribe;
        String queryFields = '';
        for (Schema.SObjectField field : fieldsMap.values()) {
            fieldDescribe = field.getDescribe();
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, fieldDescribe + ''));
            if (fieldDescribe.isAccessible() && fieldDescribe.isCreateable() )//&& fieldDescribe.isUpdateable()
            {
                if (queryFields.trim() == '')
                {
                    queryFields += String.escapeSingleQuotes(fieldDescribe.getName());
                }
                else
                {   
                    queryFields += ',' + String.escapeSingleQuotes(fieldDescribe.getName());
                }
            }
        }
        queryFields = String.escapeSingleQuotes(queryFields);
        return queryFields;
    }
}