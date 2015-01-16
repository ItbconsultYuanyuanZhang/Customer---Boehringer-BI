/************************************************************************************************************

************************************************************************************************************/
trigger VEEVA_BI_SharedMedEvent_Bulk on Event_Team_Member_BI__c (before delete, before insert, before update) 
{
//return;	
	
//identify the parent Med Event  of this team member   
ID MedEv;
ID NEWUserID;

Set<String> setMedEv = new Set<String>();
Set<String> setUsers = new set<string>(); 
List<Medical_Event_vod__Share> ListMES = new List<Medical_Event_vod__Share>();  //used for Insert

Integer sizu = 0;
if(trigger.isInsert)
	sizu = trigger.new.size();
else
	sizu = trigger.old.size();


for(Integer i = 0; i < sizu; i++)  
{
if (trigger.isDelete == true)
    {
    MedEv = trigger.old[0].Event_Management_BI__c; 
    setMedEv.add(trigger.old[i].Event_Management_BI__c); 
    }
else  
    {
    MedEv = trigger.new[0].Event_Management_BI__c;
    setMedEv.add(trigger.new[i].Event_Management_BI__c);
    
    NEWUserID = trigger.new[0].User_BI__c;
    setUsers.add(trigger.new[i].User_BI__c);
    }	
}
  
system.debug('Nr of Events  ands Users :' + setMedEv.size() + '/' +  setUsers.size());

/************************************  INSERT TRIGGER ****************************************************************/
if (trigger.isInsert == true)
    {
                                  
	Event_Team_Member_BI__c[] ETMs = [Select ID,User_BI__c,Event_Management_BI__c
	                                  from Event_Team_Member_BI__c 
                                      where 
                                      User_BI__c  in :setUsers
                                      and
                                      Event_Management_BI__c in :setMedEv  
                                      ];
                                      
     Map<String, Event_Team_Member_BI__c> MapETMs = new Map<String, Event_Team_Member_BI__c>(); 
     for(Event_Team_Member_BI__c ETMu :ETMs)
     {
       String UserId = ETMu.User_BI__c;
       String Eventu = ETMu.Event_Management_BI__c;
       MapETMs.put(UserID+'_'+Eventu,ETMu); 	
     } 


    for(Integer i = 0; i < trigger.new.size(); i++)
    {
    	if(UserInfo.getUserId() == trigger.new[i].User_BI__c)  
           return; 
    	
    	String ExtIDu = trigger.new[i].User_BI__c + '_' + trigger.new[i].Event_Management_BI__c;
    	if(MapETMs.get(ExtIDu) !=  NULL)
     	   {
     	   system.debug('THIS USER HAS BEEN PREVIOUSLY ADDED AS AN EVENT TEAM MEMBER');	
    	   trigger.new[i].adderror('THIS USER HAS BEEN PREVIOUSLY ADDED AS AN EVENT TEAM MEMBER');
    	   continue;
     	   }
          	   
    Medical_Event_vod__Share MES = new Medical_Event_vod__Share();
    MES.ParentId = trigger.new[i].Event_Management_BI__c;
    MES.UserOrGroupId = trigger.new[i].User_BI__c;  
    MES.RowCause = 'Manual';    
    
    /***************** 2013.01.29 **************************/
    if (trigger.new[i].Grant_Event_Edit_Access_BI__c == true)
        MES.AccessLevel = 'Edit';
    else
        MES.AccessLevel = 'Read'; 
    /***************** 2013.01.29 **************************/  
    
    try
    {
    system.Debug('We are going to create  share for ' + trigger.new[i].Event_Management_BI__c + '/' + trigger.new[i].User_BI__c);	
    insert MES;
    }
    catch(Exception ex)
    {
    	trigger.new[i].adderror(ex.getmessage());
    }
    
    //ListMES.add(MES);      
    
    
    
         	   
    } 
    
    try
        {
        //system.Debug('We are going to create ' + ListMEs.size() + ' shares');	
        //insert ListMES;
        return;        
        }
    catch(Exception ex)
        {
        //String errMsg = ex.getMessage();
        //if (errMsg.contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY') == true)
        //    trigger.new[0].addError('You can not add this user as shared');
        //else    
        //    trigger.new[0].addError(ex.getMessage());   
        }                                   

    return;
    }//END if INSERT
/************************************  INSERT TRIGGER ****************************************************************/


ID OLDUserID = trigger.old[0].User_BI__c;

Medical_Event_vod__Share[] MES1 = [Select Id, ParentId, UserOrGroupId,AccessLevel 
                                   from Medical_Event_vod__Share
                                   where ParentId = :MedEv
                                   and UserOrGroupId = :OLDUserID
                                   ];

/************************** DELETE TRIGGER **************************/
if (trigger.isDelete)
    {
    //in case of DELETE.  
    //identify  if share exist.  if yes delete share    
    if (MES1.size() == 1 )
        {
        //do not allow delete the Full Access user which is the Owner   
        if (UserInfo.getUserId() == OLDUserID)  
        {
        return; 
        }
                    
        delete MES1[0];             
        }
    return;
    }//END IF DELETE
/************************** DELETE TRIGGER **************************/

/************************** UPDATE TRIGGER ******************************************************************************/
if (trigger.isUpdate)
    {
        
    //2013.02.27.       
    Event_Team_Member_BI__c[] ETM = [Select ID from Event_Team_Member_BI__c 
                                     where User_BI__c =:trigger.new[0].User_BI__c
                                     and
                                     Event_Management_BI__c = :MedEv
                                     ]; 
    //2013.02.27.       
        
    if (NEWUserID != OLDUserID && ETM.size() > 0)
       {
        trigger.new[0].addError('THIS USER HAS BEEN PREVIOUSLY ADDED AS AN EVENT TEAM MEMBER');
        return;     
       }        
    
    if (NEWUserID == OLDUserID && UserInfo.getUserId() != NEWUserID)   //2013.02.27.  added UserInfo.getUserId() != NEWUserID
        {
            
        //in case of Update  if there is a change in field  trigger.new[0].Grant_Event_Edit_Access_BI__c take care
        if (trigger.new[0].Grant_Event_Edit_Access_BI__c == true && trigger.old[0].Grant_Event_Edit_Access_BI__c == false)
            {
            //update the existing Share reccord
            MES1[0].AccessLevel = 'Edit';   
            update MES1;    
            }
        if (trigger.new[0].Grant_Event_Edit_Access_BI__c == false && trigger.old[0].Grant_Event_Edit_Access_BI__c == true)
            {
            MES1[0].AccessLevel = 'Read';
            update MES1;            
            }   
        return;                                 
        }
    
        
    if (MES1.size() == 0)   
        {
        //trigger.new[0].adderror('there was no sharing  for the OLD user.  Less probable since is an update    ');    
        //return;  
        }
    else
        {
        if (NEWUserID != OLDUserID) //2013.02.27  added if
            delete MES1[0]; //not allowed to change  Useru.  Delete  the old and add a new one    
        }   
    
    //if the new User  is the logged user do not create Share
    if (UserInfo.getUserId() == NEWUserID)  
    {
    return; 
    }   
        
    Medical_Event_vod__Share MES = new Medical_Event_vod__Share();
    MES.ParentId = MedEv;
    MES.UserOrGroupId = NEWUserID;  
    MES.RowCause = 'Manual';    

    /***************** 2013.01.29 **************************/
    if (trigger.new[0].Grant_Event_Edit_Access_BI__c == true)
        MES.AccessLevel = 'Edit';
    else
        MES.AccessLevel = 'Read'; 
    /***************** 2013.01.29 **************************/
        
    try
        {
        insert MES;     
        }
    catch(Exception ex)
        {
        String errMsg = ex.getMessage();
        if (errMsg.contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY') == true)
            trigger.new[0].addError('You can not add this user as shared'); 
        else  
            trigger.new[0].addError(ex.getMessage());
                
       }
    return;     
    }
/************************** UPDATE TRIGGER ******************************************************************************/  

}