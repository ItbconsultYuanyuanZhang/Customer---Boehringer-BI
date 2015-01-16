/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      New/Edit Budget Allocation Page
*  @author:         Jefferson Escobar
*  @created:        03-Apr-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			29.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         03-Mar-2014                 jescobar                 	Construction of the class.
*/ 

public class IMP_BI_BudgetAllocationDefintion {
	
	//Page attributes
	public Budget_Allocation_BI__c budgetAllocation {get;private set;}
	
	//Errors attributes
	public boolean hasError {get; private set;}
	private String errMsg = ''; 
	
	//Page details
	public static final String LABEL_BUDGET_ALLOCATION = Schema.SObjectType.Budget_Allocation_BI__c.getLabel();
	public static final String KEYPREFIX_CYCLE = Schema.SObjectType.Cycle_BI__c.getKeyPreFix();
    public String pageTitle {get; private set;}
    public String sectionHeaderTitle {get; private set;}
    public String sectionHeaderSubTitle {get; private set;}
    private Map<String, String> map_urlParams;
    
    //Class attributes
   	private String idCountry;
    
    
    //Components Form
    public List<Selectoption> productsByCountry {get;private set;}
    private Set<String> typeSetting = IMP_BI_Product_Catalog_Setting__c.getAll().keySet();
    public List<Selectoption> channels {get;private set;}
    
	public IMP_BI_BudgetAllocationDefintion(ApexPages.standardController ctr){
		hasError = false;
		
		if(ctr.getId()!=null){//Edit  Budget Allocation
			budgetAllocation = [Select Id,Name,Cycle_BI__c,Cycle_BI__r.Country_Lkp_BI__c,Product_Catalog_BI__c,Country_BI__c,Budget_BI__c,Channel_BI__c From Budget_Allocation_BI__c where Id = :ctr.getId()];
			idCountry = budgetAllocation.Cycle_BI__r.Country_Lkp_BI__c;
			
			//initialize the page title
		    sectionHeaderSubTitle = budgetAllocation.Name;
		    sectionHeaderTitle = LABEL_BUDGET_ALLOCATION + ' Edit';
		    pageTitle = LABEL_BUDGET_ALLOCATION + ' ' + sectionHeaderTitle; 
					
		}else{// New Budget Allocation
			map_urlParams = ApexPages.currentPage().getParameters();
			String idCycle= map_urlParams.get('cId');
			//Get cycle and country Id
			Cycle_BI__c cycle = [Select Id,Name, Country_Lkp_BI__c From Cycle_BI__c where Id = :idCycle];
			idCountry = cycle.Country_Lkp_BI__c;
		
			budgetAllocation = new Budget_Allocation_BI__c (Cycle_BI__c = idCycle);
		
			//initialize the page title
		    sectionHeaderSubTitle = 'New ' + LABEL_BUDGET_ALLOCATION;
		    sectionHeaderTitle = LABEL_BUDGET_ALLOCATION + ' Edit';
		    pageTitle = LABEL_BUDGET_ALLOCATION + ' ' + sectionHeaderTitle; 
		}
		
		//Get select options 		
		productsByCountry = getProductsByCountry(idCountry);
		channels = getChannels();
	}
	
	//********************************* -=BEGIN public methods=- **********************************
   /**
	* This method is used to get list of Product by country id
	*
	@author  Jefferson Escobar
	@created 03-Apr-2014
	@version 1.0
	@since   29.0 (Force.com ApiVersion)
	*
	@return  products	list<SelectOption>
	*
	@changelog
	* 03-Apr-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
    public List<SelectOption> getProductsByCountry(String idCountry){
    	List<SelectOption> products = new List<SelectOption>();
    	
    	products.add(new SelectOption('', '--None--'));
		
		for(Product_vod__c p : [SELECT Id, Name FROM Product_vod__c WHERE Active_BI__c = true AND Country_BI__c = :idCountry AND Product_Type_vod__c in :typeSetting ORDER BY Name]){
	        if(p.Name != null) 
	        	products.add(new SelectOption(p.Id, p.Name));
    	}
    	
    	if(products==null||products.isEmpty()){
			if(!hasError){
	    		hasError = true;
				errMsg = 'There is no available Products for this Cycle!'; 
			}
			
	    	products.add(new SelectOption('', '--None--'));
    	}
        return products;
    }
    
     /**
	* This method is used to get list of channels
	*
	@author  Jefferson Escobar
	@created 03-Apr-2014
	@version 1.0
	@since   29.0 (Force.com ApiVersion)
	*
	@return  channels	list<SelectOption>
	*
	@changelog
	* 03-Apr-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
    public list<SelectOption> getChannels(){
    	List<SelectOption> channels = new List<SelectOption>();
    	channels.add(new SelectOption('', '--None--'));

		for(Channel_BI__c ch : [SELECT Id, Name FROM Channel_BI__c ORDER BY Name]){
	        	channels.add(new SelectOption(ch.Id, ch.Name));
    	}

    	return channels;
    }
    
    /**
	* This method is used to cancel back to cycle detail page
	*
	@author  Jefferson Escobar
	@created 03-Apr-2014
	@version 1.0
	@since   29.0 (Force.com ApiVersion)
	*
	@return  Pagereference
	*
	@changelog
	* 03-Apr-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/  	
	public Pagereference cancel(){
		Pagereference page;
		
		if(budgetAllocation != null && budgetAllocation.Cycle_BI__c != null){
			page = new Pagereference('/' + budgetAllocation.Cycle_BI__c);
		}
		else{
			page = new Pagereference('/' + KEYPREFIX_CYCLE);
		}
		page.setRedirect(true);
		return page;
	}
	
	/**
	* Save a new budget allocation
	*
	@author  Jefferson Escobar
	@created 03-Apr-2014
	@version 1.0
	@since   29.0 (Force.com ApiVersion)
	*
	@param budget JSON Budget Allocation Object
	*
	@return  Pagereference
	*
	@changelog
	* 03-Apr-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	* - Created
	*/
	@RemoteAction  	
	public static String saveBudget(String budgetJSON){
		Response r = new Response();
		SavePoint sp;
        
        try{
        	system.debug(':: JSON Object: ' + budgetJSON);
        	sp = Database.setSavepoint();
        	ClsBudgetAllocation clsBudget = (ClsBudgetAllocation)JSON.deserialize(budgetJSON, ClsBudgetAllocation.class);
        	system.debug(':: Budget Object to save: ' + clsBudget);
        	
        	Budget_Allocation_BI__c budgetAllocation = new Budget_Allocation_BI__c();
        	budgetAllocation.Id = (clsBudget.Id !=null && clsBudget.Id != '') ? clsBudget.Id : null;
        	
        	if(clsBudget.Id == null || clsBudget.Id == '')
        		budgetAllocation.Cycle_BI__c = clsBudget.cycle;
        		
        	budgetAllocation.Product_Catalog_BI__c = clsBudget.product;
        	budgetAllocation.Channel_BI__c = clsBudget.channel;
        	budgetAllocation.Budget_BI__c = clsBudget.budget;
        	
        	//Insert/Update record object
        	upsert budgetAllocation; 
        	
        }catch(DmlException de){
    		Database.rollback(sp);
    		r.success = false;
			r.message = de.getMessage();
			return JSON.serialize(r);
    	}
    	catch(Exception e){
    		r.success = false;
			r.message = e.getMessage();
			return JSON.serialize(r);
    	}
    	
		r.success = true;
		r.message = 'OK';
		return JSON.serialize(r);
	}

/**
==================================================================================================================================
												Wrapper Classes                                                     
==================================================================================================================================
*/
	public class ClsBudgetAllocation{
		public String Id {get;set;}
		public String cycle {get;set;}
		public String product {get;set;}
		public String channel {get;set;}
		public Integer budget {get;set;}
	}
	
	public class Response{
		public boolean success;
		public string message;
		
		public Response(){
			success = true;
			message = '';
		}
	}
}