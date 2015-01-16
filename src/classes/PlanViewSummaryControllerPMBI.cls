/**
 *  PlanViewSummaryControllerPMBI
 *  @author: John M Daniel john@mavensconsulting.com
 *  Created Date: 17 JAN 2013
 *  Description: This controller handles all aspects of the display of the PlanViewSummaryPMBI page. 
 *
 */
public with sharing class PlanViewSummaryControllerPMBI 
{
    public static final string PLAN_ID_PARAM = 'id';
    
    public Integer currentLevelAdd = 1;

    public List<PlanAndChildren> topLevelPlans { get; set; } { topLevelPlans = new List<PlanAndChildren>(); }
    // The series of plans that are the parent hierarchy to the current plan.
    //public list<PlanHierarchyModelPMBI> planHierarchy { get; private set; } { planHierarchy = new list<PlanHierarchyModelPMBI>(); }
    public List<Plan_BI__c> parentPlanHierarchy { get; private set; } { parentPlanHierarchy = new List<Plan_BI__c>(); }
    
    public string selectedPlanYear { get; set; } 
    { 
        if ( ApexPages.currentPage().getParameters().containsKey('year') ) {
            selectedPlanYear = ApexPages.currentPage().getParameters().get('year');
        } else {
            selectedPlanYear = string.valueOf(date.today().year());    
        }
    } 
    
    public PlanViewSummaryControllerPMBI getThis() { return this;}
    
    public Map<Id, UserRecordAccess> accessMap { get; set; } {}

    public list<SelectOption> planYearsAvailable { get; set; } 
    { 
        planYearsAvailable = new list<SelectOption>();
        
        Integer start = Date.today().year() - Config_Settings_PMBI__c.getOrgDefaults().Year_Range__c.intValue();
        Integer finish = Date.today().year() + Config_Settings_PMBI__c.getOrgDefaults().Year_Range__c.intValue();
        for(Integer x = start; x <= finish; x++){
            planYearsAvailable.add(new SelectOption(String.valueOf(x), String.valueOf(x)));
        }
    }
    
    public String amountRequested{ get; set; }
    public String details{ get; set; }
    public Id planId{ get; set; }
    public Id fundRequestId{ get; set; }
    public String amountGranted{ get; set; }
    public String status { get; set; }
    public List<Plan_BI__c> planOptions { get; set; }
    public String selectedPlan { get; set; }
    public List<Fund_Request_BI__c> productFundRequests { get; set; }
    public String userIsoCode {get; set;}   
    public Map<Id, List<Plan_BI__c>> subplans = null;
    
    public PageReference redirect(){
        String id = ApexPages.currentPage().getParameters().get('id');
        String url = '/apex/PlanViewSummaryPMBI';
        if(id != null && id != ''){
            url += '?id='+id;
        }
        
        PageReference planView = new PageReference(url);
        planView.setRedirect(true);
        
        return planView;
    }
    
    public List<SelectOption> getStatusOptions()
    {
        
        final list<SelectOption> options = new list<SelectOption>();
        
        for (Schema.PicklistEntry pe : Fund_Request_BI__c.Status__c.getDescribe().getPicklistValues())
        {
            options.add(new SelectOption(pe.getValue(), pe.getLabel()));
        }
        
        return options;
    }
    
    public PageReference saveFundRequest(){
         
        try{    
            ProductPlanUtility.saveFundRequest(amountRequested, details, planId, tempPlanOwnerId);
        } catch(Exception e){
            errorMessage = e.getMessage();
            if (e.getTypeName() == 'System.DmlException') {
                errorMessage = e.getDmlMessage(0);
            }
            return null;
        }
        
        return redirect();
    }
    
    public PageReference updateFundRequest(){
         
        try{  
            ProductPlanUtility.updateFundRequest(fundRequestId, amountGranted, status);
        }catch(Exception e){
            errorMessage = e.getMessage();
            if (e.getTypeName() == 'System.DmlException') {
                errorMessage = e.getDmlMessage(0);
            }
            return null;
        }
        
        return redirect();
    }

    /*************************************************************************
     *
     *     Attributes
     *
     **************************************************************************
     */
    public transient string errorMessage { get; private set; }

    public boolean isEditMode { get; set; } { isEditMode = false; }

    public boolean hasError 
    {
        get 
        {
            return String.isNotBlank(errorMessage);
        }
    }

    public boolean hasMessages 
    {
        get
        {
            return ApexPages.hasMessages();
        } 
    }
    
    public boolean hasPlanBeenFound
    {
        get
        {
            return topLevelPlans != null && topLevelPlans.size() > 0;
        }
    }
    
    public integer maximumDepthToShow
    {
        get
        {
            return (Integer) Config_Settings_PMBI__c.getInstance().Maximum_Depth__c;
        }
    }
    
    public boolean showYTDActuals
    {
        get
        {
            return ( Integer.valueof(selectedPlanYear) <= date.today().year() );
        }
    }

    public boolean showPlanVsActuals
    {
        get
        {
            return ( Integer.valueOf(selectedPlanYear) <= date.today().year() ) && !isEditMode;
        }
    }
    /*public boolean showYTDPlan
    {
        get
        {
            return ! isEditMode && selectedPlanYear == string.valueOf(date.today().year());
        }
    }*/

    public boolean selectedPlanYearIsCurrentOrFuture{
        get {
            return Integer.valueOf(selectedPlanYear) >= date.today().year();
        }
    }

    /**************************************************************************
     *
     *     Constructor
     *
     **************************************************************************
     */
    public PlanViewSummaryControllerPMBI()
    {
        refreshData();
    }

    private List<PlanAndChildren> populateChildren(PlanAndChildren plan, Map<Id, Plan_BI__c> allPlans) {
        
        List<PlanAndChildren> childPlansForParent = new List<PlanAndChildren>();
        System.debug('PLAN PLAN ID: '+plan.plan.Id);
        if(subplans != null && subplans.get(plan.plan.Id) != null){
            for(Plan_BI__c subPlan : subplans.get(plan.plan.Id)) {
                PlanAndChildren p = new PlanAndChildren( allPlans.get(subPlan.Id), ProductPlanUtility.sortFundRequests(allPlans.get(subPlan.Id).Fund_Requests__r ));
    
                p.children = populateChildren(p, allPlans);
                childPlansForParent.add(p);
            }
        }
        return childPlansForParent;
    }
    
    public List<Plan_BI__c> getParentHierarchy( Id planId, boolean first ) {    
    
        List<Plan_BI__c> tempList = new List<Plan_BI__c>();
    
        List<Plan_BI__c> plan = [select Id, Name, Parent_Plan_BI__c, UI_Name_Display_BI__c from Plan_BI__c where Id = :planId];
        
        if (plan.size() > 0) {
          tempList.addAll( getParentHierarchy( plan[0].Parent_Plan_BI__c, false ));
          
          if( !first ) {
            tempList.add(plan[0]);
          }
        }
    
        return tempList;
    }  
    
    /**************************************************************************
     *
     *     Action Methods
     *
     **************************************************************************
     */
    public void refreshData()
    {
        accessMap = new Map<Id, UserRecordAccess>();
        topLevelPlans = new List<PlanAndChildren>();
        planOptions = new List<Plan_BI__c>();
        productFundRequests = new List<Fund_Request_BI__c>();
        subplans = new Map<Id, List<Plan_BI__c>>();

        userIsoCode = [select Id, DefaultCurrencyISOCode from User where Id=: UserInfo.getUserId()].DefaultCurrencyISOCode;
        
        String selectedId = null;
        if (ApexPages.currentPage().getParameters().containsKey('id')) {
            selectedId = ApexPages.currentPage().getParameters().get('id');
        }
        
        Map<Id, Plan_BI__c> allPlans;
        allPlans = new Map<Id, Plan_BI__c>([select Id, Name, Parent_Plan_BI__c, Plan_Total_Amount_BI__c, Unallocated_Amount_BI__c, Actuals_Total_Amount_BI__c, OwnerId, 
                                                    Approver_BI__c, CurrencyISOCode, Plan_vs_Actual_BI__c, UI_Name_Display_BI__c,
                                                    (select Id, Name, Amount_Granted__c, Details__c,  Amount_Requested__c, Status__c, CreatedDate, LastModifiedDate, 
                                                        CreatedBy.Name, OwnerId, Plan__c, Plan__r.Name, Date_Requested__c, Approver_BI__c from Fund_Requests__r order by CreatedDate desc) 
                                                        from Plan_BI__c where Plan_Year_BI__c = :selectedPlanYear]);
        
        for(Plan_BI__c pln:allPlans.values()){
            if(pln.Parent_Plan_BI__c != null){
                // If we didn't add subplans for this plan before let's create a new list
                if(!subplans.containsKey(pln.Parent_Plan_BI__c)){
                    subplans.put(pln.Parent_Plan_BI__c, new Plan_BI__c[]{pln});
                }else{ 
                    // If we already added this plan let's just add another subplan to it
                    subplans.get(pln.Parent_Plan_BI__c).add(pln);
                    subplans.get(pln.Parent_Plan_BI__c).sort();
                }
            }
        }
        System.debug('Subplans: '+subplans);
                                                                          
        if (selectedId != null && allPlans.containsKey(selectedId)) {
            topLevelPlans.add( new PlanAndChildren( allPlans.get(selectedId), ProductPlanUtility.sortFundRequests(allPlans.get(selectedId).Fund_Requests__r )));
                
            //get the parent hierarchy
            parentPlanHierarchy = getParentHierarchy(selectedId, true);
    
        } else {
            for( Plan_BI__c plan : allPlans.values()) {
                if (plan.Parent_Plan_BI__c == null || !allPlans.containsKey(plan.Parent_Plan_BI__c)) {
                        topLevelPlans.add( new PlanAndChildren(plan, ProductPlanUtility.sortFundRequests(plan.Fund_Requests__r)));
                 }
            }
        }

        planOptions = ProductPlanUtility.getProductPlans(selectedPlanYear);
        productFundRequests = ProductPlanUtility.sortFundRequests(
                                    [select Id, Name, Plan__c, Plan__r.Name, Amount_Granted__c, Details__c, Amount_Requested__c,
                                        Status__c, Approver_BI__c, CreatedDate, LastModifiedDate, CreatedBy.Name, OwnerId, Date_Requested__c 
                                    from Fund_Request_BI__c 
                                    where Plan__c in :planOptions 
                                    order by CreatedDate desc]
                              );

        if (topLevelPlans.isEmpty()) {
            errorMessage = Label.PMBI_NO_PLAN_RECORD_FOUND.replace('{0}',Plan_BI__c.SObjectType.getDescribe().getLabel().toLowercase());
        } else {
            for( PlanAndChildren plan : topLevelPlans ){
                plan.children = populateChildren(plan, allPlans);
            }
        }

        fillUserAccessMap();
    }
    
    public void fillUserAccessMap(){
        List<Id> recordIds = determineRecordsForAccessTable(topLevelPlans, 0);
        List<List<Id>> nestedRecordIds = new List<List<Id>>();

        //The next 20 or so lines of code are needed because we can only query the UserRecordAccess table up to 200 records at a time
        while (recordIds.size() > 200) {
            List<Id> tempIdList = new List<Id>();
            for(Integer i=0; i< 200; i++) {
                tempIdList.add(recordIds.get(0));
                recordIds.remove(0);
            }
            nestedRecordIds.add(tempIdList);
        } 
        
        //add any remaining Ids to the list of lists    
        nestedRecordIds.add(recordIds);

        List<UserRecordAccess> userRecordAccessList = new List<userRecordAccess>();
        for (List<Id> idList : nestedRecordIds) {
            //Yes, this looks bad, but we can't query more than 200 records at a time (see comment further back) so we are stuck with this 
            //horrendus SOQL query in a for loop.
            userRecordAccessList.addAll([select RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess, HasTransferAccess, HasAllAccess, MaxAccessLevel 
                                        from UserRecordAccess 
                                        where UserId = :UserInfo.getUserId() and RecordId in :idList]);
        }
                                                                          
        for( UserRecordAccess ura : userRecordAccessList){
            accessMap.put(ura.RecordId, ura);
        }
    }

    private List<Id> determineRecordsForAccessTable(List<PlanAndChildren> plansAndTheirChildren, Integer level) {
        List<Id> tempIdList = new List<Id>();

        for ( PlanAndChildren thisPlan : plansAndTheirChildren ) {
            tempIdList.add(thisPlan.plan.Id);
            if( level < maximumDepthToShow ) {
                tempIdList.addAll( determineRecordsForAccessTable( thisPlan.children, level+1 ));
            }            
        }
        return tempIdList;
    }

    public Id tempPlanId {get; set;}
    public String tempParentPlanId {get; set;}
    public String tempPlanAmount {get; set;}
    public Id tempPlanOwnerId {get; set;}
    
    public void updatePlanList(List<PlanAndChildren> planList, Id parentPlanId, Id childPlanId, Long amount){
        for(PlanAndChildren plan : planList){
            if(plan.plan.Id == parentPlanId){
                Decimal total = 0;
                for(PlanAndChildren child : plan.children){
                    if(childPlanId == child.plan.Id){
                        child.plan.Plan_Total_Amount_BI__c = amount;
                    }
                    total += child.plan.Plan_Total_Amount_BI__c;
                } 
                plan.plan.Unallocated_Amount_BI__c = (plan.plan.Plan_Total_Amount_BI__c - total).longValue();
                if(plan.plan.Unallocated_Amount_BI__c < 0) errorMessage = System.Label.BI_PAGE_UNALLOCATED_AMOUNT_ERROR.replace('{0}', plan.plan.Name + ' (' + formatCurrency(plan.plan.CurrencyISOCode, plan.plan.Unallocated_Amount_BI__c * (-1)) + ')');
            }else{
                if(plan.children != null && plan.children.size() > 0){
                    updatePlanList(plan.children, parentPlanId, childPlanId, amount);
                }
            }
        }
    }

    public PageReference savePlan(){
        try{
            if(tempParentPlanId != null && tempParentPlanId != '' && tempParentPlanId != 'null'){
                updatePlanList(topLevelPlans, tempParentPlanId, tempPlanId, ProductPlanUtility.convertToNumber(tempPlanAmount));
            }
            updatePlanList(topLevelPlans, tempPlanId, tempPlanId, ProductPlanUtility.convertToNumber(tempPlanAmount));
        }catch(Exception e){
            errorMessage = e.getMessage();
            
            if (e.getTypeName() == 'System.DmlException') {
                errorMessage = e.getDmlMessage(0);
            }
            if (e.getMessage().contains('PlanFieldValidateTrigPMBI.CustomException')) {
                errorMessage = Label.BI_PAGE_UNALLOCATED_AMOUNT_ERROR2;
            }
        }
        
        if(errorMessage != null && errorMessage != ''){
            isEditMode = true;
            return null;
        }

        try{
            update new Plan_BI__c(Id=tempPlanId, Plan_Total_Amount_BI__c=ProductPlanUtility.convertToNumber(tempPlanAmount));
        }catch (Exception e){
            isEditMode = true;
            errorMessage = e.getMessage();
            
            if (e.getTypeName() == 'System.DmlException') {
                errorMessage = e.getDmlMessage(0);
            }
            if (e.getMessage().contains('PlanFieldValidateTrigPMBI.CustomException')) {
                errorMessage = Label.BI_PAGE_UNALLOCATED_AMOUNT_ERROR2;
            }
        }
        
        return null;
    }
    
    public void toggleEditMode()
    {
        isEditMode = ! isEditMode;        
    }

    /******************************************************************
    **
    **  This method sets up the headers for the recursive table (divs)
    **  the table is created by calling createChildDivs and passing
    **  the topLevelPlans and initial parameters
    **
    ******************************************************************/
    public Component.Apex.OutputPanel getThePanel() {
        
        /***********************        
         * Main panel container
        ************************/
        Component.Apex.OutputPanel mainPanel = new Component.Apex.OutputPanel(layout='block');
        mainPanel.styleClass = isEditMode ? 'main-panel-edit' : 'main-panel';
        if ( Integer.valueOf(selectedPlanYear) > Date.today().year()) {
            mainPanel.styleClass += ' future-year';
        }
        
        /***********************        
         * The header row
        ************************/
        Component.Apex.OutputPanel headerRow = new Component.Apex.OutputPanel(layout='block', style='height:30px;');
        {
            /***********************        
             *Plan column header            
            ************************/
            Component.Apex.OutputPanel nameHeaderPanel = new Component.Apex.OutputPanel(layout='block', styleClass='plan-name table-header');
            {
                Component.Apex.OutputPanel innerNamePanel = new Component.Apex.OutputPanel(layout='block');
                innerNamePanel.childComponents.add(new Component.Apex.OutputText(value=Plan_BI__c.sObjectType.getDescribe().getLabel()));
                nameHeaderPanel.childComponents.add( innerNamePanel );
            }
            headerRow.childComponents.add( nameHeaderPanel);
  
                /*****************************        
                 *Plan amount column header
                ******************************/
                Component.Apex.OutputPanel amountHeaderPanel = new Component.Apex.OutputPanel(layout='block', styleClass='table-header ');
                amountHeaderPanel.styleClass += isEditMode ? 'plan-amount-edit' : 'plan-amount';
                {   
                    Component.Apex.OutputPanel innerAmountPanel = new Component.Apex.OutputPanel(layout='block');
                    innerAmountPanel.childComponents.add(new Component.Apex.OutputText(value=Plan_BI__c.fields.Plan_Total_Amount_BI__c.getDescribe().getLabel()));
                    amountHeaderPanel.childComponents.add( innerAmountPanel );
                }
                headerRow.childComponents.add( amountHeaderPanel);
    
                /**********************************        
                 *Unallocated amount column header
                ***********************************/
                Component.Apex.OutputPanel unallocatedHeaderPanel = new Component.Apex.OutputPanel(layout='block', styleClass='plan-unallocated-amount table-header');
                {
                    Component.Apex.OutputPanel innerUnallocatedPanel = new Component.Apex.OutputPanel(layout='block');
                    innerUnallocatedPanel.childComponents.add(new Component.Apex.OutputText(value=Plan_BI__c.fields.Unallocated_Amount_BI__c.getDescribe().getLabel()));
                    unallocatedHeaderPanel.childComponents.add( innerUnallocatedPanel );
                }
                headerRow.childComponents.add( unallocatedHeaderPanel);
    
                /**********************************        
                 *YTD Actuals column header
                ***********************************/
                if (showYTDActuals) {
                    Component.Apex.OutputPanel ytdActualsHeaderPanel = new Component.Apex.OutputPanel(layout='block', styleClass='plan-ytd-actuals table-header');
                    {
                        Component.Apex.OutputPanel innerYtdActualsPanel = new Component.Apex.OutputPanel(layout='block');
                        innerYtdActualsPanel.childComponents.add(new Component.Apex.OutputText(value=System.Label.BI_CONTROLLER_YTD_ACTUALS));
                        ytdActualsHeaderPanel.childComponents.add( innerYtdActualsPanel );
                    }
                    headerRow.childComponents.add( ytdActualsHeaderPanel);
                }
    
                /***************************************        
                 *YTD Plan & YTD % Plan column headers
                ****************************************/
                /*if (showYTDPlan) {
                    Component.Apex.OutputPanel ytdPlanHeaderPanel = new Component.Apex.OutputPanel(layout='block', styleClass='plan-ytd-plan table-header');
                    {
                        Component.Apex.OutputPanel innerYtdPlanPanel = new Component.Apex.OutputPanel(layout='block');
                        innerYtdPlanPanel.childComponents.add(new Component.Apex.OutputText(value=System.Label.BI_CONTROLLER_YTD_PLAN));
                        ytdPlanHeaderPanel.childComponents.add( innerYtdPlanPanel );
                    }
                    headerRow.childComponents.add( ytdPlanHeaderPanel);
    
                    Component.Apex.OutputPanel ytdPercentHeaderPanel = new Component.Apex.OutputPanel(layout='block', styleClass='plan-ytd-percent table-header');
                    {
                        Component.Apex.OutputPanel innerYtdPercentPanel = new Component.Apex.OutputPanel(layout='block');
                        innerYtdPercentPanel.childComponents.add(new Component.Apex.OutputText(value=System.Label.BI_CONTROLLER_YTD_TO_PLAN));
                        ytdPercentHeaderPanel.childComponents.add( innerYtdPercentPanel );
                    }
                    headerRow.childComponents.add( ytdPercentHeaderPanel);
                }*/

                /**********************************        
                 *Plan Vs. Actuals column header
                ***********************************/
                if (showPlanVsActuals) {
                    Component.Apex.OutputPanel planVsActualHeaderPanel = new Component.Apex.OutputPanel(layout='block', styleClass='plan-vs-actual table-header');
                    {
                        Component.Apex.OutputPanel innerPlanVsActualPanel = new Component.Apex.OutputPanel(layout='block');
                        innerPlanVsActualPanel.childComponents.add(new Component.Apex.OutputText(value=System.Label.BI_CONTROLLER_PLAN_VS_ACTUALS));
                        planVsActualHeaderPanel.childComponents.add( innerPlanVsActualPanel );
                    }
                    headerRow.childComponents.add( planVsActualHeaderPanel);
                }
            }
        
        mainPanel.childComponents.add(headerRow);
        
        /**********************************************
         * Build out the rows of our table recursively
        ***********************************************/
        for (Component.Apex.OutputPanel panel : createChildDivs(topLevelPlans, 0, 'topLevelPlans', 0, null)) {
            mainPanel.childComponents.add( panel );
        }
        
        return mainPanel;
    }

    /******************************************************************
    **
    **  This is a recursive method to build out the table dynamicly 
    **  from the plan hierarchy
    **
    ******************************************************************/
    public List<Component.Apex.OutputPanel> createChildDivs(list<PlanAndChildren> plans, Integer level, String accessString, Integer indexCounter, String parentId) {
        List<Component.Apex.OutputPanel> panels = new List<Component.Apex.OutputPanel>();       

        if (level < maximumDepthToShow) {    
            for (PlanAndChildren wrappedPlan : plans ) {            
                Plan_BI__c currentPlan = wrappedPlan.plan;
                /****************************************                 
                 * The string used to bind values on 
                 * the VF page
                ****************************************/                
                String thisAccessString = accessString + '[' + String.valueOf(indexCounter) + ']';
                
                /****************************************                 
                 * determine if this row is editable
                ****************************************/
                Boolean thisRowEditable = (maximumDepthToShow == level+currentLevelAdd || wrappedPlan.children.isEmpty()) && accessMap.get(currentPlan.id).HasEditAccess  && isEditMode;

                /****************************************                 
                 * The containing row
                ****************************************/
                Component.Apex.OutputPanel outerPanel = new Component.Apex.OutputPanel( layout='block', styleClass='collapsible planType');
                
                /****************************************                 
                 * 
                 * Plan Name (and possible link to plan)
                 *
                ****************************************/
                {
                    Component.Apex.OutputPanel namePanel = new Component.Apex.OutputPanel( layout='block', styleClass='plan-name cell');                             
                    Component.Apex.OutputPanel innerNamePanel = new Component.Apex.OutputPanel( layout='block' );                    
                    {
                        
                        /**********************************************************************************
                         * Depeding on the level and access level the user may be able to link to the plan
                         * otherwise we just display the name without a link
                        **********************************************************************************/
                        Component.Apex.OutputText nameValue = new Component.Apex.OutputText( value=currentPlan.UI_Name_Display_BI__c );                    
                    
                        /*************************************************************************************
                         *no need to display link for first level but need to display briefcase to open modal
                        *************************************************************************************/
                        if (level == 0 || !accessMap.get(currentPlan.Id).HasReadAccess ) {
                            innerNamePanel.childComponents.add( nameValue );
                        } else {
                            Component.Apex.OutputLink nameLink = new Component.Apex.OutputLink( value='/apex/PlanViewSummaryPMBI?id='+currentPlan.Id+'&year='+selectedPlanYear);
                            nameLink.childComponents.add( nameValue );
                            nameLink.styleClass = 'plan-link';
                            innerNamePanel.childComponents.add( nameLink );                            
                        }                     

                        /************************************************************************************
                         * Display a briefcase to open the request funds modal for this plan if at top level
                        ************************************************************************************/
                        if (level == 0 && !isEditMode) {
                            Component.Apex.OutputText briefcase = new Component.Apex.OutputText(escape=false);
                            briefcase.value = '<a href="#myModal-' + currentPlan.Id + '" data-toggle="modal" class="briefcase-link" title="'+ System.Label.BI_CONTROLLER_MODAL_TITLE.replace('{0}', currentPlan.UI_Name_Display_BI__c) +'"><i class="icon-briefcase"/></i></a>';
                            innerNamePanel.childComponents.add( briefcase );                            
                        }
                    }                                        
                    {
                        if (!wrappedPlan.children.isEmpty() && level+currentLevelAdd < maximumDepthToShow) {
                            Component.Apex.OutputText chevron = new Component.Apex.OutputText(escape=false);
                            chevron.value = '<i class="icon-folder-open"></i><i style="display:none;" class="icon-folder-close"></i>';
                            innerNamePanel.childComponents.add( chevron );
                        }
                    }
                    namePanel.childComponents.add( innerNamePanel );

                    /********************************************************************************
                     * get the buffer for the name based on the level and apply the styling
                    ********************************************************************************/
                    Integer indent =  level*20;
                    namePanel.style = 'padding-left:' + String.valueOf(indent) + 'px;width:' + String.valueOf( 300-(indent) ) + 'px;';//margin-right:-' + indent + 'px;';

                    if (thisRowEditable && isEditMode) {
                        namePanel.styleClass += ' row-edit';
                    }

                    outerPanel.childComponents.add( namePanel );

                }
                
                /*********************
                 *
                 * Plan Amount
                 *
                **********************/                
                {
                    Component.Apex.OutputPanel amountPanel = new Component.Apex.OutputPanel(layout='block', styleClass='currency cell');
                    amountPanel.styleClass += isEditMode ? ' plan-amount-edit' : ' plan-amount';
                    {
                        Component.Apex.OutputPanel wrapper = new Component.Apex.OutputPanel(styleClass='cell-wrapper');
                        if (thisRowEditable) {
                            Component.Apex.OutputPanel addOnSpan = new Component.Apex.OutputPanel(styleClass='input-prepend input-append input-add-ons');
                            {
                                Component.Apex.OutputPanel dollarSignAddOn = new Component.Apex.OutputPanel(styleClass='add-on');
                                {
                                    dollarSignAddOn.childComponents.add( new Component.Apex.OutputText(value=currentPlan.CurrencyISOCode));
                                }
                                addOnSpan.childComponents.add(dollarSignAddOn);

                                Component.Apex.InputText amountValue = new Component.Apex.InputText(styleClass='plan-amount-input');
                                amountValue.value=currentPlan.Plan_Total_Amount_BI__c;     
                                amountValue.maxlength=12;
                                amountValue.style='text-align:right';                     
                                amountValue.expressions.value='{!'+thisAccessString + '.plan.Plan_Total_Amount_BI__c}';
                                amountValue.onchange = 'saveFired=true;var amt = this.value;setTimeout(function(){savePlan(\'' + currentPlan.Id + '\', amt, \'' + currentPlan.Parent_Plan_BI__c +'\', !finished);show_loading_overlay();},200);';
                                addOnSpan.childComponents.add( amountValue );                                        
                            }
                            wrapper.childComponents.add( addOnSpan );
                        } else {
                            Component.Apex.OutputText amountValue = new Component.Apex.OutputText();
                            amountValue.value = formatCurrency( currentPlan.CurrencyISOCode, currentPlan.Plan_Total_Amount_BI__c);
                            wrapper.childComponents.add( amountValue );
                        }
                        amountPanel.childComponents.add( wrapper );
                    }

                    if (thisRowEditable && isEditMode) {
                        amountPanel.styleClass += ' row-edit';
                    }

                    outerPanel.childComponents.add( amountPanel );
                }

                /*********************
                 *
                 * Unallocated Amount
                 *
                **********************/
                {
                    Component.Apex.OutputPanel unallocatedAmountPanel = new Component.Apex.OutputPanel(layout='block', styleClass='plan-unallocated-amount currency cell');                    
                    
                    if (currentPlan.Plan_Total_Amount_BI__c > 0 && currentPlan.Unallocated_Amount_BI__c > 0 
                            && currentPlan.Unallocated_Amount_BI__c/currentPlan.Plan_Total_Amount_BI__c < 0.1) {
                        unallocatedAmountPanel.styleClass += ' low-balance';                            
                    } else if(currentPlan.Unallocated_Amount_BI__c > 0) {
                        unallocatedAmountPanel.styleClass += ' positive-balance';
                    } else if (currentPlan.Unallocated_Amount_BI__c < 0) {
                        unallocatedAmountPanel.styleClass += ' negative-balance';
                    }
                    Component.Apex.OutputPanel wrapper = new Component.Apex.OutputPanel(styleClass='cell-wrapper');
                    {
                        Component.Apex.OutputText unallocatedAmountValue = new Component.Apex.OutputText();
                        if (currentPlan.Unallocated_Amount_BI__c >= 0) {
                            unallocatedAmountValue.value = formatCurrency( currentPlan.CurrencyISOCode, currentPlan.Unallocated_Amount_BI__c );
                        } else {
                            unallocatedAmountValue.value = '(' + formatCurrency( currentPlan.CurrencyISOCode, currentPlan.Unallocated_Amount_BI__c * (-1) ) + ')';
                        }
                        wrapper.childComponents.add( unallocatedAmountValue );                        
                    }
                    unallocatedAmountPanel.childComponents.add( wrapper );

                    if (thisRowEditable && isEditMode) {
                        unallocatedAmountPanel.styleClass += ' row-edit';
                    }

                    outerPanel.childComponents.add( unallocatedAmountPanel );
                }

                /*********************
                 *
                 * YTD Actuals
                 *
                **********************/
                if ( showYTDActuals ) {
                    Component.Apex.OutputPanel ytdActualsPanel = new Component.Apex.OutputPanel(layout='block', styleClass='plan-ytd-actuals currency cell');
                    {
                        Component.Apex.OutputPanel wrapper = new Component.Apex.OutputPanel(styleClass='cell-wrapper');
                        {
                            Component.Apex.OutputText ytdActualsAmountValue = new Component.Apex.OutputText();
                            // (Plan Actuals ) / (Plan Total Amount * Current Month From JANUARY)
                            ytdActualsAmountValue.value = formatCurrency( currentPlan.CurrencyISOCode, currentPlan.Actuals_Total_Amount_BI__c, true );
                            wrapper.childComponents.add( ytdActualsAmountValue );
                        }
                        ytdActualsPanel.childComponents.add( wrapper );
                    }
                    if (thisRowEditable && isEditMode) {
                        ytdActualsPanel.styleClass += ' row-edit';
                    }

                    outerPanel.childComponents.add( ytdActualsPanel );
                }

                /***********************************
                 *
                 * YTD Plan && YTD % to Plan
                 * TODO :  update this section with proper values
                ***********************************/
                /*if ( showYTDPlan ) {
                    Long ytdAmount = (Long)(currentPlan.Plan_Total_Amount_BI__c/12) * Date.today().month();
                    Component.Apex.OutputPanel ytdPlanPanel = new Component.Apex.OutputPanel(layout='block', styleClass='plan-ytd-plan currency cell');
                    {
                        Component.Apex.OutputPanel wrapper = new Component.Apex.OutputPanel(styleClass='cell-wrapper');
                        {
                            Component.Apex.OutputText ytdPlanAmount = new Component.Apex.OutputText();
                            ytdPlanAmount.value =  formatCurrency( currentPlan.CurrencyISOCode, ytdAmount );
                            wrapper.childComponents.add( ytdPlanAmount );
                        }
                        ytdPlanPanel.childComponents.add( wrapper );
                    }
                    Component.Apex.OutputPanel ytdPercentPanel = new Component.Apex.OutputPanel(layout='block', styleClass='plan-ytd-percent currency cell');
                    {
                        Component.Apex.OutputPanel wrapper = new Component.Apex.OutputPanel(styleClass='cell-wrapper');
                        {
                            Component.Apex.OutputText ytdPercentAmount = new Component.Apex.OutputText();
                            // ( Plan Total Amount - Plan Actuals ) / (Plan Total Amount * Current Month From JANUARY)
                            if(ytdAmount != 0){
                                ytdPercentAmount.value =  formatCurrency( currentPlan.CurrencyISOCode, currentPlan.Actuals_Total_Amount_BI__c / ytdAmount );
                            }else{
                                ytdPercentAmount.value =  formatCurrency( currentPlan.CurrencyISOCode, 0 );
                            }
                            wrapper.childComponents.add( ytdPercentAmount );
                        }
                        ytdPercentPanel.childComponents.add( wrapper );
                    }

                    if (thisRowEditable && isEditMode) {
                        ytdPlanPanel.styleClass += ' row-edit';
                        ytdPercentPanel.styleClass += ' row-edit';
                    }

                    outerPanel.childComponents.add( ytdPlanPanel );
                    outerPanel.childComponents.add( ytdPercentPanel );
                }*/   
                
                /*********************
                 *
                 * Plan vs. Actuals
                 *
                **********************/
                if ( showPlanVsActuals ) {
                    Component.Apex.OutputPanel planVsActualPanel = new Component.Apex.OutputPanel(layout='block', styleClass='plan-vs-actual currency cell');
                    {
                        if (currentPlan.Plan_vs_Actual_BI__c < 0) {
                            planVsActualPanel.styleClass += ' negative-balance';
                        }

                        Component.Apex.OutputPanel wrapper = new Component.Apex.OutputPanel(styleClass='cell-wrapper');
                        {
                            Component.Apex.OutputText planVsActualAmountValue = new Component.Apex.OutputText();                            
                            planVsActualAmountValue.value = formatCurrency( currentPlan.CurrencyISOCode, currentPlan.Plan_vs_Actual_BI__c, true );
                            wrapper.childComponents.add( planVsActualAmountValue );
                        }
                        planVsActualPanel.childComponents.add( wrapper );
                    }
                    if (thisRowEditable && isEditMode) {
                        planVsActualPanel.styleClass += ' row-edit';
                    }

                    outerPanel.childComponents.add( planVsActualPanel );
                }
                
                //Recurse through the children
                for (Component.Apex.OutputPanel panel : createChildDivs( wrappedPlan.children, level+currentLevelAdd, thisAccessString + '.children', 0, currentPlan.Id ) ) {
                    outerPanel.childComponents.add( panel );
                }
                
                panels.add( outerPanel);
                indexCounter++;

                if (level == 0) {
                    panels.add(new Component.Apex.OutputPanel(layout='block', styleClass='panel-separator'));
                }
            }
        }

        return panels;
    }
    
    private String formatCurrency(String isoCode, Decimal decimalToFormat) {
        return formatCurrency( isoCode, decimalToFormat, false );
    }

    private String formatCurrency(String isoCode, Decimal decimalToFormat, Boolean appendDecimals) {
        String formattedString = isoCode + ' ' + decimalToFormat.format();
        
        //Even with .format, a decimal will display no decimal places when decimal == .00
        if (appendDecimals && decimalToFormat - decimalToFormat.round(System.RoundingMode.FLOOR) == 0) {
            formattedString += '.00';
        }
        return formattedString;
    }
}