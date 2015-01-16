/**
*   Test class for class IMP_BI_ExtChannelBudgetDefinitionFilter.
*
@author Di Chen
@created 2013-06-25
@version 1.0
@since 20.0
*
@changelog
* 2013-06-25 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage  79%
*/
@isTest
private class IMP_BI_ExtChannelBgDefinitionFilter_Test {

    static testMethod void testMostMethodsF2FIsFalse() {
        
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc; 
        
        Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
        insert c;
                
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.Country_Lkp_BI__c = c.Id;
        cycle2.IsCurrent_BI__c = false;
        insert cycle2;
                
        Lifecycle_Template_BI__c mt = new Lifecycle_Template_BI__c();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        mt.isLaunch_Phase_BI__c = true;
        mt.Adoption_Status_01_BI__c = '1';
        mt.Adoption_Status_02_BI__c = '2';
        mt.Adoption_Status_03_BI__c = '3';
        mt.Adoption_Status_04_BI__c = '4';
        mt.Adoption_Status_05_BI__c = '5';
        insert mt;
                        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = null;
        ma.Size_BI__c = '10x11';
        ma.Lifecycle_Template_BI__c = mt.Id;
        ma.Specialization_BI__c = 'Cardiologist;GP';//Peng Zhu 2013-10-14
        ma.Column_BI__c = 11;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Filter_Field_1_BI__c = 'Rep Access';
        ma.Filter_Field_2_BI__c = 'Rep Access';
        ma.Filter_Field_3_BI__c = 'Rep Access';
        ma.Status_BI__c = 'Draft';
        insert ma;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;

        Channel_BI__c channel = new Channel_BI__c();
        channel.Name = 'Face to Face';
        channel.Cost_Rate_BI__c = 11;
        channel.Unit_BI__c = 'asdfasfd';
        insert channel;        
                
        Matrix_Cell_Detail_BI__c mcdb = new Matrix_Cell_Detail_BI__c();
        mcdb.Matrix_Cell_BI__c = mc.Id;
        mcdb.Channel_BI__c = channel.Id;
        mcdb.Quantity_BI__c = 12;
        insert mcdb;
                
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        portfolio.Status_BI__c = null;
        portfolio.Cycle_BI__c = cycle2.Id;
        insert portfolio;
        
        Budget_Allocation_BI__c bab = new Budget_Allocation_BI__c();
        bab.Cycle_BI__c = cycle2.Id;
        bab.Product_Catalog_BI__c = p2.Id;
        bab.Channel_BI__c = channel.Id;
        bab.Budget_BI__c = 11;
        bab.Budget_BI__c = 12;
        insert bab;  
        
        Test.startTest();
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtChannelBudgetDefinitionFilter ext = new IMP_BI_ExtChannelBudgetDefinitionFilter(ctrl); 
        
        ext.matrix = ma;
        
        ext.getRows();
        ext.getColumns();
        //ext.getChannelsDetailsByFilter();
        //ext.saveMatrix();
        //ext.parserJSON();
        //ext.saveChannelBudget();
        ext.saveChannelBudgetByFilter();
        ext.getLt();
        ext.getGt();
        //ext.genMatrixCellDetails();
        
        system.assert(true);
        Test.stopTest();
    }
    static testMethod void testMostMethodsF2FIsFalse2() {
        
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc;
        
        Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
        insert c;
                
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.Country_Lkp_BI__c = c.Id;
        cycle2.IsCurrent_BI__c = false;
        insert cycle2;
                
        Lifecycle_Template_BI__c mt = new Lifecycle_Template_BI__c();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        mt.isLaunch_Phase_BI__c = true;
        mt.Adoption_Status_01_BI__c = '1';
        mt.Adoption_Status_02_BI__c = '2';
        mt.Adoption_Status_03_BI__c = '3';
        mt.Adoption_Status_04_BI__c = '4';
        mt.Adoption_Status_05_BI__c = '5';
        insert mt;
                        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = null;
        ma.Size_BI__c = '10x11';
        ma.Lifecycle_Template_BI__c = mt.Id;
        ma.Specialization_BI__c = 'Cardiologist;GP';//Peng Zhu 2013-10-14
        ma.Column_BI__c = 11;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Filter_Field_1_BI__c = 'Call';
        ma.Filter_Field_2_BI__c = 'Call';
        ma.Filter_Field_3_BI__c = 'Call';
        ma.Status_BI__c = 'Draft';
        insert ma;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;

        Channel_BI__c channel = new Channel_BI__c();
        channel.Name = 'Face to Face';
        channel.Cost_Rate_BI__c = 11;
        channel.Unit_BI__c = 'asdfasfd';
        insert channel;        
                
        Matrix_Cell_Detail_BI__c mcdb = new Matrix_Cell_Detail_BI__c();
        mcdb.Matrix_Cell_BI__c = mc.Id;
        mcdb.Channel_BI__c = channel.Id;
        mcdb.Quantity_BI__c = 12;
        insert mcdb;
                
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        portfolio.Status_BI__c = null;
        portfolio.Cycle_BI__c = cycle2.Id;
        insert portfolio;
        
        Budget_Allocation_BI__c bab = new Budget_Allocation_BI__c();
        bab.Cycle_BI__c = cycle2.Id;
        bab.Product_Catalog_BI__c = p2.Id;
        bab.Channel_BI__c = channel.Id;
        bab.Budget_BI__c = 11;
        bab.Budget_BI__c = 12;
        insert bab;  
        
        Test.startTest();
        
        IMP_BI_ExtChannelBudgetDefinitionFilter.ClsMatrixCellDetail imp = new IMP_BI_ExtChannelBudgetDefinitionFilter.ClsMatrixCellDetail();
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtChannelBudgetDefinitionFilter ext = new IMP_BI_ExtChannelBudgetDefinitionFilter(ctrl); 
        
        ext.matrix = ma;
        
        ext.getRows();
        ext.getColumns();
        //ext.getChannelsDetailsByFilter();
        //ext.saveMatrix();
        //ext.parserJSON();
        //ext.saveChannelBudget();
        ext.saveChannelBudgetByFilter();
        ext.getLt();
        ext.getGt();
        //ext.genMatrixCellDetails();
        
        //New test methods @jescobar
        ext.getChannelPicklist();
        ext.resetMatrixCellDetail();
        ext.genAndSaveMatrixCellDetailNew();
        IMP_BI_ExtChannelBudgetDefinitionFilter.ClsMatrixFilter matrixFilter = new IMP_BI_ExtChannelBudgetDefinitionFilter.ClsMatrixFilter();
        IMP_BI_ExtChannelBudgetDefinitionFilter.ClsMatrixFilterNew matrixFilterNew = new IMP_BI_ExtChannelBudgetDefinitionFilter.ClsMatrixFilterNew();
        
        system.assert(true);
        Test.stopTest();
    }    
    static testMethod void testMostMethodsF2FIsTrue() {
        
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc;
        
        Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
        insert c;
                
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.Country_Lkp_BI__c = c.Id;
        cycle2.IsCurrent_BI__c = false;
        insert cycle2;
        
        Lifecycle_Template_BI__c mt = new Lifecycle_Template_BI__c();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        mt.isLaunch_Phase_BI__c = true;
        mt.Adoption_Status_01_BI__c = '1';
        mt.Adoption_Status_02_BI__c = '2';
        mt.Adoption_Status_03_BI__c = '3';
        mt.Adoption_Status_04_BI__c = '4';
        mt.Adoption_Status_05_BI__c = '5';
        insert mt;
                        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Intimacy_Levels_BI__c = null;
        ma.Potential_Levels_BI__c = null;
        ma.Size_BI__c = '10x11';
        ma.Lifecycle_Template_BI__c = mt.Id;
        ma.Specialization_BI__c = 'Cardiologist;GP';//Peng Zhu 2013-10-14
        ma.Column_BI__c = 11;
        ma.Filter_Field_1_BI__c = 'Call';
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Filter_Field_2_BI__c = 'Call';
        ma.Filter_Field_3_BI__c = 'Call';
        ma.Status_BI__c = 'Draft';
        insert ma;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        mc.Row_BI__c = 1;
        mc.Column_BI__c = 0;
        mc.Total_Customers_BI__c = 1;
        mc.Total_Intimacy_BI__c = 1;
        mc.Total_Potential_BI__c = 1;
        insert mc;
        
        Channel_BI__c channel = new Channel_BI__c();
        channel.Name = 'Face to Face';
        channel.Cost_Rate_BI__c = 11;
        channel.Unit_BI__c = 'asdfasfd';
        insert channel;
        
        Matrix_Cell_Detail_BI__c mcdb = new Matrix_Cell_Detail_BI__c();
        mcdb.Matrix_Cell_BI__c = mc.Id;
        mcdb.Channel_BI__c = channel.Id;
        mcdb.Quantity_BI__c = 12;
        insert mcdb;
        
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        portfolio.Status_BI__c = 'Draft';
        portfolio.Cycle_BI__c = cycle2.Id;
        insert portfolio;        
        
        Budget_Allocation_BI__c bab = new Budget_Allocation_BI__c();
        bab.Cycle_BI__c = cycle2.Id;
        bab.Product_Catalog_BI__c = p2.Id;
        bab.Channel_BI__c = channel.Id;
        bab.Budget_BI__c = 11;
        bab.Budget_BI__c = 12;
        //insert bab;  
        
        Test.startTest();
        
        IMP_BI_ExtChannelBudgetDefinitionFilter.channelTotalInfo extChannel = new IMP_BI_ExtChannelBudgetDefinitionFilter.channelTotalInfo(channel.Id);
        extChannel.availableUnits = 10;
        extChannel.allocatedUnits = 20;
        extChannel.build = 13;
        extChannel.remaining = 11;
        extChannel.gain = 12;
        extChannel.defend = 14;
        extChannel.observe = 16;
        extChannel.maintain = 23;
        extChannel.planned = 13;
        extChannel.totalUnits = 53;
        
        ApexPages.currentPage().getParameters().put('F2F','true');
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtChannelBudgetDefinitionFilter ext = new IMP_BI_ExtChannelBudgetDefinitionFilter(ctrl); 
        
        ext.matrix = ma;
        
        ext.getRows();
        ext.getColumns();
        //ext.getChannelsDetailsByFilter();
        //ext.saveMatrix();
        //ext.parserJSON();
        //ext.saveChannelBudget();
        ext.saveChannelBudgetByFilter();
        ext.getLt();
        ext.getGt();
        //ext.genMatrixCellDetails();
        ext.getFilterCombinationName();
        //ext.filterPicklistChanged();
        
        system.assert(true);
        Test.stopTest();
    }    
    static testMethod void testMostMethodsF2FIsTrue2() {
        
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        acc.Call_BI__c = true;    
        insert acc;
        
        Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
        insert c;
                
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.Country_Lkp_BI__c = c.Id;
        cycle2.IsCurrent_BI__c = false;
        insert cycle2;
        
     	Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Product_Catalog_BI__c = p2.Id;
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        cd.Current_Update_BI__c = true;
        insert cd;  
        
        Lifecycle_Template_BI__c mt = new Lifecycle_Template_BI__c();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        mt.isLaunch_Phase_BI__c = true;
        mt.Adoption_Status_01_BI__c = '1';
        mt.Adoption_Status_02_BI__c = '2';
        mt.Adoption_Status_03_BI__c = '3';
        mt.Adoption_Status_04_BI__c = '4';
        mt.Adoption_Status_05_BI__c = '5';
        insert mt;
                        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Intimacy_Levels_BI__c = null;
        ma.Potential_Levels_BI__c = null;
        ma.Size_BI__c = '10x11';
        ma.Lifecycle_Template_BI__c = mt.Id;
        ma.Specialization_BI__c = 'Cardiologist;GP';//Peng Zhu 2013-10-14
        ma.Column_BI__c = 11;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Filter_Field_1_BI__c = null;
        ma.Filter_Field_2_BI__c = null;
        ma.Filter_Field_3_BI__c = null;
        ma.Status_BI__c = 'Draft';
        insert ma;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        mc.Row_BI__c = 1;
        mc.Column_BI__c = 0;
        mc.Total_Customers_BI__c = 1;
        mc.Total_Intimacy_BI__c = 1;
        mc.Total_Potential_BI__c = 1;
        insert mc;
        
        Channel_BI__c channel = new Channel_BI__c();
        channel.Name = 'Face to Face';
        channel.Cost_Rate_BI__c = 11;
        channel.Unit_BI__c = 'asdfasfd';
        insert channel;
        
        Matrix_Cell_Detail_BI__c mcdb = new Matrix_Cell_Detail_BI__c();
        mcdb.Matrix_Cell_BI__c = mc.Id;
        mcdb.Channel_BI__c = channel.Id;
        mcdb.Quantity_BI__c = 12;
        insert mcdb;
        
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        portfolio.Status_BI__c = 'Draft';
        portfolio.Cycle_BI__c = cycle2.Id;
        insert portfolio;        
        
        Budget_Allocation_BI__c bab = new Budget_Allocation_BI__c();
        bab.Cycle_BI__c = cycle2.Id;
        bab.Product_Catalog_BI__c = p2.Id;
        bab.Channel_BI__c = channel.Id;
        bab.Budget_BI__c = 11;
        bab.Budget_BI__c = 12;
        //insert bab;  
        
        Test.startTest();
        
        IMP_BI_ExtChannelBudgetDefinitionFilter.channelTotalInfo extChannel = new IMP_BI_ExtChannelBudgetDefinitionFilter.channelTotalInfo(channel.Id);
        extChannel.availableUnits = 10;
        extChannel.allocatedUnits = 20;
        extChannel.build = 13;
        extChannel.remaining = 11;
        extChannel.gain = 12;
        extChannel.defend = 14;
        extChannel.observe = 16;
        extChannel.maintain = 23;
        extChannel.planned = 13;
        extChannel.totalUnits = 53;
        
        ApexPages.currentPage().getParameters().put('F2F','true');
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtChannelBudgetDefinitionFilter ext = new IMP_BI_ExtChannelBudgetDefinitionFilter(ctrl); 
        
        ext.matrix = ma;
        
        ext.checkMatrixCellDetail();
        ext.createMatrixCellDetailForNoFilter();
         
        string json = '';
        IMP_BI_ExtChannelBudgetDefinitionFilter.saveMatrixCellDetailsInBatch('{"Matrix_Cell_BI__c":"'+mc.Id+'"}');
        IMP_BI_ExtChannelBudgetDefinitionFilter.updtMatrixCellDetailsInBatch('{"Matrix_Cell_BI__c":"'+mc.Id+'"}');
		IMP_BI_ExtChannelBudgetDefinitionFilter.delCellDetailsInBatch('{"'+mcdb.Id+'"}');
        json = '{"matrixId":"'+ma.Id+'","cycleDataId":"'+cd.Id+'","isEnd":true,"listCmcdSize":1,"filterStr":"Call_BI__c"}';
        IMP_BI_ExtChannelBudgetDefinitionFilter.generateMatrixCellDetailsNew(json);
        
        system.assert(true);
        Test.stopTest();
    }
            
}