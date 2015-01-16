/**
 *	Controller class for VF page IMP_BI_CtrlApplyFilter.page
 *
 @author  Peng Zhu
 @created 2015-01-09
 @version 1.0
 @since   30.0 (Force.com ApiVersion)
 *
 @changelog
 * 2015-01-09 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
public with sharing class IMP_BI_CtrlApplyFilter {
   
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	public string message {get; set;}
	public string msgType {get; set;}
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	/////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
   /**
	* The contsructor
	*
	@author  Peng Zhu
	@created 2015-01-09
	@version 1.0
	@since   30.0 (Force.com ApiVersion)
	*
	@changelog
	* 2015-01-09 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public IMP_BI_CtrlApplyFilter() {}
	/////////////////////////////////// -=END CONSTRUCTOR=- ///////////////////////////////////////
    
    
    //********************************* -=BEGIN public methods=- **********************************
    @RemoteAction
    public static String fetchMapOfAccountMatrix(String input) {
    	ClsResponse res = new ClsResponse();
    	
    	try {
	    	Id sourceId = getFullId(input);
    		
    		map<Id, list<Matrix_BI__c>> map_productId_listAccountMatrix = fetchMapOfAccountMatrixByCycleIdOrMatrixId(sourceId);
    		
	    	res.result = JSON.serialize(map_productId_listAccountMatrix);
    	}
    	catch(Exception e) {
    		res.status = 'ERROR';
    		res.result = e.getMessage();
    	}
    	
    	
    	return JSON.serialize(res);
    }   

    @ReadOnly
    @RemoteAction    
    public static String calculateForCycleDataByMatrixId(String inMatrixId, String inType) {
		ClsResponse res = new ClsResponse();
    	
    	try {
	    	Id sourceId = getFullId(inMatrixId); 
	    	String calcType = ('update'.equalsIgnoreCase(inType) ? 'update' : 'counter');
	    	
	    	map<String, Integer> map_type_amount = new map<String, Integer>();
	    	map_type_amount.put('Selected', 0);
	    	map_type_amount.put('NotSelected', 0);	
	    	map_type_amount.put('Counter', 0);    	
	    	

			if(sourceId != NULL && 'Matrix_BI__c'.equalsIgnoreCase(sourceId.getSObjectType().getDescribe().getName())) {
				set<Id> set_businessAccountId = new set<Id>();
 				set<Id> set_personAccountId = new set<Id>();
 				set<Id> set_personAccountIdInAffiliation = new set<Id>();
 				
 				String contryCode;
	    	
				for(Cycle_Data_BI__c cdb : [SELECT Account_BI__c, Cycle_BI__r.Country_Code_BI__c FROM Cycle_Data_BI__c WHERE Selected_BI__c = TRUE AND Account_BI__r.isPersonAccount = FALSE AND Matrix_Cell_1_BI__r.Matrix_BI__c = :sourceId]) {
	 				set_businessAccountId.add(cdb.Account_BI__c);
	 				
	 				if(contryCode == NULL) contryCode = cdb.Cycle_BI__r.Country_Code_BI__c;
	 			}
	 			
	 			for(Cycle_Data_BI__c cdb : [SELECT Account_BI__c FROM Cycle_Data_BI__c WHERE Account_BI__r.isPersonAccount = TRUE AND Matrix_Cell_1_BI__r.Matrix_BI__c = :sourceId]) {
	 				set_personAccountId.add(cdb.Account_BI__c);
	 			}
	 			
	 			set_personAccountIdInAffiliation = fetchRelatedPersonAccountIds(contryCode, set_personAccountId, set_businessAccountId);
	 			
	 			map_type_amount.put('Selected', set_personAccountIdInAffiliation.size());
	 			map_type_amount.put('NotSelected', (set_personAccountId.size() - set_personAccountIdInAffiliation.size()));	
	 			
	 			map<Id, Cycle_Data_BI__c> map_id_cd = new map<Id, Cycle_Data_BI__c>([SELECT Id FROM Cycle_Data_BI__c WHERE Matrix_Cell_1_BI__r.Matrix_BI__c = :sourceId AND Account_BI__r.isPersonAccount = true AND Selected_BI__c != false AND Account_BI__c Not IN :set_personAccountIdInAffiliation]);
	 			
	 			map_type_amount.put('Counter', map_id_cd.size());
	 			
	 			if(calcType == 'update') res.result = JSON.serialize(map_id_cd.keySet());
			}
			
			if(calcType == 'counter') res.result = JSON.serialize(map_type_amount);
	    	
    	}
    	catch(Exception e) {
    		res.status = 'ERROR';
    		res.result = e.getMessage();    		
    	}    
    	
    	return JSON.serialize(res);   	    	    	
	}

    /**
	 * Method to update the cycle data according the given cycle data ids string
	 *
	 @author  Peng Zhu
	 @created 2015-01-09
	 @version 1.0
	 @since   30.0 (Force.com ApiVersion)
	 *
	 @param   inCycleDataIds   given id of Cycle or Matrix
	 *
	 @return  grouped account matrix
	 *
	 @changelog
	 * 2015-01-09 Peng Zhu <peng.zhu@itbconsult.com>
	 * - Created
	 */    
    @RemoteAction
    public static String updateCycleData(String inCycleDataIds) {
    	ClsResponse res = new ClsResponse();
    	
    	try {
	    	set<Id> set_cycleDataId = (set<Id>) JSON.deserialize(inCycleDataIds, set<Id>.class);
    		
    		list<Cycle_Data_BI__c> list_cdb = new list<Cycle_Data_BI__c>();
    		for(Cycle_Data_BI__c cdb : [SELECT Id, Selected_BI__c FROM Cycle_Data_BI__c WHERE Id IN :set_cycleDataId AND Account_BI__r.isPersonAccount = true AND Selected_BI__c != false LIMIT 2000]) {
    			cdb.Selected_BI__c = false;
    			list_cdb.add(cdb);
    		}
    		
    		//if(!list_cdb.isEmpty()) update list_cdb;
    		
    		if(list_cdb.size() == 2000) res.result = 'Not Finished';
    		else res.result = 'Finished';
    	}
    	catch(Exception e) {
    		res.status = 'ERROR';
    		res.result = e.getMessage();
    	}
    
    	return JSON.serialize(res);  
    }
    
    public void showMessage(){
    	if(message != NULL && message.trim() != '') {
	    	if('CONFIRM'.equalsIgnoreCase(msgType)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message));
	    	}
	    	else if('FATAL'.equalsIgnoreCase(msgType)) {
	    	
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, message));
	    	}
	    	else if('INFO'.equalsIgnoreCase(msgType)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
	    	}
	    	else if('WARNING'.equalsIgnoreCase(msgType)) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
	    	}
	    	else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
	    	}
    	}
    }
    //********************************* -=END public methods=- ************************************
    
    
    //********************************* -=BEGIN private methods=- *********************************
    @TestVisible
    private static set<Id> fetchRelatedPersonAccountIds(String countryCode, set<Id> set_personAccountId, set<Id> set_businessAccountId) {
    	set<Id> set_relatedPersonAccountId = new set<Id>();
    	
    	Account_Relation_Setting_BI__c inst = getAccountRelationSettingByCountry(countryCode);
    	
    	try {
	    	if(inst != NULL && String.isNotBlank(inst.Object__c) && String.isNotBlank(inst.Person_Account_Field_BI__c) && String.isNotBlank(inst.Business_Account_Field_BI__c)) {
				
				String query = 'SELECT ' + inst.Person_Account_Field_BI__c + ' FROM ' + inst.Object__c + ' WHERE ' + inst.Person_Account_Field_BI__c + ' IN :set_personAccountId AND ' + inst.Business_Account_Field_BI__c + ' IN :set_businessAccountId';
	
	 			for(sObject sobj : Database.query(query)) {
	 				Id paId = getFullId(String.valueOf(sobj.get(inst.Person_Account_Field_BI__c)));
	 				set_relatedPersonAccountId.add(paId);
	 			}
	    		
	    	}
    	}
    	catch(Exception e) {}
    	
    	return set_relatedPersonAccountId;
    }
    
    /**
	 * Method to fetch the all the account matrix related to the given id and group them by product
	 *
	 @author  Peng Zhu
	 @created 2015-01-09
	 @version 1.0
	 @since   30.0 (Force.com ApiVersion)
	 *
	 @param   sourceId   given id of Cycle or Matrix
	 *
	 @return  grouped account matrix
	 *
	 @changelog
	 * 2015-01-09 Peng Zhu <peng.zhu@itbconsult.com>
	 * - Created
	 */  
    @TestVisible
    private static map<Id, list<Matrix_BI__c>> fetchMapOfAccountMatrixByCycleIdOrMatrixId(Id sourceId) {
    	map<Id, list<Matrix_BI__c>> map_productId_listAccountMatrix = new map<Id, list<Matrix_BI__c>>();
    	
    	if(isValidSourceId(sourceId)) {
    		String sourceObjApiName = sourceId.getSObjectType().getDescribe().getName();
    		String query = 'SELECT Id, Name, Cycle_BI__c, Product_Catalog_BI__c, Product_Catalog_BI__r.Name FROM Matrix_BI__c WHERE Account_Matrix_BI__c = TRUE AND IsDeleted = FALSE AND First_Scenario_BI__c = NULL AND Scenario_BI__c = \'1\' AND Status_BI__c != \'Draft\' ';
    		
    		if('Cycle_BI__c'.equalsIgnoreCase(sourceObjApiName)) {
    			query += ' AND Cycle_BI__c = \'' + sourceId + '\' ORDER BY Product_Catalog_BI__c ';
    		}
    		else if('Matrix_BI__c'.equalsIgnoreCase(sourceObjApiName)) {
    			for(Matrix_BI__c matrix : [SELECT Cycle_BI__c, Product_Catalog_BI__c FROM Matrix_BI__c WHERE Id = :sourceId LIMIT 1]) {
    				query += ' AND Cycle_BI__c = \'' + matrix.Cycle_BI__c + '\' AND Product_Catalog_BI__c = \'' + matrix.Product_Catalog_BI__c + '\' ORDER BY Product_Catalog_BI__c ';
    			}
    		}
    		
    		for(Matrix_BI__c matrix : Database.query(query)) {
    			if(map_productId_listAccountMatrix.get(matrix.Product_Catalog_BI__c) == NULL) map_productId_listAccountMatrix.put(matrix.Product_Catalog_BI__c, new list<Matrix_BI__c>());
    			
    			map_productId_listAccountMatrix.get(matrix.Product_Catalog_BI__c).add(matrix);
    		}
    	}
    	
    	return map_productId_listAccountMatrix;
    }

    /**
	 * Method to check whether the given id is a valid id for Cycle or Matrix
	 *
	 @author  Peng Zhu
	 @created 2015-01-09
	 @version 1.0
	 @since   30.0 (Force.com ApiVersion)
	 *
	 @param   sourceId   given id
	 *
	 @return  true/false
	 *
	 @changelog
	 * 2015-01-09 Peng Zhu <peng.zhu@itbconsult.com>
	 * - Created
	 */     
    @TestVisible    
    private static boolean isValidSourceId(Id sourceId) {
    	boolean rtValue = false;
    	
    	set<String> set_objApiName = new set<String>{'Cycle_BI__c', 'Matrix_BI__c'};
    	
    	if(sourceId != NULL && set_objApiName.contains(sourceId.getSObjectType().getDescribe().getName())) {
    		rtValue = true;
    	}
    	
    	return rtValue;
    }

    /**
	 * Method to fetch the account relation setting from custom setting according the given country iso code
	 *
	 @author  Peng Zhu
	 @created 2015-01-09
	 @version 1.0
	 @since   30.0 (Force.com ApiVersion)
	 *
	 @param   input  the given country iso code
	 *
	 @return  an instance of the related custom setting record
	 *
	 @changelog
	 * 2015-01-09 Peng Zhu <peng.zhu@itbconsult.com>
	 * - Created
	 */ 
    @TestVisible    
    private static Account_Relation_Setting_BI__c getAccountRelationSettingByCountry(String input) {
    	Account_Relation_Setting_BI__c inst;
    	
    	if(input != NULL && String.isNotBlank(input)) {
    		inst = Account_Relation_Setting_BI__c.getInstance(input);
    		
    		if(inst == NULL) inst = Account_Relation_Setting_BI__c.getInstance('Default');
    	}
    	 
    	return inst;
    }
    //********************************* -=END private methods=- ***********************************
    
    
    //********************************* -=BEGIN help functions=- **********************************
    /**
	 * Method to convert the string to salesforce id
	 *
	 @author  Peng Zhu
	 @created 2015-01-09
	 @version 1.0
	 @since   30.0 (Force.com ApiVersion)
	 *
	 @param   inputId   the string type of an Id
	 *
	 @return  the Id type of the given string
	 *
	 @changelog
	 * 2015-01-09 Peng Zhu <peng.zhu@itbconsult.com>
	 * - Created
	 */    
    @TestVisible
    private static Id getFullId(String inputId) {
    	Id rtId;
    	
    	try {
    		rtId = Id.valueOf(inputId);
    	}
    	catch(Exception e) {}
    	
    	return rtId;
    }
    
    //********************************* -=END help functions=- ************************************
    
    //********************************* -=BEGIN inner classes=- ***********************************
    ///*>>>WrapperClass*/
    /** Wrapper Class for remote action call response
     *
     @changelog
     * 2015-01-14 Peng Zhu <peng.zhu@itbconsult.com>
     * - Created
     */
    public class ClsResponse {
    	public String status;
    	public String result;
    	
    	public ClsResponse() {
    		status = 'SUCCESS';
    		result = '';
    	}
    }  
	///*<<<WrapperClass*/
    //********************************* -=END inner classes=- *************************************
}