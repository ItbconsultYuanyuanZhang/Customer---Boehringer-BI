/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Test for IMP_BI_CountryView(All) class
*  @author:         Jefferson Escobar
*  @created:        15-May-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			30.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         15-May-2014                 jescobar                 	Construction of the class.
*/
@isTest
private class IMP_BI_CountryView_Test {

    static testMethod void testCountryView() {
        
        //Create test data
        insert new IMP_BI_Product_Catalog_Setting__c(Name='Detail');
        
        Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	c.Country_Code_BI__c = 'Z0';
    	insert c;
    	
    	List<Product_vod__c> products = new List<Product_vod__c>(); 
    	for(Integer i=0;i<101;i++){
    		products.add(new Product_vod__c(Name = i+'-Test Product',Product_Type_vod__c = 'Detail',Country_BI__c = c.Id,Active_BI__c = true));
    	}
    	
    	insert products;
    	
    	//Start testing
    	Test.startTest();
    	
    	//Test without showing records
    	new IMP_BI_CountryView(new Apexpages.Standardcontroller( new Country_BI__c ()));
    	new IMP_BI_CountryViewAll(new Apexpages.Standardcontroller( new Country_BI__c ()));
    	
    	//Test to Country View page layout
    	Apexpages.Standardcontroller ctr = new Apexpages.Standardcontroller(c);
    	IMP_BI_CountryView ctrCountry = new IMP_BI_CountryView(ctr);
    	ctrCountry.action_showMoreRecords();
    	ctrCountry.getShowAll();
    	
    	
    	//Test to Country View All Products page layout
    	Apexpages.Standardcontroller ctrAll = new Apexpages.Standardcontroller(c);
    	IMP_BI_CountryViewAll ctrCountryAll = new IMP_BI_CountryViewAll(ctrAll);
    	ctrCountryAll.getSortDirection();
    	ctrCountryAll.setSortDirection('DESC');
    	ctrCountryAll.sortData();
    	
    	
    	
    	//Pagination
        IMP_BI_Paging itemsPaging = new IMP_BI_Paging(100, 10);
        ctrCountryAll.itemsPaging = itemsPaging;
        ctrCountryAll.next();
    	ctrCountryAll.prev();
    	
    	Test.stopTest();
    	//Stop testing
    }
}