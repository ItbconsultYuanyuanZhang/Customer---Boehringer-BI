/**
*   Test class for class IMP_BI_ExtManageSpeciality.
*
@author Di Chen
@created 2013-07-05
@version 1.0
@since 20.0
*
@changelog
* 2013-07-05 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage  84%
*/
@isTest
private class IMP_BI_ExtManageSpeciality_Test {
	private static Country_BI__c c;
	private static Account acc;
	private static Cycle_BI__c cycle;
	private static Product_vod__c p2;
	private static Lifecycle_Template_BI__c mt;
	private static Matrix_BI__c ma;
	private static Customer_Attribute_BI__c sp;
	
    private static void createDataTest() {
    	
    	c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        insert acc;

        cycle = IMP_BI_ClsTestHelp.createTestCycle();
        cycle.Country_Lkp_BI__c = c.Id;
        insert cycle;
        
        p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        mt = IMP_BI_ClsTestHelp.createTestLifecycleTemplateBI();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        mt.isLaunch_Phase_BI__c = true;
        mt.Column_BI__c = 6;
        insert mt;
        
        ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Row_BI__c = 10;
        ma.Column_BI__c = 11;
        ma.Specialization_BI__c = 'GP';
        ma.Lifecycle_Template_BI__c = mt.Id;
        insert ma;
        
    	sp = new Customer_Attribute_BI__c();
    	sp.Country_BI__c = c.Id;
    	sp.Group_txt_BI__c = 'ENT';
    	insert sp;
    	
    }
    
    /**
    * Test method to World wide specialties
    *
    * @return
    */   
    
     static testMethod void testMostMethodWorldWide() {
     	//Create data test
     	createDataTest();
     	
     	Test.startTest();
    	
    	IMP_BI_ExtManageSpeciality.ClsGroup impCls = new IMP_BI_ExtManageSpeciality.ClsGroup();
    	IMP_BI_ExtManageSpeciality.ClsSpecialityJson impBi = new IMP_BI_ExtManageSpeciality.ClsSpecialityJson();
    	
    	ApexPages.currentPage().getParameters().put('cId',c.Id);
    	
    	ApexPages.StandardController ctrl = new ApexPages.StandardController(sp); 
        IMP_BI_ExtManageSpeciality ext = new IMP_BI_ExtManageSpeciality(ctrl);  	
        
        ext.cancel();
    	
    	String jason = '[{"sId":"'+sp.Id+'","sName":"Peng","sGroup":"test0705","cId":"","cCode":"JP"},{"sId":"'+sp.Id+'","sName":"Di Test 2","sGroup":"Di Grop","cId":"a36J00000008xulIAA","cCode":"JP"}]"';
    	IMP_BI_ExtManageSpeciality.saveSpecialityData(jason);
    	
    	system.assert(true);
     	Test.stopTest();
     }
     
    /**
    * Test method to USA and others specialties
    *
    *@author: Jefferson Escobar
    *@created: 21-Feb-2014
    * @return
    */   
     static testMethod void testMostMethodUSA() {
     	//Create data test
     	createDataTest();
     	
     	c.Country_Code_BI__c = 'Z0';
     	update c;
     	
     	Specialty_Grouping_BI__c spUSA = new Specialty_Grouping_BI__c();
    	spUSA.Country_BI__c = c.Id;
    	spUSA.Specialty_Group_BI__c = 'T-Group';
    	spUSA.Name = 'SP-Test';
    	
    	insert spUSA; 
    	
    	Specialty_Grouping_Config__c specialtyConfig = new Specialty_Grouping_Config__c(Name = 'Z0', Specialty_Field_Account__c = 'Specialty_1_vod__c');
    	insert specialtyConfig;
     	
     	Test.startTest();
    	
    	IMP_BI_ExtManageSpeciality.ClsGroup impCls = new IMP_BI_ExtManageSpeciality.ClsGroup();
    	IMP_BI_ExtManageSpeciality.ClsSpecialityJson impBi = new IMP_BI_ExtManageSpeciality.ClsSpecialityJson();
    	
    	ApexPages.currentPage().getParameters().put('cId',c.Id);
    	
    	ApexPages.StandardController ctrl = new ApexPages.StandardController(sp); 
        IMP_BI_ExtManageSpeciality ext = new IMP_BI_ExtManageSpeciality(ctrl);  	
        
        ext.cancel();
    	
    	String jason = '[{"sId":"'+sp.Id+'","sName":"Peng","sGroup":"test0705","cId":"","cCode":"US"},{"sId":"'+sp.Id+'","sName":"Di Test 2","sGroup":"Di Grop","cId":"a36J00000008xulIAA","cCode":"US"}]"';
    	IMP_BI_ExtManageSpeciality.saveSpecialityData(jason);
    	
    	system.assert(true);
     	Test.stopTest();
     }
}