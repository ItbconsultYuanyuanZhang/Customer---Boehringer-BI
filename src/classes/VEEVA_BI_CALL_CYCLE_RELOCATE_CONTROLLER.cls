public with sharing class VEEVA_BI_CALL_CYCLE_RELOCATE_CONTROLLER {

	public 	Call_Cycle_Entry_vod__c c1 { get;set; }
	
	string userID = UserInfo.getUserID();
	
	public list<Call_Cycle_Entry_vod__c> cceToUpdate  { get;set; }
	public list<Call_Cycle_Entry_vod__c> cceToDisplay { get;set; }
	
	//variables for translation
	string language = UserInfo.getLanguage();
	public string responseMessage { get;set; }
	public string description     { get;set; }
	public string title     { get;set; }
	public string weekLabel { get;set; }
	public string dayLabel  { get;set; }
	public string save      { get;set; }
	public string descLabel { get;set; }
	public string all;
	public string fromUserLabel  { get;set; }
	public string toUserLabel    { get;set; }
	public string resultLabel    { get;set; }
	
	public string selectUser;
	public string success;
	
	public string fromUser  	 { get;set; }
	public string toUser 		 { get;set; }
	public string selectedWeekID { get;set; }
	public string selectedDayID  { get;set; }
	
	
	public VEEVA_BI_CALL_CYCLE_RELOCATE_CONTROLLER(ApexPages.StandardController stdController) 
	{
		this.c1 = (Call_Cycle_Entry_vod__c)stdController.getRecord();
		
		fromUser = UserInfo.getName();
		//toUser = '???';
		
		//Error message translation
		Message_vod__c [] labels = [select 	Name,
											Text_vod__c 
									from 	Message_vod__c 
									where 	Language_vod__c = :language
									and 	Category_vod__c = 'Call Cycle Entry Relocate' 
									and 	Name in ('CCE_TITLE','CCE_SAVE_LABEL','CCE_DAY_LABEL','CCE_FROM_USER_LABEL','CCE_TO_USER_LABEL','CCE_DESC_Text','CCE_DESC_LABEL','CCE_WEEK_LABEL','CCE_ALL','CCE_RESULT_LABEL','CCE_SUCCESS','CCE_SELECT_USER') 
									and 	Active_vod__c = true];
	
		Map <String,String> labelMap = new Map <String,String> ();
	        
	    for (Message_vod__c label : labels) 
	    {
	    	labelMap.put(label.Name, label.Text_vod__c);
	    }
	    
	    
	    Map <String,String> labelMapEn = new Map <String,String> ();
	        
	    for (Message_vod__c label : [select Name, 
	    									Text_vod__c 
	    							 from 	Message_vod__c where Language_vod__c = 'en_US'
	    							 and 	Category_vod__c = 'Call Cycle Entry Relocate' 
	    							 and 	Name in ('CCE_TITLE','CCE_SAVE_LABEL','CCE_DAY_LABEL','CCE_FROM_USER_LABEL','CCE_TO_USER_LABEL','CCE_DESC_Text','CCE_DESC_LABEL','CCE_WEEK_LABEL','CCE_ALL','CCE_RESULT_LABEL','CCE_SUCCESS','CCE_SELECT_USER')  
	    							 and 	Active_vod__c = true])
	    {
	    	labelMapEn.put(label.Name, label.Text_vod__c);
	    }
		
		// translate labels
		title          = labelMap.get('CCE_TITLE') != null ? labelMap.get('CCE_TITLE') : labelMapEn.get('CCE_TITLE');
		save           = labelMap.get('CCE_SAVE_LABEL') != null ? labelMap.get('CCE_SAVE_LABEL') : labelMapEn.get('CCE_SAVE_LABEL');
		fromUserLabel  = labelMap.get('CCE_FROM_USER_LABEL') != null ? labelMap.get('CCE_FROM_USER_LABEL') : labelMapEn.get('CCE_FROM_USER_LABEL');
		toUserLabel    = labelMap.get('CCE_TO_USER_LABEL') != null ? labelMap.get('CCE_TO_USER_LABEL') : labelMapEn.get('CCE_TO_USER_LABEL');
		description    = labelMap.get('CCE_DESC_Text') != null ? labelMap.get('CCE_DESC_Text') : labelMapEn.get('CCE_DESC_Text');
		descLabel      = labelMap.get('CCE_DESC_LABEL') != null ? labelMap.get('CCE_DESC_LABEL') : labelMapEn.get('CCE_DESC_LABEL');
		weekLabel      = labelMap.get('CCE_WEEK_LABEL') != null ? labelMap.get('CCE_WEEK_LABEL') : labelMapEn.get('CCE_WEEK_LABEL');
		dayLabel       = labelMap.get('CCE_DAY_LABEL') != null ? labelMap.get('CCE_DAY_LABEL') : labelMapEn.get('CCE_DAY_LABEL');
		all            = labelMap.get('CCE_ALL') != null ? labelMap.get('CCE_ALL') : labelMapEn.get('CCE_ALL');
		resultLabel    = labelMap.get('CCE_RESULT_LABEL') != null ? labelMap.get('CCE_RESULT_LABEL') : labelMapEn.get('CCE_RESULT_LABEL');
		selectUser     = labelMap.get('CCE_SELECT_USER') != null ? labelMap.get('CCE_SELECT_USER') : labelMapEn.get('CCE_SELECT_USER');
		success        = labelMap.get('CCE_SUCCESS') != null ? labelMap.get('CCE_SUCCESS') : labelMapEn.get('CCE_SUCCESS');
		
		
		display();
		
	}

	//populate Week picklist
	public list<selectOption> getWeeks() 
	{
		list<selectOption> optionsWeek = new List<selectOption>();
		//optionsWeek.add(new selectOption('', none)); 
		optionsWeek.add(new selectOption('', all)); 
		string week = '';
		for (Call_Cycle_Entry_vod__c weeks : [select ID, Week_vod__c from Call_Cycle_Entry_vod__c where OwnerID =: userID order by Week_vod__c ]) 
		{ 
			if(week != string.valueOf(weeks.Week_vod__c))
			{
				optionsWeek.add(new selectOption(weeks.Id, string.valueOf(weeks.Week_vod__c)));
				week = string.valueOf(weeks.Week_vod__c);
			}
		}
		return optionsWeek; //return the picklist options 
	}

	//populate Day picklist
	public list<selectOption> getDays() 
	{
		list<selectOption> optionsDay = new List<selectOption>();
		//optionsDay.add(new selectOption('none', none)); 
		optionsDay.add(new selectOption('all', all)); 
		string day = '';
		for (Call_Cycle_Entry_vod__c days : [select ID, Day_of_Week_vod__c from Call_Cycle_Entry_vod__c where OwnerID =: userID order by Day_of_Week_vod__c ]) 
		{ 
			if(day != days.Day_of_Week_vod__c)
			{
				optionsDay.add(new selectOption(days.Id, days.Day_of_Week_vod__c)); 
				day = days.Day_of_Week_vod__c;
			}
		}
		return optionsDay; //return the picklist options 
	}
	
	//display actual record those are in the scope based on filter setup
	public void display()
	{
		system.debug('DISPLAY METHOD');
		string query = ' ';
		string andClause = ' ';
		
		decimal selectedWeek;
		string selectedDay;
		
		if(selectedWeekID == 'all' || selectedWeekID == 'none' || selectedWeekID == null)
			selectedWeek = null;
		else
			selectedWeek = [select Week_vod__c from Call_Cycle_Entry_vod__c where ID =: selectedWeekID limit 1].Week_vod__c;
			
		if(selectedDayID == 'all' || selectedDayID == 'none' || selectedDayID == null)
			selectedDay = null;
		else
			selectedDay  = [select Day_of_Week_vod__c from Call_Cycle_Entry_vod__c where ID =: selectedDayID limit 1].Day_of_Week_vod__c;
		
		
		//Week and Day filter handling
		if(selectedWeek != null)
			andClause = andClause + ' AND Week_vod__c = ' + selectedWeek + '';
		
		if(selectedDay != null)
			andClause = andClause + ' AND Day_of_Week_vod__c = \'' + selectedDay + '\'';
			
		
		list<Call_Cycle_Entry_vod__c> cceD;
		cceToDisplay = new list<Call_Cycle_Entry_vod__c>();
		
		cceD = database.query('select ID, Call_Cycle_Entry_vod__c.Name, Owner.Name, Account_vod__r.Name, Week_vod__c, Day_of_Week_vod__c, Duration_vod__c from Call_Cycle_Entry_vod__c where OwnerID = : userID ' + andClause + ' order by Week_vod__c ');
		system.debug('CCED SIZE: ' + cced.size());
		
		//record update
		//for(integer i=0; i<cceD.size(); i++)
		//{
		//	cceToDisplay.add(cceD[i]);
		//	system.debug('CCED RECORDS: ' + cceD[i]);
		//}
		
		//display order: Monday - Friday
		for(integer i=0; i<cceD.size(); i++)
		{
			if(cceD[i].Day_of_Week_vod__c == 'Monday')
				cceToDisplay.add(cceD[i]);
		}
		
		for(integer i=0; i<cceD.size(); i++)
		{
			if(cceD[i].Day_of_Week_vod__c == 'Tuesday')
				cceToDisplay.add(cceD[i]);
		}
		
		for(integer i=0; i<cceD.size(); i++)
		{
			if(cceD[i].Day_of_Week_vod__c == 'Wednesday')
				cceToDisplay.add(cceD[i]);
		}
		
		for(integer i=0; i<cceD.size(); i++)
		{
			if(cceD[i].Day_of_Week_vod__c == 'Thursday')
				cceToDisplay.add(cceD[i]);
		}
		
		for(integer i=0; i<cceD.size(); i++)
		{
			if(cceD[i].Day_of_Week_vod__c == 'Friday')
				cceToDisplay.add(cceD[i]);
		}
		

	}
	
	//save button action logic
	public void save()
	{
		string toUserID = c1.User_Relocate__c;
		string query = ' ';
		string andClause = ' ';
		
		if(c1.User_Relocate__c == null)
		{
			responseMessage = selectUser;
			return;
		}
		
		decimal selectedWeek;
		string selectedDay;
		
		if(selectedWeekID == 'all' || selectedWeekID == 'none' || selectedWeekID == null)
			selectedWeek = null;
		else
			selectedWeek = [select Week_vod__c from Call_Cycle_Entry_vod__c where ID =: selectedWeekID limit 1].Week_vod__c;
			
		if(selectedDayID == 'all' || selectedDayID == 'none' || selectedDayID == null)
			selectedDay = null;
		else
			selectedDay  = [select Day_of_Week_vod__c from Call_Cycle_Entry_vod__c where ID =: selectedDayID limit 1].Day_of_Week_vod__c;
		
		system.debug('Selected Week: ' + selectedWeek);
		system.debug('Selected Day: ' + selectedDay);
		system.debug('From User: ' + UserInfo.GetName());
		system.debug('From User: ' + userId);
		system.debug('To User: ' + toUserId);
		
		
		//Week and Day filter handling
		if(selectedWeek != null)
			andClause = andClause + ' AND Week_vod__c = ' + selectedWeek + '';
		
		if(selectedDay != null)
			andClause = andClause + ' AND Day_of_Week_vod__c = \'' + selectedDay + '\'';
			
		system.debug('CCE QUERY: ' + andClause);
			
		
		list<Call_Cycle_Entry_vod__c> cce;
		cceToUpdate = new list<Call_Cycle_Entry_vod__c>();
		cceToDisplay = new list<Call_Cycle_Entry_vod__c>();
		
		cce = database.query('select ID, Name, CreatedBy.Name, Owner.Name, Week_vod__c, Day_of_Week_vod__c from Call_Cycle_Entry_vod__c where OwnerID = : userID ' + andClause );
		//cce = database.query( query + andClause );
		system.debug('CCE RECORDS: ' + cce.size());
		
		integer recordCounter = 0;
		
		//record update
		for(integer i=0; i<cce.size(); i++)
		{
			if(toUserID != cce[i].OwnerID)
			{
				cce[i].OwnerID = toUserID;
				cceToUpdate.add(cce[i]);
				recordCounter = recordCounter + 1;
				system.debug('CCE RECORD: ' + cce[i]);
			}
		}
		
		
		display();
		update cceToUpdate;
		
		
		responseMessage = recordCounter + ' ' + success;
	}

}