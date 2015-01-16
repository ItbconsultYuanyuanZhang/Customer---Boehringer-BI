{!requireScript("/soap/ajax/25.0/connection.js")}
{!requireScript("/soap/ajax/25.0/apex.js")}


function URL(prefix, recordType) {
	this.url = "/" + prefix + "/e?RecordType=" + recordType + "&CancelURL={!Account.Id}";
}

URL.prototype.add = function(field, value) {
	if (value != null) this.url += "&" + field + "=" + encodeURIComponent(value);
}

URL.prototype.toString = function() {
	return this.url;
}

/* This function is not used
function getPhoneFromAccount(accountId) {
	var query = "SELECT Phone FROM Account Where Id = '" + accountId + "'";
	// Performs the query and grabs the phone number from the first record of the response.
	return sforce.connection.query(query).getArray("records")[0].Phone;
} 
*/

function getFields(recordTypeName) {
	var results = sforce.apex.execute('DCRHelperController', 'createDefaultValues', {arg: recordTypeName});

	// convert the results to a hash structure
	var idMap = {};
	for (var i=0;i<results.length;i+=2) {
		idMap[results[i]] = results[i+1];
	}
	//alert("idMap: " + JSON.stringify(idMap));
	return idMap;
}


function getAddressInfo() {
	var query = "SELECT Address_line_2_vod__c, City_vod__c, OK_State_Province_BI__r.Name, OK_State_Province_BI__r.Id, Country_Code_BI__c, OK_External_ID_BI__c, Name, Zip_vod__c FROM Address_vod__c where Account_vod__c = '{!Account.Id}' ORDER BY Primary_vod__c DESC";
	var result =  sforce.connection.query(query).getArray("records")[0];
	return result;
}

function getPrimaryParent() {
	var query = "SELECT Primary_Parent_vod__r.Id, Primary_Parent_vod__r.Name FROM Account WHERE Id = '{!Account.Id}'";
	var record = sforce.connection.query(query).getArray("records")[0];
	if (record == null) return null;
	return record.Primary_Parent_vod__r;
}

function getChildAccount() {  // Gets details from the primary parent child account object for this professional
	var query = "SELECT Parent_Account_vod__r.Id, Parent_Account_vod__r.Name, Role_BI__r.Name, Role_BI__r.Id FROM Child_Account_vod__c WHERE Child_Account_vod__c = '{!Account.id}' and Primary_vod__c = 'Yes'";
	var records = sforce.connection.query(query).getArray("records");
	if (records[0] != null) {
		var record = records[0];
		if (record.Parent_Account_vod__r == null)
			record.Parent_Account_vod__r = {Id: "", Name: ""};
		if (record.Role_BI__r == null)
			record.Role_BI__r = {Id: "", Name: ""};
		return record;
	}
	return {Parent_Account_vod__c: {Name: "", Id: ""}, Role_BI__r: {Name: "", Id: ""}};
}

/*
function getCustomerAttribute(attr) { // remember to use the <name>__r version rather than the <name>__c version of the field
	var query = "SELECT " + attr + ".Id, " + attr + ".Name FROM Account WHERE Id = '{!Account.Id}'";
	var record = sforce.connection.query(query).getArray("records")[0];
	if (record == null || record[attr] == null || record[attr] == {}) return { Id: "", Name: ""};
	return record[attr];
}
*/

function getCustomerAttribute(attr, accId) { // remember to use the <name>__r version rather than the <name>__c version of the field
	if (arguments.length == 1) accId = "{!Account.Id}";
	var query = "SELECT " + attr + ".Id, " + attr + ".Name FROM Account WHERE Id = '" + accId + "'";
	var record = sforce.connection.query(query).getArray("records")[0];
	if (record == null || record[attr] == null || record[attr] == {}) return { Id: "", Name: ""};
	return record[attr];
}

function generateUrl(recordTypeName) {
	this.recordTypeName = recordTypeName;
	this.url   = null;
	this.idMap = null;

	this.go = function() {
		this.init();
		this.individualProcess();
		window.open(this.url.toString(), "_self");
	}
}

generateUrl.prototype.add = function(label, value, isLookupId) {
	if (arguments.length == 2) isLookupId = false;
	var field = this.idMap[label];
	if (isLookupId) field += "_lkid";
	this.url.add(field, value);
}

generateUrl.prototype.init = function() {
	this.idMap = getFields(this.recordTypeName);
	this.url = new URL(this.idMap.prefix, this.idMap.RecType);
	this.add("Change_Type__c", "Update");
	var address = getAddressInfo();

	if (address != null) {
		this.add("New_Address_Line_1__c", address.Name);
		this.add("City_vod__c", address.City_vod__c);
		this.add("Country_DS__c", address.Country_Code_BI__c);
		this.add("Zip_vod__c", address.Zip_vod__c);

		if (address.OK_State_Province_BI__r != null) {
			this.add("County_DS__c", address.OK_State_Province_BI__r.Name);
			this.add("County_DS__c", address.OK_State_Province_BI__r.Id, true);
		}
	}
}


DS_HeirarchyUrl.prototype = new generateUrl("Hierarchy_DataSteward_BI");
function DS_HeirarchyUrl() {
	this.individualProcess = function() {
		this.add("Parent Account", "{!Account.Name}");
		this.add("Parent Account", "{!Account.Id}", true);
	}
}

function go_DS_Heirarchy() {
	var dsh = new DS_HeirarchyUrl();
	dsh.go();
}

