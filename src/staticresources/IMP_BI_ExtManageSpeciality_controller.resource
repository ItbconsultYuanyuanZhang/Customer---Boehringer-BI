function register_event(){	//all event
	j$('#specialSeletorDivId .draggable').off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
	j$('#specialSeletorDivId .ui-state-disabled').off('mouseenter mouseleave');
	
	var sortable_options = {containment : '#theTopDivId', cancel : '.ui-state-disabled', cursor : 'move'},
		droppable_options = {hoverClass : 'hoverTarget', activeClass : 'dropTarget', cursor : 'move'};
		
	j$('#specialSeletorDivId ul.dropUlCls').sortable({
		opacity: 0.7,
		delay: 200,
		revert: true,
		cancel: sortable_options.cancel,
		containment: sortable_options.containment,
		connectWith: 'ul.matrixDraggable',
		//stop: matrix_stop_fn_void,
		//cursor : sortable_options.cursor,
		
		helper: function (e, item){
            //console.log('Item: ',item);
			if(!item.hasClass('clicked'))
	               item.addClass('clicked');
            var elements = j$('.clicked').not('.ui-sortable-placeholder').clone();//clone().addClass('ui-state-disabled').addClass('special-state-disabled');
            //console.log('Elements: ', elements);
            var ul = j$('<ul/>');
            return ul.append(elements);;
        },
        start: function (e, ui) {
            var elements = ui.item.siblings('.clicked.hidden').not('.ui-sortable-placeholder');
            ui.item.data('items', elements);
        },
        receive: function (e, ui) {
            ui.item.before(ui.item.data('items'));
        },
        stop: function (e, ui) {
            ui.item.siblings('.clicked').removeClass('hidden');
            j$('.clicked').removeClass('clicked');
        }
    });
	
	j$("div[id^='groupSpecial']").each(function(){
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
    
	j$("div[id^='groupSpecial']").droppable({
        accept:".draggable, .matrixDraggable",
        hoverClass: droppable_options.hoverClass,
        activeClass: droppable_options.activeClass,
        //liveSelector:"#specialDivId",
        drop : function( drag, drop ) {

        	if(typeof (drop.helper.context) != 'undefined'){
        		droppable_drop_fn(drag, drop);
        	}else{
        		droppable_drop_fn_multiselect(drag,drop);
        	}
        }
    });
    
	j$("#specialSeletorDivId ul").droppable({
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

function droppable_drop_fn_multiselect (drag,drop){
	
	//Iterate every li selected and drop into the group
	jQuery.each( drop.helper.find("li"), function( i, val ) {

		var j$dragCurrent = j$("#specialSeletorDivId ul li[Id="+j$(val).attr('Id')+"]");//console.log(':: DragCurrent: ', j$dragCurrent);
		var currentId = j$(val).attr('id'),//j$.trim(j$dragCurrent.attr('id')), 
		parentId = 'specialSeletorDivId';//j$.trim(j$dragCurrent.parent().parent().attr('id'));
		//console.log('currentId: '+ currentId + ', parentId : ' + parentId + ' targetId: ' + targetId + ' conditionId: '  + conditionId);
				 
		//find a available li -- id is null
		var hasFinded = false;
		var j$dragTarget, targetId;
		
		j$(drag.target).find('li').each(function(){
			if(typeof(j$(this).attr('id')) == 'undefined' || j$(this).attr('id') == ''){
				if(!hasFinded){
					hasFinded = true;
					j$dragTarget = j$(this), targetId = j$(this).attr('id');
				}
			}
		});
		
		//if has not find any available li, do nothing
		if(typeof(j$dragTarget) != 'undefined'){
			j$dragTarget.attr({'id': currentId})
				.addClass('pgover').html(j$(val).find('span').attr('title')).removeClass('ui-state-disabled');
			j$dragCurrent.addClass('ui-state-disabled').addClass('special-state-disabled');
			j$dragCurrent.removeClass('pgover').off('mouseenter mouseleave');
		}
		else{
			j$dragTarget = j$('<li id="' + currentId + '" class="matrixDraggable pgover">' + j$dragCurrent.find('span').attr('title') + '</li>');
			j$dragCurrent.addClass('ui-state-disabled').addClass('special-state-disabled');
			j$dragCurrent.removeClass('pgover').off('mouseenter mouseleave');
			j$(drag.target).find('ul').append(j$dragTarget);
		}
	});
}


function droppable_drop_fn(drag,drop){
	var j$dragCurrent = j$(drop.helper.context), conditionId,
	currentId = j$.trim(j$dragCurrent.attr('id')), 
	parentId = j$.trim(j$dragCurrent.parent().parent().attr('id'));
	
	conditionId = (typeof(parentId) != 'undefined' && j$.trim(parentId) != '' && (parentId.indexOf('groupSpecial') > -1)) ? 'matrixDivId' : parentId;  
	var targetId = j$(drag.target).attr('id');
	
	if((targetId.indexOf('groupSpecial') > -1) && (parentId.indexOf('groupSpecial') > -1)){
		conditionId = 'horizontalMove';
	}
	
	//console.log('currentId: '+ currentId + ', parentId : ' + parentId + ' targetId: ' + targetId + ' conditionId: '  + conditionId);
	
	if(typeof(targetId) != 'undefined' && typeof(parentId) != 'undefined' && j$.trim(targetId) != '' && j$.trim(parentId) != '' && targetId != parentId){

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
					j$dragTarget.attr({'id': currentId})
						.addClass('pgover').html(j$dragCurrent.text()).removeClass('ui-state-disabled');
						
					
					j$(('#' + parentId + ' #'+currentId)).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
				}
				else{
					j$dragTarget = j$('<li id="' + currentId + '" class="matrixDraggable pgover">' + j$dragCurrent.attr('title') + '</li>');
					j$(('#' + parentId + ' #'+currentId)).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
					
					j$(drag.target).find('ul').append(j$dragTarget);
				}
				//resetDivHeight();
				break;
			
			case 'matrixDivId' : 
				var j$lis = j$(drag.target).find('li');
	        	j$lis.each(function(){
	        		if(currentId == j$(this).attr('id')){
	        			j$(this).removeClass('ui-state-disabled').removeClass('special-state-disabled');
	        			j$(this).off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
	        			j$(('#' + parentId + ' #'+currentId)).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
	        		}
	        	});
				break;
			default :  break;
		}
	}
}

/**
 *  Used to add a new Group 
 *
 @author  Peng Zhu
 @created 2013-07-02
 *
 */
function addGroup(){
	var groupIndex = parseInt(j$('#groupIndex').val()) + 1;
	var tableStr = '';
	
	var tableNum = parseFloat(j$('#matriDivId').children('table.groupTable').length);
	var divWidth = (tableNum + 1) * 233;
	j$('#matriDivId').css("width", divWidth);
	
	tableStr += '<table class="groupTable">' +
					'<tr>' +
						'<td style="display:block;">' +
						//	'Group <span class="groupIndexSpan">' + groupIndex + '</span> <input type="text" class="groupNameInput" name="groupNameInput"/>' +
						//	'<img title="delete this Group" class="deleteMatrixImg" style="cursor:pointer; margin-left:5px; vertical-align:middle; height:15px; width:15px;" onclick="removeGivenTable(this);" src="/img/func_icons/util/recycle.gif"></img>' +
						'<div class="groupNameDiv">' +
						'<span>Group </span><span class="groupIndexSpan">' + groupIndex + '</span>' +
						'</div>' +
						'<div style="float:right;margin-right:10px;">' +
						'<div class="requiredInput">' +
							'<div class="requiredBlock"></div>' +
							'<input type="text" class="groupNameInput" name="groupNameInput" onchange="checkSingleGroupName(this);"/>' +
							'<img title="delete this Group" class="deleteMatrixImg" style="cursor:pointer; margin-left:5px; vertical-align:middle; height:15px; width:15px;" onclick="removeGivenTable(this);" src="/img/func_icons/util/recycle.gif"></img>' +
						'</div>' +
						'</div>' +
						'<div style="clear:both;"></div>' +
						'<div name="erMsg" class="errorMsg groupErrMsg" style="display:none;">' +
							'<span style="color:#C00;"><strong>Error: </strong>Group name can not be the same with other speciality name which do not belong to it.</span>' +
						'</div>' +
						'</td>' +
					'</tr>' +
					'<tr>'+
		                '<td style="text-align: left;">'+
		                	'<span class="matrixTableLabel">'+
		                		label_allSpecialties + ':&nbsp;'+
		                		'<input type="checkbox"  class="chkAllSpecialty" id="chkAllSpecialty" name="chkAllSpecialty"  onclick="checkAllSpecialties(this);" />'+
		                	'</span>'+
		                 '</td>'+
		            '</tr>'+
					//'<tr>' +
					//	'<td>' +
					//	'</td>' +
					//'</tr>' +
					'<tr>' +
						'<td>' +
							'<div id="groupSpecial' + groupIndex + '" name="groupSpecial" style="height: 300px; width: 200px; border: 1px solid #000; overflow:auto;" class="specialCls ui-droppable">' +
								'<ul class="targerDropUlCls matrixDropUlCls ui-sortable">';
									for(var i=0; i<qSpecialties; i++){
										tableStr +='<li id="" class="matrixDraggable"></li>';
									}
								tableStr +='</ul>' +
							'</div>' +
						'</td>' +
					'</tr>' +
				'</table>';
				
    j$('#matriDivId').append(tableStr);
    
	j$('#groupIndex').val(groupIndex);
}

/**
 *  Used to add a new Group 
 *
 @author  Peng Zhu
 @created 2013-07-02
 *
 */
function collectSpecialityValue(){
	var sArr = new Array();

	j$("#matriDivId table").each(function(){
		var j$this = j$(this);
		
		var gName = j$.trim(j$("input[name='groupNameInput']", j$this).val());
		
    	j$("div[id^='groupSpecial'] li", j$this).each(function(){
			var liId = j$(this).attr('Id');
			if(liId){
				var s = new Object();
				s.sId = liId;
				s.sName = j$.trim(j$(this).text());
				s.sGroup = gName;
				s.cId = countryId;
				s.cCode = countryCode;
				sArr.push(s);
			}
	    });
	});
	
	//j$("#specialSeletorUlId li.newli").not('.ui-state-disabled').each(function(){
	j$("#specialSeletorUlId li").not('.ui-state-disabled').each(function(){
		var j$this = j$(this);
		var sId = j$(this).attr('Id');
		
		if(sId){
			j$this.find("span").each(function(){
				var s = new Object();
				s.sId = sId;
				s.sName = j$.trim(j$(this).text());
				s.sGroup = null;
				s.cId = countryId;
				s.cCode = countryCode;
				
				sArr.push(s);
			});
		}
	});

	return JSON.stringify(sArr);
}

function checkAllGroupName(){
	var hasError = false;
	j$("#matriDivId table").each(function(){
		var j$this = j$table = j$(this);
		
		var gName = j$.trim(j$("input[name='groupNameInput']", j$this).val());
		
		var sIds = '';
		
    	j$("div[id^='groupSpecial'] li", j$this).each(function(){
			var liId = j$(this).attr('Id');
			if(liId){
				if(sIds == '') sIds = liId;
				else sIds += ';' + liId;
			}
	    });
	    
	    if(sIds != ''){
		    j$("#specialSeletorUlId li").each(function(){
				var j$this = j$(this);
				var sId = j$(this).attr('Id');
				
				if(sId && sIds.indexOf(sId) == -1){
					j$this.find("span").each(function(){
						if(gName == j$.trim(j$(this).text())){
							hasError = true;
							j$("div[name=erMsg]", j$table).show();
						}
					});
				}
			});
	    }
	});
	
	return hasError;
}

function checkSingleGroupName(obj){
	var j$this = j$(obj), j$table = j$(getParent(j$this.get(0), 'TABLE'));
	var gName = j$.trim(j$this.val());
	var sIds = '', hasError = false;
	
	j$("div[id^='groupSpecial'] li", j$table).each(function(){
		var liId = j$(this).attr('Id');
		if(liId){
			if(sIds == '') sIds = liId;
			else sIds += ';' + liId;
		}
    });
    
    if(sIds != ''){
	    j$("#specialSeletorUlId li").each(function(){
			var j$this = j$(this);
			var sId = j$(this).attr('Id');
			
			if(sId && sIds.indexOf(sId) == -1){
				j$this.find("span").each(function(){
					if(gName == j$.trim(j$(this).text())){
						hasError = true;
					}
				});
			}
		});
    }
    if(hasError) j$("div[name=erMsg]", j$table).show();
    else j$("div[name=erMsg]", j$table).hide();
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

}

/**
 *  Used to remove the specified group table
 *
 @author  Peng Zhu
 @created 2013-07-04
 @email	  peng.zhu@itbconsult.com
 *
 */
function removeGivenTable(obj){
	var j$table = j$(getParent(j$(obj).get(0), 'TABLE'));
	
	j$("li", j$table).each(function(){
		if(j$(this).attr('id')){
			var liId = j$(this).attr('id');
			
			j$("#specialSeletorDivId li[id='" + liId + "']").removeClass('ui-state-disabled').removeClass('special-state-disabled');
			j$("#specialSeletorDivId li[id='" + liId + "']").off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
		}
	});
	
	j$table.remove();
	
	var groupIndex = parseInt(j$('#groupIndex').val()) - 1;
	j$('#groupIndex').val(groupIndex);
	
	var tableNum = parseFloat(j$('#matriDivId').children('table.groupTable').length);
	var divWidth = (tableNum + 1) * 233;
	j$('#matriDivId').css("width", divWidth);
	
	refreshTableIndex();
}


function matrix_stop_fn_void(){}

function refreshTableIndex(){
	var tableIndex = 0;
	j$("#matriDivId table span[class='groupIndexSpan']").each(function(){
		tableIndex ++;
		j$(this).text(tableIndex);
	});
}

function resetMatriDivIdSize(){
	var windowWidth = 0;
	
	if (window.innerWidth)
		windowWidth = window.innerWidth;
	else if ((document.body) && (document.body.clientWidth))
		windowWidth = document.body.clientWidth;
	else windowWidth = window.screen.width;
	
	if(windowWidth < 800) windowWidth = 800;
	
	var mainDivWidth = windowWidth - j$("#matriDivId").offset().left -80;

	j$('#matriDivId').css("max-width", mainDivWidth);
}

//** assist function to find element's parent with specified tag name **//
function getParent(el,p){
	do{
		el = el.parentNode;
	}while(el && el.nodeName != p)
	return el;
}


/**
 * Select all the specilaties for each group 
 */

function checkAllSpecialties(obj){
	//get true or false
	if(obj){
		if(obj.checked){
			var j$divTarget = j$(getParent(obj, 'TBODY')).find('div.specialCls'), targetId, j$dragTarget, j$dragCurrent;
			
			j$("li:not(.special-state-disabled)", j$("#specialSeletorDivId")).each(function(){
				j$dragCurrent = j$(this);
				var currentId = j$dragCurrent.attr('id');
				var hasFound = false;
				
				//for overflowHidden
				var j$div = j$(getParent(j$dragCurrent.get(0), 'DIV'));
				
				if(j$div.hasClass('overflowHidden')){
					j$div.removeClass('overflowHidden');
				}
				
				j$divTarget.find('li').each(function(){
					if(typeof(j$(this).attr('id')) == 'undefined' || j$(this).attr('id') == ''){	//clear old channel
						if(!hasFound){
							hasFound = true;
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
				else{
					j$dragTarget = j$('<li id="' + currentId + '" class="matrixDraggable pgover">' + j$dragCurrent.find('span').attr('title') + '</li>');
					j$dragCurrent.addClass('ui-state-disabled').addClass('special-state-disabled').css({'opacity': 1});
					j$dragCurrent.removeClass('pgover').off('mouseenter mouseleave');
					j$(drag.target).find('ul').append(j$dragTarget);
				}
			});
		}
	}
}