/**
*	Set matrix name convention
*
@author Yuanyuan Zhang
@created 2013-05-17
@version 1.0
@since 26.0 (Force.com ApiVersion)
*
@changelog
* 2015-01-08 Peng Zhu <peng.zhu@itbconsult.com>
* - Modified: given a defalut value to Scenario_BI__c when insert a matrix
*
* 2013-06-13 Peng Zhu <peng.zhu@itbconsult.com>
* - Modified : override code using Trigger Matix_BIU_setMatixName.trigger
*
* 2013-05-17 Yuanyuan Zhang <yuanyuan.zhang@itbconsult.com>
* - Created
*/

trigger IMP_BI_Matrix_BIU_setMatrixName on Matrix_BI__c (before insert, before update) {
	
	//************************* BEGIN Pre-Processing **********************************************
	//System.debug('************************* ' + triggerName + ': BEGIN Pre-Processing ********');
	
	
	//************************* END Pre-Processing ************************************************
	//System.debug('************************* ' + triggerName + ': END Pre-Processing **********');
	
	//************************* BEGIN Before Trigger **********************************************
	/*
	 * Commented by Peng Zhu 2013-06-13 Merge with Trigger Matix_BIU_setMatixNamee.trigger
	 *
	set<Id> set_productId = new set<Id>();
	set<Id> set_cycleId = new set<Id>();
	for(Matrix_BI__c ma : Trigger.new) {
		if(ma.Product_Catalog_BI__c != null){
			set_productId.add(ma.Product_Catalog_BI__c);
		}
		if(ma.Cycle_BI__c != null){
			set_cycleId.add(ma.Cycle_BI__c);
		}
	}
	
	map<Id, Product_vod__c> map_prodId_product = new map<Id, Product_vod__c>();
	map<Id, Cycle_BI__c> map_cycId_cycle = new map<Id, Cycle_BI__c>();
	
	if(!set_productId.isEmpty()){
		for(Product_vod__c pr : [SELECT Id, Name FROM Product_vod__c WHERE Id IN :set_productId]){
			map_prodId_product.put(pr.Id, pr);
		}
		
	}
	if(!set_cycleId.isEmpty()){
		for(Cycle_BI__c cyc : [SELECT Id, Name FROM Cycle_BI__c WHERE Id IN :set_cycleId]){
			map_cycId_cycle.put(cyc.Id, cyc);
		}
	}
	
	String userInitials = [SELECT User_Initials_BI__c FROM User WHERE Id = :UserInfo.getUserId()].User_Initials_BI__c;
	if(userInitials == null) userInitials='';
	for(Matrix_BI__c ma : Trigger.new){
		String prodName = ma.Product_Catalog_BI__c==null? ' ' : map_prodId_product.get(ma.Product_Catalog_BI__c).Name;
		prodName = prodName==null?' ':prodName;
		String cycName = ma.Cycle_BI__c == null? ' ' : map_cycId_cycle.get(ma.Cycle_BI__c).Name;
		cycName = cycName == null?' ':cycName;
		String createDate = ma.CreatedDate ==null? datetime.now().format():ma.CreatedDate.format();
		String specialty = ma.Specialization_BI__c == null?' ' : ma.Specialization_BI__c;
		String matrixname = userInitials + '_' + prodName + '_' + specialty + '_' + cycName + '_' + createDate;
		ma.Name = matrixname.length() > 80?matrixname.subString(0,80):matrixname;//name field has a length limit 80.
	}
	*/
	//Begin: added by Peng Zhu 2013-06-13 Copy from Trigger : Mati_BIU_setMatixName.trigger
	/*set<Id> set_productId = new set<Id>();
	set<Id> set_cycleId = new set<Id>();
	map<Id, set<Id>> map_cycId_set_matrixId = new map<Id, set<Id>>();
	
	for(Matrix_BI__c ma : Trigger.new) {
		if(ma.Product_catalog_BI__c != null){
			set_productId.add(ma.Product_Catalog_BI__c);
		}
		if(ma.Cycle_BI__c != null){
			set_cycleId.add(ma.Cycle_BI__c);
			set<Id> set_matrixId = new set<Id>();
			if(map_cycId_set_matrixId.containsKey(ma.Cycle_BI__c)){
				set_matrixId = map_cycId_set_matrixId.get(ma.Cycle_BI__c);
			}
			set_matrixId.add(ma.Id);
			map_cycId_set_matrixId.put(ma.Cycle_BI__c,set_matrixId);
		}
	}
	
	map<Id, Product_vod__c> map_prodId_product = new map<Id, Product_vod__c>();
	map<Id, Cycle_BI__c> map_cycId_cycle = new map<Id, Cycle_BI__c>();
	set<String> set_country = new set<String>();
	//set<String> set_group = new set<String>();
	map<Id, set<Id>> map_country_set_matrixId = new map<Id, set<Id>>();
	map<Id, set<String>> map_country_set_group = new map<Id, set<String>>();
	map<Id, String> map_counid_groupString = new map<Id, String>();
	map<Id, String> map_matrixId_groupString = new map<Id, String>();
	
	if(!set_productId.isEmpty()){
		for(Product_vod__c pr : [SELECT Id, Name FROM Product_vod__c WHERE Id IN :set_productId]){
			map_prodId_product.put(pr.Id, pr);
		}
		
	}
	if(!set_cycleId.isEmpty()){
		for(Cycle_BI__c cyc : [SELECT Id, Name, Country_Lkp_BI__c FROM Cycle_BI__c WHERE Id IN :set_cycleId]){
			map_cycId_cycle.put(cyc.Id, cyc);
			set_country.add(cyc.Country_Lkp_BI__c);
			set<Id> set_matrixId = map_cycId_set_matrixId.get(cyc.Id);
			set<Id> set_matrixId2 = new set<Id>();
			if(map_country_set_matrixId.containsKey(cyc.Country_Lkp_BI__c)){
				set_matrixId2 = map_country_set_matrixId.get(cyc.Country_Lkp_BI__c);
			}
			set_matrixId2.addAll(set_matrixId);
			map_country_set_matrixId.put(cyc.Country_Lkp_BI__c,set_matrixId2);
		}
	}
	
	if(!set_country.isEmpty()){
		for(Customer_Attribute_BI__c sp : [SELECT Group_BI__c,Country_BI__c FROM Customer_Attribute_BI__c WHERE Country_BI__c IN: set_country]){
			//set_group.add(sp.Group__c);
			if(!String.isBlank(sp.Group_BI__c)){
				set<String> set_group = new set<String>();
				if(map_country_set_group.containsKey(sp.Country_BI__c)){
					set_group = map_country_set_group.get(sp.Country_BI__c);
				}
				set_group.add(sp.Group_BI__c);
				map_country_set_group.put(sp.Country_BI__c,set_group);
			}
			
		}
	}
	//map_counid_groupString
	for(Id coun : map_country_set_group.keyset()){
		String groupString = '';
		for(String gp : map_country_set_group.get(coun)){
			groupString += gp + '|';
		}
		if(groupString.endsWith('|')){
			groupString = groupString.subString(0,groupString.length()-1);
		}
		map_counid_groupString.put(coun,groupString);
	}
	
	for(Id coun : map_country_set_matrixId.keySet()){
		for(Id maId : map_country_set_matrixId.get(coun)){//map_matrixId_groupString
			if(map_counid_groupString.containsKey(coun)){
				map_matrixId_groupString.put(maId, map_counid_groupString.get(coun));
			}
		}
	}
	
	String userInitials = [SELECT User_Initials_BI__c FROM User WHERE Id = :UserInfo.getUserId()].User_Initials_BI__c;
	if(userInitials == null) userInitials='';
	for(Matrix_BI__c ma : Trigger.new){
		String prodName = ma.Product_Catalog_BI__c==null? ' ' : map_prodId_product.get(ma.Product_Catalog_BI__c).Name;
		prodName = prodName==null?' ':prodName;
		String cycName = ma.Cycle_BI__c == null? ' ' : map_cycId_cycle.get(ma.Cycle_BI__c).Name;
		cycName = cycName == null?' ':cycName;
		//2013-05-29 modified by Yuanyuan Zhang use lastmodifieddate instead createdate and in update call doesn't update user initial --BEGIN
		String lastDate = ma.LastModifiedDate ==null? datetime.now().format():ma.LastModifiedDate.format();
		
		String specialty = map_matrixId_groupString.containsKey(ma.Id)?map_matrixId_groupString.get(ma.Id): ' ';
		try{
			if(trigger.isUpdate){
				list<String> list_matrixName = new list<String>();
				list_matrixName = ma.Name.split('_');
				//system.debug('yylist_matrixName: ' + list_matrixName);
				userInitials = list_matrixName.size() == 0?' ':list_matrixName[0];
				cycName = list_matrixName.size() < 4?' ':list_matrixName[3];
			}
		}
		catch(Exception ex){
			ma.addError(ex.getMessage());
		}
		String matrixname = userInitials + '_' + prodName + '_' + specialty + '_' + cycName + '_' + lastDate;
		//2013-05-29 modified by Yuanyuan Zhang use lastmodifieddate instead createdate and in update call doesn't update user initial --END
		ma.Name = matrixname.length() > 80?matrixname.subString(0,80):matrixname;//name field has a length limit 80.
	}*/
	//End: added by Peng Zhu 2013-06-13 Copy from Trigger : Mati_BIU_setMatixName.trigger
	
	//Begin: added by Peng Zhu 2015-01-08 -- given a defalut value to Scenario_BI__c when insert a matrix
	if(trigger.isBefore && trigger.isInsert) {
		for(Matrix_BI__c matrix : trigger.new) {
			if(matrix.Scenario_BI__c == NULL) matrix.Scenario_BI__c = '1';
		}
	}
	//End: added by Peng Zhu 2015-01-08 -- given a defalut value to Scenario_BI__c when insert a matrix
	
	
	set<Id> set_productId = new set<Id>();
	set<Id> set_cycleId = new set<Id>();
	map<Id, set<Id>> map_cycId_set_matrixId = new map<Id, set<Id>>();
	
	for(Matrix_BI__c ma : Trigger.new) {
		if(ma.Product_catalog_BI__c != null){
			set_productId.add(ma.Product_Catalog_BI__c);
		}
		if(ma.Cycle_BI__c != null){
			set_cycleId.add(ma.Cycle_BI__c);
			set<Id> set_matrixId = new set<Id>();
			if(map_cycId_set_matrixId.containsKey(ma.Cycle_BI__c)){
				set_matrixId = map_cycId_set_matrixId.get(ma.Cycle_BI__c);
			}
			set_matrixId.add(ma.Id);
			map_cycId_set_matrixId.put(ma.Cycle_BI__c,set_matrixId);
		}
	}
	map<Id, Product_vod__c> map_prodId_product = new map<Id, Product_vod__c>();
	map<Id, Cycle_BI__c> map_cycId_cycle = new map<Id, Cycle_BI__c>();
	if(!set_productId.isEmpty()){
		for(Product_vod__c pr : [SELECT Id, Name FROM Product_vod__c WHERE Id IN :set_productId]){
			map_prodId_product.put(pr.Id, pr);
		}
		
	}
	if(!set_cycleId.isEmpty()){
		for(Cycle_BI__c cyc : [SELECT Id, Name, Country_Lkp_BI__c FROM Cycle_BI__c WHERE Id IN :set_cycleId]){
			map_cycId_cycle.put(cyc.Id, cyc);
		}
	}
	String userInitials = [SELECT User_Initials_BI__c FROM User WHERE Id = :UserInfo.getUserId()].User_Initials_BI__c;
	if(userInitials == null) userInitials='';
	for(Matrix_BI__c ma : Trigger.new){
		String prodName = ma.Product_Catalog_BI__c==null? ' ' : map_prodId_product.get(ma.Product_Catalog_BI__c).Name;
		prodName = prodName==null?' ':prodName;
		String cycName = ma.Cycle_BI__c == null? ' ' : map_cycId_cycle.get(ma.Cycle_BI__c).Name;
		cycName = cycName == null?' ':cycName;
		//2013-05-29 modified by Yuanyuan Zhang use lastmodifieddate instead createdate and in update call doesn't update user initial --BEGIN
		String lastDate = ma.LastModifiedDate ==null? datetime.now().format():ma.LastModifiedDate.format();
		
		/*String specialty = map_matrixId_groupString.containsKey(ma.Id)?map_matrixId_groupString.get(ma.Id): ' ';*/
		
		//commented out by Peng Zhu 2013-10-14
		String specialty = '';
		if(ma.Specialization_BI__c != NULL) specialty = ma.Specialization_BI__c.replace(';','|');
		
		try{
			if(trigger.isUpdate){
				list<String> list_matrixName = new list<String>();
				list_matrixName = ma.Name.split('_');
				//system.debug('yylist_matrixName: ' + list_matrixName);
				userInitials = list_matrixName.size() == 0?' ':list_matrixName[0];
				cycName = list_matrixName.size() < 4?' ':list_matrixName[3];
			}
		}
		catch(Exception ex){
			ma.addError(ex.getMessage());
		}
		String matrixname = userInitials + '_' + prodName + '_' + specialty + '_' + cycName + '_' + lastDate;
		//2013-05-29 modified by Yuanyuan Zhang use lastmodifieddate instead createdate and in update call doesn't update user initial --END
		ma.Name = matrixname.length() > 80?matrixname.subString(0,80):matrixname;//name field has a length limit 80.
	}
	//************************* END Before Trigger ************************************************
	
	//************************* BEGIN After Trigger ***********************************************
	
	//************************* END After Trigger *************************************************
}