/* trigger: VEEVA_BI_CR_DELETE_BEFORe
 * description: don't allow non-RMs to delete Coaching Reports created by RMs
 *
 * history:
 *     9/4/2014 - Veeva PS(wa) - initial creation
 */
trigger VEEVA_BI_DELETE_BEFORE on Coaching_Report_vod__c (before delete) {
    Id RMPermSet = [Select Id from PermissionSet where Name = 'CORE_NSM_COACHING_PERMISSION' LIMIT 1].Id;
    List<PermissionSetAssignment> currentUserPSA = [Select Id from PermissionSetAssignment where AssigneeId = :UserInfo.GetUserId() and PermissionSetId = :RMPermSet];
    
    Boolean currentUserIsRM = !(currentUserPSA.IsEmpty());
    
    Set<Id> creatorIdSet = new Set<Id>();
    for(Coaching_Report_vod__c cr : trigger.old) {
        creatorIdSet.add(cr.CreatedById);
    }
    
    List<PermissionSetAssignment> creatorPSAs = [Select Id, PermissionSetId, AssigneeId from PermissionSetAssignment where AssigneeId = :creatorIdSet and PermissionSetId = :RMPermSet];    
    Map<Id, PermissionSetAssignment> psaMap = new Map<Id, PermissionSetAssignment>();
    
    for(PermissionSetAssignment psa : creatorPSAs) {
        psaMap.put(psa.AssigneeId, psa);
    }
    
    for(Coaching_Report_vod__c cr : trigger.old) {
        Boolean creatorIsRM = psaMap.get(cr.CreatedById) != null;
        if(currentUserIsRM) {
            //do nothing.  We only want to prevent non-RMs from making changes
            continue;       
        }
        else if(creatorIsRM) {
            cr.AddError('National Sales Manager Coaching Report Cannot Be Deleted');
        }
    }
    
    
}