/**
 * VEEVA_BI_CONCUR_DETAILED_PRODUCTS trigger
 * Slices the default Veeva field Detailed_Products_vod__c that contains the products added to the call by double spaces
 * and adds the first three to new fields. 
 *
 * Author: Viktor Fasi <viktor.fasi@veevasystems.com>
 * Date: 2013-03-21
 *
 * Modified: Raphael Krausz <raphael.krausz@veevasystems.com>
 * Date: 2013-04-05
 * Fixed bug - if the trigger is an insert, then Trigger.old is null.
 *
 */
trigger VEEVA_BI_CONCUR_DETAILED_PRODUCTS on Call2_vod__c (before insert, before update) {
    //system.debug('Started!');
    //check if call is newly submitted
    for (Integer i = 0; i < Trigger.new.size(); i++) {
    //system.debug('cycle started!');
    //if call is newly submitted
        if (Trigger.new[i].Status_vod__c == 'Submitted_vod'
            && (Trigger.isInsert || Trigger.old[i].Status_vod__c != Trigger.new[i].Status_vod__c)) {     
        //system.debug('Submitted!');       
            //if field is not empty
            if(Trigger.new[i].Detailed_Products_vod__c !=null && Trigger.new[i].Detailed_Products_vod__c.Length() > 0)
                {   // system.debug('Not empty!');          
                    String full = Trigger.new[i].Detailed_Products_vod__c;          
                    //system.debug('full value: ' + full);          
                    String[] products = full.split('  ');
                    if (products.size() >= 1){Trigger.new[i].CP1__c = products[0];}
                    if (products.size() >= 2){Trigger.new[i].CP2__c = products[1];}
                    if (products.size() >= 3){Trigger.new[i].CP3__c = products[2];}                                 
                }else{
                //system.debug('Empty');                   
                }   
        }else{
        //if call is not submitted
        //system.debug('Not submitted:' + Trigger.new[i].Status_vod__c + 'status');
        }
    }
}