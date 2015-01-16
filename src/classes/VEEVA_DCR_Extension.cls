/*******************************************************************************
Extension class for OK DCR Visualpage Force.

Created by: Viktor Fasi
Last modified date: 2013.10.04
********************************************************************************/
public with sharing class VEEVA_DCR_Extension {
    public V2OK_Data_Change_Request__c DCR {get; set;}
    //public list<Customer_Attribute_BI__c> CAs;

    //listoptions
    public list<SelectOption> spec {get; set;}
    public list<SelectOption> spec2 {get; set;}
    public list<SelectOption> med {get; set;}
    public list<SelectOption> med2 {get; set;}
    public list<SelectOption> qual {get; set;}
    public list<SelectOption> edu {get; set;}
    public list<SelectOption> edu2 {get; set;}
    public list<SelectOption> uni {get; set;}
    public list<SelectOption> indclass {get; set;}
    public list<SelectOption> indtyp {get; set;}
    public list<SelectOption> wkpclass {get; set;}
    public list<SelectOption> wkptyp {get; set;}
    public list<SelectOption> prov {get; set;}
    public list<SelectOption> addrsel {get; set;}
    public list<SelectOption> role {get; set;}
    public list<SelectOption> role2 {get; set;}
    public list<SelectOption> wkprectype {get; set;} // workplace record type added for BI RUS 2014-05-20

    public List<String> workplaceRecordTypeList { get; set; }

    //value lookups
    public map<String, String> codemap {get; set;}
    public Boolean getSpecR() {
        return codemap.containskey(DCR.Specialty_3_BI__c) && V2OK_Data_Change_Request__c.Specialty_3_BI__c.getDescribe().isAccessible();
    }
    public Boolean getUniR() {
        return codemap.containskey(DCR.University_BI__c) && V2OK_Data_Change_Request__c.University_BI__c.getDescribe().isAccessible();
    }
    public Boolean getEduR() {
        return codemap.containskey(DCR.Education_Specialty_2_BI__c) && V2OK_Data_Change_Request__c.Education_Specialty_2_BI__c.getDescribe().isAccessible();
    }
    public Boolean getIndTypR() {
        return codemap.containskey(DCR.Individual_Type_BI__c) && V2OK_Data_Change_Request__c.Individual_Type_BI__c.getDescribe().isAccessible();
    }
    public Boolean getMed2R() {
        return codemap.containskey(DCR.Medical_Interest_2_BI__c) && V2OK_Data_Change_Request__c.Medical_Interest_2_BI__c.getDescribe().isAccessible();
    }
    public Boolean getMed3R() {
        return codemap.containskey(DCR.Medical_Interest_3_BI__c) && V2OK_Data_Change_Request__c.Medical_Interest_3_BI__c.getDescribe().isAccessible();
    }
    public Boolean getQualR() {
        return codemap.containskey(DCR.Qualification_BI__c) && V2OK_Data_Change_Request__c.Qualification_BI__c.getDescribe().isAccessible();
    }
    public Boolean getRectype() {
        return codemap.containskey(DCR.Record_Type_BI__c) && V2OK_Data_Change_Request__c.Record_Type_BI__c.getDescribe().isAccessible();
    }
    //view variables
    public Boolean accs {get; set;}
    public Boolean person {get; set;}
    public Boolean business {get; set;}
    public Boolean address {get; set;}
    public Boolean activ {get; set;}
    public Boolean detail {get; set;}
    public Boolean RTselect {get; set;}
    public Boolean edit {get; set;}
    public Boolean fromacc {get; set;}
    public Boolean dupelist {get; set;}
    public Boolean lkpperson {get; set;}
    public Boolean lkpbusiness {get; set;}
    public Boolean hierarchy {get; set;}
    public Boolean applist {get; set;}
    public Boolean isDS {get; set;}
    public Boolean showAddrSelect {get; set;}
    public Boolean wkp {get; set;}

    //translation labels
    public String DCR_Summary {get; set;}
    public String DCR_Sel {get; set;}
    public String DCR_Continue {get; set;}
    public String DCR_Cancel {get; set;}
    public String DCR_Save {get; set;}
    public String DCR_dcr {get; set;}
    public String DCR_Edit {get; set;}
    public String DCR_Delete {get; set;}
    public String DCR_retlist {get; set;}
    public String DCR_retacc {get; set;}
    public String DCR_Submit {get; set;}
    public String DCR_Address {get; set;}
    public String DCR_Activity {get; set;}
    public String DCR_Org {get; set;}
    public String DCR_Person {get; set;}
    public String DCR_Accounts {get; set;}
    public String DCR_Info {get; set;}
    public String DCR_Dupe {get; set;}
    public String DCR_Newaddr {get; set;}
    public String DCR_None {get; set;}
    public String DCR_Response {get; set;}

    //mappings
    public DCR_Mapping__c Mapping {get; set;}
    public Map <String, Schema.SObjectField> Setting {get; set;}

    //base objects
    public RecordType RT {get; set;}
    public Address_vod__c Addr {get; set;}
    public Account HCP {get; set;}
    public Account HCO {get; set;}
    public Child_Account_vod__c CA {get; set;}

    //query fields
    public String HCPfields;
    public String HCOfields;
    public String CAfields;
    public String ADDRfields;
    //other
    public String egid;
    public Id accid; //url param
    public Id DCRid; //url param
    public String save_new;
    public String retURL; //url param
    public list<Account> dupes {get; set;} //SOSL-ed accounts
    public String addrvalue {get; set;} //value to get back
    public list<Address_vod__c> Addrlist {get; set;} //list to display
    boolean pageprefilled;


    private Set<String> ignoreFieldSet = new Set<String> {
        'CreatedById',
        'CreatedDate',
        'CurrencyIsoCode',
        'IsDeleted',
        'IsLocked',
        'LastModifiedById',
        'LastModifiedDate',
        'SetupOwnerId',
        'MayEdit',
        'Name',
        'Id',
        'SystemModstamp'
    };

    /*****************************************************************************************************************
                                                        CONSTRUCTOR START
    *****************************************************************************************************************/
    public VEEVA_DCR_Extension(ApexPages.StandardController controller) {
        //instancitialize object
        DCR = new V2OK_Data_Change_Request__c();
        this.DCR = (V2OK_Data_Change_Request__c) controller.getRecord();

        //get org-specific object code for list URL composition
        egid = V2OK_Data_Change_Request__c.sObjectType.getDescribe().getKeyPrefix();

        //default view, in case it's a new :)
        accs = false;
        person = false;
        business = false;
        address = false;
        activ = false;
        detail = true;
        RTselect = false;
        edit = false;
        dupelist = false;
        lkpperson = false;
        lkpbusiness = false;
        hierarchy = false;
        //applist=true;
        wkp = false;
        //preload = false;
        pageprefilled = false;
        //default no DS
        //isDS = false;

        /*****************************************************************************************************************
                                                        EDIT/DETAIL MODE
        *****************************************************************************************************************/
        // https://c.cs9.visual.force.com/apex/VEEVA_DCR?id=a2GK0000000E8gA&retURL=%2Fa2G%3Ffcf%3D00BK0000000QPSc%26rolodexIndex%3D-1%26page%3D1&sfdc.override=1
        //get params
        DCRid = ApexPages.currentPage().getParameters().get('id');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        save_new = ApexPages.currentPage().getParameters().get('save_new');

        if (DCRid != null) {
            //get RT by DCR ID for separation, and query all the fields
            Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('V2OK_Data_Change_Request__c').getDescribe().fields.getMap();
            String selStmt = 'SELECT ';

            for (Schema.SObjectField sfield : fieldMap.Values()) {
                schema.describefieldresult dfield = sfield.getDescribe();
                if (!dfield.getName().equals('null') || dfield.getName() != null) {
                    selStmt +=  dfield.getName() + ', ';
                }
            }
            selStmt += ' RecordType.DeveloperName ';
            selStmt += ' FROM V2OK_Data_Change_Request__c WHERE Id = \'' + DCRid + '\' LIMIT 1';
            try {
                DCR = Database.query(selSTmt);
            } catch (QueryException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The DCR provided in the URL cannot be queried for the running user with all fields: ' + e));
            }

            //if(DCR.RecordType.DeveloperName.contains('DataSteward')) isDS = true;

            if (retURL != null) {
                detail = false;
                RTselect = false;
                edit = true;
            } else {
                detail = true;
                RTselect = false;
                edit = false;
            }

        }
        if (retURL != null && save_new != null) {
            detail = false;
            RTselect = false;
            edit = true;
        }
        system.debug('Mode set for: ' + DCRid + ' retURL: ' + retURL);
        /*****************************************************************************************************************
                                                        TRANSLATIONS
        *****************************************************************************************************************/
        String lang = UserInfo.getLanguage();
        Map <String, String> labelMap = new Map <String, String> ();
        list<Message_vod__c> labels = new list<Message_vod__c>();
        // Get labels from Message_vod__c for user's language
        try {
            labels = [ SELECT Name,
                       Text_vod__c
                       FROM   Message_vod__c
                       WHERE  Language_vod__c = :lang
                                                AND    Category_vod__c = 'DCR_BI'
                                                        AND    Active_vod__c = true ];
        } catch (Queryexception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The translation Veeva Messages cannot be queried for the running user: ' + e));
        }

        for (Message_vod__c label : labels) {
            labelMap.put(label.Name, label.Text_vod__c);
        }
        //handle the situation when the Label does not exists in the Message obj
        DCR_Summary = labelMap.get('DCR_Summary') != null ? labelMap.get('DCR_Summary') : 'Summary';
        DCR_Sel = labelMap.get('DCR_Sel') != null ? labelMap.get('DCR_Sel') : 'Select the type of the DCR';
        DCR_Continue = labelMap.get('DCR_Continue') != null ? labelMap.get('DCR_Continue') : 'Continue';
        DCR_Cancel = labelMap.get('DCR_Cancel') != null ? labelMap.get('DCR_Cancel') : 'Cancel';
        DCR_Save = labelMap.get('DCR_Save') != null ? labelMap.get('DCR_Save') : 'Save';
        DCR_dcr = labelMap.get('DCR_dcr') != null ? labelMap.get('DCR_dcr') : 'DCR';
        DCR_Edit = labelMap.get('DCR_Edit') != null ? labelMap.get('DCR_Edit') : 'Edit';
        DCR_Delete = labelMap.get('DCR_Delete') != null ? labelMap.get('DCR_Delete') : 'Delete';
        DCR_retlist = labelMap.get('DCR_retlist') != null ? labelMap.get('DCR_retlist') : 'Return to DCR list';
        DCR_retacc = labelMap.get('DCR_retacc') != null ? labelMap.get('DCR_retacc') : 'Return to Account';
        DCR_Submit = labelMap.get('DCR_Submit') != null ? labelMap.get('DCR_Submit') : 'Submit for approval';
        DCR_Address = labelMap.get('DCR_Address') != null ? labelMap.get('DCR_Address') : 'Address Details';
        DCR_Activity = labelMap.get('DCR_Activity') != null ? labelMap.get('DCR_Activity') : 'Activity Details';
        DCR_Org = labelMap.get('DCR_Org') != null ? labelMap.get('DCR_Org') : 'Organisation Account Details';
        DCR_Person = labelMap.get('DCR_Person') != null ? labelMap.get('DCR_Person') : 'Person Account Details';
        DCR_Accounts = labelMap.get('DCR_Accounts') != null ? labelMap.get('DCR_Accounts') : 'Accounts';
        DCR_Info = labelMap.get('DCR_Info') != null ? labelMap.get('DCR_Info') : 'DCR Information';
        DCR_Dupe = labelMap.get('DCR_Dupe') != null ? labelMap.get('DCR_Dupe') : 'Are you sure you are not trying to create one of these accounts?';
        DCR_Newaddr = labelMap.get('DCR_Newaddr') != null ? labelMap.get('DCR_Newaddr') : '--New Address--';
        DCR_None = labelMap.get('DCR_None') != null ? labelMap.get('DCR_None') : '--None--';
        DCR_Response = labelMap.get('DCR_Response') != null ? labelMap.get('DCR_Response') : 'Data provider response';

        System.debug('Translations loaded.');
        /*****************************************************************************************************************
                                                        GET RECORDTYPE/SET DS
        *****************************************************************************************************************/
        //system.debug('recordtype: '+ DCR.Recordtype.Developername);
        String RTname = DCR.RecordTypeId;
        if (RTname == null)RTname = ApexPages.currentPage().getParameters().get('RecordType');
        if (RTname == null)RTname = ApexPages.currentPage().getParameters().get('RT');
        //System.debug('RTname: '+RTname);
        //&RecordType=012K00000008imU
        //if no RT is provided (not called from a button) we assume this is the reason they are here for
        if (RTname == null) {
            RTname = 'New_Professional_at_New_Workplace';
        }
        //decide if DS
        String okid = ApexPages.currentPage().getParameters().get('okid');
        System.debug('okid: ' + okid);
        if ((okid == null || okid == '') && ApexPages.currentPage().getParameters().get('RT') != null)RTname += '_DataSteward_BI';

        RT = new RecordType();
        try {
            RT = [SELECT Id, Name, DeveloperName  FROM RecordType WHERE SobjectType = 'V2OK_Data_Change_Request__c' AND (DeveloperName = :RTname OR Id = :RTname) LIMIT 1];
        } catch (QueryException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The RecordType cannot be queried for the running user: ' + e));
        }
        if (RT == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The recordtype provided in the URL is incorrect.'));
            return;
        }
        if (RT.DeveloperName.contains('DataSteward')) isDS = true; else isDS = false;
        applist = (detail && isDS);
        System.debug('RT set: ' + RT.Name + ' isDS: ' + isDS);
        /*****************************************************************************************************************
                                                        PICKLISTS
        *****************************************************************************************************************/
        //get the picklist values filled up if edit mode
        list<Customer_Attribute_BI__c> CAs = new list<Customer_Attribute_BI__c>();

        //clear &init lists, add empty value
        spec = new List<SelectOption>(); spec.add(new SelectOption('', DCR_None));
        spec2 = new List<SelectOption>(); spec2.add(new SelectOption('', DCR_None));
        med = new List<SelectOption>(); med.add(new SelectOption('', DCR_None));
        med2 = new List<SelectOption>(); med2.add(new SelectOption('', DCR_None));
        qual = new List<SelectOption>(); qual.add(new SelectOption('', DCR_None));
        edu = new List<SelectOption>(); edu.add(new SelectOption('', DCR_None));
        edu2 = new List<SelectOption>(); edu2.add(new SelectOption('', DCR_None));
        uni = new List<SelectOption>(); uni.add(new SelectOption('', DCR_None));
        indclass = new List<SelectOption>(); indclass.add(new SelectOption('', DCR_None));
        indtyp = new List<SelectOption>(); indtyp.add(new SelectOption('', DCR_None));
        wkptyp = new List<SelectOption>(); wkptyp.add(new SelectOption('', DCR_None));
        wkpclass = new List<SelectOption>(); wkpclass.add(new SelectOption('', DCR_None));
        prov = new List<SelectOption>(); prov.add(new SelectOption('', DCR_None));
        role = new List<SelectOption>(); role.add(new SelectOption('', DCR_None));
        wkprectype = new List<SelectOption>();
        //init maps
        //specmap = new map<Id,String>();
        codemap = new map<String, String>(); codemap.put(null, '');

        //unimap = new map<String,String>(); unimap.put(null,'');

        if (isDS != true) {
            try {
                CAs =
                    [
                        SELECT Id, Name, OK_Type_Code_BI__c, CODE_ID_CEGEDIM_BI__c, OK_Country_ID_BI__c
                        FROM Customer_Attribute_BI__c
                        WHERE OK_Type_Code_BI__c in ('SP', 'TEN', 'QLF', 'SDM', 'FAC', 'TYT', 'TYP', 'TET', 'FAD', 'DPT', 'TIH')
                        AND CODE_END_VALID_DATE_OK_BI__c like '9999-12%' //commented out for BLD1 needs to be in prod version
                        ORDER BY Name
                    ];
                //System.debug('CAs size: ' + CAs.size());
            } catch (QueryException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Customer Attributes cannot be queried for the running user: ' + e));
            }
            for (Customer_Attribute_BI__c ca : CAs) {
                //Have to keep under 1000 records, because sysadmins go over it and hit governor limits. No end-user should hit them.
                if (ca.OK_Type_Code_BI__c == 'SP' && spec.size() < 1000) spec.add(new SelectOption(ca.Id, ca.Name)); //Specialty
                if (ca.OK_Type_Code_BI__c == 'SP' && spec2.size() < 1000) spec2.add(new SelectOption(ca.Id, ca.Name)); //Specialty2
                if (ca.OK_Type_Code_BI__c == 'TEN' && med.size() < 1000) med.add(new SelectOption(ca.Id, ca.Name)); //Medical interest
                if (ca.OK_Type_Code_BI__c == 'TEN' && med2.size() < 1000) med2.add(new SelectOption(ca.Id, ca.Name)); //Medical interest2
                if (ca.OK_Type_Code_BI__c == 'QLF' && qual.size() < 1000) qual.add(new SelectOption(ca.Id, ca.Name)); //Qualification
                if (ca.OK_Type_Code_BI__c == 'SDM' && edu.size() < 1000) edu.add(new SelectOption(ca.Id, ca.Name)); //Education Specialty
                if (ca.OK_Type_Code_BI__c == 'SDM' && edu2.size() < 1000) edu2.add(new SelectOption(ca.Id, ca.Name)); //Education Specialty2
                if (ca.OK_Type_Code_BI__c == 'FAC' && uni.size() < 1000) uni.add(new SelectOption(ca.Id, ca.Name)); //University
                if (ca.OK_Type_Code_BI__c == 'TYT' && indclass.size() < 1000) indclass.add(new SelectOption(ca.Id, ca.Name)); //Individual class
                if (ca.OK_Type_Code_BI__c == 'TYP' && indtyp.size() < 1000) indtyp.add(new SelectOption(ca.Id, ca.Name)); //Individual type
                if (ca.OK_Type_Code_BI__c == 'FAD' && wkpclass.size() < 1000) wkpclass.add(new SelectOption(ca.Id, ca.Name)); //Workplace class
                if (ca.OK_Type_Code_BI__c == 'TET' && wkptyp.size() < 1000) wkptyp.add(new SelectOption(ca.Id, ca.Name)); //Workplace type
                if (ca.OK_Type_Code_BI__c == 'DPT' && prov.size() < 1000) prov.add(new SelectOption(ca.Id, ca.Name)); //Province
                if (ca.OK_Type_Code_BI__c == 'TIH' && role.size() < 1000) role.add(new SelectOption(ca.Id, ca.Name)); //Role
                //get some maps to display the names of the IDs

                if (ca.OK_Country_ID_BI__c == DCR.Country_DS__c && codemap.size() < 5000) codemap.put(ca.Id, ca.Name);
                //if(codemap.size() < 49999) codemap.put(ca.Name,ca.Name); //added only for backward compatibility
                //if(ca.OK_Type_Code_BI__c == 'SP' && specmap.size() < 1000) specmap.put(ca.Id,ca.Name);
                //if(ca.OK_Type_Code_BI__c == 'TEN'&& medmap.size() < 1000) medmap.put(ca.Id,ca.Name);
                //if(ca.OK_Type_Code_BI__c == 'QLF'&& qualmap.size() < 1000) qualmap.put(ca.Id,ca.Name);
                //if(ca.OK_Type_Code_BI__c == 'TYP'&& indtypmap.size() < 1000) indtypmap.put(ca.Id,ca.Name);
                //if(ca.OK_Type_Code_BI__c == 'FAC'&& unimap.size() < 1000) unimap.put(ca.Id,ca.Name);
            }
        } else {
            try {
                CAs =
                    [
                        SELECT Id, Name, OK_Type_BI__c, Type_BI__c, OK_Type_Code_BI__c, CODE_ID_CEGEDIM_BI__c, Country_Code_BI__c
                        FROM Customer_Attribute_BI__c
                        WHERE Type_BI__c in ('ACCT_Edu Specialty', 'ACCT_Qualification', 'ACCT_Med Interest', 'CHILD_Role', 'ACCT_Specialty', 'ACCT_University', 'ACCT_WKP Class', 'ACCT_WKP Type', 'ACCT_IND Type', 'ACCT_BI Specialty', 'ACCT_IND Class', 'ADDR_State', 'ADDR_Brick Name')
                        ORDER BY Name
                    ];
                //System.debug('CAs size: ' + CAs.size());
            } catch (QueryException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Customer Attributes cannot be queried for the running user: ' + e));
            }
            for (Customer_Attribute_BI__c ca : CAs) {
                //Have to keep under 1000 records, because sysadmins go over it and hit governor limits. No end-user should hit them.
                if ((ca.Type_BI__c == 'ACCT_Specialty' || ca.OK_Type_BI__c == 'ACCT_BI Specialty') && spec.size() < 1000) spec.add(new SelectOption(ca.Id, ca.Name)); //Specialty
                if ((ca.Type_BI__c == 'ACCT_Specialty' || ca.OK_Type_BI__c == 'ACCT_BI Specialty') && spec2.size() < 1000) spec2.add(new SelectOption(ca.Id, ca.Name)); //Specialty2
                if (ca.Type_BI__c == 'ACCT_Med Interest' && med.size() < 1000) med.add(new SelectOption(ca.Id, ca.Name)); //Medical interest
                if (ca.Type_BI__c == 'ACCT_Med Interest' && med2.size() < 1000) med2.add(new SelectOption(ca.Id, ca.Name)); //Medical interest2
                if (ca.Type_BI__c == 'ACCT_Qualification' && qual.size() < 1000) qual.add(new SelectOption(ca.Id, ca.Name)); //Qualification
                if (ca.Type_BI__c == 'ACCT_Edu Specialty' && edu.size() < 1000) edu.add(new SelectOption(ca.Id, ca.Name)); //Education Specialty
                if (ca.Type_BI__c == 'ACCT_Edu Specialty' && edu2.size() < 1000) edu2.add(new SelectOption(ca.Id, ca.Name)); //Education Specialty2
                if (ca.Type_BI__c == 'ACCT_University' && uni.size() < 1000) uni.add(new SelectOption(ca.Id, ca.Name)); //University
                if (ca.Type_BI__c == 'ACCT_IND Class' && indclass.size() < 1000) indclass.add(new SelectOption(ca.Id, ca.Name)); //Individual class
                if (ca.Type_BI__c == 'ACCT_IND Type' && indtyp.size() < 1000) indtyp.add(new SelectOption(ca.Id, ca.Name)); //Individual type
                if (ca.Type_BI__c == 'ACCT_WKP Class' && wkpclass.size() < 1000) wkpclass.add(new SelectOption(ca.Id, ca.Name)); //Workplace class
                if (ca.Type_BI__c == 'ACCT_WKP Type' && wkptyp.size() < 1000) wkptyp.add(new SelectOption(ca.Id, ca.Name)); //Workplace type
                if (ca.Type_BI__c == 'ADDR_State' && prov.size() < 1000) prov.add(new SelectOption(ca.Id, ca.Name)); //Province
                if (ca.Type_BI__c == 'CHILD_Role' && role.size() < 1000) role.add(new SelectOption(ca.Id, ca.Name)); //Role
                if (ca.Country_Code_BI__c == DCR.Country_DS__c && codemap.size() < 5000) codemap.put(ca.Id, ca.Name);
                //if(codemap.size() < 49999) codemap.put(ca.Name,ca.Name);
            }


            //fill wkprectpye
            // Changed by Raphael 2014-07-16 - added toLabel to utilise tranlsation workbench on VF page.
            Map<ID, Schema.RecordTypeInfo> wkpRecMap = Schema.Sobjecttype.Account.getRecordtypeInfosById();
            List<RecordType> recordTypes =
                [
                    SELECT Id, toLabel(Name)
                    FROM RecordType
                    WHERE SobjectType = 'Account' AND IsActive = true AND IsPersonType = false
                ];

            for (RecordType theRecordType : recordTypes) {

                if ( wkpRecMap.get(theRecordType.Id).isAvailable() ) {
                    wkprectype.add(new SelectOption(theRecordType.Id, theRecordType.Name));
                }

                if ( codemap.size() < 5000 ) {
                    codemap.put(theRecordType.Id, theRecordType.Name);
                }

            }



        }

        System.debug('Picklists filled.');

        //CALL PAGE PREFILL
        pageprefill();
        /*****************************************************************************************************************
                                                        SECTION VISIBILITY per RT
        *****************************************************************************************************************/
        //if called from button go straight to edit mode
        if ((ApexPages.currentPage().getParameters().get('RT') != null) && (ApexPages.currentPage().getParameters().get('accid') != null)) {
            System.debug('Final override of detail mode in case of called from button activated.');
            detail = false;
            RTselect = false;
            edit = true;
        }
        //Professional_Update_Delete
        if (RT.DeveloperName.contains('Professional_Update_Delete')) {
            accs = true;
            person = true;
            business = false;
            address = true;
            activ = true;
            lkpperson = true;
            lkpbusiness = false;
            hierarchy = false;
            showAddrSelect = true;
        }
        //Workplaces
        if (RT.DeveloperName.contains('Workplaces')) {
            accs = true;
            business = true;
            address = true;
            lkpperson = false;
            lkpbusiness = true;
            hierarchy = false;
            showAddrSelect = true;
            wkp = true;
        }
        //New_Professional_at_Existing_Workplace
        if (RT.DeveloperName.contains('New_Professional_at_Existing_Workplace')) {
            accs = true;
            person = true;
            address = true;
            activ = true;
            lkpperson = false;
            lkpbusiness = true;
            hierarchy = false;
            showAddrSelect = false;
        }
        //Hierarchy
        if (RT.DeveloperName.contains('Hierarchy')) {
            accs = true;
            activ = true;
            lkpperson = true;
            lkpbusiness = true;
            hierarchy = true;
            showAddrSelect = false;
        }
        //New_Professional_at_New_Workplace - no button for this
        if (RT.DeveloperName.contains('New_Professional_at_New_Workplace')) {
            person = true;
            business = true;
            address = true;
            activ = true;
            lkpperson = false;
            lkpbusiness = false;
            hierarchy = false;
            showAddrSelect = false;
        }
        //Existing_Professional_at_New_Workplace
        if (RT.DeveloperName.contains('Existing_Professional_at_New_Workplace')) {
            accs = true;
            business = true;
            address = true;
            activ = true;
            lkpperson = true;
            lkpbusiness = false;
            hierarchy = false;
            showAddrSelect = false;
        }
        if (showAddrSelect == true) addresslistfill(); //to handle edit from list
        System.debug('Visibility set.');

        if ( detail == true ) {
            // if we are displaying the information, then display the changed fields
            calculateChangedFields();
        }

    }//end of constructor
    /*****************************************************************************************************************
                                                    BUTTON-PAGEREF
    *****************************************************************************************************************/
    //unused since built in is cooler - continue from RTselection mode - might need this later
    /*public PageReference next() {
        //system.debug('Processing pageref next');
        //if DS, return URL to edit of recordtype
        /*RecordType RTselected = [SELECT Id, Name, DeveloperName  FROM RecordType WHERE SobjectType = 'V2OK_Data_Change_Request__c' AND Id = :DCR.RecordTypeId LIMIT 1];
        if(RTselected.Name.contains('DataSteward')){
            //edit target: https://cs9.salesforce.com/a2G/e?retURL=%2Fa2G%2Fo&RecordType=012K00000008jEj
            //detail  https://c.cs9.visual.force.com/apex/VEEVA_DCR?id=a2GK0000000E8al&sfdc.override=1
            // %2F = /
            String editurl = '';
            editurl += '/' + egid + '/e?retURL=%2F' + egid + '%2Fo&RecordType=' + DCR.RecordTypeId;
            //system.debug('Forwarding Datasteward to edit URL: ' + editurl);
            PageReference DS = new PageReference(editurl);
            return DS;
        }else{*/
    /*  //if not, just go to next page
        RTselect = false;
        edit = true;
        detail = false;
        return null;
    //}
    }*/

    /*****************************************************************************************************************
                                                    PAGE PREFILL
    *****************************************************************************************************************/
    public void pageprefill() {
        accid = ApexPages.currentPage().getParameters().get('accid');

        Id professionalId = DCR.Professional_DS__c;
        Id organisationId = DCR.Organisation_Account__c;

        System.debug('professionalId: ' + professionalId);
        System.debug('organisationId: ' + organisationId);

        /*
        if (accid == null) accid = DCR.Professional_DS__c;
        if (accid == null) accid = DCR.Organisation_Account__c;
        */

        if ( accid == null ) accid = professionalId;
        if ( accid == null ) accid = organisationId;

        System.debug('Accid: ' + accid);
        //if account is available

        if (accid != null) {
            //set public variable for visibility
            fromacc = true;
            //access the mapping
            querycompile();

            //String query = 'SELECT ';
            String HCPend = '';
            String HCOend = '';

            HCPend = 'SELECT isPersonAccount, University_BI__r.Name, OK_Qualification_BI__r.Name, OK_Education_Specialty_2_BI__r.Name, ' +
                     'OK_Individual_Type_BI__r.Name, Specialty_3_BI__r.Name, OK_Medical_Interest_2_BI__r.Name, OK_Medical_Interest_3_BI__r.Name, ' + HCPfields;
            if (HCOfields != '') HCPend += ',' + HCOfields;
            HCPend += '  FROM Account WHERE Id = \'' + accid + '\' LIMIT 1';

            System.debug('HCPend query BEFORE: ' + HCPend);

            //some afterwork on the query
            //if(HCPend.countMatches('Primary_Parent_vod__c')<1) HCPend = HCPend.replaceFirst('Id,', 'Id, Primary_Parent_vod__c,');
            //duplicate field queries - some more might be needed
            if (HCPend.countMatches('Id,') > 1) HCPend = HCPend.replaceFirst('Id,', '');
            if (HCPend.countMatches(',Specialty_BI__c,') > 1) HCPend = HCPend.replaceFirst(',Specialty_BI__c,', ',');
            if (HCPend.countMatches('OK_Status_Code_BI__c,') > 1) HCPend = HCPend.replaceFirst('OK_Status_Code_BI__c,', '');
            if (HCPend.countMatches('Status_BI__c,') > 1) HCPend = HCPend.replaceFirst('Status_BI__c,', '');
            if (HCPend.countMatches(',Specialty_3_BI__c,') > 1) HCPend = HCPend.replaceFirst(',Specialty_3_BI__c,', ',');
            if (HCPend.countMatches(',Specialty_2_BI__c,') > 1) HCPend = HCPend.replaceFirst(',Specialty_2_BI__c,', ',');

            System.debug('HCPend query AFTER: ' + HCPend);
            //HCP or HCO account to find out which one it is
            Account acc = new Account();
            try {
                acc = Database.query(HCPend);
            } catch (QueryException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The basic account cannot be queried for the running user, or the custom settings are not set up correctly: ' + e));
            }

            System.debug('HCO: ' + HCO);

            //Assign account types
            HCP = new Account();

            //query HCO if necessary
            if (acc.IsPersonAccount == true) {
                System.debug('acc.isPersonAccount == true');
                HCP = acc;

                System.debug('HCO: ' + HCO);

                if (HCO == null) HCOend = 'SELECT  ' + HCOfields + '  FROM Account WHERE Id = \'' + acc.Primary_Parent_vod__c + '\' LIMIT 1';

                System.debug('HCOend: ' + HCOend);

                Boolean hcoIsMissing = false;
                String error = '';

                try {
                    if (HCO == null) HCO = Database.query(HCOend);
                } catch (QueryException e) {
                    hcoIsMissing = true;
                    error = e.getMessage();
                }

                if ( HCO == null ) hcoIsMissing = true;

                if ( hcoIsMissing ) {
                    HCO = new Account();

                    if (
                        RT.DeveloperName != 'Professional_Update_Delete_DataSteward_BI'
                        && ! RT.DeveloperName.contains('New_Workplace')
                    ) {
                        error = 'The Business account cannot be found for the running user. ' + error;
                        System.debug('ERROR: ' + error);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                    }
                }




            } else {
                System.debug('acc.isPersonAccount == false');
                HCO = acc;
            }
            //query CA
            CA = new Child_Account_vod__c();

            if (acc.IsPersonAccount == true) {
                /*
                String CAend = '';
                CAend += 'SELECT ' + CAfields + ' FROM Child_Account_vod__c where Child_Account_vod__c = \'' + accid + '\' AND Parent_Account_vod__c = \'' + HCO.Id + '\' Order by Primary_vod__c DESC LIMIT 1 ';
                */

                String CAend =
                    'SELECT ' + CAfields
                    + ' FROM Child_Account_vod__c'
                    + ' WHERE Child_Account_vod__c = \'' + accid + '\''
                    + ' AND Parent_Account_vod__c = \'' + HCO.Id + '\''
                    + ' ORDER BY Primary_vod__c'
                    + ' DESC LIMIT 1 '
                    ;


                System.debug('CAend: ' + CAend);
                try {
                    CA = Database.query(CAend);
                } catch (QueryException e) {

                    // isDS - should be false (is Data Steward)
                    Boolean isProfessionalUpdateOrDelete = RT.DeveloperName.startsWith('Professional_Update_Delete');
                    Boolean isHeirarchyUpdateOrDelete = (RT.DeveloperName == 'Hierarchy' && DCR.Change_Type__c != 'Create');

                    System.debug('Point a!');
                    if ( ( isProfessionalUpdateOrDelete || isHeirarchyUpdateOrDelete ) && ! isDS ) {

                        System.debug('Is professional update or hierarchy (not create) and isn\'t data steward');

                        String messageString =
                            'The Child Account related to the accounts cannot be found for the running user: ' + e;
                        ApexPages.Message apexPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, messageString);
                        ApexPages.addMessage(apexPageMessage);

                        System.debug('Throwing error: ' + messageString);
                    }
                    System.debug('Point B');

                    /*
                    if (RT.DeveloperName != 'Professional_Update_Delete_DataSteward_BI'
                            //&& RT.DeveloperName!= 'Existing_Professional_at_New_Workplace'
                            //&& RT.DeveloperName!= 'Hierarchy'
                            && DCR.Change_Type__c != 'Create'
                       )
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Child Account related to the accounts cannot be found for the running user: ' + e));
                        */
                }
            }
            //add the queried adresses to the selector options
            addresslistfill();

            //general fields
            DCR.RecordtypeId = RT.Id;
            if ( String.isBlank(DCR.Description__c) ) DCR.Description__c = RT.Name;
            if ( String.isBlank(DCR.Status__c) ) DCR.Status__c = 'In progress';

            pageprefilled = true;
            //Mapping assignment by the custom setting
            fieldassign();

            System.debug('Field assignment is done');
        } else { //if an accid is not provided by the URL param
            fromacc = false;
            System.debug('Field assignment is NOT done');
        }//end of if account is available
    }


    /*****************************************************************************************************************
                                                    QUERY COMPILE
    *****************************************************************************************************************/
    public void querycompile() {
        Mapping = DCR_Mapping__c.getInstance();
        Setting = Schema.getGlobalDescribe().get('DCR_Mapping__c').getDescribe().fields.getMap();
        // compile the csv field list for the objects used
        //querystart SELECT
        HCPfields = '';
        HCOfields = '';
        CAfields = '';
        ADDRfields = '';
        //cycle through the custom settings
        for (Schema.SObjectField sfield : Setting.Values()) {
            String DCRfname = sfield.getDescribe().getName();
            if (DCRfname == 'CreatedById' ||
                    DCRfname == 'CreatedDate' ||
                    DCRfname == 'CurrencyIsoCode' ||
                    DCRfname == 'IsDeleted' ||
                    DCRfname == 'IsLocked' ||
                    DCRfname == 'LastModifiedById' ||
                    DCRfname == 'LastModifiedDate' ||
                    DCRfname == 'SetupOwnerId' ||
                    DCRfname == 'MayEdit' ||
                    DCRfname == 'Name' ||
                    DCRfname == 'Id' ||
                    DCRfname == 'SystemModstamp') continue;

            String value = (String) Mapping.get(DCRfname);
            if (value != null) {
                String obj = value.substringBefore('.');
                String field = value.substringAfter('.');

                if (obj == 'HCP')
                    HCPfields += field + ',';
                if (obj == 'HCO')
                    HCOfields += field + ',';
                if (obj == 'CA')
                    CAfields += field + ',';
                if (obj == 'ADDR')
                    ADDRfields += field + ',';
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The DCR mapping custom settings are missing values for this profile (or in general).'));
            }
        }
        //remove extra commas
        HCPfields = HCPfields.removeEnd(',');
        HCOfields = HCOfields.removeEnd(',');
        CAfields = CAfields.removeEnd(',');
        ADDRfields = ADDRfields.removeEnd(',');
        system.debug('Querys compiled');
    }
    /*****************************************************************************************************************
                                                    ADDRESSLIST FILL
    *****************************************************************************************************************/
    public void addresslistfill() {
        system.debug('addresslistfill started.');
        querycompile();
        if (accid == null) accid = ApexPages.currentPage().getParameters().get('accid');
        if (accid == null) accid = DCR.Professional_DS__c;
        System.debug('accid: ' + accid);
        Addr = new Address_vod__c();
        addrsel = new List<SelectOption>();
        if (accid != null) {
            String ADDRend = '';
            if (ADDRfields.countMatches('Primary_vod__c') < 1) ADDRfields += ', Primary_vod__c';
            ADDRend +=  'SELECT Formatted_Address_BI__c, ' + ADDRfields + ' FROM Address_vod__c where Account_vod__c = \'' + accid + '\' Order by Primary_vod__c DESC';

            System.debug('Addrquery: ' + ADDRend);
            try {
                Addrlist = Database.query(ADDRend);
                if (Addrlist.size() > 0)Addr = Addrlist[0];
            } catch (QueryException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The address related to the workplace cannot be found for the running user: ' + e));
            }

            //add the queried adresses to the selector options

            System.debug('Addrlist: ' + Addrlist);
            if (Addrlist.size() != 0) {
                for (Address_vod__c a : Addrlist) {
                    String alabel = '';
                    if (a.Primary_vod__c == true) alabel += '*';
                    alabel +=  a.Formatted_Address_BI__c;
                    addrsel.add(new SelectOption(a.Id, alabel));
                }
            }
        }
        addrsel.add(new SelectOption('new', DCR_Newaddr));
    }

    /*****************************************************************************************************************
                                                    FIELD ASSIGN
    *****************************************************************************************************************/
    public void fieldassign() { //without param
        Mapping = DCR_Mapping__c.getInstance();
        Setting = Schema.getGlobalDescribe().get('DCR_Mapping__c').getDescribe().fields.getMap();

        system.debug('Field assignment started.');
        system.debug('Setting size: ' + Setting.size());
        for (Schema.SObjectField sfield : Setting.Values()) {
            //if a standard field don't use it
            String DCRfname = sfield.getDescribe().getName();
            //system.debug('DCR field name: '+DCRfname + ' field: ' + sfield.getDescribe());
            if (DCRfname == 'CreatedById' ||
                    DCRfname == 'CreatedDate' ||
                    DCRfname == 'CurrencyIsoCode' ||
                    DCRfname == 'IsDeleted' ||
                    DCRfname == 'IsLocked' ||
                    DCRfname == 'LastModifiedById' ||
                    DCRfname == 'LastModifiedDate' ||
                    DCRfname == 'SetupOwnerId' ||
                    DCRfname == 'MayEdit' ||
                    DCRfname == 'Name' ||
                    DCRfname == 'Id' ||
                    DCRfname == 'SystemModstamp') continue;
            //otherwise
            String value = (String) Mapping.get(DCRfname);
            if (value != null) {
                String obj = value.substringBefore('.');
                String field = value.substringAfter('.');
                system.debug('DCR field name: ' + DCRfname + ' Value: ' + value);
                //if field empty assign a value
                if (DCR.get(DCRfname) != null)continue;
                //special lookup to text cases
                /*if(value=='HCP.University_BI__c'){
                    DCR.University_BI__c = HCP.University_BI__r.Name;
                    continue;
                }
                if(value=='HCP.OK_Individual_Type_BI__c'){
                    DCR.Individual_Type_BI__c = HCP.OK_Individual_Type_BI__r.Name;
                    continue;
                }
                if(value=='HCP.Specialty_3_BI__c'){
                    DCR.Specialty_3_BI__c = HCP.Specialty_3_BI__r.Name;
                    continue;
                }
                if(value=='HCP.OK_Medical_Interest_2_BI__c'){
                    DCR.Medical_Interest_2_BI__c = HCP.OK_Medical_Interest_2_BI__r.Name;
                    continue;
                }
                if(value=='HCP.OK_Medical_Interest_3_BI__c'){
                    DCR.Medical_Interest_3_BI__c = HCP.OK_Medical_Interest_3_BI__r.Name;
                    continue;
                }
                if(value=='HCP.OK_Education_Specialty_2_BI__c'){
                    DCR.Education_Specialty_2_BI__c = HCP.OK_Education_Specialty_2_BI__r.Name;
                    continue;
                }
                if(value=='HCP.OK_Qualification_BI__c'){
                    DCR.Qualification_BI__c = HCP.OK_Qualification_BI__r.Name;
                    continue;
                }*/
                //generic solution
                if (obj == 'HCP')
                    DCR.put(DCRfname, HCP.get(field));
                if (obj == 'HCO')
                    DCR.put(DCRfname, HCO.get(field));
                if (obj == 'CA')
                    DCR.put(DCRfname, CA.get(field));
                if (obj == 'ADDR')
                    DCR.put(DCRfname, ADDR.get(field));
            }//end of ifvalue
        }//end of schema cycle
        if (DCR.BI_Preferred_Address_BI__c != true)DCR.BI_Preferred_Address_BI__c = false;
        if (DCR.Do_Not_Phone_BI__c != true)DCR.Do_Not_Phone_BI__c = false;
        if (DCR.Do_Not_Mail_BI__c != true)DCR.Do_Not_Mail_BI__c = false;
        if (DCR.Parent_Account__c != null && [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :DCR.Parent_Account__c].HasEditAccess != true) DCR.Parent_Account__c = null;
        if (DCR.Health_Insurance_BI__c != true)DCR.Health_Insurance_BI__c = false;
        if (RT.DeveloperName.contains('Existing_Professional_at_New_Workplace')) DCR.Organisation_Account__c = null;
    }
    public void fieldassign(String objname) { //with param, for address - overwrites values

        Mapping = DCR_Mapping__c.getInstance();
        Setting = Schema.getGlobalDescribe().get('DCR_Mapping__c').getDescribe().fields.getMap();

        system.debug('Field assignment started with object: ' + objname);
        system.debug('Setting size: ' + Setting.size());

        for (Schema.SObjectField sfield : Setting.Values()) {
            //if a standard field don't use it
            String DCRfname = sfield.getDescribe().getName();
            if (DCRfname == 'CreatedById' ||
                    DCRfname == 'CreatedDate' ||
                    DCRfname == 'CurrencyIsoCode' ||
                    DCRfname == 'IsDeleted' ||
                    DCRfname == 'IsLocked' ||
                    DCRfname == 'LastModifiedById' ||
                    DCRfname == 'LastModifiedDate' ||
                    DCRfname == 'SetupOwnerId' ||
                    DCRfname == 'MayEdit' ||
                    DCRfname == 'Name' ||
                    DCRfname == 'Id' ||
                    DCRfname == 'SystemModstamp') continue;
            //otherwise
            String value = (String) Mapping.get(DCRfname);
            if (value != null) {
                String obj = value.substringBefore('.');
                String field = value.substringAfter('.');
                //system.debug('DCR field name: '+DCRfname + ' Value: ' + value);

                if (obj == 'HCP' && obj == objname)
                    DCR.put(DCRfname, HCP.get(field));
                if (obj == 'HCO' && obj == objname)
                    DCR.put(DCRfname, HCO.get(field));
                if (obj == 'CA' && obj == objname)
                    DCR.put(DCRfname, CA.get(field));
                if (obj == 'ADDR' && obj == objname)
                    DCR.put(DCRfname, ADDR.get(field));
            }//end of ifvalue
        }//end of schema cycle
        if (DCR.BI_Preferred_Address_BI__c != true)DCR.BI_Preferred_Address_BI__c = false;
        if (DCR.Do_Not_Phone_BI__c != true)DCR.Do_Not_Phone_BI__c = false;
        if (DCR.Do_Not_Mail_BI__c != true)DCR.Do_Not_Mail_BI__c = false;
        if (DCR.Parent_Account__c != null && [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :DCR.Parent_Account__c].HasEditAccess != true) DCR.Parent_Account__c = null;
        if (DCR.Health_Insurance_BI__c != true)DCR.Health_Insurance_BI__c = false;
        if (RT.DeveloperName.contains('Existing_Professional_at_New_Workplace')) DCR.Organisation_Account__c = null;
    }


    private void calculateChangedFields() {

        /* */

        Mapping = DCR_Mapping__c.getInstance();
        Setting = Schema.getGlobalDescribe().get('DCR_Mapping__c').getDescribe().fields.getMap();

        system.debug('calculateChangedFields started.');
        system.debug('Setting size: ' + Setting.size());


        Set<String> changedFieldSet = new Set<String>();

        for (Schema.SObjectField sfield : Setting.Values()) {

            Schema.DescribeFieldResult describeField = sfield.getDescribe();

            String fieldName  = describeField.getName();
            System.debug('(changed Fields) DCR field name: ' + fieldName + ' field: ' + sfield.getDescribe());

            if ( ignoreFieldSet.contains(fieldName) ) {
                // if the field is one of the fields to ignore the skip this for iteration
                System.debug('Skipping field!');
                continue;
            }

            /* */

            //otherwise
            String value = (String) Mapping.get(fieldName);
            if (value != null) {
                String obj = value.substringBefore('.');
                String field = value.substringAfter('.');
                system.debug('(changed Fields) DCR field name: ' + fieldName + ' Value: ' + value);


                if ( String.isBlank(obj) || String.isBlank(field) ) {
                    System.debug('Unable to determine obj/field from value: ' + value);
                    continue;
                }

                Object theStoredValue;
                Object theNewValue = DCR.get(fieldName);


                if ( obj == 'HCP' && HCP != null ) {
                    theStoredValue = HCP.get(field);
                } else if ( obj == 'HCO' && HCO != null ) {
                    theStoredValue = HCO.get(field);
                } else if ( obj == 'CA'  && CA != null) {
                    theStoredValue = CA.get(field);
                } else if (obj == 'ADDR' && ADDR != null) {
                    theStoredValue = ADDR.get(field);
                } else {
                    System.debug('Unable to figure out object type! obj: ' + obj);
                    continue;
                }

                String message;

                Boolean valuesAreEqual  = ( theStoredValue == theNewValue );
                Boolean newValueIsBlank = false;

                if ( theNewValue == null ) newValueIsBlank = true;

                if ( theNewValue instanceOf String ) {
                    if ( String.isBlank((String) theNewValue) ) {
                        newValueIsBlank = true;
                    }
                }

                if ( theNewValue instanceOf Boolean ) {
                    if ( theNewValue == false && theStoredValue == null ) {
                        valuesAreEqual = true;
                    }
                }



                if ( valuesAreEqual || newValueIsBlank ) {
                    message = 'Field is unchanged';
                } else {

                    List<Schema.DescribeSObjectResult> describeSobjectsResult =
                        Schema.describeSObjects(new List<String> { 'V2OK_Data_Change_Request__c' });
                    System.debug(describeSobjectsResult);
                    Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();
                    String fieldLabel = allFields.get(fieldName).getDescribe().getLabel();

                    // Field has changed
                    changedFieldSet.add(fieldLabel);
                    message = 'Field HAS changed';

                }
                message +=
                    ' ('
                    + fieldName
                    + ') old value: \''
                    + theStoredValue
                    + '\' new value: \''
                    + theNewValue
                    + '\''
                    ;
                System.debug(message);
            }
        }

        if ( changedFieldSet.isEmpty() ) {
            DCR.Changed_Fields_BI__c = '(no changed fields)';
        } else {
            String changedFieldString = '';
            List<String> changedFieldList = new List<String>();
            changedFieldList.addAll(changedFieldSet);
            changedFieldList.sort();

            for (String changedField : changedFieldList) {
                changedFieldString += changedField + '\r\n';
            }

            // Use the trimmed version (strips out the trailing newline chars)
            DCR.Changed_Fields_BI__c = changedFieldString.trim();
        }
    }

    /*****************************************************************************************************************
                                                    SAVE
    *****************************************************************************************************************/
    //SAVE the record and go to summary mode on edit
    public PageReference summary() {


        // Raphael - fix empty/missing Description (REQUEST_COMMENT) field.
        if ( String.isBlank(DCR.Description__c) ) {
            DCR.Description__c = RT.Name;
        }

        // Save unnecesary whitespace. Also just in case the RecordType accidently has a newline at the end, etc.
        DCR.Description__c = DCR.Description__c.trim();


        // Added newline test - Raphael 2014-07-17
        // if description contains a newline then don't save - report the error

        // We test by splitting the string on newline characters, and seeing if more than one element is returned
        // More than one element means a newline is present
        List<String> newlineSplitList = DCR.Description__c.split('[\\n\\r]');
        if ( newlineSplitList.size() > 1 ) {
            String error = 'Description cannot contain newline characters';
            ApexPages.Message errorMessage
                = new ApexPages.Message(ApexPages.Severity.ERROR, error);
            ApexPages.addMessage(errorMessage);
            return null;
        }

        /*
        // Added by Raphael 2014-10-15
        if ( isDS ) {
            DCR.Status = DCR.Activity_Status_BI__c;
        }
        */


        dupes = new list<Account>();
        //string descr = '';
        //descr += DCR.Description__c;
        //system.debug('devname: ' + DCR.RecordType.Developername);
        if ( DCR.Change_Type__c == 'Create'
                && !(RT.DeveloperName.contains('Hierarchy'))
                && (
                    DCR.First_Name__c != null
                    || DCR.Last_Name__c != null
                    || DCR.New_Account_Name__c != null
                )
           ) {
            //when is dupe searching is viable

            String nameSearchString;
            // Boolean personsearch = false;
            //if (DCR.First_Name__c != null && DCR.Last_Name__c != null) {
            if ( person ) {
                //if person account
                nameSearchString = DCR.First_Name__c + ' ' + DCR.Last_Name__c;
                // personsearch = true;
            } else {
                //if business account
                nameSearchString = DCR.New_Account_Name__c;
            }

            if ( ! String.isBlank(nameSearchString) ) {
                dupes =
                    (List<Account>)[
                        FIND :nameSearchString IN NAME FIELDS
                        RETURNING Account
                        (
                            Name,
                            Recordtype.Name,
                            Primary_Parent_vod__c,
                            Status_BI__c,
                            Phone,
                            Country_code_bi__c
                            WHERE isPersonAccount = :person
                                                    AND Country_code_bi__c = :DCR.Country_DS__c
                        )
                        LIMIT 10
                    ][0];
            }
        }

        calculateChangedFields();

        if (dupelist || dupes.size() == 0) { //if the list have been displayed, or no items to show
            try {
                system.debug('Upserting DCR: ' + DCR);
                upsert DCR;
            } catch (DMLException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                return null;
            }
            system.debug('Upserted line 1: ' + DCR.New_Address_Line_1__c);
            RTselect = false;
            edit = false;
            detail = true;
            //system.debug('isDS: ' + isDS);
        }
        dupelist = true;
        applist = (detail && isDS);
        //a simple refresh misses the related lists, so return the url for refresh
        string url = '';
        if (DCR.Id != null) {
            url = '/' + DCR.Id;
            PageReference DS = new PageReference(url);
            system.debug('Upserted line 1 before refresh: ' + DCR.New_Address_Line_1__c);
            return DS;
        } else {
            return null;
        }
    }
    /*****************************************************************************************************************
                                                    SMALL BUTTONS
    *****************************************************************************************************************/
    //clone
    public PageReference cloneDCR() {
        V2OK_Data_Change_Request__c newDCR = DCR.clone(false);

        try {
            insert newDCR;
        } catch (DmlException e) {
            ApexPages.addMessages(e);
            return null;
        }

        String editurl = '';
        editurl += '/apex/VEEVA_DCR?id=' + newDCR.Id + '&retURL=' + DCR.Id;
        PageReference DS = new PageReference(editurl);
        return DS;
    }

    //canceledit (return to acc or to list wherever came from) on edit
    public PageReference canceledit() {
        String editurl = '';
        if (ApexPages.currentPage().getParameters().get('accid') != null) {
            editurl += '/' + accid;
        } else {
            editurl += '/' + egid;
        }
        PageReference DS = new PageReference(editurl);
        return DS;
    }
    //returnto list on summary and RTselection
    public PageReference retlist() {
        String editurl = '';
        editurl += '/' + egid;
        PageReference DS = new PageReference(editurl);
        return DS;
    }
    //return to account on summary
    public PageReference retacc() {
        String editurl = '';
        editurl += '/' + accid;
        PageReference DS = new PageReference(editurl);
        return DS;
    }
    //delete on summary
    public PageReference del() {
        delete DCR;
        String editurl = '';
        editurl += '/' + egid;
        PageReference DS = new PageReference(editurl);
        return DS;
    }
    //edit on summary
    public PageReference editDCR() {
        RTselect = false;
        edit = true;
        detail = false;
        dupelist = false;
        applist = (detail && isDS);
        if (showAddrSelect == true) addresslistfill();
        return null;
    }
    /*****************************************************************************************************************
                                                    ADDRESS SELECT
    *****************************************************************************************************************/
    //ADDRESS SELECT
    public PageReference addrefresh() {
        system.debug('address changed to: ' + addrvalue);
        if (addrvalue == 'new') {
            Addr = new Address_vod__c();
            fieldassign('ADDR');
            DCR.Address__c = null;
        } else {
            String ADDRend2 = 'SELECT Formatted_Address_BI__c, ' + ADDRfields + ' FROM Address_vod__c where Id = \'' + addrvalue + '\' LIMIT 1';
            System.debug('ADDRend2: ' + ADDRend2);
            Addr = Database.query(ADDRend2);
            fieldassign('ADDR');
        }
        system.debug('DCR address after: ' + DCR.Address__c);
        return null;
    }
    /*****************************************************************************************************************
                                                    ACCOUNT LOOKUP SELECT
    *****************************************************************************************************************/
    public PageReference hcprefresh() {
        system.debug('hcp changed to: ' + DCR.Professional_DS__c );
        querycompile();
        String HCPend2 = 'SELECT  ' + HCPfields + ' FROM Account where Id = \'' + DCR.Professional_DS__c + '\' LIMIT 1';
        System.debug('HCPend2: ' + HCPend2);
        HCP = Database.query(HCPend2);

        if (RT.DeveloperName.contains('Existing_Professional_at_New_Workplace')) {
            fieldassign('HCP');
        } else {
            if (pageprefilled)fieldassign();
            else pageprefill();
        }

        return null;
    }
    public PageReference hcorefresh() {
        system.debug('hco changed to: ' + DCR.Organisation_Account__c );
        querycompile();
        if (DCR.Organisation_Account__c != null) {
            String HCOend2 = 'SELECT  ' + HCOfields + ' FROM Account where Id = \'' + DCR.Organisation_Account__c + '\' LIMIT 1';
            System.debug('HCOend2: ' + HCOend2);
            HCO = Database.query(HCOend2);
        }
        if (pageprefilled) {
            fieldassign(); //assign empty field
            fieldassign('HCO'); //overwrite HCO ones
        } else pageprefill();

        return null;
    }

}