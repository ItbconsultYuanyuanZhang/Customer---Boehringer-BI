trigger VEM_REQUIREMENT_BEFORE_UPSERT  on Requirement_vem__c (before insert, before update) {

    Set<Id> userSet = new Set<Id>();
    
    for (Requirement_vem__c req : trigger.new) {
        if (req.Follow_Up_Owner_User__c != null) {
            userSet.add(req.Follow_Up_Owner_User__c);        
        }        
    }
    if (userSet.size()>0){
        List<User> userList = [select Id, Name from User where Id in : userSet];
        for (Requirement_vem__c req : trigger.new) {
            for (User u : userList) {
                if (u.Id == req.Follow_Up_Owner_User__c && u.Name != req.Follow_Up_Owner__c) {
                    req.Follow_Up_Owner__c = u.Name;
                }    
            }
        }
    }
}