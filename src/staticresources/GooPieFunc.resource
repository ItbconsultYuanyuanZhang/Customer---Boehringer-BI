/**/

//
function getElCoordinate(dom) {
  var t = dom.offsetTop;
  var l = dom.offsetLeft;
  //dom=dom.offsetParent;
  while (dom.offsetParent) {
	dom=dom.offsetParent;
    t += dom.offsetTop;
    l += dom.offsetLeft;
  }; return {
    top: t,
    left: l
  };
}
//
function mousePosition(ev){
    if(ev.pageX || ev.pageY){
        return {x:ev.pageX, y:ev.pageY};
    }
    return {
        x:ev.clientX + document.documentElement.scrollLeft - document.body.clientLeft,
        y:ev.clientY + document.documentElement.scrollTop  - document.body.clientTop
    };
}