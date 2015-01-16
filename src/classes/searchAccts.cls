public class searchAccts {

    private User currentUser;
    
    public List<resultHeader> resultHeaders {set;get;}

    public String wc {get;set;}

    public List <searchField> acctSearchFields {set;get;}
    public List <searchField> addrSearchFields {set;get;}

    private List<String> acctSearchFieldSet  ;
    private List<String> addrSearchFieldSet  ;

    private List<String> resultFieldSet  ;
    private Set <String> acctResultFields = new Set<String> () ;
    private Set <String> addrResultFields = new Set<String> () ;


    private Map<String, Schema.SObjectField> acctFieldMap ;
    private Map<String, Schema.SObjectField> addrFieldMap ;

    public Map <String,String> resFieldTypeMap = new Map <String,String> () ;
    private Map <String,String> resFieldLabelMap = new Map <String,String> () ;

    public static List<SelectOption> acctRecTypesPlist ;
    public static List<SelectOption> addrRecTypesPlist ;
    private Map <String,String> recTypeXlation = new Map <String,String> () ;

    public String parentSearch {set;get;}
    public String parentAcctField {set;get;}
    public String returnElemId {set;get;}

    public Boolean showAllAddrs {set;get;}

    public searchResult [] results {get;set;}

    public String sortKey {get;set;}
    public String sortDir {get;set;}

    // Custom Labels
    public String GAS_CANCEL {set;get;}
    public String GAS_SEARCH {set;get;}
    public String GAS_LOOKUP {set;get;}
    public String GAS_SFA {set;get;}
    public String GAS_SFPA {set;get;}
    public String GAS_EM {set;get;}
    public String GAS_SW {set;get;}
    public String GAS_CONTAINS {set;get;}
    public static String GAS_NONE {set;get;}
    public String GAS_RESULTS {set;get;}
    public String GAS_ATT {set;get;}
    public String GAS_NOCRIT {set;get;}
    public String GAS_NAMESEARCH {set;get;}
    public String GAS_NOMATCH {set;get;}
    public String GAS_TOOMANY {set;get;}
    public String GAS_NOTALGN {set;get;}
    public String GAS_MANYALGN {set;get;}
    public String GAS_INTERR {set;get;}
    public String GAS_SUCCESS {set;get;}
    public String GAS_SELECT {set;get;}
    public String GAS_CLEAR {set;get;}


    //2013.08.19. Multi territiry handling
        public Boolean ShowHide {get; set;}   
        public string UTerrs {get; set;}    
        public integer STMT {get; set;}
        public boolean isMulti {get; set;}
     
        /************************************
        Collect User Territory
        ************************************/    
        public List<SelectOption> getItems() 
        {
            
            List<SelectOption> options = new List<SelectOption>();
            
            
            
            List<UserTerritory> utList = [select TerritoryId from userterritory 
                                         where UserId = :UserInfo.getUserId()] ;

            if(utList.size() > 1)
            {
               options.add(new SelectOption('none','none')); //2012.11.05.
               STMT = utList.size();  
               isMulti = true;
            }
            
            for (UserTerritory UT :utList )
            {
             String stemp = [select Name from Territory where Id = :UT.TerritoryId].Name ; 
             options.add(new SelectOption(stemp.trim(),stemp.trim()));   
            }   
            
            //if there is ony  1 territory  select it by default
            if(options.size() == 1 && (UTerrs == NULL || UTerrs == ''))
            {
               UTerrs =  options[0].getValue();  
               STMT = 1;
               //isMulti = false;
            }                   
           
           return options;      
                
        } 
    
    /************************************************************
    
    ************************************************************/    
    private String checkIfAlreadyAssigned(List <Territory> TList)
    {
        string retval;
        
        for (Territory t : TList)
        {
            if(UTerrs.contains('[') == true)
            {
                String uterru = UTerrs.substring(1, UTerrs.length() - 1);
                string[]  TERRs = uterru.split(',');
                for(String s :TERRs)
                {
                    system.debug('Terr: ' + t.Name + ' uterru: ' + s);
                    if(t.Name == s.trim())
                    {
                      if(retval != NULL)    
                      retval = retval + ',' + s.trim(); 
                      else
                      retval = s.trim();
                      
                    }
                }
            }
            else
            {
            if(t.Name == UTerrs)
               return UTerrs;   
            }
            
        }
        
        return retval;
    }
    
    /*********************************
    remove [  and ]  and replace ',' 
    with ';'
    *********************************/
    private String ConvertTerrFormat()  
    {
        if(UTerrs.startsWith('[') == true)
        {
        system.Debug('CSABA: unformatter terrs: ' + UTerrs);
        String uterru = UTerrs.substring(1, UTerrs.length() - 1);
        system.Debug('CSABA: formatter terrs 1: ' + uterru);
        uterru = uterru.replaceAll(',', ';');
        system.Debug('CSABA: formatter terrs 2: ' + uterru); 
        
        uterru = uterru.replace(', ', ',');
        system.Debug('CSABA: formatter terrs 3: ' + uterru);  
        return uterru;      
        }
        

        return UTerrs;
    }
                    
    //2013.08.19. Multi territory handling  

    // Constructor
    public searchAccts () 
    {

        getItems();  //2013.08.19.
        
        results = new List<searchResult> () ;
        parentSearch = ApexPages.currentPage().getParameters().get('parentSearch');
        parentAcctField = ApexPages.currentPage().getParameters().get('parentAcctField');
        returnElemId = ApexPages.currentPage().getParameters().get('returnElemId');
        String lang = UserInfo.getLanguage() ;
        //get user specific labels
        Message_vod__c [] labels = [select Name,Text_vod__c from Message_vod__c where Language_vod__c = :lang and Category_vod__c = 'Account' and Name in ('GAS_CANCEL','GAS_SEARCH','GAS_LOOKUP','GAS_SFA','GAS_EM','GAS_SW','GAS_CONTAINS','GAS_NONE','GAS_RESULTS','GAS_ATT','GAS_NOCRIT','GAS_NAMESEARCH','GAS_NOMATCH','GAS_TOOMANY','GAS_NOTALGN','GAS_MANYALGN','GAS_INTERR','GAS_SUCCESS', 'GAS_SELECT','GAS_SFPA','GAS_CLEAR') and Active_vod__c = true] ;
        Map <String,String> labelMap = new Map <String,String> () ;
        
        for (Message_vod__c label : labels) 
        {
            labelMap.put(label.Name, label.Text_vod__c) ;
        }
        
        //get en_US labelmap -2013.06.19 Viktor
        Map <String,String> labelMapEn = new Map <String,String> () ;
        
        for (Message_vod__c label : [select Name,Text_vod__c from Message_vod__c where Language_vod__c = 'en_US' and Category_vod__c = 'Account' and Name in ('GAS_CANCEL','GAS_SEARCH','GAS_LOOKUP','GAS_SFA','GAS_EM','GAS_SW','GAS_CONTAINS','GAS_NONE','GAS_RESULTS','GAS_ATT','GAS_NOCRIT','GAS_NAMESEARCH','GAS_NOMATCH','GAS_TOOMANY','GAS_NOTALGN','GAS_MANYALGN','GAS_INTERR','GAS_SUCCESS', 'GAS_SELECT','GAS_SFPA','GAS_CLEAR') and Active_vod__c = true]) 
        {
            labelMapEn.put(label.Name, label.Text_vod__c) ;
        }
        
        currentUser = [ select Id, Country_Code_BI__c from User where id = :UserInfo.getUserId() ]; 
        //get en_US labels from Message_vod__c if user's language is not provided -2013.06.19 Viktor
        GAS_CANCEL = labelMap.get('GAS_CANCEL') != null ? labelMap.get('GAS_CANCEL') : labelMapEn.get('GAS_CANCEL');
        GAS_SEARCH = labelMap.get('GAS_SEARCH') != null ? labelMap.get('GAS_SEARCH') : labelMapEn.get('GAS_SEARCH');
        GAS_LOOKUP = labelMap.get('GAS_LOOKUP') != null ? labelMap.get('GAS_LOOKUP') : labelMapEn.get('GAS_LOOKUP');
        GAS_SFA = labelMap.get('GAS_SFA') != null ? labelMap.get('GAS_SFA') : labelMapEn.get('GAS_SFA');
        GAS_SFPA = labelMap.get('GAS_SFPA') != null ? labelMap.get('GAS_SFPA') : labelMapEn.get('GAS_SFPA');
        GAS_EM = labelMap.get('GAS_EM') != null ? labelMap.get('GAS_EM') : labelMapEn.get('GAS_EM');
        GAS_SW = labelMap.get('GAS_SW') != null ? labelMap.get('GAS_SW') : labelMapEn.get('GAS_SW');
        GAS_CONTAINS = labelMap.get('GAS_CONTAINS') != null ? labelMap.get('GAS_CONTAINS') : labelMapEn.get('GAS_CONTAINS');
        GAS_NONE = labelMap.get('GAS_NONE') != null ? labelMap.get('GAS_NONE') : labelMapEn.get('GAS_NONE');
        GAS_RESULTS = labelMap.get('GAS_RESULTS') != null ? labelMap.get('GAS_RESULTS') : labelMapEn.get('GAS_RESULTS');
        GAS_ATT = labelMap.get('GAS_ATT') != null ? labelMap.get('GAS_ATT') : labelMapEn.get('GAS_ATT');
        GAS_NOCRIT = labelMap.get('GAS_NOCRIT') != null ? labelMap.get('GAS_NOCRIT') : labelMapEn.get('GAS_NOCRIT');
        GAS_NAMESEARCH = labelMap.get('GAS_NAMESEARCH') != null ? labelMap.get('GAS_NAMESEARCH') : labelMapEn.get('GAS_NAMESEARCH');
        GAS_NOMATCH = labelMap.get('GAS_NOMATCH') != null ? labelMap.get('GAS_NOMATCH') : labelMapEn.get('GAS_NOMATCH');
        GAS_TOOMANY = labelMap.get('GAS_TOOMANY') != null ? labelMap.get('GAS_TOOMANY') : labelMapEn.get('GAS_TOOMANY');
        GAS_NOTALGN = labelMap.get('GAS_NOTALGN') != null ? labelMap.get('GAS_NOTALGN') : labelMapEn.get('GAS_NOTALGN');
        GAS_MANYALGN = labelMap.get('GAS_MANYALGN') != null ? labelMap.get('GAS_MANYALGN') : labelMapEn.get('GAS_MANYALGN');
        GAS_INTERR = labelMap.get('GAS_INTERR') != null ? labelMap.get('GAS_INTERR') : labelMapEn.get('GAS_INTERR');
        GAS_SUCCESS = labelMap.get('GAS_SUCCESS') != null ? labelMap.get('GAS_SUCCESS') : labelMapEn.get('GAS_SUCCESS');
        GAS_SELECT = labelMap.get('GAS_SELECT') != null ? labelMap.get('GAS_SELECT') : labelMapEn.get('GAS_SELECT');
        GAS_CLEAR = labelMap.get('GAS_CLEAR') != null ? labelMap.get('GAS_CLEAR') : labelMapEn.get('GAS_CLEAR');
        
        //CSABA 2012.05.15. handle situation when the Veeva Messaages are missing
        if (GAS_CLEAR == null || GAS_SELECT == null || GAS_SUCCESS == null || GAS_INTERR == null || GAS_MANYALGN == null ||
           GAS_NOTALGN == null || GAS_TOOMANY == null || GAS_NOMATCH == null || GAS_NAMESEARCH == null || GAS_NOCRIT == null |
           GAS_ATT == null || GAS_RESULTS == null || GAS_NONE == null | GAS_CONTAINS == null || GAS_SW == null ||
           GAS_EM == null || GAS_SFPA == null || GAS_SFA == null || GAS_LOOKUP == null || GAS_SEARCH == null || GAS_CANCEL == null)
        {   
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Language dependent Veeva Messages are missing'));
        return;
        }
        //CSABA 2012.05.15. handle situation when the Veeva Messaages are missing

        // Get Record Types for Accounts and Addresses
        // We need to use the translation table, and also filter by sObjectType
        acctRecTypesPlist = new List<SelectOption> () ;
        acctRecTypesPlist.add(new SelectOption('',GAS_NONE)) ;
       
        
        for (RecordTypeLocalization rtl : [select ParentId, Parent.Name, Value from RecordTypeLocalization where ParentId in (select Id FROM RecordType where SobjectType = 'Account' and IsActive = true) and Language = :lang order by Value]) {
            acctRecTypesPlist.add(new SelectOption(rtl.ParentId,rtl.Value));
            recTypeXlation.put (rtl.Parent.Name, rtl.Value) ;
        }
        
        
        // Also need to pick up those Record Types not in RecordTypeLocalization
        for (RecordType rt :[select Id,Name from RecordType where SobjectType = 'Account' and IsActive = true and Id not in (select ParentId FROM RecordTypeLocalization where Language = :lang)]) {
            acctRecTypesPlist.add(new SelectOption(rt.Id,rt.Name));
            recTypeXlation.put (rt.Name, rt.Name) ;
        }

                    
        acctRecTypesPlist = SortOptionList(acctRecTypesPlist) ;
        // Address Record Types
        addrRecTypesPlist = new List<SelectOption> () ;
        addrRecTypesPlist.add(new SelectOption('',GAS_NONE)) ;
        for (RecordTypeLocalization rtl : [select ParentId, Parent.Name, Value from RecordTypeLocalization where ParentId in (select Id FROM RecordType where SobjectType = 'Address_vod__c' and IsActive = true) and Language = :lang order by Value]) {
            addrRecTypesPlist.add(new SelectOption(rtl.ParentId,rtl.Value));
            recTypeXlation.put (rtl.Parent.Name, rtl.Value) ;
        }
        
        // Also need to pick up those Record Types not in RecordTypeLocalization
        for (RecordType rt :[select Id,Name from RecordType where SobjectType = 'Address_vod__c' and IsActive = true and Id not in (select ParentId FROM RecordTypeLocalization where Language = :lang)]) {
            addrRecTypesPlist.add(new SelectOption(rt.Id,rt.Name));
            recTypeXlation.put (rt.Name, rt.Name) ;
        }
        addrRecTypesPlist = SortOptionList(addrRecTypesPlist) ;




        // Get values of custom settings   
        // GASSettingsGlobal__c gas = [select Account_Search_Field_Set__c,Address_Search_Field_Set__c,Result_Field_Set__c,Show_All_Addresses__c from GASSettingsGlobal__c where name = 'Main'] ;
        GASSettingsGlobal__c gas = GASSettingsGlobal__c.getInstance(UserInfo.getProfileId());
        System.debug('gas found: '+gas);
        acctSearchFieldSet = gas.Account_Search_Field_Set__c.split(',') ;
        addrSearchFieldSet = gas.Address_Search_Field_Set__c.split(',') ;
        resultFieldSet = gas.Result_Field_Set__c.split(',') ;
        showAllAddrs = gas.Show_All_Addresses__c ;
        // Set up search fields
        acctSearchFields = new List <searchField> () ;
        acctFieldMap = Schema.SObjectType.Account.fields.getMap();
        for (String f : acctSearchFieldSet) {
            try{
                Schema.DescribeFieldResult  dfr = acctFieldMap.get(f).getDescribe() ;
                acctSearchFields.add (new searchField('Account',dfr)) ;
            }catch(Exception e){
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'Custom setting account field is incorrect: ' + f));
            }
            
        }
        addrSearchFields = new List <searchField> () ;
        addrFieldMap = Schema.SObjectType.Address_vod__c.fields.getMap();
        for (String f : addrSearchFieldSet) {
            try{
                Schema.DescribeFieldResult  dfr = addrFieldMap.get(f).getDescribe() ;
                addrSearchFields.add (new searchField('Address_vod__c',dfr)) ;
            }catch(Exception e){
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'Custom setting address field is incorrect: ' + f));
            }
        }
        // Parse resultFieldSet to get result Account and Address fields
        acctResultFields = new Set<String> () ;
        addrResultFields = new Set<String> () ;
        resultHeaders = new List<resultHeader> () ;
        sortKey = '' ;
        sortDir = 'A' ;
        for (String rf : resultFieldSet) {
            try{
                if (sortKey == '') {
                    // Set sortKey to first result field in list
                    sortKey = rf; 
                }
                if (rf.startsWith('ADD.')) {
                    String dataType = addrFieldMap.get(rf.replace('ADD.', '')).getDescribe().getType().name() ;
                    resFieldTypeMap.put (rf, dataType) ;
                    String label = addrFieldMap.get(rf.replace('ADD.', '')).getDescribe().getLabel() ;
                    if (dataType == 'Reference') {
                        // We need to add Relationship.Name to acctResultFields
                        String rel = addrFieldMap.get(rf.replace('ADD.', '')).getDescribe().getRelationshipName() ;
                        addrResultFields.add(rel + '.Name') ;
                        // Remove trailing ' ID' from label
                        label = label.replaceFirst(' ID$', '') ;
                    }
                    resFieldLabelMap.put (rf, label) ;
                    addrResultFields.add (rf.replace('ADD.', '')) ;
                    resultHeader rh = new resultHeader () ;
                    rh.label = label ;
                    rh.apiname = rf ;
                    resultHeaders.add (rh) ;
                }
                else {
                    String dataType = acctFieldMap.get(rf).getDescribe().getType().name() ;
                    resFieldTypeMap.put (rf, dataType) ;
                    String label = acctFieldMap.get(rf).getDescribe().getLabel() ;
                    if (dataType == 'Reference') {
                        // We need to add Relationship.Name to acctResultFields
                        String rel = acctFieldMap.get(rf).getDescribe().getRelationshipName() ;
                        acctResultFields.add(rel + '.Name') ;
                        // Remove trailing ' ID' from label
                        label = label.replaceFirst(' ID$', '') ;
                    }
                    resFieldLabelMap.put (rf, label) ;
                    acctResultFields.add (rf) ;
                    resultHeader rh = new resultHeader () ;
                    rh.label = label ;
                    rh.apiname = rf ;
                    resultHeaders.add (rh) ;
                }
            }catch(Exception e){
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'Custom setting result field is incorrect: ' + rf));
            }
        }
        // Add the fields which we always need for Account and Address
        acctResultFields.add('Id') ;
        acctResultFields.add('FirstName') ;
        acctResultFields.add('LastName') ;
        acctResultFields.add('Name') ;
        acctResultFields.add('IsPersonAccount') ;
        addrResultFields.add('Id') ;
        addrResultFields.add('Account_vod__c') ;
        addrResultFields.add('Primary_vod__c') ;
    }

    public PageReference sortResults() {
        String newSortKey = ApexPages.currentPage().getParameters().get('sortKey');
        if (newSortKey == sortKey) {
            // Just change sortDir
            if (sortDir == 'A') {
                sortDir = 'D' ;
            }
            else {
                sortDir = 'A' ;
            }
        }
        else {
            sortKey = newSortKey ;
            sortDir = 'A' ;
        }
        results = SortSearchResults(results, sortKey, sortDir) ;
        return null ;
    }
    

    public PageReference search() {

        try {
            
            results = new List<searchResult> () ;
            Set <Id> gotAccts = new Set<Id> ();
            List <String> acctIds = new List <String> () ;
            String whereClause = '' ;
            Boolean searchAddrFirst = false ;
            String prefix = '' ;
            // Determine if user has enetered any values for address search fields
            for (searchField sf : addrSearchFields) {
                if (sf.value != '' && sf.value != 'null' && sf.value != null) {
                searchAddrFirst = true  ;
                prefix = 'Account_vod__r.' ;
                    break ;
                }
            } 
            
            //Viktor - 2013.06.05 - Add and removed a notification that the search have started
            //ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.Info, 'Searching...'));
            
            // Boolean got_csz = false; // Got City, State or Zip
            // Boolean got_noncsz = false; // Other than City, State or Zip
            Boolean got_pname = false; // Got person name
            Boolean got_name = false; // Got full name
            
            
            // Combine the search fields
            List <searchField> allSearchFields = new List <searchField> () ;
            allSearchFields.addAll(acctSearchFields) ;
            allSearchFields.addAll(addrSearchFields) ;

            // Go thru each search field
            for (searchField sf : allSearchFields) {
                if (sf.value != '' && sf.value != 'null' && sf.value != null) {
                    String field = sf.apiname ;
                    String op = '=' ;
                    String value = sf.value ;
                    // Escape any quotes in the value
                    value = value.replace('\'', '\\\'') ;

                    if (sf.obj == 'Account') {
                        field = prefix + field ;
                    }

                    if (sf.opt_value == 'Starts With') {
                        op = 'like' ;
                        value = value + '%' ;
                    }
                    if (sf.opt_value == 'Contains') {
                        op = 'like' ;
                        value = '%' + value + '%' ;
                    }

                    if (sf.is_phone) {
                        op = 'like' ;
                        value = getPhoneRegex(value) ;
                    }
                    
                    // Put quotes around val for relevant types
                    if(!sf.no_quote) {
                        value = '\'' + value + '\'' ;
                    }
                    if (whereClause != '') {
                        whereClause += ' AND ' ;
                    }
                    whereClause += ' ' + field + ' ' + op + ' ' + value;

                    if (sf.obj == 'Account') {
                        if (sf.apiname == 'Name') {
                            got_name = true ;
                        }
                        if (sf.apiname == 'FirstName' || sf.apiname == 'LastName') {
                            got_pname = true ;
                        }
                    }
                }
            }
            wc = whereClause ;
            if (whereClause == '') {
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, GAS_NOCRIT));
                return null ;
            }
            if (got_pname == true && got_name == true) {
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, GAS_NAMESEARCH));
                return null ;
            }
            // if (got_csz == true && got_noncsz == false) {
                // ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'When enterting city, state or zip, at least one other search criteria must be provided'));
                // return null ;
            // }
            if (searchAddrFirst) {
                for (Address_vod__c ad : Database.query('select Account_vod__c, Account_vod__r.IsPersonAccount from Address_vod__c where ' + whereClause)) {
                        acctIds.add(ad.Account_vod__c) ;
                }
            }
            else {
                String resFields = join(acctResultFields,',') ;
                // Add Formatted_Name_vod__c if it's not there
                if (!resFields.contains('Formatted_Name_vod__c')) {
                    resFields += ',Formatted_Name_vod__c' ;
                }
                String query = 'select Id,IsPersonAccount from Account where ' + whereClause;
                if (!String.isBlank(currentUser.Country_Code_BI__c)) {
                    if (currentUser.Country_Code_BI__c == 'UK' || currentUser.Country_Code_BI__c == 'GB' || currentUser.Country_Code_BI__c == 'IE' ) {
                		query += ' AND Country_Code_BI__c IN (\'GB\', \'UK\', \'IE\')';
                    } else if (currentUser.Country_Code_BI__c == 'DK'){
                        query += ' AND Country_Code_BI__c IN (\'DK\', \'FO\', \'GL\')';
                    } else {
                        query += ' AND Country_Code_BI__c = \'' + currentUser.Country_Code_BI__c + '\' ';
                    }
                }
                query += ' order by Name,Id';
                for (Account a : Database.query(query)) {
                        acctIds.add(a.Id) ;
                }
            }
wc = 'at 1' ;
            // Error if nothing found
            if (acctIds.size() == 0) {
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, GAS_NOMATCH));
                return null;
            }
            // If this is a search for parent, remove the account IDs we have found which are not parents.  We can do this
            // by using a GROUP BY clause which counts child accounts per parent.  This query will not return those Accounts
            // which have no child accounts.  Since we can't have more than 1000 elements in :acctIds, error out if we have more than 1000
            if (parentSearch == '1' && acctIds.size() > 1000) {
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, GAS_TOOMANY));
                return null;
            }
            Set <String> distinctAcctIds = new Set<String>() ;
System.debug ('parentSearch is ' + parentSearch) ;
            if (parentSearch == '1') {
                String query = 'select ' + parentAcctField + ', Count(Id) from Account where Primary_Parent_vod__c  in :acctIds group by ' + parentAcctField + '' ;
                AggregateResult[] groupedResults = database.query(query);
                for (AggregateResult ar : groupedResults)  {
                    System.debug('Primary_Parent_vod__c ID' + ar.get('Primary_Parent_vod__c'));
                    distinctAcctIds.add((String)ar.get('Primary_Parent_vod__c')) ;
                }
            }
            else {
                distinctAcctIds.addAll(acctIds) ;
            }
            // Maximum of 20 distinct Accounts
            if (distinctAcctIds.size() > 50) {
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, GAS_TOOMANY));
                return null;
            }

            // We now do a Parent to Child query to get the Accounts we want, along with their addresses.  Order addresses by Primary Address
            String resFields = join(acctResultFields,',') ;
            // Add Formatted_Name_vod__c if it's not there
            if (!resFields.contains('Formatted_Name_vod__c')) {
                resFields += ',Formatted_Name_vod__c' ;
            }
            String q = 'select ' + resFields + ', (select ' + join(addrResultFields,',') + ' from Address_vod__r order by Primary_vod__c desc, CreatedDate) from Account where Id in :acctIds' ;


            for (Account a : Database.query(q)) {
                searchResult mainSR ;
                Integer ix = 0 ;
                if (a.Address_vod__r.size() > 0) {
                    for (Address_vod__c ad : a.Address_vod__r) {
                        // Build the searchResults
                        searchResult sr = new searchResult () ;
                        sr.acctId = a.Id ;
                        sr.addrId = a.Address_vod__r[ix].Id ;
                        sr.isSelected = false ;
                        // Now get field values 
                        sr.srFields = new List<searchResultField> () ;
                        for (String rf : resultFieldSet) {
                            searchResultField srf = new searchResultField () ;
                            srf.apiname = rf ;
                            String typex  = resFieldTypeMap.get(rf) ;
                            if (rf.startsWith('ADD.')) {
                                srf.value = getObjValue(a.Address_vod__r[ix], rf, typex) ;
                                srf.label = resFieldLabelMap.get(rf) ;
                                srf.is_Addr = true ;
                                srf.is_Acct = false ;
                            }
                            else {
                                srf.value = getObjValue(a, rf, typex) ;
                                srf.label = resFieldLabelMap.get(rf) ;
                                // Use Formatted_Name_vod__c for Name
                                if (rf == 'Name') {
                                    srf.value = getObjValue(a, 'Formatted_Name_vod__c', 'String') ;
                                }
                                srf.is_Addr = false ;
                                srf.is_Acct = true ;
                            }
                            // The rawvalue of the srf will be used for sorting
                            srf.rawvalue = srf.value ;
                            if ((typex == 'Date' || typex == 'Datetime') && srf.value != '') {
                                // For sorting purposes, store rawvalue of Date/Datetime as seconds since epoch
                                String dtval = srf.value ;
                                if (typex == 'Date') {
                                    dtval = Datetime.newInstance(Date.parse(srf.value), Time.newInstance(0, 0, 0, 0)).format() ;
                                }
                                srf.rawvalue = (String) Datetime.parse(dtval).getTime().format() ;
                            }
                            sr.srFields.add(srf) ;
                        }
                        sr.acctName = a.Name ;
                        if (ix == 0) {
                            sr.otherAddrs = new List<SearchResult> () ;
                            mainSR = sr ;
                            results.add(mainSR) ;
                        }
                        else {
                            mainSR.otherAddrs.add(sr) ;
                        }
                        ix++ ;
                        // If we are not showing all addresses, and we are done with the first, then break out of loop
                        if (!showAllAddrs) {
                            break ;
                        }
                    }
                }
                else {
                    // No address, just get and set Account info
                    searchResult sr = new searchResult () ;
                    sr.acctId = a.Id ;
                    sr.addrId = '' ;
                    sr.isSelected = false ;
                    // Now get field values 
                    sr.srFields = new List<searchResultField> () ;
                    for (String rf : resultFieldSet) {
                        searchResultField srf = new searchResultField () ;
                        srf.apiname = rf ;
                        String typex  = resFieldTypeMap.get(rf) ;
                        if (rf.startsWith('ADD.')) {
                            srf.value = '' ;
                            srf.label = resFieldLabelMap.get(rf) ;
                            srf.is_Addr = true ;
                            srf.is_Acct = false ;
                        }
                        else {
                            srf.value = getObjValue(a, rf, typex) ;
                            srf.label = resFieldLabelMap.get(rf) ;
                            // Use Formatted_Name_vod__c for Name
                            if (rf == 'Name') {
                                srf.value = getObjValue(a, 'Formatted_Name_vod__c', 'String') ;
                            }
                            srf.is_Addr = false ;
                            srf.is_Acct = true ;
                        }
                        // The rawvalue of the srf will be used for sorting
                        srf.rawvalue = srf.value ;
                        if ((typex == 'Date' || typex == 'Datetime') && srf.value != '') {
                            // For sorting purposes, store rawvalue of Date/Datetime as seconds since epoch
                            String dtval = srf.value ;
                            if (typex == 'Date') {
                                dtval = Datetime.newInstance(Date.parse(srf.value), Time.newInstance(0, 0, 0, 0)).format() ;
                            }
                            srf.rawvalue = (String) Datetime.parse(dtval).getTime().format() ;
                        }
                        sr.srFields.add(srf) ;
                    }
                    sr.acctName = a.Name ;
                    sr.otherAddrs = new List<SearchResult> () ;
                    mainSR = sr ;
                    results.add(mainSR) ;
                }
            }
            // Sort.  Initial sort is by first result field, which has already been set in constructor
            results = SortSearchResults(results, sortKey, sortDir) ;

        }
        catch (Exception ex) 
        {
            ApexPages.addMessages(ex);
        }
         
        return null;
    }


    /************************************
    2013.08.16. add suport for multiple
    territiry alignment           Csaba
    ************************************/
    public PageReference addToTerritory() 
    {
        
        //2013.08.19.
        String newTerru = UTerrs; 
              

        if (newTerru == '[none]' || newTerru == '[]' || newTerru == 'none')
        {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Select at least 1 territory!'));
        return null ;           
        }
        else
        {
            if(newTerru == NULL)
            {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GAS_NOTALGN));
            return null ;               
            }
            
        }
        //2013.08.19.
        
        String newAcctId  = '';
        if (results == null || results.size() == 0) 
        {
            return null ;
        }
        // Find the selected Account
        for (searchResult sr : results) 
        {
            if (sr.isSelected == true) 
            {
                newAcctId = sr.acctId ;
                break ;
            }
        }
        
        if (newAcctId == '') 
        {
            return null ;
        }

         
        // Get the territory for the user
        List<UserTerritory> utList = [select TerritoryId from userterritory where UserId = :UserInfo.getUserId()] ;
        /************************************************ 2013.08.20 *************************************************
        if (utList.size() == 0) 
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GAS_NOTALGN));
            return null ;
        }
        else if (utList.size() > 1) 
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GAS_MANYALGN));
            return null ;
        }
        
               
        // Get the name of the Territory
        String userTerrName = [select Name from Territory where Id = :utList[0].TerritoryId].Name ;
        String terrString = userTerrName ;
        ************************************************* 2013.08.20. **********************************************/
        String terrString = this.ConvertTerrFormat();   //2013.08.20.
        
        
        // Now check for existing territories for the Account
        List <AccountShare> asList = [select AccountId,UserOrGroupId from AccountShare 
                                      where AccountId =  :newAcctId and RowCause in ('Territory','TerritoryManual')] ;
        
        if (asList.size() > 0) 
        {
            // Get all the UserOrGroupIds, and store in a List
            List<Id> idlist1 = new List<Id> () ;
            for (AccountShare ash : asList) 
            {
                idlist1.add(ash.UserOrGroupId) ;
            }
            // Now let's get the IDs of the Territories
            List<Id> idlist2 = new List<Id> () ;
            List<Group> groupList = [select RelatedId from group where Id in :idlist1] ;
            for (Group g : groupList) 
            {
                idlist2.add(g.RelatedId) ;
            }
            // Finally, get the names
            List <Territory> terrList = [select Name from Territory where Id in :idlist2] ;
            
            /********************* 2013.08.20. ************************************************************************************/
            
            String existingTerrs = this.checkIfAlreadyAssigned(terrList);
            System.debug('CSABA: checking terrlist: ' + terrList + '  existing: ' + existingTerrs);
            if(existingTerrs != NULL)
            {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,GAS_INTERR + ' ' + existingTerrs));
                        return null ;               
            }
            
            /********************* 2013.08.20. ************************************************************************************/
            
            /********************* 2013.08.20.**************************************************************
            for (Territory t : terrList) 
            {
                // If the Territory is already there, output a warning and exit
                if (t.Name == userTerrName) 
                {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,GAS_INTERR));
                        return null ;
                }
                terrString = terrString + ';' + t.Name ;
            }
            ********************** 2013.08.20.*************************************************************/
        }
        
        try
        {
            // Now let's see if the Account Territory Loader already exists
            List <Account_Territory_Loader_vod__c> atlList = [select Id from Account_Territory_Loader_vod__c where Account_vod__c = :newAcctId] ;
            if (atlList.size() == 1) 
            {
                Account_Territory_Loader_vod__c atl = atlList[0] ;
                //2013.08.20. T.B.C. atl.Territory_vod__c = terrString ;
                system.debug('CSABA add to terr: ' + terrString);
                atl.Territory_To_Add_vod__c = terrString;  
                //atl.Territory_to_Drop_vod__c = terrString;  
                update (atl) ;
            }
            else 
            {
                insert (new Account_Territory_Loader_vod__c(Account_vod__c=newAcctId,External_ID_vod__c=newAcctId,Territory_vod__c=terrString)) ;
            }
            
             
            //With adding to territory, add a record to the GAS history object also 2013.05.02
            system.debug('Adding GAS history.' );   
            
            if (utList.size() == 0) 
            {
                //2013.08.27. replaced with below insert (new GAS_History_BI__c(Account_BI__c = newAcctId, Operation_BI__c = 'add', Territory_ID_BI__c = null, User_Territory_Name_BI__c = terrString )) ;
                insert (new GAS_History_BI__c(Account_BI__c = newAcctId, Operation_BI__c = 'add', Territory_ID_BI__c = null, User_Territory_Name_BI__c = terrString, GAS_Alignment_Date_BI__c = system.today(),GAS_Alignment_Made_By_BI__c = UserInfo.getUserId() )) ;
            }
            else if (utList.size() >= 1)   
            {
               //2013.08.20.  have a look   
               //2013.08.27. replaced with below insert (new GAS_History_BI__c(Account_BI__c = newAcctId, Operation_BI__c = 'add', Territory_ID_BI__c = utList[0].TerritoryId, User_Territory_Name_BI__c = terrString )) ;
               insert (new GAS_History_BI__c(Account_BI__c = newAcctId, Operation_BI__c = 'add', Territory_ID_BI__c = utList[0].TerritoryId, User_Territory_Name_BI__c = terrString,GAS_Alignment_Date_BI__c = system.today(),GAS_Alignment_Made_By_BI__c = UserInfo.getUserId() )) ;
            }
            system.debug('Added GAS history.' );
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,GAS_SUCCESS + ' ' +  terrString));
            
        }
        catch(DmlException ex)
        {
            ApexPages.addMessages(ex);
        }
        
        return null ;
    }
    
  

    public PageReference cancel() 
    {
        return null ;
    }



    private static String join (Set<String> ss, String delim) 
    {
        String retVal = '' ;
        for (String s : ss) {
            if (retVal != '')  {
                retVal += delim ;
            }
            retVal += s ;
        }
        return retVal ;
    }

    private static String getPhoneRegex (String inph) 
    {

        Pattern pt = Pattern.compile('[^0-9]');
        String [] res = pt.split(inph) ;
        String digits = '' ;
        for (Integer i = 0 ; i < res.size(); i++) {
        System.debug ('r1:' + res[i]) ;
            digits = digits + res[i] ;
        }
        System.debug ('r2:' + digits) ;
        String retval= '';

        if (digits.length() == 10) {
            retval = '%' + digits.substring(0,3) + '%' + digits.substring(3,6) + '%' + digits.substring (6,10) + '%' ;
        }
        else if (digits.length() == 7) {
            retval = '%' + digits.substring(0,3) + '%' + digits.substring(3,7) + '%' ;
        }
        else if (digits.length() == 4) {
            retval = '%' + digits ;
        }
        else {
            retval = digits ;
        }
System.debug ('r3:' + retval) ;
        return retval ;
    }

    private String getObjValue (sObject so, String fname, String typex) {
        if (typex == 'Reference') {
            // Get relationship name
            String relship ;
            if (fname.startsWith('ADD.')) {
                relship = addrFieldMap.get(fname.replace('ADD.', '')).getDescribe().getRelationshipName() ;
            }
            else {
                relship = acctFieldMap.get(fname).getDescribe().getRelationshipName() ;
            }
            // Display Name field of lookup value
            SObject so2 = so.getSObject(relship);
            if (!fname.contains('RecordTypeId') && so2 != null) {
                return (String) so2.get('Name') ;
            }
            else if (fname.contains('RecordTypeId') && so2 != null) {
                // We have the value, we need to translate it
                return recTypeXlation.get((String) so2.get('Name'));
            }
            return '' ;
        }
        if (fname.startsWith('ADD.')) {
            fname = fname.replace('ADD.', '') ;
        }
        if (typex == 'Boolean') {
            Boolean b = (Boolean) so.get(fname) ;
            return (b == true ? '[X]' : '[ ]') ;
        }
        else if (typex == 'Date') {
            Date d = (Date) so.get(fname) ;
            if (d != null) {
                return d.format() ;
            }
            else {
                return '' ;
            }
        }
        else if (typex == 'Datetime') {
            Datetime d = (Datetime) so.get(fname) ;
            if (d != null) {
                return d.format() ;
            }
            else {
                return '' ;
            }
        }
        else {
            return String.valueOf(so.get(fname)) ;
        }
    }


    private List<SelectOption> SortOptionList(List<SelectOption> ListToSort) {

        // Simple quick sort : see http://improveit360.blogspot.com/2010/09/implementing-quicksort-to-sort-list-of.html
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
            
        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();
        integer pivot = ListToSort.size() / 2;
          
        // save the pivot and remove it from the list
        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        for(SelectOption x : ListToSort)
        {
            if(x.getLabel() <= pivotValue.getLabel())
                Less.add(x);
            else if(x.getLabel() > pivotValue.getLabel()) Greater.add(x);   
        }
        List<SelectOption> xList = new List<SelectOption> ();
        xList.addAll(SortOptionList(Less));
        xList.add(pivotValue);
        xList.addAll(SortOptionList(Greater));
        // Dedupe
        List<SelectOption> returnList = new List<SelectOption> ();
        Set<String> labelSet = new Set<String> () ;
        returnList.add(new SelectOption('',GAS_NONE)) ;
        labelSet.add(GAS_NONE) ;
        for(SelectOption x : xList) {
            if (!labelSet.contains(x.getLabel())) {
                returnList.add(x) ;
                labelSet.add(x.getLabel()) ;
            }
        }
        return returnList; 
    }  

    private List<searchResult> SortSearchResults (List<searchResult> ListToSort, String keyField, String sortDir) {

        if (keyField != '') {
            // Set key field for each searchResult
            for(searchResult x : ListToSort) {
                for (searchResultField y : x.srFields) {
                    // Find the keyField
                    if (y.apiname == keyField) {
                        x.key = y.rawvalue ;
                        break ;
                    }
                }
            }
        }

        // Ok, now we have the keys, can do a simple quick sort. See : http://improveit360.blogspot.com/2010/09/implementing-quicksort-to-sort-list-of.html
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
            
        List<searchResult> Less = new List<searchResult>();
        List<searchResult> Greater = new List<searchResult>();
        integer pivot = ListToSort.size() / 2;
          
        // save the pivot and remove it from the list
        searchResult pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        if (sortDir == 'A') { // Ascending
            for(searchResult x : ListToSort)
            {
                if(x.key <= pivotValue.key)
                    Less.add(x);
                else if(x.key > pivotValue.key) Greater.add(x);   
            }
        }
        else { // Descending 
            for(searchResult x : ListToSort)
            {
                if(x.key <= pivotValue.key)
                    Greater.add(x);
                else if(x.key > pivotValue.key) Less.add(x);   
            }
        }
        List<searchResult> returnList = new List<searchResult> ();
        returnList.addAll(SortSearchResults(Less, '', sortDir));
        returnList.add(pivotValue);
        returnList.addAll(SortSearchResults(Greater, '', sortDir));
        return returnList; 
    }  

    public class searchResult {

        public String acctId {get;set;}
        public String acctName {get;set;}
        public String addrId {get;set;}
        public Boolean isSelected {get;set;}
        public String key {set;get;}
        public List<searchResultField> srFields {get;set;}
        public List<searchResult> otherAddrs {get;set;}

    }

    public class searchResultField {

        public String apiname {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String rawvalue {get;set;}
        public Boolean is_Acct {get;set;}
        public Boolean is_Addr {get;set;}

    }

    public class searchField {

        public String obj {get;set;}
        public String label {get;set;}
        public String apiname {get;set;}
        public String value {get;set;}
        public String alvalue {get;set;}
        public String opt_value {get;set;}
        public Boolean is_picklist {get;set;}
        public Boolean is_reference {get;set;}
        public Boolean is_phone {get;set;}
        public Boolean is_bool {get;set;}
        public Boolean is_acctlookup {get;set;}
        public Boolean has_es {get;set;}
        public Boolean has_cs {get;set;}
        public Boolean no_quote {get;set;}
        public Boolean no_opt {get;set;}
        public Boolean no_picklist {get;set;}
        public List<SelectOption> plist {set;get;}

        public searchField (String o, Schema.DescribeFieldResult dfr) {
            obj = o ;
            label = dfr.getLabel() ;
            apiname = dfr.getName () ;
            value = '' ;
            opt_value = '' ;
            is_acctlookup = false ;
            is_reference = (dfr.getType().name() == 'Reference') ;
            is_picklist = (dfr.getType().name() == 'Picklist') ;
            is_phone = (dfr.getType().name() == 'Phone') ;
            is_bool = (dfr.getType().name() == 'Boolean') ;
            no_quote = (dfr.getType().name() == 'Boolean' ||
                        dfr.getType().name() == 'Currency' ||
                        dfr.getType().name() == 'Date' ||
                        dfr.getType().name() == 'Datetime' ||
                        dfr.getType().name() == 'Double' ||
                        dfr.getType().name() == 'Integer' ||
                        dfr.getType().name() == 'Percent' ||
                        dfr.getType().name() == 'Time') ;
            if (is_picklist) {
                plist = new List<SelectOption> () ;
                List<Schema.PicklistEntry> P = dfr.getPicklistValues();
                plist.add(new SelectOption('',searchAccts.GAS_NONE)) ;
                for (Schema.PicklistEntry pe : P) {
                    plist.add(new SelectOption(pe.getValue(),pe.getLabel()));
                }
            }
            if (is_reference) {
                // Make it a picklist of names
                is_picklist = true ;
                // Remove trailing ' ID' from label
                label = label.replaceFirst(' ID$', '') ;
                List <Schema.sObjectType> sobjs = dfr.getReferenceTo() ;
                String objName = sobjs[0].getDescribe().getName() ;
System.debug ('objName is ' + objName) ;
                if (objName == 'RecordType') {
                    // Already calculated
                    plist = obj == 'Account' ? searchAccts.acctRecTypesPlist.clone()  : searchAccts.addrRecTypesPlist.clone() ;
                }
                else if (objName != 'Account') {
                    // All other references
                    plist = new List<SelectOption> () ;
                    plist.add(new SelectOption('',searchAccts.GAS_NONE)) ;
                    String query = 'select Id,Name from ' + objName + ' order by Name' ;
                    for (sObject ox : Database.query(query)) {
                        plist.add(new SelectOption((String)ox.get('Id'), (String)ox.get('Name'))) ;
                    }
                }
                else {
                    // objName is Account.  We don't want to display thousands or more Account names in a picklist,
                    // so we handle this by creating a link to aonther search page.
                    is_acctlookup = true ;
                }
System.debug ('is_acctlookup is ' + is_acctlookup) ;
            }
            has_es = (obj == 'Account' && (apiname == 'Name' || apiname == 'FirstName' || apiname == 'LastName' || apiname == 'License_BI__c' || apiname == 'GAS_Specialty_BI__c' || apiname == 'Formatted_Name_vod__c')) || (obj == 'Address_vod__c' && (apiname == 'License_vod__c')) ;
            has_cs = (obj == 'Address_vod__c' && (apiname == 'Name' || apiname == 'GAS_State_Province_BI__c' || apiname == 'City_vod__c')) ;
            if (has_es) {
                opt_value = 'Exact Match' ;
            }
            if (has_cs) {
                opt_value = 'Starts With' ;
            }
            no_opt = !has_cs && !has_es && !is_acctlookup;
            no_picklist = !is_picklist ;
        }




    } 

    public class resultHeader {

        public String label {set;get;} 
        public String apiname {set;get;} 

    }
}