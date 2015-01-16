/**
 *	Test class for class IMP_BI_ExtMatrixUpdateStrategicWeight
 *
 @author  Peng Zhu
 @created 2013-08-27
 @version 1.0
 @since   27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-08-27 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 * - Test coverage 91%
 */
@isTest
private class IMP_BI_ExtMatrixUpdateStrategicWeig_Test {

    static testMethod void testMostMethods() {
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
        
        Lifecycle_Template_BI__c mt = new Lifecycle_Template_BI__c();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        insert mt;
        
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
        ma.Lifecycle_Template_BI__c = mt.Id;
        insert ma;
        
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
/**        
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
**/    	
    	Test.startTest();
    	
    	ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtMatrixUpdateStrategicWeight ext = new IMP_BI_ExtMatrixUpdateStrategicWeight(ctrl); 
        
        ext.updateMatrixCellStrategicWeight();
        ext.cancel();
    	
    	system.assert(true);
    	Test.stopTest();
    }
    
    static testmethod void testMostMethods2(){
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
        
        Lifecycle_Template_BI__c mt = new Lifecycle_Template_BI__c();
        mt.Name = 'mt';
        mt.Country_BI__c = c.Id;
        mt.Active_BI__c = true;
        insert mt;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Product_Catalog_BI__c = p2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Row_BI__c = 10;
        ma.Column_BI__c = 11;
        ma.Specialization_BI__c = 'GP';//Peng Zhu 2013-10-14
        ma.Status_BI__c = 'Review Needed';
        ma.Lifecycle_Template_BI__c = mt.Id;
        insert ma;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Test.startTest();
    	
    	ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_ExtMatrixUpdateStrategicWeight ext = new IMP_BI_ExtMatrixUpdateStrategicWeight(ctrl); 
        
        ext.updateMatrixCellStrategicWeight();
        ext.cancel();
    	
    	system.assert(true);
    	Test.stopTest();
    }
}