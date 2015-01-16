/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Manage the pagination on table   
*  @author:         Jefferson Escobar
*  @created:        14-May-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:          29.0 (Force.com ApiVersion) 
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         14-May-2014                 jescobar                    Construction of the class.
*/ 
public class IMP_BI_Paging {
    
    public static final Integer defaultPageSize = 5;
    
    public class PagingException extends Exception {}
    
    public Boolean isFirstPage {get {return this.startRecord == 0;}}
    public Boolean isLastPage {get {return (this.startRecord + this.maxPerPage) >= this.size;}}
    public Integer startRecord {get; private set;}
    public Integer endRecord {get; private set;}
    public Integer maxPerPage {get; private set;}
    public Integer currentPage {get; private set;}
    public Boolean isEmpty {get {return this.size == 0;}}
    
    public Integer size{get; private set;}
    
    public IMP_BI_Paging(Integer collectionSize, Integer maxPerPage) {
        this.size = collectionSize;
        this.currentPage = 1;
        this.maxPerPage = maxPerPage;
        this.startRecord = 0;
        this.endRecord = (this.size > this.maxPerPage) ? this.startRecord + (this.maxPerPage - 1) : this.size - 1;
    }

    public IMP_BI_Paging(Integer collectionSize){
        this(collectionSize, defaultPageSize);
    }
    
    public Integer getCantPages(){
        return (Math.ceil(toDouble(size)/toDouble(maxPerPage))).intValue();
    }
   
   public void next(){
        if(this.isLastPage){
            throw new PagingException('There are no more pages');
        }
        setPage(this.currentPage + 1);
   }
   
   public void previous(){
        if(this.isFirstPage){
            throw new PagingException('This is the first page!');
        }
        
        setPage(this.currentPage - 1);
   }
   
    
    
   public List<Integer> getPages(){
        Integer cant = getCantPages();
        List<Integer> pages = new List<Integer>();
        
        for(Integer i = 1 ; i <= cant ; i++){
            pages.add(i);
        }
        
        return pages;
   } 
   
   
   public void setPage(Integer x){
        if(!(1 <= x && x <= getCantPages()))
            throw new PagingException('Page out of bounds: ' + x);
        
        
        this.currentPage = x;
        this.startRecord = (x-1)*this.maxPerPage;
        
        if(!this.isLastPage)
            this.endRecord = this.startRecord + this.maxPerPage - 1;
        else
            this.endRecord = this.size - 1;
        
 
        
   }
   
   private Double toDouble(Integer x){
        return Double.valueOf(x);
   }
}