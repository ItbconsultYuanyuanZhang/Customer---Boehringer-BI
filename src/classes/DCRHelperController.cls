global class DCRHelperController {

     webservice static String[] createDefaultValues(String recType) {
     	
        //get RecordTypeId
        List<RecordType> rType = [Select Id from RecordType where DeveloperName = : recType];
        Id rtId;
        
        // if record type is empty then what?
        
        if (rType.isEmpty()) system.debug('NO RECORD TYPE FOUND!!!');
        
        if(!rType.isEmpty()){
            rtId = rType[0].Id;
        }
        
        // Obtain the magic ids
        //System.debug('PAGE-REFERENCE: ' + '/' + V2OK_Data_Change_Request__c.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1&RecordType='+rtId);
        //PageReference p = new PageReference('/' + V2OK_Data_Change_Request__c.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1&RecordType='+rtId);
        System.debug('PAGE-REFERENCE: ' + '/' + V2OK_Data_Change_Request__c.SObjectType.getDescribe().getKeyPrefix() + '/e?RecordType='+rtId);
        PageReference p = new PageReference('/' + V2OK_Data_Change_Request__c.SObjectType.getDescribe().getKeyPrefix() + '/e?RecordType='+rtId);
        String html = p.getContent().toString();
        Map<String, String> labelToId = new Map<String, String>();
        Matcher m = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
        //Matcher m = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>){0,1}(.*?)</label>').matcher(html);        
        while (m.find()) {
            String label = m.group(3);
            String id = m.group(1);
            labelToId.put(label, id);
            system.debug('label: ' + label);
            system.debug('id: ' + id);
        }
        
        system.debug('labelToId: ' + labelToId);
        
        // Relate the magic ids to the SObject fields
        List<String> params = new List<String>();
        
        //add prefix and rectype
        params.add('prefix');
        params.add(V2OK_Data_Change_Request__c.SObjectType.getDescribe().getKeyPrefix());
        params.add('RecType');
        params.add(rtId);
        
        //add other fields
        for (SObjectField field : V2OK_Data_Change_Request__c.SObjectType.getDescribe().fields.getMap().values()) 
        {
            DescribeFieldResult f = field.getDescribe();
            String label = f.getLabel();
            String name = f.getName();
            
            system.debug('Label: ' + label);
            system.debug('Name: ' + name);
            
            if (labelToId.containsKey(label)) {
                params.add(name);
                params.add(labelToId.get(label));
            }           
        }


        for (String key : labelToId.keySet()) {
        	params.add(key);
        	params.add(labelToId.get(key));
        }


        return params;
    }


}