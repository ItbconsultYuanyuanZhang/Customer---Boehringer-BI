/**************************************
Helper class to default the DCR fields.
**************************************/
public with sharing class VEEVA_DCR_HLP 
{

	public String errorMsg {get; set;}
	ID PersonAccount = NULL;
	ID WKP_Account = NULL;
	
	public void SetPerson(ID theID)
	{
		this.PersonAccount = theID;
	}
	
	public void setWKP(ID theID)
	{
		this.WKP_Account = theID;
	}
	
	public VEEVA_DCR_HLP()
	{
		
	}
	
	/***********************************************************************
	
	***********************************************************************/
	public boolean GetAdresses(V2OK_Data_Change_Request__c DCR, Boolean TDF)
	{
		// BI uses State_vod__c (and/or the state_provice field) rather than ACT_CORE_County__c
		// Address_vod__c[] addr = [Select ID, City_vod__c,Zip_vod__c,ACT_CORE_County__c, Name,Country_vod__c 
		Address_vod__c[] addr = [Select ID, City_vod__c,Zip_vod__c, OK_State_Province_BI__c, Name,Country_vod__c, Country_Code_BI__c
		                         from Address_vod__c
		                         where primary_vod__c = true
		                         and Account_vod__c = :this.WKP_Account
		                        ];
		                        
		if (addr.size() == 0)
		{
			this.errorMsg = 'Missing primary address';
			return false;
		}
		
		if (//addr[0].ACT_CORE_County__c == NULL ||
			addr[0].OK_State_Province_BI__c == NULL || 
		    addr[0].Zip_vod__c == NULL ||
		    (addr[0].Country_vod__c == NULL && addr[0].Country_Code_BI__c == NULL) || 
		    addr[0].City_vod__c == NULL || addr[0].Name == NULL)
		{
			this.errorMsg = 'Address State/City/Country/zip/address Line is missing. Check primary address of WKP or IND Primary parent.';
			//DCR.addError(this.errorMsg);
			return false;
		}
		
		if (TDF == true)
		{
			DCR.Address__c = addr[0].id;
			DCR.Country_DS__c = (addr[0].Country_Code_BI__c == NULL) ? addr[0].Country_vod__c : addr[0].Country_Code_BI__c;
			DCR.City_vod__c = addr[0].City_vod__c;
			
			// County is not used by BI - but the state is
			//DCR.County_DS__c = addr[0].ACT_CORE_County__c;
			DCR.OK_State_Province_BI__c = addr[0].OK_State_Province_BI__c;
			
			DCR.Zip_vod__c = addr[0].Zip_vod__c;
			DCR.New_Address_Line_1__c = addr[0].Name;
		}
		else
		{
		if(DCR.Country_DS__c == NULL)
		   DCR.Country_DS__c = (addr[0].Country_Code_BI__c == NULL) ? addr[0].Country_vod__c : addr[0].Country_Code_BI__c;
		   
		if(DCR.City_vod__c  == NULL)
		   DCR.City_vod__c  = addr[0].City_vod__c;  	
	
		/** County not used by BI - State/Province is	   
		if(DCR.County_DS__c == NULL)
		    DCR.County_DS__c = addr[0].State_vod__c;
		   //DCR.County_DS__c = addr[0].ACT_CORE_County__c;
		**/
		if (DCR.OK_State_Province_BI__c == NULL)
			DCR.OK_State_Province_BI__c = addr[0].OK_State_Province_BI__c; 	   
	
		if(DCR.Zip_vod__c == NULL)
		   DCR.Zip_vod__c = addr[0].Zip_vod__c;
		   
		if (DCR.New_Address_Line_1__c == NULL)
		   DCR.New_Address_Line_1__c = addr[0].Name;   
		}
		
		
		return true;                          
		
	}
	
	/********************************************************************************
	get the role ffrom child account where IND/WKP belongs.
	********************************************************************************/
	public boolean checkParentChild(V2OK_Data_Change_Request__c DCR,boolean isCreate)
	{
		// Change the OK external ID to be the implementation specific one
		Child_Account_vod__c[] CAs = [Select Id, External_ID2__c
		                              from Child_Account_vod__c
		                              where Child_Account_vod__c =:PersonAccount and 
		                              Parent_Account_vod__c = :WKP_Account    
		                             ];
		
		if (CAs.size() == 0 && isCreate == false)
		{
			this.errorMsg = 'No Parent/Child relationship for the selected Person Organisation';
			return false;
		}
		
		if (CAs.size() > 0 && isCreate == true)
		{
			this.errorMsg = 'the selected Person/Organisation are already related';
			return false;
		}
		
		if(isCreate == false)
		{   
			// if(DCR.Role__c == NULL)
		    //    DCR.Role__c = CAs[0].ACT_CORE_OK_Role_1__c;
		    // TODO: Roles?    
		}
		
		
		return true;
	}
	
	/***********************************************************************************
	Populate primary Parent  and Role
	***********************************************************************************/
	public Boolean GetPrimaryParentData(V2OK_Data_Change_Request__c DCR, String RT_Name)
	{
		// Change the role to be the implementation specific one
		// TODO - does BI need two (not one) role fields?
		Child_Account_vod__c[] CAs = [Select Id, Role_BI__c, Role_2_BI__c, Parent_Account_vod__c
		                              from Child_Account_vod__c
		                              where Child_Account_vod__c =:PersonAccount 
		                              and Primary_vod__c = 'Yes'
		                             ];
		
		if (CAs.size() == 0)
		{
			this.errorMsg = 'The Selected account has no Primary Parent';
			return false;
		}
		
		DCR.Organisation_Account__c = CAs[0].Parent_Account_vod__c;	
		DCR.Role_BI__c = CAs[0].Role_BI__c;
		// TODO: The second role field here
			
		return true;
	}
	
	/**********************************************************************************
	If  RecordType is Hierarchy Or change Type Delete just Default
	If RecordType is Professional  and cnage type is Update default
	the missing fields
	***********************************************************************************/
	public boolean PopulatePersonFields(V2OK_Data_Change_Request__c DCR, String RT_Name)
	{
	
		Account[] Acc = [Select 
				         Specialty_BI__c, 
				         FirstName,
				         LastName,
				         isPersonAccount,
				         // Change the individual class field to the implementation specific one
				         OKIndividual_Class_BI__c,
				         PersonTitle,
				         Gender_vod__c,
				         Salutation,
				         // Change the below OK external ID field to be the implementation specific one
				         OK_External_ID_BI__c
						 from Account 
						 where ID = :PersonAccount
						 ];
							 	
							 	   
				if (DCR.Specialty_BI__c == NULL || DCR.Change_Type__c == 'Delete' || RT_Name == 'Hierarchy')
					DCR.Specialty_BI__c = Acc[0].Specialty_BI__c;
		 
				if (DCR.First_Name__c == NULL || DCR.Change_Type__c == 'Delete' || RT_Name == 'Hierarchy') 
					DCR.First_Name__c = Acc[0].FirstName;
			  
				if (DCR.Last_Name__c == NULL || DCR.Change_Type__c == 'Delete' || RT_Name == 'Hierarchy')
					DCR.Last_Name__c = Acc[0].LastName;	
					  
			    //some customer use Gender. depends on Individual load mapping	
			    /* NOT FOR BI	    			
			    if (DCR.Gender_DS__c == NULL || DCR.Change_Type__c == 'Delete' || RT_Name == 'Hierarchy') 
			        DCR.Gender_DS__c = Acc[0].Salutation;
			    */  
			        
			    if (DCR.OK_Individual_Class_BI__c == NULL || DCR.Change_Type__c != 'Create' || RT_Name == 'Hierarchy') {
			    	// Change individual class to implementation specific one
			       DCR.OK_Individual_Class_BI__c = Acc[0].OKIndividual_Class_BI__c;
			    }
		
		
		return true;
	}
	
	/****************************************************************
	If change type is Delete  just Default
	If change type is Update default the missing fields 
	****************************************************************/
	public boolean PopulateWKPFields(V2OK_Data_Change_Request__c DCR)
	{
		// Change the (workplace) class and the OK External ID to be the implementation specific ones
		Account[]  OrgAcc = [Select OKWorkplace_Class_BI__c,Name,Phone
							,Specialty_BI__c
							,RecordType.Name
							,isPersonAccount 
							,OK_External_ID_BI__c 
				            from Account 
				            where Id =:WKP_Account
				            ];	
	
		// Change the OK external ID to be the implementation specific one			            
		if (OrgAcc[0].OK_External_ID_BI__c == NULL)
		{
			this.errorMsg = 'Missing OneKey ID.  Request denied  to avoid rejection!';
			return false;				
		}
		
	
		// Change the (workplace) class to be the implementation specific one
		DCR.OK_Workplace_Class_BI__c = OrgAcc[0].OKWorkplace_Class_BI__c; 
	
		//if user left epty fill it.                    
		if (DCR.New_Account_Name__c == NULL || DCR.Change_Type__c == 'Delete')
			DCR.New_Account_Name__c = OrgAcc[0].Name;
				 
		if (DCR.Phone__c == NULL || DCR.Change_Type__c == 'Delete')
			DCR.Phone__c = OrgAcc[0].Phone;
			    	
		if (DCR.Workplace_Specialty_BI__c == NULL || DCR.Change_Type__c == 'Delete')
			DCR.Workplace_Specialty_BI__c = OrgAcc[0].Specialty_BI__c;			
		
		return true;
	}
	
	public boolean GetWorkplaceClass(V2OK_Data_Change_Request__c DCR)
	{
	
		//get the WKP class
		// Change the field names to be the implementation specific ones
		Account[]  OrgAc = [Select OKWorkplace_Class_BI__c, OK_External_ID_BI__c
		                    from Account  
		                    where Id =:WKP_Account];	
			    
	
		// change the OK id to be the implementation specific one
		if(OrgAc[0].OK_External_ID_BI__c == NULL)
		{
			this.errorMsg = 'OneKey ID missing for Organisation. Request  denied to avoid rejection!';
			return false;
		}
	
		// Use the implementation specific workplace class field                
		DCR.OK_Workplace_Class_BI__c = OrgAc[0].OKWorkplace_Class_BI__c;	
		if (DCR.OK_Workplace_Class_BI__c == NULL)
		{
			this.errorMsg = 'Workplace class missing for Organisation. Request  denied to avoid rejection!';
			return false;			    	
		}
	
		return true;
		
	}

}