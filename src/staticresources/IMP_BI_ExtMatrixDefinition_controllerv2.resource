function register_event(){	//all event
    //added by Peng 2013-06-07
    j$("#matriDivId table select[name$='theMTSelecrList']").each(function(){
    	j$(this).attr("title", j$("option[value=" + j$(this).val() + "]", j$(this)).text());
		
		if(!j$(getParent(j$(this).get(0), 'TABLE')).hasClass("finalMatrix")) 
			populateColumnsForLaunchTemplate(j$(this), true);
    });
    
    //Begin: modified by Peng Zhu 2013-06-21 for copying the rows and columns from template
    j$("#matriDivId table select[name$='theMTSelecrList']").change(function(){
    	j$(this).attr("title", j$("option[value=" + j$(this).val() + "]", j$(this)).text());
    	populateColumnsForLaunchTemplate(j$(this), false);
    });
    
    //Set info matrix from matrix template already created
    /**j$("#matriDivId table select[name$='matrixTemplate']").change(function(){
		setMatrixTemplateInfo(j$(this));
		
    });*/
	//End: modified by Peng Zhu 2013-06-21
    
	j$('#specialDivId .draggable').off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
	j$('#specialDivId .ui-state-disabled').off('mouseenter mouseleave');
	
	var sortable_options = {containment : '#theTopDiv', cancel : '.ui-state-disabled', cursor : 'move'},
		droppable_options = {hoverClass : 'hoverTarget', activeClass : 'dropTarget', cursor : 'move'};
		
	var special_drop = j$('#specialDivId ul.dropUlCls').sortable({
			opacity: 0.7, 
			revert: true,
			cursor : sortable_options.cursor,
			cancel: sortable_options.cancel,
			containment: sortable_options.containment
			//start : matrix_sort_start_fn
			//stop: matrix_stop_fn_void
    });
	/*add by leijun
	  j$('.draggable').draggable({
	  	refreshPositions: true ,
	  	connectToSortable: ".draggable",
	  	helper:"clone",
	  	revert: "invalid",
	 	start: startedDrag,
         stop:stoppedDrag
	 });
	  function startedDrag() {
     	console.log(1);
        j$('.specialCls').css({
            overflow: 'visible',
        });
    }
        
    function stoppedDrag() {
    		console.log(2);
        j$('.specialCls').css({
            overflow: 'hidden',
        });
    }
	*/
	j$("div[id^='matrix']").not(".finalMatrix").each(function(){
		j$(this).sortable({
			items: "li:not(.ui-state-disabled)",
			opacity: 0.7, 
			revert: true,
			cursor : sortable_options.cursor,
			cancel: sortable_options.cancel,
			containment: sortable_options.containment,
			stop: matrix_stop_fn
    		});
	});
    
        
	j$("div[id^='matrix']").not(".finalMatrix").droppable({
        accept:".draggable, .matrixDraggable",
        hoverClass: droppable_options.hoverClass,
        activeClass: droppable_options.activeClass,
        liveSelector:"#specialDivId",
        drop : droppable_drop_fn
    });
    
	j$("#specialDivId").droppable({
        accept:".matrixDraggable",
        hoverClass: droppable_options.hoverClass,
        activeClass: droppable_options.activeClass,
        liveSelector:"#matriDivId",
        drop : droppable_drop_fn
    });
	
	/**Set enable/disable droppable div
    j$("#matriDivId table input[name$='matrixDPA']").each(function(){
    	var j$dpa = j$(this);
    	var j$divCurrSpecial = j$(getParent(j$dpa.get(0), 'TABLE')).find('div.specialCls');;
    	
    	if(j$dpa.is(":checked")){
    		j$divCurrSpecial.droppable({ disabled: true });//Set enabled droppable div
    	}else{
    		j$divCurrSpecial.droppable({ disabled: false });//Set disabled droppable div
    	}
    });*/
	
	showTextHelp();
}


/**
 * Set info for the matrix from any matrix template already created
 * 
 * @param obj DOM object select list of matrix template 
 */
function setMatrixTemplateInfo(obj){
	var j$this = j$(obj);
	var template = jsonMatrixTemplate[j$(obj).val()];
	var j$table = j$(getParent(j$this.get(0), 'TABLE'));
	var j$cycleTemplate = j$("select[name$='theMTSelecrList']", j$table);
	
	var j$potentialLabel = j$("input[name$='matrixPotentialLabel']", j$table);
	var j$adoptionLabel = j$("input[name$='matrixAdoptionLabel']", j$table);
	
	if(template){
		j$cycleTemplate.val(template.Lifecycle_Template_BI__c);
		populateColumnsForLaunchTemplate(j$cycleTemplate, false);
		
		setSpecialtiesFromTemplate(j$this.get(0),template);
		if(template.Potential_Data_Label_BI__c!=null && j$.trim(j$potentialLabel.val())=='') j$potentialLabel.val(template.Potential_Data_Label_BI__c);
		if(template.Adoption_Data_Label_BI__c!=null && j$.trim(j$adoptionLabel.val())=='') j$adoptionLabel.val(template.Adoption_Data_Label_BI__c);
			
		//var j$inputRow = j$("input[id^='theRowInput']", j$table);
		//var j$inputCol = j$("input[id^='theColumnInput']", j$table);
		//j$inputRow.val(template.Row_BI__c);
		//j$inputCol.val(template.Column_BI__c);
	}else{
		
	}
}

function e_over_draggable(e){
	var j$this = j$(this);
	switch(e.type){
		case 'mouseenter': j$this.addClass('pgover'); break;
		default : j$this.removeClass('pgover'); break;
	}
}


function droppable_drop_fn(drag,drop){
	//console.log('In drop....');
	var j$dragCurrent = j$(drop.helper.context), conditionId,
	currentId = j$.trim(j$dragCurrent.attr('id')), 
	parentId = j$.trim(j$dragCurrent.parent().parent().attr('id'));
	
	if(typeof(parentId) != 'undefined' && j$.trim(parentId) != '' && (parentId.indexOf('matrix') > -1)){
		conditionId = 'matrixDivId';
	}
	else{
		conditionId = parentId;
	}
	

	var targetId = j$(drag.target).attr('id');
	 //console.log('Current : ' + j$.trim(j$dragCurrent.parent().parent().attr('id')));
	 //console.log('targetId : ' + targetId);
	
	if((targetId.indexOf('matrix') > -1) && (parentId.indexOf('matrix') > -1)){
		conditionId = 'horizontalMove';
	}
	
	if(typeof(targetId) != 'undefined' && typeof(parentId) != 'undefined' && j$.trim(targetId) != '' && j$.trim(parentId) != '' && targetId != parentId){
		 //console.log('In cal....');
		switch(conditionId){
			case 'horizontalMove' :
				 //console.log('horizontalMove');
				var hasFinded = false;
				var j$dragTarget, targetId;
				
				j$(drag.target).find('li').each(function(){
					if(typeof(j$(this).attr('id')) == 'undefined' || j$(this).attr('id') == ''){	//cleart old channel
						if(!hasFinded){
							hasFinded = true;
							j$dragTarget = j$(this), targetId = j$(this).attr('id');
						}
					}
				});
				
				//if has not find any available li, do nothing
				if(typeof(j$dragTarget) != 'undefined'){
					j$dragTarget.attr({'id': currentId}).attr({'name': j$dragCurrent.text()})
						.addClass('pgover').html(j$dragCurrent.text()).removeClass('ui-state-disabled');
						
					
					j$(('#' + parentId + ' #'+currentId)).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
				}
				//Begin: added by Peng Zhu 2013-08-30
				else{
					j$dragTarget = j$('<li id="' + currentId + '" class="matrixDraggable pgover" name="'+j$dragCurrent.text()+'">' + j$dragCurrent.text() + '</li>');
					j$(('#' + parentId + ' #'+currentId)).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
					
					j$(drag.target).find('ul').append(j$dragTarget);
				}
				//End: added by Peng Zhu 2013-08-30
				break;
			
			case 'matrixDivId' :
				var duplicateCounter = 0;
    			//j$("div[name='matrixSpecial'] li").each(function(){
				//	var liId = j$(this).attr('Id');
	       		//	if(liId && liId == currentId) duplicateCounter ++;
	    		//}); 

				//console.log('duplicateCounter : ' + duplicateCounter);
				//console.log('currentId : ' + currentId);
				console.log(3);
				var j$lis = j$(drag.target).find('li');
	        	j$lis.each(function(){
	        		if(currentId == j$(this).attr('id')){
	        			if(duplicateCounter < 2){
	        				j$(this).removeClass('ui-state-disabled').removeClass('special-state-disabled').css({'opacity': 1});
		        			j$(this).off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
	        			}
	        			j$(('#' + parentId + ' #'+currentId)).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
	        		}
	        	});
				break;
				
			case 'specialDivId' : 
				//find a available li -- id is null
				var hasFinded = false;
				var j$dragTarget, targetId;
				var j$divTarget = j$(drag.target).find('li.pgover');
					
				
				//added by Peng Zhu 2013-06-25 for overflowHidden
				var j$div = j$(getParent(j$dragCurrent.get(0), 'DIV'));
				if(j$div.hasClass('overflowHidden')){
					j$div.removeClass('overflowHidden');
				}
				
				j$(drag.target).find('li').each(function(){
					if(typeof(j$(this).attr('id')) == 'undefined' || j$(this).attr('id') == ''){	//cleart old channel
						if(!hasFinded){
							hasFinded = true;
							j$dragTarget = j$(this), targetId = j$(this).attr('id');
						}
					}
				});
				//if has not find any available li, do nothing
				if(typeof(j$dragTarget) != 'undefined'){
					console.log(1);
					j$dragTarget.attr({'id': currentId}).attr({'name': j$dragCurrent.find('span').attr('title')})
						.addClass('pgover').html(j$dragCurrent.find('span').attr('title')).removeClass('ui-state-disabled');
					j$dragCurrent.addClass('ui-state-disabled').addClass('special-state-disabled').css({'opacity': 0.4});
					j$dragCurrent.removeClass('pgover').off('mouseenter mouseleave');
				}
				//Begin: added by Peng Zhu 2013-08-30
				else{
					console.log(2);
					j$dragTarget = j$('<li id="' + currentId + '" class="matrixDraggable pgover" name="' + j$dragCurrent.find('span').attr('title') + '">' + j$dragCurrent.find('span').attr('title') + '</li>');
					j$dragCurrent.addClass('ui-state-disabled').addClass('special-state-disabled').css({'opacity': 0.4});
					j$dragCurrent.removeClass('pgover').off('mouseenter mouseleave');
					j$(drag.target).find('ul').append(j$dragTarget);
				}
				//End: added by Peng Zhu 2013-08-30
				
				break;
			default :  break;
		}
	}
	checkAllMatrixSpecialDiv();
}

function removeMatrix(){
	j$("#matriDivId table:last-child").remove();
	var matrixIndex = parseInt(j$('#matrixIndex').val());
	if(matrixIndex > 0){
		j$('#matrixIndex').val(matrixIndex - 1);
	}
}

/**
 * collect the matrixs values on page
 * return : JSON Data
 */
function collectMatrixValues(toCalculate){
	var counter = 0, matrix = {}, arr = [], mtIdArr = [], sArrAll = [];
	
	j$("#matriDivId table").not('.finalMatrix').each(function(){
		
		var matrixEditId = j$(this).attr('id');
		if(matrixEditId && j$.trim(matrixEditId) != ''){
			matrixEditId = matrixEditId.split('-')[1];
		}
	
	    var name = j$("input[name='matrixName']", j$(this)).val();
	    var adoptionLabel = j$("input[name$='matrixAdoptionLabel']", j$(this)).val();
	    var potentialLabel = j$("input[name$='matrixPotentialLabel']", j$(this)).val();
	    var isChecked = (j$("input[name$='matrixChecked']", j$(this)) && j$("input[name$='matrixChecked']", j$(this)).get(0).checked) ? true : false ;
	    
	    adoptionLabel = (adoptionLabel == null || adoptionLabel == '') ? 'Prod Rx' : adoptionLabel;
	    potentialLabel = (potentialLabel == null || potentialLabel == '') ? 'Market Rx' : potentialLabel;
	    var isCalculated = (toCalculate) ? isChecked : false;
	    var special = '';
	    var sArr = [];
	    
		j$("div[name='matrixSpecial'] li", j$(this)).each(function(){
			var temp = j$.trim(j$(this).text());
	       	if(typeof(temp) != 'undefined' && temp != ''){
	           	special += temp + '; ';
	       	}
	       
	       	var sId= j$(this).attr('id');
	       	if( j$("[id$='AccountMatrixCK']").prop('checked') ) sId = j$(this).attr('name');
	       	//else sid = j$(this).attr('id');
	       	//console.log( j$(this).textContent );
	       	//console.log( sid );
	       	if(sId && j$.trim(sId) != ''){
	       		sArr.push(j$.trim(sId));
	       		sArrAll.push(j$.trim(sId));
	       	}
	    });
	    
	    special = j$.trim(special);
	    if(typeof(special) != 'undefined' && special != ''){
	        special = special.substring(0, special.length - 1);
	    }
	    
	    var row = j$("input[id^='theRowInput']", j$(this)).val();
	    if(typeof(row) != 'undefined' && j$.trim(row) != ''){
	    	row = parseInt(row);
	    }
	    else{
	    	row = 0;
	    }
	    
	    var dpa = false;
	    if(j$("input[name$='matrixDPA']", j$(this)) && j$("input[name$='matrixDPA']", j$(this)).get(0).checked){
	    	dpa = true;
	    }
	    
	    var allCustomers = false;
	    if(j$("input[name$='matrixAllCustomers']", j$(this)) && j$("input[name$='matrixAllCustomers']", j$(this)).get(0).checked){
	    	allCustomers = true;
	    }
	    
	    var column = j$("input[id^='theColumnInput']", j$(this)).val();
	    if(typeof(column) != 'undefined' && j$.trim(column) != ''){
	    	column = parseInt(column);
	    }
	    else{
	    	column = 0;
	    }
	    
	    //var lifeCycle = j$("select[name$='theLCSelectList']", j$(this)).val();
	    var sMtId = j$("select[name$='theMTSelecrList']", j$(this)).val();
	    if(typeof(sMtId) != 'undefined' && j$.trim(sMtId) != ''){
	    	mtIdArr.push(sMtId);
	    }
	    
	    var matrixTemplateId = j$("select[name$='matrixTemplate']", j$(this)).val();
	    
	    if(typeof(name) != 'undefined' && name != ''){
	        var cm = {};
	        
	        if(matrixEditId && j$.trim(matrixEditId) != '') cm.mid = matrixEditId;
	        cm.name = name;
	        cm.special = special;
	        //cm.lifeCycle = lifeCycle;
	        cm.tid = sMtId;
	        cm.row = row;
	        cm.column = column;
	        cm.set_sId = sArr;
	        cm.dpa = dpa;
	        cm.allCustomers = allCustomers;
	        cm.adoptionLabel = adoptionLabel;
	        cm.potentialLabel = potentialLabel;
	        cm.toCalculate = isCalculated;
	        cm.matrixTemplateId = (typeof(matrixTemplateId) != 'undefined' && j$.trim(matrixTemplateId) != '') ? matrixTemplateId : null;
	        
	        arr.push(cm);
	    }
	});

	matrix.productId = j$("select[id$='theProductList']").val();
	matrix.cid = cycleId;
	matrix.list_cm = arr;
	matrix.set_mtIds = mtIdArr;
	matrix.set_sId = sArrAll;
	matrix.countryId = countryId;
	matrix.countryCode = countryCode;
	matrix.countryCodeRegion = countryCodeRegion;
	matrix.countryTestId = countryTestId;
	//add by leijun
	matrix.accountMatrix = j$("[id$='AccountMatrixCK']").prop('checked');
	if(matrix.accountMatrix == true)  matrix.accountMatrixtype = 'HCO';
	else matrix.accountMatrixtype = 'HCP';
	console.log(matrix);
	//die
	return JSON.stringify(matrix);
}

function showTextHelp(){
	j$(function() {
		j$("img[class^='budgetHelpText']").hover(
			function () {
				j$(this).removeClass("budgetHelpText").addClass("budgetHelpTextOn");
			},
			function () {
				j$(this).removeClass("budgetHelpTextOn").addClass("budgetHelpText");
			}
		);
	  });
}


function addMatrix(){
    //TODO: get matrix index
    var matrixIndex = parseInt(j$('#matrixIndex').val()) + 1;
    
    //create table
    var tableStr = '';
    tableStr += '<table style="display:inline-block;" class="matrixInnerTable">' +
                            '<tr>' +
                                '<td> <span style="float:left;"> <input type="checkbox" value="1" id="matrixChecked-'+matrixIndex+'" id="matrixChecked" name="matrixChecked"/> </span> <img src="/s.gif" class="budgetHelpText" title="'+selectMatrix_TextHelp+'" style="float: left;margin: 3px 5px;" /> '+
                                	'<img src="/img/icon/service_contracts24.png" title="'+matrixTemplateInfo+'" style="cursor: pointer; float: right;" onclick="openMatrixTemplate(this);"/>'+	
                            	 	label_Matrix + '<span class="matrixIndexSpan">' + matrixIndex  + '</span>' + '<img title="delete this Matrix" class="deleteMatrixImg" style="cursor:pointer; margin-left:5px; vertical-align:middle; height:15px; width:15px;" onclick="removeGivenMatrix(this);" src="/img/func_icons/util/recycle.gif"></td>' +
                            '</tr>' +
                            '<tr>'+
	                            '<td style="text-align: left;">'+
	                                '<span class="matrixTableLabel">Matrix Template:&nbsp;</span>'+
	                                '<span style="float:right;">'+
	                                	matrixTemplateList+
	                                '</span>'+
	                            '</td>'+
                            '</tr>'+
                            '<tr>' +
                                '<td style="text-align: left;">' +
                                '<span class="matrixTableLabel">' + label_Name + ':&nbsp;</span><span style="float:right;">' +
                                '<div class="requiredInput"><div class="requiredBlock"></div>' + 
                                '<input name="matrixName" type="text" style="width:100px;" onchange="checkMatrixName(this);" onkeyup="if(this.value.match(/\'/)) this.value=this.value.replace(/[\']/g,\'\')"/>' +
                                '<div class="erMsg" style="display:none; font-size:12px;">' +
                                        '<font color="#C00 !important">Must not be null</font>' +
                                    '</div>' +
                                '</div></span></td>' +
                            '</tr>' +
                            '<tr>' +
                                '<td style="text-align: left;">' +
                                	'<span class="matrixTableLabel">' + label_Dpa + ':&nbsp;</span>' +
                                	'<span style="float:right;">' +
                                		'<input name="matrixDPA" type="checkbox" style="width:100px;" onclick="checkAllMatrixSpecialDiv();checkDpaForAllCustomer(this);"/>' +
                                	'</span></td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td style="text-align: left;">' +
                            	'<span class="matrixTableLabel">' + label_LaunchPhase + ':&nbsp;</span>' +
                            	'<span style="float:right;">' +
                            		'<input id="matrixLaunchPhase" type="checkbox" disabled="true" style="width:100px;" />' +
                            	'</span></td>' +
                            '</tr>' +
                            '<tr>' +
                                '<td style="text-align: left;">' +
                                	'<span class="matrixTableLabel">' + label_AllCustomers + ':&nbsp;'+
                                	'</span>' +
                                	'<span style="float:right;">' +
                                		'<input name="matrixAllCustomers" type="checkbox" style="width:100px;" onclick="checkAllCustomers(this);"/>' +
                                	'</span></td>' +
                            '</tr>' +
							'<tr>' +
                                '<td style="text-align: left;">' +
                                '<span class="matrixTableLabel">' + label_Status + ':&nbsp;</span><span style="float:right;">' +
                                '<div class="requiredInput"><div class="requiredBlock"></div>' + 
                                '<input name="matrixStatus" type="text" style="width:100px;" disabled="disabled" value="' + value_Draft + '"/>' +
                                '<div class="erMsg" style="display:none; font-size:12px;">' +
                                        '<font color="#C00 !important">Must not be null</font>' +
                                    '</div>' +
                                '</div></span></td>' +
                            '</tr>' +
                            '<tr>' +
								'<td style="text-align: left;">' + 
                            	'<span class="matrixTableLabel">Template: </span><span style="float:right;">' +
                                '<div class="requiredInput">' +
									'<div class="requiredBlock">' +
									'</div>'
	                                + mtSelectList +
								    '<div class="erMsg" style="display:none; font-size:12px;">' +
								        '<font color="#C00 !important"><strong>Error: </strong>You must select one Product!</font>' +
								    '</div>' +
								'</div></span>' +
								'</td>' +
                            '</tr>' +
							'<tr>'+
								'<td style="text-align: left;">'+
									'<span class="matrixTableLabel">'+  label_Potential +'</span>'+
									'<span style="float:right;">'+
										'<div class="requiredInput">'+
											'<span style="float:right;">'+
												'<input type="text" style="width:100px;" size="20"  maxlength="25" name="matrixPotentialLabel" placeholder="Market Rx" />'+
											'</span>'+
											'<div class="erMsg" style="display:none; font-size:12px;">'+
												'<font color="#C00 !important"><strong>Error: </strong>Must not be null!</font>'+
											'</div>'+
										'</div>'+
									'</span>'+
								'</td>'+
							'</tr>'+
							'<tr>'+
								'<td style="text-align: left;">'+
									'<span class="matrixTableLabel">'+ label_Adoption +'</span>'+
									'<span style="float:right;">'+
										'<div class="requiredInput">'+
											'<span style="float:right;">'+
												'<input type="text" style="width:100px;" size="20" name="matrixAdoptionLabel" maxlength="25" placeholder="Prod RX"/>'+
											'</span>'+
											'<div class="erMsg" style="display:none; font-size:12px;">'+
												'<font color="#C00 !important"><strong>Error: </strong>Must not be null!</font>'+
											'</div>'+
										'</div>'+
									'</span>'+
								'</td>'+
							'</tr>'+
                            //begin: --------------row and column-----------------
                            '<tr>'+
								'<td style="text-align:left;">' +
									'<span style="float:left;">' +
									'<label for="theRowInput' + matrixIndex + '">' + label_Rows + ':</label></span>' +
									'<div class="requiredInput" style="float:right;"><div class="requiredBlock"></div>' + 
							        	'<input type="text" style="width:100px" maxlength="2" id="theRowInput' + matrixIndex + '" onchange="checkSizeInput(this);" onkeyup="checkSizeInput(this);" onpaste="checkSizeInput(this);" ondragenter="checkSizeInput(this);" oncontextmenu="return false;" />' +
										'<div class="erMsg" style="display:none; font-size:12px;">' +
                                        	'<font color="#C00 !important">Must not be null</font>' +
                                    	'</div>' +
                                	'</div>' +
                             	'</td>' +
                             '</tr>' +
                             '<tr>' +
                             	'<td style="text-align:left;">' +  	
									'<span style="float:left;">' +
									'<label for="theColumnInput' + matrixIndex + '">' + label_Column + ':</label></span>' +
									'<div class="requiredInput" style="float:right;"><div class="requiredBlock"></div>' + 
							        	'<input type="text" style="width:100px;" maxlength="2" id="theColumnInput' + matrixIndex + '" onchange="checkSizeInput(this);" onkeyup="checkSizeInput(this);" onpaste="checkSizeInput(this);" ondragenter="checkSizeInput(this);" oncontextmenu="return false;" />' +
							        	'<div class="erMsg" style="display:none; font-size:12px;">' +
                                        	'<font color="#C00 !important">Must not be null</font>' +
                                    	'</div>' +
									'</div>' +
								'</td>' +
							'</tr>' + 
							//end: -------------row and column------------------
                            '<tr>' +
                                '<td>' +
                                	'<div style="text-align:left;"> '+label_Specialization+':</div>'+
                                    '<div id="matrix' + matrixIndex + '" name="matrixSpecial" style=" height: 300px; width: 250px; border: 1px solid #000; overflow:auto;color: #fff;" class="specialCls heightCls ui-droppable">' +
                                        '<div class="erMsg" style="display:none; font-size:12px;">' +
								        		'<font color="#C00 !important"><strong>Error: </strong>Please select at least one Speciality!</font>' +
								    		'</div>' +    
                                        '<ul class="targerDropUlCls matrixDropUlCls ui-sortable">';
                               var counter = parseInt(specialCounter);
                               for(var i =  0; i < counter; i++){
                                   tableStr += '<li id="" class="matrixDraggable ui-state-disabled"></li>';
                               }      
                                            
                                        tableStr += '</ul>' +
                                         
                                    '</div>' +
								                                   
                                '</td>' +
                            '</tr>' +
                            //'<tr>' +
                              //  '<td><input type="checkbox" name="isChangeToFinal" disabled="disabled">Change to Final</input></td>' +
                            //'</tr>' + 
                           // '<tr>' +
                           //     '<td style="text-align: left;">' + selectOption +
                           // '</tr>' +
                            //
                            //'<tr>' +
                            //     '<td style="text-align: left;">' + 
                            //    '<span class="matrixTableLabel">Lifecycle: </span><span style="float:right;">' +
                            //     '<div class="requiredInput">' +
							//		'<div class="requiredBlock">' +
							//		'</div>'
	                        //        + lcSelectList +
							//	    '<div class="erMsg" style="display:none; font-size:12px;">' +
							//	        '<font color="#C00 !important"><strong>Error: </strong>You must select one Value!</font>' +
							//	    '</div>' +
							//	'</div></span>' +
							//	'</td>' +
                            //'</tr>' +
                            //
                        '</table>';
    
    //append table to page
    j$('#matriDivId').append(tableStr);
    
    j$('#matrixIndex').val(matrixIndex);
}
 

function matrix_stop_fn(event, ui){
	var parentUl = j$(this);
	var counter = 0;
	// //console.log(parentUl.attr('class'));
	// //console.log('tagName : ' + j$(this).get(0).tagName);
	
	var tagName = j$(this).get(0).tagName;
	if(tagName == 'DIV'){
		parentUl = j$("ul", j$(this));
	}
	

	j$("li", parentUl).each(function(){
		if(!j$(this).text().trim()){
            j$(this).remove();
            counter ++;
        }
	});
	
	for(var i = 0; i < counter; i++){
		 parentUl.append('<li id="" class="matrixDraggable ui-state-disabled"></li>');
	}
	
	checkAllMatrixSpecialDiv();
}

//Begin: added by Peng Zhu 
function matrix_sort_start_fn(event, ui){
	var j$this = j$(this);
	//console.log('tagName : ' + j$this.get(0).tagName);
	var j$div = j$(getParent(j$this.get(0), 'DIV'));
	if(!j$div.hasClass('overflowHidden')){
		//console.log('dk');
		j$div.addClass('overflowHidden');
	}
}

function removeGivenMatrix(obj){
	var j$table = j$(obj).parent().parent().parent().parent();
	
	j$("li", j$table).each(function(){
		if(j$(this).attr('id')){
			var liId = j$(this).attr('id');
			j$("#specialDivId li[id='" + liId + "']").removeClass('ui-state-disabled').removeClass('special-state-disabled').css({'opacity': 1});
			j$("#specialDivId li[id='" + liId + "']").off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
		}
	});
	
	j$table.remove();
	
	var matrixIndex = parseInt(j$('#matrixIndex').val()) - 1;
	j$('#matrixIndex').val(matrixIndex);
	
	refreshMatrixIndex();
}

function matrix_stop_fn_void(){}

function refreshMatrixIndex(){
	var matrixIndex = 0;
	j$("#matriDivId table span[class='matrixIndexSpan']").each(function(){
		matrixIndex ++;
		j$(this).text(matrixIndex);
	});
}

/**
 * reset the div "#matrixDivId" width when brower size change
 *
 @author  Peng Zhu
 @created 2013-06-21
 @version 1.0
 *
 @changelog
 * 2013-06-21 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
function resetMatriDivIdSize(){
	//#matriDivId
	var windowWidth = 0;
	
	if (window.innerWidth)
		windowWidth = window.innerWidth;
	else if ((document.body) && (document.body.clientWidth))
		windowWidth = document.body.clientWidth;
	else windowWidth = window.screen.width;
	
	if(windowWidth < 800) windowWidth = 800;
	
	var mainDivWidth = windowWidth - j$("#matriDivId").offset().left -80;//

	j$('#matriDivId').css("max-width", mainDivWidth);
	j$('#specialDivId').css("max-width", mainDivWidth);
}

//** assist function to find element's parent with specified tag name **//
function getParent(el,p){
	do{
		el = el.parentNode;
	}while(el && el.nodeName != p)
	return el;
}

/**
 * This function is used to validate and save all the matrix info
 *
 @author  Peng Zhu
 @created 2013-06-21
 @version 1.0
 *
 @changelog
 * 2013-06-21 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
function savaMatrixsInPage(){
    showLoading();
    if(checkAllRequiredFields(true)){
        IMP_BI_ExtMatrixDefinition.saveMatrixData(collectMatrixValues(false), function(data){
            j$('#htmlEntity').html(data);
            data = j$('#htmlEntity').text();
            data = j$.parseJSON( data );
            
            if(data && !data.success){
                j$("div[id='errorMsg']").html(data.message);
                j$("div[id='errorMsg']").show();
                j$('#loading-curtain-div').hide();
            }
            else{
                cancel();
            }
        });
    }else{
        j$('#loading-curtain-div').hide();
    }
}

/**
 * This function is used to validate, save all the matrix info and then invoke the calculate matrix function in heroku
 *
 @author  Peng Zhu
 @created 2013-06-21
 @version 1.0
 *
 @changelog
 * 2013-06-21 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 * 
 * 2014-04-01 Jefferson Escobar <jescobar@omegacrmconsulting.com>
 * - Modified
 * 
 */
function savaAndCalMatrixsInPage(){
    showLoading();
    if(checkAllRequiredFields(true)){
    	
    	//Chekc if there are not matrices to calculate
    	var qMatrices = 0;
    	j$("input[name='matrixChecked']").each(function(){
    		if(j$(this).is(':checked')){
    			qMatrices++;
    		}
		});
    	
    	if(qMatrices == 0){
             if(confirm(msgMatrix2CalculateWarn)){
            	 IMP_BI_ExtMatrixDefinition.saveMatrixData(collectMatrixValues(true), function(data){
                     j$('#htmlEntity').html(data);
                     data = j$('#htmlEntity').text();
                     data = j$.parseJSON( data );
                     
                     if(data && !data.success){
                         j$("div[id='errorMsg']").html(data.message);
                         j$("div[id='errorMsg']").show();
                         j$('#loading-curtain-div').hide();
                     }
                     else{
                         cancel();
                     }
                 });
             }else{
            	 j$('#loading-curtain-div').hide();
             }
    	}else{
    		IMP_BI_ExtMatrixDefinition.saveMatrixData(collectMatrixValues(true), function(data){
                j$('#htmlEntity').html(data);
                data = j$('#htmlEntity').text();
                data = j$.parseJSON( data );
                
                if(data && !data.success){
                    j$("div[id='errorMsg']").html(data.message);
                    j$("div[id='errorMsg']").show();
                    j$('#loading-curtain-div').hide();
                }
                else{
                    calculateMatrixInPage();
                }
            });
    	}
    }else{
        j$('#loading-curtain-div').hide();
    }
}


/**
 * This function is used to populate columns value for Launch template
 *
 @author  Peng Zhu
 @created 2013-06-21
 @version 1.0
 *
 @changelog
 * 2013-06-21 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
function populateColumnsForLaunchTemplate(obj, isInit){
	//console.log('isInit : ' + isInit);
	var j$this = j$(obj);
	
	var jsonMTObj = jsonMTofLaunch[j$this.val()];
	var j$table = j$(getParent(j$this.get(0), 'TABLE'));
	var j$inputRow = j$("input[id^='theRowInput']", j$table);
	var j$inputColumn = j$("input[id^='theColumnInput']", j$table);
	var j$inputLaunch = j$("input[id^='matrixLaunchPhase']", j$table);
	var j$inputDPA = j$("input[name$='matrixDPA']", j$table);
	var j$inputAllCust = j$("input[name$='matrixAllCustomers']", j$table);
	
	if(jsonMTObj){
		//console.log('lctId : ' + jsonMTObj.lctId + ', isLaunch : ' + jsonMTObj.isLaunch + ', Row : ' + jsonMTObj.lctRow + ', Column : ' + jsonMTObj.lctColumn);
		//j$inputRow.val(jsonMTObj.lctRow);
		//j$inputColumn.val(jsonMTObj.lctColumn);
		if(!isInit || j$.trim(j$inputRow.val()) == '') j$inputRow.val(jsonMTObj.lctRow);
		if(!isInit || j$.trim(j$inputColumn.val()) == '') j$inputColumn.val(jsonMTObj.lctColumn);
		
		//j$inputRow.val(jsonMTObj.lctRow);
		//j$inputColumn.val(jsonMTObj.lctColumn);
		
		if(jsonMTObj.isLaunch){
			//j$inputColumn.val(jsonMTObj.lctColumn);
			//j$inputRow.attr('disabled', 'disabled');
			j$inputColumn.attr('disabled', 'disabled');
			j$inputColumn.attr('title', errMsg_Launch);
			j$inputLaunch.prop('checked',true);
			//j$inputDPA.prop('checked',false);
			//j$inputDPA.attr('disabled', 'disabled');
			j$inputAllCust.removeAttr('disabled');
		}
		else{
		//	j$inputRow.removeAttr('disabled');
			j$inputColumn.removeAttr('disabled');
			j$inputColumn.removeAttr('title');
			j$inputLaunch.prop('checked',false);
			//j$inputDPA.removeAttr('disabled');
		}
	}
	else{
	//	j$inputRow.removeAttr('disabled');
		j$inputColumn.removeAttr('disabled');
		j$inputColumn.removeAttr('title');
	}
	
	hideErrMsgWhenChangeMt(j$this.get(0));
}
 
/**
 * This function is used to check if each matrix speciality has at least one value
 *
 @author  Peng Zhu
 @created 2013-06-21
 @version 1.0
 *
 @changelog
 * 2013-06-21 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
function checkAllMatrixSpecialDiv(){
	j$("div[name='matrixSpecial']").not(".finalMatrix").each(function(){
        var j$this = j$(this);
        var isNull = true;
        
        j$("li", j$this).each(function(){
        	var liId = j$(this).attr('id');
        	if(liId && j$.trim(liId) != '' ){ isNull = false;}
        });
        
        //get DPA checkbox value
		var j$table = j$(getParent(j$this.get(0), 'TABLE'));
        var dpa = j$table.find("input[name$='matrixDPA']").get(0);
        if(dpa && dpa.checked){
            isNull = false;
        }
        if( j$("[id$='AccountMatrixCK']").prop('checked') ) isNull = false;//added by leijun 
        
        if(isNull){
        	j$this.siblings('.erMsg').find('font').text(errMsg_Special).parent().show();
        	j$this.children('.erMsg').find('font').text(errMsg_Special).parent().show();
        }else{
        	j$this.siblings('.erMsg').hide();
        	j$this.children('.erMsg').hide();
        }
    });
}

function checkDpaForAllCustomer(obj){
	if(obj){
		var j$allCustomers = j$(getParent(obj, 'TBODY')).find('input[name$=matrixAllCustomers]');
		var j$lauchPhase = j$(getParent(obj, 'TBODY')).find("input[id^='matrixLaunchPhase']");
		var j$divCurrSpecial = j$(getParent(obj, 'TBODY')).find('div.specialCls');
		var j$selectMT = j$(getParent(obj, 'TBODY')).find('select[name$=matrixTemplate]');
		
		if(obj.checked){
			
			j$("li.pgover", j$divCurrSpecial).each(function(){
				var duplicateCounter = 0, currentId = j$(this).attr('id'), j$this = j$(this);
				
				//j$("div[name='matrixSpecial'] li").each(function(){
				//	var liId = j$(this).attr('Id');
	       		//	if(liId && liId == currentId) duplicateCounter ++;
	    		//}); 
	
	
				var j$lis = j$("#specialDivId").find('li');
	        	j$lis.each(function(){
	        		if(currentId == j$(this).attr('id')){
	        			if(duplicateCounter < 2){
	        				j$(this).removeClass('ui-state-disabled').removeClass('special-state-disabled').css({'opacity': 1});
		        			j$(this).off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
	        			}
	        			j$this.attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
	        		}
	        	});
			});
		
			//j$allCustomers.removeAttr('checked').attr('disabled', 'disabled');
			//j$lauchPhase.prop('checked',false);
			//j$divCurrSpecial.droppable({ disabled: true });//Set disabled droppable div
			j$selectMT.attr('disabled', 'disabled');
			j$selectMT.val('');
		}
		else{
			//j$allCustomers.removeAttr('disabled');
			//j$divCurrSpecial.droppable({ disabled: false });//Set enable droppable div
			j$selectMT.removeAttr('disabled', 'disabled').val('');
		}
	}
}


/**
 * Check all the matrices for being calculated
 * @param obj is checked or isn't for checking all the matrices in the page
 * @return
 */
function checkAllMatrices(obj){
	if(obj && obj.checked){//Checked all matrices
		j$("input[name='matrixChecked']").each(function(){
			j$(this).prop('checked',true);
		});
	}else{//Unchecked all matrices
		j$("input[name='matrixChecked']").each(function(){
			j$(this).prop('checked',false);
		});
	}
}


/**
 * Fill out specialties on matrix from matrix template selected
 * 
 * @param obj Picklist matrix template
 * @param template info record selected
 */
function setSpecialtiesFromTemplate(obj,template){
	var j$divTarget = j$(getParent(obj, 'TBODY')).find('div.specialCls'), targetId, j$dragTarget, j$dragCurrent;
	var specialties  = (template.Specialty_Ids_BI__c!=null&&j$.trim(template.Specialty_Ids_BI__c)!='') ? template.Specialty_Ids_BI__c : null;
	var isIncluded = false;
	var spAllIncluded = 0;
	
	if(specialties){
		//Check if there are specialties inclued in the matrix definition 
		j$divTarget.find('li').each(function(){
			var spId = j$(this).attr('Id');
			
			if(j$.trim(spId) != '' && specialties.indexOf(spId) > -1){
				alert(msgSpecialtiesIncluded);
				isIncluded = true;
				return false;
				//console.log(':: Specilaty: ' + j$(this).html());
			}
		});
		
		j$("li:not(.special-state-disabled)", j$("#specialDivId")).each(function(){
			j$dragCurrent = j$(this);
			var currentId = j$dragCurrent.attr('id');
			var hasFinded = false;
			var j$div = j$(getParent(j$dragCurrent.get(0), 'DIV'));
			var countSPIncluded = 0;
			
			if(specialties.indexOf(currentId) > -1){
				//console.log(':: Specialty: ' + currentId);
				if(j$div.hasClass('overflowHidden')){
					j$div.removeClass('overflowHidden');
				}
				
				j$divTarget.find('li').each(function(){
					if(typeof(j$(this).attr('id')) == 'undefined' || j$(this).attr('id') == ''){	//cleart old channel
						if(!hasFinded){
							hasFinded = true;
							j$dragTarget = j$(this), targetId = j$(this).attr('id');
						}
					}
				});
				//if has not find any available li, do nothing
				if(typeof(j$dragTarget) != 'undefined'){
					j$dragTarget.attr({'id': currentId})
						.addClass('pgover').html(j$dragCurrent.find('span').attr('title')).removeClass('ui-state-disabled');
					j$dragCurrent.addClass('ui-state-disabled').addClass('special-state-disabled').css({'opacity': 1});
					j$dragCurrent.removeClass('pgover').off('mouseenter mouseleave');
				}
				//Begin: added by Peng Zhu 2013-08-30
				else{
					j$dragTarget = j$('<li id="' + currentId + '" class="matrixDraggable pgover">' + j$dragCurrent.find('span').attr('title') + '</li>');
					j$dragCurrent.addClass('ui-state-disabled').addClass('special-state-disabled').css({'opacity': 1});
					j$dragCurrent.removeClass('pgover').off('mouseenter mouseleave');
					j$(drag.target).find('ul').append(j$dragTarget);
				}
			}
		});
		
		//Validate if there are specialties available in the template to fill out the form
		spAllIncluded = j$divTarget.find('li.pgover').length;
		if(spAllIncluded == 0){
			alert('All the specialties for this template have  already included in others definitions');
		}
	}
}


function checkAllCustomers(obj){
	//get true or false
	if(obj){
		var j$dpa = j$(getParent(obj, 'TBODY')).find('input[name$=matrixDPA]');
		var j$lauchPhase = j$(getParent(obj, 'TBODY')).find("input[id^='matrixLaunchPhase']");
		
		if(obj.checked){
			var j$divTarget = j$(getParent(obj, 'TBODY')).find('div.specialCls'), targetId, j$dragTarget, j$dragCurrent;
			
			j$("li:not(.special-state-disabled)", j$("#specialDivId")).each(function(){
				j$dragCurrent = j$(this);
				var currentId = j$dragCurrent.attr('id');
				
				var hasFinded = false;
				
				//added by Peng Zhu 2013-06-25 for overflowHidden
				var j$div = j$(getParent(j$dragCurrent.get(0), 'DIV'));
				
				if(j$div.hasClass('overflowHidden')){
					j$div.removeClass('overflowHidden');
				}
				
				j$divTarget.find('li').each(function(){
					if(typeof(j$(this).attr('id')) == 'undefined' || j$(this).attr('id') == ''){	//cleart old channel
						if(!hasFinded){
							hasFinded = true;
							j$dragTarget = j$(this), targetId = j$(this).attr('id');
						}
					}
				});
				//if has not find any available li, do nothing
				if(typeof(j$dragTarget) != 'undefined'){
					j$dragTarget.attr({'id': currentId})
						.addClass('pgover').html(j$dragCurrent.find('span').attr('title')).removeClass('ui-state-disabled');
					j$dragCurrent.addClass('ui-state-disabled').addClass('special-state-disabled').css({'opacity': 1});
					j$dragCurrent.removeClass('pgover').off('mouseenter mouseleave');
				}
				//Begin: added by Peng Zhu 2013-08-30
				else{
					j$dragTarget = j$('<li id="' + currentId + '" class="matrixDraggable pgover">' + j$dragCurrent.find('span').attr('title') + '</li>');
					j$dragCurrent.addClass('ui-state-disabled').addClass('special-state-disabled').css({'opacity': 1});
					j$dragCurrent.removeClass('pgover').off('mouseenter mouseleave');
					j$(drag.target).find('ul').append(j$dragTarget);
				}
				//End: added by Peng Zhu 2013-08-30
			});
			j$divTarget.siblings('.erMsg').hide();
			//j$dpa.removeAttr('checked').attr('disabled', 'disabled');
		}
		/**else{
			if(!j$lauchPhase.is(":checked")){
				j$dpa.removeAttr('disabled');
			}
		}*/
	}

	//if true -- get all available special and set them to current matrix
	
	//DPA disable
	
}

/**
 * This function is used to check if each matrix speciality has at least one value
 *
 @author  Peng Zhu
 @created 2013-06-21
 @version 1.0
 *
 @changelog
 * 2013-06-21 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
function getLaunchTemplateValue(j$obj){
	j$this = j$obj;
	
   	var j$table = j$(getParent(j$this.get(0), 'TABLE'));
	var j$mtSelect = j$("select[name$='theMTSelecrList']" ,j$table);
	var jsonMTObj = jsonMTofLaunch[j$mtSelect.val()];
	if(jsonMTObj && jsonMTObj.isLaunch){
		return jsonMTObj.lctColumn;
	}
	
	return '';
}
/**
 * This function is used to hide the column errmsg when template select changed
 *
 @author  Peng Zhu
 @created 2013-06-21
 @version 1.0
 *
 @changelog
 * 2013-06-21 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
function hideErrMsgWhenChangeMt(obj){
	j$this = j$(obj);
	
   	var j$table = j$(getParent(j$this.get(0), 'TABLE'));
   	
   	var j$inputColumn = j$("input[id^='theColumnInput']", j$table), j$errMsg = j$inputColumn.siblings('.erMsg');
   	
   	j$errMsg.hide();
   	
   	var v = j$inputColumn.val();
	
	if(typeof v == 'undefined') v = ''; 
	v = j$.trim(v.replace(/[^\d]/g, ''));
	
    if(v != ''){
		v = parseInt(v);

		if(v && v < 1 || v > 21){
			j$errMsg.find('font').text(errMsg_Column).parent().show();
		}
    }
    else{
       j$errMsg.find('font').text(errMsg_Column_Null).parent().show();
    }
                    
    j$inputColumn.val(v);
}

/**
 * Set disabled matrix final fields
 *
 @author  Peng Zhu
 @created 2013-06-21
 @version 1.0
 *
 @changelog
 * 2013-06-21 Peng Zhu <peng.zhu@itbconsult.com>
 * - Created
 */
//
function disableAllFinalMatrix(){
	j$("#matriDivId table.finalMatrix input[name$='matrixDPA']").attr('disabled', 'disabled');
	j$("#matriDivId table.finalMatrix input[name$='matrixAllCustomers']").attr('disabled', 'disabled');
	j$("#matriDivId table.finalMatrix input[name$='matrixAdoptionLabel']").attr('disabled', 'disabled');
	j$("#matriDivId table.finalMatrix input[name$='matrixPotentialLabel']").attr('disabled', 'disabled');
}