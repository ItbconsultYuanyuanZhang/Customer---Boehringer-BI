function register_event(){	//all event
	$('body').off('click').on('click',e_click_body);
	$('#channelDivId .draggable').off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
	$('#channelDropDivId div.overMenu').off('mouseenter mouseleave click').on('mouseenter mouseleave click', e_over_click_overMenu);
	$('#chartDivId').off('mouseenter mouseleave click').on('mouseenter mouseleave click', e_over_click_chart);
	$('#matrixTotalClsId').off('mouseenter mouseleave').on('mouseenter mouseleave', e_over_overTable);
	$('#tipsnoClickId .tipsTotalDivCls').off('click').on('click', e_click_tipsTotal_avg);
	
	$('#overTableHideId').off('mouseenter mouseleave click').on('mouseenter mouseleave click', e_over_click_overTable);
	$('#channelDropDivId').off('mouseenter mouseleave').on('mouseenter mouseleave', e_over_channelDropDivId);
	$('#channelButtonTrId input[type="button"]').off('click mousedown').on('click mousedown', e_click_channelButton);
	//$('#channelInputTrId input[type="text"]').off('focus change').on('focus change',  e_focus_change_channelText);
	registerDrop_event();
	
}
function e_over_click_chart(e){
	var $this = $(this), this_h = $this.height(), $chart = $('#barChartId'),
		_offset = $this.offset(), _w = $chart.width(), $checkBox = $('#activeChart');

	switch(e.type){
		case 'mouseenter':
				$this.addClass('pgover');
				if(!$chart.hasClass('incheckbox')){
					$chart.css({'opacity': 0.1, 'left': _offset.left, 'top':(_offset.top)})
					.stop().animate({left: (_offset.left-_w), opacity: 1}, 900, function(){
						var $tmp = $(this), tmp_offset = $tmp.addClass('incheckbox').offset();
						if(tmp_offset.left < 10){
							$tmp.animate({left:10}, 900, function(){});
						}
					});
				}
			break;
		case 'click':
			break;
		default:
				$this.removeClass('pgover');
				if(!$checkBox.attr('checked')){
					$chart.stop().animate({left:_offset.left, opacity:0.1}, 900, function(){
						$(this).css({'top':-1000}).removeClass('incheckbox');
					});
				}
			break;
	}
}

function inTipsTotal_avg(_id, $spanBg, $this){
	if($spanBg.hasClass('bg')){
		$spanBg.stop().animate({backgroundColor: '#fff'}, 800, function(){
			$(this).removeClass('bg').addClass('bgf').removeAttr('style');
			$this.removeClass('inbg');
			$(_id).addClass('inbg').find('span:last').removeClass('bgf').addClass('bg');
			
			selectedCell_sum($('#matrixData li.ui-selected'));
		});
	}else{
		$(_id).removeClass('inbg').find('span:last').removeClass('bg').addClass('bgf');
		$spanBg.stop().animate({backgroundColor: '#cc4444'}, 800, function(){
			$(this).removeClass('bgf').addClass('bg').removeAttr('style');
			$this.addClass('inbg');
			
			selectedCell_sum($('#matrixData li.ui-selected'));
		});
	}
	
}

function e_click_tipsTotal_avg(e){
	var $this = $(this), thisId = $this.attr('id'), $spanBg = $this.find('span:last');
	switch(thisId){
		case 'tipsTotalDivId':
			inTipsTotal_avg('#tipsAverageDivId', $spanBg, $this);
			break;
		case 'tipsAverageDivId':
			inTipsTotal_avg('#tipsTotalDivId', $spanBg, $this);
			break;
		default:break;
	}
}
function e_click_channelButton(e){	//tips input[type="button"] 	+  and -

	var $this = $(this),$channelInput = null, selectChannelId = '', isFlg = false, _channelType = '1';
	if($this.hasClass('channel1')){
		$channelInput = $('#channelInput1');
		selectChannelId = $.trim($('#matrixTips thead th span.tipChannel1').attr('id'));
		
	}else if($this.hasClass('channel2')){
		$channelInput = $('#channelInput2');
		selectChannelId = $.trim($('#matrixTips thead th span.tipChannel2').attr('id'));
		_channelType = '2';
	}
	if(selectChannelId != ''){
		var inputValue = $.trim($channelInput.val()) == '' ? 0 : Globalize.parseInt($.trim($channelInput.val()));
		
		if($this.hasClass('addCls')){ isFlg = true; }
		else if($this.hasClass('minusCls')){ isFlg = false; }
		
		if(e.type == 'click'){
			if(isFlg){ inputValue = ++inputValue; }
			else{ if(inputValue > 0){inputValue = --inputValue;} }
			$channelInput.val(inputValue).change();
		}
	}
}

function e_focus_change_channelText(el){	//tips input[type="text"] change event

	var $this;
	if(el)
	$this = $(el);
	else
	$this = $(this);
	var thisVal = $this.data('changeData');
	if(thisVal == $this.val())
	return false;
	
	var ov = 0, validation_qty = /^([1-9]\d{0,16}|0)?$/, 
		thisId = $.trim($this.attr('id')),
		tv = Globalize.parseInt($.trim($this.val()));	//focus Event
	
	//ov = $this.inputFocusValueFormat(validation_qty, e);
	ov = $this.data('changeData');
	if(typeof ov == 'undefined') ov = '';
	
	//if(el){
	//	thisId = 'channelInput1';
	//}
	//if(e.type == 'change'){

		if($.trim($this.val()) == ''){
			tv = '';
		}else if(!validation_qty.test(tv)){
			$this.val(ov).data('changeData',ov);
			return;
		}
		
		
		var channelId = '#matrixTips thead tr th span.', _channelType = '1';
		
		switch(thisId){
			case 'channelInput1':
				channelId = channelId + 'tipChannel1';
				break;
			case 'channelInput2':
				channelId = channelId + 'tipChannel2';
				_channelType = '2';
				break;
			default:break;
		}
		
		channelId = $.trim($(channelId).attr('id'));
		
		if(channelId == ''){
			return;
		}
		
		change_channelBudget(_channelType, channelId, tv, 'ui-selected',$this.attr('class'));
		
		$this.val(tv).data('changeData',tv);
	//}
}
function e_click_body(evt){
	var elem = evt.target,elemId,i,j;
	if(elem.nodeName == 'LI') j = 2;
	else j = 5;
	var notInArea = true;
	for(i=0;i<j;i++){
		elemId = elem.id;
		if(elemId && (elemId=='matrixData'||elemId=='colors' || elemId == 'colorbody' || elemId == 'colors1' ||
			elemId == 'channelInput1' || elemId == 'channelInput2' || elemId == 'channelAdd1' || elemId == 'channelAdd2' ||
			elemId == 'channelMinus1' || elemId == 'channelMinus2' || elemId == 'matrixTips' || elemId == 'channelDropDivId' ||
			elemId == 'btnDivId' || elemId == 'matrixTotalClsId' || elemId == 'tipsnoClickId' || elemId == 'channelDropDiv')){
			notInArea = false;
			break;
		}else if(elem.parentNode){
			elem = elem.parentNode;
		}
	}
	if(notInArea){
		$('#colorbody').removeClass('inActive').fadeOut();
		$('#matrixData').find('.ui-selected').removeClass('ui-selected');
	}
}
function registerDrop_event(){	//register all jquery ui table event. 
	var sortable_options = {containment : '#channelDropDivId', cancel : '.ui-state-disabled', cursor : 'move'},
		droppable_options = {hoverClass : 'hoverTarget', activeClass : 'dropTarget', cursor : 'move'};
	
	$("#matrixData" ).selectable({filter:'li', cancel:'.tdhd', stop: select_table_stop_fn});
	
	var channel_drop = $('#channelDivId ul.dropulCls').sortable({
			opacity: 0.7, revert: true,
			cursor : sortable_options.cursor,
			cancel: sortable_options.cancel,
			containment: sortable_options.containment,
			stop: channel_stop_fn
    });
	
    $('#channel1DivContent ul.channelDropulCls, #channel2DivContent ul.channelDropulCls').sortable({
			opacity: 0.7, revert: true,
			cursor : sortable_options.cursor,
			cancel: sortable_options.cancel,
			containment: sortable_options.containment,
			stop: channelContent_stop_fn
    });
    
	$("#channel1DivContent, #channel2DivContent").droppable({
        accept:".draggable",
        hoverClass: droppable_options.hoverClass,
        activeClass: droppable_options.activeClass,
        liveSelector:"#channel1DivContent, #channel1DivContent",
        drop : droppable_drop_fn
    });
	$("#channelDivId").droppable({
        accept:".channelDraggable",
        hoverClass: droppable_options.hoverClass,
        activeClass: droppable_options.activeClass,
        liveSelector:"#channelDivId",
        drop : droppable_drop_fn
    });
    //two channel change
    if(!$("select[id$='channel1Picklist']").val()) $("select[id$='channel1Picklist']").val(selectedChannelId);
    
    $("select[id$='channel1Picklist']").change();

	matrixTotalTable(false);
    
    
    //var dtd = $.Deferred(), d = waitDeferredChannel(dtd, $("select[id$='channel1Picklist']").val());
    //if($('#loading-curtain-div').is(':hidden')) $('#loading-curtain-div').show();
	//$.when(d).done(function(){
	    if($("select[id$='channel2Picklist']").val()){
	    	$("select[id$='channel2Picklist']").change();
	    }
		$('#loading-curtain-div').hide();
	//}).fail(function(){ if(window.console)console.log('fail list_rows'); });

 	
    $('#matrixData li.tdda').unbind('mouseover mouseout').bind('mouseover mouseout', function(e){
	    if(e.type == 'mouseover'){
	        var xx = e.pageX, yy = e.pageY;
			
			var cls = $(this).attr('class');
				var col = /column_\d+/.exec(cls);
				var row = /row_\d+/.exec(cls);
				col = col[0].replace('column_','');
				row = row[0].replace('row_','');
			
			var $channel1 = $("select[id$='channel1Picklist']"), $channel2 = $("select[id$='channel2Picklist']");
        	var channel1 = $channel1.get(0), channel2 = $channel2.get(0);
        	var selecValCh1 = $.trim(channel1.value),
        		selecTxtCh1 = $.trim(channel1.options[channel1.selectedIndex].text),
        		selecValCh2 = $.trim(channel2.value),
        		selecTxtCh2 = $.trim(channel2.options[channel2.selectedIndex].text);
			
			var tableStr = '<table border="0" cellpadding="0" cellspacing="0" id="cellPopupTable" class="cellPopupTable" style="background-color:#FFFDCA;"><thead><tr><th style="width:200px;max-width:250px;"></th></tr></thead><tbody>';

			    tableStr += '<tr><td style="width:200px;max-width:250px;">';
			    tableStr += 'Average Quantity';
			    tableStr += '</td></tr>';

			tableStr += '</tbody></table>';
			
			
			var $table = $(tableStr);
			
			var existChannelId = [];
			if(selecValCh1 != '' && selecTxtCh1 != ''){
				var channelName = selecTxtCh1, channelId = selecValCh1;

				existChannelId.push(channelId);

				var thStr = '<th style="width:100px;max-width:200px; text-align:center;">' + channelName + '</th>';
		        $table.find('thead tr th:last').after(thStr);
		
		        $table.find('tbody tr').each(function(idx){
		            var tdStr = '<td id="' + channelId + '"></td>';
		            $(this).find('td:last').after(tdStr);
		        });
			}

			if(selecValCh2 != '' && selecTxtCh2 != ''){
				var channelName = selecTxtCh2, channelId = selecValCh2;

				existChannelId.push(channelId);

				var thStr = '<th style="width:100px;max-width:200px; text-align:center;">' + channelName + '</th>';
		        $table.find('thead tr th:last').after(thStr);
		
		        $table.find('tbody tr').each(function(idx){
		            var tdStr = '<td id="' + channelId + '"></td>';
		            $(this).find('td:last').after(tdStr);
		        });
			}
			
			$("#matrixTabTotal tbody tr[id$='_id']").each(function(){
				var $tr = $(this), trId = $tr.attr('id'), channelId = trId.split('_')[0], channelName = $.trim($tr.find('td:first').text());
				if(channelName && channelName != '' && existChannelId.indexOf(channelId) == -1){
					var thStr = '<th style="width:100px;max-width:200px; text-align:center;">' + channelName + '</th>';
			        $table.find('thead tr th:last').after(thStr);
			
			        $table.find('tbody tr').each(function(idx){
			            var tdStr = '<td id="' + channelId + '"></td>';
			            $(this).find('td:last').after(tdStr);
			        });
				}
		
			});
			
			for(var i=0, max=JSON_CHANNELS.length; i<max; i++){
				var o = JSON_CHANNELS[i];
				if(o.cellRow == row && o.cellColumn == col){
					var cId = o.channelId;
					
					var totalCust = 0;
					var totalQuan = 0;
					for(var idx in o.map_index_cmcdo){
						
						if(o.map_index_cmcdo[idx].qty && o.map_index_cmcdo[idx].accountNum){
							totalCust += parseFloat(o.map_index_cmcdo[idx].accountNum);
							totalQuan += parseFloat(o.map_index_cmcdo[idx].accountNum) * parseFloat(o.map_index_cmcdo[idx].qty);
						}
						
					}
					var avgQuan = 0;
					if(totalCust && totalQuan){
						avgQuan = parseFloat(totalQuan/totalCust);
					}
					
					$table.find("td[id='" + cId + "']").text(avgQuan.toFixed(1));
				}
			}
			
			//@jescobar: Showing the popUp to get its edge
			$('#cellPopup').html($table).css({'display':''});
			var $pMatrix = $('#matrixData'), cellPopupTable = $('#cellPopupTable');
			
			//Set border edge to the popUp regardig the matrix edge
			width_mx = $pMatrix.outerWidth(true), left_mx= $pMatrix.offset().left, width_popUp = cellPopupTable.width();
			xx = ((xx+width_popUp) > (width_mx+left_mx)) ? ((width_mx+left_mx) - width_popUp) : (xx-105);
			
			//show pop up according to the location event 
			$table.css({'left': xx, 'top' : (yy-102), 'position':'absolute', 'opacity':0.1}).animate({opacity: 1}, 600, function(){});
	    }
	    else if(e.type == 'mouseout'){
	        $('#cellPopup').css({'display':'none'});
	    }
	});
	//$('#loading-curtain-div').fadeOut();
}

function setSelectedChannelId(){	//first init channel id
	if(selectedChannelId == ''){return;}
	var $channel1 = $('#channel1 li'), $channelId = $(('#channelDivId li#' + selectedChannelId)),
		licost_rate__c = $channelId.attr('licost_rate__c'), liunit__c = $channelId.attr('liunit__c'),
		li_spanText = $.trim($channelId.find('span').text());
		
	$channel1.attr({'id': selectedChannelId, 'licost_rate__c': licost_rate__c, 'liunit__c': liunit__c})
			 .addClass('pgover').text(li_spanText).removeClass('ui-state-disabled').css({'opacity': 1});
	$channelId.addClass('ui-state-disabled').css({'opacity': 0.4});
	
	channelPopAssignment('add', '1', null);
	
	
	matrixTotalTable(false);
}

function channelPopAssignment(executeType, channelType, $channelId){	//add, del set channel tips values
	switch(executeType){
		case 'add':
			var channelFlg = true, channelId = '',
				$channel1 = $('#channel1DivContent li'), 
				$channel2 = $('#channel2DivContent li'),
				channel1Id = $.trim($('#channel1DivContent li').attr('id')), 
				channel2Id = $.trim($('#channel2DivContent li').attr('id'));

			if($channelId != null){// oll add channel
				if($channelId.parent().parent().attr('id') == 'channel1DivContent'){
					changeTips('1', $channelId.attr('id'), $channel1);
					channelFlg = true;
				}else{
					changeTips('2', $channelId.attr('id'), $channel2);
					channelFlg = false;
				}
			}else{	//is new channel
				
				if(typeof(channel1Id) != 'undefined' && channel1Id != ''){
					channelFlg = true;
					changeTips('1', channel1Id, $channel1);
				}
				if(typeof(channel2Id) != 'undefined' && channel2Id != ''){
					changeTips('2', channel2Id, $channel2);
					channelFlg = false;
				}
			}
			if(!($channelId == null && channelType == null)){
				var _channelType = '1';
				
				if(!channelFlg){
					channelId = $.trim($('#channel2DivContent li').attr('id'));
					_channelType = '2';
					change_channelBudget(_channelType, channelId, null, null);
				}
				else{
					channelId = $.trim($('#channel1DivContent li').attr('id'));
					change_channelBudget(_channelType, channelId, null, null);
				}
			}

			break;
		case 'del':
			var matrixTipsId = '#matrixTips .tipChannel'+channelType;
			$(matrixTipsId).each(function(){
				var $this = $(this);
				if($this.hasClass('input')){
					$this.val('');
				}else{
					$this.text(' ').attr({'id':'', 'liUnit__c':''})
				}
			});
			remove_channelBudget(channelType, $channelId);
			break;
		default : break;
	}
	
}

function changeTips(tipChannel, channelId, $channel){	//set tips values
	var matrixTips = '#matrixTips', t = matrixTips + ' .tipChannel'+tipChannel,
		$t = $(t), input1 = '', input2 = '';

	$t.each(function(){
		var $this = $(this);
		if($this.hasClass('head')){
			$this.text('').text($.trim($channel.text())).attr({'id':channelId});
		}else if($this.hasClass('body')){
			$this.text('').text($.trim($channel.attr('liUnit__c')));
		}else if($this.hasClass('input')){
			$this.attr({'liCost_Rate__c' : $.trim($channel.attr('liCost_Rate__c'))});
		}
	});

	if($('#matrixData li.ui-selected').length == 1){
		input1 =  $.trim($('#matrixData li.ui-selected div:first').text());
		input1 = input1 == '' ? '' : Globalize.parseInt(input1);
		input2 = $.trim($('#matrixData li.ui-selected div:last').text());
		input2 = input2 == '' ? '' : Globalize.parseInt(input2);
	}

	$('#channelInputTrId input[type="text"]#channelInput1').val(input1);
	$('#channelInputTrId input[type="text"]#channelInput2').val(input2);
	
	
}
function addQty(evt,el,qty){
	if(evt.preventDefault)
	evt.preventDefault();
	else
	event.returnValue = false;
	if(evt.stopPropagation)
	evt.stopPropagation();
	else
	event.cancelBubble = true;
	var $input,txt;
	if(qty < 0){
		$input = $(el).next();
		txt = $input.val();
		txt = parseInt(txt,10);
		if(isNaN(txt)) txt = 0;
		txt --;
		if(txt < 0) txt = 0;
	}else{
		$input = $(el).prev();
		txt = $input.val();
		txt = parseInt(txt,10);
		if(isNaN(txt)) txt = 0;
		txt ++;
		if(txt < 0) txt = 0;
	}
	//$input.val(txt);
	//modifyed by Peng Zhu 2013-06-19
	$input.val(txt).change();
	
	//Apply matrix modified
	matrixHasChanged=true;
	//console.log(':: it has been modified: ' + matrixHasChanged);
}
/*
 * Added by Peng Zhu 2013-06-19 for popup apply button
 */
function applyAllQty(evt,el){
	if(evt.preventDefault)
		evt.preventDefault();
	else
		event.returnValue = false;
	if(evt.stopPropagation)
		evt.stopPropagation();
	else
		event.cancelBubble = true;
	
	var $this = $(el),qty = $this.prev().val(),posIdx = $this.parent().prevAll().length;
	
	if(!/^\d+$/.test(qty)){
		alert('Invalid number. Please check.');
		return;
	}
	var elem;
	
	var filtersIdx = $('#matrixTips').children('tbody').children().length;
	
	if(filtersIdx!=null && filtersIdx == 1){
		alert('Please, apply the filter on the Matrix before assign the resources');
		return;
	}
	
	if(parseInt(qty,10) >= 0 && confirm("Do you want to apply standard values to all filter combinations? This will overwrite all previously assigned values to the selected cells!")){
		$('#matrixTips').children('tbody').children().each(function(idx){
			if(idx > 0){
				elem = $(this).children().eq(posIdx).children('input');
				elem.val(qty);
				e_focus_change_channelText(elem.get(0));
			}
		});
	}
	
	//Apply matrix modified
	matrixHasChanged=true;
}

function tipsShowOption($lis){
	$lis = $('#matrixData li.ui-selected');

	var displayCls = 'displayCls', 
		selected_len = $('#matrixData li.ui-selected').length;
	
	//Begin: added by Fuqi Tan 2013-06-18
	var $select = $('#quantityFilterDivId').children('select:first');
	
	//Commented by Peng Zhu 2013-06-19 for not --show all-- 
	//var str = ['<tr><td class="w1">Apply to all filter combinations</td><td class="w3"><input type="text" value=""/>',
	//	'<button onclick="applyAllQty(event,this);">Apply</button></td><td class="w3"><input type="text" value=""/><button onclick="applyAllQty(event,this);">Apply</button></td></tr>'],$option;
	//
	var str = [], $option;
	if(filterShowAll){
		str = ['<tr><td class="w1">Apply to all filter combinations</td><td class="w3"><input type="text" class="ipt_all" value="" onkeypress="killEnter(event,this);" onkeydown="killEnter(event,this);"/>',
			'<button onclick="applyAllQty(event,this);">Apply</button></td><td class="w3"><input type="text" class="ipt_all" value="" onkeypress="killEnter(event,this);" onkeydown="killEnter(event,this);"/><button onclick="applyAllQty(event,this);">Apply</button></td></tr>'];
	}
	//End: modified by Peng Zhu 2013-06-19
	var initVal;
	var multiVal; 
    var multiVal2 = [];
    
    var total_arr = [];//added by Peng Zhu 2014-02-10
    
	if($lis && $lis.length != 1){
		initVal = '';
		multiVal = [];
		total_arr = [];

		if(filterSize){
			$lis.each(function(idx){
				var arrIdx = idx;
				
				multiVal[arrIdx] = [];
				
				var $this = $(this);
				var cls = $this.attr('class');
				var col = /column_\d+/.exec(cls);
				var row = /row_\d+/.exec(cls);
				col = col[0].replace('column_','');
				row = row[0].replace('row_','');
				
				$this.children('div.matrixDataDivCls').each(function(idx){
					var kid = $(this).attr('id');
					for(var i=0, max=JSON_CHANNELS.length; i<max; i++){
						var o = JSON_CHANNELS[i];
						if(o.channelId == kid && o.cellRow == row && o.cellColumn == col){
							multiVal[arrIdx][idx] = o.map_index_cmcdo;
							
							//Begin: added by Peng Zhu 2014-02-11
							if(total_arr[idx] == undefined){
								total_arr[idx] = {};
							}
							
							for(var oIdx in o.map_index_cmcdo){
								if(total_arr[idx][oIdx] == undefined){
									total_arr[idx][oIdx] = {};
									total_arr[idx][oIdx]['qty'] = o.map_index_cmcdo[oIdx]['qty'];
								}
								else{
									if(total_arr[idx][oIdx]['qty'] != o.map_index_cmcdo[oIdx]['qty']){
										total_arr[idx][oIdx]['qty'] = '';
									}
								}
							} 
							//End: added by Peng Zhu 2014-02-11 
							
							break;
						}
					}
				});
				
			});
		}

		for(var i = 0; i < multiVal.length; i++){
			for(var j = 0; j < multiVal[i].length; j++){
				if(multiVal2[j] == 'undefined' || !multiVal2[j]) multiVal2[j] = [];
				
				for(var k = 0; k < filterSize; k++){
					if(typeof multiVal2[j][k] == 'undefined' || !typeof multiVal2[j][k]) multiVal2[j][k] = [];
					
					if(typeof multiVal2[j][k]['accountCounter'] != 'undefined'){
						multiVal2[j][k]['accountCounter'] = multiVal2[j][k]['accountCounter'] + multiVal[i][j][''+k]['accountCounter'];
					}
					else{
						multiVal2[j][k]['accountCounter'] = multiVal[i][j][''+k]['accountCounter'];
					}
				}
			}
		}
		
		initVal = total_arr;
	}
	else{// if($lis && $lis.length == 1)
		initVal = [];
		var cls = $lis.attr('class');
		var col = /column_\d+/.exec(cls);
		var row = /row_\d+/.exec(cls);
		col = col[0].replace('column_','');
		row = row[0].replace('row_','');
		$lis.children('div.matrixDataDivCls').each(function(idx){
			var kid = $(this).attr('id');
			for(var i=0, max=JSON_CHANNELS.length; i<max; i++){
				var o = JSON_CHANNELS[i];
				if(o.channelId == kid && o.cellRow == row && o.cellColumn == col){
					initVal[idx] = o.map_index_cmcdo;
					break;
				}
			}
		});
	}
	
	
	if($select.val() == ''){
		//Begin: added by Peng Zhu 2013-06-26 for remove [###] 
		var temp_optionText = '';
		//End: added by Peng
		$select.children().each(function(){
			$option = $(this);
			if(isNaN(parseInt( $option.val(),10)))
			return true;
			//Begin: added by Peng Zhu 2013-06-26
			temp_optionText = '';
			temp_optionText = $.trim($option.text().substring($option.text().indexOf(']') + 1));
			if($lis.length != 1){
				if(typeof multiVal2 != 'undefined' && typeof multiVal2[0] != 'undefined' && typeof multiVal2[0][0] != 'undefined'){
					//only for f2f case
					temp_optionText = '[' + multiVal2[0][$option.val()]['accountCounter'] + '] ' + temp_optionText;
				}
			}
			else{
				if(initVal != ''){
					//only for f2f case
					temp_optionText = '[' + initVal[0][$option.val()]['accountCounter'] + '] ' + temp_optionText;
				}
			}
			//End: Peng
			str.push('<tr><td class="w1">',temp_optionText,'</td><td class="w2"><button onclick="addQty(event,this,-1);">-</button><input id="channelInput1" type="text" class="',
			$option.val(),'" value="',initVal==''?'':initVal[0][$option.val()]['qty'],'" onchange="e_focus_change_channelText(this);" onkeypress="killEnter(event,this);" onkeydown="killEnter(event,this);"/><button onclick="addQty(event,this,1);">+</button></td><td class="w2"><button onclick="addQty(event,this,-1);">-</button><input id="channelInput2" type="text" class="',
			$option.val(),'" value="',initVal==''?'':initVal.length > 1? initVal[1][$option.val()]['qty']:'','" onchange="e_focus_change_channelText(this);" onkeypress="killEnter(event,this);" onkeydown="killEnter(event,this);"/><button onclick="addQty(event,this,1);">+</button></td></tr>');
		});
		$('#matrixTips').children('tbody').empty().append(str.join(''));
		//$('#matrixTips').children('tfoot').hide();//can be removed
	}else{
		$select.children().each(function(){
			$option = $(this);
			if($select.val() == $option.val()){
				//Begin: added by Peng Zhu 2013-06-26
				temp_optionText = '';
				temp_optionText = $.trim($option.text().substring($option.text().indexOf(']') + 1));
				if($lis.length != 1){
					if(typeof multiVal2 != 'undefined' && typeof multiVal2[0] != 'undefined' && typeof multiVal2[0][0] != 'undefined'){
						//only for f2f case
						temp_optionText = '[' + multiVal2[0][$option.val()]['accountCounter'] + '] ' + temp_optionText;
					}
				}
				else{
					if(initVal != ''){
						//only for f2f case
						temp_optionText = '[' + initVal[0][$option.val()]['accountCounter'] + '] ' + temp_optionText;
					}
				}
				//End: Peng
				str.push('<tr><td class="w1">',temp_optionText,'</td><td class="w2"><button onclick="addQty(event,this,-1);">-</button><input id="channelInput1" type="text" class="',
				$option.val(),'" value="',initVal==''?'':initVal[0][$option.val()]['qty'],'" onchange="e_focus_change_channelText(this);" onkeypress="killEnter(event,this);" onkeydown="killEnter(event,this);"/><button onclick="addQty(event,this,1);">+</button></td><td class="w2"><button onclick="addQty(event,this,-1);">-</button><input id="channelInput2" type="text" class="',
				$option.val(),'" value="',initVal==''?'':initVal.length > 1? initVal[1][$option.val()]['qty']:'','" onchange="e_focus_change_channelText(this);" onkeypress="killEnter(event,this);" onkeydown="killEnter(event,this);"/><button onclick="addQty(event,this,1);">+</button></td></tr>');
				return false;
			}
		});
		$('#matrixTips').children('tbody').empty().append(str.join(''));
	}
	//End: added by Fuqi Tan 2013-06-18
	$matrixTips = $('#matrixTips');
	$matrixTips.find('thead th').each(function(idx){
		if(idx > 0){
			var $this = $(this), spanId = $.trim($this.find('span').attr('id'));
			if(!spanId || $.trim(spanId) == ''){ //is empty
				$this.addClass(displayCls);
				subTipsShowOption($matrixTips, idx, false, displayCls);
			}else{
				$this.removeClass(displayCls);
				subTipsShowOption($matrixTips, idx, true, displayCls);
			}
		}
	});
	if(selected_len > 0){
		var $colorBody = $('#colorbody');
		if(!$colorBody.hasClass('inActive')){
			var $matrixOl = $('#matrixData'), 
				ol_width = $matrixOl.outerWidth(true), 
				ol_left = $matrixOl.offset().left,
				li_left = $matrixOl.find('li.ui-selected').last().offset().left,
				remain_width = (ol_width-li_left);

			var windowWidth = 800, windowHeight = 800;

			if (window.innerWidth) {
      			windowWidth = window.innerWidth;	
      			windowHeight = 	window.innerHeight;	
			}
			else if ((document.body) && (document.body.clientWidth)) {
			    windowWidth = document.body.clientWidth;	
			    windowHeight = document.body.clientHeight;
			}
			else {
				windowWidth = window.screen.width;	
				windowHeight = 	window.screen.height;	
			}		
			
			var pos_left = (windowWidth - $colorBody.width()) / 2.0;
			var pos_top = (windowHeight - $colorBody.height()) / 2.0;
				
			$colorBody.css({'top':pos_top});	
				
			$colorBody.addClass('inActive').css({'left':li_left, 'display':'', 'opacity': 0.1})
				.animate({left: pos_left, opacity: 1}, 600, function(){
				});
				
			//$colorBody.addClass('inActive').css({'left':li_left, 'display':'', 'opacity': 0.1})
			//	.animate({left: ol_width+ol_left, opacity: 1}, 600, function(){
			//	});
		}
	}
}
function subTipsShowOption($table,idx,isRemove,clsname){
	if(isRemove){
		$table.find('tfoot th').eq(idx).removeClass(clsname);
		$table.children('tbody').children().each(function(){
			$(this).children('td').eq(idx).removeClass(clsname);
		});
		return;
	}
	$table.find('tfoot th').eq(idx).addClass(clsname);
	$table.children('tbody').children().each(function(){
		$(this).children('td').eq(idx).addClass(clsname);
	});
}
/*
function formateTipChanneInput(){
	$('#channelInputTrId input[type="text"]').each(function(){
		var $this = $(this), val = $.trim($this.val());
		$this.val(formatCurrent(val));
	});
}
*/
function formatCurrent(val){
	return (Globalize.format(roundFn(val, 2), 'n'));
}



function droppable_drop_fn(drag,drop){	//droppable 			
	var $dragCurrent = $(drop.helper.context), 
		currentId = $.trim($dragCurrent.attr('id')), 
		parentId = $.trim($dragCurrent.parent().parent().attr('id'));

	switch(parentId){
		case 'channel1DivContent' : 
			var $lis = $(drag.target).find('li');
        	$lis.each(function(){
        		if(currentId == $(this).attr('id')){
        			$(this).removeClass('ui-state-disabled').css({'opacity': 1});
        			$(('#channel1DivContent #'+currentId)).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
        			channelPopAssignment('del', '1', ('#'+currentId));
        		}
        	});
			break;
		case 'channel2DivContent' : 
			var $lis = $(drag.target).find('li');
        	$lis.each(function(){
        		if(currentId == $(this).attr('id')){
        			$(this).removeClass('ui-state-disabled').css({'opacity': 1});
        			$(('#channel2DivContent #'+currentId)).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
        			channelPopAssignment('del', '2', ('#'+currentId));
        		}
        	});
			break;
		case 'channelDivId' : 
			var $dragTarget = $(drag.target).find('li'), targetId = $dragTarget.attr('id');
			if(typeof(targetId) != 'undefined' && targetId != '' && currentId != targetId){	//cleart old channel
				$(('#channelDivId li#'+targetId)).removeClass('ui-state-disabled').css({'opacity': 1});
			}

			$dragTarget.attr({'id': currentId, 'liUnit__c': $dragCurrent.attr('liUnit__c'), 'liCost_Rate__c': $dragCurrent.attr('liCost_Rate__c')})
				.addClass('pgover').html($dragCurrent.text()).removeClass('ui-state-disabled');
			channelPopAssignment('add', null, $dragTarget);
			
			break;
		default :  break;
	}
}
function remove_channelBudget(_channelType, channelId){
	//Begin: commented out by Peng Zhu 2013-10-29
	//var matrixIds = '#matrixData li.dataCell', delId = 'div:first';
	//if(_channelType == '2'){
	//	delId = 'div:last';
	//}
	//$(matrixIds).each(function(){
	//	$(this).find(delId).removeAttr('id').text('');
	//});
	//End: commented out by Peng Zhu 2013-10-29
	
	//Begin: added out by Peng Zhu 2013-10-29
	var matrixIds = '#matrixData li.dataCell', delId = 'div:first', divType = 'div.matrixDataDivCls', eqIndex = 0;
	if(_channelType == '2'){
		//delId = 'div:last';
		eqIndex = 1;
	}
	$(matrixIds).each(function(){
		//$(this).find(delId).removeAttr('id').text('');
		$(this).find(divType).eq(eqIndex).removeAttr('id').text('');
	});
	//End: added out by Peng Zhu 2013-10-29
}
function change_channelBudget(_channelType, channelId, tips_budget, selected_cls, qtyType){
	var list_rows = [], list_column = [];
	
	for(var i=0, max=JSON_CHANNELS.length; i<max; i++){
		var o = JSON_CHANNELS[i], clsName = '_cls', divType='div:first', matrixDataId = '#matrixData li.',
			row_cls = ('row_' + o.cellRow), column_cls = ('column_'+ o.cellColumn);
			
			var eqIndex = 0;
			
			divType = 'div.matrixDataDivCls';
	
		if(o.channelId == channelId){
			clsName = o.cellRow + '_' + o.cellColumn + clsName;
			//if(_channelType == '2'){divType = 'div:last';}
			if(_channelType == '2'){eqIndex = 1;}

			matrixDataId = (matrixDataId + clsName);
			if(selected_cls != null && tips_budget != null){
				matrixDataId = matrixDataId + '.'+selected_cls;
			}
			
			$(matrixDataId)
			.animate({opacity: 0.1}, 600)
			.animate({opacity: 1}, 600, function(){
				$(this).removeAttr('style').find('div').removeAttr('style');
			})
			.find(divType).eq(eqIndex).css({'display':'none'})
			.animate({}, 0, function(){	//this is change selected values 
				if(tips_budget != null){
					//Begin: added by Peng Zhu 2013-06-19
					if(typeof qtyType == 'undefined' || !/^\d/.test(qtyType)){
						qtyType = filterSelectIndex;   //possibly filterSelectIndex is null !!****
					}
					if(o.map_index_cmcdo[''+qtyType]){
						o.map_index_cmcdo[''+qtyType].qty = parseInt(tips_budget, 10);
					}
					//End: added by Peng Zhu 2013-06-19
				}
				//Commented by Peng Zhu 2013-06-19
				
				//Begin: added by Peng Zhu 2013-06-18 for filter show all
				//show the numbers
				if(filterShowAll){
					var totalQty = 0;
					var totalCycleDataCounter = 0;
					
					for(var i=0; i < filterSize; i++){
						if(o.map_index_cmcdo['' + i].qty != null && o.map_index_cmcdo['' + i].accountNum != null){
							totalQty += o.map_index_cmcdo['' + i].qty * o.map_index_cmcdo['' + i].accountNum;
							totalCycleDataCounter += o.map_index_cmcdo['' + i].accountNum;
						}
					}
					var customers = 0;
					if(totalCycleDataCounter > 0){
						customers = parseFloat(totalQty/totalCycleDataCounter).toFixed(1);
					}
					else customers = 0;
					
					//** here need consider if/how show qty when user change a qty **** //by fuqi
					var showAllHtml = '';
					if(_channelType == '1'){
						//console.log(':: Channel: ' + _channelType);
						showAllHtml += '<div class="physDiv">' + (o.customers == 'null' ? '0' : roundNumToKM(o.customers,theLocale,9999,0)) + '</div>';
						showAllHtml += '<div class="channelBudgetDiv">' + roundNumToKM(customers,theLocale,9999,1) + '</div>';
					}
					
					$(this).attr({'id':o.channelId}).html(showAllHtml);
				}else{
					if(_channelType == '1'){
						$(this).attr({'id':o.channelId}).text( (o.map_index_cmcdo[filterSelectIndex].qty == null ? '0' : o.map_index_cmcdo[filterSelectIndex].qty) );
					}
				}
				
				//End: added by Peng Zhu 2013-06-18 for filter show all
			});
			
		}

	}

	var dtd = $.Deferred(),  d = waitDeferred2(dtd, channelId);
	$.when(d)
	.done(function(){
		matrixTotalTable(true);
	}).fail(function(){ if(window.console)console.log('fail list_rows'); });
}


function BudgetChannelTotal(channelId){	//Budget Overview by Channel Table total
	var matrixDataId = ('#matrixData #'+channelId),
		PlannedTotal = 0, GainToal = 0, BuildTotal = 0, DefendTotal = 0, ObserveTotal = 0, MaintainTotal = 0; BlankTotal=0;

	$(matrixDataId).each(function(){
		var $this = $(this), t=1, $parent = $this.parent(), v = Globalize.parseInt($.trim($this.text()));
		if(filterShowAll){
			v = Globalize.parseInt($.trim($this.find('.channelBudgetDiv').text()));
		}
		
		//Begin: added by Peng Zhu <peng.zhu@itbconsult.com> 2013-06-19
		// -- when calculate "Allocated Units", we need Total_Customers__c
		var tc = $parent.attr('phys');
		if(tc){
			tc = $.trim(tc) != '' ? Globalize.parseInt(tc) : 0;
		}
		else{
			tc = 0;
		}
		//console.log('tc : ' + tc);
		//console.log('v : ' + v);
		//End: added by Peng Zhu <peng.zhu@itbconsult.com> 2013-06-19
		
		//Modified all the value from v to c*tc
		if($parent.hasClass('Gain')){
			GainToal = accAdd(v*tc, GainToal);
		}else if($parent.hasClass('Build')){
			BuildTotal = accAdd(v*tc, BuildTotal);
		}else if($parent.hasClass('Defend')){
			DefendTotal = accAdd(v*tc, DefendTotal);
		}else if($parent.hasClass('Observe')){
			ObserveTotal = accAdd(v*tc, ObserveTotal);
		}else if($parent.hasClass('Maintain')){
			MaintainTotal = accAdd(v*tc, MaintainTotal);
		}else if($parent.hasClass('Blank')){
			BlankTotal = accAdd(v*tc, BlankTotal);
		}
		
		PlannedTotal = accAdd(v*tc, PlannedTotal);
	});
	
	var channelTr = '#matrixTabTotal tbody tr#' + channelId + '_id', $channelTotal = $(channelTr), Plannedin = 0,
		channelTotal = $.trim($channelTotal.find('td.Totalcls').text());
	
	channelTotal = $.trim($channelTotal.find('td input[name=totalUnits]').val());
	
	channelTotal = channelTotal == '' ? 0 : Globalize.parseInt(channelTotal);
	
	$channelTotal.find('td.Plannedcls').text(formatCurrentNumber(PlannedTotal));
	if(channelTotal != 0){
		Plannedin = accMul((PlannedTotal / channelTotal), 100);
	}
	$channelTotal.find('td.Plannedincls').text(Globalize.format(Plannedin, 'n1')+' %');
	$channelTotal.find('td.Gaincls').text(formatCurrentNumber(GainToal));
	$channelTotal.find('td.Buildcls').text(formatCurrentNumber(BuildTotal));
	$channelTotal.find('td.Defendcls').text(formatCurrentNumber(DefendTotal));
	$channelTotal.find('td.Observecls').text(formatCurrentNumber(ObserveTotal));
	$channelTotal.find('td.Maintaincls').text(formatCurrentNumber(MaintainTotal));
	$channelTotal.find('td.Blankcls').text(formatCurrentNumber(MaintainTotal));

	//Begin: added by Peng Zhu 2013-06-28 for remaining field
	var remaingTotal = $channelTotal.find('td input[name=remainingUnits]').val();
	if(typeof remaingTotal != 'undefined' && $.trim(remaingTotal) != '') remaingTotal = Globalize.parseInt(remaingTotal);
	else remaingTotal = 0;
	
	remaingTotal = remaingTotal- PlannedTotal;
	if(remaingTotal < 0) remaingTotal = 0;
	$channelTotal.find('td.Remainingcls').text(formatCurrentNumber(remaingTotal));
	//End: added by Peng Zhu 2013-06-28 for remaining field
}

function formatCurrentNumber(nums){
	return (Globalize.format(nums, 'n0'));
}
function matrixTotalTable(isFist){
	
	if(!isFist){
		$('#matrixTabTotal .dataCelltd').each(function(indx){

			var $this = $(this), this_val = $.trim($this.text());
			
			//Begin: added by Peng Zhu 2013-06-28 for format number -- avoid 350.000 --> 350
			this_val =  Globalize.parseInt(this_val);
			//End: added by Peng Zhu 2013-06-28
			
			this_val = $.isNumeric(this_val) ? parseFloat(this_val) : 0;
			if($this.hasClass('Plannedincls')){
				this_val = Globalize.format(this_val, 'n1')+'%';
			}else{
				this_val = formatCurrentNumber(this_val);
			}
			$this.text(this_val);

		});
		
		barChart();
		
		return;
	}
	
	var list_cls = [], _cMap = new customMap();
		
//	_cMap.put('Plannedincls', 0);
	_cMap.put('Totalcls', 0); _cMap.put('Plannedcls', 0); _cMap.put('Gaincls', 0); 
	_cMap.put('Buildcls', 0); _cMap.put('Defendcls', 0); _cMap.put('Observecls', 0);
	_cMap.put('Maintaincls', 0); _cMap.put('Blankcls', 0);
	
	_cMap.put('Remainingcls', 0);
	
	list_cls = _cMap.keys();
	
	//calculate the total value for budget overview table
	for(var i=0; i<list_cls.length; i++){
		var clsName = list_cls[i], $find_th = $(('#matrixTabTotal tbody td.' + clsName)), th_v = _cMap.get(clsName);

		$find_th.each(function(){
			var $this = $(this),
				this_v = Globalize.parseInt($.trim($this.text()) == '' ? 0 : $.trim($this.text()));
			th_v += this_v;
		});
		_cMap.remove(clsName);
		_cMap.put(clsName, th_v);
	} 

	//populate the total value for budget overview table
	for(var i=0; i<list_cls.length; i++){
		var clsName = list_cls[i], find_th = ('#matrixTabTotal tfoot tr th.' + clsName), th_v = _cMap.get(clsName);
		$(find_th).text(formatCurrentNumber(th_v));
	}
	list_cls = [];
	
	
	//Calculate the total "Planned in %"
	var totals = _cMap.get('Totalcls'), planned = _cMap.get('Plannedcls'), plannedIn = 0;
	//Why add this statement?
	//totals = parseInt($('#matrixTabTotal tfoot tr th input[name="totalUnits"]').val());

	//added by Peng Zhu 2013-05-27 for avoiding Infinity result when totals is zero
	if(totals && totals != 0 && planned != 0){
		plannedIn = accMul( (planned/totals), 100 );
	}
	
	$('#matrixTabTotal tfoot tr th.Plannedincls').text(Globalize.format(plannedIn, 'n1')+' %');
	_cMap.clear();
	barChart();
}


function waitDeferred(dtd, list_cell, _channelType){
	var tasks = function(){
		cell_sum(list_cell, _channelType);
		dtd.resolve();
	};
	setTimeout(tasks,800);
	return dtd.promise(); 
}
function waitDeferred2(dtd, channelId){
	var tasks = function(){
		//BudgetChannelTotal(channelId);
		filterCombinationNameList_change($("select[id$='theFilterCombinationNameList']").val());
		dtd.resolve();
	};
	setTimeout(tasks,800);
	return dtd.promise(); 
}

function waitDeferredTipsTotal(dtd, $matrixData_selected){
	var tasks = function(){
		selectedCell_sum($matrixData_selected);
		dtd.resolve();
	};
	setTimeout(tasks,500);
	return dtd.promise(); 
}


function selectedCell_sum($matrixData_selected){
	var lens = $matrixData_selected.length, ProductRx=0, MarketRx=0, phys=0, marketTotal=0,
		$physId = $('#physId'), $marketRXId = $('#marketRXId'), $productRxId = $('#productRxId'), $marketShareId = $('#marketShareId'),
		$tipsAverageDivId = $('#tipsAverageDivId');

	//Begin: added by Peng Zhu 
	var reportUrl = '';
	//End: added by Peng Zhu 
	
	if(lens == 1){
		//Begin: added by Peng Zhu 
		reportUrl = matrixDrillDownReportUrl;
		if($matrixData_selected.attr('id') && $.trim($matrixData_selected.attr('id')) != ''){
			reportUrl += '?pv0=' + $.trim($matrixData_selected.attr('id')).substring(0, 15);
		}
		
		$("a[name='drillDownReport']").attr('href', reportUrl);
		//End: added by Peng Zhu 
		phys = $.trim($matrixData_selected.attr('phys'));
		phys = isUndefinedTag(phys) && phys != '' ? parseInt(phys) : 0;
		$physId.text(Globalize.format(phys, 'n0'));
		
		ProductRx = $.trim($matrixData_selected.attr('ProductRx'));
		ProductRx = isUndefinedTag(ProductRx) && ProductRx != '' ? parseInt(ProductRx) : 0;
		
		
		MarketRx = $.trim($matrixData_selected.attr('MarketRx'));
		MarketRx = isUndefinedTag(MarketRx) && MarketRx != '' ? parseInt(MarketRx) : 0;

		if($tipsAverageDivId.hasClass('inbg') && phys != 0){	//avg
			MarketRx = MarketRx/phys;
			ProductRx = ProductRx/phys;
		}
		
		$productRxId.text(Globalize.format(ProductRx, 'n0'));
		$marketRXId.text(Globalize.format(MarketRx, 'n0'));
		
		marketTotal = $.trim($matrixData_selected.attr('TotalMarketShare'));
		marketTotal = isUndefinedTag(marketTotal) && marketTotal != '' ? marketTotal : 0;
		
		$marketShareId.text(marketTotal + '%');
		return;
	}
	
	$matrixData_selected.each(function(){
	
		var $this = $(this); 
		
		//Begin: added by Peng Zhu 2013-06-20 for report
		if($this.attr('id') && $.trim($this.attr('id')) != ''){
			reportUrl += $.trim($this.attr('id')).substring(0, 15) + ',';
		}
		//End: added by Peng Zhu 2013-06-20 for report
		
		productRxTmp = $.trim($this.attr('ProductRx')),
		marketRxTmp = $.trim($this.attr('MarketRx')),
		physTmp = $.trim($this.attr('phys'));
			
		productRxTmp = isUndefinedTag(productRxTmp) && productRxTmp != '' ? parseInt(productRxTmp) : 0;
		ProductRx = accAdd(productRxTmp, ProductRx);
		
		marketRxTmp = isUndefinedTag(marketRxTmp) && marketRxTmp != '' ? parseInt(marketRxTmp) : 0;
		MarketRx = accAdd(marketRxTmp, MarketRx);
		
		productRxTmp = isUndefinedTag(physTmp) && physTmp != '' ? parseInt(physTmp) : 0;
		phys = accAdd(physTmp, phys);
	});
	//Begin: added by Peng Zhu 2013-06-20 for report
	if(reportUrl != null && $.trim(reportUrl) != ''){
		reportUrl = $.trim(reportUrl);
		reportUrl = reportUrl.substring(0, reportUrl.length - 1);
    	reportUrl = matrixDrillDownReportUrl + '?pv0=' + reportUrl;
	}
	else{
		reportUrl = matrixDrillDownReportUrl;
	}
	$("a[name='drillDownReport']").attr('href', reportUrl);
	//End: added by Peng Zhu 2013-06-20 for report
	
	$physId.text(Globalize.format(phys, 'n0'));
	
	
	if($tipsAverageDivId.hasClass('inbg')  && phys != 0){	//avg
		MarketRx = MarketRx/phys;
		ProductRx = ProductRx/phys;
	}
	$productRxId.text(Globalize.format(ProductRx, 'n0'));
	$marketRXId.text(Globalize.format(MarketRx, 'n0'));
	if(ProductRx != 0){
		marketTotal = roundFn(accMul(ProductRx/MarketRx, 100), 2);
	}
	$marketShareId.text(marketTotal + '%');
	
}
function cell_sum(list_cell, _channelType){
	list_cell = $.unique(list_cell);
	for(var i=0, max=list_cell.length; i<max; i++){
		var cell = list_cell[i],
			cellcls = ('#matrixData li.' + cell), 
			celltotal = ('#matrixData li.' + cell + '_total'), 
			total_1 = 0, total_2 = 0;
		$(cellcls).each(function(){
			var $this = $(this), 
				channel1 = $.trim($this.find('div:first').text()),
				channel2 = $.trim($this.find('div:last').text());
			total_1 = accAdd(channel1, total_1);
			total_2 = accAdd(channel2, total_2);
		});
		switch(_channelType){
			case '1' : $(celltotal).find('div:first').text(total_1); break;
			case '2' : $(celltotal).find('div:last').text(total_2); break;
			default :break;
		}
		
		
	}
	list_cell = [];
	
}

function barChart(){
	//************************-= Begin: added by Peng Zhu 2013-11-06 for multiple channel barchart =-**********************************
	$('#barChartId').html('');
	
	var list_ch2bdgt = [], list_chName = [], labee_config = labelConfig();
	//#matrixTabTotal tbody tr
	$("#matrixTabTotal tbody tr[id$='_id']").each(function(idx){
	    var $this = $(this), gain_v = 0, build_v = 0, defend_v = 0, observe_v = 0, maintain_v = 0, total_v = 0;  
	    var gain_p = 0, build_p = 0, defend_p = 0, observe_p = 0, maintain_p = 0;
	    
	 	list_chName[idx] = $.trim($this.find("td:first").text());
	 
	    var $gain_td = $this.find("td.Gaincls"),
	        $build_td = $this.find("td.Buildcls"),
	        $defend_td = $this.find("td.Defendcls"),
	        $observe_td = $this.find("td.Observecls"),
	        $maintain_td = $this.find("td.Maintaincls");
	
	    if($gain_td){
	        gain_v = $.trim($gain_td.text());
	        gain_v = gain_v != '' ? Globalize.parseInt(gain_v) : 0;
	    }
	
	    if($build_td){
	        build_v = $.trim($build_td.text());
	        build_v = build_v != '' ? Globalize.parseInt(build_v) : 0;
	    }
	
	    if($defend_td){
	        defend_v = $.trim($defend_td.text());
	        defend_v = defend_v != '' ? Globalize.parseInt(defend_v) : 0;
	    }
	
	    if($observe_td){
	        observe_v = $.trim($observe_td.text());
	        observe_v = observe_v != '' ? Globalize.parseInt(observe_v) : 0;
	    }
	
	    if($maintain_td){
	        maintain_v = $.trim($maintain_td.text());
	        maintain_v = maintain_v != '' ? Globalize.parseInt(maintain_v) : 0;
	    }
	
	    total_v = gain_v + build_v + defend_v + observe_v + maintain_v;
	
	    if(total_v > 0){
	        gain_p = (Math.round((gain_v/total_v*1000)))/10;
	        build_p = (Math.round((build_v/total_v*1000)))/10;
	        defend_p = (Math.round((defend_v/total_v*1000)))/10;
	        observe_p = (Math.round((observe_v/total_v*1000)))/10;
	        maintain_p = (Math.round((maintain_v/total_v*1000)))/10;
	    }
	    
	    list_ch2bdgt[idx] = [gain_p, build_p, defend_p, observe_p, maintain_p];
	
	    var error_p = Math.round((gain_p + build_p + defend_p + observe_p + maintain_p - 100)*100)/100;
	
	    if(error_p){
	        var max_idx = 0, max_v = 0;
	        for(var i = 0; i < list_ch2bdgt[idx].length; i++){
	            if(list_ch2bdgt[idx][i] > max_v){
	                max_v = list_ch2bdgt[idx][i];
	                max_idx = i;
	            }
	        }
	        if(max_v){
	            max_v = max_v - error_p;
	            list_ch2bdgt[idx][max_idx] = max_v;
	        }
	    }
	}); 
 	
    var ticks_bdgt = [
    	labee_config.a, labee_config.b, labee_config.c, labee_config.d, labee_config.e
	],

 	series_bdgt = [];
	
	for(var i = 0; i < list_chName.length; i++){
		series_bdgt.push({label: list_chName[i]});
	}
	
	try{
 		var plot1 = $.jqplot('barChartId', list_ch2bdgt, {
 			
 			seriesDefaults:{
 				renderer:$.jqplot.BarRenderer,
 				rendererOptions: {
 					barWidth: 10,
 					barPadding: 3,
 					fillToZero: true
 				},
 				pointLabels: { show: true }
 			},
 			animate: true,
 			cursor: { show: false, showTooltip:false },
 			series: series_bdgt,
	        legend: {
	            show: true,
	            placement: 'outsideGrid'
	        },
 			axes: {
 				xaxis: {
 					renderer: $.jqplot.CategoryAxisRenderer,
 					ticks: ticks_bdgt,
 					tickRenderer:$.jqplot.CanvasAxisTickRenderer,
 					tickOptions: {
 					}
 				},
 				yaxis: {
 					max:100,
 					padMin: 0,
 					tickOptions:{
 						formatString: '%d'
 					}
 				},
 				showMinorTicks:true
 			},
 			highlighter: {
 				showLabel: true, 
 				showTooltip:false,
 				tooltipAxes: 'xy',
 				useAxesFormatters:true,
 				sizeAdjust: 0 , 
 				tooltipLocation : 'ne'
 			}
 		});	
 	}catch(e){
 		
 	}
	//************************-= End: added by Peng Zhu 2013-11-06 for multiple channel barchart =-**********************************
}

function channelContent_stop_fn(event, ui){	//sortable   channel goto channelContent
	tipsShowOption();
//	$(ui.item).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
}

function channel_stop_fn(event, ui){	//sortable   channelContent goto channel
	
	var $item = $(ui.item), itemId = $item.attr('id'), 
		$channelItem1 = $('#channel1DivContent li'), 
		$channelItem2 = $('#channel2DivContent li'),
		channelItemId1 = $.trim($channelItem1.attr('id')), 
		channelItemId2 = $.trim($channelItem2.attr('id'));
		
	if(itemId == channelItemId1 || itemId == channelItemId2){
		$(ui.item).addClass('ui-state-disabled').css({'opacity': 0.4});
	}
	tipsShowOption();
}


function init_budget_overview(){
	$('#loading-curtain-div').show();
	$("select[id$='channel1Picklist']").children().each(function(){
	    var $this = $(this);   
	    if($this.val()){
	        var cId = $this.val();
			var currentId = cId, $dragCurrent = $(('#channelDivId li#' + currentId ));
			var $dragTarget = $("#channel1DivContent").find('li'), targetId = $dragTarget.attr('id');
			if(typeof(targetId) != 'undefined' && targetId != '' && currentId != targetId){	//cleart old channel
				$(('#channelDivId li#'+targetId)).removeClass('ui-state-disabled').css({'opacity': 1});
			}
		
			$dragTarget.attr({'id': currentId, 'liUnit__c': $dragCurrent.attr('liUnit__c'), 'liCost_Rate__c': $dragCurrent.attr('liCost_Rate__c')}).addClass('pgover').html($dragCurrent.text()).removeClass('ui-state-disabled');
			channelPopAssignment('add', null, $dragTarget);
	    }
	});
	$('#loading-curtain-div').hide();
}
/**
 *  added by Peng Zhu 2013-10-28 for channel picklist change
 */
function channel_change_fn(chType, chId){
	if(chType){
		var $channel1 = $("select[id$='channel1Picklist']"), $channel2 = $("select[id$='channel2Picklist']");
        var channel1 = $channel1.get(0), channel2 = $channel2.get(0);
        
        var lastSelecValCh1 = $channel1.data('lastSelecVal'),
        	lastSelecTxtCh1 = $channel1.data('lastSelecTxt'),
        	lastSelecValCh2 = $channel2.data('lastSelecVal'),
        	lastSelecTxtCh2 = $channel2.data('lastSelecTxt');
	
		switch(chType){
			case '1': 
				if (lastSelecValCh1 != null && lastSelecTxtCh1 != null) {
	                jsAddItemToSelect(channel2, lastSelecTxtCh1, lastSelecValCh1);
	            }
	            var selecval = channel1.value;
	            lastSelecValCh1 = selecval;
	            var selectxt = channel1.options[channel1.selectedIndex].text;
	            lastSelecTxtCh1 = selectxt;
	            var selecidx = channel1.selectedIndex;
	            if (selecval) {
	                jsRemoveItemFromSelect(channel2, selecval);
	            }
	            
            	$channel1.data('lastSelecVal', lastSelecValCh1);
        	 	$channel1.data('lastSelecTxt', lastSelecTxtCh1);
			
				if(chId){
					var currentId = chId, $dragCurrent = $(('#channelDivId li#' + currentId ));
					var $dragTarget = $("#channel1DivContent").find('li'), targetId = $dragTarget.attr('id');
					if(typeof(targetId) != 'undefined' && targetId != '' && currentId != targetId){	//cleart old channel
						$(('#channelDivId li#'+targetId)).removeClass('ui-state-disabled').css({'opacity': 1});
					}
	
					$dragTarget.attr({'id': currentId, 'liUnit__c': $dragCurrent.attr('liUnit__c'), 'liCost_Rate__c': $dragCurrent.attr('liCost_Rate__c')}).addClass('pgover').html($dragCurrent.text()).removeClass('ui-state-disabled');
					channelPopAssignment('add', null, $dragTarget);
				}
				else{
					$(('#channel1DivContent li')).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
					channelPopAssignment('del', '1', null);
				}
				break;
			case '2': 
	            if (lastSelecValCh2 != null && lastSelecTxtCh2 != null) {
	                jsAddItemToSelect(channel1, lastSelecTxtCh2, lastSelecValCh2);
	            }
	            var selecval = channel2.value;
	            lastSelecValCh2 = selecval;
	            var selectxt = channel2.options[channel2.selectedIndex].text;
	            lastSelecTxtCh2 = selectxt;
	            var selecidx = channel2.selectedIndex;
	            if (selecval) {
	                jsRemoveItemFromSelect(channel1, selecval);
	            }
        	 	$channel2.data('lastSelecVal', lastSelecValCh2);
        	 	$channel2.data('lastSelecTxt', lastSelecTxtCh2);
			
				if(chId){
					var currentId = chId, $dragCurrent = $(('#channelDivId li#' + currentId ));
					var $dragTarget = $("#channel2DivContent").find('li'), targetId = $dragTarget.attr('id');
					if(typeof(targetId) != 'undefined' && targetId != '' && currentId != targetId){	//cleart old channel
						$(('#channelDivId li#'+targetId)).removeClass('ui-state-disabled').css({'opacity': 1});
					}
	
					$dragTarget.attr({'id': currentId, 'liUnit__c': $dragCurrent.attr('liUnit__c'), 'liCost_Rate__c': $dragCurrent.attr('liCost_Rate__c')}).addClass('pgover').html($dragCurrent.text()).removeClass('ui-state-disabled');
					channelPopAssignment('add', null, $dragTarget);
				}
				else{
					$(('#channel2DivContent li')).attr({'id':''}).text('').addClass('ui-state-disabled').removeClass('pgover');
					channelPopAssignment('del', '2', null);
				}
				break;
			default: break;
		}
	}
}


function select_table_stop_fn(event,ui){
	var dtd = $.Deferred(),  $selectedLis = $('#matrixData li.ui-selected'), d = waitDeferredTipsTotal(dtd, $selectedLis);
	
	$.when(d)	//# Phys: //Market Rx:	//Product Rx:	//Market Share:
		.done(function(){
			channelPopAssignment('add', null, null);
			tipsShowOption($selectedLis);
		//	$('#colorbody').fadeIn();
		}).fail(function(){ if(window.console)console.log('fail waitDeferredTipsTotal'); });
	
}

var h = 95, h_one = 157;
function e_over_click_overMenu(e){
	var $this = $(this), $channelDropDiv = $('#channelDropDiv'), $chartDiv = $('#chartDivId');
	switch(e.type){
		case 'mouseenter': 
			overHidenTable($this);
			if(h == null){
				h = $channelDropDiv.height()-15;
			}
			break;
		case 'click': 
			if($this.hasClass('hide')){
				$channelDropDiv.stop(true, true).animate({height: 20}, 1200, function(){
					$(this).find('.show').stop(true, true).fadeIn();
					$chartDiv.css({'line-height':'0px'});//.find('img').css({'top': 2});
				});//.show();
			}else{
				$channelDropDiv.stop(true, true).animate({height: h}, 1200, function(){
					$(this).removeAttr('style').find('.hide').stop(true, true).fadeIn();
					$chartDiv.css({'line-height': '90px'});//.find('img').css({'top': '45%'});
				});//.show();
			}
			$this.hide().find('img').removeClass('over');
			break;
		default : overHidenTable($this); break;
	}
}
function e_over_overTable(e){
	var $this = $(this), $overHide = $('#overTableHideId');
	switch(e.type){
	case 'mouseenter': 
		//$overHide.fadeIn(); 
		$overHide.css("visibility","visible"); 
		break;
	default :
		if($this.height() > 30){
			//$overHide.fadeOut(); 
			$overHide.css("visibility","hidden"); 
		}
		break;
	}
}
function e_over_click_overTable(e){
	var $this = $(this), $matrixTableId = $('#matrixTotalClsId');
	switch(e.type){
	case 'mouseenter': 
		overHidenTable($this); 
		if(h_one == null){ h_one = $matrixTableId.height(); }
		break;
	case 'click':
		if($this.hasClass('hide')){
			$this.fadeOut(function(){
				$matrixTableId.stop(true, true).animate({height:25}, 1200, function(){
					$matrixTableId.find('div.tmpCls').hide();
					$this.addClass('show').removeClass('hide').attr({'title': 'show'}).show().find('img').removeClass('downDownCls').addClass('downUpCls');
				});
			});
		}else{
			$this.fadeOut(function(){
				$matrixTableId.find('div.tmpCls').show();
				$matrixTableId.stop(true, true).animate({height:h_one}, 1200, function(){
					$matrixTableId.removeAttr('style');
					$this.addClass('hide').removeClass('show').attr({'title': 'hide'}).fadeIn().find('img').removeClass('downUpCls').addClass('downDownCls');
				});
			});
		}
	//	$this.hide().find('img').removeClass('over');
		break;
	default : overHidenTable($this); break;
	}
}

function overHidenTable(_$this){
	if(_$this.hasClass('pgover')){
		_$this.removeClass('pgover').find('img').removeClass('over');
	}else{
		_$this.addClass('pgover').find('img').addClass('over');
	}
}

function e_over_channelDropDivId(e){
	var $this = $(this);
	switch(e.type){
		case 'mouseenter': 
				if($this.height() > 50){
					$this.find('.hide').stop(true, true).fadeIn();//.show();
				}
			break;
		default : 
				$this.removeClass('pgover').find('.hide').stop(true, true).fadeOut();//.hide();
			break;
	}
}



function e_over_draggable(e){
	var $this = $(this);
	switch(e.type){
		case 'mouseenter': $this.addClass('pgover'); break;
		default : $this.removeClass('pgover'); break;
	}
}

function showHeader_click(target){	//AppBodyHeader
	$('#loading-curtain-div').show();
	var $this = $(target), thisVal = 'ShowHeader', t = headerH, displayt = '';

	if($.trim($this.val()) == 'HideHeader'){
		thisVal = 'ShowHeader';
		displayt = 'none';
		t = 0;
	}else{
		thisVal = 'HideHeader';
	}
	$this.val(thisVal);
	$('#AppBodyHeader').stop(true, true).animate({height: t}, 1200, function(){
		$(this).find('#phHeader').css({'display': displayt});
		$('#loading-curtain-div').hide();
	});
}

;function eventHandle(event){
	var customMouser = {mouseenter: arguments[1],mouseleave: arguments[2]};
	customMouser[event.type].call(this, event);customMouser = {};
}
;function eventHandle1(event){
	var customMouser = {mouseenter: arguments[1],mouseleave: arguments[2],click: arguments[3]};
	customMouser[event.type].call(this, event);customMouser = {};
}
;function isUndefinedTag(elementTag){
	if(typeof(elementTag) != 'undefined'){
		return true;
	}
	return false;
}
function toObject(a){	//a[i][0]   [0] is first prodcut code 
	var o = {}; 
	for (var i=0, j=a.length; i<j; i=i+1) { o[$.trim(a[i][0])] = a[i]; } 
	return o; 
}
function keys(t){
	var o = toObject(t), a=[], i; 
	for (i in o) { if (o.hasOwnProperty(i)) { a.push(o[i]); } } 
	return a; 
}
function uniqArrays(x){ return (keys(x)); }

function killEnter(evt,el){
	if(evt.keyCode == 13){
		if(evt.preventDefault)
			evt.preventDefault();
		else
			event.returnValue = false;
			
		if(evt.stopPropagation)
			evt.stopPropagation();
		else
			event.cancelBubble = true;
		var $el = $(el);
		$el.next().focus().blur();
		if($el.hasClass('ipt_all')){
			applyAllQty(evt,$el.next().get(0));
		}
	}
}

/**
 * Show budget overview table
 * Added by Peng Zhu 2013-06-20
 */
function showBudgetOverviewTable(){
	if(!$('#overTableHideId').hasClass('hide')){
		$('#overTableHideId').fadeOut(function(){
			$('#matrixTotalClsId').find('div.tmpCls').show();
			$('#matrixTotalClsId').stop(true, true).animate({height:h_one}, 1200, function(){
				$('#matrixTotalClsId').removeAttr('style');
				$('#overTableHideId').addClass('hide').removeClass('show').attr({'title': 'hide'}).fadeIn().find('img').removeClass('downUpCls').addClass('downDownCls');
			});
		});
	}
}

function roundNumToKM(num,locale,kLevel,digits){
	
	if(isNaN(num)){ 
		if(!num)
		return 0;
		else return num;
	}
	var flag = num < 0 ? '-':'',startLevel = kLevel;
	num = Math.abs(num);
	if(!startLevel) startLevel = 1000;
	
	if(num<startLevel){
		num=FormatNums(num,locale,false,digits);
	}
	else if(num<1000000){
			num=Math.round(num/100)/10;
			//num=Math.round(num/1000);
			num=FormatNums(num,locale);
			num+='K';
	}
	else if(num<1000000000){
			num=Math.round(num/100000)/10;
			//num=Math.round(num/1000000);
			num=FormatNums(num,locale);
			num+='M';				
	}else if(num<1000000000000){
			num=Math.round(num/100000000)/10;
			//num=Math.round(num/1000000000);
			num=FormatNums(num,locale);
			num+='B';
	}else if(num<1000000000000000){
			num=Math.round(num/100000000000)/10;
			//num=Math.round(num/1000000000);
			num=FormatNums(num,locale);
			num+='T';
	}
	else{
		alert('Meet with too large number : ' + num);
		num='';
	}
	if(num !== ''){
		num = flag + num;
	}	
	return num;
}

function FormatNums(num,locale,flag,digits){
	locale=(''+locale).toLowerCase();
	if(num===''||(num&&num.charCodeAt&&num.substr)||isNaN(num)) {
		if(flag){
			if(locale === 'de'){
			 	unformateNum(num,'.',',',2);
			 }else{
			 	unformateNum(num,',','.',2);
			 }
		}else{
			unformateNum(num,locale,false); // change into number with function unformateNum.
		}
	}
	var isNegative = false;
	if(isNaN(digits))
		num = num.toFixed(1);
	else{
		isNegative = num <0 ? true : false;
		num = num.toFixed(digits);
	}
	var spt,deci,numint,numdec,numlen,result,position;
	if(locale=='de'){
		spt='.',deci=',',result='';
	}else{		
		spt=',',deci='.',result='';
	}
	if(isNegative) {
		result = '-';	
		num = num.replace('-','');
	}
	position=num.lastIndexOf('.');
	if(position>=0){
		numdec=num.substr(position+1);
		if(position>0)numint=num.substring(0,position);
	}else{
		numint=num;
	}

	numlen=numint.length; 
	while(numlen>3){
		var deduct=numlen%3;
		deduct=(deduct==0?3:deduct);
			result+=numint.substr(0,deduct)+spt;
			numint=numint.substr(deduct);
			numlen=numlen-deduct;		
	}
	result+=numint; 
	if(position>=0){
		result=result+deci+numdec;
	}
	return result;
}

function unformateNum(num,seperator,decimal,setScale,locale){
	num=''+num;
	var regEndWithK=/[K,k]{1}$/;
	var regEndWithM=/[M,m]{1}$/;
	var regEndWithB=/[B,b]{1}$/;
	var regEndWithT=/[T,t]{1}$/;
	var isEndWithK=regEndWithK.test(num);
	var isEndWithM=regEndWithM.test(num);	
	var isEndWithB=regEndWithB.test(num);
	var isEndWithT=regEndWithT.test(num);	
	var otherchar;
	
	otherchar=/[^\d\,]/g ;
	num=num.replace(otherchar,'');
	if(locale=='de'){
		num=num.replace(',','.');//replace with decimal
	}
	num=parseFloat(num);	
	if(isNaN(num)) num=0;
	if(isEndWithK){
		num*=1000;
	}else if(isEndWithM){
		num*=1000000;
	}else if(isEndWithB){
		num*=1000000000;
	}else if(isEndWithT){
		num*=1000000000000;
	}
	return num;	
}

/**
 *  Added by Peng Zhu 2013-10-31
 */
function waitDeferredChannel(dtd, channelId){
	var tasks = function(){
		$("select[id$='channel1Picklist']").val(channelId);
		$("select[id$='channel1Picklist']").change();
		matrixTotalTable(false);
		dtd.resolve();
	};
	setTimeout(tasks,800);
	return dtd.promise(); 
}

function initBudgetOverviewTable(chArr){
	if($('#loading-curtain-div').is(':hidden')) $('#loading-curtain-div').show();
	if(chArr && chArr.length){
		var channelId = chArr.pop();
		var dtd = $.Deferred(), d = waitDeferredChannel(dtd, channelId);
		$.when(d)
		.done(function(){
			initBudgetOverviewTable(chArr);
		}).fail(function(){ if(window.console)console.log('fail list_rows'); });
	}
	else{
	
	    if($("select[id$='channel2Picklist']").val()){
	    	$("select[id$='channel2Picklist']").change();
	    }
	    
		$('#loading-curtain-div').hide();
	}
}

/**
 *  Function for select
 */
function jsSelectIsExitItem(objSelect, objItemValue) {
    var isExit = false;
    for (var i = 0; i < objSelect.options.length; i++) {
        if (objSelect.options[i].value == objItemValue) {
            isExit = true;
            break;
        }
    }
    return isExit;
}    

     
function jsAddItemToSelect(objSelect, objItemText, objItemValue) {
    if (jsSelectIsExitItem(objSelect, objItemValue)) {
    } else {
        var varItem = new Option(objItemText, objItemValue);
        objSelect.options.add(varItem);
    }
}   
    
function jsRemoveItemFromSelect(objSelect, objItemValue) {
    if (jsSelectIsExitItem(objSelect, objItemValue)) {
        for (var i = 0; i < objSelect.options.length; i++) {
            if (objSelect.options[i].value == objItemValue) {
                objSelect.options.remove(i);
                break;
            }
        }
    } else {
    }
} 

/**
 *  added by Peng Zhu 2013-11-14
 */
function filterCombinationNameList_change(idx){
	var segmentArr = ['Gain', 'Build', 'Defend', 'Observe', 'Maintain','Blank'];
	var channelIdArr = []; 
	var summarySegment = {'Gain':0, 'Build':0, 'Defend':0, 'Observe':0,'Maintain':0 ,'Blank':0 };
	var summaryPotentialPercent = {'Gain_Potential':0, 'Build_Potential':0, 'Defend_Potential':0, 'Observe_Potential':0, 'Maintain_Potential':0, 'Blank_Potential':0}
	var summaryAdoptionPercent = {'Gain_Adoption':0, 'Build_Adoption':0, 'Defend_Adoption':0, 'Observe_Adoption':0, 'Maintain_Adoption':0, 'Blank_Adoption':0}
	var _P = '_Potential', _A = '_Adoption', _C='_Cust'; 
	var totalPotential = 0, totalAdoption = 0;
	var GainCust = 0, BuildCust = 0, DefendCust = 0, ObserveCust = 0, MaintainCust = 0, BlankCust = 0;
	var thelocale='other';
	
	if(/^de/.test(UserContext.locale)){
		thelocale = 'de';
	}
	
	for (var i = JSON_CHANNELS.length - 1; i >= 0; i--) {
		var o = JSON_CHANNELS[i];
		var oCust = o.customers == 'null' ? 0 : parseInt(o.customers);
		var oAllocatedUnits = o.allocatedUnits == 'null' ? 0 : parseInt(o.allocatedUnits);
		var oPotential = o.potential == 'null' ? 0 : parseInt(o.potential);
		var oAdoption = o.intimacy == 'null' ? 0 : parseInt(o.intimacy);

		if (o.channelId && ($.trim(o.channelId) != '') && (segmentArr.indexOf(o.segment) > -1)) {

			if (!channelIdArr[o.channelId]){
				channelIdArr[o.channelId] = {'Gain':0, 'Build':0, 'Defend':0, 'Observe':0,'Maintain':0,'Blank':0,
											'Gain_Cust':0,'Build_Cust':0,'Defend_Cust':0,'Observe_Cust':0,'Maintain_Cust':0,'Blank_Cust':0,
											'TotalPlan':0};
					
			}
			var seg_v = parseInt(channelIdArr[o.channelId][o.segment]), seg_vt = 0, totalPlan = parseInt(channelIdArr[o.channelId]['TotalPlan']);

			/**if(o.map_index_cmcdo[idx] && o.map_index_cmcdo[idx].qty){
				//map contains idx
				//seg_vt = parseInt(o.map_index_cmcdo[idx].qty);
				var j_qty = parseInt(o.map_index_cmcdo[idx].qty);
				var j_cust = o.map_index_cmcdo[j].accountNum == null ? 0 : o.map_index_cmcdo[j].accountNum;
				seg_vt = (j_qty*j_cust);  
			}
			else{*/
				//calculate avg 
			var totalQty = 0, totalCust = 0;
			for(var j in o.map_index_cmcdo){
				var j_qty = o.map_index_cmcdo[j].qty == null ? 0 : o.map_index_cmcdo[j].qty;
				var j_cust = o.map_index_cmcdo[j].accountNum == null ? 0 : o.map_index_cmcdo[j].accountNum;
				
				totalQty += parseInt(j_qty) * parseInt(j_cust);
				totalCust += parseInt(j_cust);
			}
			
			if(totalQty > 0)
				seg_vt = totalQty;//parseFloat(totalQty/totalCust).toFixed(0);
				//}End else
			
			seg_v = seg_vt;//parseInt(seg_vt) * parseInt(oAllocatedUnits);
			
			
			totalPlan += seg_v;//parseInt(seg_vt) * parseInt(seg_v);
			
			//console.log(':: Segment: ' + o.segment);
			
			channelIdArr[o.channelId][o.segment] += seg_v;
			channelIdArr[o.channelId][o.segment+_C] += oCust;
			
			if(o.segment != 'Blank')
				channelIdArr[o.channelId]['TotalPlan'] = totalPlan;
			
			//jescobar: Sum up the total potential by segment and the total potential for the matrix
			summaryPotentialPercent[o.segment+_P] += oPotential;
			summaryAdoptionPercent[o.segment+_A] += oAdoption;
			totalPotential += oPotential; 
			totalAdoption += oAdoption;
		};
	};
	 
	
	$("#matrixTabTotal tbody tr[id$='_id']").each(function(){
		var PlannedTotal = 0, GainTotal = 0, BuildTotal = 0, DefendTotal = 0, ObserveTotal = 0, MaintainTotal = 0,BlannkTotal = 0, Plannedin = 0;
		var $tr = $(this), trId = $tr.attr('id'), channelId = trId.split('_')[0];
		
		if(channelIdArr[channelId]){
			PlannedTotal = channelIdArr[channelId]['TotalPlan'];
			GainTotal = channelIdArr[channelId]['Gain'];
			BuildTotal = channelIdArr[channelId]['Build'];
			DefendTotal = channelIdArr[channelId]['Defend'];
			ObserveTotal = channelIdArr[channelId]['Observe'];
			MaintainTotal = channelIdArr[channelId]['Maintain'];
			BlankTotal = channelIdArr[channelId]['Blank'];
			
			//jescobar: Get total customer by Segment
			GainCust = (channelIdArr[channelId]['Gain'+_C]);
			BuildCust = (channelIdArr[channelId]['Build'+_C]);
			DefendCust = (channelIdArr[channelId]['Defend'+_C]);
			ObserveCust = (channelIdArr[channelId]['Observe'+_C]);
			MaintainCust = (channelIdArr[channelId]['Maintain'+_C]);
			BlankCust = (channelIdArr[channelId]['Blank'+_C]);
		};

		var channelTotal = $.trim($tr.find('td input[name=totalUnits]').val());
		channelTotal = channelTotal == '' ? 0 : Globalize.parseInt(channelTotal);
		$tr.find('td.Plannedcls').text(formatCurrentNumber(PlannedTotal));
	
		if(channelTotal != 0){
			Plannedin = accMul((PlannedTotal / channelTotal), 100);
		}
		
		$tr.find('td.Plannedincls').text(Globalize.format(Plannedin, 'n1')+' %');
		$tr.find('td.Gaincls').text(formatCurrentNumber(GainTotal));
		$tr.find('td.Buildcls').text(formatCurrentNumber(BuildTotal));
		$tr.find('td.Defendcls').text(formatCurrentNumber(DefendTotal));
		$tr.find('td.Observecls').text(formatCurrentNumber(ObserveTotal));
		$tr.find('td.Maintaincls').text(formatCurrentNumber(MaintainTotal));
		$tr.find('td.Blankcls').text(formatCurrentNumber(BlankTotal));
		
		//jescobar: Set Detail Average Customer
		var gainAvgCust = (GainCust == null || GainCust == 0) ? 0 : (GainTotal/GainCust);
		var buildAvgCust = (BuildCust == null || BuildCust == 0) ? 0 : (BuildTotal/BuildCust);
		var defendAvgCust = (DefendCust == null || DefendCust == 0) ? 0 : (DefendTotal/DefendCust);
		var observeAvgCust = (ObserveCust == null || ObserveCust == 0) ? 0 : (ObserveTotal/ObserveCust);
		var maintainAvgCust = (MaintainCust == null || MaintainCust == 0) ? 0 : (MaintainTotal/MaintainCust);
		var blankAvgCust = (BlankCust == null || BlankCust == 0) ? 0 : (BlankTotal/BlankCust);
		
		$tr.find('td.AvgCustGain').text(FormatNums(gainAvgCust,thelocale,false,2));
		$tr.find('td.AvgCustBuild').text(FormatNums(buildAvgCust,thelocale,false,2));
		$tr.find('td.AvgCustDefend').text(FormatNums(defendAvgCust,thelocale,false,2));
		$tr.find('td.AvgCustObserve').text(FormatNums(observeAvgCust,thelocale,false,2));
		$tr.find('td.AvgCustMaintain').text(FormatNums(maintainAvgCust,thelocale,false,2));
		$tr.find('td.AvgCustBlank').text(FormatNums(blankAvgCust,thelocale,false,2));
		
		//Begin: added by Peng Zhu 2013-06-28 for remaining field
		var remaingTotal = $tr.find('td input[name=remainingUnits]').val();
		if(typeof remaingTotal != 'undefined' && $.trim(remaingTotal) != '') 
			remaingTotal = Globalize.parseInt(remaingTotal);
		else
			remaingTotal = 0;
		
		remaingTotal = channelTotal - PlannedTotal;
		if(remaingTotal < 0) 
			remaingTotal = 0;
		
		$tr.find('td.Remainingcls').text(formatCurrentNumber(remaingTotal));
		//End: added by Peng Zhu 2013-06-28 for remaining field
	});
	
	//@jescobar: Potential segments summary table
	$("#matrixTabTotal tbody tr[id$='_seg']").each(function(){
		var GainPotentialP = 0, BuidlPotentialP = 0, DefendPotentialP = 0, ObservePotentialP = 0, MaintainPotentialP = 0, BlankPotentialP = 0 ;
		var GainAdoptionP = 0, BuidlAdoptionP = 0, DefendAdoptionP = 0, ObserveAdoptionP = 0, MaintainAdoptionP = 0, BlankAdoptionP = 0;
		var $tr = $(this);
		
		//console.log(':: Gain Cust: ' + GainCust);
		//jescobar: Set data for total customer by Segment
		$tr.find('td.GainclsCustomer').text(formatCurrentNumber(GainCust));
		$tr.find('td.BuildclsCustomer').text(formatCurrentNumber(BuildCust));
		$tr.find('td.DefendclsCustomer').text(formatCurrentNumber(DefendCust));
		$tr.find('td.ObserveclsCustomer').text(formatCurrentNumber(ObserveCust));
		$tr.find('td.MaintainclsCustomer').text(formatCurrentNumber(MaintainCust));
		$tr.find('td.BlankclsCustomer').text(formatCurrentNumber(BlankCust));
		
		/**jescobar: Get potential and adoption total by Segment*/
		//Potential
		GainPotentialP = summaryPotentialPercent['Gain'+_P];
		BuidlPotentialP = summaryPotentialPercent['Build'+_P];
		DefendPotentialP = summaryPotentialPercent['Defend'+_P];
		ObservePotentialP = summaryPotentialPercent['Observe'+_P];
		MaintainPotentialP = summaryPotentialPercent['Maintain'+_P];
		BlankPotentialP = summaryPotentialPercent['Blank'+_P];
		
		//Adoption
		GainAdoptionP = summaryAdoptionPercent['Gain'+_A];
		BuidlAdoptionP = summaryAdoptionPercent['Build'+_A];
		DefendAdoptionP = summaryAdoptionPercent['Defend'+_A];
		ObserveAdoptionP = summaryAdoptionPercent['Observe'+_A];
		MaintainAdoptionP = summaryAdoptionPercent['Maintain'+_A];
		BlankAdoptionP = summaryAdoptionPercent['Blank'+_A];
		
		//@jescobar: Calculate the potential % for each segment and channel 
		var gainPP = (totalPotential == null || totalPotential== 0) ? 0 : accMul((GainPotentialP/totalPotential), 100);
		var buildPP = (totalPotential == null || totalPotential== 0) ? 0 : accMul((BuidlPotentialP/totalPotential),100);
		var defendPP = (totalPotential == null || totalPotential== 0) ? 0 : accMul((DefendPotentialP/totalPotential), 100);
		var observePP = (totalPotential == null || totalPotential== 0) ? 0 : accMul((ObservePotentialP/totalPotential), 100);
		var maintainPP = (totalPotential == null || totalPotential== 0) ? 0 : accMul((MaintainPotentialP/totalPotential),100);
		var blankPP = (totalPotential == null || totalPotential== 0) ? 0 : accMul((BlankPotentialP/totalPotential),100);
		
		//@jescobar: Calculate the adoption % for each segment and channel 
		var gainAP = (totalAdoption == null || totalAdoption== 0) ? 0 : accMul((GainAdoptionP/totalAdoption), 100);
		var buildAP = (totalAdoption == null || totalAdoption== 0) ? 0 : accMul((BuidlAdoptionP/totalAdoption),100);
		var defendAP = (totalAdoption == null || totalAdoption== 0) ? 0 : accMul((DefendAdoptionP/totalAdoption), 100);
		var observeAP = (totalAdoption == null || totalAdoption== 0) ? 0 : accMul((ObserveAdoptionP/totalAdoption), 100);
		var maintainAP = (totalAdoption == null || totalAdoption== 0) ? 0 : accMul((MaintainAdoptionP/totalAdoption),100);
		var blankAP = (totalAdoption == null || totalAdoption== 0) ? 0 : accMul((BlankAdoptionP/totalAdoption),100);
		
		//jescobar: Set data for Percent of potential by Segment
		$tr.find('td.GainclsPotential').text(Globalize.format(gainPP,'n1') +' %');
		$tr.find('td.BuildclsPotential').text(Globalize.format(buildPP,'n1') +' %');
		$tr.find('td.DefendclsPotential').text(Globalize.format(defendPP,'n1') +' %');
		$tr.find('td.ObserveclsPotential').text(Globalize.format(observePP,'n1') +' %');
		$tr.find('td.MaintainclsPotential').text(Globalize.format(maintainPP,'n1') +' %');
		$tr.find('td.BlankclsPotential').text(Globalize.format(blankPP,'n1') +' %');
		
		//jescobar: Set data for Percent of adoption by Segment
		$tr.find('td.GainclsAdoption').text(Globalize.format(gainAP,'n1') +' %');
		$tr.find('td.BuildclsAdoption').text(Globalize.format(buildAP,'n1') +' %');
		$tr.find('td.DefendclsAdoption').text(Globalize.format(defendAP,'n1') +' %');
		$tr.find('td.ObserveclsAdoption').text(Globalize.format(observeAP,'n1') +' %');
		$tr.find('td.MaintainclsAdoption').text(Globalize.format(maintainAP,'n1') +' %');
		$tr.find('td.BlankclsAdoption').text(Globalize.format(blankAP,'n1') +' %');
	
	});
}