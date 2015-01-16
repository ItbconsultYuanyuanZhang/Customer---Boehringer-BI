public class VOD_ORDER_CAMPAIGN_TRIG{
            static Boolean inOrderCampaignTrig = false;
            
             private static testMethod void test_ADDRESS_TRIG  () {
             
             System.assertEquals(inOrderCampaignTrig, false);
                setCampaignTrig (true);
                System.assertEquals (getCampaignTrig (), true);
             
             }
             
            public static void setCampaignTrig (Boolean p_inCampaignTrig) {
                inOrderCampaignTrig = p_inCampaignTrig;
            }
            
           public static Boolean getCampaignTrig ()  {
                return inOrderCampaignTrig ;
           }
        }