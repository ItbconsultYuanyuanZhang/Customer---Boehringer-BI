public with sharing class IMP_BI_ClsRest4Heroku {
	public string org_id;
	public string sf_id;
	public string country;
	public string sf_name;
	public string parameters;
	
	public IMP_BI_ClsRest4Heroku() {
		org_id = UserInfo.getOrganizationId();
	}
}