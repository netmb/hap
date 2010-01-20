/**
 * @author Ben
 */
//////////////////////////////////////////////////////////////////////////////////
// LCD Menu
//////////////////////////////////////////////////////////////////////////////////

HAP.LCDMenu = function(config){
    this.conf = {
        'height': 80,
        'width': 110,
        'inPorts': 0,
        'outPorts': 0,
        'name': '',
        'display' : {}
    };
    this.conf = apply(this.conf, config);
    draw2d.CompartmentFigure.call(this);
    this.outputPort = null;
    this.setLineWidth(0);
    this.setDimension(this.conf.width, this.conf.height);
    return this;
}

HAP.LCDMenu.prototype = new draw2d.CompartmentFigure();
HAP.LCDMenu.prototype.type = 'HAP.LCDMenu';
HAP.LCDMenu.prototype.setWorkflow = function(/*:Workflow*/workflow){
    draw2d.CompartmentFigure.prototype.setWorkflow.call(this, workflow);
    
    var inP = new HAP.LCDInPort();
    inP.setWorkflow(workflow);
    inP.setName('inPort1');
    this.addPort(inP, 0, 10);
    
    var inP2 = new HAP.LCDInPort();
    inP2.setWorkflow(workflow);
    inP2.setName('inPort2');
    this.addPort(inP2, this.getWidth(), this.getHeight() - 10);
    
    this.setText(this.conf.display.Label);
}

HAP.LCDMenu.prototype.onFigureDrop = function(/*:draw2d.Figure*/figure){
    if (figure instanceof HAP.LCDMenuItem) {
        figure.width = this.width - 2;
        figure.x = this.x + 1;
        figure.setWidth(this.width - 2);
        figure.setX(this.x + 1);
        draw2d.CompartmentFigure.prototype.onFigureDrop.call(this, figure);
    }
}

HAP.LCDMenu.prototype.createHTMLElement = function(){
    this.cornerWidth = 20;
    this.cornerHeight = 20;
    
    var item = draw2d.CompartmentFigure.prototype.createHTMLElement.call(this);
    item.style.position = 'absolute';
    item.style.left = this.x + 'px';
    item.style.top = this.y + 'px';
    item.style.height = this.conf.width + 'px';
    item.style.width = this.conf.height + 'px';
    item.style.margin = '0px';
    item.style.padding = '0px';
    item.style.outline = 'none';
    item.style.zIndex = '' + draw2d.Figure.ZOrderBaseIndex;
    
    this.top_left = document.createElement('div');
    this.top_left.style.background = 'url(/static/images/lcd/circle.png) no-repeat top left';
    this.top_left.style.position = 'absolute';
    this.top_left.style.width = this.cornerWidth + 'px';
    this.top_left.style.height = this.cornerHeight + 'px';
    this.top_left.style.left = '0px';
    this.top_left.style.top = '0px';
    this.top_left.style.fontSize = '2px';
    
    this.top_right = document.createElement('div');
    this.top_right.style.background = 'url(/static/images/lcd/circle.png) no-repeat top right';
    this.top_right.style.position = 'absolute';
    this.top_right.style.width = this.cornerWidth + 'px';
    this.top_right.style.height = this.cornerHeight + 'px';
    this.top_right.style.left = '0px';
    this.top_right.style.top = '0px';
    this.top_right.style.fontSize = '2px';
    
    this.bottom_left = document.createElement('div');
    this.bottom_left.style.background = 'url(/static/images/lcd/circle.png) no-repeat bottom left';
    this.bottom_left.style.position = 'absolute';
    this.bottom_left.style.width = this.cornerWidth + 'px';
    this.bottom_left.style.height = this.cornerHeight + 'px';
    this.bottom_left.style.left = '0px';
    this.bottom_left.style.top = '0px';
    this.bottom_left.style.fontSize = '2px';
    
    this.bottom_right = document.createElement('div');
    this.bottom_right.style.background = 'url(/static/images/lcd/circle.png) no-repeat bottom right';
    this.bottom_right.style.position = 'absolute';
    this.bottom_right.style.width = this.cornerWidth + 'px';
    this.bottom_right.style.height = this.cornerHeight + 'px';
    this.bottom_right.style.left = '0px';
    this.bottom_right.style.top = '0px';
    this.bottom_right.style.fontSize = '2px';
    
    this.header = document.createElement('div');
    this.header.style.position = 'absolute';
    this.header.style.left = this.cornerWidth + 'px';
    this.header.style.top = '0px';
    this.header.style.height = this.cornerHeight + 'px';
    this.header.style.background = 'url(/static/images/lcd/topBackground.png)';
    this.header.style.fontSize = '10px';
    this.header.style.textAlign = 'center';
    
    this.footer = document.createElement('div');
    this.footer.style.position = 'absolute';
    this.footer.style.left = this.cornerWidth + 'px';
    this.footer.style.top = '0px';
    this.footer.style.height = this.cornerHeight + 'px';
    this.footer.style.background = 'url(/static/images/lcd/bottomBackground.png)';
    
    this.textarea = document.createElement('div');
    this.textarea.style.position = 'absolute';
    this.textarea.style.left = '0px';
    this.textarea.style.top = this.cornerHeight + 'px';
    this.textarea.style.borderTop = '1px solid #666666';
    this.textarea.style.borderLeft = '1px solid #666666';
    this.textarea.style.borderRight = '1px solid #666666';
    
    this.disableTextSelection(this.header);
	this.disableTextSelection(this.textarea);
	
    item.appendChild(this.top_left);
    item.appendChild(this.header);
    item.appendChild(this.top_right);
    item.appendChild(this.textarea);
    item.appendChild(this.bottom_left);
    item.appendChild(this.footer);
    item.appendChild(this.bottom_right);
    
    return item;
}

HAP.LCDMenu.prototype.setDimension = function(w, h){
    draw2d.CompartmentFigure.prototype.setDimension.call(this, w, h);
    if (this.getPort('inPort2') != null) {
      this.getPort('inPort2').setPosition(w, h - 10);
    }
    if (this.top_left != null) {
        this.top_right.style.left = (this.width - this.cornerWidth) + 'px';
        this.bottom_right.style.left = (this.width - this.cornerWidth) + 'px';
        this.bottom_right.style.top = (this.height - this.cornerHeight) + 'px';
        this.bottom_left.style.top = (this.height - this.cornerHeight) + 'px';
        this.textarea.style.width = (this.width - 2) + 'px';
        this.textarea.style.height = (this.height - this.cornerHeight * 2) + 'px';
        this.header.style.width = (this.width - this.cornerWidth * 2) + 'px';
        this.footer.style.width = (this.width - this.cornerWidth * 2) + 'px';
        this.footer.style.top = (this.height - this.cornerHeight) + 'px';
    }
    for (var i = 0; i < this.children.getSize(); i++) {
        var child = this.children.get(i);
        child.width = this.width - 2;
        child.x = this.x + 1;
        child.setWidth(w - 2);
        child.setX(this.x + 1);
    }
};


HAP.LCDMenu.prototype.setText = function(text){
    this.header.innerHTML = text;
}

HAP.LCDMenu.prototype.getContextMenu = function(){
    var menu = new draw2d.Menu();
    var figure = this;
    menu.appendMenuItem(new draw2d.MenuItem('Delete', null, function(){
        figure.getWorkflow().removeFigure(figure);
    }));
    return menu;
}

//////////////////////////////////////////////////////////////////////////////////
// LCD Menu Item
//////////////////////////////////////////////////////////////////////////////////

HAP.LCDMenuItem = function(config){
    this.conf = {
        'height': 20,
        'width': 20,
        'inPorts': 0,
        'outPorts': 0,
        'name': '',
        'outPort1X': 0,
        'outPort1Y': 10,
        'display': {}
    };
    this.conf = apply(this.conf, config);
    draw2d.ImageFigure.call(this);
    this.setLineWidth(0);
    this.outputPort = null;
    this.setDimension(this.conf.width, this.conf.height);
    return this;
}

HAP.LCDMenuItem.prototype = new draw2d.ImageFigure;
HAP.LCDMenuItem.prototype.type = 'HAP.LCDMenuItem';
HAP.LCDMenuItem.prototype.setWorkflow = function(/*:Workflow*/workflow){
    draw2d.ImageFigure.prototype.setWorkflow.call(this, workflow);
    var outP = new HAP.LCDOutPort();
    outP.setWorkflow(workflow);
    outP.setName('outPort1');
    this.addPort(outP, this.conf.outPort1X, this.conf.outPort1Y);
    this.setText(this.conf.display['Label (14 max.)']);
    
}

HAP.LCDMenuItem.prototype.createHTMLElement = function(){
    this.item = draw2d.Node.prototype.createHTMLElement.call(this);
    this.item.style.width = this.conf.width + 'px';
    this.item.style.height = this.conf.height + 'px';
    this.item.style.margin = '0px';
    this.item.style.padding = '0px';
    this.item.style.backgroundImage = 'url(/static/images/lcd/menuItemBackground.png)';
    this.item.style.fontSize = '10px';
    this.item.style.textAlign = 'center';
    this.labelDiv = document.createElement('div');
    this.labelDiv.innerHTML = this.conf.display.Label;
    this.item.appendChild(this.labelDiv);
    this.disableTextSelection(this.labelDiv);
    return this.item;
}

HAP.LCDMenuItem.prototype.setText = function(text){
    this.labelDiv.innerHTML = text;
}

HAP.LCDMenuItem.prototype.setWidth = function(width){
    this.item.style.width = width;
    var port = this.getPort('outPort1');
    if (port != null && port.getX() != 0) {// flipped
      this.getPort('outPort1').setPosition(width, 10);
    }
    if (this.workflow != null && this.workflow.getCurrentSelection() == this) {
      this.workflow.showResizeHandles(this);
    }
}

HAP.LCDMenuItem.prototype.setX = function(x){
    this.item.style.left = x;
}

HAP.LCDMenuItem.prototype.setY = function(diff){
    this.y -= diff;
}

HAP.LCDMenuItem.prototype.getContextMenu = function(){
    var menu = new draw2d.Menu();
    var figure = this;
    menu.appendMenuItem(new draw2d.MenuItem('Delete', null, function(){
        if (figure.getParent()) {
          figure.getParent().removeChild(figure);
        }
        figure.getWorkflow().removeFigure(figure);
    }));
    menu.appendMenuItem(new draw2d.MenuItem('Flip Port', null, function(){
        var port = figure.getPort('outPort1');
        var x = port.getX();
        var y = port.getY();
        var figW = figure.getWidth();
        var figH = figure.getHeight();
        if (x == 0 && y == 10) {
          port.setPosition(figW, 10);
        }
        if (x == figW && y == 10) {
          port.setPosition(0, 10);
        }
    }));
    return menu;
}

//////////////////////////////////////////////////////////////////////////////////
// LCD Object
//////////////////////////////////////////////////////////////////////////////////

HAP.LCDObject = function(config){
    this.conf = {
        'height': 20,
        'width': 110,
        'inPorts': 0,
        'outPorts': 0,
        'name': '',
        'inPort1X': 0,
        'inPort1Y': 10,
        'display': {}
    };
    this.conf = apply(this.conf, config);
    draw2d.Node.call(this);
    this.outputPort = null;
    this.setDimension(this.conf.width, this.conf.height);
    return this;
}

HAP.LCDObject.prototype = new draw2d.Node;
HAP.LCDObject.prototype.type = 'HAP.LCDObject';
HAP.LCDObject.prototype.setWorkflow = function(/*:Workflow*/workflow){
    draw2d.Node.prototype.setWorkflow.call(this, workflow);
    if (workflow != null && this.outputPort == null) {
        var inP = new HAP.LCDInPort();
        inP.setWorkflow(workflow);
        inP.setName('inPort1');
        this.addPort(inP, this.conf.inPort1X, this.conf.inPort1Y);
        
        if (this.conf.display['Label (16 max.)'] != '') {
          this.setText(this.conf.display['Label (16 max.)']);
        }
        else {
          this.setText(this.conf.name);
        }
    }
}

HAP.LCDObject.prototype.setDimension = function(w, h){
    draw2d.Node.prototype.setDimension.call(this, w, 20);
    var port = this.getPort('inPort1');
    if (port != null && port.getX() != 0) {//flipped
      port.setPosition(w, 10);
    }
    if (this.centerDiv != null) {
        this.centerDiv.style.width = this.width - 20 + 'px';
        this.rightDiv.style.left = this.width - 10 + 'px';
    }
}

HAP.LCDObject.prototype.createHTMLElement = function(){
    var item = draw2d.Node.prototype.createHTMLElement.call(this);
    item.style.width = this.conf.width + 'px';
    item.style.height = this.conf.height + 'px';
    item.style.margin = '0px';
    item.style.padding = '0px';
    item.style.border = '0px';
    
    this.leftDiv = document.createElement('div');
    this.leftDiv.style.background = 'url(/static/images/lcd/lcdObject_left.png) no-repeat';
    this.leftDiv.style.position = 'absolute';
    this.leftDiv.style.top = 0 + 'px';
    this.leftDiv.style.left = 0 + 'px';
    this.leftDiv.style.width = 10 + 'px';
    this.leftDiv.style.height = 20 + 'px';
    this.leftDiv.style.fontSize = '2px';
    
    this.centerDiv = document.createElement('div');
    this.centerDiv.style.background = 'url(/static/images/lcd/lcdObject_center.png)';
    this.centerDiv.style.position = 'absolute';
    this.centerDiv.style.left = 10 + 'px';
    this.centerDiv.style.top = 0 + 'px';
    this.centerDiv.style.width = this.conf.width - 20 + 'px';
    this.centerDiv.style.height = 20 + 'px';
    this.centerDiv.style.fontSize = '10px';
    this.centerDiv.style.textAlign = 'center';
    
    this.rightDiv = document.createElement('div');
    this.rightDiv.style.background = 'url(/static/images/lcd/lcdObject_right.png) no-repeat top right';
    this.rightDiv.style.position = 'absolute';
    this.rightDiv.style.top = 0 + 'px';
    this.rightDiv.style.left = this.conf.width - 10 + 'px';
    this.rightDiv.style.width = 10 + 'px';
    this.rightDiv.style.height = 20 + 'px';
    this.rightDiv.style.fontSize = '2px';
    
    this.disableTextSelection(this.centerDiv);
		
    item.appendChild(this.leftDiv);
    item.appendChild(this.centerDiv);
    item.appendChild(this.rightDiv);
    
    return item;
}

HAP.LCDObject.prototype.setText = function(text){
    this.centerDiv.innerHTML = text;
}

HAP.LCDObject.prototype.getContextMenu = function(){
    var menu = new draw2d.Menu();
    var figure = this;
    menu.appendMenuItem(new draw2d.MenuItem('Delete', null, function(){
        figure.getWorkflow().removeFigure(figure);
    }));
    menu.appendMenuItem(new draw2d.MenuItem('Flip Port', null, function(){
        var port = figure.getPort('inPort1');
        var x = port.getX();
        var y = port.getY();
        var figW = figure.getWidth();
        var figH = figure.getHeight();
        if (x == 0 && y == 10) {
          port.setPosition(figW, 10);
        }
        if (x == figW && y == 10) {
          port.setPosition(0, 10);
        }
    }));
    return menu;
}

//////////////////////////////////////////////////////////////////////////////////
// LCD Object Images
//////////////////////////////////////////////////////////////////////////////////

HAP.LCDMenuImage = function(config){ // for object-tree view
    this.conf = config;
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.position = 'absolute';
    div.style.backgroundImage = 'url(/static/images/lcd/menu.png)';
    textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center';
    textDiv.style.width = this.conf.width - 15 + 'px';
    textDiv.innerHTML = this.conf.name;
    textDiv.style.paddingLeft = 8 + 'px';
    textDiv.style.paddingTop = 2 + 'px';
    div.appendChild(textDiv);
    return div;
}

HAP.LCDMenuItemImage = function(config){ // for object-tree view
    this.conf = config;
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.position = 'absolute';
    div.style.backgroundImage = 'url(/static/images/lcd/menuItem.png)';
    textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center';
    textDiv.style.width = this.conf.width - 15 + 'px';
    textDiv.innerHTML = this.conf.name;
    textDiv.style.paddingLeft = 8 + 'px';
    textDiv.style.paddingTop = 10 + 'px';
    div.appendChild(textDiv);
    return div;
}

HAP.LCDObjectImage = function(config){ // for object-tree view
    this.conf = config;
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.position = 'absolute';
    div.style.backgroundImage = 'url(/static/images/lcd/lcdObjectForTree.png)';

    textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center';
    textDiv.style.width = this.conf.width - 15 + 'px';
    textDiv.innerHTML = this.conf.name;
    textDiv.style.paddingLeft = 8 + 'px';
    textDiv.style.paddingTop = 2 + 'px';
    div.appendChild(textDiv);
    return div;
}
