/**
 *	Controller class used in ExtPortfolioReportList VF pages
 *
 @author 	Peng Zhu
 @created 	2013-06-25
 @version 	1.0
 @since 	27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-06-25 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
public class IMP_BI_ExtPortfolioReportList {
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	public Portfolio_BI__c portfolio {get; set;}
	public String reportUrl {get; set;}
	public String reportId {get; set;}
	public list<SelectOption> list_report {get; private set;} 
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    /**
	 * map to store global describtion due to limit on describe methodes.
	 */
	private map<String, String> map_urlParams;
	
	map<Id, Portfolio_Report_List_BI__c> map_id_prlb;
	
	private static final String AREA_LOCAL = 'local';
	private static final String AREA_GLOBAL = 'global';
	
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	/////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
   /**
	* The contsructor
	*
	@author Peng Zhu
	@created 2013-06-25
	@version 1.0
	@since 27.0 (Force.com ApiVersion)
	*
	@changelog
	* 2013-06-25 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public IMP_BI_ExtPortfolioReportList(ApexPages.standardController stdCtrl) {
    	map_urlParams = ApexPages.currentPage().getParameters();
    	
    	reportId = '';
    	reportUrl = '';
    	
    	//Portfolio_BI__c portfolioTemp = (Portfolio_BI__c) stdCtrl.getRecord();
    	//system.debug('**@@Peng portfolioTemp : ' + portfolioTemp);
    	
    	Id pfId = stdCtrl.getId();
    	if(pfId != null){
    		for(Portfolio_BI__c pf : [SELECT Id, Max_Number_SalesReps_BI__c, FTEs_Field_Force_Simulation_BI__c, Cycle_BI__r.Country_Lkp_BI__c FROM Portfolio_BI__c WHERE Id = :pfId]){
    			portfolio = pf;
    		}
    		
    	}
    	else{
    		portfolio = new Portfolio_BI__c();
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Portfolio Id!'));
    	}
    	
		list_report = getListOfReportName();
    }
	/////////////////////////////////// -=END CONSTRUCTOR=- ///////////////////////////////////////
    
    
    //********************************* -=BEGIN public methods=- **********************************
   /**
	* This method is used to 
	*
	@author  Peng Zhu
	@created 2013-06-25
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@param year			year string
	@param ownerId		owner id string
	*
	@return 			the visit capacity
	*
	@changelog
	* 2013-06-25 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    public void forceSimulationChanged(){
    	try{
    		reportUrl = '';
    		//reportId = '';
	    	if(portfolio != null) update portfolio;
	    	//list_report = getListOfReportName();
	    	
	    	reportListChanged();
    	}
    	catch(Exception e){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
    	}
    }
    
    public void reportListChanged(){
    	if(reportId != null && reportId.trim() != '' && map_id_prlb.containsKey(reportId)){
    		Portfolio_Report_List_BI__c prlb = map_id_prlb.get(reportId);
    		
    		reportUrl = prlb.Report_URL_BI__c;
    		String fieldExp = '', replaceStr = '';
    		if(prlb.Filter_1_BI__c != null && prlb.Filter_1_BI__c.trim() != ''){
				fieldExp = '';
				fieldExp = prlb.Filter_1_BI__c.trim();
				fieldExp = fieldExp.substring(fieldExp.indexOf('.') + 1, fieldExp.length() -1);
				if(fieldExp != null && fieldExp.trim() != '' && portfolio.get(fieldExp) != null){
					replaceStr = String.valueOf(portfolio.get(fieldExp));
					if(fieldExp.equalsIgnoreCase('Id')) replaceStr = replaceStr.substring(0, 15);
					if(reportUrl.contains(prlb.Filter_1_BI__c)) reportUrl = reportUrl.replace(prlb.Filter_1_BI__c, replaceStr);
				}
				else{
					reportUrl = reportUrl.replace(prlb.Filter_1_BI__c, '');
				}
			}
			
			if(prlb.Filter_2_BI__c != null && prlb.Filter_2_BI__c.trim() != ''){
				fieldExp = '';
				fieldExp = prlb.Filter_2_BI__c.trim();
				fieldExp = fieldExp.substring(fieldExp.indexOf('.') + 1, fieldExp.length() -1);
				if(fieldExp != null && fieldExp.trim() != '' && portfolio.get(fieldExp) != null){
					replaceStr = String.valueOf(portfolio.get(fieldExp));
					if(fieldExp.equalsIgnoreCase('Id')) replaceStr = replaceStr.substring(0, 15);
					if(reportUrl.contains(prlb.Filter_2_BI__c)) reportUrl = reportUrl.replace(prlb.Filter_2_BI__c, replaceStr);
				}
				else{
					reportUrl = reportUrl.replace(prlb.Filter_2_BI__c, '');
				}
			}
			
			if(prlb.Filter_3_BI__c != null && prlb.Filter_3_BI__c.trim() != ''){
				fieldExp = '';
				fieldExp = prlb.Filter_3_BI__c.trim();
				fieldExp = fieldExp.substring(fieldExp.indexOf('.') + 1, fieldExp.length() -1);
				if(fieldExp != null && fieldExp.trim() != '' && portfolio.get(fieldExp) != null){
					replaceStr = String.valueOf(portfolio.get(fieldExp));
					if(fieldExp.equalsIgnoreCase('Id')) replaceStr = replaceStr.substring(0, 15);
					if(reportUrl.contains(prlb.Filter_3_BI__c)) reportUrl = reportUrl.replace(prlb.Filter_3_BI__c, replaceStr);
				}
				else{
					reportUrl = reportUrl.replace(prlb.Filter_3_BI__c, '');
				}
			}
    	}
    	else{
    		reportUrl = '';
    	}
    }
    //********************************* -=END public methods=- ************************************
    
    
    //********************************* -=BEGIN private methods=- *********************************
   /**
	* This method is used to get list of report name
	*
	@author  Peng Zhu
	@created 2013-06-25
	@version 1.0
	@since   27.0 (Force.com ApiVersion)
	*
	@return 	list<SelectOption>
	*
	@changelog
	* 2013-06-25 Peng Zhu <peng.zhu@itbconsult.com>
	* - Created
	*/
    private list<SelectOption> getListOfReportName(){
    	list<SelectOption> list_so = new list<SelectOption>();
    	
    	map_id_prlb = new map<Id, Portfolio_Report_List_BI__c>();
    	
    	set<String> set_pFields = new set<String>();
    	
		list_so.add(new SelectOption('', '--None--'));
    	if(portfolio != null){
    		String queryStr = 'SELECT Id, Name, Filter_1_BI__c, Filter_2_BI__c, Filter_3_BI__c, Area_BI__c, Country_BI__c, Report_URL_BI__c FROM Portfolio_Report_List_BI__c  WHERE ';
			
			//if(portfolio.FTEs_Field_Force_Simulation_BI__c != null){
			//	queryStr += ' Simulation_BI__c = TRUE AND (';
			//}
			
    		if(portfolio.Cycle_BI__r.Country_Lkp_BI__c != null){
    			queryStr += ' (Country_BI__c = \'' + portfolio.Cycle_BI__r.Country_Lkp_BI__c + '\' AND Area_BI__c = \'' + AREA_LOCAL + '\' ';
    			queryStr += ') OR ';
    		}
    		
    		queryStr += ' (Area_BI__c = \'' + AREA_GLOBAL +'\')';
    		
    		//if(portfolio.FTEs_Field_Force_Simulation_BI__c != null){
			//	queryStr += ' )';
			//}
			
    		queryStr += ' ORDER BY Name';
    		
    		String fieldExp = '';
			for(Portfolio_Report_List_BI__c prlb : Database.query(queryStr)){
				if(prlb.Name != null && prlb.Report_URL_BI__c != null){
					list_so.add(new SelectOption(prlb.Id, prlb.Name));
					
					map_id_prlb.put(prlb.Id, prlb);
					
					if(prlb.Filter_1_BI__c != null && prlb.Filter_1_BI__c.trim() != ''){
						fieldExp = prlb.Filter_1_BI__c.trim();
						if(fieldExp != null && fieldExp.trim() != '') fieldExp = fieldExp.substring(fieldExp.indexOf('.') + 1, fieldExp.length() -1);
						if(fieldExp != null && fieldExp.trim() != '' && !set_pFields.contains(fieldExp)) set_pFields.add(fieldExp);
					}
					
					if(prlb.Filter_2_BI__c != null && prlb.Filter_2_BI__c.trim() != ''){
						fieldExp = prlb.Filter_2_BI__c.trim();
						if(fieldExp != null && fieldExp.trim() != '') fieldExp = fieldExp.substring(fieldExp.indexOf('.') + 1, fieldExp.length() -1);
						if(fieldExp != null && fieldExp.trim() != '' && !set_pFields.contains(fieldExp)) set_pFields.add(fieldExp);
					}
					
					if(prlb.Filter_3_BI__c != null && prlb.Filter_3_BI__c.trim() != ''){
						fieldExp = prlb.Filter_3_BI__c.trim();
						if(fieldExp != null && fieldExp.trim() != '') fieldExp = fieldExp.substring(fieldExp.indexOf('.') + 1, fieldExp.length() -1);
						if(fieldExp != null && fieldExp.trim() != '' && !set_pFields.contains(fieldExp)) set_pFields.add(fieldExp);
					}
				}
				
			}
			
			if(!set_pFields.contains('Id')) set_pFields.add('Id');
			if(!set_pFields.contains('FTEs_Field_Force_Simulation_BI__c')) set_pFields.add('FTEs_Field_Force_Simulation_BI__c');
			if(!set_pFields.contains('Cycle_BI__r.Country_Lkp_BI__c')) set_pFields.add('Cycle_BI__r.Country_Lkp_BI__c');
			if(!set_pFields.contains('Max_Number_SalesReps_BI__c')) set_pFields.add('Max_Number_SalesReps_BI__c');
			
			if(!set_pFields.isEmpty() && portfolio.Id != null){
				queryStr = 'SELECT ';
				
				for(String str : set_pFields){
					queryStr += str + ', ';
				}
				
				queryStr = queryStr.substring(0, queryStr.length()-2);
				
				queryStr += ' FROM Portfolio_BI__c WHERE Id = \'' + portfolio.Id + '\'';
				
				for(Portfolio_BI__c pf : Database.query(queryStr)){
					portfolio = pf;
				}
			
			}
    	}
    	return list_so;
    }
    
    //********************************* -=END private methods=- ***********************************
    
    
    //********************************* -=BEGIN help functions=- **********************************
    //********************************* -=END help functions=- ************************************
    
    //********************************* -=BEGIN inner classes=- ***********************************
    ///*>>>WrapperClass*/
	///*<<<WrapperClass*/
    //********************************* -=END inner classes=- *************************************
}