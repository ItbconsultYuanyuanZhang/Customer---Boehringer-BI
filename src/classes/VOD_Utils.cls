public class VOD_Utils {

    public static String toString(Set<String> data, String seperator) {
        String result = '';
        boolean first = true;
        for (String str : data) {
            if (first)
               first = false;
            else
               result += seperator;
            result += str;
        }
        return result;
    }

    private static boolean updateChildAccount = false;
    private static boolean updateAccount = false;
    private static boolean isMergeAccountProcess = false;

    public static boolean getUpdateChildAccount () {
        return updateChildAccount;
    }
    public static void setUpdateChildAccount (boolean bVal) {
        updateChildAccount = bVal;
    }
    public static boolean getUpdateAccount () {
        return updateAccount;
    }
    public static void setUpdateAccount (boolean bVal) {
        updateAccount = bVal;
    }

    //property to see of account merge is in progress
    public static boolean getisMergeAccountProcess () {
        return isMergeAccountProcess;
    }
    public static void setisMergeAccountProcess (boolean bVal) {
        isMergeAccountProcess = bVal;
    }

    public static boolean canModifyAllData () {
        String ProfileId = UserInfo.getProfileId();
        Profile pr = [Select Id, PermissionsModifyAllData From Profile where Id = :ProfileId];
        if (pr != null && pr.PermissionsModifyAllData)
            return true;
        return false;
    }

    private static Set<Id> addresses = new Set<Id> ();
    public static Set<Id> getaddresses() {
        return addresses;
    }

    public static String getAccessibleFieldsSoql(String obj, String whereClause) {
        String sql = '';
        String fieldString = '';
        list<String> fieldList = new list<String>();
        // Get a map of field names for this object type.
        Map<String, Schema.SObjectField> fieldMap =
           Schema.getGlobalDescribe().get(obj.toLowerCase()).getDescribe().fields.getMap();
        if (fieldMap != null)
        {
           // Loop through all fields.
           for (Schema.SObjectField f : fieldMap.values())
           {
              // Describe each field.
              Schema.DescribeFieldResult fd = f.getDescribe();
              // Is this field is queryable? If so, we can query it.
                 // This is the API name.
                 fieldList.add(fd.getName());
           }
        }
        // Sort and assemble field list.
        if (!fieldList.isEmpty())
        {
           fieldList.sort();
           for (string s : fieldList)
           {
              fieldString += s + ',';
           }
        }
        // Strip terminal comma.
        if (fieldString.endsWith(','))
           fieldString = fieldString.substring(0, fieldString.lastIndexOf(','));
        // Assemble SQL statement.
        sql = 'SELECT ' + fieldString + ' FROM ' + obj;
        // Append WHERE clause if present; if ORDER BY or LIMIT are needed,
        // append them to WHERE clause when calling this method.
        if (whereClause != null && whereClause != '')
           sql += ' WHERE ' + whereClause;
        return sql;
   }

   public static boolean isNetworkEnabled() {
   	Integer cnt = [Select count() From Network_Settings_vod__c Where NETWORK_CUSTOMER_MASTER_MODE_vod__c Not In (0, null) Limit 1];
	return cnt > 0;
   }
  	
   public static String quotedOrNull(String value) {
        if (value == null) {
            return 'null';
        }
        return '\'' + value + '\'';
   }
}