global class scheduleAddressPreferredUpdate implements Schedulable{ global void execute(SchedulableContext sc) {
VEEVA_BI_BATCH_Address_Preferred_flag b = new VEEVA_BI_BATCH_Address_Preferred_flag (); database.executebatch(b,20);
}
}