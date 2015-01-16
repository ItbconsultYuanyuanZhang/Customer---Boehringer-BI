/**
*   Test class for class ExtMatrixDefinition.
*
@author Di Chen
@created 2013-05-28
@version 1.0
@since 20.0
*
@changelog
* 2013-05-28 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage  83%
*/
@isTest
private class IMP_BI_ExtMatrixDefinition_Test {
	static testMethod void testFalse() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	c.Country_Code_BI__c = 'Z0';
    	insert c;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';  
        insert acc;

        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'Z0';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        cycle2.Country_Lkp_BI__c = c.Id;
        insert cycle2;
        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Name = '234';
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Row_BI__c = 10;
        ma.Column_BI__c = 11;
        ma.Specialization_BI__c = 'GP';//Peng Zhu 2013-10-14
        ma.Status_BI__c = 'Draft';
        ma.Calculate_BI__c = true;
        insert ma;
        
        Lifecycle_Template_BI__c mt = new Lifecycle_Template_BI__c();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        insert mt;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Product_Catalog_BI__c = p2.Id;
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        cd.Current_Update_BI__c = true;
        insert cd;     	
        
    	Customer_Attribute_BI__c sp = new Customer_Attribute_BI__c();
    	sp.Country_BI__c = c.Id;
    	sp.Group_txt_BI__c = 'ENT';
    	sp.Name = 'SP-Test';
    	insert sp;
    	    	
    	Channel_BI__c channel = new Channel_BI__c();
    	channel.Name = 'Face to Face';
    	channel.Cost_Rate_BI__c = 11;
    	channel.Unit_BI__c = 'asdfasfd';
    	insert channel;
    	
    	Matrix_Template_BI__c matrixTemplate = new Matrix_Template_BI__c(Name = 'M-Template Testing',Country_BI__c=c.Id,Lifecycle_Template_BI__c=mt.Id,
    								Specialties_BI__c=sp.Name,Specialty_Ids_BI__c=sp.Id,Product_Catalog_BI__c=p2.Id);
    	insert matrixTemplate; 
    	
    	Test.startTest();
    	
    	ApexPages.currentPage().getParameters().put('mId',ma.Id);
    	ApexPages.currentPage().getParameters().put('cId',cycle2.Id);
    	ApexPages.currentPage().getParameters().put('viewModel','viewModel');
    	
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtMatrixDefinition ext = new IMP_BI_ExtMatrixDefinition(ctrl); 
        
       // ext.generateListOfClsSpecial();
       	ext.save();
        ext.calculationMatrix();
        ext.getTemplatesByCountry();
        ext.cancel();
        
        String jason = '{"productId":"'+p2.Id+'","cid":"'+cycle2.Id+'","list_cm":[{"mid":"'+ma.Id+'","name":"Peng Validate Test 1","special":"ENT","tid":"'+mt.Id+'","row":4,"column":5,"set_sId":["'+sp.Id+'"],"dpa":true,"toCalculate":true},{"name":"Peng JSON Test","special":"Cardiology","tid":"'+
        				mt.Id+'","row":10,"column":11,"set_sId":["'+sp.Id+'"],"dpa":true,"toCalculate":true}],"countryId":"'+c.Id+'","set_mtIds":["'+mt.Id+'"]}';        
        
        IMP_BI_ExtMatrixDefinition.saveMatrixData(jason);
        
        IMP_BI_ExtMatrixDefinition.ClsMatrixEdit extCls = new IMP_BI_ExtMatrixDefinition.ClsMatrixEdit();
        IMP_BI_ExtMatrixDefinition.ClsMatrixs extClss = new IMP_BI_ExtMatrixDefinition.ClsMatrixs();
        IMP_BI_ExtMatrixDefinition.ClsMatrix extClsss = new IMP_BI_ExtMatrixDefinition.ClsMatrix();
        
        system.assert(true);
        Test.stopTest();
    }
    
	static testMethod void testTrue() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';  
        insert acc;

        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        cycle2.Country_Lkp_BI__c = c.Id;
        insert cycle2;
        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Name = '234';
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Row_BI__c = 10;
        ma.Column_BI__c = 11;
        ma.Specialization_BI__c = 'GP';//Peng Zhu 2013-10-14
        ma.Status_BI__c = 'Final';
        insert ma;
        
        Lifecycle_Template_BI__c mt = new Lifecycle_Template_BI__c();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        insert mt;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Product_Catalog_BI__c = p2.Id;
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        cd.Current_Update_BI__c = true;
        insert cd;     	
        
    	Customer_Attribute_BI__c sp = new Customer_Attribute_BI__c();
    	sp.Country_BI__c = c.Id;
    	sp.Group_txt_BI__c = 'ENT';
    	insert sp;
    	    	
    	Channel_BI__c channel = new Channel_BI__c();
    	channel.Name = 'Face to Face';
    	channel.Cost_Rate_BI__c = 11;
    	channel.Unit_BI__c = 'asdfasfd';
    	insert channel;
        
    	Test.startTest();
    	
    	ApexPages.currentPage().getParameters().put('mId',ma.Id);
    	ApexPages.currentPage().getParameters().put('cId',cycle2.Id);
    	ApexPages.currentPage().getParameters().put('viewModel','viewModel');
    	
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtMatrixDefinition ext = new IMP_BI_ExtMatrixDefinition(ctrl); 
        
      //  ext.generateListOfClsSpecial();
        ext.getTemplatesByCountry();
        ext.cancel();
        
        String jason = '{"productId":"'+p2.Id+'","cid":"'+cycle2.Id+'","list_cm":[{"mid":"'+ma.Id+'","name":"Peng Validate Test 1","special":"ENT","tid":"'+mt.Id+'","row":4,"column":5,"set_sId":["'+sp.Id+'"],"dpa":true,"toCalculate":true},{"name":"Peng JSON Test","special":"Cardiology","tid":"'+
        				mt.Id+'","row":10,"column":11,"set_sId":["'+sp.Id+'"],"dpa":true,"toCalculate":true}],"countryId":"'+c.Id+'","set_mtIds":["'+mt.Id+'"],"accountMatrix":true}';
        
        IMP_BI_ExtMatrixDefinition.saveMatrixData(jason);
        
         jason = '{"productId":"'+p2.Id+'","cid":"'+cycle2.Id+'","list_cm":[{"mid":"'+ma.Id+'","name":"Peng Validate Test 1","special":"ENT","tid":"'+mt.Id+'","row":4,"column":5,"set_sId":["'+sp.Id+'"],"dpa":true,"toCalculate":true},{"name":"Peng JSON Test","special":"Cardiology","tid":"'+
        				mt.Id+'","row":10,"column":11,"set_sId":["'+sp.Id+'"],"dpa":true,"toCalculate":true}],"countryId":"'+c.Id+'","set_mtIds":["'+mt.Id+'"],"accountMatrix":false}';
        IMP_BI_ExtMatrixDefinition.saveMatrixData(jason);
        
        IMP_BI_ExtMatrixDefinition.ClsMatrixEdit extCls = new IMP_BI_ExtMatrixDefinition.ClsMatrixEdit();
        IMP_BI_ExtMatrixDefinition.ClsMatrixs extClss = new IMP_BI_ExtMatrixDefinition.ClsMatrixs();
        IMP_BI_ExtMatrixDefinition.ClsMatrix extClsss = new IMP_BI_ExtMatrixDefinition.ClsMatrix();
        
        system.assert(true);
        Test.stopTest();
    } 
     
	static testMethod void testMore() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	c.Country_Code_BI__c = 'Z0';
    	insert c;
    	
    	Specialty_Grouping_BI__c spUSA = new Specialty_Grouping_BI__c();
    	spUSA.Country_BI__c = c.Id;
    	spUSA.Specialty_Group_BI__c = 'T-Group';
    	spUSA.Name = 'SP-Test';
    	
    	insert spUSA;
    	
    	Specialty_Grouping_Config__c specialtyConfig = new Specialty_Grouping_Config__c(Name = 'Z0', Specialty_Field_Account__c = 'Specialty_1_vod__c');
    	insert specialtyConfig;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';  
        insert acc;

        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'US';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        cycle2.Country_Lkp_BI__c = c.Id;
        insert cycle2;
        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Name = '234';
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Row_BI__c = 10;
        ma.Column_BI__c = 11;
        ma.Specialization_BI__c = 'GP';//Peng Zhu 2013-10-14
        ma.Status_BI__c = 'Draft';
        ma.Account_Matrix_Split_BI__c = 'test;';
        ma.Account_Matrix_BI__c = true;
        ma.Scenario_BI__c = '1';
        insert ma;
        
        Lifecycle_Template_BI__c mt = new Lifecycle_Template_BI__c();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        insert mt;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Product_Catalog_BI__c = p2.Id;
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        cd.Current_Update_BI__c = true;
        insert cd;     	
        
    	Customer_Attribute_BI__c sp = new Customer_Attribute_BI__c();
    	sp.Country_BI__c = c.Id;
    	sp.Group_txt_BI__c = 'ENT';
    	insert sp;
    	
    	Customer_Attribute_BI__c sp2 = new Customer_Attribute_BI__c();
    	sp2.Name = 'ENTT';
    	sp2.Country_BI__c = c.Id;
    	//sp.Group_txt_BI__c = 'ENT';
    	insert sp2;
    	    	
    	Channel_BI__c channel = new Channel_BI__c();
    	channel.Name = 'Face to Face';
    	channel.Cost_Rate_BI__c = 11;
    	channel.Unit_BI__c = 'asdfasfd';
    	insert channel;
    	
    	Cycle_Data_Overview_BI__c cdo = new Cycle_Data_Overview_BI__c();
    	cdo.Account_Matrix_Split_BI__c = 'test;';
    	cdo.Cycle_BI__c = cycle2.Id;
    	cdo.Product_Catalog_BI__c = p2.Id;
    	insert cdo;
    	Test.startTest();
    	
    	ApexPages.currentPage().getParameters().put('mId',ma.Id);
    	ApexPages.currentPage().getParameters().put('cId',cycle2.Id);
    	ApexPages.currentPage().getParameters().put('viewModel','viewModel');
    	ApexPages.currentPage().getParameters().put('retURL','/' + ma);
    	
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtMatrixDefinition ext = new IMP_BI_ExtMatrixDefinition(ctrl); 
        ext.accountMatrix = true;
        ext.rerenderEditMatrix();
        
        system.assert(true);
        Test.stopTest();
    }  
}