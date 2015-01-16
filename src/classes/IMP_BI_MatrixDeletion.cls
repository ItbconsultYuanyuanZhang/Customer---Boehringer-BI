/**
* ===================================================================================================================================
*                                   IMMPaCT BI                                                     
* ===================================================================================================================================
*  Decription:      Deletion Matrix more than 50k records
*  @author:         Jefferson Escobar
*  @created:        15-Mar-2014
*  @version:        1.0
*  @see:            Salesforce IMMPaCT
*  @since:			29.0 (Force.com ApiVersion)	
* ===================================================================================================================================
*       Version     Date                        Developer                   Notes
*       1.0         15-Mar-2014                 jescobar                 	Construction of the class.
*/ 
 
public class IMP_BI_MatrixDeletion {
	
	public Matrix_BI__c matrix {get;private set;}
	public String errMsg {get;private set;}
	
	/**
    * The contsructor
    *
	* @param ctr matrix controller parameter
	*
	* @changelog
	*  15-Mar-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	*  - Created
	*/
	public IMP_BI_MatrixDeletion(ApexPages.standardController ctr){
		//Get standard record
		matrix = (Matrix_BI__c) ctr.getRecord(); 
		
		if(matrix.Id != null){
			//Get matrix with Id from standard controller
			matrix = [Select Id,Name,Cycle_BI__c,Cycle_BI__r.Name 
						From Matrix_BI__c where Id = :matrix.Id limit 1 FOR UPDATE];
			//TODO:Validate if the matrix has been related in any portfolio 
			List<Strategic_Brand_Weight_BI__c> matrixOnPortfolio = [SELECT Id,Portfolio_BI__c,Portfolio_BI__r.Name FROM Strategic_Brand_Weight_BI__c WHERE Matrix_BI__c = :matrix.Id limit 1];
			
			if(matrixOnPortfolio!=null&&!matrixOnPortfolio.isEmpty()){//&& !isAdmin
				String retURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + matrix.Cycle_BI__c; 
				errMsg = 'This matrix is used in portfolio <a href="/'+matrixOnPortfolio.get(0).Portfolio_BI__c+'"><b>"'+matrixOnPortfolio.get(0).Portfolio_BI__r.Name+'"</b></a>, so it cannot be removed. Click <a href="' 
							+ retURL + '"><b>here</b> </a> to return back.';
				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg) );
			}
		}else{//If an error occurred
			String retURL = URL.getSalesforceBaseUrl().toExternalForm() + '/'; 
			errMsg = 'It is not possible to delete the matrix. Click <a href="' + retURL + '"><b>here</b> </a> to return back.';
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg) );
		}
	}
		
	/**
	* Delete Relationship Matrix cycle data child records
	*
	* @param Matrix Id
	* @return String
	*
	* @changelog
	*  15-Mar-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	*  - Created
	*/
    @RemoteAction
    public static Response clearCycData(string idMatrix) {
        Response r = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
            List<Cycle_Data_BI__c> cycleDataToUpdate = [SELECT Id 
                                      FROM Cycle_Data_BI__c 
                                      WHERE Matrix_BI__c = :idMatrix
                                      limit 4000];//5000
                                      
			
			system.debug(':: Updating Cycle data:  ' + (cycleDataToUpdate!=null&&cycleDataToUpdate.size() > 0 ? cycleDataToUpdate.size() : 0));
            
            if(cycleDataToUpdate!=null&&cycleDataToUpdate.size() == 4000){//5000
                r.gotonext = 'gonext';
            }
            
            if(cycleDataToUpdate!=null&&cycleDataToUpdate.size() != 0){
            	
            	for(Cycle_Data_BI__c cd : cycleDataToUpdate){
            		cd.Matrix_BI__c = null;
            		cd.Matrix_Cell_BI__c = null;
            	}
            	
            	//Records updted
            	r.delSize = cycleDataToUpdate.size();
           		database.update(cycleDataToUpdate);
            }
        }
        catch(DmlException de){
    		Database.rollback(sp);
    		r.message = '[ERROR] ' + de.getMessage();
			r.isException = true;
			return r;
			//ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, de.getMessage()) );
			system.debug('[ERROR]' + de.getMessage());
    	}
        catch(Exception ex){
            r.message = '[ERROR] ' + ex.getMessage();
            r.isException = true;
            //ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getMessage()) );
            system.debug('[ERROR]' + ex.getMessage());
        }
        
        system.debug(':: Return Cycle Data Process: ' + r);
        return r;
    }
    
    
    /**
	* Delete Relationship Portfolio Field Force Simulation
	*
	* @param Matrix Id
	* @return String
	*
	* @changelog
	*  15-Mar-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	*  - Created
	*/
    @RemoteAction
    public static Response clearPortfolioSimulation(String idMatrix) {
        Response r = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
           List<Portfolio_Field_Force_Simulation_BI__c> portfolioSimluationToUpd = [SELECT Id 
                                      FROM Portfolio_Field_Force_Simulation_BI__c 
                                      WHERE Product_Matrix_BI__c = :idMatrix
                                      limit 5000];//5000
                
			system.debug(':: Deleting Portfolio Field Force Simulation:  ' + (portfolioSimluationToUpd!=null&&portfolioSimluationToUpd.size() > 0 ? portfolioSimluationToUpd.size() : 0) );
            
            if(portfolioSimluationToUpd!=null&&portfolioSimluationToUpd.size() == 5000){//4000
                r.gotonext = 'gonext';
            }
            
            if(portfolioSimluationToUpd!=null&&portfolioSimluationToUpd.size() != 0){
            	//Update Portfolio Field Simulation Records
            	for(Portfolio_Field_Force_Simulation_BI__c pffs : portfolioSimluationToUpd){
            		pffs.Product_Matrix_BI__c = null;
            	}
            	r.delSize = portfolioSimluationToUpd.size();
            	update portfolioSimluationToUpd;
            }
        }
        catch(DmlException de){
    		Database.rollback(sp);
    		r.message = '[ERROR] ' + de.getMessage();
			r.isException = true;
			return r;
			//ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, de.getMessage()) );
			system.debug('[ERROR] ' + de.getMessage());
    	}
        catch(Exception ex){
            r.message = '[ERROR] ' + ex.getMessage();
            r.isException = true;
            //ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getMessage()) );
            system.debug('[ERROR]' + ex.getMessage());
        }
        
        system.debug(':: Return Portfolio Field Force Simulation Process: ' + r);
        return r;
    }
    
    /**
	* Delete Matrix Cell Details
	*
	* @param Matrix Id
	* @return String
	*
	* @changelog
	*  15-Mar-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	*  - Created
	*/
	 @RemoteAction
	public static Response clearMatrixDetail(String idMatrix) {
        Response r = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
        	List<Matrix_Cell_Detail_BI__c> cellMatricesToDelete = [SELECT Id FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__r.Matrix_BI__c = :idMatrix limit 1000];
            
            system.debug(':: Cells Detail to delete ' + (cellMatricesToDelete!=null&&cellMatricesToDelete.size()>0?cellMatricesToDelete.size():0));
            
            
            if(cellMatricesToDelete!=null&&cellMatricesToDelete.size() == 1000){
            	r.gotonext = 'gonext';
            }
        	
        	if(cellMatricesToDelete!=null&&cellMatricesToDelete.size() != 0){
        		r.delSize = cellMatricesToDelete.size();
        		database.delete(cellMatricesToDelete);
				database.emptyRecycleBin(cellMatricesToDelete);
			}
        }
        catch(DmlException de){
    		Database.rollback(sp);
    		r.message = '[ERROR] ' + de.getMessage();
			r.isException = true;
			//ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, de.getMessage()) );
			system.debug('[ERROR]' + de.getMessage());
			return r;
    	}
        catch(Exception ex){
            r.message ='[ERROR] ' + ex.getMessage();
            r.isException = true;
            //ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getMessage()) );
            system.debug('[ERROR]' + ex.getMessage());
        }
        return r;
    }
    
	
	/**
	* Delete Matrix Cells
	*
	* @param Matrix Id
	* @return String
	*
	* @changelog
	*  15-Mar-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	*  - Created
	*/
	@RemoteAction
	public static Response clearMatrixCell(String idMatrix) {
        Response r = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
        	List<Matrix_Cell_BI__c> matrixCellToDelete = [SELECT Id FROM Matrix_Cell_BI__c WHERE Matrix_BI__c = :idMatrix limit 10];
            
            system.debug('::Deleting Matrix Cell: ' + (matrixCellToDelete!=null&&matrixCellToDelete.size()>0 ? matrixCellToDelete.size() : 0 ));
            
            if(matrixCellToDelete!=null&&matrixCellToDelete.size() == 10){
            	r.gotonext = 'gonext';
            }
			
			if(matrixCellToDelete!=null&&matrixCellToDelete.size() != 0){
        		r.delSize = matrixCellToDelete.size();
        		//delete matrixCellToDelete;
				database.delete(matrixCellToDelete);
				database.emptyRecycleBin(matrixCellToDelete);
			}
        }
        catch(DmlException de){
        	Database.rollback(sp);
    		r.message ='[ERROR] ' +  de.getMessage();
			r.isException = true;
			//ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, de.getMessage()) );
			system.debug('[ERROR]' + de.getMessage());
			return r;
    	}
        catch(Exception ex){
        	r.message = '[ERROR] ' + ex.getMessage();
            r.isException = true;
            //ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getMessage()) );
            system.debug('[ERROR]' + ex.getMessage());
        }
        
		system.debug(':: Return Matrix Cell to Delete...' + r);        
        return r;
    }
    
    @RemoteAction
    public static Response clearMatrixData(String idMatrix) {
        Response r = new Response();
        Savepoint sp = Database.setSavepoint();
        try{
        	delete [Select Id From Matrix_BI__c where Id = :idMatrix];
        }
        catch(DmlException de){
    		Database.rollback(sp);
    		r.message ='[ERROR] ' + de.getMessage();
			r.isException = true;
			//ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, de.getMessage()) );
			system.debug('[ERROR]' + de.getMessage());
			return r;
    	}
        catch(Exception ex){
            r.message = '[ERROR] ' + ex.getMessage();
            r.isException = true;
            //ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getMessage()) );
            system.debug('[ERROR]' + ex.getMessage());
        }
        system.debug(':: Response Deleting Matrix: ' + r);
        return r;
    }
    
    /**
    * Get total of records Matrix childs
    * 
    * @param idMatrix Id Matrix to get childs records
    * @return Server response
    *
    * @changelog
	*  14-Apr-2014 Jefferson Escobar <jescobar@omegacrmconsulting.com>
	*  - Created
    */
    @RemoteAction
    @ReadOnly
    public static Response getTotalRecords(String idMatrix){
    	Response r = new Response();
    	Integer total = 0;
		try{
	    	Integer cData = [Select count() From Cycle_Data_BI__c where Matrix_BI__c = :idMatrix]; 
	    	Integer portfolio = [Select count() From Portfolio_Field_Force_Simulation_BI__c where Product_Matrix_BI__c = :idMatrix];
	    	Integer cells = [Select count() From Matrix_Cell_BI__c where Matrix_BI__c = :idMatrix];
	    	Integer cellsDetail = [Select count() FROM Matrix_Cell_Detail_BI__c WHERE Matrix_Cell_BI__r.Matrix_BI__c = :idMatrix];
	    	
	    	//Sum up total of child records
	    	total = (cData!=null ? cData : 0) + (portfolio!=null ? portfolio : 0) + (cells!=null ? cells : 0) + (cellsDetail!=null ? cellsDetail : 0);
	    }catch(DmlException de){
    		r.message = '[ERROR] ' + de.getMessage();
    		r.isException = true;
			system.debug('[ERROR]' + de.getMessage());
			return r;
    	}
        catch(Exception ex){
            r.message = '[ERROR] ' + ex.getMessage();
            r.isException = true;
            system.debug('[ERROR]' + ex.getMessage());
        }
    	r.message = String.valueOf(total); 
    	return r;
    }
    
/**
==================================================================================================================================
												Wrapper Classes                                                     
==================================================================================================================================
*/
    
	public class Response{
        boolean isException;
        String gotonext;
        string message;
        Integer delSize;
        //set<Id> set_recyclId;
        
        public Response() {
            gotonext = 'isover';
            message = '';
            delSize = 0;
            isException=false;
            //set_recyclId = new set<Id>();
        }
   }
}