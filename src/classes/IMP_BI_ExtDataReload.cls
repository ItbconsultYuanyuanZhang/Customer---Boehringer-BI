/**
*   Extension class for page ExtDataReload
*
@author Yuanyuan Zhang
@created 2013-05-17
@version 1.0
@since 26.0 (Force.com ApiVersion)
*
@changelog
* 2013-05-17 Yuanyuan Zhang <yuanyuan.zhang@itbconsult.com>
* - Created
*/

public class IMP_BI_ExtDataReload {
   
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    /**
     * map to store global describtion due to limit on describe methodes.
     */
    public String mode{get;private set;}
    /**
     * transient string to show custom message on page.
     */
    public transient String message{get;private set;}
    
    /*
    *product list
    */
    //public list<productClass> list_productClass{get;set;}
    public Id cycId{get;set;}
    
    //public list<String> list_productId{get;set;}
    public String productIdString{get;set;}
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END public members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=BEGIN private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    /**
     * map to store global describtion due to limit on describe methodes.
     */
    private map<String, String> map_urlParams;
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -=END private members=- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    /////////////////////////////////// -=BEGIN CONSTRUCTOR=- /////////////////////////////////////
    /**
    * The contsructor
    *
    @author Yuanyuan Zhang
    @created 2013-05-17
    @version 1.0
    @since 26.0 (Force.com ApiVersion)
    *
    @changelog
    * 2013-05-17 Yuanyuan Zhang <yuanyuan.zhang@itbconsult.com>
    * - Created
    */
    public IMP_BI_ExtDataReload(ApexPages.standardController sc) {
        map_urlParams = ApexPages.currentPage().getParameters();
        
        if(map_urlParams.containsKey('id')){
            cycId = map_urlParams.get('id');
        }
        if(cycId != null){
           init(cycId);
        }
        /*ClsCycProd ccp = new ClsCycProd();
        ccp.cycId = 'asdfgsdf';
        list<String> list_a = new list<String>();
        list_a.add('sdfasfs');
        list_a.add('ytryty');
        ccp.list_prodId = list_a;
        aaa= JSON.serialize(ccp);
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, aaa));*/
    }
    /////////////////////////////////// -=END CONSTRUCTOR=- ///////////////////////////////////////
    
    
    //********************************* -=BEGIN public methods=- **********************************
    /**
    * This method is used to 
    *
    @author Yuanyuan Zhang
    @created 2013-05-17
    @version 1.0
    @since 26.0 (Force.com ApiVersion)
    *
    *@param id          cycle id
    @changelog
    * 2013-05-17 Yuanyuan Zhang <yuanyuan.zhang@itbconsult.com>
    * - Created
    */
    
    public void init(Id cyId){
        Cycle_BI__c cyc = [SELECT Country_Lkp_BI__c, Country_Lkp_BI__r.Name FROM Cycle_BI__c WHERE Id =:cyId limit 1];
        //list_productId = new list<String>();
        productIdString = '';
        if(cyc.Country_Lkp_BI__c != null){
            //list_productClass = new list<productClass>();//Country_2_BI__c, Country_1_BI__c, 
            /*for(Product_vod__c prod : [SELECT Country_BI__c, Name, Id 
                                   FROM Product_vod__c 
                                   WHERE Country_BI__c =: cyc.Country_Lkp_BI__c]){
                 productIdString += prod.Id + ',';
               
            }*/
            
            for(Cycle_Data_Overview_BI__c cdo : [SELECT Product_Catalog_BI__c FROM Cycle_Data_Overview_BI__c WHERE Cycle_BI__c = :cyId]){
            	productIdString += cdo.Product_Catalog_BI__c + ',';
            }
            /*for(Product__c prod : [SELECT Country_2__c, Country_1__c, Country__c, Name, RecordTypeId, Id,
                                         (Select Id From Cycle_Data__r limit 1)
                                   FROM Product__c 
                                   WHERE Country_2__c =: cyc.Country_Lkp__c]){
                
                Boolean hasCycData = false;
                for(Cycle_Data__c cd : prod.Cycle_Data__r){
                    hasCycData = true;
                }
                if(hasCycData){
                    //productClass pc = new productClass(prod);
                    //list_productClass.add(pc);
                    //list_productId.add(prod.Id);
                    productIdString += prod.Id + ',';
                }
            }*/
        }
        if(productIdString.endsWith(',')){
            productIdString = productIdString.subString(0,productIdString.length()-1);
        }
        /*if(productIdString == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.No_Product));
        }*/
    }
    
    public pageReference cancel(){
        pageReference pr = new pageReference('/' + cycId);
        pr.setRedirect(true);
        return pr;
    }
    
    @RemoteAction
    public static Response clearCycData(string productId) {
        Response r = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
            ClsCycProd ccp = (ClsCycProd)JSON.deserialize(productId, ClsCycProd.class);
            //ClsCycProd ccp = (ClsCycProd)JSON.deserialize('{"list_prodId":["a062000000ZQbB8AAL","a062000000b7QUvAAM"],"cycId":"a002000000S7CMAAA3"}', ClsCycProd.class);
            system.debug('yyccp: '  + ccp);
            String cycId = ccp.cycId;
            list<String> list_prodIds = ccp.list_prodId;
            list<Cycle_Data_BI__c> list_cycd2del = new list<Cycle_Data_BI__c>();
            for(Cycle_Data_BI__c cycd : [SELECT Id 
                                      FROM Cycle_Data_BI__c 
                                      WHERE Cycle_BI__c = :cycId
                                      AND Product_Catalog_BI__c IN :list_prodIds limit 4000]){//10000
                list_cycd2del.add(cycd);
            }
            system.debug('yylist_cycd2del.size: ' + list_cycd2del.size());
            if(list_cycd2del.size() == 4000){//10000
                r.gotonext = 'gonext';
            }
            r.delSize = list_cycd2del.size();
            /*else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Cycdata is cleared!'));
            }*/
            if(list_cycd2del.size() != 0){
            	database.delete(list_cycd2del);
            	database.emptyRecycleBin(list_cycd2del);
            }
        }
        catch(DmlException de){
    		Database.rollback(sp);
    		r.success = false;
			r.message = de.getMessage();
			return r;
    	}
        catch(Exception ex){
            r.message = ex.getMessage();
            r.success = false;
        }
        
        
        return r;
    }
    
    @RemoteAction
    public static Response clearMatrixData(string productId) {
        Response r = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
            ClsCycProd ccp = (ClsCycProd)JSON.deserialize(productId, ClsCycProd.class);
            //ClsCycProd ccp = (ClsCycProd)JSON.deserialize('{"list_prodId":["a062000000ZQbB8AAL","a062000000b7QUvAAM"],"cycId":"a002000000S7CMAAA3"}', ClsCycProd.class);
            //system.debug(ccp);
            String cycId = ccp.cycId;
            list<String> list_prodIds = ccp.list_prodId;
            list<Matrix_BI__c> list_matrix2del = new list<Matrix_BI__c>();
            set<Id> set_matrixId = new set<Id>();
            for(Matrix_BI__c mat : [SELECT Id 
                                 FROM Matrix_BI__c
                                 WHERE Cycle_BI__c =:cycId
                                 AND Product_catalog_BI__c IN :list_prodIds
                                 AND Status_BI__c = 'Draft']){
                list_matrix2del.add(mat);
                //set_matrixId.add(mat.Id);
            }
            
            if(list_matrix2del.size() != 0){
            	database.delete(list_matrix2del);
				database.emptyRecycleBin(list_matrix2del);
            }
            
            
            r.delSize = list_matrix2del.size();
        }
        catch(DmlException de){
    		Database.rollback(sp);
    		r.success = false;
			r.message = de.getMessage();
			return r;
    	}
        catch(Exception ex){
            r.message = ex.getMessage();
            r.success = false;
        }
        
        
        return r;
    }
    
    @RemoteAction
    public static Response clearMatrixCell(string productId) {
        Response r = new Response();
        //Savepoint sp = Database.setSavepoint();
        try{
            ClsCycProd ccp = (ClsCycProd)JSON.deserialize(productId, ClsCycProd.class);
            //ClsCycProd ccp = (ClsCycProd)JSON.deserialize('{"list_prodId":["a062000000ZQbB8AAL","a062000000b7QUvAAM"],"cycId":"a002000000S7CMAAA3"}', ClsCycProd.class);
            String cycId = ccp.cycId;
            list<String> list_prodIds = ccp.list_prodId;
            list<Matrix_BI__c> list_matrix2del = new list<Matrix_BI__c>();
            set<Id> set_matrixId = new set<Id>();
            for(Matrix_BI__c mat : [SELECT Id 
                                 FROM Matrix_BI__c
                                 WHERE Cycle_BI__c =:cycId
                                 AND Product_catalog_BI__c IN :list_prodIds
                                 AND Status_BI__c = 'Draft']){
                set_matrixId.add(mat.Id);
            }
            
            list<Matrix_Cell_BI__c> list_mc2del = new list<Matrix_Cell_BI__c>();
            
            for(Matrix_Cell_BI__c mc : [SELECT Id FROM Matrix_Cell_BI__c WHERE Matrix_BI__c in :set_matrixId limit 10]){
        		list_mc2del.add(mc);
        	}
            
            if(list_mc2del.size() == 10){
            	r.success = false;
				r.message = 'delcell';
				delete list_mc2del;
				//database.delete(list_mc2del);
				//database.emptyRecycleBin(list_mc2del);
            }
            else{
            	if(list_mc2del.size() != 0){
            		delete list_mc2del;
					//database.delete(list_mc2del);
					//database.emptyRecycleBin(list_mc2del);
				}
				r.success = true;
				r.message = 'delcelldone';
            }
            	
        }
        catch(DmlException de){
    		//Database.rollback(sp);
    		r.success = false;
			r.message = de.getMessage();
			return r;
    	}
        catch(Exception ex){
            r.message = ex.getMessage();
            r.success = false;
        }
        
        
        return r;
    }
    
    @RemoteAction
    public static Response clearMatrixDetail(string productId) {
        Response r = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
            ClsCycProd ccp = (ClsCycProd)JSON.deserialize(productId, ClsCycProd.class);
            //ClsCycProd ccp = (ClsCycProd)JSON.deserialize('{"list_prodId":["a062000000ZQbB8AAL","a062000000b7QUvAAM"],"cycId":"a002000000S7CMAAA3"}', ClsCycProd.class);
            //system.debug(ccp);
            String cycId = ccp.cycId;
            list<String> list_prodIds = ccp.list_prodId;
            list<Matrix_BI__c> list_matrix2del = new list<Matrix_BI__c>();
            set<Id> set_matrixId = new set<Id>();
            for(Matrix_BI__c mat : [SELECT Id 
                                 FROM Matrix_BI__c
                                 WHERE Cycle_BI__c =:cycId
                                 AND Product_catalog_BI__c IN :list_prodIds 
                                 AND Status_BI__c = 'Draft']){
                set_matrixId.add(mat.Id);
            }
            
            list<Matrix_Cell_Detail_BI__c> list_matrixDetail2del = new list<Matrix_Cell_Detail_BI__c>();
            
            //Matrix_Cell_Detail_BI__c Matrix_Cell_BI__c Matrix_BI__c
            for(Matrix_Cell_Detail_BI__c mcd : [SELECT Id FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__r.Matrix_BI__c in :set_matrixId limit 1000]){
            	list_matrixDetail2del.add(mcd);
            }
            
            if(list_matrixDetail2del.size() == 1000){
            	r.success = false;
				r.message = 'deldetail';
				database.delete(list_matrixDetail2del);
				database.emptyRecycleBin(list_matrixDetail2del);
            }
            else{
            	if(list_matrixDetail2del.size() != 0){
					database.delete(list_matrixDetail2del);
					database.emptyRecycleBin(list_matrixDetail2del);
				}
				r.success = true;
				r.message = 'deldetaildone';
            }
            	
        }
        catch(DmlException de){
    		Database.rollback(sp);
    		r.success = false;
			r.message = de.getMessage();
			return r;
    	}
        catch(Exception ex){
            r.message = ex.getMessage();
            r.success = false;
        }
        
        
        return r;
    }
    
    @remoteAction
    public static Response setCycleDataNull(string productId) {
        Response r = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
            //ClsCycProd ccp = (ClsCycProd)JSON.deserialize(productId, ClsCycProd.class);
            //ClsCycProd ccp = (ClsCycProd)JSON.deserialize('{"list_prodId":["a062000000ZQbB8AAL","a062000000b7QUvAAM"],"cycId":"a002000000S7CMAAA3"}', ClsCycProd.class);
            //system.debug(ccp);
            //String cycId = ccp.cycId;
            //list<String> list_prodIds = ccp.list_prodId;
            //list<Matrix_BI__c> list_matrix2del = new list<Matrix_BI__c>();
            //set<Id> set_matrixId = new set<Id>();
            /*for(Matrix_BI__c mat : [SELECT Id 
                                 FROM Matrix_BI__c
                                 WHERE Cycle_BI__c =:cycId
                                 AND Product_catalog_BI__c IN :list_prodIds limit 1]){
                set_matrixId.add(mat.Id);
            }*/
            system.debug('yyproductId: ' + productId);
            list<Cycle_Data_BI__c> list_cd2update = new list<Cycle_Data_BI__c>();
            
            for(Cycle_Data_BI__c cd : [SELECT Id,Matrix_BI__c FROM Cycle_Data_BI__c WHERE Matrix_BI__c =:productId limit 1000]){
            	cd.Matrix_BI__c = null;
            	list_cd2update.add(cd);
            }
            
            if(list_cd2update.size() == 1000){
            	r.success = false;
				r.message = 'setnull';
				update list_cd2update;
            }
            else{
            	if(list_cd2update.size() != 0){
					update list_cd2update;
				}
				r.success = true;
				r.message = 'setnulldone';
            }
            	
        }
        catch(DmlException de){
    		Database.rollback(sp);
    		r.success = false;
			r.message = de.getMessage();
			return r;
    	}
        catch(Exception ex){
            r.message = ex.getMessage();
            r.success = false;
        }
        
        
        return r;
    }
    
    /*
    @RemoteAction
    public static Response clearMatrixData(string productId) {
        Response r = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
            ClsCycProd ccp = (ClsCycProd)JSON.deserialize(productId, ClsCycProd.class);
            //ClsCycProd ccp = (ClsCycProd)JSON.deserialize('{"list_prodId":["a062000000ZQbB8AAL","a062000000b7QUvAAM"],"cycId":"a002000000S7CMAAA3"}', ClsCycProd.class);
            //system.debug(ccp);
            String cycId = ccp.cycId;
            list<String> list_prodIds = ccp.list_prodId;
            list<Matrix_BI__c> list_matrix2del = new list<Matrix_BI__c>();
            set<Id> set_matrixId = new set<Id>();
            for(Matrix_BI__c mat : [SELECT Cycle_BI__c, Product_catalog_BI__c, Id 
                                 FROM Matrix_BI__c
                                 WHERE Cycle_BI__c =:cycId
                                 AND Product_catalog_BI__c IN :list_prodIds limit 1]){
                list_matrix2del.add(mat);
                set_matrixId.add(mat.Id);
            }
            
            list<Matrix_Cell_Detail_BI__c> list_matrixDetail2del = new list<Matrix_Cell_Detail_BI__c>();
            
            //Matrix_Cell_Detail_BI__c Matrix_Cell_BI__c Matrix_BI__c
            for(Matrix_Cell_Detail_BI__c mcd : [SELECT Id FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__r.Matrix_BI__c in :set_matrixId limit 100]){
            	list_matrixDetail2del.add(mcd);
            }
            
            if(list_matrixDetail2del.size() == 100){
            	r.success = false;
				r.message = 'deldetail';
				database.delete(list_matrixDetail2del);
				//database.emptyRecycleBin(list_matrixDetail2del);
            }
            else{
            	if(list_matrixDetail2del.size() != 0){
					database.delete(list_matrixDetail2del);
					//database.emptyRecycleBin(list_matrixDetail2del);
				}
            	list<Matrix_Cell_BI__c> list_mc2del = new list<Matrix_Cell_BI__c>();
            	for(Matrix_Cell_BI__c mc : [SELECT Id FROM Matrix_Cell_BI__c WHERE Matrix_BI__c in :set_matrixId limit 100]){
            		list_mc2del.add(mc);
            	}
            	
            	if(list_mc2del.size() == 100){
            		r.success = false;
					r.message = 'delcell';
					database.delete(list_mc2del);
					//database.emptyRecycleBin(list_mc2del);
            	}
            	else{
	            	
					if(list_mc2del.size() != 0){
						database.delete(list_mc2del);
						//database.emptyRecycleBin(list_mc2del);
					}
					if(list_matrix2del.size() == 1){
						
						database.delete(list_matrix2del);
						r.success = false;
						r.message = 'delmatrix';
						//database.emptyRecycleBin(list_matrix2del);
					}
					else{
						r.success = true;
						r.message = 'done';
						//database.delete(list_matrix2del);
					}
            	}
            }
            
            //delete list_matrix2del;
            r.delSize = list_matrix2del.size();
        }
        catch(DmlException de){
    		Database.rollback(sp);
    		r.success = false;
			r.message = de.getMessage();
			return r;
    	}
        catch(Exception ex){
            r.message = ex.getMessage();
            r.success = false;
        }
        
        
        return r;
    }*/
    
    //@RemoteAction
    /*public static Response clearMatrixData(string productId) {
        Response r = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
            ClsCycProd ccp = (ClsCycProd)JSON.deserialize(productId, ClsCycProd.class);
            //ClsCycProd ccp = (ClsCycProd)JSON.deserialize('{"list_prodId":["a062000000ZQbB8AAL","a062000000b7QUvAAM"],"cycId":"a002000000S7CMAAA3"}', ClsCycProd.class);
            system.debug(ccp);
            String cycId = ccp.cycId;
            list<String> list_prodIds = ccp.list_prodId;
            list<Matrix_BI__c> list_matrix2del = new list<Matrix_BI__c>();
            for(Matrix_BI__c mat : [SELECT Cycle_BI__c, Product_catalog_BI__c, Id 
                                 FROM Matrix_BI__c
                                 WHERE Cycle_BI__c =:cycId
                                 AND Product_catalog_BI__c IN :list_prodIds]){
                list_matrix2del.add(mat);
            }
            
            delete list_matrix2del;
            r.delSize = list_matrix2del.size();
        }
        catch(DmlException de){
    		Database.rollback(sp);
    		r.success = false;
			r.message = de.getMessage();
			return r;
    	}
        catch(Exception ex){
            r.message = ex.getMessage();
            r.success = false;
        }
        
        
        return r;
    }*/
    
    @RemoteAction
    public static productHasCd checkProductHasCd(string productId) {
        
        productHasCd phc = new productHasCd();
        try{
            //system.debug('yyproductId:  ' + productId);
            list<String> list_Id = productId.split(',');
            //system.debug('yylist_Id:  ' + list_Id);
            Cycle_Data_BI__c cd = new Cycle_Data_BI__c();
            cd = [select product_catalog_BI__c, product_catalog_BI__r.Name from Cycle_Data_BI__c where cycle_BI__c = :list_Id[1] and product_catalog_BI__c = :list_Id[0] limit 1];
            //system.debug('yycd:  ' + cd);
            if(cd != null){
                phc.hasCycData = true;
                phc.cd = cd;
            }
        
        }
        catch(Exception ex){
        }
        
        
        return phc;
    }
    //********************************* -=END public methods=- ************************************
    
    
    //********************************* -=BEGIN private methods=- *********************************
    //********************************* -=END private methods=- ***********************************
    
    
    //********************************* -=BEGIN help functions=- **********************************
    //********************************* -=END help functions=- ************************************
    
    //********************************* -=BEGIN inner classes=- ***********************************
    ///*>>>WrapperClass*/
    /*public class productClass{
        public Boolean isSelected{get;set;}
        public Product__c prod{get;private set;}
        public productClass(Product__c pr){
            isSelected = false;
            prod = pr;
        }
    }*/
    
    public class ClsCycProd {
        public Id cycId;
        public list<Id> list_prodId;
    }
    
    public class Response{
        boolean success;
        String gotonext;
        string message;
        Integer delSize;
        //set<Id> set_recyclId;
        
        public Response() {
            success = true;
            gotonext = 'isover';
            message = '';
            delSize = 0;
            //set_recyclId = new set<Id>();
        }
   }
   
   public class productHasCd{
        boolean hasCycData{get;set;}
        Cycle_Data_BI__c cd{get;set;}
        public productHasCd(){
            hasCycData = false;
        }
   }
    ///*<<<WrapperClass*/
    //********************************* -=END inner classes=- *************************************
}