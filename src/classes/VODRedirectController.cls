public with sharing class VODRedirectController {
    public VODRedirectController(ApexPages.StandardController controller) {
    }

    public VODRedirectController() {
    }

    public String redirectURL { get; set; }

    public static String getVodVersion() {
        return VOD_Common.VOD_VERSION;
    }
  
    public static String getVodUrl () {
        return VOD_Common.VOD_URL;
    }
    public static boolean getInMaintenance () {
        return VOD_Common.VOD_MAINT;
    }
    public static String getExcludedUsers () {
        return VOD_Common.VOD_EXCLUDED_USERS;
    }

    public static String getVodServerUrl() {
        return VOD_Common.VOD_SERVER_URL;
    }

    public static String getVodFtpUrl(){
        return VOD_Common.FTP_SERVER_URL;
    }
    public static String getVodContentUrl(){
        return VOD_Common.CONTENT_SERVER_URL;
    }
	
	//for MC Engine
   public static String getMcUrl(){
       return Veeva_Common_vod__c.getValues('Main').Multichannel_Server_vod__c + '/' + Veeva_Common_vod__c.getValues('Main').Multichannel_Context_Root_vod__c;
   }
   public static String getMcVersion(){
		return Veeva_Common_vod__c.getValues('Main').Multichannel_Context_Root_vod__c;
   }
    
    public String getPageSize() {
        String url = ApexPages.currentPage().getUrl();
        if (url.contains('View_Cycle_Plan_vod')) {
            Integer targetCount = [select count() from Cycle_Plan_Target_vod__c where Cycle_Plan_vod__c = :ApexPages.currentPage().getParameters().get('id')];
            Integer height = 50*targetCount;
            if (height < 3000)
                height = 3000;
            return height+'px';
        } else if (url.contains('TSF_vod')) {
            return '600px';
        } else if (url.contains('Concur_Admin_vod')) {
            return '8000px';
        }
        return '4000px';
    }
    
    public static String getScrolling() {
        String url = ApexPages.currentPage().getUrl();
        if (url.contains('View_Cycle_Plan_vod')) {
            return 'true';
        } else if (url.contains('TSF_vod')) {
            return 'true';
        }
        return 'false';
    }

    public PageReference doRedirect() {
        PageReference redirect = new PageReference(redirectURL);
        redirect.setRedirect(true);
        return redirect;
    }
}