/*
 * Created By:   Roman Lerman
 * Created Date: 7/13/2012
 * Description:  Unit test for AccountMergeTriggerMVN class.
 */
@isTest
private with sharing class AccountMergeTriggerTestMVN {
    static Account generateAccount(){
        List<RecordType> professionalRecordTypeList = [select Id from RecordType where Name='Professional_vod'];
        
        Id professionalRecordType = null;
        if(professionalRecordTypeList != null && professionalRecordTypeList.size() > 0){
            professionalRecordType = professionalRecordTypeList[0].Id;
        }
        
        Account testAccount = new Account();
        testAccount.FirstName = 'Test';
        testAccount.LastName = 'Professional';
        testAccount.RecordTypeId = professionalRecordType;
        insert testAccount;
        
        return testAccount;
    }
    
    static Account_Territory_Loader_vod__c generateATL(Id accountId, String territoryList){
        Account_Territory_Loader_vod__c atl = new Account_Territory_Loader_vod__c();
        atl.External_Id_vod__c = accountId;
        atl.Account_vod__c = accountId;
        atl.Territory_vod__c = territoryList;
        
        insert atl;
        
        return atl;
    }
    
    static TSF_vod__c generateTSF(Id accountId, String territory, Date lastActivityDate, Integer ytdActivity){
        TSF_vod__c tsf = new TSF_vod__c();
        tsf.Account_vod__c = accountId;
        tsf.Name = territory;
        tsf.Territory_vod__c = territory;
        tsf.Last_Activity_Date_vod__c = lastActivityDate;
        tsf.YTD_Activity_vod__c = ytdActivity;
        insert tsf;
        
        return tsf;
    }
    
    static testMethod void testNoRecordMerge(){        
        Account testAccount = generateAccount();      
        Account testAccount2 = generateAccount();
 
        Test.startTest();
            merge testAccount testAccount2;
        Test.stopTest();
        
        List<TSF_vod__c> tsfs = [select Id, Last_Activity_Date_vod__c, YTD_Activity_vod__c from TSF_vod__c];
        List<Account_Territory_Loader_vod__c> atls = [select Id, Territory_vod__c from Account_Territory_Loader_vod__c];
        
        System.assertEquals(0, tsfs.size());
        System.assertEquals(1, atls.size());
        
        System.debug('ATL TERRITORY: '+atls[0].Territory_vod__c);
        
    }
    static testMethod void testNoLosingRecordMerge(){        
        Account testAccount = generateAccount();
        Account_Territory_Loader_vod__c testAccountATL = generateAtl(testAccount.Id, ';101;102;');
        TSF_vod__c testAccountTSF = generateTSF(testAccount.Id, '101', Date.today()-1, 2);
                
        Account testAccount2 = generateAccount();
         
        Test.startTest();
            merge testAccount testAccount2;
        Test.stopTest();
        
        List<TSF_vod__c> tsfs = [select Id, Last_Activity_Date_vod__c, YTD_Activity_vod__c from TSF_vod__c];
        List<Account_Territory_Loader_vod__c> atls = [select Id, Territory_vod__c from Account_Territory_Loader_vod__c];
        
        System.assertEquals(1, tsfs.size());
        System.assertEquals(1, atls.size());
        
        System.debug('ATL TERRITORY: '+atls[0].Territory_vod__c);
        
        System.assert(atls[0].Territory_vod__c.contains('101'));
        System.assert(atls[0].Territory_vod__c.contains('102'));
        
        System.assertEquals(2, tsfs[0].YTD_Activity_vod__c);
        System.assertEquals(Date.today()-1, tsfs[0].Last_Activity_Date_vod__c);
    }
    static testMethod void testNoWinningRecordMerge(){        
        Account testAccount = generateAccount();
             
        Account testAccount2 = generateAccount();
        Account_Territory_Loader_vod__c testAccount2ATL = generateAtl(testAccount2.Id, ';102;103;');
        TSF_vod__c testAccount2TSF = generateTSF(testAccount2.Id,'101', Date.today(), 2);
        
        Test.startTest();
            merge testAccount testAccount2;
        Test.stopTest();
        
        List<TSF_vod__c> tsfs = [select Id, Last_Activity_Date_vod__c, YTD_Activity_vod__c from TSF_vod__c];
        List<Account_Territory_Loader_vod__c> atls = [select Id, Territory_vod__c from Account_Territory_Loader_vod__c];
        
        System.assertEquals(1, tsfs.size());
        System.assertEquals(1, atls.size());
        
        System.debug('ATL TERRITORY: '+atls[0].Territory_vod__c);
        
        System.assert(atls[0].Territory_vod__c.contains('102'));
        System.assert(atls[0].Territory_vod__c.contains('103'));
        
        System.assertEquals(2, tsfs[0].YTD_Activity_vod__c);
        System.assertEquals(Date.today(), tsfs[0].Last_Activity_Date_vod__c);
    }
    
    static testMethod void testMerge(){     
        Account testAccount = generateAccount();
        Account_Territory_Loader_vod__c testAccountATL = generateAtl(testAccount.Id, ';101;102;');
        TSF_vod__c testAccountTSF = generateTSF(testAccount.Id, '101', Date.today()-1, 2);
                
        Account testAccount2 = generateAccount();
        Account_Territory_Loader_vod__c testAccount2ATL = generateAtl(testAccount2.Id, ';102;103;');
        TSF_vod__c testAccount2TSF = generateTSF(testAccount2.Id,'101', Date.today(), 2);
        
        Test.startTest();
            merge testAccount testAccount2;
        Test.stopTest();
        
        List<TSF_vod__c> tsfs = [select Id, Last_Activity_Date_vod__c, YTD_Activity_vod__c from TSF_vod__c];
        List<Account_Territory_Loader_vod__c> atls = [select Id, Territory_vod__c from Account_Territory_Loader_vod__c];
        
        System.assertEquals(1, tsfs.size());
        System.assertEquals(1, atls.size());
        
        System.debug('ATL TERRITORY: '+atls[0].Territory_vod__c);
        
        System.assert(atls[0].Territory_vod__c.contains('101'));
        System.assert(atls[0].Territory_vod__c.contains('102'));
        System.assert(atls[0].Territory_vod__c.contains('103'));
        
        System.assertEquals(4, tsfs[0].YTD_Activity_vod__c);
        System.assertEquals(Date.today(), tsfs[0].Last_Activity_Date_vod__c);
    }
}