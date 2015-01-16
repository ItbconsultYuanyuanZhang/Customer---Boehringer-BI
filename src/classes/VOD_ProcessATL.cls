public class VOD_ProcessATL {
    
    public static final String ATL_TRACKING_FIELD = 'ATL_Last_Update_Date_Time_vod__c';
    
    public static void processATL(List<Account_Territory_Loader_vod__c> acctLoaders, Set<Id> acctIds) {     

        System.debug(acctIds);
        // If we are doing an update we need to clean out the account share rows. 
        List<AccountShare []> sharesToDel = new List<AccountShare[]>();                               
        for (AccountShare [] shares : [Select Id From AccountShare 
                                           where  AccountId in :acctIds 
                                           AND RowCause  = 'TerritoryManual']) {
            sharesToDel.add(shares);
        }  
        
        for (AccountShare [] shares : sharesToDel) {
            delete shares;
        }
                    
        // collect all territory names
        List<Set<String>> allTerrNames = new List<Set<String>>();
        Set<String> terrNames = new Set<String>();
        for (Account_Territory_Loader_vod__c acc : acctLoaders) {                       
            Set<String> newTerrs = new Set<String>();
            newTerrs.addAll(acc.Territory_vod__c.split(';'));
            newTerrs.remove('');
            
            // add territories to set               
            for (Set<String> iterTerrs : allTerrNames) {
                newTerrs.removeAll(iterTerrs);   
            }
            newTerrs.removeAll(terrNames);
            
            // break up to avoid governor limit
            if (terrNames.size() + newTerrs.size() < 1000) {
                terrNames.addAll(newTerrs);
            }
            else {
                allTerrNames.add(terrNames);
                terrNames = newTerrs;
            } 
        } 
        allTerrNames.add(terrNames);                   
        
        // use territory names to find out Territory and Group records          
        List<Map<Id, Territory>> allTerritories = new List<Map<Id, Territory>>();
        List<Map<String, Territory>> allTerritoryByName = new List<Map<String, Territory>>();
        List<Map<String,Group>> allGroupsByRelated =  new List<Map<String,Group>> ();           
        for (Set<String> names : allTerrNames) {            
            Map<Id,Territory> territories = new Map<Id,Territory> 
                ([Select Id, AccountAccessLevel, CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel,Name From Territory where Name in :names]);
            if (territories.size() == 0)
                continue;                
            allTerritories.add(territories);          
            // Create a Map that is by territory name and not id,  makes it easier to lookup
            Map<String, Territory> territoryByName = new Map<String,Territory> ();                          
            for (Territory terr : territories.values()) {               
               territoryByName.put(terr.Name, terr);   
            }             
            allTerritoryByName.add(territoryByName);                    
                      
            // Grab a list of the groups for the territories that we are using.  
            // We only grab the group ids for 'TerritoryAndSubordinates' so that we can make manual assignements.
            // To grab the "Territory" group would cause a "TerritoryManual" assignment.  If you change this then you need to
            // Change the query on AccountShare for deletes from Manual to TerritroyManual. 
            //Map<Id,Group> groups = new Map<Id,Group>([Select Id, RelatedId from Group where Type = 'TerritoryAndSubordinates' and RelatedId in :territories.keySet()]);
            Map<Id,Group> groups = new Map<Id,Group>([Select Id, RelatedId from Group where Type = 'Territory' and RelatedId in :territories.keySet()]);           
            if (groups.size() == 0) 
                continue;
           
           //Make a map of groups by territory id so that it is easier to lookup     
           Map<String, Group> groupsByRelated =  new Map<String,Group> ();                    
           for (Group grp : groups.values()) {                     
               groupsByRelated.put(grp.RelatedId, grp);
           }                 
           allGroupsByRelated.add(groupsByRelated);
        }
        
        // ready to create AccountShare  
        List <AccountShare> addShares = new List<AccountShare>();       
        for (Account_Territory_Loader_vod__c acc : acctLoaders) {                        
            String [] Territory_Split = acc.Territory_vod__c.split(';');  
            Set<String> uniqueSplits = new Set<String>();
            uniqueSplits.addAll(Territory_Split);
            uniqueSplits.remove('');
            Set<Id> groupIds = new Set<Id>();             
            for (String terrValue : uniqueSplits) {        
                Territory terr = null;
                
                for (Map<String, Territory> territoryByName : AllTerritoryByName) { 
                    terr = territoryByName.get(terrValue);  
                    if (terr != null)
                       break;                         
                }
                               
                // If we cant find the territory that was provieded move to the next entry.
                if (terr == null) {
                    System.debug ('Territory not found for = ' + terrValue);    
                    continue;
                }
                
                Group grp = null;
                for (Map<String,Group> groupsByRelated : allGroupsByRelated) {
                    grp = groupsByRelated.get(terr.Id);
                    if (grp != null)
                       break;
                }                       
                
                // If in the unlikely event we don't find a group. Move to the next 
                if (grp == null) {
                    System.debug ('Group not found for = '+ terrValue + '/' + terr.Id);
                    continue;   
                }
                
                if (groupIds.contains(grp.Id)) 
                    continue;
                
                groupIds.add(grp.Id);
                
                //Since we are creating a manual assignment we read the important AccountShare settings
                //off the territory and assign them to the new row.
                AccountShare accShare = new AccountShare (  UserOrGroupId = grp.Id,
                                                        //  AccountAccessLevel = terr.AccountAccessLevel, 
                                                        //  CaseAccessLevel = terr.CaseAccessLevel, 
                                                        //  OpportunityAccessLevel = terr.OpportunityAccessLevel,
                                                            AccountId = acc.Account_vod__c);
                System.debug ('Adding AccountShare grpId:' + grp.Id + ', acctId:' + acc.Account_vod__c);
                addShares.add(accShare);  
                if (addShares.size() == 1000) {
                    insert addShares; 
                    addShares.clear();
                }                    
            }
        }
        
        // If we have new rows,  then perform the insert.
        if (addShares.size () > 0) {
            insert addShares;
        }
        updateAccountATLTracking(acctIds); 
    }
    
    public static boolean haveAccountATLTracking() {
        Map<String, Schema.SObjectField> fieldMap = Schema.sObjectType.Account.fields.getMap();
        Schema.SObjectField trackingField = fieldMap.get(ATL_TRACKING_FIELD);
        Veeva_Settings_vod__c settings = Veeva_Settings_vod__c.getInstance();
        
        return trackingField != null && trackingField.getDescribe().getType() == Schema.DisplayType.DateTime && settings.ATL_LAST_UPDATE_TRACKING_vod__c;
    }
    
    public static void updateAccountATLTracking(Set<Id> acctIds) {
        if (acctIds != null && acctIds.size() > 0 && haveAccountATLTracking()) {
            DateTime now = Datetime.now();
            List<Account> accounts = new List<Account>();
            for (Id acctId : acctIds) {
                Account acct = new Account(Id=acctId);
                acct.put(ATL_TRACKING_FIELD, now);
                accounts.add(acct);
            }
            update accounts;
        }
    }   
}