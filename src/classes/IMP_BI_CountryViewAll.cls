/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Show all related list of products on Country filter by Product Type Product Detail   
*  @author:         Jefferson Escobar
*  @created:        09-May-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:          29.0 (Force.com ApiVersion) 
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         09-May-2014                 jescobar                    Construction of the class.
*/ 

public class IMP_BI_CountryViewAll {
    
    public List<Product_vod__c> products {get;private set;}
    public Country_BI__c country {get;private set;}
    public Integer rowsPage {get;private set;}
    public boolean hasError {get;private set;}
    private Set<String> typeSetting = IMP_BI_Product_Catalog_Setting__c.getAll().keySet();
    
    /**Paginator */
    public IMP_BI_Paging itemsPaging {get; set;}
    private static Integer ITEMS_PER_PAGE = 100;
    
    /**Sort action variables */
       private String sortDirection = 'ASC';
   private String sortExp = 'Name';

   public String sortExpression
   {
     get
     {
        return sortExp;
     }
     set
     {
       //if the column is clicked on then switch between Ascending and Descending modes
       if (value == sortExp)
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       else
         sortDirection = 'ASC';
       sortExp = value;
     }
   }
    
    
    /**
    * The contsructor
    *
    * @param ctr Country controller parameter
    *
    * @changelog
    *  09-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    *  - Created
    */
    public IMP_BI_CountryViewAll(ApexPages.standardController ctr){
        if(ctr.getId()!=null){
            hasError = false;
            country = [Select Id,Name From Country_BI__c where Id = :ctr.getId()];
            products = [Select Id,Name, Active_BI__c,Product_Type_vod__c From Product_vod__c
                    where Country_BI__c = :this.country.Id and Product_Type_vod__c in :typeSetting Order by Name Asc];
            itemsPaging = new IMP_BI_Paging(products.size(), ITEMS_PER_PAGE);
        }else{//If an error occurred
            hasError = true;
        }
    }
    
    /**
    * Get sort direction
    *
    * @return type of sort direction
    *
    * @changelog
    *  13-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    *  - Created
    */
    public String getSortDirection(){
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
    }
    
    /**
    * Set sort direction value
    *
    * @return type of sort direction
    *
    * @changelog
    *  13-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    *  - Created
    */
     public void setSortDirection(String value){  
       sortDirection = value;
     }
    
    /**
    * Sorting the prodcuts by Name
    *
    * @return Pagereference
    *
    * @changelog
    *  13-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    *  - Created
    */
    public Pagereference sortData(){
    	String productsType='';
    	
    	Integer i=1;
    	for(String t : this.typeSetting){
    		productsType+= '\'' + t + '\'' + (i==typeSetting.size() ? '' : ',' );
    		i++;
    	}
    	
    	system.debug(':: Types: ' + productsType);
        String sortFullExp = sortExpression  + ' ' + sortDirection;//build the full sort expression
        String query='Select Id,Name, Active_BI__c,Product_Type_vod__c From Product_vod__c where Country_BI__c = \'' + this.country.Id +'\' and Product_Type_vod__c in ' + '(' +productsType+ ')' +' Order by '+ sortFullExp;
        this.products = Database.query(query);//query the database based on the sort expression
        
        return null;
   }
   
   public Pagereference prev() {        
        itemsPaging.previous();
        return null;
    }
    
    public Pagereference next() {       
        itemsPaging.next();
        return null;
    }
}