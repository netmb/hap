/**
 * @author Ben
 */
HAP.LCDInPort = function(_5327){
    draw2d.InputPort.call(this, _5327);
}

HAP.LCDInPort.prototype = new draw2d.InputPort;
HAP.LCDInPort.prototype.type = 'HAP.LCDInPort';
HAP.LCDInPort.prototype.onDrop = function(port){
    if (port.getMaxFanOut && port.getMaxFanOut() <= port.getFanOut()) {
        return;
    }
    if (this.parentNode.id != port.parentNode.id) {
        var cmdCon = new draw2d.CommandConnect(this.parentNode.workflow, port, this);
        cmdCon.setConnection(new HAP.Connection());
        this.parentNode.workflow.getCommandStack().execute(cmdCon);
    }
}

//HAP.LCDInPort.prototype.isOver = function(/*:int*/iX,/*:int*/ iY){
//    var obj = Ext.getCmp(this.workflow.scrollArea.id);
//    var offX = obj.body.dom.scrollLeft;
//    var offY = obj.body.dom.scrollTop;
//    var x = this.getAbsoluteX() - offX - this.coronaWidth - this.getWidth() / 2;
//    var y = this.getAbsoluteY() - offY - this.coronaWidth - this.getHeight() / 2;
//    var iX2 = x + this.width + (this.coronaWidth * 2) + this.getWidth() / 2;
//    var iY2 = y + this.height + (this.coronaWidth * 2) + this.getHeight() / 2;
//    return (iX >= x && iX <= iX2 && iY >= y && iY <= iY2);
//}

HAP.LCDOutPort = function(_48ae){
    draw2d.OutputPort.call(this, _48ae);
}

HAP.LCDOutPort.prototype = new draw2d.OutputPort;
HAP.LCDOutPort.prototype.type = 'HAP.LCDOutPort';
HAP.LCDOutPort.prototype.onDrop = function(port){
    if (this.getMaxFanOut() <= this.getFanOut()) {
        return;
    }
    if (this.parentNode.id != port.parentNode.id) {
        var cmdCon = new draw2d.CommandConnect(this.parentNode.workflow, this, port);
        cmdCon.setConnection(new HAP.Connection());
        this.parentNode.workflow.getCommandStack().execute(cmdCon);
    }
}

HAP.LCDOutPort.prototype.onDragstart = function(x, y){
    if (this.getConnections().size > 0) {
      return;
    }
    if (!this.canDrag) {
      return false;
    }
    this.command = new draw2d.CommandMove(this, this.x, this.y);
    return true;
}
