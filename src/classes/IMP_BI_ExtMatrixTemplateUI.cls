/**
 *  extension class for matrix
 *
 @author Yuanyuan Zhang
 @created 2013-05-06
 @version 1.0
 @since 26.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-05-08 Haobo Song <haobo.song@itbconsult.com>
 * - Matrix Template Cell table creation
 * 2013-05-06 Yuanyuan Zhang <yuanyuan.zhang@itbconsult.com>
 * - Created
 */
public class IMP_BI_ExtMatrixTemplateUI {
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    public string mode{get; private set;}
    //public Boolean launchMode{get;set;}
    public String editMode{get;private set;}
    public String potValue{get;set;}
    public String intValue{get;set;}
    //public Boolean isLaunch{get;set;}
    public Lifecycle_Template_BI__c theMT{get;set;}
    public Boolean isAdmin{get;set;}
    public List<SelectOption> countries {get;private set;}
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    private map<String, String> map_urlParams; 
    //private Lifecycle_Template_BI__c theMT;
    private static final string SUCC = 'SUCCESS';
    private static final string ERROR = 'ERROR'; 
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=-   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    /////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
    public IMP_BI_ExtMatrixTemplateUI(ApexPages.standardController sc){
        theMT = (Lifecycle_Template_BI__c) sc.getRecord();
        map_urlParams = ApexPages.currentPage().getParameters();
        mode = '1';
        //Load countries
        
        countries = new List<SelectOption>();
        countries.add(new SelectOption('','--None--')); 
        for(Country_BI__c c : [Select Id,Name From Country_BI__c]){
        	countries.add(new SelectOption(c.Id,c.Name));
        }
        
        isAdmin = isAdmin();
        ////TODO: Ask for the global scenario
        //launchMode = false;
        //isLaunch = false;
        
        if(theMT.Id == null){
            editMode = 'no';
            //only for test
            theMT.name = 'New';
            //system.debug('yyretURL: ' + map_urlParams.get('retURL'));
            Country_BI__c coun;
            if(map_urlParams.containsKey('retURL')){
                String counId = map_urlParams.get('retURL');
                counId = counId.subString(1, counId.length());
                theMT.Country_BI__c = counId;
                system.debug('counId: ' + counId);
                coun= [SELECT Id,Name FROM Country_BI__c where id = :counId];
                
            }
            else{
                coun= [SELECT Id,Name FROM Country_BI__c Limit 1];
                if(coun != null){
                    theMT.Country_BI__c = coun.Id;
                }
                
            }
            
            theMT.Area_BI__c = 'Local';
            if(coun.Name.equalsIgnoreCase('Global')){
            	theMT.Area_BI__c = 'Global';
            }
            
            
            //theMT.Product_Lifecycle__c = 'Growth';
            //theMT.Area_BI__c = 'Global';
            theMT.Row_BI__c = 10;
            theMT.Column_BI__c = 10;
            //theMT.Dimension_1_Name__c = 'D1';
            //theMT.Dimension_2_Name__c = 'D2';
            //theMT.Growth_Weighting_Factor__c = 1.2;
            //theMT.Decline_Weighting_Factor__c = 0.2;
            //theMT.Launch_Weighting_Factor__c = 1.8;
            //theMT.Maturity_Weighting_Factor__c = 0.7;
            theMT.Adoption_Weight_Factor_BI__c = 1.2;
            theMT.Potential_Weight_Factor_BI__c = 0.8;
            theMT.isLaunch_Phase_BI__c = false;
            theMT.Active_BI__c = true;
        }
        else{
            theMT = [SELECT Id,isLaunch_Phase_BI__c,Area_BI__c,Row_BI__c,Column_BI__c,Active_BI__c,Description_BI__c,
            				Adoption_Weight_Factor_BI__c,Potential_Weight_Factor_BI__c,Name,Country_BI__c,
            				Adoption_Status_01_BI__c,Adoption_Status_02_BI__c,Adoption_Status_03_BI__c,Adoption_Status_04_BI__c,Adoption_Status_05_BI__c,
            				Potential_Status_01_BI__c,Potential_Status_02_BI__c,Potential_Status_03_BI__c,Potential_Status_04_BI__c,Potential_Status_05_BI__c 
                     FROM Lifecycle_Template_BI__c WHERE Id = :theMT.Id limit 1];
            /*if(theMT.isLaunch_Phase__c){Dimension_1_Name__c,Dimension_2_Name__c,
                launchMode = true;
            }*/
            //mode = '1';
            editMode = 'yes';
            
            //2013-07-02 added by Yuanyuan Zhang if country is global, set area global.
            //theMT.Area_BI__c = theMT.Country_BI__r.Name == 'Global'?'Global':'Local';
            //Country_BI__c cou = [SELECT Id, Name FROM Country_BI__c WHERE Id = :theMT.Country_BI__c];
            /*if(cou != null){
            	if(cou.Name == 'Global'){
            		String profilId = UserInfo.getProfileId();
            		SystemAdminProfil__c sap = SystemAdminProfil__c.getInstance('Admin Profil');
            		if(!profilId.equalsIgnoreCase(sap.AdminId__c)){
            			isAdmin = false;
            		}
            	}
            }*/
        }
        
    }
    /////////////////////////////////// -=END CONSTRUCTOR=- /////////////////////////////////////
    
    
  	private Boolean isAdmin (){
		Boolean isAdmin = false;
		
		//TODO: Ask for the global scenario
        //if(theMT.Area_BI__c == 'Global'){
		String profilId = UserInfo.getProfileId().subString(0,15);
		Map<String, SystemAdminProfil__c> mapAdmin = SystemAdminProfil__c.getAll();
		
		system.debug(':: Id profile: '  + profilId + ' Admin Setting: ' + mapAdmin);
		
		//jescobar: Validate multiple users with permissions  to update global templates 
		for(SystemAdminProfil__c sap : mapAdmin.values()){
			if(profilId.equalsIgnoreCase(sap.AdminId__c)){
				isAdmin = true;
				break;
			}
    	}
    		
    		/**jescobar: Modified to apply for multiple users admin
    			SystemAdminProfil__c sap = SystemAdminProfil__c.getInstance('Admin Profil');
    		/**if(!profilId.equalsIgnoreCase(sap.AdminId__c)){
    			isAdmin = false;
    		}*/
    	//}
		
		return isAdmin;  	
  	}
    
    
    //********************************* -=BEGIN public methods=- ************************************
    /**
    * This method is to create matrix template and matrix cell template
    *
    @author Haobo Song
    @created 2013-05-08
    @version 1.0
    @since 26.0 (Force.com ApiVersion)
    *
    *
    @return null
    *
    @changelog
    * 2013-05-08 Haobo Song <haobo.song@itbconsult.com>
    * - Created
    */  
    public pageReference create() {
        /*if(theMT.Product_Lifecycle__c.equalsIgnoreCase('launch')){
            if(String.isBlank(theMT.Adoption_Status_01_BI__c)
            || String.isBlank(theMT.Adoption_Status_02_BI__c)
            || String.isBlank(theMT.Adoption_Status_03_BI__c)
            || String.isBlank(theMT.Adoption_Status_04_BI__c)
            || String.isBlank(theMT.Adoption_Status_05_BI__c)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'please define adoption status!'));
                mode = '0';
                return null;
            }
            if(String.isBlank(theMT.Potential_Status_01_BI__c)
            || String.isBlank(theMT.Potential_Status_02_BI__c)
            || String.isBlank(theMT.Potential_Status_03_BI__c)
            || String.isBlank(theMT.Potential_Status_04_BI__c)
            || String.isBlank(theMT.Potential_Status_05_BI__c)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'please define potential status!'));
                mode = '0';
                return null;
            }
        }*/
        mode = '1';
        return null;
    }
    
    /**
    * This method is to get the matrix template as JSON
    *
    @author Haobo Song
    @created 2013-05-08
    @version 1.0
    @since 26.0 (Force.com ApiVersion)
    *
    *
    @return the matrix template in JSON
    *
    @changelog
    * 2013-05-08 Haobo Song <haobo.song@itbconsult.com>
    * - Created
    */  
    public string getMT() {
        return JSON.serialize(theMT);
    }
    
    /*public pageReference showHideAdoption(){
    	system.debug('yylaunch: ' + theMT.isLaunch_Phase__c);
        if(theMT.isLaunch_Phase__c){
            launchMode = true;
        }
        else{
            launchMode = false;
        }
        return null;
    }*/
    
    
    /**
    * This method is to save the matrix template and its underlying cells
    *
    @author Haobo Song
    @created 2013-05-08
    @version 1.0
    @since 26.0 (Force.com ApiVersion)
    *
    *
    @return null
    *
    @changelog
    * 2013-05-08 Haobo Song <haobo.song@itbconsult.com>
    * - Created
    */
    @RemoteAction
    public static string saveMT(string inMTJSON) {
        ClsResponse r = new ClsResponse();
        r.success = true;
        r.message = SUCC;
        try{
            ClsMatrixTemplate clstemplate = (ClsMatrixTemplate)JSON.deserialize(inMTJSON, ClsMatrixTemplate.class);
            //system.debug('@@@@@@@@@@');
            //system.debug(template);
            Lifecycle_Template_BI__c template2insert = clstemplate.mt;
            //list<Matrix_Cell_Template__c> list_mct2insert = clstemplate.list_mct;
            insert template2insert;
            //for(Matrix_Cell_Template__c mct: list_mct2insert){
            //    mct.Matrix_Template__c = template2insert.Id;
            //}
            //insert list_mct2insert;
        }catch(Exception ex){
            r.success = false;
            r.message = ex.getMessage();
        }
        return JSON.serialize(r);
    }
    
    /**
    * This method is to save the matrix template and its underlying cells
    *
    @author Haobo Song
    @created 2013-05-08
    @version 1.0
    @since 26.0 (Force.com ApiVersion)
    *
    *
    @return null
    *
    @changelog
    * 2013-05-08 Haobo Song <haobo.song@itbconsult.com>
    * - Created
    */
    @RemoteAction
    public static string editMT(string inMTJSON) {
        ClsResponse r = new ClsResponse();
        r.success = true;
        r.message = SUCC;
        try{
            ClsMatrixTemplate clstemplate = (ClsMatrixTemplate)JSON.deserialize(inMTJSON, ClsMatrixTemplate.class);
            //system.debug('@@@@@@@@@@');
            //system.debug(template);
            Lifecycle_Template_BI__c template2update = clstemplate.mt;
            //list<Matrix_Cell_Template__c> list_mct2insert = clstemplate.list_mct;
            update template2update;
            //for(Matrix_Cell_Template__c mct: list_mct2insert){
            //    mct.Matrix_Template__c = template2insert.Id;
            //}
            //insert list_mct2insert;
        }catch(Exception ex){
            r.success = false;
            r.message = ex.getMessage();
        }
        return JSON.serialize(r);
    }
    
   /**
    * This method is to verify the country
    *
    @author  Peng Zhu
    @created 2013-07-17
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @param	 inCountryName	country name
    *
    @return  r				instance of ClsResponse
    *
    @changelog
    * 2013-07-17 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */
    @RemoteAction
    public static string verifyCountry(string inCountryName) {
        ClsResponse r = new ClsResponse();
        r.success = true;
        r.message = SUCC;
        try{
			if(inCountryName != null && inCountryName.trim() != ''){
				list<Country_BI__c> list_c = [SELECT Id, Name FROM Country_BI__c WHERE Name = :inCountryName];
				
				if(list_c != null && !list_c.isEmpty()){
					if(list_c.size() > 1){
						r.success = false;
           				r.message = 'Multiple items found. Please click icon to refine search.';
					}
					else{
						r.countryId = list_c[0].Id;
					}
				}
				else{
					r.success = false;
           			r.message = 'No matches found.';
				}
			}
			else{
	            r.success = false;
            	r.message = 'Invalid country name.';
			}
        }catch(Exception ex){
            r.success = false;
            r.message = ex.getMessage();
        }
        return JSON.serialize(r);
    }
    //********************************* -=END public methods=- **************************************
    
    
    //********************************* -=BEGIN private methods=- ************************************
    
    //********************************* -=BEGIN inner classes=- **************************************
    public class ClsMatrixTemplate {
        public Lifecycle_Template_BI__c mt;
        //public list<Matrix_Cell_Template__c> list_mct;
    }
    
    public class ClsResponse {
        public boolean success;
        public string message;
        
        public string countryId;//added by Peng Zhu 2013-07-17 for verifying the country
        
        public ClsResponse () {
            success = true;
            message = '';
            
            countryId = '';
        }
    }
    //********************************* -=END inner classes=- ****************************************  
    
}