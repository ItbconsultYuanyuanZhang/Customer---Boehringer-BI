global with sharing class VEEVA_ApprovedDocumentAccessChecker{
        
    Global Map<Id, Boolean> userHasAccessToApprovedDocuments(Set<Id> documentIds) {
        Map<Id, Boolean> result = new Map<Id, Boolean>();
        Map<Id, Approved_Document_vod__c> docMap = new Map<Id, Approved_Document_vod__c>([select Id, Name from Approved_Document_vod__c where id IN :documentIds]);
        for(Id docId: documentIds){
            result.put(docId, docMap.containsKey(docId));            
        }
        return result;
    }
    
    Global Map<Id, Boolean> userHasAccessToAccounts(Set<Id> accountIds) {
        Map<Id, Boolean> result = new Map<Id, Boolean>();
        Map<Id, Account> accountMap = new Map<Id, Account>([select Id, Name from Account where id IN :accountIds]);
        for(Id accountId: accountIds){
            result.put(accountId, accountMap.containsKey(accountId));            
        }
        return result;
    }


}