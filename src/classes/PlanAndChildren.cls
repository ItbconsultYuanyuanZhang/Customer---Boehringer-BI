/**
 *  PlanAndChildren
 *  Created Date: 18 Feb 2013
 *  Created By: Roman Lerman
 *  Description: This is a model class that displays the plan hierarchy on the PlanViewSummaryPage.
 */
public class PlanAndChildren {
    public Plan_BI__c         plan { get; set; }
    public List<Fund_Request_BI__c> fundRequests { get; set; }
    public List<PlanAndChildren> children { get; set; }

    public PlanAndChildren(Plan_BI__c plan, List<Fund_Request_BI__c> fundRequests) {
        this.plan = plan;
        this.children = new List<PlanAndChildren>();
        this.fundRequests = fundRequests;
    }
}