/**
*   Test class for class IMP_BI_ExtMatrix.
*
@author Di Chen
@created 2013-05-28
@version 1.0
@since 20.0
*
@changelog
* 2013-05-28 Di Chen <di.chen@itbconsult.com>
* - Created
*- Test coverage 80%
*/
@isTest
private class IMP_BI_ExtMatrix_Test {
	static testMethod void testFalse() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        insert acc;

        Cycle_BI__c cycle = IMP_BI_ClsTestHelp.createTestCycle();
        insert cycle;
        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        P2.Country_BI__c = c.Id;
        insert p2;
        
        Lifecycle_Template_BI__c mt = IMP_BI_ClsTestHelp.createTestLifecycleTemplateBI();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        mt.isLaunch_Phase_BI__c = true;
        mt.Column_BI__c = 6;
        insert mt;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Row_BI__c = 10;
        ma.Column_BI__c = 11;
        ma.Specialization_BI__c = 'GP';//Peng Zhu 2013-10-14
        ma.Lifecycle_Template_BI__c = mt.Id;
        insert ma;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        cycle2.Country_Lkp_BI__c = c.Id;
        insert cycle2;
        
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Product_Catalog_BI__c = p2.Id;
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        cd.Current_Update_BI__c = true;
        insert cd;     	
    	
    	Channel_BI__c channel = new Channel_BI__c();
    	channel.Name = 'Face to Face';
    	channel.Cost_Rate_BI__c = 11;
    	channel.Unit_BI__c = 'asdfasfd';
    	insert channel;
    	
    	map<Id, Channel_BI__c> map_id_channel = new map<Id, Channel_BI__c>();
    	map_id_channel.put(ma.Id,channel);
    	
    	Test.startTest();
    	
    	IMP_BI_ExtMatrix.MatrixCellChannel extMat = new IMP_BI_ExtMatrix.MatrixCellChannel(channel.Id);
    	extMat.channelBudget = channel.Id;
    	
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtMatrix ext = new IMP_BI_ExtMatrix(ctrl); 
        
        ext.matrix = ma;
        
        ext.getRows();
        ext.getColumns();
        ext.getChannels();
        ext.getChannelsDetails();
        ext.saveMatrix();
        ext.parserJSON();
        ext.saveChannelBudget();
        ext.getLt();
        ext.getGt();
        ext.getSelectedChannelId();
        ext.filterChannelForF2F(map_id_channel);
        
        system.assert(true);
        Test.stopTest();
    }
	static testMethod void testFalse2() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        insert acc;

        Cycle_BI__c cycle = IMP_BI_ClsTestHelp.createTestCycle();
        insert cycle;
        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        P2.Country_BI__c = c.Id;
        insert p2;
        
        Lifecycle_Template_BI__c mt = IMP_BI_ClsTestHelp.createTestLifecycleTemplateBI();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        mt.isLaunch_Phase_BI__c = true;
        mt.Adoption_Status_01_BI__c = '1';
        mt.Adoption_Status_02_BI__c = '1';
        mt.Adoption_Status_03_BI__c = '1';
        mt.Adoption_Status_04_BI__c = '1';
        mt.Adoption_Status_05_BI__c = '1';
        mt.Column_BI__c = 6;
        insert mt;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Row_BI__c = 10;
        ma.Column_BI__c = 11;
        ma.Specialization_BI__c = 'GP';//Peng Zhu 2013-10-14
        ma.Lifecycle_Template_BI__c = mt.Id;
        insert ma;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        cycle2.Country_Lkp_BI__c = c.Id;
        insert cycle2;
        
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Product_Catalog_BI__c = p2.Id;
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        cd.Current_Update_BI__c = true;
        insert cd;     	
    	
    	Channel_BI__c channel = new Channel_BI__c();
    	channel.Name = 'Face to Face';
    	channel.Cost_Rate_BI__c = 11;
    	channel.Unit_BI__c = 'asdfasfd';
    	insert channel;
    	
    	map<Id, Channel_BI__c> map_id_channel = new map<Id, Channel_BI__c>();
    	map_id_channel.put(ma.Id,channel);
    	
    	Test.startTest();
    	
    	IMP_BI_ExtMatrix.MatrixCellChannel extMat = new IMP_BI_ExtMatrix.MatrixCellChannel(channel.Id);
    	extMat.channelBudget = channel.Id;
    	
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtMatrix ext = new IMP_BI_ExtMatrix(ctrl); 
        
        ext.matrix = ma;
        
        ext.getRows();
        ext.getColumns();
        ext.getChannels();
        ext.getChannelsDetails();
        ext.saveMatrix();
        ext.parserJSON();
        ext.saveChannelBudget();
        ext.getLt();
        ext.getGt();
        ext.getSelectedChannelId();
        ext.filterChannelForF2F(map_id_channel);
        
        system.assert(true);
        Test.stopTest();
    }    
    static testMethod void testTrue() {
    	
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';
        insert acc;

        Cycle_BI__c cycle = IMP_BI_ClsTestHelp.createTestCycle();
        insert cycle;
        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = null;
        ma.Potential_Levels_BI__c = null;
        ma.Size_BI__c = '10x11';
        ma.Row_BI__c = 10;
        ma.Column_BI__c = 11;
        ma.Specialization_BI__c = 'GP';//Peng Zhu 2013-10-14
        insert ma;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        cycle2.Country_Lkp_BI__c = c.Id;
        insert cycle2;
        
        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Product_Catalog_BI__c = p2.Id;
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        cd.Current_Update_BI__c = true;
        insert cd;     	
    	
    	Channel_BI__c channel = new Channel_BI__c();
    	channel.Name = 'Face to Face';
    	channel.Cost_Rate_BI__c = 11;
    	channel.Unit_BI__c = 'asdfasfd';
    	insert channel;
    	
    	map<Id, Channel_BI__c> map_id_channel = new map<Id, Channel_BI__c>();
    	map_id_channel.put(ma.Id,channel);
    	
    	Test.startTest();
    	
    	ApexPages.currentPage().getParameters().put('F2F','true');
    	
    	list<IMP_BI_ExtMatrix.channelTotalInfo> list_channelDetails = new list<IMP_BI_ExtMatrix.channelTotalInfo>();
    	IMP_BI_ExtMatrix.channelTotalInfo extC = new IMP_BI_ExtMatrix.channelTotalInfo(channel.Id);
    	extC.channelId = channel.Id;
    	extC.channelName = 'adfas';
    	extC.availableUnits = 21;
    	extC.allocatedUnits = 12;
    	extC.remaining = 12;
    	extC.gain = 12;
    	extC.build = 12;
    	extC.defend = 12;
    	extC.observe = 12;
    	extC.maintain = 12;
    	extC.planned = 12;
    	list_channelDetails.add(extC);
    	
    	IMP_BI_ExtMatrix.MatrixCellChannel extMat = new IMP_BI_ExtMatrix.MatrixCellChannel(channel.Id);
    	extMat.channelBudget = channel.Id;
    	
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtMatrix ext = new IMP_BI_ExtMatrix(ctrl); 
        
        ext.list_channelDetails = list_channelDetails;
        ext.totalChannelInfo = extC;
        ext.matrix = ma;
        
        ext.getRows();
        ext.getColumns();
        ext.getChannels();
        ext.getChannelsDetails();
        ext.saveMatrix();
        ext.parserJSON();
        ext.saveChannelBudget();
        ext.getLt();
        ext.getGt();
        ext.getSelectedChannelId();
        ext.filterChannelForF2F(map_id_channel);
        
        system.assert(true);
        Test.stopTest();
    } 
}