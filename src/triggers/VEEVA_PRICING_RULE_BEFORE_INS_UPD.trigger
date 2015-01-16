trigger VEEVA_PRICING_RULE_BEFORE_INS_UPD on Pricing_Rule_vod__c (before insert, before update) {
    if (VOD_ORDER_CAMPAIGN_TRIG.getCampaignTrig() == true)
        return;
    List <String> externalIds = new List<String> ();
    RecordType recTypeListPrice;
    RecordType recTypePayment;
    for (RecordType recType : [Select Id, Name from RecordType where SobjectType = 'Pricing_Rule_vod__c' and Name in ('List_Price_Rule_vod', 'Payment_Terms_Rule_vod')]) {
        if (recType.Name == 'List_Price_Rule_vod')
            recTypeListPrice = recType;
        else
            recTypePayment = recType;
    }

    for (Pricing_Rule_vod__c pr : Trigger.new) {
        if(Trigger.isUpdate){
            if(pr.Order_Campaign_vod__c != null){
                Order_Campaign_vod__c theCampaign =[select Start_Date_vod__c, End_Date_vod__c from Order_Campaign_vod__c where Id=:pr.Order_Campaign_vod__c];
                if(theCampaign != null
                   &&(pr.Start_Date_vod__c != theCampaign.Start_Date_vod__c
                      || pr.End_Date_vod__c != theCampaign.End_Date_vod__c)){
                          pr.Id.addError(System.Label.INCONSISTENT_DATE_ERROR, false);
                          return;
                      }
            }
        }else if(Trigger.isInsert){
            if(pr.Order_Campaign_vod__c != null){
                Order_Campaign_vod__c theCampaign =[select Start_Date_vod__c, End_Date_vod__c from Order_Campaign_vod__c where Id=:pr.Order_Campaign_vod__c];
                if(theCampaign != null){
                    pr.Start_Date_vod__c = theCampaign.Start_Date_vod__c;
                    pr.End_Date_vod__c = theCampaign.End_Date_vod__c;
                }
            }
        }

        if(pr.RecordTypeId == recTypeListPrice.Id) {
            pr.Quantity_Max_vod__c = null;
            pr.Quantity_Min_vod__c = null;
            pr.Comparison_Type_vod__c = null;
        }
        else if(pr.Quantity_Max_vod__c == null && pr.Quantity_Min_vod__c == null){
            pr.Id.addError(System.Label.QUANTITY_ERROR, false);
            return;
        }

        // limits on kit
        Id product = pr.Product_vod__c;
        if (product != null && ![Select Id from Product_vod__c where Product_Type_vod__c = 'Kit Item' and Parent_Product_vod__c = :product limit 1].isEmpty())
        {
            if (pr.Cross_Product_Rule_vod__c || pr.RecordTypeId == recTypeListPrice.Id || pr.Comparison_Type_vod__c != 'Product Quantity') {
                pr.Id.addError(System.Label.Kit_Type_Error, false);
                return;
            }
        }

        product = pr.Comparison_Product_vod__c;
        if (product != null && pr.Comparison_Type_vod__c != 'Product Quantity' && ![Select Id from Product_vod__c where Product_Type_vod__c = 'Kit Item' and Parent_Product_vod__c = :product limit 1].isEmpty()){
            pr.Id.addError(System.Label.Kit_Type_Error, false);
            return;
        }

        SObject prInterface = (SObject)pr;
        String Currcode  = '';

        try {
            Currcode  = (String)prInterface.get('CurrencyIsoCode');
        } catch ( System.SObjectException e) {
        }
        // Create an external ID.
        pr.External_Id_vod__c = pr.RecordTypeId + '__';
        if (pr.RecordTypeId != recTypePayment.Id)
            pr.External_Id_vod__c += pr.Comparison_Type_vod__c + '__';
        pr.External_Id_vod__c += Currcode +'__'+
            pr.Product_vod__c + '__' +
            pr.Account_vod__c+ '__' +
            pr.Account_Group_vod__c +'__' +
            pr.Order_Campaign_vod__c +'__'+
            pr.Pricing_Group_vod__c +'__' +
            pr.Comparison_Product_vod__c + '__' +
            pr.Cross_Product_Rule_vod__c + '__' +
            pr.Contract_vod__c;

        externalIds.add(pr.External_Id_vod__c);
    }
    Map <String, List<VEEVA_PRICE_RULE_CLASS>> priceList = new Map <String, List<VEEVA_PRICE_RULE_CLASS>> ();

    for (Pricing_Rule_vod__c checkPr : [SELECT External_Id_vod__c,
                                        Quantity_Min_vod__c,
                                        Quantity_Max_vod__c,
                                        Start_Date_vod__c,
                                        End_Date_vod__c
                                        FROM Pricing_Rule_vod__c where External_Id_vod__c in :externalIds
                                        AND ID not in :Trigger.new]) {

                                            List <VEEVA_PRICE_RULE_CLASS> myList = priceList.get(checkPr.External_Id_vod__c);
                                            if (myList == null)
                                                myList = new List<VEEVA_PRICE_RULE_CLASS> ();
                                            VEEVA_PRICE_RULE_CLASS vprc = new VEEVA_PRICE_RULE_CLASS (checkPr.External_Id_vod__c,
                                                                                                      checkPr.Quantity_Min_vod__c,
                                                                                                      checkPr.Quantity_Max_vod__c,
                                                                                                      checkPr.Start_Date_vod__c,
                                                                                                      checkPr.End_Date_vod__c);
                                            myList.add(vprc);

                                            priceList.put(checkPr.External_Id_vod__c, myList);

                                        }

    for (Pricing_Rule_vod__c pr : Trigger.new) {
        List <VEEVA_PRICE_RULE_CLASS> checkList = priceList.get(pr.External_Id_vod__c);

        // No rows in DB.
        if (checkList == null || checkList.size() == 0)
            continue;

        for (VEEVA_PRICE_RULE_CLASS cVprc : checkList) {
            if ((pr.Start_Date_vod__c >= cVprc.Start_date && pr.Start_Date_vod__c <= cVprc.End_date) ||
                (cVprc.Start_date >= pr.Start_Date_vod__c && cVprc.Start_date <= pr.End_Date_vod__c)) {
                    if(cVprc.Min_val == null){ //existing rule has a open qtyMin
                        if(pr.Quantity_Min_vod__c == null || pr.Quantity_Min_vod__c < cVprc.Max_val){
                            pr.Id.addError(System.Label.OVERLAP_ERROR, false);
                            break;
                        }
                    }else if(cVprc.Max_val == null){ //existing has a open qtyMax
                        if(pr.Quantity_Max_vod__c == null || pr.Quantity_Max_vod__c > cVprc.Min_val){
                            pr.Id.addError(System.Label.OVERLAP_ERROR, false);
                            break;
                        }
                    }
                    if(pr.Quantity_Min_vod__c == null){
                        if(cVprc.Min_val < pr.Quantity_Max_vod__c){ //new rule has open qtyMin
                            pr.Id.addError(System.Label.OVERLAP_ERROR, false);
                            break;
                        }
                    }else if(pr.Quantity_Max_vod__c == null){
                        if(cVprc.Max_val > pr.Quantity_Min_vod__c){ //new rule has open qtyMax
                            pr.Id.addError(System.Label.OVERLAP_ERROR, false);
                            break;
                        }
                    }
                    if (pr.Quantity_Min_vod__c > cVprc.Min_val && pr.Quantity_Min_vod__c < cVprc.Max_val) {
                        pr.Id.addError(System.Label.OVERLAP_ERROR, false);
                        break;
                    }
                    if (pr.Quantity_Max_vod__c > cVprc.Min_val && pr.Quantity_Max_vod__c < cVprc.Max_val) {
                        pr.Id.addError(System.Label.OVERLAP_ERROR, false);
                        break;
                    }
                    if (pr.Quantity_Min_vod__c == cVprc.Min_val || pr.Quantity_Max_vod__c == cVprc.Max_val) {
                        pr.Id.addError(System.Label.OVERLAP_ERROR, false);
                        break;
                    }
                }
        }
    }
}