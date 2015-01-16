/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Show related list of products on Country filter by Product Type Product Detail   
*  @author:         Jefferson Escobar
*  @created:        06-May-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:          29.0 (Force.com ApiVersion) 
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         06-May-2014                 jescobar                    Construction of the class.
*/ 
 
public class IMP_BI_CountryView {   

    public List<Product_vod__c> products;
    public Country_BI__c country {get;private set;}
    public Integer rowsPage {get;set;}
    public Integer showAll;
    public Integer showMore {get;private set;}
    private Integer totalRecords;
    public boolean hasError {get;private set;}
    private Set<String> typeSetting = IMP_BI_Product_Catalog_Setting__c.getAll().keySet();
    
    /**
    * The contsructor
    *
    * @param ctr Country controller parameter
    *
    * @changelog
    *  06-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    *  - Created
    */
    public IMP_BI_CountryView(ApexPages.standardController ctr){
        country = (Country_BI__c) ctr.getRecord();     
          
        if(country!=null&&country.Id!=null){
            //this.country = (Country_BI__c) ctr.getRecord();
            products = getProducts();
            system.debug(':: Products: ' + products);
            totalRecords = (products!=null && products.size()>0) ? products.size() : 0;
            rowsPage = 5;
            this.showMore=getShowMore();
            showAll= (totalRecords > 50) ?  50 :  totalRecords;
            hasError = false;
            system.debug(':: Has Id :: ' + ctr.getRecord());
        }else{
            //If an error occurred
            hasError = true;
        }
        
    }
    
    /**
    * Get products detail by Country Id
    *
    * @return List of products detail by country Id
    *
    * @changelog
    *  06-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    *  - Created
    */
    public List<Product_vod__c> getProducts(){
        products = [Select Id,Name, Active_BI__c,Product_Type_vod__c From Product_vod__c
                        where Country_BI__c = :this.country.Id and Product_Type_vod__c in :typeSetting Order by Name Asc];
        return products;
    }
    
    /**
    * Set value of show all records 
    *
    * @return 
    *
    * @changelog
    *  07-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    *  - Created
    */
    public void setShowAll(){
        Integer remaining = this.totalRecords - this.showAll;
        
        if((this.showAll+this.ShowMore)<this.totalRecords){
            this.showAll+=this.ShowMore;
        }else if(remaining>0){
            this.showAll += remaining;
        }
        
        //Set value show all records
        this.showAll = (this.showAll>145 ? 145 : this.showAll);
    }
    
    /**
    * Get String value of show all records 
    *
    * @return 
    *
    * @changelog
    *  13-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    *  - Created
    */
    public String getShowAll(){
        String plus =  (this.showAll < this.totalRecords) ? '+' : '';
        return '(' + this.showAll + plus + ')';
    }
    
    /**
    * value to show more records
    *
    * @return how many records will be showed
    *
    * changelog
    * 07-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    * - Created
    */
    public Integer getShowMore(){
        Integer showMore;
        Integer remaining = totalRecords - rowsPage;
        
        if(remaining <= 0){
            showMore=null;
        }else if(remaining>rowsPage){
            showMore = rowsPage; 
        }else{
            showMore = remaining; 
        }
        
        return (showMore > 45 ? 45 : showMore);
    }
    
    
    /**
    *
    * Action to show more records for products list
    * @return Pagereference
    *
    * changelog
    * 07-May-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
    * - Created
    */
    public Pagereference action_showMoreRecords(){
        system.debug(':: Show More: ' + showMore);
        this.rowsPage= ((this.rowsPage+showMore)>99 ? 100 : this.rowsPage+showMore);

        //Update Value of showAll records
        if(this.showMore!=null){
            setShowAll();
        }
        this.showMore = getShowMore();
        
        return null;
    }
}