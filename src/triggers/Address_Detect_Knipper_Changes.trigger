trigger Address_Detect_Knipper_Changes on Address_vod__c (before insert,before update) {   
      
    for (Address_vod__c a : trigger.new) {
     if (a.Country_Code_BI__c == 'US') {
            if (Trigger.isInsert) {
                a.Addressmodstamp__c = system.now();
            }
            else {
                if (trigger.oldmap.get(a.id).Name != a.Name) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).Address_line_2_vod__c != a.Address_line_2_vod__c) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).City_vod__c != a.City_vod__c) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).State_vod__c != a.State_vod__c) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).Zip_vod__c != a.Zip_vod__c) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).Zip_4_vod__c != a.Zip_4_vod__c) {
                    a.Addressmodstamp__c = system.now(); 
                } else if (trigger.oldmap.get(a.id).Primary_vod__c != a.Primary_vod__c) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).DEA_vod__c != a.DEA_vod__c) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).DEA_Status_vod__c != a.DEA_Status_vod__c) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).DEA_Expiration_Date_vod__c != a.DEA_Expiration_Date_vod__c) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).License_vod__c != a.License_vod__c) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).License_Expiration_Date_vod__c != a.License_Expiration_Date_vod__c) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).License_Status_vod__c != a.License_Status_vod__c) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).Phone_vod__c != a.Phone_vod__c) {
                    a.Addressmodstamp__c = system.now();
                } else if (trigger.oldmap.get(a.id).Fax_vod__c != a.Fax_vod__c) {
                    a.Addressmodstamp__c = system.now();
                }
            }
         }
      }
            }