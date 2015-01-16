function register_progressBar(channelId, Plannedin, isRemove){
	if(isRemove){
		switch(channelId){
			case '1': 
				$( "#channel1progressbar" ).progressbar({ value: '' }).find('div').css({'background': '#f2b01e'});
				$( "#channel1barText" ).text('');
				break;
			case '2':
				$( "#channel2progressbar" ).progressbar({ value: '' }).find('div').css({'background': '#f2b01e'});
				$( "#channel2barText" ).text('');
				break;
			default:
				$( "#channel1progressbar" ).progressbar({ value: '' }).find('div').css({'background': '#f2b01e'});
				$( "#channel1barText" ).text('');
				$( "#channel2progressbar" ).progressbar({ value: '' }).find('div').css({'background': '#f2b01e'});
				$( "#channel2barText" ).text('');
				break;
		
		}
		return;
	}
	
	var channel_1 = $('#channel1DivContent ul').find(('#'+channelId))[0];
	var channel_2 = $('#channel2DivContent ul').find(('#'+channelId))[0];
	if(isUndefinedTag(channel_1)){
		$( "#channel1progressbar" ).progressbar({ value: Plannedin }).find('div').css({'background': '#f2b01e'});		
		$( "#channel1barText" ).text(Globalize.format(Plannedin, 'n1')+'%');
	}
	if(isUndefinedTag(channel_2)){
		$( "#channel2progressbar" ).progressbar({ value: Plannedin }).find('div').css({'background': '#f2b01e'});
		$( "#channel2barText" ).text(Globalize.format(Plannedin, 'n1')+'%');
	}
}

function register_event(){	//all event
	$('body').off('click').on('click',e_click_body);
	$('#channelDivId .draggable').off('mouseenter mouseleave').on('mouseleave mouseenter', e_over_draggable);
//	$('#matrixData').off('mouseenter mouseleave').on('mouseleave mouseenter', registerMatrixDataMouserEvent);
	$('#channelDropDivId div.overMenu').off('mouseenter mouseleave click').on('mouseenter mouseleave click', e_over_click_overMenu);
	$('#chartDivId').off('mouseenter mouseleave click').on('mouseenter mouseleave click', e_over_click_chart);
	$('#matrixTotalClsId').off('mouseenter mouseleave').on('mouseenter mouseleave', e_over_overTable);
	$('#tipsnoClickId .tipsTotalDivCls').off('click').on('click', e_click_tipsTotal_avg);
	
	$('#overTableHideId').off('mouseenter mouseleave click').on('mouseenter mouseleave click', e_over_click_overTable);
	$('#channelDropDivId').off('mouseenter mouseleave').on('mouseenter mouseleave', e_over_channelDropDivId);
	$('#channelButtonTrId input[type="button"]').off('click mousedown').on('click mousedown', e_click_channelButton);
	//$('#channelInputTrId input[type="text"]').off('focus change').on('focus change',  e_focus_change_channelText);
	register_progressBar('all', null, true);
	registerDrop_event();
	
}
function e_over_click_chart(e){
	var $this = $(this), this_h = $this.height(), $chart = $('#barChartId'), 
		_offset = $this.offset(), _w = $chart.width(), $checkBox = $('#activeChart');

	switch(e.type){
		case 'mouseenter':
				$this.addClass('pgover');
				if(!$chart.hasClass('incheckbox')){
					$chart.css({'opacity': 0.1, 'left': _offset.left, 'top':(_offset.top+this_h)})
					.stop().animate({left: (_offset.left-_w), opacity: 1}, 900, function(){
						var $tmp = $(this), tmp_offset = $tmp.addClass('incheckbox').offset();
						if(tmp_offset.left < 10){
							$tmp.animate({left:10}, 900, function(){});
						}
					});
				}
			break;
		case 'click':
			/*
				if($checkBox.attr('checked')){
					$checkBox.attr('checked', false);
				}else{
					$checkBox.attr('checked', true);
				}
				*/
			/*
				var $chart = $('#barChartId'), _top = '', _hide = 'hide';
				if($chart.hasClass('hide')){
					_top = -1000;
					$chart.removeClass(_hide);
					_hide = 'show';
				}
				$chart.css({'top':_top}).addClass(_hide);
			*/
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
	
	if(el){
		thisId = 'channelInput1';
	}
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
	setSelectedChannelId();
	$('#loading-curtain-div').fadeOut();
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
				channelId = $.trim($('#channel1DivContent li').attr('id'));
				
				if(!channelFlg){
					channelId = $.trim($('#channel2DivContent li').attr('id'));
					_channelType = '2';
				}
				change_channelBudget(_channelType, channelId, null, null);
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
function killEnter(evt,el){console.log(evt);
	if(evt.keyCode == 13){
		if(evt.preventDefault)
		evt.preventDefault();
		else
		event.returnValue = false;
		if(evt.stopPropagation)
		evt.stopPropagation();
		else
		event.cancelBubble = true;
		//$(el).blur();
	}
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
	var $this = $(el),qty = $this.prev().val(),posIdx = $this.parent().prev().length;
	
	if(!/^\d+$/.test(qty)){
		alert('Invalid number. Please check.');
		return;
	}
	var elem;
	if(parseInt(qty,10) >= 0 && confirm("Do you want to apply standard values to all filter combinations? This will overwrite all previously assigned values to the selected cells!")){
		
		$('#matrixTips').children('tbody').children().each(function(idx){
			if(idx > 0){
				elem = $(this).children().eq(posIdx).children('input');
				elem.val(qty);
				e_focus_change_channelText(elem.get(0));
			}
		});
	}
}
function tipsShowOption($lis){
	var displayCls = 'displayCls', 
		selected_len = $('#matrixData li.ui-selected').length;
	
	//Begin: added by Fuqi Tan 2013-06-18
	var $select = $('#quantityFilterDivId').children('select');
	var str = ['<tr><td class="w1">Apply to all filter combination</td><td class="w3"><input type="text" value="" onkeypress="killEnter(event,this);" onkeydown="killEnter(event,this);"/>',
		'<button onclick="applyAllQty(event,this);">Apply</button></td><td class="w3"><input type="text" value="" onkeypress="killEnter(event,this);" onkeydown="killEnter(event,this);"/><button onclick="applyAllQty(event,this);">Apply</button></td></tr>'],$option;
	var initVal;
	if($lis.length != 1) initVal = '';
	else{
		initVal = [];
		var cls = $lis.attr('class');
		var col = /column_\d/.exec(cls);
		var row = /row_\d/.exec(cls);
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
		$select.children().each(function(){
			$option = $(this);
			if(isNaN(parseInt( $option.val(),10)))
			return true;
			str.push('<tr><td class="w1">',$option.text(),'</td><td class="w2"><button onclick="addQty(event,this,-1);">-</button><input type="text" class="',
			$option.val(),'" value="',initVal==''?'':initVal[0][$option.val()]['qty'],'" onchange="e_focus_change_channelText(this);" onkeypress="killEnter(event,this);"/><button onclick="addQty(event,this,1);">+</button></td><td class="w2"><button onclick="addQty(event,this,-1);">-</button><input type="text" class="',
			$option.val(),'" value="',initVal==''?'':initVal.length > 1? initVal[1][$option.val()]['qty']:'','" onchange="e_focus_change_channelText(this);" onkeypress="killEnter(event,this);"/><button onclick="addQty(event,this,1);">+</button></td></tr>');
		});
		$('#matrixTips').children('tbody').empty().append(str.join(''));
		//$('#matrixTips').children('tfoot').hide();//can be removed
	}else{
		$select.children().each(function(){
			$option = $(this);
			if($select.val() == $option.val()){
				str.push('<tr><td class="w1">',$option.text(),'</td><td class="w2"><button onclick="addQty(event,this,-1);">-</button><input type="text" class="',
				$option.val(),'" value="',initVal==''?'':initVal[0][$option.val()]['qty'],'" onchange="e_focus_change_channelText(this);" onkeypress="killEnter(event,this);"/><button onclick="addQty(event,this,1);">+</button></td><td class="w2"><button onclick="addQty(event,this,-1);">-</button><input type="text" class="',
				$option.val(),'" value="',initVal==''?'':initVal.length > 1? initVal[1][$option.val()]['qty']:'','" onchange="e_focus_change_channelText(this);" onkeypress="killEnter(event,this);"/><button onclick="addQty(event,this,1);">+</button></td></tr>');
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
			$colorBody.addClass('inActive').css({'left':li_left, 'display':'', 'opacity': 0.1})
				.animate({left: ol_width+ol_left, opacity: 1}, 600, function(){
				});
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
	var matrixIds = '#matrixData li.dataCell', delId = 'div:first';
	if(_channelType == '2'){
		delId = 'div:last';
	}
	$(matrixIds).each(function(){
		$(this).find(delId).removeAttr('id').text('');
	});
	register_progressBar(_channelType, '', true);
}
function change_channelBudget(_channelType, channelId, tips_budget, selected_cls, qtyType){
	
	var list_rows = [], list_column = [];
	
	for(var i=0, max=JSON_CHANNELS.length; i<max; i++){
		var o = JSON_CHANNELS[i], clsName = '_cls', divType='div:first', matrixDataId = '#matrixData li.',
			row_cls = ('row_' + o.cellRow), column_cls = ('column_'+ o.cellColumn);
	
		if(o.channelId == channelId){
			clsName = o.cellRow + '_' + o.cellColumn + clsName;
			if(_channelType == '2'){divType = 'div:last';}

			matrixDataId = (matrixDataId + clsName);
			if(selected_cls != null && tips_budget != null){
				matrixDataId = matrixDataId + '.'+selected_cls;
			}
			
			$(matrixDataId)
			.animate({opacity: 0.1}, 600)
			.animate({opacity: 1}, 600, function(){
				$(this).removeAttr('style').find('div').removeAttr('style');
			})
			.find(divType).css({'display':'none'})
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
					//**** here need consider if/how show qty when user change a qty **** //by fuqi
					var showAllHtml = '';
					showAllHtml += '<div>' + (o.customers == 'null' ? '0' : o.customers) + '</div>';
					showAllHtml += '<div>' + (o.intimacy == 'null' ? '0' : o.intimacy) + '</div>';
					showAllHtml += '<div>' + (o.potential == 'null' ? '0' : o.potential) + '</div>';
					showAllHtml += '<div class="channelBudgetDiv">' + (o.channelBudget == 'null' ? '0' : o.channelBudget) + '</div>';
					$(this).attr({'id':o.channelId}).html(showAllHtml);
				}else{
					$(this).attr({'id':o.channelId}).text( (o.map_index_cmcdo[filterSelectIndex].qty == null ? '0' : o.map_index_cmcdo[filterSelectIndex].qty) );
					//console.log('index:'+i+' row:'+o.cellRow+' Col:'+o.cellColumn+' qty:'+o.map_index_cmcdo[filterSelectIndex].qty);
					
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

	
	/*
	var dtd = $.Deferred(),  d = waitDeferred(dtd, list_rows, _channelType);
	
	$.when(d)
		.done(function(){
			
			list_rows = [];
			var c = waitDeferred(dtd, list_column, _channelType);
			$.when(c).done(function(){
				list_column = [];
				BudgetChannelTotal(channelId);
			}).fail(function(){ if(window.console)console.log('fail list_column'); });
			
		}).fail(function(){ if(window.console)console.log('fail list_rows'); });

	*/
}

function BudgetChannelTotal(channelId){	//Budget Overview by Channel Table total
	var matrixDataId = '#matrixData #'+channelId,
		PlannedTotal = 0, GainToal = 0, BuildTotal = 0, DefendTotal = 0, ObserveTotal = 0, MaintainTotal = 0;

	$(matrixDataId).each(function(){
		var $this = $(this), t=1, $parent = $this.parent(), v = $.trim($this.text());
		if(filterShowAll){
			v = $.trim($this.find('.channelBudgetDiv').text());
		}
		
		if($parent.hasClass('Gain')){
			GainToal = accAdd(v, GainToal);
		}else if($parent.hasClass('Build')){
			BuildTotal = accAdd(v, BuildTotal);
		}else if($parent.hasClass('Defend')){
			DefendTotal = accAdd(v, DefendTotal);
		}else if($parent.hasClass('Observe')){
			ObserveTotal = accAdd(v, ObserveTotal);
		}else if($parent.hasClass('Maintain')){
			MaintainTotal = accAdd(v, MaintainTotal);
		}
		
		PlannedTotal = accAdd(v, PlannedTotal);
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
	
	register_progressBar(channelId, Plannedin, false);
}
function formatCurrentNumber(nums){
	return (Globalize.format(nums, 'n0'));
}
function matrixTotalTable(isFist){
	
	if(!isFist){
		$('#matrixTabTotal .dataCelltd').each(function(indx){

			var $this = $(this), this_val = $.trim($this.text());
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
	_cMap.put('Maintaincls', 0);
	
	list_cls = _cMap.keys();
	
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

	for(var i=0; i<list_cls.length; i++){
		var clsName = list_cls[i], find_th = ('#matrixTabTotal tfoot tr th.' + clsName), th_v = _cMap.get(clsName);
		$(find_th).text(formatCurrentNumber(th_v));
	}
	list_cls = [];
	
	var totals = _cMap.get('Totalcls'), planned = _cMap.get('Plannedcls'), plannedIn = 0;
	totals = parseInt($('#matrixTabTotal tfoot tr th input[name="totalUnits"]').val());
	//commented by Peng Zhu 2013-05-27 for avoiding Infinity result when totals is zero
	//if(planned != 0){
	//	plannedIn = accMul( (planned/totals), 100 );
	//}

	//added by Peng Zhu 2013-05-27 for avoiding Infinity result when totals is zero
	if(totals && totals != 0 && planned != 0){
		plannedIn = accMul( (planned/totals), 100 );
	}
	else{
		plannedIn = 0;
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
		BudgetChannelTotal(channelId);
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

	if(lens == 1){
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
			cellcls = '#matrixData li.' + cell, 
			celltotal = '#matrixData li.' + cell + '_total', 
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
	
	var list_data = [], t = 0, labee_config = labelConfig();
	$('#matrixTabTotal tfoot th').each(function(indx){
        var $this = $(this), this_val = $.trim($this.text());
        this_val = this_val != '' ? Globalize.parseInt(this_val) : 0;
        if(indx >3){
            list_data.push(this_val);
        	t += this_val;
        }
	});
	
	//Begin: added by Peng Zhu 2013-05-21 for using percent
	var totalAU = $.trim($('#matrixTabTotal tfoot th.Plannedcls').text()) != '' ? Globalize.parseInt($.trim($('#matrixTabTotal tfoot th.Plannedcls').text())) : 0;
	var list_data_percent = [];
	var totalPercent = 0;
	var indexPercent = 0;
	if(typeof(totalAU) != 'undefined' && totalAU > 0){
		for(var i=0; i< list_data.length; i++){
			var temp_v = (parseFloat(list_data[i])/totalAU*100).toFixed(1);
			totalPercent += parseFloat(temp_v);
			if(temp_v > 0){
				indexPercent = i;
			}
			list_data_percent.push(temp_v);
		}
	}
	else{
		list_data_percent = [0, 0, 0, 0, 0];
	}
	var totalPercent_v = parseFloat(totalPercent).toFixed(1);
	
	if(parseInt(totalPercent_v) != 100){
		var errorMargin = (100 - parseFloat(totalPercent).toFixed(1)).toFixed(1);
		list_data_percent[indexPercent] = parseFloat(parseFloat(list_data_percent[indexPercent]) + parseFloat(errorMargin)).toFixed(1);
	}
	
	//this is used to let the barchart show the max yaxis in 100%
    list_data_percent.push(90);
	
	//End: added by Peng Zhu 2013-05-21
	
	$('#barChartId').html('');
	
	var totals = $.trim($('#matrixTabTotal tfoot th.Totalcls').text()) != '' ? Globalize.parseInt($.trim($('#matrixTabTotal tfoot th.Totalcls').text())) : 0;
    totals = parseInt(totals - t);
    list_data.push(totals);

    var ticks = [
    	labee_config.a, labee_config.b, labee_config.c, labee_config.d, 
    	labee_config.e
	],

 	series = [
 		{label: labee_config.a}, 
 		{label: labee_config.b}, 
 		{label: labee_config.c}, 
 		{label: labee_config.d},
		{label: labee_config.e}
 	],

 	seriesColors = [
 		'#F8B818','#FCFC04','#20A020','#FC0404','#2060A0'
 	];
 	try{
 		//var plot1 = $.jqplot('barChartId', [list_data], {
 		
 		var plot1 = $.jqplot('barChartId', [list_data_percent], {
 			
 			seriesDefaults:{
 				renderer:$.jqplot.BarRenderer,
 				rendererOptions: {
 					barWidth: 20,
 					fillToZero: true,
 					varyBarColor: true
 				},
 				pointLabels: { show: true }
 			},
 			animate: true,//!$.jqplot.use_excanvas,
 			cursor: { show: false, showTooltip:false },
 			seriesColors:seriesColors,
 			series: series,
 			axes: {
 				xaxis: {
 					renderer: $.jqplot.CategoryAxisRenderer,
 					ticks: ticks,
 					tickRenderer:$.jqplot.CanvasAxisTickRenderer,
 					tickOptions: {
 						angle: 90
 					}
 				},
 				yaxis: {
 					max:100,
 					padMin: 0,
 					tickOptions:{
 						//     prefix: '$'
 						formatString: '%d%'
 						//suffix: '%'
 					}
 				},
 				showMinorTicks:true//,
 				//yaxis: { padMin: 0 }
 			},
 			highlighter: {
 				show: true, 
 				showLabel: true, 
 				showTooltip:false,
 				tooltipAxes: 'xy',
 				useAxesFormatters:true,
 				//	formatString: '$s, ',
 				sizeAdjust: 0 , 
 				tooltipLocation : 'ne'
 			}
 		});
 		
 	}catch(e){
 		
 	}
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