/**
 * The trigger only activates if the DCR is approved, that can only be done manually, so it only handles
 * one record, not batches.
 *
 * Modified by: Raphael Krausz <raphael.krausz@veeva.com>
 * Date:        2014-10-15
 * Description:
 *   Status_BI__c is now 'Active' for new accounts
 *
 *
 * Modified by: Raphael Krausz <raphael.krausz@veeva.com>
 * Date:        2014-10-30
 * Description:
 *   Changed the trigger from "after update" to "before update".
 *   This was causing problems, as exceptions generated here were still allowing the DCR record
 *   to be saved as approved ("Verified" status) but the work wasn't done.
 *
 *
 * Modified by: Raphael Krausz <raphael.krausz@veeva.com>
 * Date:        2014-10-31
 * Description:
 *   Changed the error handling.
 *   Exceptions thrown in the approval process are caught, the DCR is rejected
 *   and the reason placed in the comments section.
 *
 *
 * Modified by: Raphael Krausz <raphael.krausz@veeva.com>
 * Date:        2014-12-04
 * Description:
 *   Changed the error handling.
 *   ALL exceptions thrown in the approval process are caught, the DCR is rejected
 *   and the reason placed in the comments section.
 *
 *
 * Modified by: Raphael Krausz <raphael.krausz@veeva.com>
 * Date:        2014-12-08
 * Description:
 *      Ensured ChildAccounts are clear and configured correctly before inserting
 *      into database. (Bug resolved.)
 *
 * Modified by: Raphael Krausz <raphael.krausz@veeva.com>
 * Date:        2014-12-08
 * Description:
 *      Existing professional at New Workplace now also creates an address
 *      for the HCP.
 *
 * Modified by: Raphael Krausz <raphael.krausz@veeva.com>
 * Date:        2014-12-10
 * Description:
 *      Fixed bug (nullSystemException) - caused by calling 
 *      childAccount.Primary_vod__c.equalsIgnoreCase(..) when Primary_vod__c was null
 *      (Was in determining primary address)
 *
 */

trigger VEEVA_BI_DCR_Approve_DS on V2OK_Data_Change_Request__c (before update) {
    system.debug('Starting VEEVA_BI_DCR_Approve_DS');




    V2OK_Data_Change_Request__c dataChangeRequest = Trigger.new[0];

    // ENTRY CRITERIA
    //(record is approved)
    if (dataChangeRequest.Status__c != 'Verified') {
        system.debug('Skipping record, not verified / final approved.');
        return;
    }


    // BASIC DEFINITION
    Account HCP = new Account();
    Account HCO = new Account();
    Child_Account_vod__c CA = new Child_Account_vod__c();
    Address_vod__c ADDR = new Address_vod__c();

    // OBJECT PROCESSING

    //get rectype
    String RTdevname = '';
    RTdevname = [SELECT DeveloperName FROM RecordType WHERE Id = :dataChangeRequest.RecordTypeId LIMIT 1].DeveloperName;
    if (RTdevname.contains('DataSteward') != true) {
        system.debug('Not a DataSteward record, returning.');
        return;
    }
    system.debug('Its alive!');
    //DEFINE OBJECT MAPPING BASED ON THE CUSTOM SETTING
    DCR_Mapping__c Mapping = DCR_Mapping__c.getInstance();
    Map <String, Schema.SObjectField> Setting = Schema.getGlobalDescribe().get('DCR_Mapping__c').getDescribe().fields.getMap();

    for (Schema.SObjectField sfield : Setting.Values()) {
        String DCRfname = sfield.getDescribe().getName();
        //System.debug('DCRfield: '+ sfield.getDescribe());

        if (DCRfname == 'CreatedById' ||
                DCRfname == 'CreatedDate' ||
                DCRfname == 'CurrencyIsoCode' ||
                DCRfname == 'IsDeleted' ||
                DCRfname == 'IsLocked' ||
                DCRfname == 'LastModifiedById' ||
                DCRfname == 'LastModifiedDate' ||
                DCRfname == 'SetupOwnerId' ||
                DCRfname == 'MayEdit' ||
                DCRfname == 'Name' ||
                DCRfname == 'Id' ||
                DCRfname == 'SystemModstamp') continue;

        String value = (String) Mapping.get(DCRfname);

        if (value != null) {
            String obj = value.substringBefore('.');
            String field = value.substringAfter('.');
            system.debug('dataChangeRequest field: ' + DCRfname + ' field: ' + field + ' object: ' + obj + ' field value: ' + dataChangeRequest.get(DCRfname) + ' source field type: ' + sfield.getDescribe().getType());

            if (obj == 'HCP' || obj == 'ACC')
                HCP.put(field, dataChangeRequest.get(DCRfname));
            if (obj == 'HCO' || obj == 'ACC') {
                if (field == 'RecordTypeId' && dataChangeRequest.get(DCRfname) == null) continue; //skip null recordtype assingment
                HCO.put(field, dataChangeRequest.get(DCRfname));
            }

            if (obj == 'CA')
                CA.put(field, dataChangeRequest.get(DCRfname));

            if (obj == 'ADDR')
                ADDR.put(field, dataChangeRequest.get(DCRfname));
        } else {
            dataChangeRequest.addError( 'The dataChangeRequest mapping custom settings are missing values for this profile (or in general).');
        }
    }

    // New accounts must be marked as Active
    // Raphael 2014-10-15
    if ( RTdevname.containsIgnoreCase('New_Workplace') ) {
        HCO.Status_BI__c = 'Active';
    }

    if ( RTdevname.containsIgnoreCase('New_Professional') ) {
        HCP.Status_BI__c = 'Active';
    }

    if (RTdevname == 'Workplaces_DataSteward_BI') {
        if (dataChangeRequest.Change_Type__c == 'Create') {
            HCO.Status_BI__c = 'Active';
        }
    }
    // End new accounts must be marked as Active 2014-10-15


    // EXTRA FIELDS THAT CAN'T BE CONFIGURED
    /*
    BI_Preferred_Address_BI__c
    Do_Not_Mail_BI__c
    Do_Not_Phone_BI__c
    */
    if (ADDR.BI_Preferred_Address_BI__c != true)ADDR.BI_Preferred_Address_BI__c = false;
    if (HCP.Do_Not_Phone_BI__c != true)HCP.Do_Not_Phone_BI__c = false;
    if (HCP.Do_Not_Mail_BI__c != true)HCP.Do_Not_Mail_BI__c = false;
    HCP.BI_Maintained_BI__c = true;
    HCO.BI_Maintained_BI__c = true;

    system.debug('RT: ' + RTdevname);
    // DECIDE WHAT TO DO ACCORDING TO RECORDTYPE

    try {
        if (RTdevname == 'Professional_Update_Delete_DataSteward_BI') {
            //upsert hcp, ca and addr
            //delete person, ca
            if (dataChangeRequest.Change_Type__c == 'Create') {
                try {
                    insert hcp;
                } catch (Exception e) {
                    String message = 'The HCP could not be inserted, probably it already exists. ';
                    dataChangeRequest.addError(message + e);
                }

                //CA.Child_Account_vod__c =HCP.Id;
                //upsert ca;
                Address_vod__c ADDR2 = new Address_vod__c();
                ADDR2 = ADDR.clone();
                ADDR2.Account_vod__c = HCP.Id;
                insert ADDR2;
            } else if (dataChangeRequest.Change_Type__c == 'Update') {
                upsert hcp;
                System.debug('ADDR acc: ' + ADDR.Account_vod__c + ' HCP.Id: ' + HCP.Id );
                if (dataChangeRequest.Address__c == null) {
                    Address_vod__c ADDR2 = new Address_vod__c();
                    ADDR2 = ADDR.clone();
                    ADDR2.Account_vod__c = HCP.Id;
                    insert ADDR2;
                } else {
                    update addr;
                }
            } else if (dataChangeRequest.Change_Type__c == 'Delete' || dataChangeRequest.Change_Type__c == 'Inactivate' || dataChangeRequest.Change_Type__c == 'Deactivate') {
                HCP.Status_BI__c = 'Inactive';
                HCP.OK_Status_Code_BI__c = 'Invalid';
                update hcp;
                //delete hcp;
            }
        } else if (RTdevname == 'Workplaces_DataSteward_BI') {
            //upsert hco and addr
            //delete hco, addr
            if (dataChangeRequest.Change_Type__c == 'Create') {
                upsert hco;
                //upsert ca;
                Address_vod__c ADDR2 = new Address_vod__c();
                ADDR2 = ADDR.clone();
                ADDR2.Account_vod__c = HCO.Id;
                insert ADDR2;
            } else if (dataChangeRequest.Change_Type__c == 'Update') {
                upsert hco;
                if (dataChangeRequest.Address__c == null) {
                    Address_vod__c ADDR2 = new Address_vod__c();
                    ADDR2 = ADDR.clone();
                    ADDR2.Account_vod__c = HCO.Id;
                    insert ADDR2;
                } else {
                    update addr;
                }
            } else if (dataChangeRequest.Change_Type__c == 'Delete' || dataChangeRequest.Change_Type__c == 'Deactivate') {
                HCO.Status_BI__c = 'Inactive';
                HCO.OK_Status_Code_BI__c = 'Invalid';
                HCO.Specialty3_BI__c = null;
                update hco;
                //delete hcp;
            }
        } else if (RTdevname == 'New_Professional_at_Existing_Workplace_DataSteward_BI') {
            //insert hcp, ca and addr to hcp

            insert hcp;

            Child_Account_vod__c childAccount = CA.clone();
            childAccount.Id = null;
            childAccount.Parent_Account_vod__c = dataChangeRequest.Organisation_Account__c;
            childAccount.Child_Account_vod__c = HCP.Id;
            insert childAccount;

            Address_vod__c hcpAddress = ADDR.clone();
            hcpAddress.Account_vod__c = HCP.Id;

            Boolean isPrimary = hcpAddress.BI_Preferred_Address_BI__c;
            if ( ! String.isBlank(childAccount.Primary_vod__c) ) {
                if ( childAccount.Primary_vod__c.equalsIgnoreCase('Yes') ) {
                    isPrimary = true;
                }
            }

            if (isPrimary == null) {
                isPrimary = false;
            }

            hcpAddress.Primary_vod__c = isPrimary;
            insert hcpAddress;
            //dataChangeRequest.Professional_DS__c = HCP.Id;


        } else if (RTdevname == 'New_Professional_at_New_Workplace_DataSteward_BI') {
            //insert hcp, hco, ca and addr to both
            insert hcp;
            insert hco;

            Child_Account_vod__c childAccount = CA.clone();
            childAccount.Id = null;
            childAccount.Child_Account_vod__c = HCP.Id;
            childAccount.Parent_Account_vod__c = HCO.Id;
            insert childAccount;

            System.debug('CA inserted');

            Address_vod__c hcpAddress = ADDR.clone();
            hcpAddress.Account_vod__c = HCP.Id;

            Boolean isPrimary = hcpAddress.BI_Preferred_Address_BI__c;
            if ( ! String.isBlank(childAccount.Primary_vod__c) ) {
                if ( childAccount.Primary_vod__c.equalsIgnoreCase('Yes') ) {
                    isPrimary = true;
                }
            }

            if (isPrimary == null) {
                isPrimary = false;
            }

            hcpAddress.Primary_vod__c = isPrimary;
            insert hcpAddress;
            System.debug('ADDR1 inserted');

            Address_vod__c ADDR2 = new Address_vod__c();
            ADDR2 = ADDR.clone();
            ADDR2.Account_vod__c = HCO.Id;
            insert ADDR2;
            System.debug('ADDR2 inserted');
            //dataChangeRequest.Professional_DS__c = HCP.Id;
            //dataChangeRequest.Organisation_Account__c  = HCO.Id;
        } else if (RTdevname == 'Existing_Professional_at_New_Workplace_DataSteward_BI') {
            //insert hco, ca and addr to hco
            insert hco;


            Child_Account_vod__c childAccount = CA.clone();
            childAccount.Id = null;
            childAccount.Child_Account_vod__c = dataChangeRequest.Professional_DS__c;
            childAccount.Parent_Account_vod__c = HCO.Id;
            insert childAccount;

            Address_vod__c ADDR2 = new Address_vod__c();
            ADDR2 = ADDR.clone();
            ADDR2.Account_vod__c = HCO.Id;
            insert ADDR2;

            Address_vod__c hcpAddress = ADDR2.clone();
            hcpAddress.Account_vod__c = HCP.Id;

            Boolean isPrimary = hcpAddress.BI_Preferred_Address_BI__c;
            if ( ! String.isBlank(childAccount.Primary_vod__c) ) {
                if ( childAccount.Primary_vod__c.equalsIgnoreCase('Yes') ) {
                    isPrimary = true;
                }
            }
            if (isPrimary == null) {
                isPrimary = false;
            }
            hcpAddress.Primary_vod__c = isPrimary;
            insert hcpAddress;

        } else if (RTdevname == 'Hierarchy_DataSteward_BI') {
            //upsert ca
            //delete ca
            if (dataChangeRequest.Change_Type__c == 'Create') {
                if (dataChangeRequest.Organisation_Account__c == null && dataChangeRequest.Professional_DS__c == null ) {
                    String message = 'The Child account record to be updated does not exists, or the process was not started from an account button.';
                    dataChangeRequest.addError(message);
                }

                Child_Account_vod__c CA2 = new Child_Account_vod__c();
                CA2 = CA.clone();
                CA2.Child_Account_vod__c = dataChangeRequest.Professional_DS__c;
                CA2.Parent_Account_vod__c = dataChangeRequest.Organisation_Account__c;
                CA2.External_id_vod__c = dataChangeRequest.Organisation_Account__c + '__' + dataChangeRequest.Professional_DS__c;
                upsert CA2 External_id_vod__c;
                /*
                Address_vod__c ADDR2 = new Address_vod__c();
                ADDR2 = ADDR.clone();
                ADDR2.Account_vod__c = HCP.Id;
                insert ADDR2;
                */
            } else if (dataChangeRequest.Change_Type__c == 'Update') {
                if (dataChangeRequest.Organisation_Account__c == null && dataChangeRequest.Professional_DS__c == null ) {
                    String message = 'The Child account record to be updated does not exists, or the process was not started from an account button.';
                    dataChangeRequest.addError(message);
                } else {

                    CA.Child_Account_vod__c = dataChangeRequest.Professional_DS__c;
                    CA.Parent_Account_vod__c = dataChangeRequest.Organisation_Account__c;

                    CA.External_id_vod__c = dataChangeRequest.Organisation_Account__c + '__' + dataChangeRequest.Professional_DS__c;
                    CA.Id = null;
                    upsert ca External_id_vod__c;
                }
            } else if (dataChangeRequest.Change_Type__c == 'Delete' || dataChangeRequest.Change_Type__c == 'Inactivate') {
                if (dataChangeRequest.Organisation_Account__c == null && dataChangeRequest.Professional_DS__c == null ) {
                    String message = 'The Child account record to be updated does not exists, or the process was not started from an account button.';
                    dataChangeRequest.addError(message);
                } else {
                    string extId = dataChangeRequest.Organisation_Account__c + '__' + dataChangeRequest.Professional_DS__c;
                    delete [SELECT Id FROM Child_Account_vod__c WHERE External_id_vod__c = :extId ];
                    //CA.OK_Process_Code_BI__c = 'D';
                    //upsert ca External_id_vod__c;
                } //delete ca;
            }
        } else {
            System.debug('Unknown DCR record type (' + dataChangeRequest.RecordTypeId + ')');
            dataChangeRequest.addError('The Record type (' + dataChangeRequest.RecordtypeId + ') is not valid for approval.');
        }
    } catch (Exception e) {
        dataChangeRequest.addError('An error occurred trying to process the Data Change Request. ' + e);
    }
}