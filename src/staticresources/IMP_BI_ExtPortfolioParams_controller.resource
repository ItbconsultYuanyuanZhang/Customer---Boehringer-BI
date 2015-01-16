function showWeightValueIn100(item){
	if(item.value > 100){
		alert('The value must between 1 and 100');
		item.value = 100;
	}
	else if(item.value < 1){
		alert('The value must between 1 and 100');
		item.value = 1;
	}
	else if(!item.value){
		alert('The value must between 1 and 100');
		item.value = 1;
	}
}

function showPriorityValueIn100(item){
	if(item.value > 100){
		alert('The value must between 0 and 100');
		item.value = 100;
	}
	else if(item.value < 0){
		alert('The value must between 0 and 100');
		item.value = 0;
	}
	else if(!item.value){
		alert('The value must between 0 and 100');
		item.value = 0;
	}
}

function register_event(){
	j$('#matricesSeletorDivId .draggable').off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
	
	var sortable_options = {containment : '.mainContentDiv', cancel : '.ui-state-disabled', cursor : 'move'},//portfolioDiv
	droppable_options = {hoverClass : 'hoverTarget', activeClass : 'dropTarget', cursor : 'move'};
		
	var special_drop = j$('#matricesSeletorDivId ul.dropUlCls').sortable({
			opacity: 0.7, revert: true,
			cursor : sortable_options.cursor,
			cancel: sortable_options.cancel,
			containment: sortable_options.containment,
			helper: 'clone',
			appendTo: document.body
			//delay: 300
			//stop: matrix_stop_fn_void
    });
    
    

	j$("div[id^='portfolio']").each(function(){
		j$(this).sortable({
			items: "li:not(.ui-state-disabled)",
			opacity: 0.7, 
			revert: true,
			cursor : sortable_options.cursor,
			cancel: sortable_options.cancel,
			containment: sortable_options.containment,
			helper: 'clone',
			appendTo: document.body,
			stop: matrix_stop_fn
    	});
    	var thisDiv = j$(this);
    	thisDiv.closest('table').find('[id$="pfAccountMatrix"]').on('click',function(event){
    		var thisCheckbox = this;
    		if (this.checked) {
    			var firstRun = true;
    			thisDiv.find('li:not(.ui-state-disabled)').filter(function(){return j$(this).hasClass('noCurrentMatrix');}).each(function(){
    				if (firstRun) {
    					if (confirm('All none account matrix will be deleted. Are you sure?')) {
    						firstRun = false;
    					} else {
    						thisCheckbox.checked = false;
    						return false;
    					}
    				}
    				if (!firstRun) {
	    				thisDiv.find('li:not(.ui-state-disabled)').filter(function(){return j$(this).hasClass('noCurrentMatrix');}).each(function(){
	    					var currentId = j$(this).attr('id');
	    					var thisLi = j$(this);
	    					
	    					j$("#matricesSeletorDivId").find('li').each(function(){
	    						if(currentId == j$(this).attr('id')){
				        			j$(this).removeClass('ui-state-disabled').removeClass('special-state-disabled').css({'opacity': 1});
				        			j$(this).off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
				        			thisLi.attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover').removeClass('noCurrentMatrix');
				        		}
	    					});
	    					
	    				});
	    			}
    			});
    			
    		}
    	});
	});
    
	j$("div[id^='portfolio']").droppable({
        accept:".draggable, .matrixDraggable",
        hoverClass: droppable_options.hoverClass,
        activeClass: droppable_options.activeClass,
        //liveSelector:"#specialDivId",
        drop : droppable_drop_fn
    });
    
	j$("#matricesSeletorDivId").droppable({
        accept:".matrixDraggable",
        hoverClass: droppable_options.hoverClass,
        activeClass: droppable_options.activeClass,
        //liveSelector:"#matriDivId",
        drop : droppable_drop_fn
    });
    
    j$("#accountMatrix").on("change", function(){
    	if (confirm('All changes will be lost. Are you sure?')) {
    		showLoading();
    		console.log('1: ' + j$("#accountMatrix").get(0).checked);
    		j$("[id$='accMatrixCheck']").val(j$("#accountMatrix").get(0).checked);
    		refreshPage();
    	} else {
    		if (j$("#accountMatrix").get(0).checked) {
    			j$("#accountMatrix").get(0).checked = false;
    		} else {
    			j$("#accountMatrix").get(0).checked = true;
    		}
    		return false;
    	}
    });
}

function e_over_draggable(e){
	var j$this = j$(this);
	switch(e.type){
		case 'mouseenter': j$this.addClass('pgover'); break;
		default : j$this.removeClass('pgover'); break;
	}
}


function droppable_drop_fn(drag,drop){
	//console.log('In drop function....');
	var j$dragCurrent = j$(drop.helper.context), conditionId, currentId = j$.trim(j$dragCurrent.attr('id')), 
		parentId = j$.trim(j$dragCurrent.parent().parent().attr('id'));
	//console.log(j$(drop.helper.context));
	//console.log(j$dragCurrent.parent().parent().attr('id'));
	//console.log(drag);
	//console.log(drop);
	//console.log('j$dragCurrent');
	//console.log(j$dragCurrent);
	if(typeof(parentId) != 'undefined' && j$.trim(parentId) != '' && (parentId.indexOf('portfolio') > -1)){
		conditionId = 'pfDivId';
	}
	else{
		conditionId = parentId;
	}

	var targetId = j$(drag.target).attr('id');
	//console.log('Current : ' + j$.trim(j$dragCurrent.parent().parent().attr('id')));
	//console.log('targetId : ' + targetId);
	
	if((targetId.indexOf('portfolio') > -1) && (parentId.indexOf('portfolio') > -1)){
		conditionId = 'horizontalMove';
	}
	
	if(typeof(targetId) != 'undefined' && typeof(parentId) != 'undefined' && j$.trim(targetId) != '' && j$.trim(parentId) != '' && targetId != parentId
		&& typeof(currentId) != 'undefined' && j$.trim(currentId) != ''){
		//console.log('In cal....');
		//console.log('currentid: ' + currentId);
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
				
				/*
				var ck = j$(drag.target).closest('tbody').find("[id $= 'pfAccountMatrix']")[0];
				if (ck.checked && j$dragCurrent.hasClass('noCurrentMatrix')) {
					
					alert('You can only move account matrix to this portofolio!');
					break;
				}
				*/
				
				//console.log('drag.target');
				//console.log(j$(drag.target).closest('tbody'));
				//console.log('ck');
				//console.log(ck);
				//console.log(ck.checked);
				//console.log(j$dragCurrent.hasClass('accountMatrix'));
				
				
				
				
				
				//console.log(j$dragCurrent.text());
				//console.log(j$dragCurrent.html());
				//if has not find any available li, do nothing
				if(typeof(j$dragTarget) != 'undefined'){
					/*j$dragTarget.attr({'id': currentId})
						.addClass('pgover').html(j$dragCurrent.text()).removeClass('ui-state-disabled');*/
					//yy modified text to html
					
					
					j$dragTarget.attr({'id': currentId})
						.addClass('pgover').html(j$dragCurrent.html()).removeClass('ui-state-disabled');
						
					if (j$dragCurrent.hasClass('noCurrentMatrix')) {
						j$dragTarget.addClass('noCurrentMatrix');
					}
							
					//console.log('dragtext1: ' + j$(('#' + parentId + ' #'+currentId)).text());
					//j$(('#' + parentId + ' #'+currentId)).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
					
					j$('div[id="'+parentId+'"]' + ' #'+currentId).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover').removeClass('noCurrentMatrix');
					
					//console.log('hier');
				}
				
				break;
			
			case 'pfDivId' : 
			//console.log('in pfDivId ......');
			
				var j$lis = j$(drag.target).find('li');
	        	j$lis.each(function(){
	        		if(currentId == j$(this).attr('id')){
	        			j$(this).removeClass('ui-state-disabled').removeClass('special-state-disabled').css({'opacity': 1});
	        			j$(this).off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
	        			
	        			//console.log('#' + parentId + ' #'+currentId);
	        			//console.log(j$('div[id="'+parentId+'"]' + ' #'+currentId).text());
	        			
	        			
	        			///div[id='portfolio1.0']
	        			j$('div[id="'+parentId+'"]' + ' #'+currentId).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover').removeClass('noCurrentMatrix');
	        			//console.log('dragtext2: ' + j$('#' + parentId + ' #'+currentId).attr({'id':''}).text());
	        		}
	        	});
				break;
				
			case 'matricesSeletorDivId' : 
				//console.log('in matricesSeletorDivId .....');
				//find a available li -- id is null
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
				
				/*
				var ck = j$(drag.target).closest('tbody').find("[id $= 'pfAccountMatrix']")[0];
				
				if (ck.checked && !j$dragCurrent.hasClass('accountMatrix')) {
					
					alert('You can only move account matrix to this portofolio!');
					hasFinded = false;
				}
				*/
				//console.log('drag.target');
				//console.log(j$(drag.target).closest('tbody'));
				//console.log('ck');
				//console.log(ck);
				//console.log(ck.checked);
				//console.log(j$dragCurrent.hasClass('accountMatrix'));
				
				//console.log(typeof(j$dragTarget));
				//console.log(hasFinded);
				//if has not find any available li, do nothing
				if(typeof(j$dragTarget) != 'undefined' && hasFinded
					&& typeof(currentId) != 'undefined' && j$.trim(currentId) != ''){
				
					//j$dragTarget.attr({'id': currentId})
						//.addClass('pgover').html(j$dragCurrent.text()).removeClass('ui-state-disabled');
					
					if (!j$dragCurrent.hasClass('currentMatrix')) {
						j$dragTarget.addClass('noCurrentMatrix');
					}
					
					
					j$dragTarget.attr({'id': currentId})
						.addClass('pgover').html(j$dragCurrent.html()).removeClass('ui-state-disabled');//2013-06-28 modified by Yuanyuan Zhang chenge text to html	
					
					
					j$dragTarget.find('.matrixTitleCls').css('display','');
					j$dragTarget.find('#currentCheckbox').remove();
					//console.log('xxx');
					//console.log(j$dragTarget);
					//console.log(j$dragTarget.find('＃currentCheckbox'));
					j$dragTarget.find('#cmNameSpan').addClass('matrixTitleCls mightOverflow');
					
					
					
						
					j$dragCurrent.addClass('ui-state-disabled').addClass('special-state-disabled').css({'opacity': 0.4});
					j$dragCurrent.removeClass('pgover').removeClass('noCurrentMatrix').off('mouseenter mouseleave');
					//yy added
					//console.log(j$dragCurrent.find('input').val());
					//var spanStr = '<span id="' + currentId + 'weight">' + j$dragCurrent.find('input').val() +'<span>' ;

					//comment out by Peng Zhu 2013-08-08 for adding full coverage field 
					//var spanStr = '<span class="spanInputCls">Weight:<input type="text" id="' + currentId + 'weight" value="" class="ui-state-disabled inputCls" onkeyup="inputCheck(this);" onblur="showWeightValueIn100(this);"/>'+ 
					//				'Priority:<input type="text" id="' + currentId + 'priori" value="" class="ui-state-disabled inputCls" onkeyup="inputCheck(this);" onblur="showPriorityValueIn100(this);"/></span>';//onblur="check100(this);"
					
					//added by Peng Zhu 2013-08-08 for adding full coverage field
					var spanStr = '<span class="spanInputCls"><span>Weight:</span><input type="text" id="' + currentId + 'weight" value="" class="ui-state-disabled inputCls" onkeyup="inputCheck(this);" onblur="showWeightValueIn100(this);"/>'+ 
									'<span style="margin-left:30px; padding-left:3px;">All Details Required:</span><input id="' + currentId + 'fullCoverage" type="checkbox" class="ui-state-disabled fullCoverageCb" />' + 
									//'<span style="padding-left:3px;">% Required Details:</span><input type="text" id="' + currentId + 'priori" value="0" class="ui-state-disabled inputCls" onkeyup="inputCheck(this);" onblur="showPriorityValueIn100(this);"/>' +
									'</span>';
					j$dragTarget.append(spanStr);
				}

				break;
			default :  break;
		}
	}
}

function check100(item){
	alert(item.value);
}

function inputCheck(obj){
	obj.value=obj.value.replace(/[^\d]/g,'');
	j$(obj).val(obj.value);
}


function matrix_stop_fn(event, ui){
	var parentUl = j$(this);
	var counter = 0;
	//console.log(parentUl.attr('class'));
	//console.log('tagName : ' + j$(this).get(0).tagName);
	
	var tagName = j$(this).get(0).tagName;
	if(tagName == 'DIV'){
		parentUl = j$("ul", j$(this));
	}
	
	
	j$("li", parentUl).each(function(){
		////console.log(j$(this).text().trim());
		if(!j$(this).text().trim()){
            j$(this).remove();
            counter ++;
        }
	});
	
	for(var i = 0; i < counter; i++){
		 parentUl.append('<li id="" class="matrixDraggable ui-state-disabled"></li>');
	}
}

function matrix_stop_fn_void(){}

function removeGivenPortfolio(obj){
	var j$table = j$(obj).parent().parent().parent().parent();
	
	j$("li", j$table).each(function(){
		if(j$(this).attr('id')){
			var liId = j$(this).attr('id');
			j$("#matricesSeletorDivId li[id='" + liId + "']").removeClass('ui-state-disabled').removeClass('special-state-disabled').css({'opacity': 1});
			j$("#matricesSeletorDivId li[id='" + liId + "']").off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
		}
	});
	
	j$table.remove();
	
	var pfIndex = parseInt(j$('#portfolioIndex').val()) - 1;
	j$('#portfolioIndex').val(pfIndex);
	
	refreshMatrixIndex();
}

function refreshMatrixIndex(){
	var pfIndex = 0;
	j$("#pfInnerTableDiv table span[class='pfIndexSpan']").each(function(){
		pfIndex++;
		j$(this).text(pfIndex);
	});
}

/**
 * collect the portfolio values on page
 * return : JSON Data
 */
function collectMatrixValues(){
/*
	var matrix = new Object();
	
	var arr = new Array();
	
	var mtIdArr = new Array();

	j$("#pfInnerTableDiv table").each(function(){
	
		var pfEditId = j$(this).attr('id');
		if(pfEditId && j$.trim(pfEditId) != ''){
			pfEditId = pfEditId.split('-')[1];
		}
		
		////console.log('pfEditId : ' + pfEditId);
	
		//portfolio name
	    var name = j$("input[name$='pfName']", j$(this)).val();
	    //portfolio number of FTE's
		var nfInput = j$("input[name$='nfInput']", j$(this)).val();
		//portfolio days in the field
		var dfInput = j$("input[name$='dfInput']", j$(this)).val();
		//portfolio calls per day
		var cdInput = j$("input[name$='cdInput']", j$(this)).val();
		//portfolio details per call
		var dcInput = j$("input[name$='dcInput']", j$(this)).val();
	    
	    
	    var column = j$("input[id^='theColumnInput']", j$(this)).val();
	    ////console.log('CCColumn : ' + column);
	    if(typeof(column) != 'undefined' && j$.trim(column) != ''){
	    	column = parseInt(column);
	    }
	    else{
	    	column = 0;
	    }
	    
	    var lifeCycle = j$("select[name$='theLCSelectList']", j$(this)).val();
	    var sMtId = j$("select[name$='theMTSelecrList']", j$(this)).val();
	    if(typeof(sMtId) != 'undefined' && j$.trim(sMtId) != ''){
	    	mtIdArr.push(sMtId);
	    }
	    
	    ////console.log('name: ' + name);
	    ////console.log('special: ' + special);
	    ////console.log('sMtId: ' + sMtId);
	    ////console.log('lifeCycle: ' + lifeCycle);
	    ////console.log('Row: ' + row);
	    ////console.log('Column: ' + column);
	    
	    if(typeof(name) != 'undefined' && name != ''){
	        var cm = new Object();
	        
	        if(matrixEditId && j$.trim(matrixEditId) != '') cm.mid = matrixEditId;
	        cm.name = name;
	        cm.special = special;
	        cm.lifeCycle = lifeCycle;
	        cm.tid = sMtId;
	        cm.row = row;
	        cm.column = column;
	        
	        arr.push(cm);
	    }
	});

	////console.log('MtIdArr : ' + mtIdArr.toString());

	matrix.productId = j$("select[id$='theProductList']").val();
	//matrix.tid = j$("select[id$='theTemplateList']").val();
	matrix.cid = cycleId;
	matrix.list_cm = arr;
	matrix.set_mtIds = mtIdArr;
	

	return JSON.stringify(matrix);
	*/
}

function addPortfolio(){
	var matrixIndex = parseInt(j$('#portfolioIndex').val()) + 1, tabstr='';
	
	tabstr += '<table style="display:inline-block;" class="portfolioTable">'+
				'<tr>'+
					'<td class="labelCol" colspan="2" style="text-align:center !important;">'+potoFolios +'<span style="padding-left:3px;" class="pfIndexSpan">'+matrixIndex+'</span><img title="delete this Portfolio" class="deleteMatrixImg" style="cursor:pointer; margin-left:5px; vertical-align:middle; height:15px; width:15px;" onclick="removeGivenPortfolio(this);" src="/img/func_icons/util/recycle.gif"></img></td>'+
				'</tr>'+
				'<tr>'+
					'<td class="labelCol">'+pName+':</td>'+
					'<td class="dataCol"><input type="text" id="pfNameInput"/></td>'+
				'</tr>'+
				/*'<tr>'+
                    '<td class="labelCol">'+pAccountMatrix+':</td>'+
                    '<td class="dataCol"><input type="checkbox" id="pfAccountMatrix" /></td>'+
                '</tr>'+*/
                
				'<tr>'+
					'<td colspan="2" style="width:364px">'+
						'<div id="portfolio'+matrixIndex+'" name="pfMatrices" style=" height: 100%; border: 1px solid #000; " class="specialCls heightCls ui-droppable">'+
							'<ul class="targerDropUlCls matrixDropUlCls ui-sortable">';
							var counter = parseInt(maxMatrixSize);
							for(var i = 0; i < counter;i++){
								tabstr += '<li id="" class="matrixDraggable ui-state-disabled"></li>';
							}
					tabstr +='</ul>'+
						'</div>'+
					'</td>'+
				'</tr>'+
				'<tr>'+
					'<td class="labelCol">'+pFTE+':</td>'+
					'<td class="dataCol"><input type="text" id="nfInput" value=""/></td>'+
				'</tr>'+
				'<tr>'+
					'<td class="labelCol">'+pDay+':</td>'+
					'<td class="dataCol"><input type="text" id="dfInput" value=""></input></td>'+
				'</tr>'+
				'<tr>'+
					'<td class="labelCol">'+pCall+':</td>'+
					'<td class="dataCol"><input type="text" id="cdInput" value=""></input></td>'+
				'</tr>'+
				'<tr>'+
					'<td class="labelCol">'+pDetail+':</td>'+
					'<td class="dataCol"><input type="text" id="dcInput" value=""></input></td>'+
				'</tr>'+
			'</table>';
	j$("#pfInnerTableDiv").append(tabstr);		
	j$('#portfolioIndex').val(matrixIndex);
}

function updateWeightInPro(obj){
	var weightValue = obj.value;
	var matchId = obj.id.substring(0, obj.id.length- 11);
	////console.log(matchId);
	j$("div[id ^='portfolio'] ul li span").each(function(){
		////console.log(this.id);
		var keyid = this.id;
		if(keyid.length > 10){
			if(keyid.substring(0,keyid.length - 6) == matchId){
				j$(this).text(weightValue);
			}
		}
	});
}

function collectPortfolioValues(){
	//ClsPortfolio
	var list_cpf = [];
	
	j$("#pfInnerTableDiv table").each(function(){
		var pf={},list_cmId=[],cpf = {};
		var pfname = j$("input[id$='pfNameInput']", j$(this)).val();
		if(pfname && j$.trim(pfname) != ''){
			var pfEditId = j$(this).attr('id');
			if(pfEditId && j$.trim(pfEditId) != ''){
				pfEditId = pfEditId.split('-')[1];
			}
			else{
				pfEditId = null;
			}
			pf.id = pfEditId;
			////console.log('pfEditId : ' + pfEditId);
			//portfolio name
		    pf.name = pfname;
		    //portfolio number of FTE's
			pf.Number_of_FTEs_BI__c = j$("input[id$='nfInput']", j$(this)).val();
			//portfolio days in the field
			pf.Number_of_days_in_the_field_BI__c = j$("input[id$='dfInput']", j$(this)).val();
			//portfolio calls per day
			pf.Number_of_calls_per_day_BI__c = j$("input[id$='cdInput']", j$(this)).val();
			//portfolio details per call
			pf.Numbers_of_details_per_call_BI__c = j$("input[id$='dcInput']", j$(this)).val();
			pf.Account_Matrices_BI__c = j$("input[id$='accountMatrix']").is(':checked') ? true : false;
			pf.Country_Code_BI__c = country;
			
			cpf.pf = pf;
			////console.log(pf);
			j$(this).find('li').each(function(){
				var cm={};
				////console.log(j$(this).attr('id'));
				////console.log(j$(this).find('input').val());
				var id = j$(this).attr('id');
				if(id && j$.trim(id)!=''){
					cm.maId = id;
					cm.weight = j$(this).find('input').eq(0).val();
					cm.fullCoverage = j$(this).find('input').eq(1).get(0).checked;
					//cm.priori = j$(this).find('input').eq(2).val();
					cm.priori = "0";
					//cm.weight = j$(this).find('input').val();
					
					
					//alert(j$(this).find('input').eq(0).val());
					//alert(j$(this).find('input').eq(1).val());
					//cm.combi = id + ','+j$(this).find('span').text();
					list_cmId.push(cm);
				}
			});
			cpf.list_cmId = list_cmId;
			list_cpf.push(cpf);
		}
		
		
	});
	var result={};
	result.cycId = cycId;
	result.list_cpf = list_cpf;
	////console.log(result);
	return JSON.stringify(result);
}