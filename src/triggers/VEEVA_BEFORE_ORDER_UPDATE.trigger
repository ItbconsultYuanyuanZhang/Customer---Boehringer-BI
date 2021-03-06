trigger VEEVA_BEFORE_ORDER_UPDATE on Order_vod__c (before update) {
    String ProfileId = UserInfo.getProfileId();
    VOD_ERROR_MSG_BUNDLE bundle = new VOD_ERROR_MSG_BUNDLE();
    Profile pr = [Select Id, PermissionsModifyAllData From Profile where Id = :ProfileId];
    boolean modAllData = false;
    if (pr != null && pr.PermissionsModifyAllData) {
        modAllData = true;
    }

    Set<Id> acctIDs = new Set<Id>();

    for (Order_vod__c orderNew : Trigger.new) {
        acctIds.add(orderNew.Account_vod__c);
        acctIds.add(orderNew.Entity_Reference_Id_vod__c);
    }

    Map<Id, Account> acctMap = new Map<id, Account>([SELECT Name FROM Account WHERE Id IN :acctIds]);


    for (Integer i = 0; i <Trigger.new.size(); i++) {
        Order_vod__c orderNew = Trigger.new[i];

        Order_vod__c orderOld = Trigger.old[i];

        if (orderNew.Lock_vod__c == true && modAllData != true) {
            if (!orderNew.Override_Lock_vod__c)
                orderNew.Id.addError(System.Label.NO_MODIFY_ORDER, false);
        }
        if (orderNew.Override_Lock_vod__c)
            orderNew.Override_Lock_vod__c = false;

        if (orderOld.Lock_vod__c == true && orderNew.Lock_vod__c == false) {
           orderNew.Status_vod__c = 'Saved_vod';
        }

        if (orderOld.Status_vod__c != 'Submitted_vod' &&orderNew.Status_vod__c == 'Submitted_vod') {
           orderNew.Lock_vod__c = true;
        }

        // a super user (a user who has PermissionsModifyAllData) is allowed to update a locked record
        if (orderOld.Status_vod__c == 'Submitted_vod' && orderNew.Status_vod__c == 'Submitted_vod') {
            continue;
        } else{
            if(orderNew.Account_vod__c != null){
                orderNew.Account_ID_vod__c = orderNew.Account_vod__c;
                orderNew.Account_Name_vod__c = acctMap.get(orderNew.Account_vod__c).Name;
            }
        }
    }
}