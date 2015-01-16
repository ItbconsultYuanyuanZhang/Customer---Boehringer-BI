global class schedule_BI_ABM_COACHING_BATCH implements Schedulable 
{	
	global void execute(SchedulableContext sc) 
	{	
		VEEVA_BI_ABM_COACHING_BATCH b = new VEEVA_BI_ABM_COACHING_BATCH(); 
		database.executebatch(b,100); 
	}

}