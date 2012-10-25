/**
 * @author bendowski
 */
HAP.ACInPort = function(_5327){
    draw2d.InputPort.call(this, _5327);
}

HAP.ACInPort.prototype = new draw2d.InputPort;
HAP.ACInPort.prototype.type = 'inPort';
HAP.ACInPort.prototype.onDrop = function(port){
    if (port.getMaxFanOut && port.getMaxFanOut() <= port.getFanOut()) {
        return;
    }
    if (this.parentNode.id != port.parentNode.id) {
        var cmdCon = new draw2d.CommandConnect(this.parentNode.workflow, port, this);
        cmdCon.setConnection(new HAP.Connection());
        this.parentNode.workflow.getCommandStack().execute(cmdCon);
    }
}

HAP.ACInPort.prototype.onDragEnter = function(/*:draw2d.Port*/port){
    if (this.getConnections().size > 0) {
        return;
    }
    this.parentNode.workflow.connectionLine.setColor(new draw2d.Color(0, 150, 0));
    this.parentNode.workflow.connectionLine.setLineWidth(3);
    this.showCorona(true);
}


//HAP.ACInPort.prototype.isOver = function(/*:int*/iX,/*:int*/ iY){
//		var obj = Ext.getCmp(this.workflow.scrollArea.id);
//		var offX = obj.body.dom.scrollLeft;
//		var offY = obj.body.dom.scrollTop;
//    var offX = this.workflow.getScrollLeft();
//		var offY = this.workflow.getScrollTop();
//		var x = this.getAbsoluteX() - offX - this.coronaWidth - this.getWidth() / 2;
//   var y = this.getAbsoluteY() - offY - this.coronaWidth - this.getHeight() / 2;
//   var iX2 = x + this.width + (this.coronaWidth * 2) + this.getWidth() / 2;
//   var iY2 = y + this.height + (this.coronaWidth * 2) + this.getHeight() / 2;
//  return (iX >= x && iX <= iX2 && iY >= y && iY <= iY2);
//}

HAP.ACOutPort = function(_48ae){
    draw2d.OutputPort.call(this, _48ae);
}

HAP.ACOutPort.prototype = new draw2d.OutputPort;
HAP.ACOutPort.prototype.type = 'outPort';
HAP.ACOutPort.prototype.onDrop = function(port){
    if (port.getConnections().size > 0) {// if conns on inPort > 0 do nothing
        return;
    }
    if (this.getMaxFanOut() <= this.getFanOut()) {
        return;
    }
    if (this.parentNode.id != port.parentNode.id) {
        var cmdCon = new draw2d.CommandConnect(this.parentNode.workflow, this, port);
        cmdCon.setConnection(new HAP.Connection());
        this.parentNode.workflow.getCommandStack().execute(cmdCon);
    }
}
