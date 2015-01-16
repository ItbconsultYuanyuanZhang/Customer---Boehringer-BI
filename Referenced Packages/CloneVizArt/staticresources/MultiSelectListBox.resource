var NS4 = (navigator.appName == "Netscape" && parseInt(navigator.appVersion) < 5);

function addOption(theSel, theText, theValue) {
	var newOpt = new Option(theText, theValue);
	var selLength = theSel.length;
	theSel.options[selLength] = newOpt;
}

function deleteOption(theSel, theIndex) {
	var selLength = theSel.length;
	if (selLength > 0) {
		theSel.options[theIndex] = null;
	}
}

function moveOptions(theSelFrom, theSelTo) {

	var selLength = theSelFrom.length;
	var selectedText = new Array();
	var selectedValues = new Array();
	var selectedCount = 0;

	var i;

	for (i = selLength - 1; i >= 0; i--) {
		if (theSelFrom.options[i].selected) {
			selectedText[selectedCount] = theSelFrom.options[i].text;
			selectedValues[selectedCount] = theSelFrom.options[i].value;
			deleteOption(theSelFrom, i);
			selectedCount++;
		}
	}
	for (i = selectedCount - 1; i >= 0; i--) {
		addOption(theSelTo, selectedText[i], selectedValues[i]);
	}

	if (NS4)
		history.go(0);
}

function doMove(from, to) {
	var theSelFrom = document.getElementById(from);
	var theSelTo = document.getElementById(to);

	if (theSelFrom && theSelTo) {
		moveOptions(theSelFrom, theSelTo);
	}
}

function convertSelectToText(sel, textArea, separator) {
	var theSel = document.getElementById(sel);
	var theTextArea = document.getElementById(textArea);
	var i;
	var tmp = '';
	if (theSel && theTextArea && separator) {
		theTextArea.value = "";
		for (i = 0; i < theSel.length; i++) {
			tmp += (theSel.options[i].value + separator);
		}
		if (tmp.length > 0)
			theTextArea.value = tmp.substring(0, tmp.length - 1);
	}
}

function move(from, to, sel, textArea, separator) {
	if (from && to && sel && textArea && separator) {
		doMove(from, to);
		convertSelectToText(sel, textArea, separator);
	}
}

function moveOptionUp(sel, direction) {
	var theSel = document.getElementById(sel);
	if (theSel != null) {
		if (direction) {
			if (theSel.selectedIndex > 0) {
				for ( var i = 0; i < theSel.length; i++) {
					if (theSel[i].selected) {
						var oOption = theSel.options[i];
						var oPrevOption = theSel.options[i-- - 1];
						theSel.insertBefore(oOption, oPrevOption);
					}
				}
			}
		} else {
			for ( var i = theSel.length - 1; i >= 0; i--) {
				if (theSel[i].selected) {
					if (i == theSel.length - 1)
						return;
					var oOption = theSel.options[i];
					var oNextOption = theSel.options[i + 1];
					theSel.insertBefore(oNextOption, oOption);
				}
			}
		}
	}
}
