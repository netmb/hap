/**
 * @author Ben
 */
HAP.GUIObject = function(data){
    this.toggleGrid = false;
    if (!data.display) {// coming in via drag & drop
        this.guiObject = classFactory(data.type, null, true);
        this.guiObject.id = 0;
    }
    else {
        this.guiObject = classFactory(data.type, data, true);
        this.guiObject.id = data.id;
    }
    draw2d.Figure.call(this);
    this.setDimension(this.guiObject.conf.display['width'], this.guiObject.conf.display['height']);
    this.setZIndex(this.guiObject.conf.display['z-Index']);
}

HAP.GUIObject.prototype = new draw2d.Figure;
HAP.GUIObject.prototype.type = 'GUIObject';
HAP.GUIObject.prototype.createHTMLElement = function(){
    var item = draw2d.Figure.prototype.createHTMLElement.call(this); 
    item.appendChild(this.guiObject.div);  
    this.d = document.createElement('div');
    this.d.style.position = 'absolute';
    this.d.style.left = '0px';
    this.d.style.top = '0px';
    this.d.style.zIndex = 100;
    item.appendChild(this.d);
    return item;
}

HAP.GUIObject.prototype.setDimension = function(w, h, callFromGrid){
    draw2d.Figure.prototype.setDimension.call(this, w, h);
    if (this.d) {
        this.d.style.width = w + 'px';
        this.d.style.height = h + 'px';
        this.guiObject.setWidth(w);
        this.guiObject.setHeight(h);
        if (!callFromGrid) {
          Ext.getCmp('guiPropertyGrid').setSource(this.guiObject.conf.display);
        }
    }
}

HAP.GUIObject.prototype.setPosition = function(x, y){
    draw2d.Figure.prototype.setPosition.call(this, x, y);
    this.guiObject.setX(this.getX(), true);
    this.guiObject.setY(this.getY(), true);
}

HAP.GUIObject.prototype.setZIndex = function(index){
    this.setZOrder(100 + index);
    this.d.style.zIndex = 100 + index;
}

HAP.GUIObject.prototype.onDrag = function(){
    draw2d.Figure.prototype.onDrag.call(this);
    this.guiObject.setX(this.getX(), true);
    this.guiObject.setY(this.getY(), true);
};

HAP.GUIObject.prototype.onDragend = function(){
    draw2d.Figure.prototype.onDragend.call(this);
    this.guiObject.setX(this.getX(), true);
    this.guiObject.setY(this.getY(), true);
    Ext.getCmp('guiPropertyGrid').setSource(this.guiObject.conf.display);
};

HAP.GUIObject.prototype.getContextMenu = function(){
    var menu = new draw2d.Menu();
    var figure = this;
    menu.appendMenuItem(new draw2d.MenuItem('Copy', null, function(){
        figure.guiObject.id = 0;
        figure.guiObject.conf.id = 0;
        cutNPaste = Ext.ux.clone(figure.guiObject.conf);
    }));
    menu.appendMenuItem(new draw2d.MenuItem('Paste', null, function(){
        var wf = figure.getWorkflow();
//        var offX = Ext.getCmp(wf.scrollArea.id).body.dom.scrollLeft;
//        var offY = Ext.getCmp(wf.scrollArea.id).body.dom.scrollTop;
        var offX = wf.getScrollLeft();
				var offY = wf.getScrollTop();
        var fig = new HAP.GUIObject(cutNPaste);
        wf.addFigure(fig, wf.currentMouseX + offX, wf.currentMouseY + offY);
    }));
    menu.appendMenuItem(new draw2d.MenuItem('Delete', null, function(){
        figure.getWorkflow().removeFigure(figure);
    }));
    menu.appendMenuItem(new draw2d.MenuItem('Toggle Grid', null, function(){
        var wf = figure.getWorkflow();
        if (wf.snap) {
          wf.snap = false;
        }
        else {
          wf.snap = true;
        }
        wf.setSnapToGrid(wf.snap);
    }));
    return menu;
}

HAP.GUIObject.prototype.setGUIObjectConfig = function(){
    this.guiObject.setConfig(this.guiObject.conf, true);
    if (this.guiObject.conf.display['Value'] != null) {
      this.guiObject.setValue(this.guiObject.conf.display['Value']);
    }
    this.setPosition(this.guiObject.conf.display['x'], this.guiObject.conf.display['y']);
    this.setDimension(this.guiObject.conf.display['width'], this.guiObject.conf.display['height'], true);
    this.setZIndex(this.guiObject.conf.display['z-Index']);
}


draw2d.Workflow.prototype.showMenu = function(/*:draw2d.Menu*/menu,/*:int*/ xPos,/*:int*/ yPos){
    if (this.menu != null) {
        this.html.removeChild(this.menu.getHTMLElement());
        this.menu.setWorkflow();
    }
    this.menu = menu;
    if (this.menu != null) {
        this.menu.setWorkflow(this);
				this.menu.setPosition(xPos, yPos);
        this.html.appendChild(this.menu.getHTMLElement());
        this.menu.paint();
    }
}
