/**
 *
 * Prevents triggers from executing recursively
 *
 * Currently used for the BI Preferred flag trigger
 *
 * Author: Raphael Krausz <raphael.krausz@veevasystems.com>
 * Created date: 2013-03-28
 *
 * See: http://www.salesforce.com/docs/developer/cookbook/Content/apex_controlling_recursive_triggers.htm
 *
 */

public class TriggerRecursionHelper {

    private static boolean BiPreferredTriggerStarted = false;

    public static boolean hasBiPreferredTriggerStarted() {
        return BiPreferredTriggerStarted;
    }

    // By setting the variable to true, it maintains this  
    
    // new value throughout the duration of the request  
    
    // (or testMethod)  
    
    public static void setBiPreferredTriggerStarted() {
        BiPreferredTriggerStarted = true;
    }

}