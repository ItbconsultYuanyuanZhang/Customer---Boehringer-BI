trigger VEEVA_QUESTION_RESPONSE_BEFORE_UPSERT on Question_Response_vod__c (before insert, before update) {
    Set<Id> picklistTypeIds = new Set<Id>();
    Set<Id> textTypeIds = new Set<Id>();
    Id dateTypeId = null;
    Id datetimeTypeId = null;
    Id numberTypeId = null;
    for(RecordType type: [Select Id, DeveloperName FROM RecordType WHERE SObjectType = 'Survey_Question_vod__c']) {
        if(type.DeveloperName.equals('Picklist_vod') || type.DeveloperName.equals('Radio_vod') || type.DeveloperName.equals('Multiselect_vod')) {
            picklistTypeIds.add(type.Id);
        } else if(type.DeveloperName.equals('Text_vod') || type.DeveloperName.equals('Long_Text_vod')) {
            textTypeIds.add(type.Id);
        } else if(type.DeveloperName.equals('Date_vod')) {
            dateTypeId = type.Id;
        } else if(type.DeveloperName.equals('Datetime_vod')) {
            datetimeTypeId = type.Id;
        } else if(type.DeveloperName.equals('Number_vod')) {
            numberTypeId = type.Id;
        }
    }

    for(Question_Response_vod__c response : Trigger.new) {
        response.Score_vod__c = null;

        if(picklistTypeIds.contains(response.Type_vod__c)) {
            if(response.Response_vod__c != null) {
                Long score = 0;
                
                Map<String, String> answerScoreMap = new Map<String, String>();
                String answerChoices = response.Answer_Choice_vod__c;
                String[] answerChoicesSplit = answerChoices.split(';');
                for(Integer i = 0; i < answerChoicesSplit.size()-1;){
                    String answer = answerChoicesSplit[i];
                    String weight = answerChoicesSplit[i+1];
                    answerScoreMap.put(answer,weight);
                    i += 2;
                }
                List<String> hashes = new List<String>();
                for(String chosenResponse : response.Response_vod__c.split(';')) {
                    hashes.add(EncodingUtil.base64encode(Crypto.generateDigest('MD5', (Blob.valueOf(chosenResponse.trim())))));
                    if(answerScoreMap.containsKey(chosenResponse)){
                        score += Long.valueOf(answerScoreMap.get(chosenResponse));
                    }else{
                        system.debug('Invalid response: \'' + chosenResponse + '\', does not match any of the answer choices. This response choice was not counted in Score_vod__c');
                    }
                }
                hashes.sort();
                response.Response_Hash_vod__c = String.join(hashes, '');

                response.Score_vod__c = score;
            } else {
                response.Response_Hash_vod__c = null;
            }
        } else if(textTypeIds.contains(response.Type_vod__c)) {
            if(response.Text_vod__c != null) {
                response.Response_Hash_vod__c = EncodingUtil.base64encode(Crypto.generateDigest('MD5', (Blob.valueOf(response.Text_vod__c))));
            } else {
                response.Response_Hash_vod__c = null;
            }
        } else if (dateTypeId == Id.valueOf(response.Type_vod__c)) {
            if(response.Date_vod__c!= null) {
                response.Response_Hash_vod__c = 'true';
            } else {
                response.Response_Hash_vod__c = null;
            }
        } else if (datetimeTypeId == Id.valueOf(response.Type_vod__c)) {
            if(response.Datetime_vod__c != null) {
                response.Response_Hash_vod__c = 'true';
            } else {
                response.Response_Hash_vod__c = null;
            }
        } else if (numberTypeId == Id.valueOf(response.Type_vod__c)) {
            if(response.Number_vod__c != null) {
                response.Response_Hash_vod__c = 'true';
            } else {
                response.Response_Hash_vod__c = null;
            }
        }
    }
}