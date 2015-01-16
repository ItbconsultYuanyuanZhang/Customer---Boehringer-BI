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
trigger IMP_BI_Matrix_BDAD_valiDelAndClearCD on Matrix_BI__c (before delete, after delete) {
    if (trigger.isBefore) {
        Boolean runInAfter = false;
        Set<Id> set_matrixId = new Set<Id>();
        set<Id> set_firstScenarioMatrixId = new Set<Id>();
        map<Id, Integer> map_matrixId_scenarioNumber = new map<Id, Integer>();
        map<Id, Matrix_BI__c> map_matrixId_matrix = new map<Id, Matrix_BI__c>();
        map<Id, Matrix_BI__c> map_firstScenMatrixId_matrix = new map<Id, Matrix_BI__c>();
        map<Id, Matrix_BI__c> map_firstScenMatrixId_currentMatrix = new map<Id, Matrix_BI__c>();
        map<Id,Matrix_BI__c> map_firstId_matrix = new map<Id,Matrix_BI__c>();//use for prevent delete first scen matrix.
        map<Id, List<Integer>> map_scenMatrixId_list_scenNum = new map<Id, List<Integer>>();//get all scenario number for each scenario incl. deleted matrix
        for (Matrix_BI__c mb : trigger.old) {
            //if (mb.Current_BI__c) {
                set_matrixId.add(mb.Id);
                Integer scenarioNum = Integer.valueOf(mb.Scenario_BI__c);
                
                map_matrixId_matrix.put(mb.Id, mb);
                Id firstScenMatrixId = mb.First_Scenario_BI__c == null ? mb.Id : mb.First_Scenario_BI__c;
                set_firstScenarioMatrixId.add(firstScenMatrixId);
                //get all scenario number for each scenario incl. deleted matrix
                if (!map_scenMatrixId_list_scenNum.containsKey(firstScenMatrixId)) {
                    map_scenMatrixId_list_scenNum.put(firstScenMatrixId, new List<Integer>());
                }
                map_scenMatrixId_list_scenNum.get(firstScenMatrixId).add(Integer.valueOf(mb.Scenario_BI__c));
                if (mb.Current_BI__c) {
                    map_firstScenMatrixId_currentMatrix.put(firstScenMatrixId, mb);
                }
                //get the matrix in a scenario with the minimum scenario number
                if (map_firstScenMatrixId_matrix.containsKey(firstScenMatrixId) && Integer.valueOf(map_firstScenMatrixId_matrix.get(firstScenMatrixId).Scenario_BI__c) < Integer.valueOf(mb.Scenario_BI__c)) {
                    continue;
                }
                map_firstScenMatrixId_matrix.put(firstScenMatrixId, mb);
                
                
            //} 
            //if matrix is first matrix, check whether it has other matrix in the same scenario
            if (mb.First_Scenario_BI__c == null || mb.Scenario_BI__c == '1') {
                map_firstId_matrix.put(mb.Id, mb);
            }
        }
        Boolean hasError = false;
        
        for (IMP_BI_Config_Matrix__c cm : [SELECT Matrix_Id__c, Batch_Process_Id__c FROM IMP_BI_Config_Matrix__c WHERE Matrix_Id__c IN :set_firstScenarioMatrixId]) {
            if (map_firstScenMatrixId_matrix.containsKey(cm.Matrix_Id__c)) {
                map_firstScenMatrixId_matrix.get(cm.Matrix_Id__c).addError('You can not delete the matrice, because a related batch is running. Please try again after the batch run.');
                hasError = true;
                break;
            }
        }
        
        if (!map_firstScenMatrixId_matrix.isEmpty()) {
            for (Matrix_BI__c mb : [select First_Scenario_BI__c from Matrix_BI__c where First_Scenario_BI__c IN :map_firstId_matrix.keySet()]) {
                map_firstId_matrix.get(mb.First_Scenario_BI__c).addError('You can not delete first matrice in a scenario, if there are other matrix existing in this scenario.');
                hasError = true;
                break;
            }
        }
        
        if (!set_matrixId.isEmpty() && !hasError) {
            
            map<Id, List<Matrix_BI__c>> map_scenMatrixId_list_matrix = new map<Id, List<Matrix_BI__c>>();
            map<Id, Integer> map_matriceId_oldScenNum = new map<Id, Integer>();
            map<Id, Boolean> map_matriceId_isCurrent = new map<Id, Boolean>();
            map<Id, Matrix_BI__c> map_matriceId_updatedMatrix = new map<Id, Matrix_BI__c>();
            
            //Get existing matrix order by scenario number
            for (Matrix_BI__c mb : [SELECT Id, Scenario_BI__c, Current_BI__c, First_Scenario_BI__c FROM Matrix_BI__c WHERE Id IN :set_matrixId OR First_Scenario_BI__c IN :set_firstScenarioMatrixId order by Scenario_BI__c]) {
                Id firstScenMatrixId = mb.First_Scenario_BI__c == null ? mb.Id : mb.First_Scenario_BI__c;
                if (map_firstScenMatrixId_matrix.containsKey(firstScenMatrixId)) {
                    if (!map_scenMatrixId_list_scenNum.containsKey(firstScenMatrixId)) {
                        map_scenMatrixId_list_scenNum.put(firstScenMatrixId, new List<Integer>());
                    }
                    map_scenMatrixId_list_scenNum.get(firstScenMatrixId).add(Integer.valueOf(mb.Scenario_BI__c));
                    
                    //get only matrix which's scenario number is bigger than deleted one(the one in deleted matrix of same scenario, which has the minimum of scenarion number). The matrice, which's scenario number is less than deleted one
                    Integer delMBScenNum = Integer.valueOf(map_firstScenMatrixId_matrix.get(firstScenMatrixId).Scenario_BI__c);
                    if (delMBScenNum < Integer.valueOf(mb.Scenario_BI__c) && !map_matrixId_matrix.containsKey(mb.Id)) {
                        if (!map_scenMatrixId_list_matrix.containsKey(firstScenMatrixId)) {
                            map_scenMatrixId_list_matrix.put(firstScenMatrixId, new List<Matrix_BI__c>());
                        }
                        map_scenMatrixId_list_matrix.get(firstScenMatrixId).add(mb);
                        map_matriceId_oldScenNum.put(mb.Id, Integer.valueOf(mb.Scenario_BI__c));
                    }
                    
                }
                
            }
            
            //check whether the mb is allowed to delete
            for (Id firstScenMatrixId : map_scenMatrixId_list_scenNum.keySet()) {
                List<Integer> list_scenNum = map_scenMatrixId_list_scenNum.get(firstScenMatrixId);
                list_scenNum.sort();
                if (map_firstScenMatrixId_currentMatrix.containsKey(firstScenMatrixId)) {
                    Matrix_BI__c mb = map_firstScenMatrixId_currentMatrix.get(firstScenMatrixId);
                    if(list_scenNum.get(list_scenNum.size() - 1) != Integer.valueOf(mb.Scenario_BI__c) && list_scenNum.size() != 1) {
                        mb.addError('The current matrix can only be deleted if it is the last one in the set.');
                        hasError = true;
                        break;
                    } 
                }
            }
            
            
            //Define new scenario number for existing matrix 
            if (!hasError) {
                for (String firstScenId : map_firstScenMatrixId_matrix.keySet()) {
                    Integer delMBScenNum = Integer.valueOf(map_firstScenMatrixId_matrix.get(firstScenId).Scenario_BI__c);
                    //Boolean isFirst = true;
                    if (map_scenMatrixId_list_matrix.containsKey(firstScenId)) {
                        for (Matrix_BI__c mb : map_scenMatrixId_list_matrix.get(firstScenId)) {
                            if (mb.Current_BI__c) {
                                map_matriceId_isCurrent.put(mb.Id, true);
                            }
                            /*
                            if (!isFirst) {
                                if (delMBScenNum == Integer.valueOf(mb.Scenario_BI__c)) {
                                    delMBScenNum++;
                                    continue;
                                }
                            }
                            isFirst = false;
                            */
                            mb.Scenario_BI__c = delMBScenNum + '';
                            map_matriceId_updatedMatrix.put(mb.Id, mb);
                            delMBScenNum ++;
                            
                        }
                    }
                }
                
            }
            
            //clear cycle data
            if (!hasError && !map_matriceId_updatedMatrix.isEmpty()) {
                runInAfter = true;
                IMP_BI_ClsMatrixUtil.map_matriceId_oldScenNum = map_matriceId_oldScenNum;
                IMP_BI_ClsMatrixUtil.map_matriceId_isCurrent = map_matriceId_isCurrent;
                IMP_BI_ClsMatrixUtil.map_matriceId_updatedMatrix = map_matriceId_updatedMatrix;
                IMP_BI_ClsMatrixUtil.set_firstScenMatrixId = set_firstScenarioMatrixId;
                
                /*
                IMP_BI_ClsBatch_clearScenNumOfCycleData cuc = new IMP_BI_ClsBatch_clearScenNumOfCycleData();
                cuc.map_matriCellAPI_set_matrixCellId  = map_matriCellAPI_set_matrixCellId;
                cuc.set_firstScenMatrixId = set_firstScenarioMatrixId;
                database.executeBatch(cuc);
                */
             }
             
        }
        IMP_BI_ClsMatrixUtil.runInAfter = runInAfter;
    }
    else if (trigger.isAfter && IMP_BI_ClsMatrixUtil.runInAfter) {
        if (!IMP_BI_ClsMatrixUtil.map_matriceId_updatedMatrix.isEmpty()) {
            update IMP_BI_ClsMatrixUtil.map_matriceId_updatedMatrix.values();
        }
        
        IMP_BI_ClsBatch_clearScenNumOfCycleData cuc = new IMP_BI_ClsBatch_clearScenNumOfCycleData();
        cuc.map_matriceId_updatedMatrix  = IMP_BI_ClsMatrixUtil.map_matriceId_updatedMatrix;
        cuc.map_matriceId_oldScenNum  = IMP_BI_ClsMatrixUtil.map_matriceId_oldScenNum;
        cuc.map_matriceId_isCurrent  = IMP_BI_ClsMatrixUtil.map_matriceId_isCurrent;
        cuc.set_firstScenMatrixId = IMP_BI_ClsMatrixUtil.set_firstScenMatrixId;
        database.executeBatch(cuc);
    }
}