public with sharing class VEEVA_AccountCyclePlan_Control {

    public String getAccountId() {
        return  System.currentPageReference().getParameters().get('id');
    }
    public boolean getShowActualCalls(){
        return 'true'.equals(System.currentPageReference().getParameters().get('sac'));
    }
    public boolean getShowTotalCalls(){
        return 'true'.equals(System.currentPageReference().getParameters().get('stc'));
    }
    public boolean getShowProdDetails(){
        return 'true'.equals(System.currentPageReference().getParameters().get('spd'));
    }
}