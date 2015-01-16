/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Test for IMP_BI_Datadeletion(All) class
*  @author:         Jefferson Escobar
*  @created:        11-Aug-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			30.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         11-Aug-2014                 jescobar                 	Construction of the class.
*/
@isTest
private class IMP_BI_DataDeletion_Test {

    static testMethod void tstDataDeletion() {
        Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc;
        
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Cycle_BI__c cycle2 = new Cycle_BI__c();
        cycle2.Country_BI__c = 'USA';
        cycle2.Start_Date_BI__c = date.today() - 10;
        cycle2.End_Date_BI__c = date.today() + 10;
        cycle2.IsCurrent_BI__c = false;
        cycle2.Country_Lkp_BI__c = c.Id;
        insert cycle2;
    	        
        Product_vod__c p2 = IMP_BI_ClsTestHelp.createTestProduct();
        p2.Country_BI__c = c.Id;
        insert p2;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle2.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Specialization_BI__c = 'Cardiologist;GP';
        ma.Status_BI__c = 'Draft';
        ma.Product_Catalog_BI__c = p2.Id;
        insert ma;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;

        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle2.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        insert cd; 
        
        Cycle_Data_Overview_BI__c productLoad = new Cycle_Data_Overview_BI__c(	Product_Catalog_BI__c = p2.Id, Cycle_BI__c = cycle2.Id);
        insert productLoad;
       
        
        //Start test process
        Test.startTest();
    	ApexPages.currentPage().getParameters().put('id',cycle2.Id);
    	
        IMP_BI_DataDeletion dataDeletion = new IMP_BI_DataDeletion(new ApexPages.StandardController(cycle2));
        
        dataDeletion.products2Del = ''+p2.Id;
        
        //Run deletion Process
        dataDeletion.runDeletionProcess();
        
        //Run batch process under test action
        dataDeletion.runDeletionBatch(cycle2.Id, new List<String>{''+p2.Id});
        dataDeletion.syncProgressBar();
        
        IMP_BI_ClsBatch_ClearCycleData batchClearCD = new IMP_BI_ClsBatch_ClearCycleData(cycle2.Id, new List<String>{''+p2.Id});
        Database.BatchableContext bc;
        batchClearCD.start(bc);
        batchClearCD.execute(bc, new List<Cycle_Data_BI__c>{cd});
        batchClearCD.finish(bc);
        
        // Invoke cancel action
        dataDeletion.cancel();
        //Return back 
        dataDeletion.calculateCycleData();
        Test.stopTest();
         
    }
}