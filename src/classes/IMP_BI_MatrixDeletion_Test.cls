/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Test for IMP_BI_MatrixDeletion class
*  @author:         Jefferson Escobar
*  @created:        02-Apr-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			29.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         02-Apr-2014                 jescobar                 	Construction of the class.
*/ 
@isTest
private class IMP_BI_MatrixDeletion_Test {
	
    static testMethod void testDeleteMatrixInfo() {
    	
    	Account acc = IMP_BI_ClsTestHelp.createTestAccount();
        acc.Name = '123e';    
        insert acc;
        
    	Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	insert c;
    	
        Cycle_BI__c cycle = new Cycle_BI__c();
        cycle.Country_BI__c = 'USA';
        cycle.Start_Date_BI__c = date.today() - 10;
        cycle.End_Date_BI__c = date.today() + 10;
        cycle.IsCurrent_BI__c = false;
        cycle.Country_Lkp_BI__c = c.Id;
        insert cycle;
        
        Matrix_BI__c ma = IMP_BI_ClsTestHelp.createTestMatrix();
        ma.Cycle_BI__c = cycle.Id;
        ma.Intimacy_Levels_BI__c = 11;
        ma.Potential_Levels_BI__c = 10;
        ma.Size_BI__c = '10x11';
        ma.Specialization_BI__c = 'Cardiologist;GP';
        insert ma;
        
        Portfolio_BI__c portfolio = IMP_BI_ClsTestHelp.createTestPortfolio();
        insert portfolio;
        
        Portfolio_Field_Force_Simulation_BI__c pffs = IMP_BI_ClsTestHelp.createTestPortfolioFieldForceSimulationBI(); 
        pffs.Portfolio_BI__c = portfolio.Id;
        pffs.Product_Matrix_BI__c = ma.Id;
        insert pffs;
        
        Matrix_Cell_BI__c mc = IMP_BI_ClsTestHelp.createTestMatrixCell();
        mc.Matrix_BI__c = ma.Id;
        insert mc;
        
        Matrix_Cell_Detail_BI__c mcd = new Matrix_Cell_Detail_BI__c();
        mcd.Matrix_Cell_BI__c = mc.Id;
        insert mcd;

        Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
        cd.Account_BI__c = acc.Id;
        cd.Cycle_BI__c = cycle.Id;
        cd.Potential_BI__c = 12;
        cd.Intimacy_BI__c = 12;
        cd.Matrix_BI__c = ma.Id;
        insert cd;
        
        Strategic_Brand_Weight_BI__c matrixPortfolio = new Strategic_Brand_Weight_BI__c(Matrix_BI__c = ma.Id,Portfolio_BI__c=portfolio.Id);
		insert matrixPortfolio; 
    	  
    	Test.startTest();
    	
    	ApexPages.StandardController ctrl = new ApexPages.StandardController(ma); 
        IMP_BI_MatrixDeletion matrixDeletion = new IMP_BI_MatrixDeletion(ctrl); 

        IMP_BI_MatrixDeletion.clearCycData(ma.Id);
        IMP_BI_MatrixDeletion.clearPortfolioSimulation(ma.Id);
        IMP_BI_MatrixDeletion.clearMatrixDetail(ma.Id);
        IMP_BI_MatrixDeletion.clearMatrixCell(ma.Id);
        IMP_BI_MatrixDeletion.clearMatrixData(ma.Id);
		IMP_BI_MatrixDeletion.getTotalRecords(ma.Id);
		
			
		//Not load any matrix in the default constructor
		new IMP_BI_MatrixDeletion (new ApexPages.StandardController(new Matrix_BI__c()));
		
        Test.stopTest();
    }
}