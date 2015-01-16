public class VOD_CALL_CHILD_VALIDATE {
        	
        	
        	 static testMethod void test_VOD_CALL_CHILD_VALIDATE () {
        		String callID = '@test@';
        		String nullValue = null;
        		System.assertEquals(false,isValidCallID(''));
        		System.assertEquals(false,isValidCallID('null'));
        		System.assertEquals(false,isValidCallID(nullValue));
        		System.assertEquals(false,isValidCallID(callID));
        		System.assertEquals(true,isValidCallID('12345'));
        			 	
        	 }
        	
        	
           public static boolean isValidCallID (String CallID)  {
           	
           	
           if (CallID == null ||CallId =='' ||  CallID =='null' || (CallID.startsWith('@') && CallID.endsWith('@')))
        		return false;
        		
        	return true; 
        	}
        	
        
        }