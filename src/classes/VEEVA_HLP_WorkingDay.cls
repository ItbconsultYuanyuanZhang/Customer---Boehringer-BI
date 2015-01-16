/*********************************************
Helper class to get working days for a given
Year/Month/Country
*********************************************/
public with sharing class VEEVA_HLP_WorkingDay 
{
	
	private String theYear;
	private String theMonth;
	private String theCountry;
	
	private Integer theWD;
	
	private String SQLs = 'Select ';
	
	public VEEVA_HLP_WorkingDay()
	{
		
	}
	
	/**********************************************************************
	
	**********************************************************************/
	public Integer GetWorkingDay(String Country, String Year, String Month)
	{
		
		String MonthWD = Month + '_BI__c';
		String RealName = Country + '_' + Year;
		
		SQLs = 'Select Max(' + MonthWD + ') resultu from Working_Day_BI__c where Country_Code_BI__c = \'' + Country + '\'  and Name = \'' + RealName + '\' ';
		
		System.debug('SQLu: ' + SQLs);
		
		List<AggregateResult> ARs = Database.query(SQLs);
		
		Integer Res =  Integer.valueOf(ARs[0].get('resultu'));  
		
		System.debug('Res = ' + Res);
		
		return Res;
	}

}