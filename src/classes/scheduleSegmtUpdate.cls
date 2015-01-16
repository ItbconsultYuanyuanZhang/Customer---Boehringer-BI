global class scheduleSegmtUpdate implements Schedulable{ global void execute(SchedulableContext sc) {
VEEVA_BI_BATCH_SAPD_SEGMENT_UPDATE b = new VEEVA_BI_BATCH_SAPD_SEGMENT_UPDATE(); database.executebatch(b,100);
}}