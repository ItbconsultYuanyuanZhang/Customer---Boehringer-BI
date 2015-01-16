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
private class IMP_BI_BudgetAllocationDefintion_Test {

    static testMethod void testManageBudgetAllocation() {
        //Load data
        Country_BI__c c = IMP_BI_ClsTestHelp.createTestCountryBI();
    	c.Country_Code_BI__c = 'Z0';
    	insert c;
    	
    	Product_vod__c p = IMP_BI_ClsTestHelp.createTestProduct();
        p.Country_BI__c = c.Id;
        insert p;
        
        Channel_BI__c channel = new Channel_BI__c(Name = 'Face-To_Face_Test');
        insert channel;
        
    	Cycle_BI__c cycle = IMP_BI_ClsTestHelp.createTestCycle();
    	cycle.Country_Lkp_BI__c = c.Id;
    	insert cycle;
		
		Test.startTest();

		ApexPages.currentPage().getParameters().put('cId',cycle.Id);    	
    	Apexpages.Standardcontroller ctr = new Apexpages.Standardcontroller(new Budget_Allocation_BI__c());
    	IMP_BI_BudgetAllocationDefintion ctrBudget = new IMP_BI_BudgetAllocationDefintion(ctr);
    	
    	//Save Budget Allocation
    	String budgetJSON = '{"cycle":"'+cycle.Id+'","product":"'+p.Id+'","channel":"'+channel.Id+'","budget":"1000"}';
    	IMP_BI_BudgetAllocationDefintion.saveBudget(budgetJSON);
    	
    	ctrBudget.cancel();
    	
    	Budget_Allocation_BI__c ba = new Budget_Allocation_BI__c(Cycle_BI__c = cycle.Id, Budget_BI__c = 1000, Channel_BI__c = channel.Id, Product_Catalog_BI__c = p.Id);
    	insert ba;
    	
    	//Load Budget Allocation
    	new IMP_BI_BudgetAllocationDefintion(new Apexpages.Standardcontroller(ba));

    	Test.stopTest();
    }
}