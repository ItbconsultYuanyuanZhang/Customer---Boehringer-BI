global class VEEVA_BI_scheduleCallCals implements Schedulable{ global void execute(SchedulableContext sc) {

	VEEVA_BI_BATCH_CYCLE_PLAN_CALC b = new VEEVA_BI_BATCH_CYCLE_PLAN_CALC(); database.executebatch(b,100);
	VEEVA_BI_BATCH_CYCLE_PLAN_CALC_CALLS c = new VEEVA_BI_BATCH_CYCLE_PLAN_CALC_CALLS (); database.executebatch(c,100);

}}