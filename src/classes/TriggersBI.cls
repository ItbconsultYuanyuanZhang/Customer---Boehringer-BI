/**
 *  TriggersBI
 *  @author: John Daniel john@mavensconsulting.com
 *  Created Date: 24 JAN 2013
 *  Description: This class sets up trigger templating. 
 */
public class TriggersBI 
{
    public enum Evt 
    {
        afterdelete, afterinsert, afterundelete,
        afterupdate, beforedelete, beforeinsert, beforeupdate   
    }

    public interface HandlerInterface
    {
        void handle();
    } 

    // Internal mapping of handlers
    map<String, list<HandlerInterface>> eventHandlerMapping = new map<String, list<HandlerInterface>>();
    
    public TriggersBI bind(Evt event, HandlerInterface eh)
    {
        list<HandlerInterface> handlers = eventHandlerMapping.get(event.name());
        if (handlers == null) 
        {
            handlers = new list<HandlerInterface>();
            eventHandlerMapping.put(event.name(), handlers);
        }
        handlers.add(eh);
        return this;
    }

    public void manage()
    {
        Evt ev = null;
        if(trigger.isInsert && trigger.isBefore)
        {
            ev = Evt.beforeinsert;
        }
        else if(trigger.isInsert && trigger.isAfter)
        {
            ev = Evt.afterinsert;
        }
        else if(trigger.isUpdate && trigger.isBefore)
        {
            ev = Evt.beforeupdate;
        }
        else if(trigger.isUpdate && trigger.isAfter)
        {
            ev = Evt.afterupdate;
        }
        else if(trigger.isDelete && trigger.isBefore)
        {
            ev = Evt.beforedelete;
        }
        else if(trigger.isDelete && trigger.isAfter)
        {
            ev = Evt.afterdelete;
        }
        else if(trigger.isundelete)
        {
            ev = Evt.afterundelete;             
        }
        
        list<HandlerInterface> handlers = eventHandlerMapping.get(ev.name());
        
        if (handlers != null && ! handlers.isEmpty()) 
        {
            for (HandlerInterface h : handlers) 
            {
                h.handle();
            }
        }
    }
}