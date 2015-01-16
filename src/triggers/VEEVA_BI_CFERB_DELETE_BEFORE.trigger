/* trigger: VEEVA_BI_CFERB_DELETE_BEFORE
 * description: don't allow non-RMs to delete CFERBS created by RMs
 *
 * history:
 *     9/4/2014 - Veeva PS(wa) - initial creation
 */
trigger VEEVA_BI_CFERB_DELETE_BEFORE on CFE_Report_Behavior_BI__c (before delete) {
    Id RMPermSet = [Select Id from PermissionSet where Name = 'CORE_NSM_COACHING_PERMISSION' LIMIT 1].Id;
    List<PermissionSetAssignment> currentUserPSA = [Select Id from PermissionSetAssignment where AssigneeId = :UserInfo.GetUserId() and PermissionSetId = :RMPermSet];
    
    Boolean currentUserIsRM = !(currentUserPSA.IsEmpty());
    
    Set<Id> creatorIdSet = new Set<Id>();
    for(CFE_Report_Behavior_BI__c crb : trigger.old) {
        creatorIdSet.add(crb.CreatedById);
    }
    
    List<PermissionSetAssignment> creatorPSAs = [Select Id, PermissionSetId, AssigneeId from PermissionSetAssignment where AssigneeId = :creatorIdSet and PermissionSetId = :RMPermSet];    
    Map<Id, PermissionSetAssignment> psaMap = new Map<Id, PermissionSetAssignment>();
    
    for(PermissionSetAssignment psa : creatorPSAs) {
        psaMap.put(psa.AssigneeId, psa);
    }
    
    for(CFE_Report_Behavior_BI__c crb : trigger.old) {
        Boolean creatorIsRM = psaMap.get(crb.CreatedById) != null;
        if(currentUserIsRM) {
            //do nothing.  We only want to prevent non-RMs from making changes
            continue;       
        }
        else if(creatorIsRM) {
            crb.AddError('National Sales Manager Coaching Report Cannot Be Deleted');
        }
    }    
}