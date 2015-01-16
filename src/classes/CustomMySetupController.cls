public class CustomMySetupController {
	/***
		WARNING!!!!
		
		Do not use this Product Alignment controller and the MySetup page at the same time
		It may cause inconsistencies in the database (e.g. lost update problem)
		
		Author: Raphael Krausz <raphael.krausz@veevasystems.com>
		
		TODO: Optimise further by having member lists of product ids and member map of product ids to setups?
		
	***/
	

        public My_Setup_Products_vod__c theUser { get; set; }
        public List<Product_vod__c> products { get; set; }
        // Map<Product_vod__c.id, selected or not>
        public Map<Id, Boolean> included  { get; set; }
        public Map<Id, Boolean> favourite { get; set; }
        public User user { get; set; }
        public String pageBlockMode { get; set; } // { return 'edit'; } }
        private ApexPages.StandardController stdCtrl;
        
        public CustomMySetupController() {
        	included  = new Map<Id, Boolean> {};
        	favourite = new Map<Id, Boolean> {};
        	products  = new Product_vod__c[] {};
        }
        public CustomMySetupController(ApexPages.StandardController std)
		{
		   stdCtrl=std;
		}
        
        public void cedit() {
        	pageBlockMode = 'edit';
        }
        
        String userId;
        
        /*
        public void UserSelected(){
		 	My_Setup_Products_vod__c u = (My_Setup_Products_vod__c) stdCtrl.getRecord();
          	system.debug('u: ' + u); 
          	userId = u.OwnerId;
          	system.debug('u: ' + u); 
        }
        */
        
        public void searchOwner() {/*****/
        	
        	system.debug('searchOwner started');        	
        	included  = new Map<Id, Boolean> {};
        	favourite = new Map<Id, Boolean> {};
        	products  = new Product_vod__c[] {};
        	        	        	
        	pageBlockMode = 'detail';
        	
        	My_Setup_Products_vod__c u = (My_Setup_Products_vod__c) stdCtrl.getRecord();
          	system.debug('u: ' + u); 
          	userId = u.OwnerId;
          	
          	//userId = '005K0000001QtapIAC';
          	
        	//userId = ApexPages.CurrentPage().getParameters().get('thePage:theForm:pbConfigure:bsUser:OwnerID_lkid');
        	        	
        	system.debug('userid: ' + userId);
        	if (userId == null) return;
        	
        	try {
        		user = [ SELECT id, Region_BI__c FROM User WHERE id = :userId ];
        		//system.debug('user: ' + user);
        	} catch (system.QueryException e) {
        		return;
        	}
        	
        	try {
        		theUser = [ SELECT id, ownerid FROM My_Setup_Products_vod__c WHERE ownerid = :userId limit 1 ];
        		system.debug('theUser: ' + theUser);
        	} catch (system.QueryException e) {
        		system.debug('userexception');
        		theUser = new My_Setup_Products_vod__c();
        		theUser.ownerId = userId;
        	}
        	
			if (user.Region_BI__c == null || Pattern.matches('^\\s*$', user.Region_BI__c))
        		products = [ SELECT Id, Name, Region_BI__c, Country_Code_BI__c, External_ID_vod__c FROM Product_vod__c WHERE Product_Type_vod__c = 'Detail' order by name asc ];
        	else
        		products = [
					SELECT Id, Name, Region_BI__c, Country_Code_BI__c, External_ID_vod__c FROM Product_vod__c
					WHERE Product_Type_vod__c = 'Detail' and Region_BI__c = :user.Region_BI__c
					ORDER BY Name ASC
				];
				
        	system.debug('products size: ' + products.size() );
        	
        	List<Id> product_ids = new List<Id> {};
        	//Map<Id, My_Setup_Products_vod__c> setups = new Map<Id, My_Setup_Products_vod__c> {};
        	system.debug('products size0: '+ products.size());
        	system.debug('included size0: '+ included.size());
        	system.debug('favourite size0: '+ favourite.size());
        	
        	if(included.size()==0 && favourite.size()==0){
	        	
	        	try {
		        	for(Product_vod__c product : products) {
		        		product_ids.add(product.id);
		        		included.put(product.id, false);
		        		favourite.put(product.id, false);
		        	}
	        	}catch(Exception ex){
	        		apexPages.addMessages(ex);
	        	}
	        	
	        	system.debug('products size1: '+ products.size());
	        	system.debug('included size1: '+ included.size());
	        	system.debug('favourite size1: '+ favourite.size());
	        	
	        	My_Setup_Products_vod__c[] setups;
	        	
	        	try {
	        		setups = [
	        			SELECT Product_vod__r.Id, Id, Favorite_vod__c FROM My_Setup_Products_vod__c WHERE OwnerId = :user.Id AND Product_vod__c IN :product_ids
	        		];
	        	} catch(system.QueryException e) {
	        		// If no results were returned, ensure there is an empty list to work upon
	        		setups = new My_Setup_Products_vod__c[] {};
	        	}
	        	
	        	for (My_Setup_Products_vod__c setup : setups) {
	        		included.put(setup.Product_vod__r.Id, true);
	        		favourite.put(setup.Product_vod__r.Id, setup.Favorite_vod__c);
	        	}      /*** */ 	
	        	
	        	
        	}
        	
        	system.debug('products size2: '+ products.size());
	        system.debug('included size2: '+ included.size());
	        system.debug('favourite size2: '+ favourite.size());
        }
        
        
        
        public void csave() {
        	        	
        	system.debug('products size3: '+ products.size());
        	system.debug('included size3: '+ included.size());
        	system.debug('favourite size3: '+ favourite.size());
        	
        	if (user == null || products.size() == 0) return;
        	
        	// thePage:theForm:pbConfigure:btProducts:0:included    - replace 0 with actual index
        	// thePage:theForm:pbConfigure:btProducts:0:favourite
        	// null is unchecked, 'on' is checked
        	
        	set<Id> product_ids = new set<Id> {};
        	
        	Map<Id, My_Setup_Products_vod__c> productSetupMap = new Map<Id, My_Setup_Products_vod__c> {};
        	try{
	        	for (Product_vod__c product : products) {
	        		//system.debug('productid: '+ product.Id);
	        		product_ids.add(product.Id);
	        		productSetupMap.put(product.Id, null);
	        	}
        	}catch(Exception ex){
        		apexPages.addMessages(ex);
        	}
        	
        	My_Setup_Products_vod__c[] setups = null;
        	
        	try {
        		setups = [
        				SELECT Product_vod__r.Id, Id, Favorite_vod__c FROM My_Setup_Products_vod__c WHERE OwnerId = :user.Id and Product_vod__c IN :product_ids
        		];        			
        	} catch(system.QueryException e) {
        		setups = new My_Setup_Products_vod__c[] {};
        	}
        	
        	try{
	        	for (My_Setup_Products_vod__c setup : setups) {
	        		productSetupMap.put(setup.Product_vod__r.Id, setup);
	        	}
        	}catch(Exception ex){
        		apexPages.addMessages(ex);
        	}
        	
        	
        	try{
	        	for (Integer i = 0; i < products.size(); i++) {
	        		Boolean included  = (ApexPages.CurrentPage().getParameters().get('thePage:theForm:pbConfigure:btProducts:' + i + ':included')  != null);
	        		Boolean favourite = (ApexPages.CurrentPage().getParameters().get('thePage:theForm:pbConfigure:btProducts:' + i + ':favourite') != null);
	        		
	        		
	
	        		My_Setup_Products_vod__c setup = productSetupMap.get(products[i].Id);
	
	        		system.debug('products['  + i + ']: ' + products[i].Name);
	        		system.debug('included['  + i + ']: ' + included);
	        		system.debug('favourite[' + i + ']: ' + favourite);
	        		
	        		// If the user marks the product as a favourite, but forget to include it than we include it.
	        		// Alternatively, we could remove the favourite tick and the product, however
	        		// it needs to be done one way or the other.
					// Ultimately JavaScript should be responsible for ensuring more 'sane' user input, and prevent
					// this condition from happening.
	        		if (favourite && !included) included = true;
	        		
	        		if (!included && setup != null) {  // !included && setup
	        			delete setup;
	        		} else if (included && setup == null) {   // included && !setup
	        			setup 					= new My_Setup_Products_vod__c();
	        			setup.OwnerId 			= user.Id;
	        			setup.Product_vod__c 	= products[i].Id;
	        			setup.Favorite_vod__c 	= (favourite != null);
	        			insert setup;
	        		} else if (included && setup != null) {    // included && setup
	        			if (favourite != setup.Favorite_vod__c) {
	        				setup.Favorite_vod__c = favourite;
	        				update setup;
	        			}
	        		}
	        		// else !included && !setup - nothing to do
	        		
	        		// included  && !setup	**
	        		// included  &&  setup	**
	        		// !included && !setup  -- nothing to do
	        		// !included &&  setup 	**    
	        		       		
	        	}
        	}catch(Exception ex){
        		apexPages.addMessages(ex);
        	}
        	
        	 pageBlockMode = 'detail';
        	 
        	 searchOwner();
        	         	 
        	 system.debug('This is the last line of the code.');
        }
        
 }