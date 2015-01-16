/**
 *  Controller class used in ExtPortfolioParams VF pages
 *
 @author  Peng Zhu
 @created 2013-05-30
 @version 1.0
 @since   27.0 (Force.com ApiVersion)
 *
 @changelog
 * 2013-05-30 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
global with sharing class IMP_BI_ExtPortfolioParams {
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    public static final string KEYPREFIX_CYCLE = Schema.SObjectType.Cycle_BI__c.getKeyPrefix();
    public Cycle_BI__c cycle {get; private set;}
    public list<ClsMatrix> list_cm {get; set;}
    public list<Matrix_BI__c> list_matrix {get; set;}
    public list<Portfolio_BI__c> list_pf {get; set;}
    public Integer portfolioIndex {get; set;}
    
    public list<ClsPortfolio> list_cpf {get; set;}
    
    public String pageTitle {get; private set;}
    public String sectionHeaderTitle {get; private set;}
    public String sectionHeaderSubTitle {get; private set;}
    public String viewModel {get; private set;}
    public integer maxMatrixListSize{get;set;}//yy added
    public String calBaseUrl {get; set;}//added by Peng Zhu 2013-09-04
    public boolean isChecked { get; set; }
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    /**
     * map to store global describtion due to limit on describe methodes.
     */
    private map<String, String> map_urlParams;
    private Id cycleId;
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    /////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
   /**
    * The contsructor
    *
    @author  Peng Zhu
    @created 2013-05-30
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @changelog
    * 2013-05-30 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */
    public IMP_BI_ExtPortfolioParams(ApexPages.standardController stdCtrl) {
        pageTitle = system.Label.IMP_BI_PortfolioTitle;
        sectionHeaderTitle = system.Label.IMP_BI_PortfolioTitle;
        sectionHeaderSubTitle = system.Label.IMP_BI_PortfolioTitle;
        this.isChecked = true;
        //Begin: added by Peng Zhu 2013-09-04
        if(IMP_BI_Default_Setting__c.getInstance('Sandbox') != null && IMP_BI_Default_Setting__c.getInstance('Sandbox').Boolean_Value_BI__c == TRUE){
            
            if(IMP_BI_Default_Setting__c.getInstance('Sandbox Heroku Url') != null 
                && IMP_BI_Default_Setting__c.getInstance('Sandbox Heroku Url').Text_Value_BI__c != null
                && IMP_BI_Default_Setting__c.getInstance('Sandbox Heroku Url').Text_Value_BI__c.trim() != ''){
                
                calBaseUrl = IMP_BI_Default_Setting__c.getInstance('Sandbox Heroku Url').Text_Value_BI__c.trim() + 'ntlCalculation/';
            }
            else{
                calBaseUrl = 'https://boehringer-ingelheim-sandbox.herokuapp.com/itbconsult/queue/ntlCalculation/';
            }
        }
        else{
            if(IMP_BI_Default_Setting__c.getInstance('Production Heroku Url') != null 
                && IMP_BI_Default_Setting__c.getInstance('Production Heroku Url').Text_Value_BI__c != null
                && IMP_BI_Default_Setting__c.getInstance('Production Heroku Url').Text_Value_BI__c.trim() != ''){
                
                calBaseUrl = IMP_BI_Default_Setting__c.getInstance('Production Heroku Url').Text_Value_BI__c.trim() + 'ntlCalculation/';
            }
            else{
                calBaseUrl = 'https://boehringer-ingelheim.herokuapp.com/itbconsult/queue/ntlCalculation/';
            }
        }
        //End: added by Peng Zhu 2013-09-04
        
        
        portfolioIndex = 0;
        
        map_urlParams = ApexPages.currentPage().getParameters();
        
        //Id cycleId = stdCtrl.getId();
        //Id cycleId = 'a002000000REZO6';
        //Id cycleId = 'a39J00000004FC4';//'a002000000SNx7G';
        Id portFolioId;
        if(map_urlParams.containsKey('cycid')){
            cycleId = map_urlParams.get('cycid');
        }
        else{
            portFolioId = stdCtrl.getId();
            Portfolio_BI__c pfb = new Portfolio_BI__c();
            for(Portfolio_BI__c pf : [SELECT Cycle_BI__c FROM Portfolio_BI__c WHERE Id = :portFolioId limit 1]){
                pfb = pf;
            }
            if(pfb != null){
                cycleId = pfb.Cycle_BI__c;
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.IMP_BI_AssociateWithCycle));
                return;
            }
        }
        
        
        
        for(Cycle_BI__c c : [SELECT Id, Name, Country_Lkp_BI__c, Country_Lkp_BI__r.Name FROM Cycle_BI__c WHERE Id = :cycleId]){
            cycle = c;
        }
        if(cycle == null) cycle = new Cycle_BI__c();
        
        getMatrixAndPortfolio();
    }
    /////////////////////////////////// -=END CONSTRUCTOR=- ///////////////////////////////////////
    
    
    //********************************* -=BEGIN public methods=- **********************************
   public void refreshPage(){
       getMatrixAndPortfolio();
   }
   
   public void getMatrixAndPortfolio(){
       list_cm = new list<ClsMatrix>();
        
        list_matrix = new list<Matrix_BI__c>();
        
        map<id, ClsMatrix> map_id_cm = new map<id, ClsMatrix>();
        
        String queryString = 'SELECT Id, Current_BI__c ,Name, Name_BI__c, Cycle_BI__c,Weight_BI__c,Account_Matrix_BI__c, Scenario_BI__c FROM Matrix_BI__c WHERE Cycle_BI__c = :cycleId AND Status_BI__c = \'Ready for NTL\' ';
        
        queryString = this.isChecked ? queryString + ' AND Account_Matrix_BI__c = true ' : queryString + ' AND Account_Matrix_BI__c = false ';
        
        
        for(Matrix_BI__c m : database.query(queryString)){//2013-07-01 added by Yuanyuan Zhang only final matrices will be shown//2013-07-04 modified by yuanyuan zhang status is chenged to "Ready for NTL"
            list_matrix.add(m);
            ClsMatrix cm = new ClsMatrix();
            cm.cmId = m.Id;
            cm.cmName = m.Name_BI__c.length() > 10?m.Name_BI__c.subString(0,10):m.Name_BI__c;
            cm.cmTitle = m.Name_BI__c;
            cm.isAccountMatrix = m.Account_Matrix_BI__c;
            cm.scenario = m.Scenario_BI__c;
            cm.isCurrent = m.Current_BI__c;
            map_id_cm.put(m.Id, cm);
        }
        
        
        map<id, list<ClsMatrix>> map_pfId_cms = new map<id, list<ClsMatrix>>();
        //integer maxMatrixListSize = 0;
        maxMatrixListSize = 0;//yy modified
        //maxMatrixListSize = list_matrix.size();  //
        for(Strategic_Brand_Weight_BI__c sbw : [SELECT Id, Matrix_BI__c, Portfolio_BI__c,Portfolio_BI__r.Status_BI__c, Strategic_Weight_BI__c,First_detail_priority_BI__c, Full_Coverage_BI__c FROM Strategic_Brand_Weight_BI__c WHERE Matrix_BI__c IN :map_id_cm.keySet()]){
            /*if(sbw.Matrix_BI__c != null && map_id_cm.containsKey(sbw.Matrix_BI__c)){
                map_id_cm.get(sbw.Matrix_BI__c).isAssigned = true;
                map_id_cm.get(sbw.Matrix_BI__c).weight = sbw.Strategic_Weight_BI__c;//yy added
                
                if(sbw.Portfolio_BI__c != null && !map_pfId_cms.containsKey(sbw.Portfolio_BI__c)) map_pfId_cms.put(sbw.Portfolio_BI__c, new list<ClsMatrix>());
                
                map_pfId_cms.get(sbw.Portfolio_BI__c).add(map_id_cm.get(sbw.Matrix_BI__c));
                
                if(map_pfId_cms.get(sbw.Portfolio_BI__c).size() > maxMatrixListSize) maxMatrixListSize = map_pfId_cms.get(sbw.Portfolio_BI__c).size();
            }*/
            if(sbw.Matrix_BI__c != null){
                if(map_id_cm.containsKey(sbw.Matrix_BI__c)){
                    //if(sbw.Portfolio_BI__r.Status_BI__c == 'Draft' || sbw.Portfolio_BI__r.Status_BI__c == null ){//2013-07-04 commenet out by yuanyuan zhang show all portfolio independent of status
                        map_id_cm.get(sbw.Matrix_BI__c).isAssigned = true;
                        map_id_cm.get(sbw.Matrix_BI__c).weight = Integer.valueOf(sbw.Strategic_Weight_BI__c);//yy added First_detail_priority_BI__c
                        map_id_cm.get(sbw.Matrix_BI__c).priori = Integer.valueOf(sbw.First_detail_priority_BI__c);//2013-06-20 yy added for First_detail_priority_BI__c
                        map_id_cm.get(sbw.Matrix_BI__c).sbw = sbw;
                        
                        if(sbw.Portfolio_BI__c != null && !map_pfId_cms.containsKey(sbw.Portfolio_BI__c)) map_pfId_cms.put(sbw.Portfolio_BI__c, new list<ClsMatrix>());
                        
                        map_pfId_cms.get(sbw.Portfolio_BI__c).add(map_id_cm.get(sbw.Matrix_BI__c));
                        
                        if(map_pfId_cms.get(sbw.Portfolio_BI__c).size() > maxMatrixListSize) maxMatrixListSize = map_pfId_cms.get(sbw.Portfolio_BI__c).size();
                    //}
                    //else{
                    //    map_id_cm.remove(sbw.Matrix_BI__c);
                    //}
                }
            }
        }
        
        //if(maxMatrixListSize < 4) maxMatrixListSize = 4;
        maxMatrixListSize = list_matrix.size();
        
        if(!map_id_cm.isEmpty()) list_cm.addAll(map_id_cm.values());
        
        list_pf = new list<Portfolio_BI__c>();
        list_cpf = new list<ClsPortfolio>();
        String queryPort = 'SELECT Id, Name, Account_Matrices_BI__c, Number_of_FTEs_BI__c, Number_of_calls_per_day_BI__c, Number_of_days_in_the_field_BI__c, Numbers_of_details_per_call_BI__c FROM Portfolio_BI__c WHERE Cycle_BI__c = :cycleId ';
        queryPort = this.isChecked ? queryPort + ' AND Account_Matrices_BI__c = true ' : queryPort + ' AND Account_Matrices_BI__c = false ';
        for(Portfolio_BI__c p : database.query(queryPort)){//AND (Status_BI__c = 'Draft'
                                 //OR Status_BI__c = null)
            list_pf.add(p);
            
            ClsPortfolio cpf = new ClsPortfolio();
            cpf.pf = p;
            if(map_pfId_cms.containsKey(p.Id)){
                for(Integer i = map_pfId_cms.get(p.Id).size(); i < maxMatrixListSize; i++){//why all matrix list will have the max matrix list size?
                    ClsMatrix cm = new ClsMatrix();
                    cm.cmId = null;
                    cm.cmName = '';
                    
                    map_pfId_cms.get(p.Id).add(cm);
                }
                cpf.list_cm = map_pfId_cms.get(p.Id);
            }
            else{
                for(Integer i = 0; i < maxMatrixListSize; i++){
                    ClsMatrix cm = new ClsMatrix();
                    cm.cmId = null;
                    cm.cmName = '';
                    
                    cpf.list_cm.add(cm);
                }
            }
            list_cpf.add(cpf);
        }
        
        if(!list_pf.isEmpty()) portfolioIndex = list_pf.size();//what to do with that?
   }
   /**
    * This method is used to 
    *
    @author  Peng Zhu
    @created 2013-05-30
    @version 1.0
    @since   27.0 (Force.com ApiVersion)
    *
    @param year         year string
    @param ownerId      owner id string
    *
    @return             the visit capacity
    *
    @changelog
    * 2013-05-30 Peng Zhu <peng.zhu@itbconsult.com>
    * - Created
    */
    public String getCurrentTimeUserLocal(){
        return '';
    }
    
    public pageReference cancel(){
        Pagereference page;
        
        if(map_urlParams.containsKey('retURL')){
            page = new Pagereference(map_urlParams.get('retURL'));
        }
        else if(cycle != null && cycle.Id != null){
            page = new Pagereference('/' + cycle.Id);
        }
        else{
            page = new Pagereference('/' + KEYPREFIX_CYCLE);
        }
        
        page.setRedirect(true);
        
        return page;
    }
    
    
    @remoteAction
    global static string savePortfolio(String result, Boolean isAM){
        //for(Portfolio__c p : [SELECT Id, Name, Number_of_FTEs__c, Number_of_calls_per_day__c, Number_of_days_in_the_field__c, Numbers_of_details_per_call__c FROM Portfolio__c WHERE Cycle__c = :cycleId]){
        
        Response r = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
            //system.debug('yyresult: ' + result);
            ClsPortfolioResult cpfr = (ClsPortfolioResult)JSON.deserialize(result, ClsPortfolioResult.class);
            //system.debug('yycpfr: ' + cpfr);
            //system.debug(cpfr.list_cpf[0].list_cmId[0].maId);
            list<Portfolio_BI__c> list_pf2upsert = new list<Portfolio_BI__c>();
            set<Id> set_pfnotDel = new set<Id>();
            list<Portfolio_BI__c> list_pf2del = new list<Portfolio_BI__c>();
            
            for(ClsPortfolioSave cpfs : cpfr.list_cpf){
                if(cpfs.pf.Cycle_BI__c == null){
                    cpfs.pf.Cycle_BI__c = cpfr.cycId;
                }
                
                list_pf2upsert.add(cpfs.pf);
                if(cpfs.pf.Id != null){
                    set_pfnotDel.add(cpfs.pf.Id);
                }
                
                /*if(cpfs.list_cmId != null && cpfs.list_cmId.size() != 0){
                    
                }*/
            }
            String queryString = 'SELECT Id FROM Portfolio_BI__c WHERE Id NOT IN :set_pfnotDel and Cycle_BI__c = \'' + cpfr.cycId + '\' ';
            queryString = isAM ? queryString + ' AND Account_Matrices_BI__c = true ' : queryString + ' AND Account_Matrices_BI__c = false ';
            for(Portfolio_BI__c p : database.query(queryString)){//AND (Status_BI__c = 'Draft' OR Status_BI__c = null)//2013-07-04 comment out show all portfolio independent of status
                list_pf2del.add(p);
            }
            if(list_pf2del.size() != 0){
                delete list_pf2del;
            }
            if(list_pf2upsert.size() != 0){
                upsert list_pf2upsert;
            } 
            //system.debug('yylist_pf2upsert: ' + list_pf2upsert);
            map<Id,decimal> map_matrixId_weight = new map<Id,decimal>();
            
            set<Id> set_pfId = new set<Id>();
            set<Id> set_cmId = new set<Id>();
            list<Strategic_Brand_Weight_BI__c> list_sbw2Insert = new list<Strategic_Brand_Weight_BI__c>();
            list<Strategic_Brand_Weight_BI__c> list_sbw2del = new list<Strategic_Brand_Weight_BI__c>();
            list<Strategic_Brand_Weight_BI__c> list_sbw2update = new list<Strategic_Brand_Weight_BI__c>();
            for(ClsPortfolioSave cpfs : cpfr.list_cpf){
                set_pfId.add(cpfs.pf.Id);
                if(cpfs.list_cmId != null && cpfs.list_cmId.size() != 0){
                    for(ClsMatrixId cmi : cpfs.list_cmId){
                        set_cmId.add(cmi.maId);
                        
                        Strategic_Brand_Weight_BI__c sbw = new Strategic_Brand_Weight_BI__c();
                        sbw.Matrix_BI__c = cmi.maId;
                        sbw.Portfolio_BI__c = cpfs.pf.Id;
                        if(cmi.weight != null && cmi.weight.trim() != ''){
                            sbw.Strategic_Weight_BI__c = Integer.valueOf(cmi.weight);
                        }
                        else{
                            sbw.Strategic_Weight_BI__c = null;
                        }
                        
                        //2013-06-21 added by Yuanyuan Zhang for priority detail
                        //Begin: commented out by Peng Zhu 2013-08-16
                        //if(cmi.priori != null && cmi.priori.trim() != ''){
                        //    sbw.First_detail_priority_BI__c = Integer.valueOf(cmi.priori);
                        //}
                        //else{
                        //    sbw.First_detail_priority_BI__c = null;
                        //}
                        //End: commented out by Peng Zhu 2013-08-16
                        sbw.First_detail_priority_BI__c = 0;
                        
                        //Begin: added by Peng Zhu 2013-08-08
                        //system.debug('**@@Peng cmi.fullCoverage : ' + cmi.fullCoverage);
                        if(cmi.fullCoverage != null) sbw.Full_Coverage_BI__c = cmi.fullCoverage;
                        //system.debug('**@@Peng sbw.Full_Coverage_BI__c : ' + sbw.Full_Coverage_BI__c);
                        
                        //End: added by Peng Zhu 2013-08-08 
                        
                        map_matrixId_weight.put(sbw.Matrix_BI__c,sbw.Strategic_Weight_BI__c);
                        
                        list_sbw2Insert.add(sbw);
                    }
                    
                }
            }
            
            //system.debug('yylist_sbw2Insert: ' + list_sbw2Insert);
            
            set<Id> set_delMatrixId = new set<Id>();
            list<Strategic_Brand_Weight_BI__c> list_sbw2Insert2 = list_sbw2Insert.clone();
            list<Integer> list_remove = new list<Integer>();
            for(Strategic_Brand_Weight_BI__c sbw : [SELECT Id , Matrix_BI__c, Portfolio_BI__c, Strategic_Weight_BI__c,First_detail_priority_BI__c, Full_Coverage_BI__c FROM Strategic_Brand_Weight_BI__c WHERE  Portfolio_BI__c IN :set_pfId]){//Matrix_BI__c IN :set_cmId AND
                //list_sbw2del.add(sbw);
                Boolean isMatch = false;
                //system.debug('yylist_sbw2Insert.size(): ' + list_sbw2Insert.size());
                for(Integer i = 0; i < list_sbw2Insert.size(); i++){//if it is find, means it is already exited, should be updated.
                    if(list_sbw2Insert[i].Matrix_BI__c == sbw.Matrix_BI__c && list_sbw2Insert[i].Portfolio_BI__c == sbw.Portfolio_BI__c){
                        if(sbw.Strategic_Weight_BI__c != list_sbw2Insert[i].Strategic_Weight_BI__c || sbw.First_detail_priority_BI__c != list_sbw2Insert[i].First_detail_priority_BI__c || sbw.Full_Coverage_BI__c != list_sbw2Insert[i].Full_Coverage_BI__c){
                            sbw.Strategic_Weight_BI__c = list_sbw2Insert[i].Strategic_Weight_BI__c;
                            //commentd out by Peng Zhu 2013-08-16
                            //sbw.First_detail_priority_BI__c = list_sbw2Insert[i].First_detail_priority_BI__c;
                            //added by Peng Zhu 2013-08-16
                            sbw.First_detail_priority_BI__c = 0;
                            
                            sbw.Full_Coverage_BI__c = list_sbw2Insert[i].Full_Coverage_BI__c;
                            list_sbw2update.add(sbw);
                        }
                        
                        isMatch = true;
                        list_remove.add(i);
                        break;
                    }
                }
                if(!isMatch){//Don't find means it should be deleted.
                    list_sbw2del.add(sbw);
                    set_delMatrixId.add(sbw.Matrix_BI__c);
                }
            }
            //system.debug('yylist_sbw2update: ' + list_sbw2update);
            list_remove.sort();
            for(Integer j = list_remove.size()-1; j >=0 ; j-- ){
                list_sbw2Insert2.remove(list_remove[j]);
            }
            
            if(list_sbw2del.size() != 0){
                delete list_sbw2del;
            }
            
            if(list_sbw2update.size() != 0){
                update list_sbw2update;
            }
            
            if(list_sbw2Insert2.size() != 0){
                insert list_sbw2Insert2;
            }
            
            //system.debug('yymap_matrixId_weight: ' + map_matrixId_weight);
            //system.debug('yyset_delMatrixId: ' + set_delMatrixId);
            if(!map_matrixId_weight.isEmpty() || !set_delMatrixId.isEmpty()){
                list<Matrix_BI__c> list_matrix = new list<Matrix_BI__c>();
                for(Matrix_BI__c mb : [SELECT Id, Weight_BI__c FROM Matrix_BI__c WHERE Id IN: map_matrixId_weight.keyset() OR Id IN:set_delMatrixId]){
                    if(map_matrixId_weight.containsKey(mb.Id)){
                        mb.Weight_BI__c = map_matrixId_weight.get(mb.Id);
                    }
                    else{
                        mb.Weight_BI__c = null;
                    }
                    list_matrix.add(mb);
                }
                update list_matrix;
            }
            r.orgId = (String)UserInfo.getOrganizationId();
        
            for(Portfolio_BI__c pf : list_pf2upsert){
                String pfId = (String) pf.Id;
                r.pfIdString = r.pfIdString == null? pfId:r.pfIdString + ',' + pfId;
            }
        }
        catch(DMLexception dex){
            Database.rollback(sp);
            r.success = false;
            r.message = dex.getMessage();
            return JSON.serialize(r);
        }
        catch(Exception e){
            r.success = false;
            r.message = e.getMessage() + e.getLineNumber();
            return JSON.serialize(r);
        }
        
        r.success = true;
        r.message = 'OK';
        
        
        return JSON.serialize(r);
    }
    //********************************* -=END public methods=- ************************************
    
    
    //********************************* -=BEGIN private methods=- *********************************
    //********************************* -=END private methods=- ***********************************
    
    
    //********************************* -=BEGIN help functions=- **********************************
    //********************************* -=END help functions=- ************************************
    
    //********************************* -=BEGIN inner classes=- ***********************************
    ///*>>>WrapperClass*/
    public class ClsMatrix{
        public Id cmId {get; set;}
        public String cmName {get; set;}
        public String cmTitle{get;set;}
        public Boolean isAssigned {get; set;}
        public Integer weight{get;set;}//yy added
        public Integer priori{get;set;}//2013-06-20 yy added for first detail priority
        public Strategic_Brand_Weight_BI__c sbw {get; set;}// added by Peng Zhu 2013-08-08
        public Boolean isAccountMatrix {get; set;}
        public String scenario { get; set;}
        public Boolean isCurrent { get; set;}
        
        public ClsMatrix(){
            isAssigned = false;
            isAccountMatrix = false;
        }
    }
    
    public class ClsPortfolio{
        public Portfolio_BI__c pf {get; set;}
        public list<ClsMatrix> list_cm {get; set;}
        
        public ClsPortfolio(){
            list_cm = new list<ClsMatrix>();
        }
    }
    public class ClsMatrixId{
        public String maId;
        public String weight;
        public String priori;
        public Boolean fullCoverage;
        public Boolean isAccountMatrix;
    }
    public class ClsPortfolioSave{
        public Portfolio_BI__c pf;
        public list<ClsMatrixId> list_cmId;
    }
    
    public class ClsPortfolioResult{
        public String cycId;
        public list<ClsPortfolioSave> list_cpf;
        
    }
    
    public class Response{
        public boolean success;
        public string message;
        public String pfIdString;
        public String orgId;
        
        public Response(){
            success = true;
            message = '';
        }
    }
    ///*<<<WrapperClass*/
    //********************************* -=END inner classes=- *************************************
}