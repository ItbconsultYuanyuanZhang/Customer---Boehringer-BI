public with sharing class BulkAddAttendees 
{
    
    public String ApplyNameFilter {get; set;}  //CSABA 2011.11.17.

      private final Medical_Event_vod__c medicalEvent;
      
        //IDs of Accounts already attending an Event
        private set<string> attendeeIDs;
      
        public string selectedView {get; set;}
        
        public string selectedViewType {get; set;}
        //public string ComboBox {get; set;}
        
        //Custom list of Accounts to display in the view
        public list<DisplayAccount> AccountList {get; set;}
        
        private Map<String, View_vod__c> viewMap = new Map<String, View_vod__c>();
        
        //bool to indicate if there are any Account to display in the view
        public boolean resultsToDisplay 
        {
                get 
                {
                        if (AccountList != null && !AccountList.IsEmpty()) 
                        {
                                return true;
                        } 
                        else 
                        {
                                return false;
                        }
                }
        }
       //Get field labels as Veeva messages************************************
        // Custom Labels
        /***
        Bulk Add Attendees to
        Source
        Filter (Name contains)
        Event:
        Select
        Name
        Address
        City
        State
        Zip code
        Return to 
        Apply
        Add To Event
        Toggle All Rows
        VIEW
        LIST
        Select a View
        ***/
      public String BA_ADD {set;get;}
      public String BA_SOURCE {set;get;} 
      public String BA_FILTER {set;get;} 
      public String BA_EVENT {set;get;} 
      public String BA_SELECT {set;get;} 
      public String BA_NAME {set;get;} 
      public String BA_ADDRESS {set;get;} 
      public String BA_CITY {set;get;} 
      public String BA_STATE {set;get;} 
      public String BA_ZIP {set;get;} 
      public String BA_RETURN {set;get;} 
      public String BA_APPLY {set;get;} 
      public String BA_ADDTO {set;get;}
      public String BA_TOGGLE {set;get;} 
      public String BA_VIEW {set;get;} 
      public String BA_LIST {set;get;} 
      public String BA_SELECTVIEW {set;get;}  
      public String BA_SELECTLIST {set;get;}
      public String BA_NOACC {set;get;}
      public String BA_NOLIST {set;get;}
      public String BA_WARN {set;get;}
      public String BA_1ATT {set;get;}
      public String BA_ATTS {set;get;}
      public String BA_NOATT {set;get;}
      
      private User currentUser;
                 
    //********************************************************************
    //search scope related functions
    public List<SelectOption> getViewType() 
  {
      List<SelectOption> options = new List<SelectOption>();
      if(BA_VIEW==null) this.BA_VIEW = 'View';
      if(BA_LIST==null) this.BA_LIST = 'List';
       options.add(new SelectOption('VIEW',BA_VIEW));
      options.add(new SelectOption('LIST',BA_LIST));
       return options;
  }    
 
    /******************************************
    //Q: why not collect it from ATL object????
    //Maybee because it might not exist there?
    ;terr1;terr2;terrN
    ******************************************/
    private String CollectAccTerr(ID newAcctId)
    {
      String terrString = '';
       
        List <AccountShare> asList = [select AccountId,UserOrGroupId from AccountShare 
                                      where AccountId =  :newAcctId 
                                      and RowCause in ('Territory','TerritoryManual')] ;
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
            
            //Build a ';' string separated string. It will be used later in ATL.Territory_vod__c
            for (Territory t : terrList) 
            {
                terrString = terrString + ';' + t.Name ;
            }
        }
      return terrString;
    }      
 

    /*************************
    If the User has multiple 
    alignment Hamayour raise 
    an error. WHY?
    Question:  How to handle 
    Terr Hierarchy?????????? 
    terr1
    *************************/
    public String GetUserTerr()
    {
      List<UserTerritory> utList = [select TerritoryId from userterritory where UserId = :UserInfo.getUserId()] ;
        if (utList.size() == 0) 
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'User not aligned to any territory'));
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'GAS_NOTALGN'));
            return null ;
        }
        
        set<String> UterIDs = new set<String>();
        for(UserTerritory UT :utList)
        {
          UterIDs.add(UT.TerritoryId);
        }
        
        // Get the name of the Territory
        String userTerrName;
        Territory[] Terrs = [select Name from Territory where Id in :UterIDs] ;
        
        if(Terrs.size() == 1)
        {
            return '\'' + Terrs[0].Name + '\'';  
        }
            
        for(Territory theT :Terrs)
        {
          
          if(userTerrName == NULL)
             userTerrName = '\'' + theT.Name + '\'';
          else
             userTerrName = userTerrName + ',\'' + theT.Name + '\'';
        }
          
        return userTerrName;

    }       
    //********************************************************************
        
        /***********************************************************************************************************
        Constructor.  Just set the Event object member based  controller. and set up language dependent veeva messages
        ***********************************************************************************************************/
        public BulkAddAttendees(ApexPages.StandardController stdController) 
        { 
          this.medicalEvent = (Medical_Event_vod__c)stdController.getRecord();
          
          selectedViewType = 'VIEW';
          
          
          ApplyNameFilter = '';  //2012.04.18.
      /*****************************************************************    
          //USE LANGUAGE DEPENDENT LABELS - Added by Viktor 2013.05.06
      ******************************************************************/   
        String lang = UserInfo.getLanguage() ;
         
         Message_vod__c [] labels = [select Name,Text_vod__c from Message_vod__c where Language_vod__c = :lang and Category_vod__c = 'BAA' and Active_vod__c = true] ;
          //system.debug('Labels: ' + labels);
          
          
          if (labels.size()==0) 
          {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Language dependent Veeva Messages are  missing!'));
            labels = [select Name,Text_vod__c from Message_vod__c where Language_vod__c = 'en_US' and Category_vod__c = 'BAA' and Active_vod__c = true] ;
          }
          
          Map <String,String> labelMap = new Map <String,String> () ;
          
          for (Message_vod__c label : labels) 
          {
              labelMap.put(label.Name, label.Text_vod__c) ;
          }
          
          currentUser = [ select Id, Country_Code_BI__c from User where id = :UserInfo.getUserId() ]; 
  
         /***
          Bulk Add Attendees to
          Source
          Filter (Name contains)
          Event:
          Select
          Name
          Address
          City
          State
          Zip code
          Return to 
          Apply
          Add To Event
          Toggle All Rows
          VIEW
          LIST
          Select a View
          Select a List
          'No Accounts were found for this view' +535,585
          'No List was selected'
          'WARNING:  Only 20 attendees can be addeded in one session!'
          '1 attendee has been successfully added to your event'
          ' attendees have been successfully added to your event'
          'No attendees were selected'
          ***/
            
          BA_ADD = labelMap.get('BA_ADD') ;
          BA_SOURCE = labelMap.get('BA_SOURCE') ;
          BA_FILTER = labelMap.get('BA_FILTER') ;
          BA_EVENT = labelMap.get('BA_EVENT') ;
          BA_SELECT = labelMap.get('BA_SELECT') ;
          BA_NAME = labelMap.get('BA_NAME') ;
          BA_ADDRESS = labelMap.get('BA_ADDRESS') ;
          BA_CITY = labelMap.get('BA_CITY') ;
          BA_STATE = labelMap.get('BA_STATE') ;
          BA_ZIP = labelMap.get('BA_ZIP') ;
          BA_RETURN = labelMap.get('BA_RETURN') ;
          BA_APPLY = labelMap.get('BA_APPLY') ;
          BA_ADDTO = labelMap.get('BA_ADDTO') ;
          BA_TOGGLE = labelMap.get('BA_TOGGLE') ;
          BA_VIEW = labelMap.get('BA_VIEW') ;
          BA_LIST = labelMap.get('BA_LIST') ;
          BA_SELECTVIEW = labelMap.get('BA_SELECTVIEW') ;
          BA_SELECTLIST = labelMap.get('BA_SELECTLIST') ;
          BA_NOACC = labelMap.get('BA_NOACC') ;
          BA_NOLIST = labelMap.get('BA_NOLIST') ;
          BA_WARN = labelMap.get('BA_WARN') ;
          BA_1ATT = labelMap.get('BA_1ATT') ;
          BA_ATTS = labelMap.get('BA_ATTS') ;
          BA_NOATT = labelMap.get('BA_NOATT') ;
          
          
          if (BA_ADD == null || BA_SOURCE == null || BA_FILTER == null || BA_EVENT == null || BA_SELECT == null ||
             BA_NAME == null || BA_ADDRESS == null || BA_CITY == null || BA_STATE == null || BA_ZIP == null ||
             BA_RETURN == null || BA_APPLY == null || BA_ADDTO == null || BA_TOGGLE == null ||
             BA_VIEW == null || BA_LIST == null || BA_SELECTVIEW == null || BA_SELECTLIST == null || 
             BA_NOACC == null || BA_NOLIST == null || BA_WARN == null || BA_1ATT == null || BA_ATTS == null ||  
             BA_NOATT == null)
          { 
           
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please configure all "BA_*" Veeva messages for language: ' +  lang));
              
          return;
          }
          
      }
        
        
        
                
      
        
        /**************************************
        
        **************************************/
        public list<SelectOption> getListItems()
        {
        String debugText = '';
        String userProfileId = UserInfo.getProfileId();
        String userId = UserInfo.getUserId();  
          
        list<SelectOption> options = new list<SelectOption>();
        
        if (selectedViewType == 'VIEW')
          {
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'VIEW'));
                if(BA_SELECTVIEW==null) this.BA_SELECTVIEW = 'Select a View';
                options.add(new SelectOption('0', BA_SELECTVIEW));
                List<String> viewProfiles = new List<String>();
                //get views for a user and add them to the view Map
                for (View_vod__c view:
                        [SELECT Id, Name, Columns_vod__c, Criteria_vod__c, Statement_vod__c, Type_vod__c, OwnerId, Public_vod__c, Profile_vod__c 
                         FROM View_vod__c
                         WHERE Type_vod__c = 'MyAccounts' AND (OwnerId = :userId OR Public_vod__c = true) //Profile_Vod__c
                         ORDER BY Name]
                    )
                         {
                           viewProfiles.clear();
                           
                           //CSABA remove the Account list from options.  only contacts
                   if (view.Name.contains('Accounts'))
                   {
                     continue;
                   }
                           //CSABA remove the Account list from options.  only contacts
                           
                           if (view.Profile_vod__c != null) 
                           {
                             viewProfiles = view.Profile_vod__c.split(',');
                           }
                           if ((view.OwnerId == userId) || (view.Public_vod__c == true && view.Profile_vod__c == null)) 
                           {
                             options.add(new SelectOption(view.Id, view.Name));
                                viewMap.put(view.Id, view);
                                debugText += view.Name + ', ';
                           } 
                           else if (!viewProfiles.IsEmpty() && view.Public_vod__c == true) 
                           {
                             for (String p : viewProfiles) 
                             {
                               if (p == userProfileId) 
                               {
                                 options.add(new SelectOption(view.Id, view.Name));
                                    viewMap.put(view.Id, view);
                                    debugText += view.Name + ', ';
                                    break;
                               }
                             }
                           }
                        }             
            
          
          }
        else
          {
             //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'LIST'));
               if(BA_SELECTLIST==null) this.BA_SELECTLIST = 'Select a List';
               options.add(new SelectOption('0', BA_SELECTLIST));
        
             for (Account_List_vod__c Lvw :[Select Id, Name, Access_vod__c From Account_List_vod__c where Ownerid = :userId])
             {  
              options.add(new SelectOption(Lvw.Id, Lvw.Name));
             }
      
          }
          
          return options;

        }
        
        
        //Get a list of Views for the user
        public list<SelectOption> getViewItemsNonfiltered() 
        {
                list<SelectOption> options = new list<SelectOption>();
                //create default view
                if(BA_SELECTVIEW==null) this.BA_SELECTVIEW = 'Select a View';
                options.add(new SelectOption('0', BA_SELECTVIEW));
                //get views for a user and add them to the view Map
                for (View_vod__c view:
                         [SELECT Id, Name, Columns_vod__c, Criteria_vod__c, Statement_vod__c 
                         FROM View_vod__c
                         ORDER BY Name]
                    )
                {
                   options.add(new SelectOption(view.Id, view.Name));
                   viewMap.put(view.Id, view);
                }       
                return options;
        }
        
        
        //Get a list of Views for the user  ..  CSABA code transferred above in  method  getListItems
        public list<SelectOption> getViewItems() 
        {
          
          
              //Identify the User first
                String debugText = '';
                String userProfileId = UserInfo.getProfileId();
                String userId = UserInfo.getUserId();
                
                
                list<SelectOption> options = new list<SelectOption>();
                //create default view
                if(BA_SELECTVIEW==null) this.BA_SELECTVIEW = 'Select a View';
                options.add(new SelectOption('0', BA_SELECTVIEW));
                List<String> viewProfiles = new List<String>();
                //get views for a user and add them to the view Map
                for (View_vod__c view:
                        [SELECT Id, Name, Columns_vod__c, Criteria_vod__c, Statement_vod__c, Type_vod__c, OwnerId, Public_vod__c, Profile_vod__c 
                         FROM View_vod__c
                         WHERE Type_vod__c = 'MyAccounts' AND (OwnerId = :userId OR Public_vod__c = true) //Profile_Vod__c
                         ORDER BY Name]
                    )
                         {
                           viewProfiles.clear();
                           if (view.Profile_vod__c != null) 
                           {
                             viewProfiles = view.Profile_vod__c.split(',');
                           }
                           if ((view.OwnerId == userId) || (view.Public_vod__c == true && view.Profile_vod__c == null)) 
                           {
                             options.add(new SelectOption(view.Id, view.Name));
                                viewMap.put(view.Id, view);
                                debugText += view.Name + ', ';
                           } 
                           else if (!viewProfiles.IsEmpty() && view.Public_vod__c == true) 
                           {
                             for (String p : viewProfiles) 
                             {
                               if (p == userProfileId) 
                               {
                                 options.add(new SelectOption(view.Id, view.Name));
                                    viewMap.put(view.Id, view);
                                    debugText += view.Name + ', ';
                                    break;
                               }
                             }
                           }
                        }       
                
                system.debug('Views for this user: ' + viewMap.values());
                system.debug('Views for this user: ' + debugText);
                return options;
        }        
        
       
        
        /*******************************
        CSABA. collect Accounts from the 
        List
        If data source is VIEW call the
        original function and return.
        If data soure is LIST get the
        Accounts belonging to it.
        *******************************/
        public void RefreshListAccounts()
        {
          

          
                   //clear existing list of Accounts
                if (AccountList != null) { AccountList.clear(); }
                
                
                
                if (selectedViewType == 'VIEW')
                {

                refreshAccounts();  
                return;
                }
        
   
                if (this.selectedView != '0')  
                {

                                                    
                 String accountQuery = 'SELECT Account_vod__r.Id, Account_vod__r.Name, Account_vod__r.Specialty_View_BI__c, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__c WHERE Primary_vod__c = true and  Account_vod__c in (Select Account_vod__c From Account_List_Item_vod__c where Account_List_vod__c = ' + '\'' + selectedView + '\'' + ')';                
                 
                 
                 
                 //CSABA 22011.11.17.  Try to apply filter for Account Name *************************************
                 if (this.ApplyNameFilter.length() > 0)
                 {
                   accountQuery = accountQuery + '  and Account_vod__r.Name like \'%' + ApplyNAmeFilter + '%\''; 
                 }
                 //CSABA 22011.11.17.  Try to apply filter for Account Name *************************************
                 
                 list<Address_vod__c> accountsToList = Database.query(accountQuery);
                  
                 if (!accountsToList.isEmpty()) 
                  {
                  //Get list of Accounts already listed as attendees to this event
                  this.attendeeIDs = new set<string>{};
                  for (Event_Attendee_vod__c ea : [SELECT Account_vod__c, Medical_Event_vod__c 
                                                   FROM Event_Attendee_vod__c
                                                   WHERE Medical_Event_vod__c = :this.medicalEvent.Id]) 
                  {
                   attendeeIds.Add(ea.Account_vod__c);
                  }
                            
                            
                  //Add accounts to inner class
                  list<DisplayAccount> displayAccounts = new list<DisplayAccount>();
                  for (Address_vod__c item : accountsToList) 
                    {
                     displayAccounts.add(new DisplayAccount(item, attendeeIds.contains(item.Account_vod__r.Id)));
                    }
                  AccountList = displayAccounts;
                  } 
                  else 
                  {
                  //No Accounts were returned, show message   //2013.08.29. added to avoid crach in case of missing message
                  if(BA_NOACC != NULL)
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,BA_NOACC));
                  else
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No accounts returned'));
                     
                  }

                }
                else
                {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,BA_NOLIST));                  
                }       
          
        }
        
        //Get a list of Accounts when the View is changed
        public void refreshAccounts()
        {
                          
                //clear existing list of Accounts
                if (AccountList != null) { AccountList.clear(); }
        
                system.debug('Selected view ID is: ' + selectedView); 
                
                

                if (selectedView != '0') 
                {
                View_vod__c view = viewMap.get(selectedView) ;
                system.debug('Select view criteria is: ' + view.Criteria_vod__c);   //is the view filter 
                system.debug('Select view statement is: ' + view.Statement_vod__c); //is the list of columns
                        
                   
                        //Build the SOQL string
                        string accountQuery = 'SELECT Account_vod__r.Id, Account_vod__r.Name, Account_vod__r.Specialty_View_BI__c, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__c WHERE Primary_vod__c = true';
                        
                         
         
                       //CSABA 22011.11.17.  Try to apply filter for Account Name *************************************
                     if (this.ApplyNameFilter.length() > 0) 
                       {
                       accountQuery = accountQuery + '  and Account_vod__r.Name like \'%' + ApplyNameFilter + '%\' '; 
                       }
                        //CSABA 22011.11.17.  Try to apply filter for Account Name *************************************
                        
                       system.debug('accountQuery: ' + accountQuery);    
                       system.debug('ApplyNameFilter: ' + ApplyNameFilter);
                        
 
                       
                        
                        //check if the view is filtered.
                        if (view.Criteria_vod__c != null) 
                        {
                                list<SearchField> searchFields = ParseCriteria(view.Criteria_vod__c);
                                                               
                                
                                //2012.11.19.  in case searchFields is null skip
                                if (searchFields == NULL)
                                   {
                                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,BA_NOACC));
                                     return;  
                                   }
                                //2012.11.19.  in case searchFields is null skip
                                
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'User Territory: ' + this.GetUserTerr()));   
                //return;                                
                                
                                DebugCriteria(searchFields);
                                string whereClause = WhereClause(searchFields);
                     
                                if (whereClause != '') 
                                {
                                       // accountQuery += ' AND ' + whereClause;
                                        accountQuery += ' AND ' + whereClause + ' ORDER by Account_vod__r.Name';
                                }
                                                              
                        system.debug('Account query: ' + accountQuery);  
                        }
                
                  

                system.debug('FINAL accountQuery: ' + accountQuery);     
                
               // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, accountQuery));     
               // return; 
              

                //Query for Accounts and build DisplayAccounts inner class
                list<Address_vod__c> accountsToList = Database.query(accountQuery);  
                
                //if(accountsToList != NULL)
                //   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'sizu =' + accountsToList.size()));    
                //return;      
                
                
                if (!accountsToList.isEmpty()) 
                {
                        //Get list of Accounts already listed as attendees to this event
                        this.attendeeIDs = new set<string>{};
                        for (Event_Attendee_vod__c ea : [SELECT Account_vod__c, Medical_Event_vod__c 
                                                         FROM Event_Attendee_vod__c
                                                         WHERE Medical_Event_vod__c = :this.medicalEvent.Id]) 
                             {
                              attendeeIds.Add(ea.Account_vod__c);
                             }
                          
                          
                        //Add accounts to inner class
                        list<DisplayAccount> displayAccounts = new list<DisplayAccount>();
                        for (Address_vod__c item : accountsToList) 
                        {
                        displayAccounts.add(new DisplayAccount(item, attendeeIds.contains(item.Account_vod__r.Id)));
                        }
                        AccountList = displayAccounts;
                } 
                else 
                {
                //No Accounts were returned, show message
                if(BA_NOACC != NULL)
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,BA_NOACC)); 
                else
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Accounts returned'));
                }
                }
    }
    
    //Handle "Add to Event" button click
    public PageReference AddAttendees() 
    {
      /******************* MOVE IT AFTER THE FOR LOOP ********************************
      if (AccountList.size() > 20)
      {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'WARNING:  Only 20 attendee can be addeded in one session!'));
      return null;
      }
      ******************** MOVE IT AFTER THE FOR LOOP ********************************/
      
        integer i = 0;
        //Get record type ID for 'HCP Event Attendee'
        //string hcpEventAttendeeRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'HCP Event Attendee' AND SobjectType = 'Event_Attendee_vod__c'].Id;
        
        //Create new attendee records
        List<Event_Attendee_vod__c> attendeesToAdd = new List<Event_Attendee_vod__c>{};
        for (DisplayAccount a : AccountList) 
        {
                if (a.IsSelected && !a.IsAttending) 
                {
                 Event_Attendee_vod__c attendee = New Event_Attendee_vod__c(Account_vod__c = a.Id, 
                 Medical_Event_vod__c = this.medicalEvent.Id,
                 Status_vod__c = 'Invited');      
                 
                 //CSABA 2012.01.18.  Handle SOQL limits
                 //i = i + 1;
                 //if (i > 20)
                 //break;                        
                 //CSABa 2012.01.18.  Handle SOQL limits
                              
                 attendeesToAdd.add(attendee);
                }
        }
        //Insert new attendees

        //2012.11.19.  I do not remember why we have to add the below warning here *********************************
      if (attendeesToAdd.size() > 20)
      {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,BA_WARN));
      return null;
      }
        //2012.11.19.  I do not remember why we have to add the above warning here *********************************
        
        if (attendeesToAdd.size() > 0) 
        {
                try 
                {
                  
                  
                        insert attendeesToAdd;
                        string message;
                        //Create message for n attendees added
                        if (attendeesToAdd.size() == 1) 
                        {
                        message = BA_1ATT;
                        } 
                        else 
                        {
                        message = attendeesToAdd.size() + ' ' +BA_ATTS;      
                        }
                        
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, message));
                } 
                catch (Exception ex) 
                {
                //Return error message
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Exception occured: ' + ex.getMessage()));  //CSABa 2012.01.18
                return null; //CSABA 2012.01.18.
                //CSABA 2012.01.18.  ApexPages.addMessages(ex);
                }
        } 
        else 
        {
                //No Accounts were selected. Show message.
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, BA_NOATT));
        }
        //Clean up, reset View to default
        AccountList.clear();
        selectedView = '0';
        return null;
    }
    
    
    
 
        //Write search fields to debug log
        private void DebugCriteria(list<SearchField> searchFields) 
        {
                integer i = 1;
                for (SearchField sf : searchFields) 
                { 
                        system.debug('Search Field ' + i);
                        system.debug('Obj = ' + sf.Obj);
                        system.debug('ApiName = ' + sf.ApiName);
                        system.debug('Opt = ' + sf.Opt);
                        system.debug('Value = ' + sf.ValueArray);
                        system.debug('NoQuote = ' + sf.NoQuote);
                        i++;
                }
        }
        
        //Parse the criteria string into searchField objects
        private list<SearchField> ParseCriteria(string criteriaString) 
        {
                list<SearchField> searchFields = new list<SearchField>();
                SearchField searchField;
                
                string[] criteria = criteriaString.split(';;;');
                
                system.debug('criteria: ' + criteriaString);
                
                for (string criterion : criteria) 
                {
                    system.debug('criterion: ' + criterion);
                        //get array of object.apiName, operator, and value
                        string[] part = criterion.split(':::');
                        
                        
                        system.debug('part.size(): ' + part.size());
                        
                        //2012.11.19.  Add to avoid exceptio in case the selectewd view has no items 
                        if (part.size() < 2) {
                          system.debug('part size is less than 2, returning null');
                          return null;
                        }
                        
                        //get array of object and apiName by splitting on period btwn object and field
                        string[] objApiName = part[0].split('\\.');
                        //build searchField object and add to list
                        searchField = New SearchField();                                
                        searchField.Obj = objApiName[0]; 
                        searchField.ApiName = objApiName[1];
                        searchField.Opt = part[1];
                        if (part.size() >= 3) {
                          searchField.ValueArray = part[2].split(',,');
                        } else {
                            searchField.ValueArray = new String[]{ '' };  
                        }
                        searchFields.add(searchField);
                }
                return searchFields;
        }
        
        //Build SOQL WHERE clause given an array of SearchField objects
        private string WhereClause(list<SearchField> searchFields) 
        {
                string whereClause = '';
                
                string MyDebug = '';
                
                for (SearchField sf : searchFields) 
                {
                      MyDebug = MyDebug + ' @ ' + sf; 
                      
                        //Only build WHERE clauses for Account and Address objects
                        if (sf.Obj == 'Account' || sf.Obj == 'Address_vod__c'  ) 
                        {
                                string field = sf.ApiName;
                                string op = '=';
                                string value = '';
                                
                                if (sf.Obj == 'Account') { field = 'Account_vod__r.' + field; }
                                
                                if (sf.ValueArray.size() > 1) 
                                {
                                        //Multiple values, build WHERE IN () clause
                                        op = 'IN';
                                        boolean noQuote = sf.NoQuote;
                                        string v = '';
                                        for (string s : sf.ValueArray) 
                                        {
                                                if (!noQuote) {
                                                        v += '\'' + s + '\',';
                                                } else {
                                                        v += s + ',';
                                                }
                                        }
                                        //remove trailing comma
                                v = v.substring(0,v.length()-1);
                                value = '(' + v + ')';
                                } 
                                else 
                                {
                                        value = sf.ValueArray[0];
                                        if (sf.Opt == 'ne') { op = '!='; }
                                        if (sf.Opt == 'lt') { op = '<'; }
                                        if (sf.Opt == 'lte') { op = '<='; } 
                                        if (sf.Opt == 'gt') { op = '>'; } 
                                        if (sf.Opt == 'gte') { op = '>='; }
                                        if (sf.Opt == 'sw') { op = 'LIKE'; value += '%'; } 
                                        if (sf.Opt == 'nc' || sf.Opt == 'c') 
                                        {
                                        op = 'LIKE'; value = '%'+value+'%';
                                        }
                                        if (!sf.NoQuote) 
                                        {
                                        value = '\'' + value + '\'' ;
                                        }
                                }                               
                                
                                if (whereClause != '') { whereClause += ' AND'; }
                                if (sf.Opt == 'nc') 
                                {
                                //surround NOT IN clause with parens
                                whereClause += ' (NOT ' + field + ' ' + op + ' ' + value + ')';
                                } 
                                else 
                                {
                                whereClause += ' ' + field + ' ' + op + ' ' + value;
                                }                               
                        }
                        else if(sf.Obj == 'TSF_vod__c')
                        {
                          
                                string field = sf.ApiName;
                                string op = '=';
                                string value = '';
                                
                                if (sf.Obj == 'Account') { field = 'Account_vod__r.' + field; }
                                
                                if (sf.ValueArray.size() > 1) 
                                {
                                        //Multiple values, build WHERE IN () clause
                                        op = 'IN';
                                        boolean noQuote = sf.NoQuote;
                                        string v = '';
                                        for (string s : sf.ValueArray) 
                                        {
                                                if (!noQuote) {
                                                        v += '\'' + s + '\',';
                                                } else {
                                                        v += s + ',';
                                                }
                                        }
                                        //remove trailing comma
                                v = v.substring(0,v.length()-1);
                                value = '(' + v + ')';
                                } 
                                else 
                                {
                                        value = sf.ValueArray[0];
                                        if (sf.Opt == 'ne') { op = '!='; }
                                        if (sf.Opt == 'lt') { op = '<'; }
                                        if (sf.Opt == 'lte') { op = '<='; } 
                                        if (sf.Opt == 'gt') { op = '>'; } 
                                        if (sf.Opt == 'gte') { op = '>='; }
                                        if (sf.Opt == 'sw') { op = 'LIKE'; value += '%'; } 
                                        if (sf.Opt == 'nc' || sf.Opt == 'c') 
                                        {
                                        op = 'LIKE'; value = '%'+value+'%';
                                        }
                                        if (!sf.NoQuote) 
                                        {
                                        //value = '\'' + value + '\'' ;
                                        }
                                }                               
                                
                                if (whereClause != '') { whereClause += ' AND'; }
                                if (sf.Opt == 'nc') 
                                {
                                //surround NOT IN clause with parens
                                whereClause += ' (NOT ' + field + ' ' + op + ' ' + value + ')';
                                } 
                                else 
                                {
                                whereClause = whereClause + ' Account_vod__c in ( Select Account_vod__c from TSF_vod__c where ';  
                                whereClause += ' ' + field + ' ' + op + ' ' + value;
                                whereClause += ' and Territory_vod__c in ('+ GetUserTerr() + ')';  
                                whereClause += ') '; 
                                }                            
                             
                        }
                }
                
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, MyDebug));  //2013.08.27.
                               
                return whereClause;
        }
        
        
    /***************************
    Inner class storing the Accs
    ***************************/    
    public class DisplayAccount 
    {
        public string Id {get;set;}
        public string Name {get;set;}
        public boolean IsSelected {get;set;}
        public boolean IsAttending {get;set;}
        public string Address {get;set;}
        public string City {get;set;}
        public string State {get;set;}
        public string PostCode {get;set;}
        public string Specialty {get;set;}
        
        //Constructor.
        public DisplayAccount(Address_vod__c item, boolean isAttending) 
        {
                this.Id = item.Account_vod__r.Id;
                this.Name = item.Account_vod__r.Name;
                this.Specialty = item.Account_vod__r.Specialty_View_BI__c;
                this.Address = item.Name;
                this.City = item.City_vod__c;
                this.State = item.State_vod__c;
                this.PostCode = item.Zip_vod__c;
                this.IsSelected = isAttending;
                this.IsAttending = isAttending;
                
        }       
    }
    
    
    public class SearchField 
    {
        //Determine the datatype of the field and if it should be enclosed in quotes
        public  boolean NoQuote 
        {
                get 
                {
                        Set<String> noQuoteSet = new Set<String>{'BOOLEAN', 'CURRENCY', 'DATE', 'DATETIME', 'DOUBLE', 'INTEGER', 'PERCENT', 'TIME'};
                        Map<String, Schema.SObjectField> fieldMap;
                        string dataType;                        
                        if (this.Obj == 'Account') 
                        {
                        fieldMap = Schema.SObjectType.Account.fields.getMap();
                        } 
                        else if (this.Obj == 'Address_vod__c') 
                        {
                        fieldMap = Schema.SObjectType.Address_vod__c.fields.getMap();
                        } 
                        else 
                        {
                                return false;
                        }
                        dataType = fieldMap.get(this.ApiName).getDescribe().getType().name();
                        system.debug('Datatype is: ' + dataType);
                        if (noQuoteSet.contains(dataType)) 
                        {
                        return true;
                        } 
                        else 
                        { 
                        return false;
                        }
                }
        }
        
        public string Obj {get;set;}
                public string ApiName {get;set;}
                public string Opt {get;set;}
                public string[] ValueArray {get;set;}
                public SearchField(){}
                public SearchField(string obj, string apiName, string opt, string[] valueArray) 
                {
                        this.Obj = obj;
                        this.ApiName = apiName;
                        this.Opt = opt;
                        this.ValueArray = valueArray;
                }
    }



}