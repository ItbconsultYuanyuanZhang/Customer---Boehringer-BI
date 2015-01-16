/**
 * Validate matrix deletion and clear cycle data
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
trigger Matrix_BD_validateDelAndClearCycleData on Matrix_BI__c (before delete) {
    Set<Id> set_matrixId = new Set<Id>();
    Set<Integer> set_scenarioNumber = new Set<Integer>();
    set<Id> set_firstScenarioMatrixId = new Set<Id>();
    map<Id, Integer> map_matrixId_scenarioNumber = new map<Id, Integer>();
    map<Id, Matrix_BI__c> map_matrixId_matrix = new map<Id, Matrix_BI__c>();
    map<Id, Matrix_BI__c> map_firstScenMatrixId_matrix = new map<Id, Matrix_BI__c>();
    map<Id,Matrix_BI__c> map_firstId_matrix = new map<Id,Matrix_BI__c>();//use for prevent delete first scen matrix.
    
    for (Matrix_BI__c mb : trigger.old) {
        if (mb.Current_BI__c) {
            set_matrixId.add(mb.Id);
            Integer scenarioNum = Integer.valueOf(mb.Scenario_BI__c);
            set_scenarioNumber.add(scenarioNum);
            
            map_matrixId_matrix.put(mb.Id, mb);
            Id firstScenMatrixId = mb.First_Scenario_BI__c == null ? mb.Id : mb.First_Scenario_BI__c;
            set_firstScenarioMatrixId.add(firstScenMatrixId);
            map_firstScenMatrixId_matrix.put(firstScenMatrixId, mb);
        } else if (mb.First_Scenario_BI__c == null || mb.Scenario_BI__c == '1') {
            map_firstId_matrix.put(mb.Id, mb);
        }
    }
    Boolean hasError = false;
    if (!map_firstScenMatrixId_matrix.isEmpty()) {
        for (Matrix_BI__c mb : [select First_Scenario_BI__c from Matrix_BI__c where First_Scenario_BI__c IN :map_firstScenMatrixId_matrix.keySet()]) {
            map_firstId_matrix.get(mb.First_Scenario_BI__c).addError('You can not delete first matrix in a scenario, if there are other matrix existing in this scenario.');
            hasError = true;
        }
    }
    
    if (!set_matrixId.isEmpty() && !hasError) {
        map<Id, List<Integer>> map_scenMatrixId_list_scenNum = new map<Id, List<Integer>>();
        List<Matrix_BI__c> list_validMB = new List<Matrix_BI__c>();
        for (Matrix_BI__c mb : [SELECT Id, Scenario_BI__c, Current_BI__c, First_Scenario_BI__c FROM Matrix_BI__c WHERE Id IN :set_matrixId OR First_Scenario_BI__c IN :set_firstScenarioMatrixId]) {
            Id firstScenMatrixId = mb.First_Scenario_BI__c == null ? mb.Id : mb.First_Scenario_BI__c;
            if (!map_scenMatrixId_list_scenNum.containsKey(firstScenMatrixId)) {
                map_scenMatrixId_list_scenNum.put(firstScenMatrixId, new List<Integer>());
            }
            map_scenMatrixId_list_scenNum.get(firstScenMatrixId).add(Integer.valueOf(mb.Scenario_BI__c));
        }
        
        //check whether the mb is allowed to delete
        for (Id firstScenMatrixId : map_scenMatrixId_list_scenNum.keySet()) {
            List<Integer> list_scenNum = map_scenMatrixId_list_scenNum.get(firstScenMatrixId);
            list_scenNum.sort();
            if (map_firstScenMatrixId_matrix.containsKey(firstScenMatrixId)) {
                Matrix_BI__c mb = map_firstScenMatrixId_matrix.get(firstScenMatrixId);
                if(list_scenNum.get(list_scenNum.size() - 1) != Integer.valueOf(mb.Scenario_BI__c) && list_scenNum.size() != 1) {
                    Id firstScenMId = mb.First_Scenario_BI__c == null ? mb.Id : mb.First_Scenario_BI__c;
                    if(set_firstScenarioMatrixId.contains(firstScenMId)) {
                        set_firstScenarioMatrixId.remove(firstScenMId);
                    }
                    mb.addError('The current matrix can only be deleted if it is the last one in the set.');
                    hasError = true;
                } else {
                    Integer scenarioNum = Integer.valueOf(mb.Scenario_BI__c);
                    map_matrixId_scenarioNumber.put(mb.Id,scenarioNum);
                    list_validMB.add(mb);
                }
            }
        }
        //clear cycle data
        if (!hasError && list_validMB.size() > 0) {
            map<String, set<Id>> map_matriCellAPI_set_matrixCellId = new map<String, set<Id>>();
            for (Matrix_Cell_BI__c mcb : [SELECT Id, Matrix_BI__c FROM Matrix_Cell_BI__c WHERE Matrix_BI__c IN :list_validMB]) {
                Integer scenNum = map_matrixId_scenarioNumber.get(mcb.Matrix_BI__c);
                String mcAPI = 'Matrix_Cell_' + scenNum + '_BI__c';
                if (!map_matriCellAPI_set_matrixCellId.containsKey(mcAPI)) {
                    map_matriCellAPI_set_matrixCellId.put(mcAPI, new set<Id>());
                }
                map_matriCellAPI_set_matrixCellId.get(mcAPI).add(mcb.Id);
            }
            IMP_BI_ClsBatch_clearScenNumOfCycleData cuc = new IMP_BI_ClsBatch_clearScenNumOfCycleData();
            cuc.map_matriCellAPI_set_matrixCellId  = map_matriCellAPI_set_matrixCellId;
            cuc.set_firstScenMatrixId = set_firstScenarioMatrixId;
            database.executeBatch(cuc);
         }
    }
}