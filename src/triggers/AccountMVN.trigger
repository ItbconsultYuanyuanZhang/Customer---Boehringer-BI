/*
 * Created By:   Roman Lerman
 * Created Date: 7/13/2012
 * Description:  Generic Account Trigger
 */
trigger AccountMVN on Account (after delete, before delete) {
    new TriggersMVN()
        .bind(TriggersMVN.Evt.beforedelete, new BeforeMergeTriggerMVN())
        .bind(TriggersMVN.Evt.afterdelete, new AccountMergeTriggerMVN())
        .manage();
}