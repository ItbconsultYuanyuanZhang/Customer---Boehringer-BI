/**
 *  This scheduler class is used to clean the Target Account/Detail/Portfolio FieldForce Simulation which identifies if the version is not identical with the one on Portfolio.
 *
 @author Lili Zhao
 @created 2013-06-04  
 @version 1.0
 @since 27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-06-04 Lili Zhao <lili.zhao@itbconsult.com>
 * - Created
 */
global with sharing class IMP_BI_ClsScheduler_ClearFldFcSimulation implements Schedulable{
	global void execute(SchedulableContext sc) {
		IMP_BI_ClsBatch_FieldForceSimulation batchPortfolioFieldForceSimulation = new IMP_BI_ClsBatch_FieldForceSimulation();		
		database.executebatch(batchPortfolioFieldForceSimulation);
	}
}