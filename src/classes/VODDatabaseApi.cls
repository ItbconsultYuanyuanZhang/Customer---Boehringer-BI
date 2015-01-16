// VODDatabaseApi presumes that no objects are dependent of objects behind them,
// and objects are committed to DB on request order.

global with sharing class VODDatabaseApi {
    
    static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    static Map<String, List<SObject>> newListMap = new Map<String, List<SObject>>();
    
    WebService static String process(String xml) {
        String output = '';
        if (xml == null || xml.length() == 0)
            return output;
        // System.debug(xml);
        Map<String, VodObject> vodObjMap = new Map<String, VodObject>();
        Map<String, Set<String>> dependentMap = new Map<String, Set<String>>();
        List<VodObject> vodObjs = parseDocument(xml, dependentMap, vodObjMap);
        if (vodObjs.size() == 0)
            return output;               
        Savepoint sp = Database.setSavepoint();          
        try {       
            output = processVodObjects(vodObjs, sp, dependentMap, vodObjMap); 
            System.debug(output);
            return output;
            }
        catch (System.DmlException  e) { 
            output ='err;;;E;;;';        
            for (Integer i = 0; i < e.getNumDml(); i++) 
                output += e.getDmlMessage(i) + '; ';
            Database.rollback(sp);
            return output; 
        }
        catch(DBException e) {
            output = 'err;;;E;;;' + e.getMessage();
            Database.rollback(sp);
            return output;
        }
        catch (System.Exception e) {
            output = 'err;;;E;;;' + e.getMessage();
            Database.rollback(sp);
            return output;
        }
    }
   
    //  1) perform DML on objects with all dependents resolved
    //  2) call updateDependents to resolve their child objects
    private static String processVodObjects(List<VodObject> vodObjs, 
                            Savepoint sp, Map<String, Set<String>> dependentMap, 
                            Map<String, VodObject> vodObjMap) {
            
        if (vodObjs.size() == 0)
            return '';
        Map<String, String> sfIdMap = new Map<String, String>();   
        Set<String> allParentIds = dependentMap.keySet();
        Set<String> parentIds = new Set<String>();
        String output = '';
        
        // collect objects ready to be committed in a group
        List<SObject> readySObjects = null;
        List<String> readyVodIds = new List<String>();
        Set<String> readySObjIds = new Set<String>();
        String action = null;
        String typeName = null;
        
        // process VodObject in order
        for (VodObject vObj : vodObjs) {                             
            // group SObjects ready to be committed
            boolean added = addToGroup(readySObjects, readyVodIds, readySObjIds, 
                        action, typeName, vObj, allParentIds, parentIds);
                                    
            if (!added) {
                if (readySObjects != null) {                    
                    // commit SObjects collected so far
                    output += updateDB(readyVodIds, readySObjects, action, sfIdMap);     
                    if (parentIds.size() > 0) {
                        updateDependents(parentIds, dependentMap, vodObjMap, sfIdMap);  
                    } 
                    readySObjects = null;
                    readySObjIds.clear();
                    readyVodIds.clear();
                    parentIds.clear(); 
                }
                
                // start a new group                                    
                List<SObject> newList = newListMap.get(vObj.m_name);
                if (newList == null) {
                    // workaround for creating List<SObject>
                    String objectName = String.escapeSingleQuotes(vObj.m_name); // CRM-45716
                    newList = Database.query('select id from ' + objectName + ' limit 0');  
                    newListMap.put(vObj.m_name, newList);
                }
                readySObjects = newList.clone();   
                action = vObj.m_action;
                typeName = vObj.m_name;           
                addToGroup(readySObjects, readyVodIds, readySObjIds, action, typeName, 
                            vObj, allParentIds, parentIds);
            }
            
            if (!vObj.m_ready)
                throw new DBException('not all objects can be committed to DB');           
        } 
        
        if (readySObjects != null)   
            output += updateDB(readyVodIds, readySObjects, action, sfIdMap); 
                       
        return output;
    }  
    
    private static String updateDB(List<String> vodIds, List<SObject> sObjs, String action,  
                                Map<String, String> sfIdMap) {
        if (sObjs.size() ==0)
            return ''; // no op
        if (action == 'INS')
            return doInsert(vodIds, sObjs, sfIdMap);
        else if (action == 'UPD')
            return doUpdate(vodIds, sObjs, sfIdMap);
        else if (action == 'UPS')
            return doUpsert(vodIds, sObjs, sfIdMap);
        else if (action == 'DEL')
            return doDelete(vodIds, sObjs); 
        return ''; // no op                             
    }           
   
    private static String doInsert(List<String> vodIds, List<SObject> sObjects, 
                            Map<String, String> sfIdMap) {
        String output = '';
        List<Database.Saveresult> results = Database.insert(sObjects, true);  
        Integer i = 0;
        for (Database.Saveresult sr : results) {
            if (sr.isSuccess()) {
                output += vodIds.get(i) + ';;;S;;;' + sr.getId() + '<--->';  
                sfIdMap.put(vodIds.get(i), sr.getId());                            
            } else {
                output = '';
                for (Database.Error err: sr.getErrors()) {
                    output += err.getMessage() + '; ';
                }
                throw new DBException(output);
            }
            i++;
        }
        return output;       
    }
   
    private static String doUpdate(List<String> vodIds, List<SObject> sObjects, 
                                Map<String, String> sfIdMap) {
        String output = '';
        List<Database.Saveresult> results = Database.update(sObjects, true);  
        Integer i = 0;
        for (Database.Saveresult sr : results) {
            if (sr.isSuccess()) {
                output += vodIds.get(i) + ';;;S;;;' + sr.getId() + '<--->'; 
                sfIdMap.put(vodIds.get(i), sr.getId());                               
            } else {
                output = '';
                for (Database.Error err: sr.getErrors()) {
                    output += err.getMessage() + '; ';
                }
                throw new DBException(output);
            }
            i++;
        }
        return output;       
   }
   
   private static String doUpsert(List<String> vodIds, List<SObject> sObjects,  
                                Map<String, String> sfIdMap){
        String output = '';
        List<Database.Upsertresult> results = Database.upsert(sObjects, true);  
        Integer i = 0;
        for (Database.Upsertresult sr : results) {
            if (sr.isSuccess()) {
                output += vodIds.get(i) + ';;;S;;;' + sr.getId() + '<--->'; 
                sfIdMap.put(vodIds.get(i), sr.getId());                               
            } else {
                output = '';
                for (Database.Error err: sr.getErrors()) {
                    output += err.getMessage() + '; ';
                }
                throw new DBException(output);
            }
            i++;
        }
        return output;
    }
        
   
    private static String doDelete(List<String> vodIds, List<SObject> sObjects) {
        String output = '';
        List<Database.Deleteresult> results = Database.delete(sObjects, true);  
        Integer i = 0;
        for (Database.Deleteresult sr : results) {
            if (sr.isSuccess()) {
                output += vodIds.get(i) + ';;;S;;;<--->';                              
            } else {
                output = '';
                for (Database.Error err: sr.getErrors()) {
                    output += err.getMessage() + '; ';
                }
                throw new DBException(output);
            }
            i++;
        }
        return output;
    }
   
    // collect a group of objects ready to be committed
    private static boolean addToGroup(List<SObject> readySObjects, List<String> readyVodIds,
                                Set<String> readySObjIds, 
                                String action, String typeName, VodObject vObj, 
                                Set<String> allParentIds, Set<String> parentIds) 
    {
        if (readySObjects == null || vObj.m_ready == false)
           return false;   
        if (vObj.m_action != action || vObj.m_name != typeName)
           return false;
        if (readySObjects.size() == 200) //govenor limit
           return false;
        
        // construct SObject 
        Schema.SObjectType objType = gd.get(vObj.m_name);
        if (objType == null) 
            return true; //no op
            
        String idValue = null;
        VodField idField = vObj.m_fieldList.get('Id');
 
        if (idField != null) 
            idValue = idField.m_value;
        
        SObject sObj = null;
        if ('INS' != vObj.m_action && idValue != null && idValue.length() > 0) {
            if (readySObjIds.contains(idValue))
                return false;
            readySObjIds.add(idValue); 
            sObj = objType.newSObject(idValue);
        } else {
            sObj = objType.newSObject(); 
        }
                       
        for (VodField vField : vObj.m_fieldList.values()) {
            if (vField.m_name == 'Id')
                continue;                       
            addField (vField, sObj);
        }
           
        readySObjects.add(sObj);
        readyVodIds.add(vObj.m_objectid);
        if (action != 'DEL' && allParentIds.contains(vObj.m_objectid))
            parentIds.add(vObj.m_objectid);                 
        return true;           
   }       
                
    private static void updateDependents (Set<String> parentVodIds, 
                            Map<String, Set<String>> dependentMap, 
                            Map<String, VodObject> vodObjMap, Map<String, String> sfIdMap) 
    {
        Map<String, String> nameMap = new Map<String, String>();
        Set<String> resolved = new Set<String>();
        for (String parent : parentVodIds) {        
            String searchId = '@' + parent + '@';
            String searchIdName = '@' + parent + '@NAME@';
            String sfId = sfIdMap.get(parent);    
    
            for (String dependentId : dependentMap.get(parent)) {
                VodObject vObj = vodObjMap.get(dependentId);
                for (VodField vField : vObj.m_fieldList.values()) {
                    String value = vField.m_value;
                    if (value == searchId) {
                        vField.m_value = sfId;
                    }
                    if (value == searchIdName) {
                        String Name = nameMap.get(sfId);
                        if (Name == null) {
                            // CRM-45716 - cleaning the inputs to prevent SOQL injection
                            String objectName = String.escapeSingleQuotes(vodObjMap.get(parent).m_name);
                            sObject S = Database.query('SELECT ID, NAME FROM ' + objectName + ' WHERE ID =\'' + sfId + '\'');
                            if (S != null) {
                                String sName = (String)S.get('Name');
                                nameMap.put(sfId, sName);
                                Name = sName;
                            }
                        }
                        vField.m_value = Name;
                    }
                }               
            }
            resolved.addAll(dependentMap.get(parent));
            dependentMap.remove(parent);
        }
        
        // find VodObjects ready to be processed
        Set<String> allDependents = new Set<String>();
        for (Set<String> ids : dependentMap.values())
           allDependents.addAll(ids);
        resolved.removeAll(allDependents);
        for (String id : resolved) 
           vodObjMap.get(id).m_ready = true;    
    }
 
    private static List<VodObject> parseDocument(String xml, 
            Map<String, Set<String>> dependentMap, Map<String, VodObject> vodObjMap) {
        
        List<VodObject> vodObjs = new List<VodObject>();  
        Set<String> vodIds = new Set<String>();       
        Xmlstreamreader xmlReader = new Xmlstreamreader(xml);
        while(xmlReader.hasNext()) {
            // Start at the beginning of the book and make sure that it is a book
            if (xmlReader.isStartElement()) {
                if ('OBJECT' == xmlReader.getLocalName()) {
                    String uri = xmlReader.getNamespace();
                    String action = xmlReader.getAttributeValue(uri, 'action');
                    String objectid = xmlReader.getAttributeValue(uri, 'id');
                    String name = xmlReader.getAttributeValue(uri, 'name');
                    String upsertField = xmlReader.getAttributeValue(uri, 'upsertField');
                    VodObject vObject = new VodObject (name,objectid,action,upsertField);
                    Set<String> parentIds = new Set<String>();
                                   
                    // loop on the children of the OBJECT
                    while (xmlReader.hasNext()) {
                        xmlReader.next();
                        if (xmlReader.isEndElement() && xmlReader.getLocalName() == 'OBJECT') {
                            vodObjMap.put(objectid, vObject);
                            vodIds.add(objectid);
                            break;
                        }   
                        if (xmlReader.isStartElement() &&  xmlReader.getLocalName() == 'FIELD') {
                            String fldUri = xmlReader.getNamespace();
                            String fldName =  xmlReader.getAttributeValue(fldUri, 'name'); 
                            String fldType =  xmlReader.getAttributeValue(fldUri, 'type');
                            String fldValue =  xmlReader.getAttributeValue(fldUri, 'value');
                            String[] splits = fldValue.split('@');
                            if (splits.size() > 1 && vodIds.contains(splits[1])) {
                                parentIds.add(splits[1]); 
                            }                         
                            VodField fld = new VodField (fldName,fldType,fldValue);
                            vObject.m_fieldList.put(fld.m_name, fld);
                        }                       
                    }
                    
                    vodObjs.add(vObject);
                    if (parentIds.size() == 0) { // ready for DML
                        vObject.m_ready = true;
                    }
                    else {
                        // map of parent to children
                        for (String parentId : parentIds) {                       
                            Set<String> childIds = dependentMap.get(parentId);
                            if (childIds == null) 
                                dependentMap.put(parentId, new Set<String> {objectid});
                            else
                                childIds.add(objectid);
                        }
                    }
                }           
            }
                
            if (xmlReader.hasNext())
                xmlReader.next();               
        }
        System.debug(dependentMap);
        return vodObjs;            
    }
    
    private static void addField (VodField vField, SOBject sobj) {
        String fldType = vField.m_fldType;
        String value = vField.m_value;
        String name = vField.m_name;
        
         if ('_boolean' == fldType) {
            boolean b = false;                   
            if ('true'.equalsIgnoreCase(value)) {
                b = true;
            }
            sobj.put(name,b);
            return;
        }
        
         if (value == null || value.length() == 0) {
                sobj.put(name,null);
                return;
         }
        
        if ('date' == fldType) {
            Date dt = Date.valueOf(value);
            sobj.put(name,dt);
        } else if ('datetime' == fldType) {
            if (value == null || value.length() == 0)
            return;
            Long l = Long.valueOf(value);
            Datetime dtm = Datetime.newInstance(l);     
            sobj.put(name,dtm); 
        } else if ('_double' == fldType || 'double' == fldType || 'currency' == fldType ) {
            Double d = Double.valueOf(value);
            sobj.put(name,d);   
        }  else if ('_long' == fldType || 'long' == fldType) {
            Long l = Long.valueOf(value);
            sobj.put(name,l);   
        }  else if ('_int' == fldType || 'int' == fldType) {
            Integer i = Integer.valueOf(value);
            sobj.put(name,i);   
        }  else if ('percent' == fldType || '_precent' == fldType) {
            Double d = Double.valueOf(value);
            sobj.put(name,d);   
        }  else {
            sobj.put(name,value);
        }       
    }
   
         
    class VodField { 
        String m_name;
        String m_fldType;
        String m_value;
        
        VodField (String name, String fldType,String value) {
            m_name = name;
            m_fldType = fldType;
            m_value = value;    
        }
    }
    
    class VodObject {
        String m_action; 
        String m_objectid;
        String m_name;
        String m_upsertField;
        Boolean m_ready;
        
        Map <String,VodField> m_fieldList = new Map <String,VodField>();
    
        VodObject(String name, String objectid, string action, String upsertField) {
            m_action = action; 
            m_objectid = objectid;
            m_name = name;
            m_upsertField = upsertField;
            m_ready = false;
        }
    }
    
    class DBException extends Exception {}
}