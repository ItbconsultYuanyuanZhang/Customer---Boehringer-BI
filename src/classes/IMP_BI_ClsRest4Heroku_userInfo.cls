@RestResource(urlMapping='/getUserInfo/v1/*')
global with sharing class IMP_BI_ClsRest4Heroku_userInfo {
	@HttpGet
	global static Response doGet(){
		Response r = new Response();
        try {  
            RestRequest req = RestContext.request;
            Id uId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            for(User u: [select  id, username from User where id =: uId ]) {
				r.userinfo = u;
			}
        }	
        catch(exception e) {
            r.success = false;
            r.message = e.getMessage();
        }
        return r;
	}
	
	global class Response{		
        public boolean success;
        public string message;
        public User userinfo;
        public Response() {
            success = true;
            message = '';
        }
   }
}