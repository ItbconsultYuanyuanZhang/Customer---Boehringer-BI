public class RaphaelMySetupController {
    public My_Setup_Products_vod__c rkms { get; set; }
    public User theUser { get; set; }
	public void searchOwner() {
    	String id = ApexPages.CurrentPage().getParameters().get('thePage:theForm:pbConfigure:bsUser:OwnerID_lkid');
    	system.debug('id: ' + id);
    	theUser = [ SELECT id, firstname, lastname FROM User WHERE id = :id ];
    	
    }
    
    public RaphaelMySetupController() {
    	system.debug('In constructor');
    	system.debug('ID: ' + ApexPages.CurrentPage().getParameters().get('thePage:theForm:pbConfigure:bsUser:OwnerID_lkid'));
    }
}