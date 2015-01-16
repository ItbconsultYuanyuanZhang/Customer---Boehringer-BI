trigger VOD_CALL2_SAMPLE_BEFORE_TRIGGER on Call2_Sample_vod__c (before delete, before insert, before update) {
        
    //do not call this in case of Delete! 
    if(trigger.isDelete == false)
        VEEVA_CSL.Main(trigger.new);
   

    VOD_ERROR_MSG_BUNDLE bnd = new VOD_ERROR_MSG_BUNDLE ();
    String NO_DEL_SUB = bnd.getErrorMsg('NO_DEL_SUB');
    String NO_UPD_SUB = bnd.getErrorMsg('NO_UPD_SUB');
        
    List <String> parentCall = new List <String> ();

    Set<String> allIds =  new Set<String> ();
    Map<String, List<Product_Group_vod__c>> productGroupMapping = new Map<String, List<Product_Group_vod__c>>();
    Map<String, List<String>> acctSamples = new Map<String, List<String>>();
    Call2_Sample_vod__c [] cRow = null;
    
    // variable to hold the multi currency
    Boolean isMultiCurrency = false;  
    Map<String, String> productCurrenciesSGMap = new Map<String, String> ();
            
    if (Trigger.isDelete) 
        cRow = Trigger.old;
    else
        cRow = Trigger.new;   
            
            
    for (Integer i = 0; i < cRow.size (); i++ ) {
        parentCall.add (cRow[i].Call2_vod__c);          
    }
    
    // check for multicurrency
    SOBject callSampleInterface = (SObject) cRow[0];
    String currCodeCSample = null;
    try {
        currCodeCSample = (String)callSampleInterface.get('CurrencyIsoCode');
    } catch ( System.SObjectException e) {
    }
    
    if (currCodeCSample != null) {
        isMultiCurrency = true;
    }
            
    Map <Id, Call2_vod__c> calls =  VOD_CALL2_CHILD_COMMON.getCallMap (parentCall);
    for (Integer k = 0; k < cRow.size(); k++) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            if (cRow[k].Attendee_Type_vod__c != null && cRow[k].Attendee_Type_vod__c.length() > 0 &&  
                cRow[k].Entity_Reference_Id_vod__c != null && cRow[k].Entity_Reference_Id_vod__c.length() > 0) {
                if ('Person_Account_vod' == cRow[k].Attendee_Type_vod__c  || 'Group_Account_vod' == cRow[k].Attendee_Type_vod__c ) {
                    cRow[k].Account_vod__c = cRow[k].Entity_Reference_Id_vod__c;    
                    cRow[k].Entity_Reference_Id_vod__c = null;                  
                }
            }
    
        }
        if ((Trigger.isInsert || Trigger.isUpdate) && (cRow[k].Override_Lock_vod__c == true)) {
            cRow[k].Override_Lock_vod__c = false;
            continue;
        }
        if (VOD_CALL2_CHILD_COMMON.isLocked (cRow[k].Call2_vod__c, calls)) {
            if (Trigger.isDelete) {
                cRow[k].Call2_vod__c.addError(NO_DEL_SUB);
            }
            else {
                if (VEEVA_SAMPLE_CANCEL.isSampleCancel == false)
                    cRow[k].Call2_vod__c.addError(NO_UPD_SUB);
            }
        }
        Call2_vod__c myCall = calls.get(cRow[k].Call2_vod__c);
        
        String ownerId = null;
        if (myCall != null)
            ownerId = myCall.OwnerId;
       
      
      String AccountProd = VOD_CALL2_CHILD_COMMON.getLimitId (cRow[k].Account_vod__c,cRow[k].Product_vod__c, '');
      String AccountProdUser = VOD_CALL2_CHILD_COMMON.getLimitId (cRow[k].Account_vod__c,cRow[k].Product_vod__c, ownerId);
      String UserProd = VOD_CALL2_CHILD_COMMON.getLimitId ('',cRow[k].Product_vod__c, ownerId);
      
      allIds.add(AccountProd);
      allIds.add(AccountProdUser);
      allIds.add(UserProd);   
   
      // add for product group mapping
      List<String> samples = acctSamples.get(cRow[k].Account_vod__c);
      if (samples == null) {
          samples = new List<String>();
          acctSamples.put(cRow[k].Account_vod__c, samples);
      }
      samples.add(cRow[k].Product_vod__c);
      
      if (!productGroupMapping.containsKey(cRow[k].Product_vod__c)) {
          productGroupMapping.put(cRow[k].Product_vod__c, new List<Product_Group_vod__c>());
      }
      
    }
    
    for (Product_Group_vod__c prodGrpObj :
            [Select Id,Start_Date_vod__c,End_Date_vod__c,Product_vod__c,Product_Catalog_vod__c
                From Product_Group_vod__c
                Where Product_vod__c In :productGroupMapping.keySet()]) {
        List<Product_Group_vod__c> pgs = productGroupMapping.get(prodGrpObj.Product_vod__c);
        pgs.add(prodGrpObj);
    }
    
    // generate group ids for sample product groups
    for (String acctId : acctSamples.keySet()) {
        List<String> sampleIds = acctSamples.get(acctId);
        for (String sampleId : sampleIds) {
            List<Product_Group_vod__c> prodGroups = productGroupMapping.get(sampleId);
            for (Product_Group_vod__c prodGroup : prodGroups) {
                allIds.add(VOD_CALL2_CHILD_COMMON.getLimitId(acctId, prodGroup.Product_Catalog_vod__c, ''));
            }
        }
    }    
    Map<String, List<Sample_Limit_vod__c>> mapSLbyExtId = new   Map<String, List<Sample_Limit_vod__c>>();
    Map<String,Sample_Limit_vod__c> updateMap = new  Map<String,Sample_Limit_vod__c> ();
    List<Sample_Limit_Transaction_vod__c> transactions = new  List<Sample_Limit_Transaction_vod__c> ();
    String sampleLimitSelect = null;   
    
    String sampleLimitQuery;
    
    if (isMultiCurrency) {
        sampleLimitQuery = 'Select  Name,External_Id_vod__c,Account_vod__c, Account_vod__r.Formatted_Name_vod__c,' +
                      'Disbursed_Quantity_vod__c, End_Date_vod__c, Enforce_Limit_vod__c, Group_Id_vod__c,' + 
                      'Id, Limit_Per_Call_vod__c, Limit_Quantity_vod__c, Product_vod__c, Product_vod__r.Name,' + 
                      'Remaining_Quantity_vod__c, Sample_Limit_Type_vod__c, Start_Date_vod__c, User_vod__c,' + 
                      'Limit_Amount_vod__c, Disbursed_Amount_vod__c, Remaining_Amount_vod__c, Product_vod__r.CurrencyIsoCode,' +  
                      'User_vod__r.Username, CurrencyIsoCode FROM Sample_Limit_vod__c Where Group_Id_vod__c in :allIds';
    
    } else {
        sampleLimitQuery = 'Select  Name,External_Id_vod__c,Account_vod__c, Account_vod__r.Formatted_Name_vod__c,' + 
                      'Disbursed_Quantity_vod__c, End_Date_vod__c, Enforce_Limit_vod__c, Group_Id_vod__c,' + 
                      'Id, Limit_Per_Call_vod__c, Limit_Quantity_vod__c, Product_vod__c, Product_vod__r.Name,' + 
                      'Remaining_Quantity_vod__c, Sample_Limit_Type_vod__c, Start_Date_vod__c, User_vod__c,' +
                      'Limit_Amount_vod__c, Disbursed_Amount_vod__c, Remaining_Amount_vod__c,' +  
                      'User_vod__r.Username FROM Sample_Limit_vod__c Where Group_Id_vod__c in :allIds';
    }
    
    List<Sample_Limit_vod__c> sampleLimits = Database.query(sampleLimitQuery); 
    for (Sample_Limit_vod__c limitObj : sampleLimits) {
                    
        String acctId = limitObj.Account_vod__c;
        if (acctId != null && !limitObj.Group_Id_vod__c.startsWith(acctId.substring(0,15))) {
            continue;
        }       
                    
        List<Sample_Limit_vod__c> thisLimit =  mapSLbyExtId.get(limitObj.Group_Id_vod__c);
        if (thisLimit == null) {
            thisLimit =  new List<Sample_Limit_vod__c> ();
        }  
        thisLimit.add(limitObj);
        mapSLbyExtId.put (limitObj.Group_Id_vod__c, thisLimit);
        
        // add all product ids of product type sample product group to get the currencies
        if (isMultiCurrency) { 
            SOBject pInterface = (SObject)limitObj.Product_vod__r;           
            try {
                productCurrenciesSGMap.put(limitObj.Product_vod__c, (String)pInterface.get('CurrencyIsoCode'));
            } catch ( System.SObjectException e) {
            }
        }
      }
      
      system.debug(' the values of product group currencies are ' + productCurrenciesSGMap); 
       
      
      if (mapSLbyExtId.size() > 0) {
           for (Integer k = 0; k < cRow.size(); k++) {

             if (cRow[k].Limit_Applied_vod__c == true || cRow[k].Apply_Limit_vod__c == false || Trigger.isDelete == true)
                continue;

             cRow[k].Apply_Limit_vod__c = false;
             cRow[k].Limit_Applied_vod__c = true;
             
             Call2_vod__c myCall = calls.get(cRow[k].Call2_vod__c);
             String ownerId = null;
             Date CallDate = null;
            
             if (myCall != null) {
                ownerId = myCall.OwnerId;
                CallDate = cRow[k].Call_Date_vod__c;
                
             }
             System.Debug ('cRow=' +  cRow[k]);
             String AccountProd = VOD_CALL2_CHILD_COMMON.getLimitId (cRow[k].Account_vod__c,cRow[k].Product_vod__c, '');
             String AccountProdUser = VOD_CALL2_CHILD_COMMON.getLimitId (cRow[k].Account_vod__c,cRow[k].Product_vod__c, ownerId);
             String UserProd = VOD_CALL2_CHILD_COMMON.getLimitId ('',cRow[k].Product_vod__c, ownerId);
              
              List<Sample_Limit_vod__c>  AccountProdLst =  mapSLbyExtId.get(AccountProd);         
              List<Sample_Limit_vod__c>  AccountProdUserLst =  mapSLbyExtId.get(AccountProdUser);
              List<Sample_Limit_vod__c>  UserProdList =  mapSLbyExtId.get(UserProd);
              
              Boolean isValueIgnore = false;
            
              if (AccountProdLst != null && AccountProdLst.size() > 0) {
                    for (Sample_Limit_vod__c myLimit : AccountProdLst) {
                        if (CallDate >= myLimit.Start_Date_vod__c  && CallDate <= myLimit.End_Date_vod__c) {                        
                            
                            // here check if the multicurrency org and skip the currencies that do not match                            
                            SObject slInterface = (SObject) myLimit;
                            System.debug(' value of my limit is  ' + myLimit);                            
                            String currCodeSL  = null;
                            // now get the currency for product 
                            SOBject prodInterface = (SObject) cRow[k];
                            String currCodeProd = null;
                            try {
                                currCodeSL = (String)slInterface.get('CurrencyIsoCode');
                                currCodeProd = (String)prodInterface.get('CurrencyIsoCode');
                            } catch ( System.SObjectException e) {
                            }
                            
                            // just for debugging purposes
                            System.debug('in the account product combination ');      
                            System.debug('the sample limit currency value is   ' + currCodeSL);
                            System.debug('the product currency value is    ' + currCodeProd);
                             
                            Sample_Limit_vod__c checkLimit = updateMap.get(myLimit.Id);
                            if (checkLimit != null) {
                                // check the currencies and continue is its not same
                                if (currCodeSL != null && currCodeProd != null) { // means multicurrency org
                                    if (!currCodeSL.equals(currCodeProd)) {
                                        isValueIgnore = true;
                                    }   
                                } 
                                System.debug ('CheckLimit=' + checkLimit);
                                if (isValueIgnore) {
                                    // check if its only value limit or both
                                    if (checkLimit.Limit_Quantity_vod__c != null) { // both
                                        Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], checkLimit, myCall, isValueIgnore);
                                        transactions.add(slT);
                                    } else { // only value limit
                                        continue;
                                    }                                    
                                } else { // is value ignore is false either due to non multi currency org or the currencies matched 
                                    Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], checkLimit, myCall, false);
                                    transactions.add(slT);    
                                }
                                if(checkLimit.Limit_Amount_vod__c != null && checkLimit.Disbursed_Amount_vod__c == null) {
                                    checkLimit.Disbursed_Amount_vod__c = 0.0;    
                                }
                                if (checkLimit.Disbursed_Quantity_vod__c == null) {
                                    checkLimit.Disbursed_Quantity_vod__c = 0;
                                }
                                if (checkLimit.Limit_Per_Call_vod__c == false) {
                                    if (!VEEVA_SAMPLE_CANCEL.isSampleCancel) {
                                        checkLimit.Disbursed_Quantity_vod__c += cRow[k].Quantity_vod__c;
                                        // add condition if its only amount limit we need to update those amount fields
                                        if(checkLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {
                                            checkLimit.Disbursed_Amount_vod__c += cRow[k].Amount_vod__c;                                            
                                        }
                                    }
                                    else {
                                        checkLimit.Disbursed_Quantity_vod__c -= cRow[k].Quantity_vod__c;
                                        if(checkLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {                                            
                                            checkLimit.Disbursed_Amount_vod__c -= cRow[k].Amount_vod__c;                                            
                                        }
                                    }
                                }
                                checkLimit.Disable_Txn_Create_vod__c = true;
                                updateMap.put(checkLimit.Id,checkLimit);
                            } else {
                                System.debug ('myLimit=' + myLimit);
                                // check for the currencies and skip if there are not same
                                 // check the currencies and continue is its not same
                                if (currCodeSL != null && currCodeProd != null) { // means multicurrency org
                                    if (!currCodeSL.equals(currCodeProd)) {
                                        isValueIgnore = true;
                                    }   
                                } 
                                if (myLimit.Disbursed_Quantity_vod__c == null) {
                                    myLimit.Disbursed_Quantity_vod__c = 0;
                                }
                                
                                if (isValueIgnore) { // now check if its quantity, value or both
                                    if (myLimit.Limit_Quantity_vod__c != null) { // only quantity limit
                                        Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], myLimit, myCall, isValueIgnore);
                                        transactions.add(slT);
                                    } else { // only value limit
                                        continue;
                                    }
                                } else { // either currency matched or non multi currency org
                                    Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], myLimit, myCall, false);
                                    transactions.add(slT);
                                }
                                if(myLimit.Limit_Amount_vod__c != null && myLimit.Disbursed_Amount_vod__c == null) {
                                    myLimit.Disbursed_Amount_vod__c = 0.0;           
                                }
                                if (myLimit.Limit_Per_Call_vod__c == false) {
                                    if (!VEEVA_SAMPLE_CANCEL.isSampleCancel) {
                                       myLimit.Disbursed_Quantity_vod__c +=cRow[k].Quantity_vod__c;
                                       if(myLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {
                                           myLimit.Disbursed_Amount_vod__c +=cRow[k].Amount_vod__c;
                                       }
                                    }
                                    else {
                                        myLimit.Disbursed_Quantity_vod__c -=cRow[k].Quantity_vod__c;
                                        if(myLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {
                                            myLimit.Disbursed_Amount_vod__c -=cRow[k].Amount_vod__c;                                            
                                        }
                                    }
                                }
                                myLimit.Disable_Txn_Create_vod__c = true;
                                updateMap.put(myLimit.Id,myLimit);
                            }
                            
                        }
                    }           
              }
              if (AccountProdUserLst != null && AccountProdUserLst.size() > 0) {
                for (Sample_Limit_vod__c myLimit : AccountProdUserLst) {
                        if (CallDate >= myLimit.Start_Date_vod__c  && CallDate <= myLimit.End_Date_vod__c) {
                                // check for multicurrency and their corresponding values
                                SObject slInterface = (SObject)myLimit;
                                String currCodeSL  = null;
                                // now get the currency for product 
                                SOBject prodInterface = (SObject) cRow[k];
                                String currCodeProd = null;
                                try {
                                    currCodeSL = (String)slInterface.get('CurrencyIsoCode');
                                    currCodeProd = (String)prodInterface.get('CurrencyIsoCode');
                                } catch ( System.SObjectException e) {
                                }

                                Sample_Limit_vod__c checkLimit = updateMap.get(myLimit.Id);
                            if (checkLimit != null) {
                                System.debug ('CheckLimit=' + checkLimit);
                                
                                // check the currencies and continue if its not same
                                if (currCodeSL != null && currCodeProd != null) { // means multicurrency org
                                    if (!currCodeSL.equals(currCodeProd)) {
                                        isValueIgnore = true;
                                    }   
                                }
                                if (isValueIgnore) { // now check if its quantity, value or both
                                    if (checkLimit.Limit_Quantity_vod__c != null) {
                                        Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], checkLimit, myCall, isValueIgnore);
                                        transactions.add(slT);
                                    } else {
                                        continue;
                                    }
                                } else {
                                    Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], checkLimit, myCall, false);
                                    transactions.add(slT);
                                }
                                if(checkLimit.Limit_Amount_vod__c != null && checkLimit.Disbursed_Amount_vod__c == null ) {
                                    checkLimit.Disbursed_Amount_vod__c = 0.0;
                                }
                                if (checkLimit.Disbursed_Quantity_vod__c == null) {
                                    checkLimit.Disbursed_Quantity_vod__c = 0;    
                                }
                                if (checkLimit.Limit_Per_Call_vod__c == false) {
                                    if (!VEEVA_SAMPLE_CANCEL.isSampleCancel) {
                                        checkLimit.Disbursed_Quantity_vod__c += cRow[k].Quantity_vod__c;
                                        if(checkLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {                                            
                                            checkLimit.Disbursed_Amount_vod__c += cRow[k].Amount_vod__c;                                            
                                        }
                                    }
                                    else {
                                        checkLimit.Disbursed_Quantity_vod__c -= cRow[k].Quantity_vod__c;
                                        if(checkLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {
                                            checkLimit.Disbursed_Amount_vod__c -= cRow[k].Amount_vod__c;                                            
                                        }
                                    }
                                }
                                checkLimit.Disable_Txn_Create_vod__c = true;
                                updateMap.put(checkLimit.Id,checkLimit);
                            } else {
                                System.debug ('myLimit=' + myLimit);
                                // check the currencies and continue if its not same
                                if (currCodeSL != null && currCodeProd != null) { // means multicurrency org
                                    if (!currCodeSL.equals(currCodeProd)) {
                                        isValueIgnore = true;
                                    }   
                                }
                                if (myLimit.Disbursed_Quantity_vod__c == null) {
                                    myLimit.Disbursed_Quantity_vod__c = 0;
                                }
                                // add default to the disbursed amount field
                                if (myLimit.Limit_Amount_vod__c != null && myLimit.Disbursed_Amount_vod__c == null) {
                                    myLimit.Disbursed_Amount_vod__c = 0.0;
                                }
                                if (isValueIgnore) { // now check if its quantity, value or both
                                    if (myLimit.Limit_Quantity_vod__c != null) {
                                        Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], myLimit, myCall, isValueIgnore);
                                        transactions.add(slT);
                                    } else {
                                        continue;
                                    }
                                } else {
                                    Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], myLimit, myCall, false);
                                    transactions.add(slT);
                                }
                                if (myLimit.Limit_Per_Call_vod__c == false) {
                                    if (!VEEVA_SAMPLE_CANCEL.isSampleCancel) {
                                        myLimit.Disbursed_Quantity_vod__c +=cRow[k].Quantity_vod__c;
                                        if(myLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {                                            
                                            myLimit.Disbursed_Amount_vod__c +=cRow[k].Amount_vod__c;                                            
                                        }
                                    }
                                    else {
                                        myLimit.Disbursed_Quantity_vod__c -=cRow[k].Quantity_vod__c;
                                        if(myLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {                                            
                                            myLimit.Disbursed_Amount_vod__c -=cRow[k].Amount_vod__c;                                           
                                        }
                                    }
                                }
                                myLimit.Disable_Txn_Create_vod__c = true;
                                updateMap.put(myLimit.Id,myLimit);
                            }
                        }
                    }           
              }
              if (UserProdList != null && UserProdList.size() > 0) {
                for (Sample_Limit_vod__c myLimit : UserProdList) {
                        if (CallDate >= myLimit.Start_Date_vod__c  && CallDate <= myLimit.End_Date_vod__c) {
                                Sample_Limit_vod__c checkLimit = updateMap.get(myLimit.Id);
                                // check for multicurrency and their corresponding values
                                SObject slInterface = (SObject)myLimit;
                                String currCodeSL  = null;
                                // now get the currency for product 
                                SOBject prodInterface = (SObject) cRow[k];
                                String currCodeProd = null;
                                try {
                                    currCodeSL = (String)slInterface.get('CurrencyIsoCode');
                                    currCodeProd = (String)prodInterface.get('CurrencyIsoCode');
                                } catch ( System.SObjectException e) {
                                }
                                
                                System.debug('in the user product combination ');      
                                System.debug('the sample limit currency value is   ' + currCodeSL);
                                System.debug('the product currency value is    ' + currCodeProd);
                            if (checkLimit != null) {
                                System.debug ('CheckLimit=' + checkLimit);
                                // check the currencies and continue if its not same
                                if (currCodeSL != null && currCodeProd != null) { // means multicurrency org
                                    if (!currCodeSL.equals(currCodeProd)) {
                                        isValueIgnore = true;
                                    }   
                                }
                                if (isValueIgnore) { // now check if its quantity, value or both
                                    if (checkLimit.Limit_Quantity_vod__c != null) {
                                        Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], checkLimit, myCall, isValueIgnore);
                                        transactions.add(slT);
                                    } else {
                                        continue;
                                    }
                                } else {
                                    Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], checkLimit, myCall, false);
                                    transactions.add(slT);
                                }
                                if(checkLimit.Limit_Amount_vod__c != null && checkLimit.Disbursed_Amount_vod__c == null) {
                                    checkLimit.Disbursed_Amount_vod__c = 0.0;
                                }
                                if ( checkLimit.Disbursed_Quantity_vod__c == null) {
                                     checkLimit.Disbursed_Quantity_vod__c = 0;
                                }
                                if (checkLimit.Limit_Per_Call_vod__c == false) {
                                    if (!VEEVA_SAMPLE_CANCEL.isSampleCancel) {
                                        checkLimit.Disbursed_Quantity_vod__c += cRow[k].Quantity_vod__c;
                                        if(checkLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {                                            
                                            checkLimit.Disbursed_Amount_vod__c += cRow[k].Amount_vod__c;                                           
                                        }
                                    }
                                    else {
                                        checkLimit.Disbursed_Quantity_vod__c -= cRow[k].Quantity_vod__c;
                                        if(checkLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {                                            
                                            checkLimit.Disbursed_Amount_vod__c -= cRow[k].Amount_vod__c;                                           
                                        }
                                    }
                                }
                                checkLimit.Disable_Txn_Create_vod__c = true;
                                updateMap.put(checkLimit.Id,checkLimit);
                            } else {
                                System.debug ('myLimit=' + myLimit);
                                // check the currencies and continue if its not same
                                if (currCodeSL != null && currCodeProd != null) { // means multicurrency org
                                    if (!currCodeSL.equals(currCodeProd)) {
                                        isValueIgnore = true;
                                    }   
                                }
                                if (myLimit.Disbursed_Quantity_vod__c == null){
                                    myLimit.Disbursed_Quantity_vod__c = 0;
                                }
                                // set default to disbursed amount
                                if (myLimit.Limit_Amount_vod__c != null && myLimit.Disbursed_Amount_vod__c == null){
                                    myLimit.Disbursed_Amount_vod__c = 0.0;
                                }
                                if (isValueIgnore) { // now check if its quantity, value or both                                 
                                    if (myLimit.Limit_Quantity_vod__c != null) {    
                                        Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], myLimit, myCall, isValueIgnore);
                                        transactions.add(slT);
                                    } else {
                                        continue;
                                    }
                                } else {
                                    Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], myLimit, myCall, false);
                                    transactions.add(slT);
                                }
                                if (myLimit.Limit_Per_Call_vod__c == false) {
                                    if (!VEEVA_SAMPLE_CANCEL.isSampleCancel) {
                                        myLimit.Disbursed_Quantity_vod__c +=cRow[k].Quantity_vod__c;
                                        if( myLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {
                                            myLimit.Disbursed_Amount_vod__c +=cRow[k].Amount_vod__c;
                                        }
                                    }
                                    else {
                                        myLimit.Disbursed_Quantity_vod__c -=cRow[k].Quantity_vod__c;
                                        if( myLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {
                                            myLimit.Disbursed_Amount_vod__c -=cRow[k].Amount_vod__c;
                                        }
                                    }
                                }
                                myLimit.Disable_Txn_Create_vod__c = true;
                                updateMap.put(myLimit.Id,myLimit);
                            }
                        }
                    }           
              }

              // now determine which sample group limits need to be updated
              List<Product_Group_vod__c> prodGroups = productGroupMapping.get(cRow[k].Product_vod__c);
              if (prodGroups != null) {
                  for (Product_Group_vod__c prodGroup : prodGroups) {
                      // verify what active groups the product belongs to
                      if (CallDate >= prodGroup.Start_Date_vod__c && CallDate <= prodGroup.End_Date_vod__c) {
                          List<Sample_Limit_vod__c> acctGroupList = mapSLbyExtId.get(VOD_CALL2_CHILD_COMMON.getLimitId(cRow[k].Account_vod__c, prodGroup.Product_Catalog_vod__c, '')); 
                          if (acctGroupList != null) {
                              for (Sample_Limit_vod__c myLimit : acctGroupList) {
                                if (CallDate >= myLimit.Start_Date_vod__c && CallDate <= myLimit.End_Date_vod__c) {
                                    // here check if the multicurrency org and skip the currencies that do not match                            
                                    SObject slInterface = (SObject)myLimit;
                                    String currCodeSL  = null;
                                    // now get the currency for product                                                                        
                                    String currCodeProd = null;
                                    if (productCurrenciesSGMap != null && productCurrenciesSGMap.size() > 0) {
                                        currCodeProd = productCurrenciesSGMap.get(myLimit.Product_vod__c);
                                    }
                                    try {
                                        currCodeSL = (String)slInterface.get('CurrencyIsoCode');                                        
                                    } catch ( System.SObjectException e) {
                                    }
                                    
                                    system.debug(' the group sample limit case the SL currency is ' + currCodeSL);
                                    system.debug(' the group sample limit case the SL currency is ' + currCodeProd);
                                    
                                    Sample_Limit_vod__c checkLimit = updateMap.get(myLimit.Id);
                                    if (checkLimit != null) {
                                        System.debug ('CheckLimit=' + checkLimit);
                                        // check the currencies and continue is its not same
                                        if (currCodeSL != null && currCodeProd != null) { // means multicurrency org
                                            if (!currCodeSL.equals(currCodeProd)) {
                                                isValueIgnore = true;
                                            }   
                                        }
                                        if (isValueIgnore) { // now check if its quantity, value or both    
                                            if (checkLimit.Limit_Quantity_vod__c != null) { 
                                                Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], checkLimit, myCall, isValueIgnore);
                                                transactions.add(slT);
                                            } else {
                                                continue;
                                            }
                                        } else {
                                            Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], checkLimit, myCall, false);
                                            transactions.add(slT);
                                        }
                                        if(checkLimit.Limit_Amount_vod__c != null && checkLimit.Disbursed_Amount_vod__c == null ) { 
                                            checkLimit.Disbursed_Amount_vod__c = 0.0; 
                                        }
                                        if (checkLimit.Disbursed_Quantity_vod__c == null) {
                                            checkLimit.Disbursed_Quantity_vod__c = 0;
                                        }
                                        if (checkLimit.Limit_Per_Call_vod__c == false) {
                                            checkLimit.Disbursed_Quantity_vod__c += cRow[k].Quantity_vod__c;
                                            if(checkLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {
                                                checkLimit.Disbursed_Amount_vod__c += cRow[k].Amount_vod__c;
                                            }
                                        }
                                        checkLimit.Disable_Txn_Create_vod__c = true;
                                        updateMap.put(checkLimit.Id,checkLimit);
                                    } else {
                                        System.debug ('myLimit=' + myLimit);
                                        // check the currencies and continue is its not same
                                        if (currCodeSL != null && currCodeProd != null) { // means multicurrency org
                                            if (!currCodeSL.equals(currCodeProd)) {
                                                isValueIgnore = true;
                                            }   
                                        }
                                        if (isValueIgnore) { // now check if its quantity, value or both 
                                            if (myLimit.Limit_Quantity_vod__c != null) { 
                                                Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], myLimit, myCall, isValueIgnore);
                                                transactions.add(slT);
                                            } else {
                                                continue;
                                            }
                                        } else {
                                            Sample_Limit_Transaction_vod__c slT = VOD_CALL2_CHILD_COMMON.createTransactionRecord ( cRow[k], myLimit, myCall, false);
                                            transactions.add(slT);
                                        }
                                        if (myLimit.Disbursed_Quantity_vod__c == null) {
                                            myLimit.Disbursed_Quantity_vod__c = 0; 
                                        } 
                                        if (myLimit.Limit_Amount_vod__c != null && myLimit.Disbursed_Amount_vod__c == null) {
                                            myLimit.Disbursed_Amount_vod__c = 0.0;
                                        }                                      
                                        if (myLimit.Limit_Per_Call_vod__c == false) {
                                            myLimit.Disbursed_Quantity_vod__c +=cRow[k].Quantity_vod__c;                                            
                                            if (myLimit.Limit_Amount_vod__c != null && cRow[k].Amount_vod__c != null && !isValueIgnore) {
                                                myLimit.Disbursed_Amount_vod__c +=cRow[k].Amount_vod__c;
                                            }
                                        }
                                        myLimit.Disable_Txn_Create_vod__c = true;
                                        updateMap.put(myLimit.Id,myLimit);
                                    }   
                                }
                             }
                         }
                      }
                  }
               }
           }
           
           if (transactions.size() > 0) {
            insert transactions;
           }
           if (updateMap.size() > 0) {
                update  updateMap.values();
           }
        
      }
}