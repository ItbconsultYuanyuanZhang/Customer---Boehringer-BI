/**
 *	Contains a set of static methods used in Matrix Filter related class, trigger and VF pages
 *
 @author 	Peng Zhu
 @created 	2013-07-26
 @version 	1.0
 @since 	27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-07-26 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
public class IMP_BI_ClsMatrixFilterConfig {
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    /**
	 * set to store avaliable filter field on account
	 */	
	public static final set<String> SET_ACCOUNT_FIELD_FILTER = new set<String>{
		//'Access_BI__c', //
		'BI_Speaker_BI__c', 
		'Call_BI__c', 
		'Call_Limitation_BI__c', 
		'Do_Not_Call_vod__c', 
		//'KOL_Therapeutic_Area__c', 
		'Preferred_Channel_for_Campaign_BI__c',
		'Preferred_Channel_for_Contact_BI__c', 
		'Rep_Access_BI__c', 
		'Rx_Behavior_BI__c', 
		'Scientific_Expert__c', 
		//'Territory_vod__c',
		'WebDetailing_BI__c',
		//TODO:jescobar New Filter Profiles US Request 27-Oct-2014
		'IMMPaCT_profile1_BI__c',
		'IMMPaCT_profile2_BI__c',
		'IMMPaCT_profile3_BI__c',
		'IMMPaCT_profile4_BI__c',
		'IMMPaCT_profile5_BI__c',
		'IMMPaCT_profile6_BI__c',
		'IMMPaCT_profile7_BI__c',
		'IMMPaCT_profile8_BI__c',
		'IMMPaCT_profile9_BI__c'
	};
	
    /**
	 * map to store 'account field api name' -- 'cycle data field api name'
	 */
	 public static final Map<String, String> map_acApi_cdApi = new Map<String, String>{
	 	//'Access_BI__c' => 'Access_BI__c',
	 	'BI_Speaker_BI__c' => 'BI_Speaker_BI__c',
	 	'Call_BI__c' => 'Call_BI__c',
	 	'Call_Limitation_BI__c' => 'Call_Limitation_BI__c',
	 	'Do_Not_Call_vod__c' => 'Do_Not_Call_vod_BI__c',
	 	'Preferred_Channel_for_Campaign_BI__c' => 'Preferred_Channel_for_Campaign_BI__c',
	 	'Preferred_Channel_for_Contact_BI__c' => 'Preferred_Channel_for_Contact_BI__c',
	 	'Rep_Access_BI__c' => 'Rep_Access_BI__c',
	 	'Rx_Behavior_BI__c' => 'Rx_Behavior_BI__c',
	 	'Scientific_Expert__c' => 'Scientific_Expert_BI__c',
	 	'WebDetailing_BI__c' => 'Face_to_Face_BI__c',
	 	//TODO:jescobar New Filter Profiles US Request 27-Oct-2014
		'IMMPaCT_profile1_BI__c' => 'IMMPaCT_profile1_BI__c',
		'IMMPaCT_profile2_BI__c' => 'IMMPaCT_profile2_BI__c',
		'IMMPaCT_profile3_BI__c' => 'IMMPaCT_profile3_BI__c',
		'IMMPaCT_profile4_BI__c' => 'IMMPaCT_profile4_BI__c',
		'IMMPaCT_profile5_BI__c' => 'IMMPaCT_profile5_BI__c',
		'IMMPaCT_profile6_BI__c' => 'IMMPaCT_profile6_BI__c',
		'IMMPaCT_profile7_BI__c' => 'IMMPaCT_profile7_BI__c',
		'IMMPaCT_profile8_BI__c' => 'IMMPaCT_profile8_BI__c',
		'IMMPaCT_profile9_BI__c' => 'IMMPaCT_profile9_BI__c'
	 };
	 
    /**
	 * map to store 'cycle data field api name' -- 'account field api name'
	 */
	 public static final Map<String, String> map_cdApi_acApi = new Map<String, String>{
	 	//'Access_BI__c' => 'Access_BI__c',
	 	'BI_Speaker_BI__c' => 'BI_Speaker_BI__c',
	 	'Call_BI__c' => 'Call_BI__c',
	 	'Call_Limitation_BI__c' => 'Call_Limitation_BI__c',
	 	'Do_Not_Call_vod_BI__c' => 'Do_Not_Call_vod__c',
	 	'Face_to_Face_BI__c' => 'WebDetailing_BI__c',
	 	'Preferred_Channel_for_Campaign_BI__c' => 'Preferred_Channel_for_Campaign_BI__c',
	 	'Preferred_Channel_for_Contact_BI__c' => 'Preferred_Channel_for_Contact_BI__c',
	 	'Rep_Access_BI__c' => 'Rep_Access_BI__c',
	 	'Rx_Behavior_BI__c' => 'Rx_Behavior_BI__c',
	 	'Scientific_Expert_BI__c' => 'Scientific_Expert__c',
	 	//TODO:jescobar New Filter Profiles US Request 27-Oct-2014
		'IMMPaCT_profile1_BI__c' => 'IMMPaCT_profile1_BI__c',
		'IMMPaCT_profile2_BI__c' => 'IMMPaCT_profile2_BI__c',
		'IMMPaCT_profile3_BI__c' => 'IMMPaCT_profile3_BI__c',
		'IMMPaCT_profile4_BI__c' => 'IMMPaCT_profile4_BI__c',
		'IMMPaCT_profile5_BI__c' => 'IMMPaCT_profile5_BI__c',
		'IMMPaCT_profile6_BI__c' => 'IMMPaCT_profile6_BI__c',
		'IMMPaCT_profile7_BI__c' => 'IMMPaCT_profile7_BI__c',
		'IMMPaCT_profile8_BI__c' => 'IMMPaCT_profile8_BI__c',
		'IMMPaCT_profile9_BI__c' => 'IMMPaCT_profile9_BI__c'
	 };
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	/////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////

	/////////////////////////////////// -=END CONSTRUCTOR=- ///////////////////////////////////////
    
    
    //********************************* -=BEGIN public methods=- **********************************
   /**
	* This method is used to filter the needless field
	*
	@author  Peng Zhu
	@created 2013-07-26
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@param	 objType	 Object Api Name
	@param	 set_filter  set of choice field, field name
	*
	@return  map_aName_aLabel   a map, key is Field Api Name and value id Field Label Name
	*
	@changelog
	* 2013-07-26 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/  
	public static map<String, String> getFieldMapping(String objType, set<String> set_filter){
		map<String, String> map_aName_aLabel = new map<String, String>();

		if(objType != null && (objType = objType.trim()) != ''){
			map<String, Schema.SObjectField> fieldMap= Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();
			
			for (String fieldName: fieldMap.keySet()) {
				if(set_filter == null || set_filter.isEmpty() || set_filter.contains(fieldName)){
					map_aName_aLabel.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
				}
			}
		}
		
		return map_aName_aLabel;
    }
    //********************************* -=END public methods=- ************************************
    
    
    //********************************* -=BEGIN private methods=- *********************************
    //********************************* -=END private methods=- ***********************************
    
    
    //********************************* -=BEGIN help functions=- **********************************
    //********************************* -=END help functions=- ************************************
    
    //********************************* -=BEGIN inner classes=- ***********************************
    ///*>>>WrapperClass*/
	///*<<<WrapperClass*/
    //********************************* -=END inner classes=- *************************************
}