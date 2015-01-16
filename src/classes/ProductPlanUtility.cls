/**
 *  ProductPlanUtility
 *  Created By: Roman Lerman
 *  Created Date: 11 FEB 2013
 *  Description: This class performs all of the without sharing tasks for the PlanViewSummaryControllerPMBI class (retrieving, creating, and updating fund requests).
 *               This is necessary because of the sharing structure in the org.
 * 
 */
public without sharing class ProductPlanUtility{
    public static List<Plan_BI__c> getProductPlans(String selectedPlanYear) {
        return [select Id, Name from Plan_BI__c where Plan_Year_BI__c = :selectedPlanYear 
            and Type_BI__c =: System.Label.BI_GLOBAL_PRODUCT_NAME];
    }
    
    public static List<Fund_Request_BI__c> sortFundRequests(List<Fund_Request_BI__c> fundRequestList){
        List<Fund_Request_BI__c> sortedList = new List<Fund_Request_BI__c>();
        List<Fund_Request_BI__c> toAddLater = new List<Fund_Request_BI__c>();

        for(Fund_Request_BI__c first : fundRequestList) {
            if(first.Approver_BI__c == UserInfo.getUserId() && Config_Settings_PMBI__c.getOrgDefaults().Fund_Request_Working_Status__c.contains(first.Status__c)) {
                sortedList.add(first);
            } else {
                toAddLater.add(first);
            }
        }
        
        sortedList.addAll(toAddLater);
        
        return sortedList;
    }

    public static void saveFundRequest(String amountRequested, String details, Id planId, Id approverId){  
       Fund_Request_BI__c fundRequest = new Fund_Request_BI__c(Amount_Requested__c = convertToNumber(amountRequested), Details__c = details, Plan__c = planId, Approver_BI__c = approverId);
       insert fundRequest;
       
       // In the unlikely event that the Owner of the Fund Request and the Owner of the associated Plan is the same the
       // code below will error, which is ok since it means the user already had access to the fund request
       try{
            Fund_Request_BI__Share fundRequestShare = new Fund_Request_BI__Share();
            fundRequestShare.ParentId = fundRequest.Id;
            fundRequestShare.UserOrGroupId = approverId;
            fundRequestShare.AccessLevel = Config_Settings_PMBI__c.getOrgDefaults().Access_Level_Edit__c;

            insert fundRequestShare;
        }catch(Exception e){
            System.debug('Fund Request Sharing Exception: '+e.getMessage());
        }
    }
    
    public static void updateFundRequest(Id fundRequestId, String amountGranted, String status){ 
        Fund_Request_BI__c fundRequest = new Fund_Request_BI__c(Id=fundRequestId, Amount_Granted__c = convertToNumber(amountGranted), Status__c = status);  
        update fundRequest;
    }
    
    class InvalidNumberException extends Exception{}
    
    public static Long convertToNumber(String amt){
        Long amount;
        if(amt == null || amt == ''){
            amount = 0;
        }else{
            try {
                 amount = Long.valueOf(amt);
            }catch(Exception e){
                throw new InvalidNumberException(System.Label.BI_NUMBER_EXCEPTION);
            }
        }
        
        return amount;
    }
}