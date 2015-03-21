Ext.namespace('HAP');
Ext.QuickTips.init();
Ext.BLANK_IMAGE_URL = '/../static/js/ext/resources/images/default/s.gif'; // Ext 2.0
Ext.form.Field.prototype.msgTarget = 'side';
Ext.state.Manager.setProvider(new Ext.state.CookieProvider());

var log;
var currentConfig;
var cutNPaste;
var userRoles = {};

classFactory = function(className, arg0, arg1){
    var subClass = className.split('.')[1];
    if (!arg1) {
        return new HAP[subClass](arg0);
    }
    else {
        return new HAP[subClass](arg0, arg1);
    }
}

Ext.ux.isUndefined = function(a){
    return (typeof a == 'undefined');
}

Ext.ux.isNullOrUndefined = function(element){
    return (Ext.ux.isUndefined(element) || element == null);
}

Ext.ux.clone = function(myObj){
    if (Ext.ux.isNullOrUndefined(myObj)) 
        return myObj;
    var objectClone = new myObj.constructor();
    for (var property in myObj) 
        if (typeof myObj[property] == 'object') 
            objectClone[property] = Ext.ux.clone(myObj[property]);
        else 
            objectClone[property] = myObj[property];
    return objectClone;
};

apply = function(rcv, config){
    if (rcv && config && typeof config == 'object') {
        for (var p in config) {
            if (p == 'display') {
                rcv.display = apply({}, config.display);
                for (var dp in config.display) {
                    rcv.display[dp] = config.display[dp];
                }
            }
            else {
                rcv[p] = config[p];
            }
        }
    }
    return rcv;
};

var taskLogUpdate = {
    run: function(){
        logAutoUpdater();
    },
    interval: 30000
}

var taskSpeedLogUpdate = {
    run: function(){
        logAutoUpdater();
    },
    interval: 1000
}

var taskSpeedSchedulerUpdate = {
    run: function(){
        storeSchedules.reload({
            params: {
                filter: '* * * * *'
            }
        });
    },
    interval: 1000
}

// Prototype for checkboxes inside table

Ext.grid.CheckColumn = function(config){
    Ext.apply(this, config);
    if (!this.id) {
        this.id = Ext.id();
    }
    this.renderer = this.renderer.createDelegate(this);
    
};


Ext.grid.CheckColumn.prototype = {
    init: function(grid){
        this.grid = grid;
        this.grid.on('render', function(){
            var view = this.grid.getView();
            view.mainBody.on('mousedown', this.onMouseDown, this);
        }, this);
    },
    
    onMouseDown: function(e, t){
        if (t.className && t.className.indexOf('x-grid3-cc-' + this.id) != -1) {
            e.stopEvent();
            var index = this.grid.getView().findRowIndex(t);
            var record = this.grid.store.getAt(index);
            record.set(this.dataIndex, !record.data[this.dataIndex]);
            if (this.singleSelect) {
                var c = this.grid.store.getCount();
                for (var i = 0; i < c; i++) {
                    if (i != index) {
                        var record = this.grid.store.getAt(i);
                        if (record.data[this.dataIndex] == 1 || record.data[this.dataIndex] == true) {
                            record.set(this.dataIndex, false);
                        }
                    }
                }
            }
        }
    },
    
    renderer: function(v, p, record){
        p.css += ' x-grid3-check-col-td';
        return '<div class="x-grid3-check-col' + (v ? '-on' : '') +
        ' x-grid3-cc-' +
        this.id +
        '">&#160;</div>';
    }
};

// D&D with x and y coordinates at the source-object doesnt work correctly

Ext.override(Ext.dd.DragSource, {
    startDrag: function(x, y){
        var dragEl = Ext.get(this.getDragEl());
        var el = Ext.get(this.getEl());
        dragEl.applyStyles({
            width: el.dom.style.width,
            height: el.dom.style.height,
            backgroundImage: el.dom.style.backgroundImage
        });
        dragEl.update(el.dom.innerHTML);
    },
    autoOffset: function(x, y){
        this.setDelta(0, 0);
    }
});

// Connection & Connection Decorator

HAP.ConnectionDecorator = function(){
    draw2d.ArrowConnectionDecorator.call(this);
}

HAP.ConnectionDecorator.prototype = new draw2d.ArrowConnectionDecorator;
HAP.ConnectionDecorator.prototype.type = 'HAP.ConnectionDecorator';
HAP.ConnectionDecorator.prototype.paint = function(g){
    g.setColor(new draw2d.Color(0, 0, 0));
    g.fillPolygon([0, 13, 13, 0], [0, 4, -4, 0]);
    // draw the border
    g.setColor(this.color);
    g.setStroke(1);
    g.drawPolygon([0, 13, 13, 0], [0, 4, -4, 0]);
}

HAP.Connection = function(){
    draw2d.Connection.call(this);
    this.sourcePort = null;
    this.targetPort = null;
    this.lineSegments = new Array();
    this.setRouter(new draw2d.NullConnectionRouter());
    this.setTargetDecorator(new HAP.ConnectionDecorator());
    this.setLineWidth(1);
}

HAP.Connection.prototype = new draw2d.Connection();
HAP.Connection.prototype.getContextMenu = function(){
    var menu = new draw2d.Menu();
    var conn = this;
    menu.appendMenuItem(new draw2d.MenuItem('Delete', null, function(){
        conn.getWorkflow().removeFigure(conn);
    }));
    menu.appendMenuItem(new draw2d.MenuItem('Change Style...', null, function(){
        var currentRouter = conn.getRouter();
        if (currentRouter.type == 'draw2d.NullConnectionRouter') {
            conn.setRouter(new draw2d.ManhattanConnectionRouter());
        }
        else 
            if (currentRouter.type == 'draw2d.ManhattanConnectionRouter') {
                conn.setRouter(new draw2d.BezierConnectionRouter());
            }
            else 
                if (currentRouter.type == 'draw2d.BezierConnectionRouter') {
                    conn.setRouter(new draw2d.NullConnectionRouter());
                }
    }));
    return menu;
};

// Radio Groups in ExtJS 2.2 have no set/get, maybe in 3.x
Ext.override(Ext.form.RadioGroup, {
  getName: function() {
    return this.items.first().getName();
  },

  getValue: function() {
    var v;

    this.items.each(function(item) {
      v = item.getRawValue();
      return !item.getValue();
    });

    return v;
  },

  setValue: function(v) {
    this.items.each(function(item) {
      item.setValue(item.getRawValue() == v);
    });
  }
});