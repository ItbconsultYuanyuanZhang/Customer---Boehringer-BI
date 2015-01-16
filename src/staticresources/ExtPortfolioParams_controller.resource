function showWeightValueIn100(item){
	if(this.value > 100){
		alert('The value must between 1 and 100');
		this.value = 100;
	}
	else if(this.value < 1){
		alert('The value must between 1 and 100');
		this.value = 1;
	}
}

function showPriorityValueIn100(item){
	if(this.value > 100){
		alert('The value must between 0 and 100');
		this.value = 100;
	}
	else if(this.value < 0){
		alert('The value must between 0 and 100');
		this.value = 0;
	}
}

function register_event(){
	j$('#matricesSeletorDivId .draggable').off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
	
	var sortable_options = {containment : '#pfOuterTable', cancel : '.ui-state-disabled', cursor : 'move'},
	droppable_options = {hoverClass : 'hoverTarget', activeClass : 'dropTarget', cursor : 'move'};
		
	var special_drop = j$('#matricesSeletorDivId ul.dropUlCls').sortable({
			opacity: 0.7, revert: true,
			cursor : sortable_options.cursor,
			cancel: sortable_options.cancel,
			containment: sortable_options.containment,
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
			stop: matrix_stop_fn
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
}

function e_over_draggable(e){
	var j$this = j$(this);
	switch(e.type){
		case 'mouseenter': j$this.addClass('pgover'); break;
		default : j$this.removeClass('pgover'); break;
	}
}


function droppable_drop_fn(drag,drop){
	console.log('In drop function....');
	var j$dragCurrent = j$(drop.helper.context), conditionId, currentId = j$.trim(j$dragCurrent.attr('id')), 
		parentId = j$.trim(j$dragCurrent.parent().parent().attr('id'));
	console.log(j$(drop.helper.context));
	console.log(j$dragCurrent.parent().parent().attr('id'));
	console.log(drag);
	console.log(drop);
	if(typeof(parentId) != 'undefined' && j$.trim(parentId) != '' && (parentId.indexOf('portfolio') > -1)){
		conditionId = 'pfDivId';
	}
	else{
		conditionId = parentId;
	}

	var targetId = j$(drag.target).attr('id');
	console.log('Current : ' + j$.trim(j$dragCurrent.parent().parent().attr('id')));
	console.log('targetId : ' + targetId);
	
	if((targetId.indexOf('portfolio') > -1) && (parentId.indexOf('portfolio') > -1)){
		conditionId = 'horizontalMove';
	}
	
	if(typeof(targetId) != 'undefined' && typeof(parentId) != 'undefined' && j$.trim(targetId) != '' && j$.trim(parentId) != '' && targetId != parentId){
		console.log('In cal....');
		switch(conditionId){
			case 'horizontalMove' :
				console.log('horizontalMove');
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
				console.log(j$dragCurrent.text());
				console.log(j$dragCurrent.html());
				//if has not find any available li, do nothing
				if(typeof(j$dragTarget) != 'undefined'){
					/*j$dragTarget.attr({'id': currentId})
						.addClass('pgover').html(j$dragCurrent.text()).removeClass('ui-state-disabled');*/
					//yy modified text to html
					j$dragTarget.attr({'id': currentId})
						.addClass('pgover').html(j$dragCurrent.html()).removeClass('ui-state-disabled');	
					console.log('dragtext1: ' + j$(('#' + parentId + ' #'+currentId)).attr({'id':''}).text());
					//j$(('#' + parentId + ' #'+currentId)).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
					j$('#' + parentId + ' #'+currentId).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
					console.log('dragtext1: ' + j$(('#' + parentId + ' #'+currentId)).attr({'id':''}).text());
				}
				
				break;
			
			case 'pfDivId' : 
			console.log('in pfDivId ......');
			
				var j$lis = j$(drag.target).find('li');
	        	j$lis.each(function(){
	        		if(currentId == j$(this).attr('id')){
	        			j$(this).removeClass('ui-state-disabled').removeClass('special-state-disabled').css({'opacity': 1});
	        			j$(this).off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
	        			//console.log('dragtext2: ' + j$('#'+currentId));
	        			
	        			console.log('#' + parentId + ' #'+currentId);
	        			j$('#' + parentId).find('li').each(function(){
	        				alert(this.id);
	        			});
	        			//console.log(j$(this).attr('id'));
	        			//j$(('#' + parentId + ' #'+currentId)).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
	        			
	        			j$('#' + parentId + ' #'+currentId).attr({'id':''}).html('').addClass('ui-state-disabled').removeClass('pgover');
	        			console.log('dragtext2: ' + j$('#' + parentId + ' #'+currentId).attr({'id':''}).text());
	        		}
	        	});
				break;
				
			case 'matricesSeletorDivId' : 
				console.log('in matricesSeletorDivId .....');
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
				//if has not find any available li, do nothing
				if(typeof(j$dragTarget) != 'undefined'){
					j$dragTarget.attr({'id': currentId})
						.addClass('pgover').html(j$dragCurrent.text()).removeClass('ui-state-disabled');
					j$dragCurrent.addClass('ui-state-disabled').addClass('special-state-disabled').css({'opacity': 0.4});
					j$dragCurrent.removeClass('pgover').off('mouseenter mouseleave');
					//yy added
					console.log(j$dragCurrent.find('input').val());
					//var spanStr = '<span id="' + currentId + 'weight">' + j$dragCurrent.find('input').val() +'<span>' ;

					var spanStr = '<span class="spanInputCls">Weight:<input type="text" id="' + currentId + 'weight" value="" class="ui-state-disabled inputCls" onkeyup="inputCheck(this);" onblur="check100(this);"/></span>';
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
	console.log(parentUl.attr('class'));
	console.log('tagName : ' + j$(this).get(0).tagName);
	
	var tagName = j$(this).get(0).tagName;
	if(tagName == 'DIV'){
		parentUl = j$("ul", j$(this));
	}
	
	
	j$("li", parentUl).each(function(){
		console.log(j$(this).text().trim());
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



function addPortfolio(){
	var matrixIndex = parseInt(j$('#portfolioIndex').val()) + 1, tabstr='';
	
	tabstr += '<table style="display:inline-block;" class="portfolioTable">'+
				'<tr>'+
					'<td class="labelCol" colspan="2" style="text-align:center !important;">Portfolio <span style="padding-left:3px;" class="pfIndexSpan">'+matrixIndex+'</span><img title="delete this Portfolio" class="deleteMatrixImg" style="cursor:pointer; margin-left:5px; vertical-align:middle; height:15px; width:15px;" onclick="removeGivenPortfolio(this);" src="/img/func_icons/util/recycle.gif"></img></td>'+
				'</tr>'+
				'<tr>'+
					'<td class="labelCol">Name:</td>'+
					'<td class="dataCol"><input type="text" id="pfNameInput"/></td>'+
				'</tr>'+
				'<tr>'+
					'<td colspan="2">'+
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
					'<td class="labelCol">Number of FTE\'s:</td>'+
					'<td class="dataCol"><input type="text" id="nfInput" value=""/></td>'+
				'</tr>'+
				'<tr>'+
					'<td class="labelCol">Days in the field:</td>'+
					'<td class="dataCol"><input type="text" id="dfInput" value=""></input></td>'+
				'</tr>'+
				'<tr>'+
					'<td class="labelCol">Calls per Day:</td>'+
					'<td class="dataCol"><input type="text" id="cdInput" value=""></input></td>'+
				'</tr>'+
				'<tr>'+
					'<td class="labelCol">Details per Call:</td>'+
					'<td class="dataCol"><input type="text" id="dcInput" value=""></input></td>'+
				'</tr>'+
			'</table>';
	j$("#pfInnerTableDiv").append(tabstr);		
	j$('#portfolioIndex').val(matrixIndex);
}

function updateWeightInPro(obj){
	var weightValue = obj.value;
	var matchId = obj.id.substring(0, obj.id.length- 11);
	console.log(matchId);
	j$("div[id ^='portfolio'] ul li span").each(function(){
		console.log(this.id);
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
			console.log('pfEditId : ' + pfEditId);
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
			cpf.pf = pf;
			console.log(pf);
			j$(this).find('li').each(function(){
				var cm={};
				console.log(j$(this).attr('id'));
				console.log(j$(this).find('input').val());
				var id = j$(this).attr('id');
				if(id && j$.trim(id)!=''){
					cm.maId = id;
					cm.weight = j$(this).find('input').val();
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
	console.log(result);
	return JSON.stringify(result);
}