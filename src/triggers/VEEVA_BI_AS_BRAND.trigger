trigger VEEVA_BI_AS_BRAND on Account_Tactic_vod__c (before insert, before update) {
	
	Set<Id> strats = new Set<Id>();
    for (Account_Tactic_vod__c acct : Trigger.new) 
        strats.add(acct.Product_Strategy_vod__c);
	
	Map<Id, Product_Strategy_vod__c> brands = new Map<Id, Product_Strategy_vod__c>(
        [select Product_Plan_vod__r.Product_vod__c 
         from Product_Strategy_vod__c 
         where id in :strats]);

	for (Account_Tactic_vod__c bas : Trigger.new){
		if(bas.Product_Strategy_vod__c != null && brands!=null){
			Id brand = brands.get(bas.Product_Strategy_vod__c).Product_Plan_vod__r.Product_vod__c;
			
			if(brand!=null){
				bas.Brand_BI__c = brand ;
			}		
		}
	}
}