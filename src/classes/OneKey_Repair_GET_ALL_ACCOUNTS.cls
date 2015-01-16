global without sharing class OneKey_Repair_GET_ALL_ACCOUNTS
    implements Database.Batchable<SObject> {

    private List<OneKey_AccountAddress_Repair__c> accountFixes;

    global Database.QueryLocator start(Database.BatchableContext BC) {

        /* For Accounts missing addresses: */

        /* */

        String selStmt =
            'SELECT'
            + '  Id,'
            + '  OK_External_ID_BI__c,'
            + '  Country_Code_BI__c,'
            + '  isPersonAccount'
            + ' FROM Account'
            + ' WHERE Country_Code_BI__c != null'
            + '   AND OK_Status_Code_BI__c = \'Valid\''
            + '   AND OK_External_ID_BI__c LIKE \'W%\''
            + '   AND Id NOT IN (SELECT Account_vod__c FROM Address_vod__c)'
            ;

        /* */


        /* For /all/ OneKey Accounts: */

        /* * /
        String selStmt =
            'SELECT'
            + '  Id,'
            + '  OK_External_ID_BI__c,'
            + '  Country_Code_BI__c,'
            + '  isPersonAccount'
            + ' FROM Account'
            + ' WHERE Country_Code_BI__c != null'
            + '   AND OK_Status_Code_BI__c = \'Valid\''
            + '   AND OK_External_ID_BI__c LIKE \'W%\''
            ;
        /* */

        return Database.getQueryLocator(selStmt);
    }

    global void execute(Database.BatchableContext BC, List<Account> oneKeyAccounts) {

        // accountFixes = new List<OneKey_AccountAddress_Repair__c>();

        for (Account oneKeyAccount : oneKeyAccounts) {
            OneKey_AccountAddress_Repair__c accountFix = new OneKey_AccountAddress_Repair__c(
                Name = oneKeyAccount.OK_External_ID_BI__c,
                Country_Code_BI__c = oneKeyAccount.Country_Code_BI__c,
                //hasBeenCorrected_BI__c = false,
                // This is the default (hasBeenCorrected - false) - not doing this
                // as not to overwrite completed work
                isPersonAccount_BI__c = oneKeyAccount.isPersonAccount
            );

            accountFixes.add(accountFix);
        }

        Database.upsert(accountFixes, OneKey_AccountAddress_Repair__c.Name, true);

    }

    global void finish(Database.BatchableContext BC) {
    }

}