/******************************************************************************************************


******************************************************************************************************/
trigger VEEVA_BI_ShareMedEvent on Event_Team_Member_BI__c (before insert, before update, before delete) 
{

//return; 

//identify the parent Med Event  of this team member   
ID MedEv;
ID NEWUserID;
  
if (trigger.isDelete == true)
    {
    MedEv = trigger.old[0].Event_Management_BI__c;  
    }
else  
    {
    MedEv = trigger.new[0].Event_Management_BI__c;
    NEWUserID = trigger.new[0].User_BI__c;
    }
       

/************************************  INSERT TRIGGER ****************************************************************/
if (trigger.isInsert == true)
    {
        
    Event_Team_Member_BI__c[] ETM = [Select ID from Event_Team_Member_BI__c 
                                     where User_BI__c =:trigger.new[0].User_BI__c
                                     and
                                     Event_Management_BI__c = :MedEv
                                     ]; 
                                            
    if (ETM.size() > 0)
        {
        system.debug('THIS USER HAS BEEN PREVIOUSLY ADDED AS AN EVENT TEAM MEMBER. User: ' + trigger.new[0].User_BI__c + ' Event=' + MedEv);    
        trigger.new[0].addError('THIS USER HAS BEEN PREVIOUSLY ADDED AS AN EVENT TEAM MEMBER. User: ' + trigger.new[0].User_BI__c + ' Event=' + MedEv);
        return;    
        }
        
    
    //if the new User  is the logged user do not create Share
    if (UserInfo.getUserId() == NEWUserID)  
        {
        system.debug('Logged user is the New user');    
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
        System.Debug('We are going to insert Share for event '+ MedEv + 'and user ' + NEWUserID);   
        insert MES;
        return;     
            
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
    }//END if INSERT
/************************************  INSERT TRIGGER ****************************************************************/

ID OLDUserID = trigger.old[0].User_BI__c;

Medical_Event_vod__Share[] MES1 = [Select Id, ParentId, UserOrGroupId,AccessLevel 
                                   from Medical_Event_vod__Share
                                   where ParentId = :MedEv
                                   and UserOrGroupId = :OLDUserID
                                   ];
                                   
    system.Debug('Hello 1. OldUser:' + OLDUserID + ' MES1.size() = ' + MES1.size() +  ' MES = '+  MedEv + ' MES1 = ' +  MES1);  
    //return;                                    
                                   

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
         System.Debug('Hello 1. NewUser:' + NEWUserID + ' MES1.size() = ' + MES1.size()); 
         
 
        if(MES1.size() >0 )
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
        }                 
		else
		{
                System.Debug('The  current User was not added as share for some reason at creation time!! Create it now');
                //2013.05.16.
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
                    system.Debug('We are going to create a share for MedEv: ' + MedEv + ' ad User: ' + NEWUserID);  
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
                //2013.05.16.			
		}
		return;
      }
    
     
     //if we are here either the old user != NewUser  or the NewUser  the logged one   
    if (MES1.size() == 0)   
        {
        //trigger.new[0].adderror('there was no sharing  for the OLD user.  Less probable since is an update    ');    
        //return;  
        }
    else
        {
        if (NEWUserID != OLDUserID) 
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