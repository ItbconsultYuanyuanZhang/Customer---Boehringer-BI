/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Test for IMP_BI_BudgetAllocationDefintion class
*  @author:         Jefferson Escobar
*  @created:        04-Apr-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			29.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         04-Apr-2014                 jescobar                 	Construction of the class.
*/
@isTest
private class IMP_BI_MatrixTemplateDefinition_Test {

    static testMethod void tstMatrixTemplate() {
        //Create test data
        Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	c.Country_Code_BI__c = 'Z1';
    	insert c;
    	
    	
        insert new IMP_BI_Product_Catalog_Setting__c(Name='Detail');
        Product_vod__c p = IMP_BI_ClsTestHelp.createTestProduct();
        p.Country_BI__c = c.Id;
        p.Name =  'P-Testing';
        p.Product_Type_vod__c = 'Detail';
        insert p;
        
        Lifecycle_Template_BI__c lfct = IMP_BI_ClsTestHelp.createTestLifecycleTemplateBI();
        lfct.Country_BI__c = c.Id;
        insert lfct;
        
        Customer_Attribute_BI__c sp = new Customer_Attribute_BI__c();
    	sp.Country_BI__c = c.Id;
    	sp.Group_txt_BI__c = 'T-Group';
    	sp.Name = 'SP-Test';
    	sp.Country_Code_BI__c = c.Country_Code_BI__c;
    	insert sp;
    	
    	Specialty_Grouping_BI__c spGrouping = new Specialty_Grouping_BI__c();
    	spGrouping.Country_BI__c = c.Id;
    	spGrouping.Specialty_Group_BI__c = 'T-Group';
    	spGrouping.Name = 'SP-Test';
    	insert spGrouping;
    	
    	Specialty_Grouping_Config__c specialtyConfig = new Specialty_Grouping_Config__c(Name = 'Z0', Specialty_Field_Account__c = 'Specialty_1_vod__c');
    	insert specialtyConfig;
    	
    	Matrix_Template_BI__c matrixTemplate = new Matrix_Template_BI__c(Name = 'M-Template Testing',Country_BI__c=c.Id,Lifecycle_Template_BI__c=lfct.Id,
    								Specialties_BI__c=sp.Name,Specialty_Ids_BI__c=sp.Id,Product_Catalog_BI__c=p.Id);
    	insert matrixTemplate; 
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('cId',c.Id);    	
    	IMP_BI_MatrixTemplateDefinition ctrMT = new IMP_BI_MatrixTemplateDefinition(new Apexpages.Standardcontroller(matrixTemplate));
    	
    	
    	//Set values matrix template to JSON object
    	String budgetJSON = '{"Id":"'+matrixTemplate.Id+'","name":"'+matrixTemplate.Name+'","countryId":"'+c.Id+'","countryCode":"'+c.Country_Code_BI__c+'","countryCodeRegion":"'+c.Country_Code_Region_BI__c
    							+'","productId":"'+ p.Id+'","cycleTemplateId":"'+lfct.Id+'","specialties":["'+sp.Name+'"]}';
    	IMP_BI_MatrixTemplateDefinition.saveMatixTemplate(budgetJSON);
    	
    	ctrMT.cancel();
    	
    	//Testing new Template
    	ApexPages.currentPage().getParameters().put('specialties',sp.Name);
    	ApexPages.currentPage().getParameters().put('pId',p.Id);
    	ApexPages.currentPage().getParameters().put('lctId',lfct.Id);
    	
    	//Set up a new matrix template
    	c.Country_Code_BI__c = 'Z0';
    	update c;
    	new IMP_BI_MatrixTemplateDefinition(new Apexpages.Standardcontroller(new Matrix_Template_BI__c()));
    	IMP_BI_MatrixTemplateDefinition.saveMatixTemplate(budgetJSON);
    	new IMP_BI_MatrixTemplateDefinition.ClsMatrixTemplate();
    	
    	
        Test.stopTest(); 
    }
}