/**
 *  This batch class is used to calculate cycle data overview by using related cycle data
 *
 @author Yuanyuan Zhang
 @created 2013-05-29
 @version 1.0
 @since 27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2014-04-11 Jefferson Escobar <jescobar@omegacrmconsulting.com>
 * - Modified
 */

global class IMP_BI_ClsBatch_calculateDataCycleView implements Database.Batchable<SObject>, Database.Stateful{

    global String query;
    global String filter;  
    
    global map<Id,map<Id, Integer>> map_cycleId_mapProductId_cdCount = new map<Id,map<Id, Integer>>();
    global map<Id,map<Id, Decimal>> map_cycleId_mapProductId_Potential = new map<Id,map<Id, Decimal>>();
    global map<Id,map<Id, Decimal>> map_cycleId_mapProductId_Adoption = new map<Id,map<Id, Decimal>>();
    global map<Id,map<Id, String>> map_cycleId_mapProductId_AMS = new map<Id,map<Id, String>>(); //added by leijun 2015-01-07 
    
    public IMP_BI_ClsBatch_calculateDataCycleView(String cycId) {       
        list<Cycle_Data_Overview_BI__c> list_cdo = new list<Cycle_Data_Overview_BI__c>();
        for(Cycle_Data_Overview_BI__c cdo : [SELECT Id,Cycle_BI__c FROM Cycle_Data_Overview_BI__c WHERE Cycle_BI__c = :cycId]){
            list_cdo.add(cdo);
        }
        if(list_cdo.size() != 0){
            delete list_cdo;
        }
    }   

    global Database.QueryLocator start(Database.BatchableContext BC){ 
        
        if(query == null || query == '') {
            query = 'SELECT Cycle_BI__c, Product_Catalog_BI__c,Potential_BI__c,Intimacy_BI__c,Account_Matrix_Split_BI__c FROM Cycle_Data_BI__c ';
            if(filter != null) query += filter;
        }  
        return Database.getQueryLocator(query);  
            
    }

    global void execute(Database.BatchableContext BC, list<Cycle_Data_BI__c> list_cycleData){
    	
        for(Cycle_Data_BI__c cd : list_cycleData) {
            
            //Initialize the list objects
            map<Id,Integer> map_prodId_count = new map<Id,Integer>();
            map<Id,Decimal> map_prodId_Potential = new map<Id,Decimal>();
            map<Id,Decimal> map_prodId_Adoption = new map<Id,Decimal>();
            map<Id,String> map_prodId_AMS = new map<Id,String>(); //added by leijun 2015-01-07 
            
            //Get total units of each product 
            if(map_cycleId_mapProductId_cdCount.containsKey(cd.Cycle_BI__c)){
                map_prodId_count = map_cycleId_mapProductId_cdCount.get(cd.Cycle_BI__c);
            }
            
            //Get total potential of each product 
            if(map_cycleId_mapProductId_Potential.containsKey(cd.Cycle_BI__c)){
                map_prodId_Potential = map_cycleId_mapProductId_Potential.get(cd.Cycle_BI__c);
            }
            
            //Get total adoption of each product 
            if(map_cycleId_mapProductId_Adoption.containsKey(cd.Cycle_BI__c)){
                map_prodId_Adoption = map_cycleId_mapProductId_Adoption.get(cd.Cycle_BI__c);
            }
            
            //added by leijun 2015-01-07 
            //Get total Account Matrix Split of each product 
            if(map_cycleId_mapProductId_AMS.containsKey(cd.Cycle_BI__c)){
                map_prodId_AMS = map_cycleId_mapProductId_AMS.get(cd.Cycle_BI__c);
            }
            
            //Get  Account Matrix Split of products
            String accountMatrixSplit  = '';
            if(map_prodId_AMS.containsKey(cd.Product_Catalog_BI__c)){
                accountMatrixSplit = map_prodId_AMS.get(cd.Product_Catalog_BI__c);
            }
            set<String> set_ams = new set<String>();
            for(String str : accountMatrixSplit.split(';')){
            		set_ams.add(str);
            }
            
            if(!set_ams.contains(cd.Account_Matrix_Split_BI__c)) {
				accountMatrixSplit+=(cd.Account_Matrix_Split_BI__c!=null) ? cd.Account_Matrix_Split_BI__c+';' : '';
				map_prodId_AMS.put(cd.Product_Catalog_BI__c, accountMatrixSplit);
				map_cycleId_mapProductId_AMS.put(cd.Cycle_BI__c,map_prodId_AMS);
            }
            
            //Get quantity of products
            Integer countProd = 0;
            if(map_prodId_count.containsKey(cd.Product_Catalog_BI__c)){
                countProd = map_prodId_count.get(cd.Product_Catalog_BI__c);
            }
            
            //Get value of potential
            Decimal potential = 0;
            if(map_prodId_Potential.containsKey(cd.Product_Catalog_BI__c)){
                potential = map_prodId_Potential.get(cd.Product_Catalog_BI__c);
            }
            
            //Get quantity of products
            Decimal adoption = 0;
            if(map_prodId_Adoption.containsKey(cd.Product_Catalog_BI__c)){
                adoption = map_prodId_Adoption.get(cd.Product_Catalog_BI__c);
            }
            
            //Get values
            countProd++;
            potential+=(cd.Potential_BI__c!=null) ? cd.Potential_BI__c : 0;
            adoption+=(cd.Intimacy_BI__c!=null) ? cd.Intimacy_BI__c : 0;
            
            //Put summary values for each product
            map_prodId_count.put(cd.Product_Catalog_BI__c, countProd);
            map_cycleId_mapProductId_cdCount.put(cd.Cycle_BI__c,map_prodId_count);
            
            map_prodId_Potential.put(cd.Product_Catalog_BI__c, potential);
            map_cycleId_mapProductId_Potential.put(cd.Cycle_BI__c,map_prodId_Potential);
            
            map_prodId_Adoption.put(cd.Product_Catalog_BI__c, adoption);
            map_cycleId_mapProductId_Adoption.put(cd.Cycle_BI__c,map_prodId_Adoption);
            
        }          
    }

    global void finish(Database.BatchableContext BC){
        list<Cycle_Data_Overview_BI__c> list_cdo2insert = new list<Cycle_Data_Overview_BI__c>();
        set<Id> set_cycleId = new set<Id>();
        for(Id cycId : map_cycleId_mapProductId_cdCount.keySet()){
            map<Id,Integer> map_prodId_count = map_cycleId_mapProductId_cdCount.get(cycId);
            map<Id,Decimal> map_prodId_Potential = map_cycleId_mapProductId_Potential.get(cycId);
            map<Id,Decimal> map_prodId_Adoption = map_cycleId_mapProductId_Adoption.get(cycId);
            map<Id,String> map_prodId_AMS = map_cycleId_mapProductId_AMS.get(cycId);//added by leijun 2015-01-07 
            
            for(Id prodId : map_prodId_count.keySet()){
                Cycle_Data_Overview_BI__c cdo = new Cycle_Data_Overview_BI__c();
                cdo.Cycle_BI__c = cycId;
                cdo.Product_Catalog_BI__c = prodId;
                cdo.Count_BI__c = map_prodId_count.get(prodId);
                //Get potential and adoption values
                cdo.Total_Potential_BI__c = map_prodId_Potential.get(prodId);
                cdo.Total_Adoption_BI__c = map_prodId_Adoption.get(prodId);
                cdo.Account_Matrix_Split_BI__c = map_prodId_AMS.get(prodId);//added by leijun 2015-01-07 
                
                list_cdo2insert.add(cdo);
            }
            set_cycleId.add(cycId);
        }
        list<Cycle_Data_Overview_BI__c> list_cdo2del = new list<Cycle_Data_Overview_BI__c>();
        for(Cycle_Data_Overview_BI__c cdo : [SELECT Id,Cycle_BI__c FROM Cycle_Data_Overview_BI__c WHERE Cycle_BI__c IN: set_cycleId]){
            list_cdo2del.add(cdo);
        }
        if(list_cdo2del.size() != 0){
            delete list_cdo2del;
        }
        
        
        if(list_cdo2insert.size() != 0){
            insert list_cdo2insert;
        }
    }

}