/*
 * Changelog
 *
 * Date: 2014-08-19
 * By:   Raphael Krausz <raphael.krausz@veeva.com>
 * Description:
 *    Fixed bug. Changed Name value for PermissionSet lookup from 'Regional_Manager' to 'CORE_NSM_COACHING_PERMISSION'
 *
 */

public without sharing class VEEVA_CR_Extension
{
    
    //context object 
    private final Coaching_Report_vod__c CRobj;
    
    public integer total_size=0; //used to show user the total size of the list
    private integer counter=0;  //keeps track of the offset
    /************************************************
    CHANGE THIS VALUE IF YOU WANT TO CHANGE LIST SIZE
    *************************************************/    
    private integer list_size=20; //sets the page size or number of rows 
    
    //collectio of objects displayed on the GRID
    public list<DisplaySmtg> ObjectsToDisplay {get; set;}
       
    public list<CFE_Rep_Behavior_BI__c> Init_Bs {get; set;}
    
    private Map<CFE_Rep_Behavior_BI__c, String>  templateList;  //probably not needed anymore
    
    set<id> compfilter = new set<id>();
    set<id> actfilter = new set<id>();
    
    //just to be displayed on the header 
    public String ContextObject {get; set;}
    
    //boolean deciding if the page is approved and read-only
    public boolean approved {set;get;}
    
    //custom labels
    public String CR_TITLE {set;get;}
    public String CR_ADD {set;get;}
    public String CR_ADV {set;get;}
    public String CR_TEM {set;get;}
    public String CR_ACT {set;get;}
    public String CR_COMP {set;get;}
    public String CR_COLBEH {set;get;}
    public String CR_COLACT {set;get;}
    public String CR_COLCOMP {set;get;}
    public String CR_NTEM {set;get;}
    public String CR_NACT {set;get;}
    public String CR_NCOMP {set;get;}
    public String CR_TOTAL {set;get;}
    public String CR_RETURN {set;get;}
    public String CR_ADDED {set;get;}
    public String CR_APPROVED {set;get;}
    
  
    //get user country code
      id id1 = userinfo.getUserId();
      user[] u = [select Country_code_BI__c from user where id = :id1 limit 1];
      String c = u[0].Country_code_BI__c;
    
    //Do not allow non-regional managers to add Behaviors to CRs created by Regional Managers
     public Boolean RegionalManagerDisable {get;set;}
     
    /*******************************************************************
    CONSTRUCTOR
    *******************************************************************/ 
    public VEEVA_CR_Extension(ApexPages.StandardController stdController)
    {
      //display everything normally
      approved = false;
      system.debug('constructor started');
      //get context object form Controller   
      this.CRobj = (Coaching_Report_vod__c)stdController.getRecord();
      
      Coaching_Report_vod__c myCR = [Select Id, CreatedById from Coaching_Report_vod__c where Id = :CRobj.Id];

      //WA-9/4/2014  
      //Setup Regional Manager logic

      // Updated by Raphael Krausz 2014-09-18 changed name for PermissionSet
      //Id RMPermSet = [Select Id from PermissionSet where Name = 'Regional_Manager' LIMIT 1].Id;
      Id RMPermSet = [Select Id from PermissionSet where Name = 'CORE_NSM_COACHING_PERMISSION' LIMIT 1].Id;      
      List<PermissionSetAssignment> currentUserPSA = [Select Id from PermissionSetAssignment where AssigneeId = :UserInfo.GetUserId() and PermissionSetId = :RMPermSet];
      List<PermissionSetAssignment> creatingUserPSA = [Select Id from PermissionSetAssignment where AssigneeId = :myCR.CreatedById and PermissionSetId = :RMPermSet];
      
      if(creatingUserPSA.IsEmpty()) {
          RegionalManagerDisable = false;
      }
      else if(currentUserPSA.IsEmpty()) {
          RegionalManagerDisable = true;
      }
      else {
          RegionalManagerDisable = false;
      }
      
      //get coaching report status to disable page if necessary
      String status = CRobj.Status__c;
      if(status == 'Approved') approved = true;
      
      //define used maps&list
      templateList  = new Map<CFE_Rep_Behavior_BI__c,String>();
      
      Init_Bs = new list<CFE_Rep_Behavior_BI__c>();   
      
      //InitBehaviourListWithTemplates();  //mayee no longer needed //confirmed :)

      //build template relationship
      //BulidB_T_Relationship();
    
   
      // do label translation
      collectLanguageSpecificLabels();
      
      //load to bg 
      InitgridB();
      system.debug('refresh list');
      
      //render eleements with the refresh command
      RefreshFfilterdList();             
    }
    
    
    //Added by Erik Dozsa, 2013.05.06.
    //Custom label translation according to user's language setup - logic from 'Global Account Search' solution
    public void collectLanguageSpecificLabels()
    {
        
        String lang = UserInfo.getLanguage();
        
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'User Language is: ' + lang)); 
        
        // Get labels from Message_vod__c for user's language
        Message_vod__c [] labels = [ select Name,
                                            Text_vod__c 
                                     from   Message_vod__c 
                                     where  Language_vod__c = :lang 
                                     and    Category_vod__c = 'Coach Report' 
                                     //and  Name in ('CR_ADDED','CR_TITLE','CR_ADD','CR_ADV','CR_TEM','CR_ACT','CR_COMP','CR_COLBEH','CR_COLACT','CR_COLCOMP','CR_NTEM','CR_NACT','CR_NCOMP','CR_TOTAL', 'CR_RETURN') 
                                     and    Active_vod__c = true ];
                                    
        Map <String,String> labelMap = new Map <String,String> ();
        
        for (Message_vod__c label : labels) 
        {
            labelMap.put(label.Name, label.Text_vod__c);
        }
        //handle the situation when the Label does not exists in the Message obj
        //x ? y : z
        CR_TITLE = labelMap.get('CR_TITLE') != null ? labelMap.get('CR_TITLE') : 'Coaching Report';
        CR_ADD = labelMap.get('CR_ADD') != null ? labelMap.get('CR_ADD') : 'Add';
        CR_ADV = labelMap.get('CR_ADV') != null ? labelMap.get('CR_ADV') : 'Apply Filters for the grid below.';
        CR_TEM = labelMap.get('CR_TEM') != null ? labelMap.get('CR_TEM') : 'Template:';
        CR_ACT = labelMap.get('CR_ACT') != null ? labelMap.get('CR_ACT') : 'Activity:';
        CR_COMP = labelMap.get('CR_COMP') != null ? labelMap.get('CR_COMP') : 'Competency:';
        CR_COLBEH = labelMap.get('CR_COLBEH') != null ? labelMap.get('CR_COLBEH') : 'Behaviour';
        CR_COLACT = labelMap.get('CR_COLACT') != null ? labelMap.get('CR_COLACT') : 'Activity';
        CR_COLCOMP = labelMap.get('CR_COLCOMP') != null ? labelMap.get('CR_COLCOMP') : 'Competency';
        CR_NTEM = labelMap.get('CR_NTEM') != null ? labelMap.get('CR_NTEM') : 'None - Select Template';
        CR_NACT = labelMap.get('CR_NACT') != null ? labelMap.get('CR_NACT') : 'None - Select Activity';
        CR_NCOMP = labelMap.get('CR_NCOMP') != null ? labelMap.get('CR_NCOMP') : 'None - Select Competency';
        CR_TOTAL = labelMap.get('CR_TOTAL') != null ? labelMap.get('CR_TOTAL') : 'Showing Page # ';
        CR_RETURN = labelMap.get('CR_RETURN') != null ? labelMap.get('CR_RETURN') : 'Return to ';
        CR_ADDED = labelMap.get('CR_ADDED') != null ? labelMap.get('CR_ADDED') : 'Behaviours have been added.';
        CR_APPROVED = labelMap.get('CR_APPROVED') != null ? labelMap.get('CR_APPROVED') : 'The Coaching Report cannot be modified/deleted because it has already been approved.';
    }    
    //end of translation section 
   

   
    
    public string Selected_ActivityFilter;
    
    public string getSelected_ActivityFilter(){
        system.debug('Getting Selected_ActivityFilter: '+Selected_ActivityFilter);
        return Selected_ActivityFilter;
    }
    public string setSelected_ActivityFilter(String s){
        system.debug('Setting Selected_ActivityFilter: '+s);
        Selected_ActivityFilter = s;
        return Selected_ActivityFilter;
    }
    
    /************************************************
    Collect all  activities from custom object
    CFE_Rep_Activity_BI__c    
    ************************************************/
    public list<SelectOption> getListActivityItems() 
    {
        system.debug('getListActivityItems');
        system.debug('actfilter size: ' + actfilter.size());
        system.debug('Selected_ActivityFilter: '+Selected_ActivityFilter);
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',CR_NACT));
        CFE_Rep_Activity_BI__c[] Cs;
        
        if(actfilter.size()<1){
            Cs = [select Id, Name  from CFE_Rep_Activity_BI__c
                                       where Country_Code_BI__c = :c
                                       order by Name
                                      ];
            
        }else{
            Cs = [select Id, Name  from CFE_Rep_Activity_BI__c
                                       where Country_Code_BI__c = :c
                                       and Id IN :actfilter
                                       order by Name
                                      ];
        }
        
        
        for (CFE_Rep_Activity_BI__c c : Cs)
        {
        options.add(new SelectOption(c.Id,c.Name)); 
        }
        
        //RefreshFfilterdList();
        return options;
    }
    
    public string Selected_CompetencyFilter {get; set;} 
    
    /************************************************
    Collect all  competencies from custom object
    CFE_Rep_Competency_BI__c
    ************************************************/
    public list<SelectOption> getListCompetencyItems() 
    {
        system.debug('getListCompetencyItems');
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',CR_NCOMP));
        CFE_Rep_Competency_BI__c[] Cs;
        
        if(compfilter.size()<1){
            Cs = [select Id, Name  from CFE_Rep_Competency_BI__c
                                        where Country_Code_BI__c = :c
                                        
                                        order by Name
                                        ];
        }else{
            Cs = [select Id, Name  from CFE_Rep_Competency_BI__c
                                        where Country_Code_BI__c = :c
                                        and Id IN :compfilter
                                        order by Name
                                        ];
        }
        
        
        for (CFE_Rep_Competency_BI__c c : Cs)
        {
        options.add(new SelectOption(c.Id,c.Name)); 
        }
        
        return options;
    }   
    
     public string Selected_TemplateFilter {get; set;}   
     
    /************************************************
    Collect all  competencies from custom object
    CFE_Rep_Competency_BI__c
    ************************************************/
  
       
    public list<SelectOption> getListTemplateItems() 
    {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('none',CR_NTEM));
        
        Coaching_Template_BI__c[] Ts = [select Id, Name  from Coaching_Template_BI__c
                                        where Country_Code_BI__c = :c
                                        order by Name
                                        ];
        
        for (Coaching_Template_BI__c t : Ts)
        {
        options.add(new SelectOption(t.Name,t.Name));   
        }
        
        return options;
    }
    
    /********************************************
    LIST PAGINATION FUNCTIONS
    ********************************************/
       public PageReference Beginning() { //user clicked beginning
          counter = 0;
          RefreshFfilterdList();
                
          return null;
       }
     
       public PageReference Previous() { //user clicked previous button
          counter -= list_size;
          RefreshFfilterdList();
                 
          return null;
       }
     
       public PageReference Next() { //user clicked next button
          counter += list_size;
          RefreshFfilterdList();
                  
          return null;
       }
     
       public PageReference End() { //user clicked end
          counter = total_size - math.mod(total_size, list_size);
          RefreshFfilterdList();
                  
          return null;
       }
     
       public Boolean getDisablePrevious() { 
          //this will disable the previous and beginning buttons
          if (counter>0) return false; else return true;
       }
     
       public Boolean getDisableNext() { //this will disable the next and end buttons
          if (counter + list_size < total_size) return false; else return true;
       }
     
       public Integer getTotal_size() {
          return total_size;
       }
     
       public Integer getPageNumber() {
          return counter/list_size + 1;
       }
     
       public Integer getTotalPages() {
          if (math.mod(total_size, list_size) > 0) {
             return total_size/list_size + 1;
          } else {
             return (total_size/list_size);
          }
       }
    
    
    
    
    /******************************************************** *********************
    get the Data from DB.
    /* ****************************************************************************/
    //heap excessive
    private void InitgridB()
    { 
        system.debug('InitgridB started');
        
        CFE_Rep_Behavior_BI__c[] Bs = [select ID, Name,
                                                   Activity_BI__c,
                                                   Competency_BI__c,
                                                   Activity_BI__r.Name,
                                                   Competency_BI__r.Name
                                                   from CFE_Rep_Behavior_BI__c
                                                   where Country_Code_BI__c = :c
                                                   order by Name
                                                   //limit 100
                                                   //limit :list_size 
                                                   //offset :counter //offset SOQL is not recognized by eclipse
                                                  ];
                                                  
       ObjectsToDisplay = new list<DisplaySmtg>();                                                
        
        
        
        for (CFE_Rep_Behavior_BI__c B :Bs)
        { 
            Init_Bs.add(B);
            //ObjectsToDisplay.add(new DisplaySmtg(B));
        }             
    
        
    }   

    
    
    /************************************************************************************************
    Build a comma separated string from templates to which the Behaviour belongs too
    ************************************************************************************************/
    public void BuildTempListMap(CFE_Rep_Behavior_BI__c pB, Coaching_Template_Behavior_BI__c[] pCTs)
    {
        String st = ',';
        
        for (Coaching_Template_Behavior_BI__c CT : pCTs)
        {
            st = st  + CT.Name + ',';
        }
        
        templateList.put(pB,st);    
    } 
    
    
    /***********************************************************************************************
    REFRESH-RENDER LIST
    Iterate through the InitList  and
    sort out the filtered items.
    ***********************************************************************************************/
    public void RefreshFfilterdList()
    {
    system.debug('RefreshFfilterdList');
    
    String Act;
    String Comp;
    String Tempu;
    //Integer rec = 0;
    //Boolean mod = true;
    Integer cycle = 0;
    total_size=0;
    compfilter = new set<id>();
    actfilter = new set<id>();
    map<id, String> CTBmap = new map<id, String>();
    
        ObjectsToDisplay = new list<DisplaySmtg>();
         
        
        system.debug('Init_Bs.size():' + Init_Bs.size());
        if (this.Init_Bs.size() > 0)
        {
            //for(Integer i=counter; i<Init_Bs.size() && i<(counter+list_size); i++)
            
            //total_size = Init_Bs.size();
            
            //if the template is selected, get the appropriate map for it
            if (this.Selected_TemplateFilter != 'none' && this.Selected_TemplateFilter != null){
                Coaching_Template_Behavior_BI__c[] CTBs = [Select Behavior_BI__c, Coaching_Template_BI__r.Name
                                              From Coaching_Template_Behavior_BI__c where Coaching_Template_BI__r.Name = :this.Selected_TemplateFilter];
                                              
                for(Coaching_Template_Behavior_BI__c CTB : CTBs){
                    CTBmap.put(CTB.Behavior_BI__c, CTB.Coaching_Template_BI__r.Name);
                }                              
                        
            }
            
            
            for(CFE_Rep_Behavior_BI__c Bu :Init_Bs)
            {
                //if match the filter add to display list
                //CFE_Rep_Behavior_BI__c Bu = Init_Bs[i];
                                                                        
                Act = Bu.Activity_BI__c;
                Comp = Bu.Competency_BI__c; 
                
                
                DisplaySmtg Dobj = new DisplaySmtg(Bu); 
                
                system.debug('Selected_ActivityFilter:' + this.Selected_ActivityFilter);
                if (this.Selected_ActivityFilter != '' && this.Selected_ActivityFilter != null)
                    {
                    if (Selected_ActivityFilter != Act)
                    continue;
                                
                    }
                //system.debug('Selected_CompetencyFilter: ' + this.Selected_CompetencyFilter);         
                if (this.Selected_CompetencyFilter != '' && this.Selected_CompetencyFilter != null)
                    {
                    if (this.Selected_CompetencyFilter != Comp)
                    continue;
                    }
                //system.debug('Selected_TemplateFilter' + this.Selected_TemplateFilter);
                //replace this part with a more effective code  - get it from a map -DONE
                
                if (this.Selected_TemplateFilter != 'none' && this.Selected_TemplateFilter != null)
                    {         
                    //if (this.FindBT_Match(Bu.Name,Selected_TemplateFilter ) == false)
                    if(CTBmap.get(Bu.Id)==null || CTBmap.get(Bu.Id)=='')  
                        continue;
                    }           
                //system.debug('Adding element: ' + Dobj);
                cycle++;
                total_size++;
                
                if (Bu.Activity_BI__c != null)
                        actfilter.add(Bu.Activity_BI__c);
                        
                if (Bu.Competency_BI__c != null)
                        compfilter.add(Bu.Competency_BI__c);
                
                //cycle counts added list elements, 
                //when it gets over the currently displayed number 
                //it adds the next list_size elements       
                if(cycle>counter && cycle <= (counter+list_size) ) {
                    ObjectsToDisplay.add(Dobj); 
                }
                
                //only cycle throught the necessary elements not to break action limits
                //if(rec==list_size) break;
                
                
            }
            
            System.debug('total size: ' + total_size);
            System.debug('counter: ' + counter);
            if(counter>total_size) Beginning();
        }
    }
    
    /**********************************************************************************************************************************
    Create new CFE_Report_Behavior_BI__c records based 
    on the contextObject and the selected Behaviours 
    from the grid
    ***********************************************************************************************************************************/
    public void  CreateNewCoachingReportBehaviours()
    {

        List<CFE_Report_Behavior_BI__c>  CRBs = new List<CFE_Report_Behavior_BI__c>();
        
        for (DisplaySmtg obj :ObjectsToDisplay)
        {
            if (obj.IsSelected == false)
            continue;
            
            //else we have a selected  item  lets add it ot the newCRB
            CFE_Report_Behavior_BI__c newCRB = new CFE_Report_Behavior_BI__c();
            
            newCRB.Coaching_Report_BI__c = CRobj.id; //the the parent
            
            
            
            if (obj.CTB != null) // if CTB
                newCRB.Behavior_BI__c = obj.CTB.Behavior_BI__c;  
            else                 // if B 
            newCRB.Behavior_BI__c = obj.theBehaviourbjID;

            
            CRBs.add(newCRB);
        }
        
        if (CRBs.size() > 0) {
            insert CRBs;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, CR_ADDED));
        }
        
    }
    
    /**************************************************
    
    **************************************************/
    public Boolean HasBeh_Template(ID pId, String pTempl)
    {
        try
        {
            
        if (ObjectsToDisplay.size() == 0)
        {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Exception occured: '));
        }
        else
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Exsfds '));
        
            
        for (DisplaySmtg obj :ObjectsToDisplay)
        {
            
            
            if (obj.theBehaviourbjID != pID)
                continue;

           if (obj.HasTemplate(pTempl))
                return true;
        }
        
        return false;           
        }
        catch(Exception myex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Exception occured: ' + myex.getMessage()));
            return false;
        }
        

    }
    
   //EXCESSIVE FUNCTION 1 
    /*public void BulidB_T_Relationship()
    {
        system.debug('BulidB_T_Relationship() started.');    
            
        Coaching_Template_BI__c[] CTs = [Select Name, 
                                             (Select Name, Coaching_Template_BI__c, Behavior_BI__c, Behavior_BI__r.Name, Coaching_Template_BI__r.Name
                                              From Coahing_Template_Behaviors__r
                                              where Behavior_BI__c != null
                                              //AND Coahing_Template_Behaviors__r != null
                                              ) 
                                         From Coaching_Template_BI__c
                                         where Country_Code_BI__c = :c
                                         ];
        system.debug('country code: ' + c);
        system.debug('CTs size: ' + CTs.size());
        
        
                
        for (Coaching_Template_BI__c CT :CTs)
        {
            
            Coaching_Template_Behavior_BI__c[] CTBs = CT.Coahing_Template_Behaviors__r;
            system.debug('CTb size: ' + CTBs.size());
            for (Coaching_Template_Behavior_BI__c CTB :CTBs)
            {
                //2012.06.28. *****************
                if (CTB.Behavior_BI__r == NULL)
                    continue;
                if (CTB.Behavior_BI__c == NULL)
                    continue;
                //2012.076.28. **************** 
            
            CTB_Relation CTB_R = new CTB_Relation(CT,CTB.Behavior_BI__r);
            CTB_relationList.add(CTB_R);
            
            }
        }                                 

    system.debug('CTB_relationList size: ' + CTB_relationList.size());
    //system.debug('CTB_relationList: ' + CTB_relationList);      
    }
    
    // CTB_relationList 40kb
    
    List<CTB_Relation> CTB_relationList = new List<CTB_Relation>();
    
    
    /********************************************************
    Find  a B T combination having the names as parameters. 
    ********************************************************
    public Boolean FindBT_Match(String pBName, String pTName)
    {
        
        for(CTB_Relation CTBR :CTB_relationList)
        {
            if (CTBR.Compare(pTName,pBName) == true)
              return true;
        }
        
        return false;
    }
    
    /*****************************************************
    Inner class used to filter Behavioiurs by Template.
    *****************************************************
    public class CTB_Relation
    {
        
         private String CTName;
         private String BName;
        
         private Coaching_Template_BI__c CT;
         private CFE_Rep_Behavior_BI__c B;
        
        public CTB_Relation()
        {
            
        }
        
        //2012.06.28. constructor
        public CTB_Relation(Coaching_Template_BI__c pCT, CFE_Rep_Behavior_BI__c pB)
        {
            CT = pCT;
            CTName = pCT.Name;
            
            B = pB;
            BName = pB.Name;
        }
        
        
        public Boolean Compare(CTB_Relation pCTBRel)
        {
            if (CTName == pCTBRel.CTName && BName == pCTBRel.BName)
            return true;
            
            return false;   
        }
        
        
        public Boolean Compare(String pCTName, String pBName)
        {
            if (CTName == pCTName && BName == pBName)
            return true;
            
            return false;   
        }       
    
    }
    
    
    /***************************
    Inner class storing the Accs
    
    Coaching_Template_Behavior_BI__c
    ***************************/    
    public class DisplaySmtg 
    {
        Map<String, String>  templateList = new Map<String,String>();
        
        Coaching_Template_Behavior_BI__c CTB;
        ID theBehaviourbjID;
        CFE_Rep_Behavior_BI__c theBehaviourObj;
        
        //the below 3 will be displayed in the grid
        public String theBehaviour {get; set;}
        public String theActivity  {get; set;} 
        public String theCompetency {get; set;} 
 
 
        /*******************************************************
        
        *******************************************************/
        public DisplaySmtg(Coaching_Template_Behavior_BI__c pCTB)
        {
            CTB = pCTB;
            theBehaviourbjID = pCTB.Behavior_BI__c;
            theBehaviourObj = pCTB.Behavior_BI__r;
            
            theBehaviour = pCTB.Behavior_BI__r.Name;
            theActivity = pCTB.Behavior_BI__r.Activity_BI__r.Name;
            theCompetency = pCTB.Behavior_BI__r.Competency_BI__r.Name;
                
        }
        
        
        /********************************************
        
        ********************************************/
        public DisplaySmtg(CFE_Rep_Behavior_BI__c pB)
        {

            theBehaviourbjID = pB.Id;
            theBehaviourObj = pB;
            
            theBehaviour = pB.Name;
            theActivity = pB.Activity_BI__r.Name;
            theCompetency = pB.Competency_BI__r.Name;
                
        }    
        
        
        /************************************************************************************
        
        ************************************************************************************/
        public DisplaySmtg(CFE_Rep_Behavior_BI__c pB, Coaching_Template_Behavior_BI__c[] CTs)
        {

            theBehaviourbjID = pB.Id;
            theBehaviourObj = pB;
            
            theBehaviour = pB.Name;
            theActivity = pB.Activity_BI__r.Name;
            theCompetency = pB.Competency_BI__r.Name;
            
            if (CTs != null)
            {
                for (Coaching_Template_Behavior_BI__c CT : CTS)
                {
                    templateList.put(CT.Name,pB.Name);
                }
            }
        }   
        
  
        public Boolean HasTemplate(String templateName)
        {
            if (templateList.containsKey(templateName) == true)
                return true;
            else 
                return false;   
        }   
                
         
            
        public boolean IsSelected {get;set;}
 
    }
    
    
 
    

}