trigger VEEVA_CONTRACT_LINE_BEFORE on Contract_Line_vod__c (before insert, before delete, before update) {
    Map<Id, Contract_Line_vod__c> modifiedLines = new Map<Id, Contract_Line_vod__c>();
    Set<Id> contractIds = new Set<Id>();

    if(Trigger.old != null) {
        modifiedLines.putAll(Trigger.old);
    }
    if(Trigger.new != null) {
        modifiedLines.putAll(Trigger.new);
    }

    for(Contract_Line_vod__c line : modifiedLines.values()) {
        contractIds.add(line.Contract_vod__c);
    }

    boolean isMultiCurrency = Schema.SObjectType.Contract_Line_vod__c.fields.getMap().containsKey('CurrencyIsoCode');
    String contractParentQuery;
    if(isMultiCurrency) {
        contractParentQuery = 'Select Id, Lock_vod__c, Override_Lock_vod__c, CurrencyIsoCode ' +
                'FROM Contract_vod__c ' +
                'WHERE Id IN :contractIds';
    } else {
        contractParentQuery = 'Select Id, Lock_vod__c, Override_Lock_vod__c ' +
                'FROM Contract_vod__c ' +
                'WHERE Id IN :contractIds';
    }
    Map<Id, Contract_vod__c> contractParents = new Map<Id, Contract_vod__c> (
        (List<Contract_vod__c>) Database.query(contractParentQuery)
    );

    // Locked contract check
    for(Contract_Line_vod__c line : modifiedLines.values()) {
        Contract_Line_vod__c newLine = Trigger.newMap != null ? Trigger.newMap.get(line.Id) : null;
        Contract_Line_vod__c oldLine = Trigger.newMap != null ? Trigger.oldMap.get(line.Id) : null;
        Contract_vod__c contract = contractParents.get(line.Contract_vod__c);

        if(contract.Lock_vod__c && !contract.Override_Lock_vod__c &&
                !((newLine != null && newLine.Override_Lock_vod__c) || (oldLine != null && oldLine.Override_Lock_vod__c))) {
            line.addError('Contract is locked', false);
        } else if(oldLine != null && oldLine.Lock_vod__c && !oldLine.Override_Lock_vod__c &&
                (newLine == null || (newLine.Lock_vod__c && !newLine.Override_Lock_vod__c))) {
            line.addError('Contract Line is locked', false);
        }
    }

    if(Trigger.new != null) {
        List<Contract_Line_vod__c> existingContractLines = [SELECT Product_vod__c, Contract_vod__c
            FROM Contract_Line_vod__c
            WHERE Id NOT IN :modifiedLines.values() AND Contract_vod__r.RecordType.DeveloperName IN ('Sales_vod', 'Listing_vod') AND Contract_vod__c IN :contractIds];
        Map<Id, Set<Id>> contractProductMap = new Map<Id, Set<Id>>();

        for(Contract_Line_vod__c line : existingContractLines) {
            if(!contractProductMap.containsKey(line.Contract_vod__c)) {
                contractProductMap.put(line.Contract_vod__c, new Set<Id>());
            }

            Set<Id> productSet = contractProductMap.get(line.Contract_vod__c);
            productSet.add(line.Product_vod__c);
        }

        Map<Id, Product_vod__c> productIdentifierMap = new Map<Id, Product_vod__c>();
        for(Contract_Line_vod__c line : Trigger.new) {
            // Unique product check for upserts
            if(!contractProductMap.containsKey(line.Contract_vod__c)) {
                contractProductMap.put(line.Contract_vod__c, new Set<Id>());
            }

            Set<Id> productSet = contractProductMap.get(line.Contract_vod__c);
            if(productSet.contains(line.Product_vod__c)) {
                line.addError(VOD_GET_ERROR_MSG.getErrorMsg('CONTRACT_LINE_DUPLICATE_ERROR', 'CONTRACTS'), false);
            } else {
                productSet.add(line.Product_vod__c);
            }

            if(line.Product_vod__c != null) {
                productIdentifierMap.put(line.Product_vod__c, null);
            }

            // Currency handling
            if(isMultiCurrency) {
                Contract_vod__c contract = contractParents.get(line.Contract_vod__c);
                String CurrencyIsoCode = (String) contract.get('CurrencyIsoCode');
                line.put('CurrencyIsoCode', CurrencyIsoCode);
            }
        }

        productIdentifierMap = new Map<Id, Product_vod__c>([SELECT Id, Product_Identifier_vod__c FROM Product_vod__c WHERE Id IN :productIdentifierMap.keySet()]);
        for(Contract_Line_vod__c line : Trigger.new) {
            if(line.Product_vod__c != null) {
                line.Product_Identifier_vod__c = productIdentifierMap.get(line.Product_vod__c).Product_Identifier_vod__c;
            }
        }
    }
}