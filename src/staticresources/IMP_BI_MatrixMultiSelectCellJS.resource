var slt = true;
$(function() {
	$("#matrixData" ).selectable({filter:'li',cancel:'.tdhd',stop:function(event,ui){
    	setPopData();
    	var $colorBody = $('#colorbody');
		if($colorBody.is(":hidden")){
	    	var w = $(window).width();
	    	var pLeft;
	    	if(!isNaN(w) && w<1000 && w >500){
	    		//commented by Peng Zhu 2013-05-14
	    		//$('#colorbody').css('left',w-230);
	    		
	    		//added by Peng Zhu 2013-05-14
	    		pLeft = w - 230;
	    	}
	    	//commented by Peng Zhu 2013-05-14
	    	//$('#colorbody').show();
	    	
	    	
	    	var ol_width = $("#matrixData").parent().outerWidth(true), 
				ol_left = $("#matrixData").parent().offset().left,
	    		li_left = $("#matrixData").find('li.ui-selected').last().offset().left;
	    		
	    	if(pLeft && (li_left < pLeft)){
	    		$colorBody.css({'left':li_left, 'display':'', 'opacity': 0.1,'position':'absolute'})
					.animate({left: pLeft, opacity: 1}, 600, function(){
					});
	    	}else{
		    	$colorBody.css({'left':li_left, 'display':'', 'opacity': 0.1,'position':'absolute'}).animate({left:ol_width+ol_left, opacity: 1}, 600, function(){});
	    	}
		}
	}});
	$('body').live('click',function(evt){
		var elem = evt.target,elemId,i,j;
		elemId = elem.id;
		if(elemId && (elemId=='ckaverage'||elemId=='cktotal')){
			notInArea = false;
		}else{	
			if(elem.nodeName == 'LI') j = 2;
			else j = 10;
			var notInArea = true;
			for(i=0;i<j;i++){
				elemId = elem.id;
				if(elemId && (elemId=='matrixData'||elemId=='colors')){
					notInArea = false;
					break;
				}else if(elem.parentNode){
					elem = elem.parentNode;
				}
			}
		}
		j = 10;
		elem = evt.target;
		elemId = elem.id;
		for(i=0;i<j;i++){
			elemId = elem.id;
			console.log(elemId);
			if(elemId && (elemId=='individualFilter')){
				notInArea = false;
				break;
			}else if(elem.parentNode){
				elem = elem.parentNode;
			}
		}
		console.log(notInArea);
		console.log($("#individualFilter").is( ":visible"));
		if ($("#individualFilter").is( ":visible")) {
			notInArea = false;
		}
		
		if(notInArea){
			//$('#colorbody').hide();
			$('#colorbody').fadeOut();
			$('#matrixData').find('.ui-selected').removeClass('ui-selected');
		}
	});
});

/**
 * Showing legends on Matrix determine segments
 * @author jescobar 
 * @return
 */
$(function() {
	
	$('#chkPotential').change(function() {
		if($(this).is(':checked')) {
				$('#matrixData li.ui-selectee span.sp2').css('display','');
	    } else {
	    	$('#matrixData li.ui-selectee span.sp2').css('display','none');
	    }
	});
	$('#chkAdoption').change(function() {
		if($(this).is(':checked')) {
				$('#matrixData li.ui-selectee span.sp3').css('display','');
	    } else {
	    	$('#matrixData li.ui-selectee span.sp3').css('display','none');
	    }
	});
	$('#cMShare').change(function() {
		if($(this).is(':checked')) {
				$('#matrixData li.ui-selectee span.sp4').css('display','');
	    } else {
	    	$('#matrixData li.ui-selectee span.sp4').css('display','none');
	    }
	});
	$('#numOfDoc').change(function() {
		if($(this).is(':checked')) {
				$('#matrixData li.ui-selectee span.sp5').css('display','');
	    } else {
	    	$('#matrixData li.ui-selectee span.sp5').css('display','none');
	    }
	});
});

function setPopData(){
	var isTotal,
		count = 0,
		datas = {'phy':0,'mrx':0,'prx':0,'dd':0},
		$li,
		dgts = 0,
		spdata;
	if($('#cktotal').hasClass('isTotalOn')){
		isTotal = 1;
	}else if($('#ckaverage').hasClass('isAverageOn')){
		isTotal = 2;
		dgts = 1;
	}else{
		//no data should show
		isTotal = 3;  		
	}
	
	if(isTotal != 3){
		var reportUrl = '';
		
    	$('#matrixData').children('.ui-selected').not('.tdhd').each(function(idx){
    		$li = $(this);
    		
    		if($li.attr('name') && $.trim($li.attr('name')) != ''){
    			reportUrl += $li.attr('name').substring(0, 15) + ',';
    		}
    		
			datas.phy += $li.data('da');
			datas.mrx += $li.data('db');
			datas.prx += $li.data('dc');
			
			if(count ==0)
			datas.dd += $li.data('dd');
    		count ++;    		
    	});
		
    	if(reportUrl != null && $.trim(reportUrl) != ''){
    		reportUrl = $.trim(reportUrl);
    		reportUrl = reportUrl.substring(0, reportUrl.length - 1);
	    	reportUrl = matrixDrillDownReportUrl + '?pv0=' + reportUrl;
    	}
    	else{
    		reportUrl = matrixDrillDownReportUrl;
    	}
    	
    	if(isTotal == 2){
    		if(datas.phy != 0){
	    		datas.mrx = Math.round(100*datas.mrx/datas.phy)/100;
	    		datas.prx = Math.round(100*datas.prx/datas.phy)/100;
    		}else{
    			datas.mrx = datas.prx = 0;
    		}
    	}
    	$('#popdata').show();
    	
    	$("a[name='drillDownReport']").attr('href', reportUrl);
    	
    	$('#pyd').text(roundNumToKM(datas.phy,thelocale,9999,0));
    	$('#mrx').text(roundNumToKM(datas.mrx,thelocale,9999,dgts));
    	$('#pdr').text(roundNumToKM(datas.prx,thelocale,9999,dgts));
    	if(count == 1 && !isNaN(datas.dd)){
    		$('#tms').text(FormatNums(datas.dd,thelocale,false,2)+' %');
    	}else if(!isNaN(datas.mrx) && datas.mrx != 0){
    		$('#tms').text(FormatNums(100*datas.prx/datas.mrx,thelocale,false,2)+' %');
    	}else{
    		$('#tms').text(FormatNums(0,thelocale,false,2)+' %');
    	}
	}else{
		$('#popdata').hide();
	}
}
function setColor(el){
	var cls = el.className,
		$this;
	$('#matrixData').children('li.ui-selected').not('.tdhd').each(function(){
		$this = $(this);
		$this.removeClass('Gain').removeClass('Build').removeClass('Defend').removeClass('Observe').removeClass('Maintain').removeClass('Blank').addClass(cls).removeClass('ui-selected');
		$this.children('input').eq(0).val(cls);
	});
	//$('#colorbody').hide();
	//$('#colorbody').fadeOut();
	calKpi();
}	
function setStatistic(t){
  	var $elem;
  	if(t==1){
  		$elem = $('#cktotal');
  		$elem.toggleClass('isTotalOn');
  		if($elem.hasClass('isTotalOn')){
  			$('#ckaverage').removeClass('isAverageOn');
  		}
  	}else if(t==2){
  		$elem = $('#ckaverage');
  		$elem.toggleClass('isAverageOn');
  		if($elem.hasClass('isAverageOn')){
  			$('#cktotal').removeClass('isTotalOn');
  		}
  	}
  	setPopData();
  	calLi(true);  	
}
var thelocale='other';
if(/^de/.test(UserContext.locale)){
	thelocale = 'de';
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