/**
 *	Contains a set of static methods used in synchronization between Visits__c and Event
 *
 @author 	Yuanyuan Zhang
 @created 	2013-05-29
 @version 	1.0
 @since 	26.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-05-29 Yuanyuan Zhang <yuanyuan.zhang@itbconsult.com>
 * - Created
 */

public class IMP_BI_CtrlCalculateCycleDataOverview {
	
	public IMP_BI_CtrlCalculateCycleDataOverview(){
		
	}
	
	public pageReference runBatch(){
		map<String,String> mapURLParam = apexPages.currentPage().getParameters();
        String cycid = mapURLParam.get('cycid');
		IMP_BI_ClsBatch_calculateDataCycleView batchApex = new IMP_BI_ClsBatch_calculateDataCycleView(cycid);
		batchApex.filter = ' where Cycle_BI__c = \'' + cycid + '\'';
		if(!test.isRunningTest()){
        	ID batchprocessid = Database.executeBatch(batchApex);
		}
        
        pageReference pr;
        if(mapURLParam.containsKey('retUrl')){
        	pr = new pageReference(mapURLParam.get('retUrl'));
        }
        else pr = new pageReference('/' + cycid);
        pr.setRedirect(true);
        return pr;
	}
}