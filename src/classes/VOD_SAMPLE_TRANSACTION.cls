public class VOD_SAMPLE_TRANSACTION {
  
    public static RecordType [] recType  = [ Select Id, Name from RecordType where SobjectType = 'Sample_Transaction_vod__c'  and  (Name ='Receipt_vod' or Name = 'Transfer_vod')];
    private static boolean updateGroup = true;
            
    public static boolean getUpdateGroup () {
        return updateGroup;
    }
    public static void setUpdateGroup (boolean bVal) {
        updateGroup = bVal;
    }
    
    private static testMethod void testUpdateGroup() {
        setUpdateGroup(true);
        System.assert(getUpdateGroup() == true);
        setUpdateGroup(false);
        System.assert(getUpdateGroup() == false);
    }
    
}