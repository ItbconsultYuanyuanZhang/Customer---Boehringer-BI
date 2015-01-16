global class preRunSOQL_BI implements Schedulable {
    global void execute(SchedulableContext sc) {

        Set<Id> call2Set = new Set<ID> { '00Dd0000000fR5VEAU', '00DU0000000YDvNMAW' };
        Set<Id> medicalEventSet = new Set<Id> { '00D90000000nSjPEAU' };


        Id orgId = UserInfo.getOrganizationId();

        if ( call2Set.contains(orgId) ) {
            executeCallQuery();
        }

        if ( medicalEventSet.contains(orgId) ) {
            executeMedicalEventQuery();
        }
    }

    private void executeCallQuery() {

        try {
            List<Call2_vod__c> calls =
                [
                    SELECT Id,
                    OwnerId,
                    Entity_Display_Name_vod__c,
                    Call_Date_vod__c,
                    Expense_Amount_vod__c,
                    Attendee_list_vod__c,
                    Incurred_Expense_vod__c,
                    Expense_Attendee_Type_vod__c,
                    Account_vod__r.Id,
                    Account_vod__r.FirstName,
                    Account_vod__r.LastName,
                    Account_vod__r.PersonTitle,
                    Account_vod__r.IsPersonAccount,
                    Account_vod__r.Primary_Parent_vod__r.Name,
                    Contact_vod__r.Id,
                    Contact_vod__r.FirstName,
                    Contact_vod__r.LastName,
                    Contact_vod__r.Title,
                    User_vod__r.Id,
                    User_vod__r.FirstName,
                    User_vod__r.LastName,
                    User_vod__r.Title,
                    CF__c,
                    CD__c,
                    CE__c,
                    C8__c,
                    CP2__c,
                    CP3__c,
                    City_vod__c,
                    Name,
                    CP1__c,
                    C5__c,
                    C4__c,
                    C1__c,
                    C6__c,
                    Account_vod__r.External_ID_vod__c,
                    Account_vod__r.BI_External_ID_1__c,
                    Account_vod__r.NPI_vod__c,
                    C2__c,
                    C3__c,
                    Always_False__c,
                    Always_Yes__c,
                    (
                        SELECT Id,
                        Expense_Attendee_Type_vod__c,
                        Entity_Display_Name_vod__c,
                        Account_vod__r.Id,
                        Account_vod__r.FirstName,
                        Account_vod__r.LastName,
                        Account_vod__r.PersonTitle,
                        Account_vod__r.IsPersonAccount,
                        Account_vod__r.Primary_Parent_vod__r.Name,
                        Contact_vod__r.Id,
                        Contact_vod__r.FirstName,
                        Contact_vod__r.LastName,
                        Contact_vod__r.Title,
                        User_vod__r.Id,
                        User_vod__r.FirstName,
                        User_vod__r.LastName,
                        User_vod__r.Title,
                        C4__c,
                        C5__c,
                        C1__c,
                        C6__c,
                        Account_vod__r.External_ID_vod__c,
                        Account_vod__r.BI_External_ID_1__c,
                        Account_vod__r.NPI_vod__c,
                        C2__c,
                        C3__c,
                        Always_False__c,
                        Always_Yes__c
                        FROM Call2_vod__r
                        WHERE Incurred_Expense_vod__c = true
                    )
                    FROM Call2_vod__c
                    WHERE Expense_Amount_vod__c > 0
                    AND Expense_Post_Status_vod__c = null
                            AND Parent_Call_vod__c = null
                                    AND Status_vod__c = 'Submitted_vod'
                                            AND LastModifiedDate >= LAST_N_DAYS:5
                ];
        } catch (Exception e) {

        }

    }

    private void executeMedicalEventQuery() {

        try {

            List<Medical_Event_vod__c> medicalEvents =
                [
                    SELECT Id,
                    OwnerId,
                    Name,
                    Start_Date_vod__c,
                    End_Date_vod__c,
                    Expense_Amount_vod__c,
                    HVH_Type_BI__c,
                    Tracking_Number_BI__c,
                    Event_ID_BI__c,
                    Product_BI__r.Name,
                    Description_vod__c,
                    Text_Total_of_Attendees_BI__c,
                    Text_Max_Number_of_Participants_BI__c,
                    (
                        SELECT Id,
                        Expense_Attendee_Type_vod__c,
                        Account_vod__r.Id,
                        Account_vod__r.FirstName,
                        Account_vod__r.LastName,
                        Account_vod__r.PersonTitle,
                        Account_vod__r.Primary_Parent_vod__r.Name,
                        Contact_vod__r.Id,
                        Contact_vod__r.FirstName,
                        Contact_vod__r.LastName,
                        Contact_vod__r.Title,
                        User_vod__r.Id,
                        User_vod__r.FirstName,
                        User_vod__r.LastName,
                        User_vod__r.Title,
                        Account_vod__r.External_ID_vod__c,
                        Medical_Event_vod__r.Always_Yes__c
                        FROM Event_Attendee_vod__r
                        WHERE Incurred_Expense_vod__c = true
                    )
                    FROM Medical_Event_vod__c
                    WHERE Expense_Amount_vod__c > 0
                    AND Expense_Post_Status_vod__c = null
                            AND Submit_Expense_vod__c = true
                                    AND LastModifiedDate >= LAST_N_DAYS:5
                ];

        } catch (Exception e) {

        }

    }

}