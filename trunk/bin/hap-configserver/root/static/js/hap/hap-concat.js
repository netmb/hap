/**
 * @author Ben
 */
var LoadingMask = function(){
    return {
        init: function(){
            var loading = Ext.get('loading');
            var mask = Ext.get('loading-mask');
            mask.setOpacity(0.8);
            mask.shift({
                xy: loading.getXY(),
                width: loading.getWidth(),
                height: loading.getHeight(),
                remove: true,
                duration: 2,
                opacity: 0.3,
                easing: 'easeOut',
                callback: function(){
                    loading.fadeOut({
                        duration: 0.2,
                        remove: true
                    });
                }
            });
        }
    }
}
();

Ext.onReady(LoadingMask.init, LoadingMask, true)
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
});HAP.GridImageTrigger = function(config){
    this.conf = {
        redimWrapper: true
    };
    Ext.apply(this.conf, config);
    
    HAP.GridImageTrigger.superclass.constructor.call(this);
}

Ext.extend(HAP.GridImageTrigger, Ext.form.TriggerField, {
    onTriggerClick: function(event){
        var chooser = new ImageChooser({
            url: '/json/getImages'
        });
        var oThis = this;
        chooser.show(null, function(data){
            var gridStore = Ext.getCmp(oThis.conf.targetGrid).getStore(); //modify Triggerfield via setValue wont work !
            gridStore.getById(oThis.conf.targetRowName).set('value', data.url);
            if (oThis.conf.redimWrapper && data.w > 1 && data.h > 1) { // dont resize if null-image is selected
                gridStore.getById('width').set('value', parseInt(data.w)); // parseInt otherwise its a String -> javascript roundtrip problem
                gridStore.getById('height').set('value', parseInt(data.h));
            }
        });
    }
});

HAP.GridChartObject = function(config){
    this.conf = {
        redimWrapper: true
    };
    Ext.apply(this.conf, config);
    HAP.GridChartObject.superclass.constructor.call(this);
}

Ext.extend(HAP.GridChartObject, Ext.form.TriggerField, {
    onTriggerClick: function(event){
        var oThis = this;
        var chartDisplayObj = Ext.getCmp(oThis.conf.targetGrid).conf.display;
        var chooser = new HAP.ChartPropWindow(chartDisplayObj);
        chooser.show();
    }
});


HAP.GridChart5Object = function(config){
    this.conf = {
        redimWrapper: true
    };
    Ext.apply(this.conf, config);
    HAP.GridChart5Object.superclass.constructor.call(this);
}

Ext.extend(HAP.GridChart5Object, Ext.form.TriggerField, {
    onTriggerClick: function(event){
        var oThis = this;
        var chartDisplayObj = Ext.getCmp(oThis.conf.targetGrid).conf.display;
        var chooser = new HAP.Chart5PropWindow(chartDisplayObj);
        chooser.show();
    }
});

HAP.GridColorField = function(gridId, rowName, confObj){ // Extending doesnt work
    this.gridId = gridId;
    this.gridRowName = rowName;
    var cF = new Ext.form.ColorField({
        showHexValue: true
    });
    var oThis = this;
    cF.on('change', function(){
        var gridStore = Ext.getCmp(oThis.gridId).getStore(); //modify Triggerfield via setValue wont work !
        gridStore.getById(oThis.gridRowName).set('value', cF.getValue());
    });
    return cF;
}

HAP.GridTextField = function(confObj){
    //this.id = confObj.id;
    this.allowBlank = false;
    HAP.GridTextField.superclass.constructor.call(this);
}

Ext.extend(HAP.GridTextField, Ext.form.TextField, {});

HAP.GridTextLabel = function(gridId, confObj){
    this.id = confObj.id;
    this.allowBlank = true;
    if (confObj.maxLength) {
        this.maxLength = confObj.maxLength;
    }
    HAP.GridTextLabel.superclass.constructor.call(this);
    
    this.on('change', function(field, newValue, oldValue){
        Ext.getCmp(gridId).getCurrentFigure().setText(newValue);
    });
    
}

Ext.extend(HAP.GridTextLabel, Ext.form.TextField, {});

HAP.GridSimulatorValue = function(gridId, confObj){
    this.id = confObj.id;
    this.allowBlank = true;
    if (confObj.maxLength) {
        this.maxLength = confObj.maxLength;
    }
    HAP.GridTextLabel.superclass.constructor.call(this);
    
    this.on('change', function(field, newValue, oldValue){
        var cFigure = Ext.getCmp(gridId).getCurrentFigure();
        cFigure.setSimValue(cFigure.conf.calcVar, newValue);
        //Ext.getCmp('btnSimulate').handler.call();
    });
    
}

Ext.extend(HAP.GridSimulatorValue, Ext.form.TextField, {});


HAP.GridActivateSimulatorValue = function(gridId, confObj){
    this.id = confObj.id;
    HAP.GridTextLabel.superclass.constructor.call(this);
    this.on('change', function(field, newValue, oldValue){
        var cFigure = Ext.getCmp(gridId).getCurrentFigure();
        if (cFigure.conf.display['Activate (Simulator)'] == 1) 
            cFigure.conf.calcVar = 1;
        else 
            cFigure.conf.calcVar = 0;
        cFigure.setSimValue(cFigure.conf.calcVar, cFigure.conf.display['Simulator-Value']);
    });
}

Ext.extend(HAP.GridActivateSimulatorValue, Ext.form.TextField, {});


HAP.GridComboModules = function(confObj){
    this.id = confObj.id;
    this.store = storeModules;
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'module';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a module...';
    this.forceSelection = true;
    this.selectOnFocus = true;
    this.editable = false;
    this.allowBlank = false;
    HAP.GridComboModules.superclass.constructor.call(this);
    this.on('select', function(){
        var devCombo = Ext.getCmp('gridComboDevices');
        var triggerCombo = Ext.getCmp('gridComboTriggerDevices');
        if (devCombo)
          devCombo.loadDevices(this.value);
        if (triggerCombo)
          triggerCombo.loadDevices(this.value);
    });
}

Ext.extend(HAP.GridComboModules, Ext.form.ComboBox, {});

HAP.GridComboDevices = function(confObj){
    this.id = confObj.id;
    this.store = storeAllDevices;
    this.valueField = 'address';
    this.displayField = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a device...';
    this.selectOnFocus = true;
    this.editable = false;
    HAP.GridComboDevices.superclass.constructor.call(this);
}

Ext.extend(HAP.GridComboDevices, Ext.form.ComboBox, {
    loadDevices: function(mId){
        this.store.proxy = new Ext.data.HttpProxy({
            url: '/json/getAllDevices/' + mId
        });
        this.store.load();
    }
});

HAP.GridComboTriggerDevices = function(confObj){
    this.id = confObj.id;
    this.store = storeAllTriggerDevices;
    this.valueField = 'address';
    this.displayField = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a device...';
    this.selectOnFocus = true;
    this.editable = false;
    HAP.GridComboTriggerDevices.superclass.constructor.call(this);
}

Ext.extend(HAP.GridComboTriggerDevices, Ext.form.ComboBox, {
    loadDevices: function(mId){
        this.store.proxy = new Ext.data.HttpProxy({
            url: '/json/getAllTriggerDevices/' + mId
        });
        this.store.load();
    }
});

HAP.GridComboMacros = function(confObj){
    this.id = confObj.id;
    this.store = storeMacros;
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'makro';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a macro...';
    this.forceSelection = true;
    this.selectOnFocus = true;
    this.editable = false;
    this.allowBlank = false;
    HAP.GridComboMacros.superclass.constructor.call(this);
}

Ext.extend(HAP.GridComboMacros, Ext.form.ComboBox, {});

HAP.GridComboTimeBase = function(confObj){
    this.id = confObj.id;
    this.store = storeTimeBase;
    this.valueField = 'value';
    this.displayField = 'name';
    //this.hiddenName = 'module';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a Time-Base...';
    this.forceSelection = true;
    this.selectOnFocus = true;
    this.editable = false;
    this.allowBlank = false;
    HAP.GridComboTimeBase.superclass.constructor.call(this);
    
}

Ext.extend(HAP.GridComboTimeBase, Ext.form.ComboBox, {});

HAP.GridComboWeekdays = function(confObj){
    this.id = confObj.id;
    this.store = storeWeekdays;
    this.valueField = 'value';
    this.displayField = 'name';
    //this.hiddenName = 'module';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a Time-Base...';
    this.forceSelection = true;
    this.selectOnFocus = true;
    this.editable = false;
    this.allowBlank = false;
    HAP.GridComboWeekdays.superclass.constructor.call(this);
}

Ext.extend(HAP.GridComboWeekdays, Ext.form.ComboBox, {});

HAP.GridComboView = function(confObj){
    this.id = confObj.id;
    this.store = storeGuiViews;
    this.valueField = 'id';
    this.displayField = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a View...';
    this.forceSelection = false;
    this.selectOnFocus = true;
    this.editable = false;
    this.allowBlank = true;
    HAP.GridComboView.superclass.constructor.call(this);
    this.on('select', clearOtherViews);
}

Ext.extend(HAP.GridComboView, Ext.form.ComboBox, {});

var clearOtherViews = function(field, record, index){
    var gridStore = Ext.getCmp('guiPropertyGrid').getStore();
    if (field.id != 'gridComboView') {
        gridStore.getById('Target View').set('value', '');
    }
    if (field.id != 'gridComboScene') {
        gridStore.getById('Target Scene').set('value', '');
    }
    if (field.id != 'gridTextExternalTarget') {
        gridStore.getById('Target External').set('value', '');
    }
}

HAP.GridComboScene = function(confObj){
    this.id = confObj.id;
    this.store = storeGuiScenes;
    this.valueField = 'id';
    this.displayField = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a Scene...';
    this.forceSelection = false;
    this.selectOnFocus = true;
    this.editable = false;
    this.allowBlank = true;
    HAP.GridComboScene.superclass.constructor.call(this);
    this.on('select', clearOtherViews);
}

Ext.extend(HAP.GridComboScene, Ext.form.ComboBox, {});


HAP.GridComboChartType = function(confObj){
    this.id = confObj.id;
    this.store = [ 'Line', 'Bar', 'HBar', 'HProgress', 'VProgress', 'Meter', 'Odometer' ];
    this.valueField = 'id';
    this.displayField = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a Type...';
    this.forceSelection = false;
    this.selectOnFocus = true;
    this.editable = false;
    this.allowBlank = true;
    HAP.GridComboChartType.superclass.constructor.call(this);
}
Ext.extend(HAP.GridComboChartType, Ext.form.ComboBox, {});


var gridRenderer = function(editor, v){
    var rv = editor.field.emptyText;
    var dfld = editor.field.displayField;
    var vfld = editor.field.valueField;
    var i = editor.field.store.find(vfld, v);
    var rec = editor.field.store.getAt(i);
    if (rec) {
        rv = rec.get(dfld);
    }
    return rv;
};

Ext.grid.PropertyColumnModel.prototype.renderCell = function(val, p, record, rowIndex, colIndex, ds){
    var rv = val;
    if (this.grid.customRenderers && this.grid.customRenderers[record.get('name')]) {
        rv = this.grid.customRenderers[record.get('name')](this.grid.customEditors[record.get('name')], val, p, record, rowIndex, colIndex, ds);
    }
    else {
        if (val instanceof Date) {
            rv = this.renderDate(val);
        }
        else 
            if (typeof val == 'boolean') {
                rv = this.renderBool(val);
            }
    }
    return Ext.util.Format.htmlEncode(rv);
};

Ext.grid.PropertyStore.prototype.setSource = function(o){
    this.source = o;
    this.store.removeAll();
    var data = [];
    for (var k in o) {
        var avoid = false;
        
        if (this.grid.onlyFields && this.grid.onlyFields.length > 0) {
            avoid = true;
            if (this.grid.onlyFields.indexOf(k) > -1) {
                avoid = false;
            }
        }
        
        if (this.grid.avoidFields && this.grid.avoidFields.length > 0) {
            if (this.grid.avoidFields.indexOf(k) > -1) {
                avoid = true;
            }
        }
        
        
        if (!avoid && this.isEditableValue(o[k])) {
            data.push(new Ext.grid.PropertyRecord({
                name: k,
                value: o[k]
            }, k));
        }
    }
    this.store.loadRecords({
        records: data
    }, {}, true);
}
/**
 * @author bendowski
 */
HAP.ObjectTreePanel = function(){
    this.id = 'objectTreePanel';
    this.iconCls = 'objectExplorer';
    this.region = 'north'; // wichtig!
    this.height = 500; //wichtig
    this.split = true; // wichtig
    //this.title = 'Objects';
    this.border = false;
    this.iconCls = 'nav';
    this.autoScroll = true;
    this.layout = 'fit';
    HAP.ObjectTreePanel.superclass.constructor.call(this);
}

Ext.extend(HAP.ObjectTreePanel, Ext.Panel, {
    removeAll: function(){
        if (this.items) {
            this.items.each(function(item, index, len){
                if (document.getElementById(item.id)) {
                    var node = document.getElementById(item.id).parentNode;
                    if (node.hasChildNodes()) {
                        while (node.childNodes.length >= 1) {
                            node.removeChild(node.firstChild);
                        }
                    }
                    this.remove(item, true); //and remove from DOM !
                }
            }, this);
        }
    }
});

/**
 * @author bendowski
 */
HAP.ObjectPropertyPanel = function(){
    this.id = 'objectPropertyPanel';
    this.region = 'center';
    this.split = true;
    this.autoScroll = true;
    this.height = 500;
    this.layout = 'fit';
    HAP.ObjectPropertyPanel.superclass.constructor.call(this);
}

Ext.extend(HAP.ObjectPropertyPanel, Ext.Panel, {
    removeAll: function(){
        if (this.items) 
            this.items.each(function(item, index, len){
                this.remove(item, true); //and remove from DOM !
            }, this);
    }
});
HAP.UploadFileWindow = function(el, event, callback){
    dialog = new Ext.ux.UploadDialog.Dialog({
	title: 'File upload',
        url: '/fileupload/getFile',
        reset_on_hide: false,
        allow_close_on_upload: true,
        upload_autostart: true,
        permitted_extensions: ['jpg', 'jpeg', 'gif', 'png', 'zip', 'JPG', 'JPEG', 'GIF', 'PNG', 'ZIP']
    });
        
    var onUploadSuccess =  function (dialog, filename, data){
        if (data.firmwareid) {
            storeFirmware.reload({
                parms: {
                    firmwareid: data.firmwareid
                }
            });
        }
        if (callback) {
          callback();
        }
    }

    dialog.show();
    dialog.on('uploadsuccess', onUploadSuccess);
}


var newEntry = Ext.data.Record.create([{
    name: 'time',
    type: 'date'
}, {
    name: 'source',
    type: 'string'
}, {
    name: 'type',
    type: 'string'
}, {
    name: 'message',
    type: 'string'
}]);

var logAutoUpdater = function(filter){
    if (storeLog.reader.jsonData) {
        storeLog.proxy.conn.url = '/log/getNewLogEntries/1/' +
        storeLog.reader.jsonData.lastID;
        storeLog.proxy.conn.method = 'GET', storeLog.reload({
            add: true
        });
        storeLog.proxy.conn.url = '/log/getNewLogEntries/0/' +
        storeLog.reader.jsonData.lastID;
        var pBar = Ext.getCmp('logPagingToolbar');
        pBar.getPageData().activePage;
    }
}

HAP.LogTable = function(){
    var sm = new Ext.grid.CheckboxSelectionModel({});
    var cm = new Ext.grid.ColumnModel([sm, {
        id: 'logTableTime',
        header: 'Time',
        dataIndex: 'time',
        sortable: true,
        width: 40
    }, {
        id: 'logTableSource',
        header: 'Source',
        dataIndex: 'source',
        sortable: true,
        width: 30
    }, {
        id: 'logTableType',
        header: 'Type',
        dataIndex: 'type',
        sortable: true,
        width: 20
    }, {
        id: 'logTableMessage',
        header: 'Message',
        dataIndex: 'message',
        sortable: true,
        width: 400
    }]);
    
    this.id = 'logTable';
    this.ds = storeLog;
    this.cm = cm;
    this.sm = sm;
    this.region = 'south';
    this.viewConfig = {
        forceFit: true
    };
    
    this.tbar = new Ext.Toolbar([{
        id: 'logLiveMonitorButton',
        enableToggle: true,
        text: 'Start Live Monitoring',
        iconCls: 'start',
        toggleHandler: function(button, state){
            if (state) {
                Ext.TaskMgr.stop(taskLogUpdate);
                Ext.TaskMgr.start(taskSpeedLogUpdate);
                button.setText('Stop Live Monitoring');
                button.setIconClass('stop');
            }
            else {
                Ext.TaskMgr.stop(taskSpeedLogUpdate);
                Ext.TaskMgr.start(taskLogUpdate);
                button.setText('Start Live Monitoring');
                button.setIconClass('start');
            }
        }
    }, {
        text: 'Clear Log',
        iconCls: 'delete',
        handler: function(){
            var win = new Ext.Window({
                title: 'Clear Log',
                width: 200,
                height: 100,
                resizable: false,
                bodyBorder: false,
                border: false,
                buttonAlign: 'center',
                bodyStyle: 'padding:10px 10px 0',
                items: [new Ext.form.Checkbox({
                    id: 'checkClearAllLog',
                    inputValue: 1,
                    boxLabel: 'Clear all entries'
                })],
                buttons: [{
                    text: 'Ok',
                    iconCls: 'ok',
                    handler: function(){
                        var ids = new Array();
                        var i = 0;
                        var recs = sm.getSelections();
                        for (i in recs) {
                            ids[i] = recs[i].id;
                        }
                        var conn = new Ext.data.Connection();
                        conn.request({
                            method: 'POST',
                            url: '/log/clear',
                            params: {
                                all: Ext.getCmp('checkClearAllLog').getValue(),
                                data: Ext.util.JSON.encode(ids)
                            }
                        });
                        conn.on('requestcomplete', function(sender, response){
                            var r = Ext.decode(response.responseText);
                            if (r.permissiondenied) {
                                var loginWindow = new HAP.LoginWindow();
                                loginWindow.show();
                            }
                            else {
                                storeLog.load();
                            }
                        });
                        win.hide();
                        win.destroy();
                    }
                }, {
                    text: 'Cancel',
                    iconCls: 'cancel',
                    handler: function(){
                        win.hide();
                        win.destroy();
                    }
                }]
            
            });
            win.show();
        }
    }, {
        text: 'Download Log',
        iconCls: 'download',
        handler: function(){
            var win = new Ext.Window({
                title: 'Download Log',
                width: 200,
                height: 100,
                resizable: false,
                bodyBorder: false,
                border: false,
                buttonAlign: 'center',
                bodyStyle: 'padding:10px 10px 0',
                items: [new Ext.form.Checkbox({
                    id: 'downloadAllLog',
                    inputValue: 1,
                    boxLabel: 'Download complete log'
                })],
                buttons: [{
                    text: 'Ok',
                    iconCls: 'ok',
                    handler: function(){
                        var ids = new Array();
                        var recs = sm.getSelections();
                        for (var i in recs) {
                            ids[i] = recs[i].id;
                        }
                        //window.open('/log/getPDF?all=' + Ext.getCmp('downloadAllLog').getValue() + '&ids=' + ids);
                        window.open('/log/getLog?all=' + Ext.getCmp('downloadAllLog').getValue() + '&ids=' + ids);
                        win.hide();
                        win.destroy();
                    }
                }, {
                    text: 'Cancel',
                    iconCls: 'cancel',
                    handler: function(){
                        win.hide();
                        win.destroy();
                    }
                }]
            
            });
            win.show();
        }
    }]);
    
    this.bbar = new Ext.PagingToolbar({
        id: 'logPagingToolbar',
        pageSize: 50,
        store: storeLog,
        displayInfo: true,
        autoHeight: true,
        displayMsg: 'Displaying Record {0} - {1} of {2}',
        emptyMsg: 'No records to display'
    });
    
    HAP.LogTable.superclass.constructor.call(this);
    
    var pBar = Ext.getCmp('logPagingToolbar');
    pBar.getPageData().activePage;
    pBar.doLoad(pBar.cursor);
    
}

Ext.extend(HAP.LogTable, Ext.grid.EditorGridPanel, {
    addEntry: function(source, type, message){
        var c = new newEntry({
            time: (new Date()).dateFormat('Y-m-j G:i:s'),
            source: source,
            type: type,
            message: message
        })
        storeLog.insert(0, c);
    }
});
var storeLog = new Ext.data.Store({
    autoLoad: true,
    url: '/log/getNewLogEntries/',
    reader: new Ext.data.JsonReader({
        totalProperty: 'total',
        root: 'log',
        id: 'id',
        lastID: 'lastID' // custom attribute
    }, [{
        name: 'pid',
        type: 'int'
    }, {
        name: 'time',
        type: 'date',
        dateFormat: 'Y-m-d H:i:s'
    }, {
        name: 'source',
        type: 'string'
    }, {
        name: 'type',
        type: 'string'
    }, {
        name: 'message',
        type: 'string'
    }])
});

storeLog.on('load', function(){
    storeLog.sort('time', 'DESC');
    var count = storeLog.getCount();
    if (count > 50) {
        var firstOut = storeLog.getRange(50, count);
        for (var i = 0; i < firstOut.length; i++) {
            storeLog.remove(firstOut[i]);
        }
    }
});

var storeRooms = new Ext.data.Store({
    url: '/json/getRooms',
    reader: new Ext.data.JsonReader({
        root: 'rooms'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeUpstreamInterfaces = new Ext.data.Store({
    url: '/json/getUpstreamInterfaces',
    reader: new Ext.data.JsonReader({
        root: 'upstreaminterfaces'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});


var storeModules = new Ext.data.Store({
    url: '/json/getModules',
    reader: new Ext.data.JsonReader({
        root: 'modules'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeModuleProps = new Ext.data.Store({
    url: '/managemodules/getModules',
    pruneModifiedRecords: true,
    reader: new Ext.data.JsonReader({
        root: 'modules',
        id: 'id'
    }, [{
        name: 'name',
        type: 'string',
        mapping: 'name'
    }, {
        name: 'id',
        mapping: 'id'
    }, {
        name: 'firmwareid',
        mapping: 'firmwareid'
    }, {
        name: 'devoption/1',
        mapping: 'devoption/1'
    }, {
        name: 'devoption/2',
        mapping: 'devoption/2'
    }, {
        name: 'devoption/4',
        mapping: 'devoption/4'
    }])
});

var storeNotifyModules = new Ext.data.Store({
    url: '/json/getNotifyModules',
    reader: new Ext.data.JsonReader({
        root: 'modules'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeUpstreamModules = new Ext.data.Store({
    url: '/json/getUpstreamModules',
    reader: new Ext.data.JsonReader({
        root: 'modules'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeFreeModuleAddresses = new Ext.data.Store({
    url: '/json/getFreeModuleAddresses/',
    reader: new Ext.data.JsonReader({
        root: 'addresses'
    }, [{
        name: 'address'
    }])
});

var storeAddresses = new Ext.data.Store({
    url: '/json/getAddresses/',
    reader: new Ext.data.JsonReader({
        root: 'addresses'
    }, [{
        name: 'name'
    }])
});

var storePortPins = new Ext.data.Store({
    url: '/json/getPortPins/',
    reader: new Ext.data.JsonReader({
        root: 'portpins'
    }, [{
        name: 'name'
    }])
});

var storeDeviceTypes = new Ext.data.Store({
    url: '/json/getDeviceTypes',
    reader: new Ext.data.JsonReader({
        root: 'devicetypes'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeTimeBase = new Ext.data.Store({
    autoLoad: true,
    url: '/json/getTimeBase',
    reader: new Ext.data.JsonReader({
        root: 'timebase'
    }, [{
        name: 'value'
    }, {
        name: 'name'
    }])
});

var storeWeekdays = new Ext.data.Store({
    autoLoad: true,
    url: '/json/getWeekdays',
    reader: new Ext.data.JsonReader({
        root: 'days'
    }, [{
        name: 'value'
    }, {
        name: 'name'
    }])
});


var storeDigitalInputTypes = new Ext.data.Store({
    url: '/json/getDigitalInputTypes',
    reader: new Ext.data.JsonReader({
        root: 'devicetypes'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeDevices = new Ext.data.Store({
    url: '/json/getDevices',
    reader: new Ext.data.JsonReader({
        root: 'devices'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeShutterDevices = new Ext.data.Store({
    url: '/json/getShutterDevices',
    reader: new Ext.data.JsonReader({
        root: 'devices'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])

});

var storeAllDevices = new Ext.data.Store({
    url: '/json/getAllDevices',
    reader: new Ext.data.JsonReader({
        root: 'devices'
    }, [{
        name: 'name'
    }, {
        name: 'address'
    }, {
        name: 'module'
    }])
});

var storeAllTriggerDevices = new Ext.data.Store({
    url: '/json/getAllTriggerDevices',
    reader: new Ext.data.JsonReader({
        root: 'devices'
    }, [{
        name: 'name'
    }, {
        name: 'address'
    }, {
        name: 'module'
    }])
});

var storeLogicalInputs = new Ext.data.Store({
    url: '/json/getLogicalInputs',
    reader: new Ext.data.JsonReader({
        root: 'logicalinputs'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeLogicalInputs1 = new Ext.data.Store({
    url: '/json/getLogicalInputs',
    reader: new Ext.data.JsonReader({
        root: 'logicalinputs'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeAbstractDevices = new Ext.data.Store({
    url: '/json/getAbstractDevices',
    reader: new Ext.data.JsonReader({
        root: 'abstractdevices'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeLogicalInputTemplates = new Ext.data.Store({
    url: '/json/getLogicalInputTemplates',
    reader: new Ext.data.JsonReader({
        root: 'templates',
        id: 'id'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }, {
        name: 'type'
    }])
});

var storeASInputValueTemplates = new Ext.data.Store({
    url: '/json/getASInputValueTemplates',
    reader: new Ext.data.JsonReader({
        root: 'templates',
        id: 'id'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }, {
        name: 'type'
    }])
});

var storeStartModes = new Ext.data.Store({
    url: '/json/getStartModes',
    reader: new Ext.data.JsonReader({
        root: 'startmodes'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeFirmware = new Ext.data.Store({
    url: '/managefirmware/getFirmware',
    pruneModifiedRecords: true,
    reader: new Ext.data.JsonReader({
        root: 'firmware',
        id: 'id' // wichtig, sonst passt das mapping nicht (combobox in grid)
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }, {
        name: 'date'
    }, {
        name: 'version'
    }, {
        name: 'precompiled'
    }, {
        name: 'compileoptions'
    }, {
        name: 'filename'
    }])
});

var storeMacros = new Ext.data.Store({
    url: '/json/getMacros',
    reader: new Ext.data.JsonReader({
        root: 'macros'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeIRDestinations = new Ext.data.SimpleStore({
    fields: ['id', 'name'],
    data: [['standardOutputs', 'Device'], ['shutter', 'Shutter'], ['makro', 'Makro']]
});

var storeConfig = new Ext.data.Store({
    url: '/manageconfigs/getConfigs',
    pruneModifiedRecords: true,
    reader: new Ext.data.JsonReader({
        root: 'results',
        id: 'id'
    }, [{
        name: 'name',
        type: 'string',
        mapping: 'name'
    }, {
        name: 'id',
        mapping: 'id'
    }, {
        name: 'isdefault',
        mapping: 'isdefault'
    }])
});

var storeSchedulerCommands = new Ext.data.Store({
    url: '/json/getSchedulerCommands',
    reader: new Ext.data.JsonReader({
        root: 'scheduler',
        id: 'id'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeSchedules = new Ext.data.Store({
    url: '/managescheduler/getSchedules',
    pruneModifiedRecords: true, //get modifiedRecords in grid persists on store-load()
    reader: new Ext.data.JsonReader({
        root: 'schedules',
        id: 'id'
    }, [{
        name: 'cron',
        type: 'string',
        mapping: 'cron'
    }, {
        name: 'id',
        mapping: 'id'
    }, {
        name: 'cmd',
        mapping: 'cmd'
    }, {
        name: 'args',
        mapping: 'args'
    }, {
        name: 'description',
        mapping: 'description'
    }, {
        name: 'status',
        mapping: 'status'
    }])
});

var storeGuiViews = new Ext.data.Store({
    url: '/json/getGuiViews',
    reader: new Ext.data.JsonReader({
        root: 'views'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeGuiScenes = new Ext.data.Store({
    url: '/json/getGuiScenes',
    reader: new Ext.data.JsonReader({
        root: 'scenes'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeUsers = new Ext.data.Store({
    url: '/users/get',
    reader: new Ext.data.JsonReader({
        root: 'users',
        id: 'id'
    }, [{
        name: 'id'
    }, {
        name: 'username'
    }, {
        name: 'password'
    }, {
        name: 'prename'
    }, {
        name: 'surname'
    }, {
        name: 'email'
    }, {
        name: 'password1'
    }, {
        name: 'password2'
    }])
});

var storeUserRoles = new Ext.data.Store({
    url: '/users/getUserRoles',
    reader: new Ext.data.JsonReader({
        root: 'userRoles',
        id: 'id'
    }, [{
        name: 'id'
    }, {
        name: 'role'
    }, {
        name: 'status'
    }])
});


var loadStores = function(){
    storeModules.load();
    storeNotifyModules.load();
    storeUpstreamModules.load();
    storeAddresses.load();
    storePortPins.load();
    storeDeviceTypes.load();
    storeUpstreamInterfaces.load();
    storeRooms.load();
    storeFirmware.load();
    storeStartModes.load();
    storeLogicalInputTemplates.load();
    storeDigitalInputTypes.load();
    storeMacros.load();
    storeSchedulerCommands.load();
    storeGuiViews.load();
    storeGuiScenes.load();
    storeASInputValueTemplates.load();
}
HAP.TextName = function(url){
    this.id = url + '/textName';
    this.fieldLabel = 'Name';
    this.name = 'name';
    this.width = 230;
    this.allowBlank = false;
    this.tabIndex = 0;
    HAP.TextName.superclass.constructor.call(this);
}

Ext.extend(HAP.TextName, Ext.form.TextField, {});

HAP.TextModuleUID = function(url){
    this.id = url + '/uid';
    this.fieldLabel = 'UID';
    this.name = 'uid';
    this.width = 230;
    this.allowBlank = false;
    this.maskRe = /[ABCDEF\d]+/;
    this.regex = /^([ABCDEF\d]){6}$/;
    this.regexText = 'Only digits from 0-9 and characters from A-F allowed.\n A valid UID looks like: 00AF4C and is noted on every Control-Unit';
    this.invalidText = this.regexText;
    HAP.TextModuleUID.superclass.constructor.call(this);
}

Ext.extend(HAP.TextModuleUID, Ext.form.TextField, {});

HAP.TextFormulaDescription = function(url){
    this.fieldLabel = 'Formula Descr.';
    this.name = 'formuladescription';
    this.id = url + '/textFormulaDescription';
    this.width = 230;
    this.allowBlank = true;
    HAP.TextFormulaDescription.superclass.constructor.call(this);
}

Ext.extend(HAP.TextFormulaDescription, Ext.form.TextField, {});

HAP.TextFormula = function(url){
    this.fieldLabel = 'Formula';
    this.name = 'formula';
    this.id = url + '/textFormula';
    this.width = 230;
    this.allowBlank = true;
    HAP.TextFormula.superclass.constructor.call(this);
}

Ext.extend(HAP.TextFormula, Ext.form.TextField, {});

HAP.ComboRoom = function(url){
    this.id = url + '/comboRoom';
    this.store = storeRooms;
    this.fieldLabel = 'Room';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'room';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a room...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboRoom.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboRoom, Ext.form.ComboBox, {});


HAP.ComboUpstreamInterface = function(url){
    this.id = url + '/comboUpstreamInterface';
    this.store = storeUpstreamInterfaces;
    this.fieldLabel = 'Upstream Interf.';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'upstreaminterface';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select an interface...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboUpstreamInterface.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboUpstreamInterface, Ext.form.ComboBox, {});


HAP.ComboModule = function(url, confObj){
    this.id = url + '/comboModule';
    if (confObj && confObj.instance) {
        this.id = url + '/comboModule/' + confObj.instance;
    }
    this.store = storeModules;
    this.fieldLabel = 'Module';
    if (confObj && confObj.fieldLabel) {
        this.fieldLabel = confObj.fieldLabel;
    }
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'module';
    if (confObj && confObj.name) {
        this.name = confObj.name;
        this.hiddenName = confObj.name;
    }
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a module...';
    this.forceSelection = true;
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    if (confObj && confObj.allowBlank) {
        this.allowBlank = true;
    }
    HAP.ComboModule.superclass.constructor.call(this);
    
    this.on('select', function(){
        changeAddressAndPortPin(url, this.value)
    });
}

Ext.extend(HAP.ComboModule, Ext.form.ComboBox, {});

HAP.ComboAddress = function(url){
    this.id = url + '/comboAddress';
    this.store = storeAddresses;
    this.fieldLabel = 'Address';
    this.valueField = 'name';
    this.forceSelection = true;
    this.displayField = 'name';
    this.hiddenName = 'address';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select an address...';
    this.selectOnFocus = true;
    this.width = 60;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboAddress.superclass.constructor.call(this);
    
    this.on('select', function(){
        var comboModule = Ext.getCmp(url + '/comboModule');
        if (comboModule.getValue() != '' && this.getValue != '') {
            var conn = new Ext.data.Connection();
            conn.request({
                method: 'GET',
                url: '/json/checkAddress/' + comboModule.getValue() + '/' + this.getValue() + '/' + this.id.split('/')[1]
            });
            var oThis = this;
            conn.on('requestcomplete', function(sender, param){
                var response = Ext.util.JSON.decode(param.responseText);
                if (!response.success) {
                    oThis.reset();
                }
            }, {
                scope: this
            });
        }
    });
}

Ext.extend(HAP.ComboAddress, Ext.form.ComboBox, {});

HAP.ComboPortPin = function(url){
    this.id = url + '/comboPortPin';
    this.store = storePortPins;
    this.fieldLabel = 'Port-Pin';
    this.forceSelection = true;
    this.valueField = 'name';
    this.displayField = 'name';
    this.hiddenName = 'portPin';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select an port-pin...';
    this.selectOnFocus = true;
    this.width = 60;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboPortPin.superclass.constructor.call(this);
    
    this.on('select', function(){
        var comboModule = Ext.getCmp(url + '/comboModule');
        if (comboModule.getValue() != '' && this.getValue != '') {
            var conn = new Ext.data.Connection();
            conn.request({
                method: 'GET',
                url: '/json/checkPortPin/' + comboModule.getValue() + '/' + this.getValue() + '/' + this.id.split('/')[1]
            });
            var oThis = this;
            conn.on('requestcomplete', function(sender, param){
                var response = Ext.util.JSON.decode(param.responseText);
                if (!response.success) {
                    oThis.reset();
                }
            }, {
                scope: this
            });
        }
    });
}

Ext.extend(HAP.ComboPortPin, Ext.form.ComboBox, {});

HAP.ComboDeviceType = function(url){
    this.id = url + '/comboDeviceType';
    this.store = storeDeviceTypes;
    this.fieldLabel = 'Type';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'type';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a type...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboDeviceType.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboDeviceType, Ext.form.ComboBox, {});

HAP.ComboDigitalInputType = function(url){
    this.id = url + '/comboDigitalInputType';
    this.store = storeDigitalInputTypes;
    this.fieldLabel = 'Type';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'type';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a type...';
    this.selectOnFocus = true;
    this.width = 200;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboDigitalInputType.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboDigitalInputType, Ext.form.ComboBox, {});

HAP.ComboIRDestinations = function(url){
    this.id = url + '/comboIRDestinations';
    this.store = storeIRDestinations;
    this.fieldLabel = 'Type';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'type';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a type...';
    this.selectOnFocus = true;
    this.width = 64;
    this.editable = false;
    this.allowBlank = false;
    
    HAP.ComboIRDestinations.superclass.constructor.call(this);
    var oThis = this;
    this.on('select', function(){
        Ext.getCmp(url).doLayout();
        oThis.hideField(Ext.getCmp(url + '/comboDevices'));
        oThis.hideField(Ext.getCmp(url + '/comboAbstractDevices'));
        oThis.hideField(Ext.getCmp(url + '/comboMakros'));
        switch (this.value) {
            case 'makro':
                oThis.showField(Ext.getCmp(url + '/comboMakros'), {
                    allowBlank: false
                });
                Ext.getCmp(url + '/irkey').minValue = 0;
                Ext.getCmp(url + '/irkey').maxValue = 9;
                break;
            case 'standardOutputs':
                oThis.showField(Ext.getCmp(url + '/comboDevices'), {
                    allowBlank: false
                });
                Ext.getCmp(url + '/irkey').minValue = 10;
                Ext.getCmp(url + '/irkey').maxValue = 99;
                break;
            case 'shutter':
                oThis.showField(Ext.getCmp(url + '/comboAbstractDevices'), {
                    allowBlank: false
                });
                Ext.getCmp(url + '/irkey').minValue = 10;
                Ext.getCmp(url + '/irkey').maxValue = 99;
                break;
        }
        Ext.getCmp(url).doLayout();
    });
}

Ext.extend(HAP.ComboIRDestinations, Ext.form.ComboBox, {
    hideField: function(field){
        field.allowBlank = true;
        field.hide();
        field.getEl().up('.x-form-item').setDisplayed(false);
    },
    showField: function(field, confObj){
        if (confObj) {
            field.allowBlank = confObj.allowBlank;
        }
        field.show();
        field.getEl().up('.x-form-item').setDisplayed(true);
    }
});

HAP.ComboMakros = function(url, confObj){
    this.id = url + '/comboMakros';
    this.store = storeMacros;
    this.fieldLabel = 'Makro';
    this.valueField = 'id';
    this.displayField = 'name';
    this.name = 'makro';
    this.hiddenName = 'makro';
    if (confObj && confObj.name) {
        this.name = confObj.name;
        this.hiddenName = confObj.name;
    }
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a makro...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    HAP.ComboMakros.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboMakros, Ext.form.ComboBox, {});

HAP.ComboDevices = function(url, confObj){
    this.id = url + '/comboDevices';
    if (confObj && confObj.instance) {
        this.id = url + '/comboDevices/' + confObj.instance;
    }
    if (confObj && confObj.shutter) {
        this.store = storeShutterDevices;
        storeShutterDevices.load();
    }
    else {
        this.store = storeDevices;
        storeDevices.load();
    }
    //    storeDevices.proxy = new Ext.data.HttpProxy({
    //        url: '/json/getDevices/standardOutputs'
    //    });
    //    storeDevices.load();
    
    this.fieldLabel = 'Type';
    if (confObj && confObj.label) {
        this.fieldLabel = confObj.label;
    }
    if (confObj && confObj.name) {
        this.name = confObj.name;
        this.hiddenName = confObj.name;
    }
    this.valueField = 'id';
    this.displayField = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a device...';
    this.selectOnFocus = true;
    this.width = 200;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboDevices.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboDevices, Ext.form.ComboBox, {});

HAP.ComboLogicalInputs = function(url, confObj){
    this.id = url + '/comboLogicalInputs';
    if (confObj && confObj.instance) {
        this.id = url + '/comboLogicalInputs/' + confObj.instance;
    }
    if (confObj && confObj.rotaryEncoder) {
        this.store = storeLogicalInputs;
        storeLogicalInputs.proxy = new Ext.data.HttpProxy({
            url: '/json/getLogicalInputs/151'
        });
        storeLogicalInputs.load();
    }
    else {
        if (confObj && confObj.pushButton) {
            this.store = storeLogicalInputs1;
            storeLogicalInputs1.proxy = new Ext.data.HttpProxy({
                url: '/json/getLogicalInputs/186'
            });
            storeLogicalInputs1.load();
        }
        else 
            if (confObj && confObj.rotaryEncoderPushButton) {
                this.store = storeLogicalInputs1;
                storeLogicalInputs1.proxy = new Ext.data.HttpProxy({
                    url: '/json/getLogicalInputs/158'
                });
                storeLogicalInputs1.load();
            }
    }
    this.fieldLabel = 'Type';
    if (confObj && confObj.label) {
        this.fieldLabel = confObj.label;
    }
    if (confObj && confObj.name) {
        this.name = confObj.name;
        this.hiddenName = confObj.name;
    }
    this.valueField = 'id';
    this.displayField = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a device...';
    this.selectOnFocus = true;
    this.width = 200;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboLogicalInputs.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboLogicalInputs, Ext.form.ComboBox, {});

HAP.ComboAbstractDevices = function(url, confObj){
    this.id = url + '/comboAbstractDevices';
    if (confObj && confObj.instance) {
        this.id = url + '/comboAbstractDevices/' + confObj.instance;
    }
    this.store = storeAbstractDevices;
    if (confObj && confObj.gui) {
        storeAbstractDevices.proxy = new Ext.data.HttpProxy({
            url: '/json/getAbstractDevices/96/240'
        });
        storeAbstractDevices.load();
    }
    if (confObj && confObj.shutter) {
        storeAbstractDevices.proxy = new Ext.data.HttpProxy({
            url: '/json/getAbstractDevices/192/0'
        });
        storeAbstractDevices.load();
    }
    this.fieldLabel = 'Type';
    if (confObj && confObj.label) {
        this.fieldLabel = confObj.label;
    }
    if (confObj && confObj.name) {
        this.name = confObj.name;
        this.hiddenName = confObj.name;
    }
    this.valueField = 'id';
    this.displayField = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a device...';
    this.selectOnFocus = true;
    this.width = 200;
    this.editable = false;
    HAP.ComboAbstractDevices.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboAbstractDevices, Ext.form.ComboBox, {});

HAP.ComboLogicalInputTemplates = function(url){
    this.id = url + '/comboLogicalInputTemplates';
    this.store = storeLogicalInputTemplates;
    this.fieldLabel = 'Template';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'type';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a template...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = true;
    HAP.ComboLogicalInputTemplates.superclass.constructor.call(this);
    
    this.on('select', function(){
        Ext.getCmp(url).load({
            url: 'logicalinput/getCheckedCheckboxes/' + this.value,
            method: 'GET',
            success: function(form, action){
                // Ext.getCmp(url).setTitle(action.result.data.name)
            }
        });
    });
}
Ext.extend(HAP.ComboLogicalInputTemplates, Ext.form.ComboBox, {});

HAP.ComboNotify = function(url){
    this.id = url + 'comboNotify';
    this.store = storeNotifyModules;
    this.fieldLabel = 'Notify';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'notify';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a module...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    storeModules.clearFilter();
    HAP.ComboNotify.superclass.constructor.call(this);
    
}

Ext.extend(HAP.ComboNotify, Ext.form.ComboBox, {});

HAP.ComboUpstreamModules = function(url){
    this.id = url + 'comboUpstreamModule';
    this.store = storeUpstreamModules;
    this.fieldLabel = 'Upstream Module';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'upstreammodule';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a module...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    storeModules.clearFilter();
    HAP.ComboUpstreamModules.superclass.constructor.call(this);
    
}

Ext.extend(HAP.ComboUpstreamModules, Ext.form.ComboBox, {});

HAP.ComboModuleAddress = function(url){
    this.id = url + '/comboModuleAddress';
    this.store = storeFreeModuleAddresses;
    this.fieldLabel = 'Module Address';
    this.valueField = 'address';
    this.displayField = 'address';
    this.hiddenName = 'address';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select an address...';
    this.forceSelection = true;
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboModuleAddress.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboModuleAddress, Ext.form.ComboBox, {});

HAP.ComboStartMode = function(url){
    this.id = url + '/comboStartMode';
    this.store = storeStartModes;
    this.fieldLabel = 'Startmode';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'startmode';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select an startmode...';
    this.forceSelection = true;
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboStartMode.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboStartMode, Ext.form.ComboBox, {});

HAP.ComboFirmware = function(url){
    this.id = url + '/comboFirmware';
    this.tabIndex = 99;
    this.store = storeFirmware;
    this.fieldLabel = 'Firmware';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'firmwareid';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a firmware...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboFirmware.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboFirmware, Ext.form.ComboBox, {});

HAP.ComboSchedulerCommands = function(url){
    this.id = url + '/comboSchedulerCommands';
    this.store = storeSchedulerCommands;
    this.fieldLabel = 'Scheduler Commands';
    this.valueField = 'name';
    this.displayField = 'name';
    this.hiddenName = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a command...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboFirmware.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboSchedulerCommands, Ext.form.ComboBox, {});

HAP.ComboGuiViews = function(url){
    this.id = url + '/comboGuiViews';
    this.store = storeGuiViews;
    this.fieldLabel = 'View';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'viewId';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a view...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboGuiViews.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboGuiViews, Ext.form.ComboBox, {});

HAP.ButtonKeyPad = function(url, confObj){
    this.id = url + '/' + confObj.key;
    this.style = {
        left: confObj.x,
        top: confObj.y
    };
//    this.x = confObj.x;
//    this.y = confObj.y;
    this.minWidth = 30;
    if (confObj && confObj.minWidth) {
        this.minWidth = confObj.minWidth;
    }
    this.text = confObj.label;
    this.handler = function(){
        comboModule = Ext.getCmp(url + '/comboModule');
        if (comboModule.value) {
            Ext.getCmp(url).load({
                url: url.split('/')[0] + '/learn/' + confObj.key,
                method: 'POST',
                params: {
                    rcId: url.split('/')[1],
                    module: Ext.getCmp(url + '/comboModule').value,
                    room: Ext.getCmp(url + '/comboRoom').value
                },
                waitMsg: 'Press the desired Key on your Remote-Control now!',
                success: function(form, action){
                    if (action.result.data.keyName != null) { //keyName is set, if called from Remote-Control-Panel and not from the learned-Key-Panel
                        Ext.getCmp('treeDevice').addIRCode(url, 'remotecontrollearned', action.result.data.keyName, action.result.data.id);
                        Ext.getCmp('treeModule').addIRCode(url, 'remotecontrollearned', action.result.data.keyName, action.result.data.id);
                        Ext.getCmp('treeRoom').addIRCode(url, 'remotecontrollearned', action.result.data.keyName, action.result.data.id);
                    }
                },
                failure: function(form, action){
                    Ext.MessageBox.show({
                        title: 'Warning',
                        msg: action.result.info,
                        buttons: Ext.Msg.OK,
                        icon: Ext.MessageBox.INFO
                    });
                    
                }
            });
        }
        else {
            Ext.MessageBox.show({
                title: 'Warning',
                msg: 'No module selected!',
                buttons: Ext.Msg.OK,
                icon: Ext.MessageBox.INFO
            });
        }
    };
    HAP.ButtonKeyPad.superclass.constructor.call(this);
}

Ext.extend(HAP.ButtonKeyPad, Ext.Button, {});

HAP.ComboASInputValueTemplates = function(){
    this.store = storeASInputValueTemplates;
    this.fieldLabel = 'Template';
    this.valueField = 'type';
    this.displayField = 'name';
    this.hiddenName = 'type';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a template...';
    this.selectOnFocus = true;
    this.width = 200;
    this.editable = false;
    this.allowBlank = true;
    this.listeners = {
        'select': function(){
					Ext.getCmp('simValue').setValue(this.getValue());
        }
    };
    HAP.ComboASInputValueTemplates.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboASInputValueTemplates, Ext.form.ComboBox, {});


var changeAddressAndPortPin = function(url, module){
    if (Ext.getCmp(url + '/comboAddress')) {
        Ext.getCmp(url + '/comboAddress').reset();
        storeAddresses.proxy = new Ext.data.HttpProxy({
            url: '/json/getAddresses/' + module
        });
        storeAddresses.load();
    }
    if (Ext.getCmp(url + '/comboPortPin')) {
        Ext.getCmp(url + '/comboPortPin').reset();
        storePortPins.proxy = new Ext.data.HttpProxy({
            url: '/json/getPortPins/' + module
        });
        storePortPins.load();
    }
}

var loadAddressAndPortPin = function(module, currentAddress, currentPortPin){
    if (module != '' && currentAddress != '') {
        storeAddresses.proxy = new Ext.data.HttpProxy({
            url: '/json/getAddresses/' + module + '/' + currentAddress
        });
        storeAddresses.load();
    }
    if (module != '' && currentPortPin != '') {
        storePortPins.proxy = new Ext.data.HttpProxy({
            url: '/json/getPortPins/' + module + '/' + currentPortPin
        });
        storePortPins.load();
    }
}

var saveButtonClicked = function(url, formPanel, params){
    var target = url.split('/');
    formPanel.form.submit({
        url: target[0] + '/submit/' + target[1],
        params: params,
        success: function(fp, action){
            //log.addEntry('hapConfig', 'Info', 'Saved changes:' + url +
            //' - Server response: ' +
            //action.result.info);
            
            formPanel.target = target[0] + '/' + action.result.data.id;
            Ext.getCmp(url).setTitle(action.result.data.name);
            
            if (target[0] == 'macro' && target[1] == 0) {
                Ext.getCmp('treeMacro').addHapNode(url, null, action.result.data.name, action.result.data.id);
            }
            else 
                if (target[0] == 'macro' && target[1] != 0) {
                    Ext.getCmp('treeMacro').updateHapNode(url, action.result.data.name);
                }
                else 
                    if (target[1] == 0) {
                        Ext.getCmp('treeDevice').addHapNode(url, null, action.result.data.name, action.result.data.id);
                        Ext.getCmp('treeModule').addHapNode(url, null, action.result.data.name, action.result.data.id);
                        Ext.getCmp('treeRoom').addHapNode(url, null, action.result.data.name, action.result.data.id);
                        Ext.getCmp('treeGUI').addHapNode(url, null, action.result.data.name, action.result.data.id);
                    }
                    else {
                        Ext.getCmp('treeDevice').updateHapNode(url, action.result.data.name);
                        Ext.getCmp('treeModule').updateHapNode(url, action.result.data.name);
                        Ext.getCmp('treeRoom').updateHapNode(url, action.result.data.name);
                        Ext.getCmp('treeGUI').updateHapNode(url, action.result.data.name);
                    }
            // update stores
            switch (target[0]) {
                case 'module':
                    storeModules.load();
                    storeNotifyModules.load();
                    storeUpstreamModules.load();
                    break;
                case 'device':
                    storeDevices.load();
                    break;
                case 'logicalinput':
                    storeLogicalInputs.load();
                    storeLogicalInputs1.load();
                    break;
                case 'abstractdevice':
                    storeAbstractDevices.load();
                    break;
                case 'room':
                    storeRooms.load();
                    break;
                case 'guiview':
                    storeGuiViews.load();
                    break;
                case 'guiscene':
                    storeGuiScenes.load();
                    break;
                case 'macro':
                    storeMacros.load();
                    break;
            };
            if (target[0] == 'macro') {
                Ext.getCmp('center-panel-macro').remove(url);
                Ext.getCmp('center-panel-macro').doLayout();
            }
            else {
                Ext.getCmp('center-panel').remove(url);
                Ext.getCmp('center-panel').doLayout();
            }
        },
        failure: function(fp, action){
            if (action.result && action.result.sessionexpired) {
                Ext.MessageBox.show({
                    title: 'Warning',
                    msg: 'Session expired ! Please Reload this Page (F5)',
                    buttons: Ext.Msg.OK
                });
            }
            else 
                if (action.result && action.result.permissiondenied) {
                    var loginWindow = new HAP.LoginWindow();
                    loginWindow.show();
                }
                else {
                    var msg = 'Data processing failed.';
                    if (action.result) {
                        msg = 'Data processing failed.<br>Response:' + action.result.data;
                    }
                    Ext.MessageBox.show({
                        title: 'Warning',
                        msg: msg,
                        buttons: Ext.Msg.OK
                    });
                }
        }
    });
}

var deleteButtonClicked = function(url, formPanel){
    var target = url.split('/');
    if (target[0] == 'macro' && target[1] == 0) {
        Ext.getCmp('center-panel-macro').remove(url);
        Ext.getCmp('center-panel-macro').doLayout();
        return;
    }
    if (target[1] == 0) {
        Ext.getCmp('center-panel').remove(url);
        Ext.getCmp('center-panel').doLayout();
        return;
    }
    HAP.deleteObject(url);
}

HAP.deleteObject = function(url){
    var target = url.split('/');
    if (target[1] == 0) {
        return;
    }
    Ext.MessageBox.show({
        title: 'Warning',
        msg: 'Are you sure that you want to delete this item?',
        buttons: Ext.Msg.YESNO,
        icon: Ext.MessageBox.QUESTION,
        fn: function(btn, txt){
            if (btn == 'yes') {
                Ext.Ajax.request({
                    url: target[0] + '/delete/' + target[1],
                    params: {
                        id: target[1]
                    },
                    callback: function(options, success, response){
                        var r = Ext.decode(response.responseText);
                        if (r.success) {
                            switch (target[0]) {
                                case 'module':
                                    storeModules.load();
                                    storeNotifyModules.load();
                                    storeUpstreamModules.load();
                                    break;
                                case 'device':
                                    storeDevices.load();
                                    break;
                                case 'logicalinput':
                                    storeLogicalInputs.load();
                                    storeLogicalInputs1.load();
                                    break;
                                case 'abstractdevice':
                                    storeAbstractDevices.load();
                                    break;
                                case 'room':
                                    storeRooms.load();
                                    break;
                                case 'guiview':
                                    storeGuiViews.load();
                                    break;
                                case 'guiscene':
                                    storeGuiViews.load();
                                    break;
                                case 'macro':
                                    storeMacros.load();
                                    break;
                            };
                            if (target[0] == 'macro') {
                                Ext.getCmp('treeMacro').removeHapNode(url);
                                Ext.getCmp('center-panel-macro').remove(url);
                                Ext.getCmp('center-panel-macro').doLayout();
                            }
                            else {
                                Ext.getCmp('treeDevice').removeHapNode(url);
                                Ext.getCmp('treeModule').removeHapNode(url);
                                Ext.getCmp('treeRoom').removeHapNode(url);
                                Ext.getCmp('treeGUI').removeHapNode(url);
                                Ext.getCmp('center-panel').remove(url);
                                Ext.getCmp('center-panel').doLayout();
                            }
                        }
                        else {
                            if (r.sessionexpired) {
                                Ext.MessageBox.show({
                                    title: 'Warning',
                                    msg: 'Session expired ! Please Reload this Page (F5)',
                                    buttons: Ext.Msg.OK
                                });
                            }
                            else 
                                if (r.permissiondenied) {
                                    var loginWindow = new HAP.LoginWindow();
                                    loginWindow.show();
                                }
                                else {
                                    Ext.MessageBox.show({
                                        title: 'Warning',
                                        msg: 'Database-Action failed:' + r.info,
                                        buttons: Ext.Msg.OK
                                    });
                                }
                        }
                    }
                });
                
            }
        }
    });
}
HAP.ManageConfigWindow = function(item){

    storeConfig.load();
    
    var sm = new Ext.grid.CheckboxSelectionModel({});
    
    var checkColumnDefaultConfig = new Ext.grid.CheckColumn({
        header: 'Default',
        singleSelect: true, // own extension, not in Extjs
        dataIndex: 'isdefault',
        inputValue: 1,
        width: 75
    });
    
    var cm = new Ext.grid.ColumnModel([sm, {
        id: 'name',
        header: 'Name',
        dataIndex: 'name',
        sortable: true,
        width: 350,
        editor: new Ext.form.TextField({
            allowBlank: false
        })
    }, checkColumnDefaultConfig]);
    
    var newConfig = Ext.data.Record.create([{
        name: 'name',
        type: 'string'
    }, {
        name: 'id'
    }, {
        name: 'default'
    }]);
    
    var grid = new Ext.grid.EditorGridPanel({
        store: storeConfig,
        cm: cm,
        height: 300,
        autoExpandColumn: 'name',
        plugins: [checkColumnDefaultConfig],
        frame: false,
        sm: sm,
        viewConfig: {
            forceFit: true
        }
    });
    
    function saveChanges(){
        //var mr = storeConfig.getModifiedRecords();
				var mr = storeConfig.getRange(0, storeConfig.getCount());
        if (mr.length > 0) {
            var data = new Array;
            for (var index in mr) {
                data.push(mr[index].data);
            }
            var conn = new Ext.data.Connection();
            conn.request({
                method: 'POST',
                url: '/manageconfigs/setConfigs',
                params: {
                    data: Ext.util.JSON.encode(data)
                }
            });
            conn.on('requestcomplete', function(sender, param){
                var response = Ext.util.JSON.decode(param.responseText);
                if (response.permissiondenied) {
                    var loginWindow = new HAP.LoginWindow();
                    loginWindow.show();
                }
                else 
                    if (response.success) {
                        storeConfig.reload({
                            save: true
                        });
                    }
                    else {
                        Ext.MessageBox.alert('Warning', response.info);
                    }
            }, {
                scope: this
            });
        }
    }
    
    function addConfig(){
        grid.stopEditing();
        var c = new newConfig({
            name: '',
            id: 0
        });
        storeConfig.insert(0, c);
        grid.getSelectionModel().selectRow(0);
        grid.startEditing(0, 1);
    }
    
    function deleteConfig(){
        Ext.MessageBox.show({
            title: 'Warning',
            msg: 'Are you sure that you want to delete this configuration?',
            buttons: Ext.Msg.YESNO,
            icon: Ext.MessageBox.QUESTION,
            fn: function(btn, txt){
                if (btn == 'yes') {
                    var sel = grid.getSelectionModel().getSelections();
                    var data = new Array;
                    for (var index in sel) {
                        data.push(sel[index].data);
                    }
                    var conn = new Ext.data.Connection();
                    conn.request({
                        method: 'POST',
                        url: '/manageconfigs/delConfigs',
                        params: {
                            data: Ext.util.JSON.encode(data)
                        }
                    });
                    conn.on('requestcomplete', function(sender, param){
                        var response = Ext.util.JSON.decode(param.responseText);
                        if (response.permissiondenied) {
                            var loginWindow = new HAP.LoginWindow();
                            loginWindow.show();
                        }
                        else 
                            if (response.success) {
                                storeConfig.reload();
                            }
                            else {
                                Ext.MessageBox.alert('Warning', response.info);
                            }
                    }, {
                        scope: this
                    });
                }
            }
        })
    }
    
    function selectConfig(){
        if (grid.getSelectionModel().getSelected() == null) {
            Ext.MessageBox.alert('Warning', 'No config selected');
            return;
        }
        if (grid.getSelectionModel().getCount() > 1) {
            Ext.MessageBox.alert('Warning', 'You cant select multiple Configs');
            return;
        }
        if (grid.getSelectionModel().getSelected().data.id == 0) {
            Ext.MessageBox.alert('Warning', 'Please save the changes first!');
            return;
        }
        Ext.getCmp('currentConfig').setText(grid.getSelectionModel().getSelected().data.name);
        var conn = new Ext.data.Connection();
        conn.request({
            url: '/manageconfigs/selectConfig/' + grid.getSelectionModel().getSelected().data.id,
            success: function(){
                Ext.getCmp('treeDevice').getRootNode().reload();
                Ext.getCmp('treeModule').getRootNode().reload();
                Ext.getCmp('treeRoom').getRootNode().reload();
                Ext.getCmp('treeGUI').getRootNode().reload();
                loadStores();
                win.hide();
                win.destroy();
            }
        });
    }
    
    var win = new Ext.Window({
        title: 'Manage/Select Config',
        iconCls: 'config',
        modal: true,
        closable: true,
        width: 350,
        height: 350,
        autoScroll: true,
        close: selectConfig,
        layout: 'fit', // important -> tells sub-components to fit (showing scrollbars correctly)
        items: [grid],
        tbar: [{
            text: 'Select',
            handler: selectConfig,
            iconCls: 'ok'
        }, '-', {
            text: 'Save Changes',
            handler: saveChanges,
            iconCls: 'save'
        }, '-', {
            text: 'Add',
            handler: addConfig,
            iconCls: 'add'
        }, '-', {
            text: 'Delete',
            handler: deleteConfig,
            iconCls: 'delete'
        }]
    });
    
    
    win.show(this);
    
    // mark current config
    storeConfig.on('load', function(){
        if (storeConfig.lastOptions.save != true) {
            var selRecords = new Array();
            selRecords[0] = storeConfig.getById(storeConfig.reader.jsonData.currentConfig);
            sm.selectRecords(selRecords);
        }
    })
}
HAP.ManageModulesWindow = function(item){

    storeModuleProps.load();
    
    var sm = new Ext.grid.CheckboxSelectionModel({
        singleSelect: false
    });
    
    var checkColumnFullConfig = new Ext.grid.CheckColumn({
        header: 'Push Config',
        dataIndex: 'devoption/4',
        inputValue: 4,
        width: 75
    });
    
    var checkColumnWireless = new Ext.grid.CheckColumn({
        header: 'Via Wireless',
        dataIndex: 'devoption/2',
        inputValue: 2,
        width: 85
    });
    
    var checkColumnLcd = new Ext.grid.CheckColumn({
        header: 'Push LCD',
        dataIndex: 'devoption/1',
        inputValue: 1,
        width: 75
    });
    
    var cm = new Ext.grid.ColumnModel([sm, {
        id: 'manageModulesName',
        header: 'Name',
        dataIndex: 'name',
        sortable: true,
        width: 230,
        editor: new Ext.form.TextField({
            allowBlank: false
        })
    }, checkColumnFullConfig, checkColumnLcd, checkColumnWireless, {
        id: 'manageModulesFirmware',
        header: 'Firmware',
        dataIndex: 'firmwareid',
        sortable: true,
        width: 200,
        editor: new HAP.ComboFirmware({}),
        renderer: function(data){
            record = storeFirmware.getById(data);
            if (record) {
                return record.data.name;
            }
            else {
                return data;
            }
        }
    }]);
    
    var grid = new Ext.grid.EditorGridPanel({
        ds: storeModuleProps,
        cm: cm,
        width: 665,
        autoHeight: true,
        autoExpandColumn: 'name',
        frame: false,
        sm: sm,
        plugins: [checkColumnFullConfig, checkColumnWireless, checkColumnLcd],
        clicksToEdit: 1,
        viewConfig: {
            forceFit: true
        },
        tbar: [{
            text: 'Save Changes',
            handler: saveChanges,
            iconCls: 'save'
        }, '-', {
            text: 'Run Task',
            handler: pushConfig,
            iconCls: 'go'
        }, '-', {
            text: 'Flash',
            handler: flash,
            iconCls: 'flash'
        }, '-', {
            text: 'Reset',
            handler: reset,
            iconCls: 'reset'
        }]
    });
    
    function saveChanges(){
        var mr = storeModuleProps.getModifiedRecords();
        var data = new Array;
        for (var index in mr) {
            data.push(mr[index].data);
        }
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'POST',
            url: '/managemodules/setModules',
            params: {
                data: Ext.util.JSON.encode(data)
            }
        });
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.util.JSON.decode(param.responseText);
            if (response.permissiondenied) {
                var loginWindow = new HAP.LoginWindow();
                loginWindow.show();
            }
            else 
                if (response.success) {
                    storeModuleProps.commitChanges();
                    for (var i in response.data) {
                        Ext.getCmp('treeModule').updateHapNode(response.data[i].url, response.data[i].name);
                        Ext.getCmp('treeRoom').updateHapNode(response.data[i].url, response.data[i].name);
                    }
                    storeModules.reload();
                }
        }, {
            scope: this
        });
    }
    
    function pushConfig(){
        saveChanges();
        if (grid.getSelectionModel().getSelected() == null) {
            Ext.MessageBox.alert('Warning', 'No module selected');
            return;
        }
        var sel = grid.getSelectionModel().getSelections();
        var data = new Array;
        for (var index in sel) {
            data.push(sel[index].data);
        }
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'POST',
            url: '/managemodules/pushConfig',
            params: {
                data: Ext.util.JSON.encode(data)
            }
        });
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.decode(param.responseText);
            if (response.permissiondenied) {
                var loginWindow = new HAP.LoginWindow();
                loginWindow.show();
            }
            else 
                if (response.success) {
                    storeModuleProps.commitChanges();
                    win.hide();
                    win.destroy();
                    HAP.ManageSchedulerWindow();
                    Ext.getCmp('schedulerLiveMonitorButton').toggle(true);
                    Ext.getCmp('logLiveMonitorButton').toggle(true);
                }
                else {
                    Ext.MessageBox.alert('Warning', response.info);
                }
        }, {
            scope: this
        });
    }
    
    function flash(){
        saveChanges();
        if (grid.getSelectionModel().getSelected() == null) {
            Ext.MessageBox.alert('Warning', 'No module selected');
            return;
        }
        Ext.MessageBox.show({
            title: 'Warning',
            msg: 'Are you sure that you want start the flash-process?',
            buttons: Ext.Msg.YESNO,
            icon: Ext.MessageBox.QUESTION,
            fn: function(btn, txt){
                if (btn == 'yes') {
                    var sel = grid.getSelectionModel().getSelections();
                    var data = new Array;
                    for (var index in sel) {
                        data.push(sel[index].data);
                    }
                    var conn = new Ext.data.Connection();
                    conn.request({
                        method: 'POST',
                        url: '/managemodules/flashFirmware',
                        params: {
                            data: Ext.util.JSON.encode(data)
                        }
                    });
                    conn.on('requestcomplete', function(sender, param){
                        var response = Ext.util.JSON.decode(param.responseText);
                        if (response.permissiondenied) {
                            var loginWindow = new HAP.LoginWindow();
                            loginWindow.show();
                        }
                        else 
                            if (response.success) {
                                storeModuleProps.commitChanges();
                                win.hide();
                                win.destroy();
                                HAP.ManageSchedulerWindow();
                                Ext.getCmp('schedulerLiveMonitorButton').toggle(true);
                                Ext.getCmp('logLiveMonitorButton').toggle(true);
                            }
                            else {
                                Ext.MessageBox.alert('Warning', response.info);
                            }
                    }, {
                        scope: this
                    });
                }
            }
        })
    }
    
    function reset(){
        if (grid.getSelectionModel().getSelected() == null) {
            Ext.MessageBox.alert('Warning', 'No module selected');
            return;
        }
        var sel = grid.getSelectionModel().getSelections();
        var data = new Array;
        for (var index in sel) {
            data.push(sel[index].data);
        }
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'POST',
            url: '/managemodules/resetModules',
            params: {
                data: Ext.util.JSON.encode(data)
            }
        });
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.util.JSON.decode(param.responseText);
            if (response.permissiondenied) {
                var loginWindow = new HAP.LoginWindow();
                loginWindow.show();
            }
            else 
                if (response.success) {
                    storeModuleProps.commitChanges();
                    win.hide();
                    win.destroy();
                    HAP.ManageSchedulerWindow();
                    Ext.getCmp('schedulerLiveMonitorButton').toggle(true);
                    Ext.getCmp('logLiveMonitorButton').toggle(true);
                }
                else {
                    Ext.MessageBox.alert('Warning', response.info);
                }
        }, {
            scope: this
        });
    }
    
    var win = new Ext.Window({
        title: 'Manage Modules',
        iconCls: 'module',
        closable: true,
        width: 680,
        autoHeight: true,
        autoScroll: true,
        items: [grid]
    });
    win.show(this);
    
}

HAP.ManageMacrosWindow = function(item){
        
    var tabPanel = new Ext.TabPanel({
        region: 'center',
         margins:'3 3 3 0', 
        //layoutOnTabChange : true,
        id: 'center-panel-macro',
        enableTabScroll: true,
        deferredRender: false,
        activeTab: 0
    })
    
    var win = new Ext.Window({
        title: 'Manage Macros',
        layout: 'border',
        iconCls: 'macro',
        closable: true,
        //resizable: false,
        width: 800,
        height: 550,
        items: [new HAP.TreeMacro(), tabPanel]
    });
    win.show(this);
   
}

HAP.ManageFirmwareWindow = function(id){

    storeFirmware.load();
    
    var sm = new Ext.grid.CheckboxSelectionModel({
        singleSelect: false
    });
    
    var checkColumnPreCompiled = new Ext.grid.CheckColumn({
        header: 'Pre-Compiled',
        dataIndex: 'precompiled',
        inputValue: 1,
        width: 75
    });
    
    var cm = new Ext.grid.ColumnModel([sm, {
        header: 'Name',
        dataIndex: 'name',
        sortable: true,
        width: 200,
        editor: new Ext.form.TextField({
            allowBlank: false
        })
    }, checkColumnPreCompiled, {
        header: 'Version',
        dataIndex: 'version',
        sortable: true,
        width: 60
    }, {
        header: 'Date',
        dataIndex: 'date',
        sortable: true,
        width: 60
    }, {
        header: 'Filename',
        dataIndex: 'filename',
        sortable: true,
        width: 160
    }]);
    
    var newConfig = Ext.data.Record.create([{
        name: 'name',
        type: 'string'
    }, {
        name: 'id'
    }]);
    
    var grid = new Ext.grid.EditorGridPanel({
        store: storeFirmware,
        cm: cm,
        width: 565,
        autoWidth: true,
        autoHeight: true,
        autoExpandColumn: 'name',
        frame: false,
        sm: sm,
        plugins: [checkColumnPreCompiled],
        viewConfig: {
            forceFit: true
        },
        tbar: [{
            text: 'Save Changes',
            handler: saveChanges,
            iconCls: 'save'
        }, '-', {
            text: 'Add',
            handler: addFirmware,
            iconCls: 'add'
        }, '-', {
            text: 'Delete',
            handler: deleteFirmware,
            iconCls: 'delete'
        }]
    });
    
    function saveChanges(){
        var mr = storeFirmware.getModifiedRecords();
        if (mr.length > 0) {
            var data = new Array;
            for (var index in mr) {
                data.push(mr[index].data);
            }
            var conn = new Ext.data.Connection();
            conn.request({
                method: 'POST',
                url: '/managefirmware/setFirmware',
                params: {
                    data: Ext.util.JSON.encode(data)
                }
            });
            conn.on('requestcomplete', function(sender, param){
                var response = Ext.util.JSON.decode(param.responseText);
                if (response.success) {
                    storeFirmware.reload();
                }
                else {
                    Ext.MessageBox.alert('Warning', response.info);
                }
            }, {
                scope: this
            });
        }
    }
    
    function addFirmware(){
        HAP.UploadFileWindow();
    }
    
    function deleteFirmware(){
        Ext.MessageBox.show({
            title: 'Warning',
            msg: 'Are you sure that you want to remove the selected firmware(s)?',
            buttons: Ext.Msg.YESNO,
            icon: Ext.MessageBox.QUESTION,
            fn: function(btn, txt){
                if (btn == 'yes') {
                    var sel = grid.getSelectionModel().getSelections();
                    var data = new Array;
                    for (var index in sel) {
                        data.push(sel[index].data);
                    }
                    var conn = new Ext.data.Connection();
                    conn.request({
                        method: 'POST',
                        url: '/managefirmware/delFirmware',
                        params: {
                            data: Ext.util.JSON.encode(data)
                        }
                    });
                    conn.on('requestcomplete', function(sender, param){
                        var response = Ext.decode(param.responseText);
                        if (response.success) {
                            storeFirmware.reload();
                        }
                        else {
                            Ext.MessageBox.alert('Warning', response.info);
                        }
                    }, {
                        scope: this
                    });
                }
            }
        })
    }
    
    var win = new Ext.Window({
        title: 'Firmware Repository',
        iconCls: 'firmwareRepository',
        closable: true,
        width: 585,
        autoScroll: true,
        items: [grid]
    });
    
    win.show(this);
    
    // mark uploaded firmware (lastOptions.parms get set when upload finished - see HAP.UploadFileWindow)
    storeFirmware.on('load', function(){
        if (storeFirmware.lastOptions.parms) {
            var selRecords = grid.getSelectionModel().getSelections();
            selRecords.push(storeFirmware.getById(storeFirmware.lastOptions.parms.firmwareid));
            sm.selectRecords(selRecords);
        }
    })
    
}
HAP.ManageSchedulerWindow = function(item){

    storeSchedules.load();
    
    var sm = new Ext.grid.CheckboxSelectionModel({
        singleSelect: false
    });
    
    var newSchedule = Ext.data.Record.create([{
        name: 'cron',
        type: 'string'
    }, {
        name: 'cmd'
    }, {
        name: 'args'
    },{
        name: 'description'
    }, {
        name: 'status'
    }]);
    
    var cm = new Ext.grid.ColumnModel([sm, {
        id: 'manageSchedulerCron',
        header: 'Cron',
        dataIndex: 'cron',
        sortable: true,
        editor: new Ext.form.TextField({
            allowBlank: false
        })
    }, {
        id: 'manageSchedulerCmd',
        header: 'Command',
        dataIndex: 'cmd',
        sortable: true,
        editor: new HAP.ComboSchedulerCommands({})
    }, {
        id: 'manageSchedulerArgs',
        header: 'Arguments',
        dataIndex: 'args',
        sortable: true,
        width: 200,
        editor: new Ext.form.TextField({
            allowBlank: true
        })
    },{
        id: 'manageSchedulerDescription',
        header: 'Description',
        dataIndex: 'description',
        width: 100,
        sortable: true,
        editor: new Ext.form.TextField({
            allowBlank: true
        })
    }, {
        id: 'manageSchedulerStatus',
        header: 'Status',
        dataIndex: 'status',
        width: 60,
        sortable: true
    }]);
    
    var grid = new Ext.grid.EditorGridPanel({
        ds: storeSchedules,
        cm: cm,
        width: 700,
        autoWidth: true,
        autoHeight: true,
        autoExpandColumn: 'cron',
        frame: false,
        sm: sm,
        clicksToEdit: 1,
        viewConfig: {
            forceFit: true
        },
        tbar: [{
            text: 'Save Changes',
            handler: saveChanges,
            iconCls: 'save'
        }, '-', {
            text: 'Add',
            handler: addSchedule,
            iconCls: 'add'
        }, '-', {
            text: 'Delete',
            handler: deleteSchedule,
            iconCls: 'delete'
        }, '-', {
            id: 'schedulerLiveMonitorButton',
            enableToggle: true,
            text: 'Start Live Monitoring',
            iconCls: 'start',
            toggleHandler: toggleMonitoring
        
        }]
    });
    
    function saveChanges(){
        var mr = storeSchedules.getModifiedRecords();
        if (mr.length > 0) {
            var data = new Array;
            for (var index in mr) {
                data.push(mr[index].data);
            }
            var conn = new Ext.data.Connection();
            conn.request({
                method: 'POST',
                url: '/managescheduler/setSchedules',
                params: {
                    data: Ext.util.JSON.encode(data)
                }
            });
            conn.on('requestcomplete', function(sender, param){
                var response = Ext.util.JSON.decode(param.responseText);
                if (response.permissiondenied) {
                  var loginWindow = new HAP.LoginWindow();
                  loginWindow.show();
                }
                else {
                  if (response.success) {
                    storeSchedules.reload();
                  }
                  else {
                    Ext.MessageBox.alert('Warning', response.info);
                  }
                }
            }, {
                scope: this
            });
        }
    }
    
    function addSchedule(){
        grid.stopEditing();
        var c = new newSchedule({
            cron: '',
            cmd: '',
            args: '',
			description: '',
            id: 0
        });
        storeSchedules.insert(0, c);
        grid.getSelectionModel().selectRow(0);
        grid.startEditing(0, 1);
    }
    
    function deleteSchedule(){
        var sel = grid.getSelectionModel().getSelections();
        var data = new Array;
        for (var index in sel) {
            data.push(sel[index].data);
        }
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'POST',
            url: '/managescheduler/delSchedules',
            params: {
                data: Ext.util.JSON.encode(data)
            }
        });
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.util.JSON.decode(param.responseText);
            if (response.permissiondenied) {
              var loginWindow = new HAP.LoginWindow();
              loginWindow.show();
            }
            else {
              if (response.success) {
                storeSchedules.reload();
              }
              else {
                Ext.MessageBox.alert('Warning', response.info);
              }
            }
        }, {
            scope: this
        });
    }
    
    function stopSpeedLog(){
        Ext.getCmp('schedulerLiveMonitorButton').toggle(false);
        Ext.getCmp('logLiveMonitorButton').toggle(false);
        win.hide();
        win.destroy();
    }
    
    function toggleMonitoring(button, state){
        if (state) {
            Ext.TaskMgr.start(taskSpeedSchedulerUpdate);
            button.setText('Stop Live Monitoring');
            button.setIconClass('stop');
            Ext.getCmp('logLiveMonitorButton').toggle(true);
        }
        else {
            Ext.TaskMgr.stop(taskSpeedSchedulerUpdate);
            button.setText('Start Live Monitoring');
            button.setIconClass('start');
            Ext.getCmp('logLiveMonitorButton').toggle(false);
            storeSchedules.reload({
                params: {}
            });
        }
    }
    
    var win = new Ext.Window({
        title: 'Manage Scheduler',
        closable: true,
        iconCls: 'scheduler',
        width: 715,
        autoHeight: true,
        autoScroll: true,
        close: stopSpeedLog,
        items: [grid]
    });
    win.show(this);
};

//////////////////////////////////////////////////
// Tree
//////////////////////////////////////////////////

HAP.TreeChartProp = function(chartDisplayObj){
    this.chartDisplayObj = chartDisplayObj;
    this.id = 'treeChartProp';
    this.title = 'Chart Properties';
    this.region = 'west';
    this.width = 175;
    this.split = true;
    this.autoScroll = true;
    this.margins = '3 0 3 3';
    this.cmargins = '3 3 3 3';
    this.animate = true;
    this.rootVisible = true;
    this.root = new Ext.tree.AsyncTreeNode({
        loader: new HAP.ChartTreeLoader({
            chart: chartDisplayObj.chart
        }),
        text: 'Chart',
        cObj: this.chartDisplayObj.chart,
        draggable: false,
        expanded: true,
        id: 'chart/0/root'
    });
    this.listeners = {
        'click': showProps,
        'contextmenu': this.contextMenuHandler
    };
    
    function showProps(node, event){
        Ext.getCmp('chartPropertyGrid').setSource(node.attributes.cObj);
    }
    
    HAP.TreeChartProp.superclass.constructor.call(this);
}

Ext.extend(HAP.TreeChartProp, Ext.tree.TreePanel, {
    contextMenuHandler: function(node, e){
        if (!this.menu) {
            this.menu = new HAP.TreeGraphContextMenu(node, e);
        }
        this.menu.setActiveNode(node);
        this.menu.showAt(e.getXY());
    }
});


//////////////////////////////////////////////////
// TREE LOADER
//////////////////////////////////////////////////

HAP.ChartTreeLoader = function(conf){
    this.conf = conf;
    HAP.ChartTreeLoader.superclass.constructor.call(this);
}
Ext.extend(HAP.ChartTreeLoader, Ext.tree.TreeLoader, {
    load: function(node, callback){
        for (obj in this.conf.chart) {
            if (typeof this.conf.chart[obj] != 'string' && typeof this.conf.chart[obj] != 'boolean') {
                var newNode = new Ext.tree.TreeNode({
                    text: obj,
                    cObj: this.conf.chart[obj],
                    leaf: false
                });
                node.appendChild(newNode);
                if (this.conf.chart[obj] instanceof Array) {
                    newNode.id = obj;
                    newNode.expanded = true;
                    var size = this.conf.chart[obj].length;
                    for (var z = 0; z < size; z++) {
                        newNode.appendChild(new Ext.tree.TreeNode({
                            text: this.conf.chart[obj][z]['HAP-Name'],
                            cObj: this.conf.chart[obj][z],
                            leaf: true
                        }))
                    }
                }
            }
        }
        callback();
    }
});


//////////////////////////////////////////////////
// CONTEXT MENU
//////////////////////////////////////////////////

HAP.TreeGraphContextMenu = function(node, event){
    this.id = 'treeGraphContextMenu';
    this.items = [{
        text: 'Add Bar',
        chartText: 'Bar',
        chartType: 'bar',
        iconCls: 'add',
        scope: this,
        handler: addChartObjectHandler
    }, {
        text: 'Add Pie',
        chartText: 'Pie',
        chartType: 'pie',
        iconCls: 'add',
        scope: this,
        handler: addChartObjectHandler
    }, {
        text: 'Add H-Bar',
        chartText: 'H-Bar',
        chartType: 'hbar',
        iconCls: 'add',
        scope: this,
        handler: addChartObjectHandler
    }, {
        text: 'Add Line',
        chartText: 'Line',
        chartType: 'line',
        iconCls: 'add',
        scope: this,
        handler: addChartObjectHandler
    }, {
        text: 'Add Line-Dot',
        chartText: 'Line-Dot',
        chartType: 'line_dot',
        iconCls: 'add',
        scope: this,
        handler: addChartObjectHandler
    }, {
        text: 'Add Line-Hollow',
        chartText: 'Line-Hollow',
        chartType: 'line_hollow',
        iconCls: 'add',
        scope: this,
        handler: addChartObjectHandler
    }, {
        text: 'Edit',
        iconCls: 'edit',
        scope: this,
        handler: function(){
            this.node.select();
            this.node.fireEvent('click', this.node);
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        scope: this,
        handler: function(){
            if (this.node.parentNode.text == 'elements') {
                var array = Ext.getCmp('treeChartProp').chartDisplayObj.chart.elements;
                var len = array.length;
                for (var i = 0; i < len; i++) {
                    if (array[i] == this.node.attributes.cObj) {
                        array.splice(i, 1);
                    }
                }
                this.node.remove();
            }
        }
    }];
    
    function addChartObjectHandler(menu, menuItem, event){
        var chartObj = apply({}, Ext.getCmp('treeChartProp').chartDisplayObj.templates[menu.chartType]);
        var newNode = new Ext.tree.TreeNode({
            text: menu.chartText,
            cObj: chartObj,
            leaf: false
        });
        Ext.getCmp('treeChartProp').chartDisplayObj.chart.elements.push(chartObj);
        Ext.getCmp('treeChartProp').getNodeById('elements').appendChild(newNode);
    }
    
    HAP.TreeGraphContextMenu.superclass.constructor.call(this);
}

Ext.extend(HAP.TreeGraphContextMenu, Ext.menu.Menu, {
    setActiveNode: function(node){
        this.node = node;
    }
});


//////////////////////////////////////////////////
// WIN
//////////////////////////////////////////////////

HAP.ChartPropWindow = function(treeObject, callback){
    this.callback = callback;
    this.title = 'Manage Chart Properties';
    this.layout = 'border';
    this.iconCls = 'macro';
    this.closable = true;
    this.width = 800;
    this.height = 550;
    this.items = [new HAP.TreeChartProp(treeObject), new HAP.GUIPropertyGrid({
        id: 'chartPropertyGrid'
    })];
    var oThis = this;
    this.listeners = {
        show: function(){
            oThis.setZIndex(10001); // firefox 3 fix
        }
    };
    HAP.ChartPropWindow.superclass.constructor.call(this);
}

Ext.extend(HAP.ChartPropWindow, Ext.Window, {});

//////////////////////////////////////////////////
// Tree
//////////////////////////////////////////////////

HAP.TreeChart5Prop = function(chartDisplayObj){
    this.chartDisplayObj = chartDisplayObj;
    this.id = 'treeChartProp';
    this.title = 'Chart Properties';
    this.region = 'west';
    this.width = 175;
    this.split = true;
    this.autoScroll = true;
    this.margins = '3 0 3 3';
    this.cmargins = '3 3 3 3';
    this.animate = true;
    this.rootVisible = true;
    this.root = new Ext.tree.AsyncTreeNode({
        loader: new HAP.Chart5TreeLoader({
            data: chartDisplayObj
        }),
        text: 'Chart',
        cObj: this.chartDisplayObj.chart,
        draggable: false,
        expanded: true,
        id: 'chart/0/root'
    });
    this.listeners = {
        'click': this.showProps,
        'contextmenu': this.contextMenuHandler
    };

    HAP.TreeChart5Prop.superclass.constructor.call(this);
}

Ext.extend(HAP.TreeChart5Prop, Ext.tree.TreePanel, {
    showProps: function(node, event) {
        Ext.getCmp('chartPropertyGrid').setSource(node.attributes.cObj);
    },
    contextMenuHandler: function(node, e){
        if (node.text == 'Data-Source' || node.parentNode.text == 'Data-Source') {
            if (!this.menu) {
                this.menu = new HAP.TreeChart5ContextMenu(node, e);
            }
            this.menu.setActiveNode(node);
            this.menu.showAt(e.getXY());
        }
    }
});


//////////////////////////////////////////////////
// TREE LOADER
//////////////////////////////////////////////////

HAP.Chart5TreeLoader = function(conf){
    this.conf = conf;
    HAP.Chart5TreeLoader.superclass.constructor.call(this);
}
Ext.extend(HAP.Chart5TreeLoader, Ext.tree.TreeLoader, {
    load: function(node, callback){
        var sourceNode = new Ext.tree.TreeNode({
            text: 'Data-Source',
            id: 'data-source',
            cObj: {},
            leaf: false,
            expanded: true
        });
        node.appendChild(sourceNode);
        var size = this.conf.data.dataSources.length;
        for (var z = 0; z < size; z++) {
            var newNode = new Ext.tree.TreeNode({
                text: this.conf.data.dataSources[z].Description,
                cObj: this.conf.data.dataSources[z],
                leaf: false
            });
            sourceNode.appendChild(newNode);
        }
        var propNode = new Ext.tree.TreeNode({
            text: 'Properties',
            cObj: {},
            leaf: false
        });
        node.appendChild(propNode);
        for (obj in this.conf.data.chart) {
            var newNode = new Ext.tree.TreeNode({
                text: obj,
                cObj: this.conf.data.chart[obj],
                leaf: true
            });
            propNode.appendChild(newNode);
        }
        callback();
    }
});


//////////////////////////////////////////////////
// CONTEXT MENU
//////////////////////////////////////////////////

HAP.TreeChart5ContextMenu = function(node, event){
    this.id = 'treeGraphContextMenu';
    this.items = [{
        text: 'Add Source',
        iconCls: 'add',
        scope: this,
        handler: addChart5ObjectHandler
    }, {
        text: 'Delete',
        iconCls: 'delete',
        scope: this,
        handler: function(){
            if (this.node.parentNode.text == 'Data-Source') {
                var array = Ext.getCmp('treeChartProp').chartDisplayObj.dataSources;
                var len = array.length;
                for (var i = 0; i < len; i++) {
                    if (array[i] == this.node.attributes.cObj) {
                        array.splice(i, 1);
                    }
                }
                this.node.remove();
            }
        }
    }];
    
    function addChart5ObjectHandler(menu, menuItem, event){
        var chartObj = apply({}, Ext.getCmp('treeChartProp').chartDisplayObj.sourceTemplate);
        var newNode = new Ext.tree.TreeNode({
            text: 'Source',
            cObj: chartObj,
            leaf: false
        });
        var tmp = Ext.getCmp('treeChartProp');
        Ext.getCmp('treeChartProp').chartDisplayObj.dataSources.push(chartObj);
        Ext.getCmp('treeChartProp').getNodeById('data-source').appendChild(newNode);
    }
    
    HAP.TreeChart5ContextMenu.superclass.constructor.call(this);
}

Ext.extend(HAP.TreeChart5ContextMenu, Ext.menu.Menu, {
    setActiveNode: function(node){
        this.node = node;
    }
});


//////////////////////////////////////////////////
// WIN
//////////////////////////////////////////////////

HAP.Chart5PropWindow = function(treeObject, callback){
    this.callback = callback;
    this.title = 'Manage Chart Properties';
    this.layout = 'border';
    this.iconCls = 'macro';
    this.closable = true;
    this.width = 800;
    this.height = 550;
    this.items = [new HAP.TreeChart5Prop(treeObject), new HAP.GUIPropertyGrid({
        id: 'chartPropertyGrid'
    })];
    var oThis = this;
    this.listeners = {
        show: function(){
            oThis.setZIndex(10001); // firefox 3 fix
        }
    };
    HAP.Chart5PropWindow.superclass.constructor.call(this);
}

Ext.extend(HAP.Chart5PropWindow, Ext.Window, {});
HAP.LoginWindow = function(){
    this.loginButtonHandler = function(){
        if (!this.loginForm.getForm().isValid()) {
            return;
        }
        var user = this.username.getValue();
        var pass = this.password.getValue();
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'POST',
            url: 'login/check',
            params: {
                user: user,
                pass: pass
            }
        });
        var oThis = this;
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.util.JSON.decode(param.responseText);
            if (response.success) {
                userRoles = response.roles;
                if (!Ext.getCmp('vp')) {
                    var viewport = new HAP.Viewport();
                    viewport.show();
					Ext.getCmp('currentUser').setText(user);
                    configRequest();
                }
                oThis.destroy();
            }
						else {
							var wel = oThis.getEl();
							var pos = wel.getXY();
							wel.sequenceFx().shift({
                    duration:   0.1,
                    x:          pos[0] - 15
                }).shift({
                    duration:   0.1,
                    x:          pos[0] + 15
                }).shift({
                    duration:   0.1,
                    x:          pos[0] - 10
                }).shift({
                    duration:   0.1,
                    x:          pos[0] + 10
                }).shift({
                    duration:   0.1,
                    x:          pos[0] - 5
                }).shift({
                    duration:   0.1,
                    x:          pos[0] + 5
                }).shift({
                    duration:   0.1,
                    x:          pos[0]
                }); 
						}
        }, {
            scope: this
        });
    };
    this.username = new Ext.form.TextField({
        id: 'textfieldUsername',
        msgTarget: 'side',
        fieldLabel: 'User',
        name: 'f_email',
        width: 175,
        allowBlank: true,
        value: Ext.state.Manager.get('UserName', ''),
        invalidText: 'Username missing'
    });
    this.password = new Ext.form.TextField({
        id: 'textfieldPassword',
        msgTarget: 'side',
        fieldLabel: 'Password',
        allowBlank: false,
        name: 'f_pass',
        width: 175,
        inputType: 'password'
    });
    this.password.on('specialkey', function(A, B){
        if (B.getKey() == 13) {
            this.loginButtonHandler()
        }
    }, this);
    this.loginForm = new Ext.FormPanel({
        id: 'formLoginForm',
        labelWidth: 75,
        defaults: {
            width: 230
        },
        baseCls: 'x-plain',
        defaultType: 'textfield',
        labelAlign: 'left',
        bodyStyle: {
            padding: '10px'
        },
        border: false,
        items: [this.username, this.password]
    });
    Ext.QuickTips.init();
    HAP.LoginWindow.superclass.constructor.call(this, {
        id: 'windowLoginDialog',
        width: 400,
        autoHeight: true,
        modal: true,
        shadow: true,
        bodyBorder: false,
        plain: true,
        collapsible: false,
        resizable: false,
        closable: true,
        title: 'Login',
        iconCls: 'password',
        defaultButton: 'textfieldUsername', //autoFocus
        buttons: [{
            text: 'Login',
            handler: this.loginButtonHandler,
            scope: this
        }],
        items: [this.loginForm]
    });
}
Ext.extend(HAP.LoginWindow, Ext.Window, {});
Ext.BLANK_IMAGE_URL = '/../static/js/ext/resources/images/default/s.gif'; // Ext 2.0

HAP.WinRole = function(){
    this.id = 'winRole';
    this.modal = true;
    this.title = 'Rolle bearbeiten';
    this.layout = 'fit';
    this.width = '500';
    this.autoHeight = true;
    this.plain = true;
    this.items = [{
        id: 'formRole',
        xtype: 'form',
        frame: true,
        autoHeight: true,
        items: [{
            xtype: 'textfield',
            fieldLabel: 'Rolle',
            name: 'role',
            hiddenName: 'role',
            anchor: '100%'
        }]
    }];
    this.buttons = [{
        text: 'OK',
        iconCls: 'ok',
        scope: this,
        handler: function(){
            saveButtonHandler('formRole', 'winRole');
        }
    }, {
        text: 'Abbrechen',
        iconCls: 'cancel',
        handler: function(){
            cancelButtonHandler('winRole');
        }
    }];
		HAP.WinRole.superclass.constructor.call(this);
    Ext.getCmp('formRole').on('render', function(){
        this.record = Ext.getCmp('gridRoles').getSelectionModel().getSelected();
        Ext.getCmp('formRole').getForm().loadRecord(this.record);
    });
};

Ext.extend(HAP.WinRole, Ext.Window, {});
HAP.ChangePasswordWindow = function(){
	var oThis = this;
    function saveButtonClick(){
        if (Ext.getCmp('npassword1').getValue() == Ext.getCmp('npassword2').getValue()) {
            if (Ext.getCmp('npassword1').getValue() == '' || Ext.getCmp('npassword2').getValue() == '') {
                Ext.MessageBox.alert('Warning', 'Password not set');
            }
            else {
                var conn = new Ext.data.Connection();
                conn.request({
                    method: 'POST',
                    url: 'users/setUserPassword',
                    params: {
                        password: Ext.getCmp('npassword1').getValue()
                    }
                });
                conn.on('requestcomplete', function(sender, param){
                    var response = Ext.util.JSON.decode(param.responseText);
                    if (response.success) {
                        oThis.close();
                    }
                    else {
                        if (response.permissiondenied) {
                            var loginWindow = new HAP.LoginWindow();
                            loginWindow.show();
                        }
                    }
                }, {
                    scope: this
                });
            }
        }
        else {
            Ext.MessageBox.alert('Warning', 'Check password');
        }
    };
    
    this.id = 'changePasswordWindow';
    this.modal = true;
    this.title = 'Change Password';
	this.iconCls = 'password';
    this.layout = 'fit';
    this.width = '400';
    this.autoHeight = true;
    this.plain = true;
    this.items = [{
        id: 'formChangePassword',
        xtype: 'form',
        frame: true,
        labelWidth: 120,
        autoHeight: true,
        //height: '200',
        items: [{
            xtype: 'textfield',
            fieldLabel: 'Password',
            inputType: 'password',
            name: 'npassword1',
            id: 'npassword1',
            hiddenname: 'npassword1',
            anchor: '100%'
        }, {
            xtype: 'textfield',
            fieldLabel: 'Password (re-type)',
            inputType: 'password',
            id: 'npassword2',
            name: 'npassword2',
            hiddenname: 'npassword2',
            anchor: '100%'
        }]
    }];
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClick();
        },
        scope: this
    }];
    this.buttons = [{
        text: 'OK',
        iconCls: 'ok',
        scope: this,
        handler: saveButtonClick
    }, {
        text: 'Cancel',
        iconCls: 'cancel',
        handler: function(){
            oThis.close();
        }
    }];
    HAP.ChangePasswordWindow.superclass.constructor.call(this);
};

Ext.extend(HAP.ChangePasswordWindow, Ext.Window, {});
HAP.ManageUserWindow = function(item){

    storeUsers.load();
    
    var sm = new Ext.grid.CheckboxSelectionModel({});
    
    var cm = new Ext.grid.ColumnModel([sm, {
        id: 'name',
        header: 'Username',
        dataIndex: 'username',
        sortable: true,
        width: 350,
        editor: new Ext.form.TextField({
            allowBlank: false
        })
    }]);
    
    var newUser = Ext.data.Record.create([{
        name: 'id'
    }, {
        name: 'username',
        type: 'text'
    }, {
        name: 'password',
        type: 'text'
    }, {
        name: 'password1',
        type: 'text'
    }, {
        name: 'password2',
        type: 'text'
    }, {
        name: 'prename',
        type: 'text'
    }, {
        name: 'surname',
        type: 'text'
    }, {
        name: 'email',
        type: 'text'
    }])
    
    var grid = new Ext.grid.EditorGridPanel({
        id: 'gridUsers',
        store: storeUsers,
        cm: cm,
        height: 300,
        autoExpandColumn: 'username',
        frame: false,
        sm: sm,
        viewConfig: {
            forceFit: true
        }
    });
    
    function saveChanges(){
        var mr = storeUsers.getModifiedRecords();
        if (mr.length > 0) {
            var data = new Array;
            for (var index in mr) {
                data.push(mr[index].data);
            }
            var conn = new Ext.data.Connection();
            conn.request({
                method: 'POST',
                url: '/users/submit',
                params: {
                    data: Ext.util.JSON.encode(data)
                }
            });
            conn.on('requestcomplete', function(sender, param){
                var response = Ext.util.JSON.decode(param.responseText);
                if (response.success) {
                    storeUsers.reload({
                        save: true
                    });
                }
                else {
                    Ext.MessageBox.alert('Warning', response.info);
                }
            }, {
                scope: this
            });
        }
    }
    
    function addUser(){
        grid.stopEditing();
        var c = new newUser({
            id: 0,
            username: "",
            password: "",
            prename: "",
            surname: "",
            email: ""
        });
        storeUsers.insert(0, c);
        grid.getSelectionModel().selectRow(0);
        grid.startEditing(0, 1);
    }
    
    function deleteUser(){
        Ext.MessageBox.show({
            title: 'Warning',
            msg: 'Are you sure that you want to delete this user?',
            buttons: Ext.Msg.YESNO,
            icon: Ext.MessageBox.QUESTION,
            fn: function(btn, txt){
                if (btn == 'yes') {
                    var sel = grid.getSelectionModel().getSelections();
                    var data = new Array;
                    for (var index in sel) {
                        data.push(sel[index].data);
                    }
                    var conn = new Ext.data.Connection();
                    conn.request({
                        method: 'POST',
                        url: '/users/delete',
                        params: {
                            data: Ext.util.JSON.encode(data)
                        }
                    });
                    conn.on('requestcomplete', function(sender, param){
                        var response = Ext.util.JSON.decode(param.responseText);
                        if (response.success) {
                            storeUsers.reload();
                        }
                        else {
                            Ext.MessageBox.alert('Warning', response.info);
                        }
                    }, {
                        scope: this
                    });
                }
            }
        })
    }
    
    function editUser(){
        var sm = grid.getSelectionModel();
        if (sm.getSelected() == null) {
            Ext.MessageBox.alert('Warning', 'No selections');
            return;
        }
        if (sm.getCount() > 1) {
            Ext.MessageBox.alert('Warning', 'No multiple selections allowed');
            return;
        }
        var mr = sm.getSelections();
        
        var win = new HAP.UserPropWindow(sm.getSelected().data.id);
        win.show();
    }
    
    var win = new Ext.Window({
        title: 'Manage Users',
        iconCls: 'user',
        modal: true,
        closable: true,
        width: 350,
        height: 350,
        autoScroll: true,
        layout: 'fit', // important -> tells sub-components to fit (showing scrollbars correctly)
        items: [grid],
        tbar: [{
            text: 'Save Changes',
            handler: saveChanges,
            iconCls: 'save'
        }, '-', {
            text: 'Add',
            handler: addUser,
            iconCls: 'add'
        }, {
            text: 'Edit',
            handler: editUser,
            iconCls: 'edit'
        }, '-', {
            text: 'Delete',
            handler: deleteUser,
            iconCls: 'delete'
        }]
    });
    
    win.show(this);
    
}
HAP.UserPropWindow = function(userId){
    this.id = 'winUser';
    this.iconCls = 'user';
	this.modal = true;
    this.title = 'Edit user';
    this.layout = 'fit';
    this.width = '400';
    this.autoHeight = true;
    this.plain = true;
    this.items = [{
        id: 'formUser',
        xtype: 'form',
        frame: true,
        autoHeight: true,
        items: [{
            xtype: 'fieldset',
            title: 'User-details',
            collapsible: false,
            autoHeight: true,
            defaultType: 'textfield',
            items: [{
                xtype: 'textfield',
                fieldLabel: 'Username',
                name: 'username',
                hiddenName: 'username',
                anchor: '100%'
            }, {
                xtype: 'textfield',
                fieldLabel: 'Prename',
                name: 'prename',
                hiddenName: 'prename',
                anchor: '100%'
            }, {
                xtype: 'textfield',
                fieldLabel: 'Surname',
                name: 'surname',
                hiddenName: 'surname',
                anchor: '100%'
            }, {
                xtype: 'textfield',
                fieldLabel: 'E-Mail',
                name: 'email',
                hiddenName: 'email',
                anchor: '100%'
            }]
        }, {
            xtype: 'fieldset',
            title: 'Password',
            autoHeight: true,
            defaultType: 'textfield',
            labelWidth: 130,
            items: [{
                fieldLabel: 'Password',
                inputType: 'password',
                name: 'password1',
                id: 'password1',
                hiddenname: 'password1',
                anchor: '100%'
            }, {
                fieldLabel: 'Password (re-type)',
                inputType: 'password',
                id: 'password2',
                name: 'password2',
                hiddenname: 'password2',
                anchor: '100%'
            }]
        }, {
            xtype: 'fieldset',
            title: 'Roles',
            autoHeight: true,
            items: [new HAP.GridUserRoles(userId)]
        }]
    }];
    var oThis = this;
    this.buttons = [{
        text: 'OK',
        iconCls: 'ok',
        scope: this,
        handler: function(){
            if (Ext.getCmp('password1').getValue() == Ext.getCmp('password2').getValue()) {
                if (Ext.getCmp('password1').getValue() == '' || Ext.getCmp('password2').getValue() == '') {
                    Ext.MessageBox.alert('Warning', 'Password not set');
                }
                else {
                    var mr = storeUserRoles.getModifiedRecords();
                    var roleData = new Array;
                    for (var index in mr) {
                        roleData.push(mr[index].data);
                    }
                    
                    var form = Ext.getCmp('formUser');
                    form.getForm().updateRecord(form.record);
                    
                    var data = new Array;
                    form.record.data.roles = roleData;
                    data.push(form.record.data);
                    
                    var conn = new Ext.data.Connection();
                    conn.request({
                        method: 'POST',
                        url: 'users/submit',
                        params: {
                            data: Ext.util.JSON.encode(data)
                        }
                    });
                    conn.on('requestcomplete', function(sender, param){
                        var response = Ext.util.JSON.decode(param.responseText);
                        if (response.success) {
                            storeUsers.reload();
                            storeUsers.commitChanges();
                            storeUserRoles.commitChanges();
                            var form = Ext.getCmp('formUser');
                            form.getForm().updateRecord(form.record);
                            oThis.close();
                        }
                        else {
                            if (response.permissiondenied) {
                                var loginWindow = new HAP.LoginWindow();
                                loginWindow.show();
                            }
                        }
                    }, {
                        scope: this
                    });
                }
            }
            else {
                Ext.MessageBox.alert('Warning', 'Check password');
            }
        }
    }, {
        text: 'Cancel',
        iconCls: 'cancel',
        handler: function(){
            oThis.close();
        }
    }];
    HAP.UserPropWindow.superclass.constructor.call(this);
    Ext.getCmp('formUser').on('render', function(){
        this.record = Ext.getCmp('gridUsers').getSelectionModel().getSelected();
        Ext.getCmp('formUser').getForm().loadRecord(this.record);
    });
    
};

Ext.extend(HAP.UserPropWindow, Ext.Window, {});
HAP.GridUserRoles = function(userId){
    var checkColumn = new Ext.grid.CheckColumn({
        header: 'active',
        dataIndex: 'status',
        width: 35
    });
    var cm = new Ext.grid.ColumnModel([{
        id: 'role',
        header: 'Role',
        dataIndex: 'role',
        sortable: true,
        width: 295
    }, checkColumn]);
    storeUserRoles.load({
        params: {
            id: userId
        }
    });
    this.clicksToEdit = 1;
    this.id = 'gridUserRoles';
    this.ds = storeUserRoles;
    this.cm = cm;
    this.frame = false;
    this.plugins = [checkColumn];
    this.height = 190;
    this.width = 350;
    this.layout = 'fit';
    HAP.GridUserRoles.superclass.constructor.call(this);
}

Ext.extend(HAP.GridUserRoles, Ext.grid.EditorGridPanel, {});

HAP.TreeDevice = function(){
    this.id = 'treeDevice';
    this.title = 'by Device';
    this.iconCls = 'byDevice';
    this.autoScroll = true;
    this.animate = true;
    this.rootVisible = true;
    this.root = new Ext.tree.AsyncTreeNode({
        loader: new Ext.tree.TreeLoader({
            dataUrl: '/treedevice/getTreeNodes'
        }),
        text: 'Devices',
        draggable: false,
        expanded: true,
        id: 'device/0/root'
    });
    this.listeners = {
        'click': viewPanel,
        'contextmenu': this.contextMenuHandler
    };
    HAP.TreeDevice.superclass.constructor.call(this);
}

Ext.extend(HAP.TreeDevice, Ext.tree.TreePanel, {
    addHapNode: function(url, type, newName, newId){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            if (!type) {
                type = url.split('/')[0];
            }
            this.getNodeById(url).expand();
            this.getNodeById(url).appendChild(new Ext.tree.TreeNode({
                text: newName,
                id: type + '/' + newId
            }));
            this.getNodeById(type + '/' + newId).select();
        }
        else {
            this.root.reload();
        }
    },
    updateHapNode: function(url, newName){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            if (this.getNodeById(url)) {// maybe a bug?: If tree-node isnt expanded, it doesnt exist in dom !
                this.getNodeById(url).setText(newName);
            }
            else {
                this.root.reload();
            }
        }
        else {
            this.root.reload();
        }
    },
    removeHapNode: function(url){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            this.getNodeById(url).remove();
        }
        else {
            this.root.reload();
        }
    },
    addIRCode: function(url, type, newName, newId){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            if (this.getNodeById(type + '/' + newId)) {
                this.updateHapNode(type + '/' + newId, newName);
            }
            else {
                this.addHapNode(url, type, newName, newId);
            }
        }
        else {
            this.root.reload();
        }
    },
    contextMenuHandler: function(node, e){
        if (!this.menu) {
            this.menu = new HAP.TreeContextMenu(node, e);
        }
        this.menu.setActiveNode(node);
        this.menu.showAt(e.getXY());
    }
});

HAP.TreeModule = function(){
    this.id = 'treeModule';
    this.title = 'by Module';
    this.iconCls = 'byModule';
    this.autoScroll = true;
    this.animate = true;
    this.rootVisible = true;
    this.root = new Ext.tree.AsyncTreeNode({
        loader: new Ext.tree.TreeLoader({
            dataUrl: '/treemodule/getTreeNodes'
        }),
        text: 'Modules',
        draggable: false,
        expanded: true,
        id: 'module/0/root'
    });
    this.listeners = {
        'click': viewPanel,
        'contextmenu': this.contextMenuHandler
    };
    HAP.TreeModule.superclass.constructor.call(this);
}

Ext.extend(HAP.TreeModule, Ext.tree.TreePanel, {
    addHapNode: function(url, type, newName, newId){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            if (!type) {
                type = url.split('/')[0];
            }
            this.getNodeById(url).expand();
            if (type == 'module') {
                this.getNodeById(url).appendChild(new Ext.tree.AsyncTreeNode({
                    text: newName,
                    id: type + '/' + newId,
                    loader: new Ext.tree.TreeLoader({
                        dataUrl: '/treemodule/getTreeNodes/' + newId
                    })
                }));
            }
            else {
                this.getNodeById(url).appendChild(new Ext.tree.TreeNode({
                    text: newName,
                    id: type + '/' + newId
                }));
            }
            this.getNodeById(type + '/' + newId).select();
        }
        else {
            this.root.reload();
        }
    },
    updateHapNode: function(url, newName){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            if (this.getNodeById(url)) {// maybe a bug?: If tree-node isnt expanded, it doesnt exist in dom !
                this.getNodeById(url).setText(newName);
            }
            else {
                this.root.reload();
            }
        }
        else {
            this.root.reload();
        }
    },
    removeHapNode: function(url){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            this.getNodeById(url).remove();
        }
        else {
            this.root.reload();
        }
    },
    addIRCode: function(url, type, newName, newId){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            if (this.getNodeById(type + '/' + newId)) {
                this.updateHapNode(type + '/' + newId, newName);
            }
            else {
                this.addHapNode(url, type, newName, newId);
            }
        }
        else {
            this.root.reload();
        }
    },
    contextMenuHandler: function(node, e){
        if (!this.menu) {
            this.menu = new HAP.TreeContextMenu(node, e);
        }
        this.menu.setActiveNode(node);
        this.menu.showAt(e.getXY());
    }
});

HAP.TreeRoom = function(){
    this.id = 'treeRoom';
    this.title = 'by Room';
    this.iconCls = 'byRoom';
    this.autoScroll = true;
    this.animate = true;
    this.rootVisible = true;
    this.root = new Ext.tree.AsyncTreeNode({
        loader: new Ext.tree.TreeLoader({
            dataUrl: '/treeroom/getTreeNodes'
        }),
        text: 'Rooms',
        draggable: false,
        expanded: true,
        id: 'room/0/root'
    });
    this.listeners = {
        'click': viewPanel,
        'contextmenu': this.contextMenuHandler
    };
    HAP.TreeRoom.superclass.constructor.call(this);
}

Ext.extend(HAP.TreeRoom, Ext.tree.TreePanel, {
    addHapNode: function(url, type, newName, newId){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            if (!type) {
                type = url.split('/')[0];
            }
            this.getNodeById(url).expand();
            if (type == 'room') {
                this.getNodeById(url).appendChild(new Ext.tree.AsyncTreeNode({
                    text: newName,
                    id: type + '/' + newId,
                    loader: new Ext.tree.TreeLoader({
                        dataUrl: '/treeroom/getTreeNodes/' + newId
                    })
                }));
            }
            else {
                this.getNodeById(url).appendChild(new Ext.tree.TreeNode({
                    text: newName,
                    id: type + '/' + newId
                }));
            }
            this.getNodeById(type + '/' + newId).select();
        }
        else {
            this.root.reload();
        }
    },
    updateHapNode: function(url, newName){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            if (this.getNodeById(url)) { // maybe a bug?: If tree-node isnt expanded, it doesnt exist in dom !
                this.getNodeById(url).setText(newName);
            }
            else {
                this.root.reload();
            }
        }
        else {
            this.root.reload();
        }
    },
    removeHapNode: function(url){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            this.getNodeById(url).remove();
        }
        else {
            this.root.reload();
        }
    },
    addIRCode: function(url, type, newName, newId){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            if (this.getNodeById(type + '/' + newId)) {
                this.updateHapNode(type + '/' + newId, newName);
            }
            else {
                this.addHapNode(url, type, newName, newId);
            }
        }
        else {
            this.root.reload();
        }
    },
    contextMenuHandler: function(node, e){
        if (!this.menu) {
            this.menu = new HAP.TreeContextMenu(node, e);
        }
        this.menu.setActiveNode(node);
        this.menu.showAt(e.getXY());
    }
});

HAP.TreeGUI = function(){
    this.id = 'treeGUI';
    this.title = 'GUI';
    this.iconCls = 'gui';
    this.autoScroll = true;
    this.animate = true;
    this.rootVisible = true;
    this.root = new Ext.tree.AsyncTreeNode({
        loader: new Ext.tree.TreeLoader({
            dataUrl: '/treegui/getTreeNodes'
        }),
        text: 'Views',
        draggable: false,
        expanded: true,
        id: 'guiview/0/root'
    });
    this.listeners = {
        'click': viewPanel,
        'contextmenu': this.contextMenuHandler
    };
    HAP.TreeGUI.superclass.constructor.call(this);
}

Ext.extend(HAP.TreeGUI, Ext.tree.TreePanel, {
    addHapNode: function(url, type, newName, newId){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            if (!type) {
                type = url.split('/')[0];
            }
            if (type == 'guiscene') {
                this.getNodeById(url).parentNode.appendChild(new Ext.tree.TreeNode({
                    text: newName,
                    id: type + '/' + newId
                }));
            }
            else {
                this.getNodeById(url).expand();
                var tNode = new Ext.tree.TreeNode({
                    text: newName,
                    id: type + '/' + newId
                });
                this.getNodeById(url).appendChild(tNode);
                if (type == 'guiview') {
                    tNode.appendChild(new Ext.tree.TreeNode({
                        text: 'New Scene',
                        id: 'guiscene/0/' + newId
                    }))
                }
                this.getNodeById(type + '/' + newId).select();
            }
        }
        else {
            this.root.reload();
        }
    },
    updateHapNode: function(url, newName){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            if (this.getNodeById(url)) {// maybe a bug?: If tree-node isnt expanded, it doesnt exist in dom !
                this.getNodeById(url).setText(newName);
            }
            else {
                this.root.reload();
            }
        }
        else {
            this.root.reload();
        }
    },
    removeHapNode: function(url){
        if (this.id == Ext.getCmp('west-panel').layout.activeItem.id && this.getNodeById(url)) {
            this.getNodeById(url).remove();
        }
        else {
            this.root.reload();
        }
    },
    contextMenuHandler: function(node, e){
        if (!this.menu) {
            this.menu = new HAP.TreeContextMenu(node, e);
        }
        this.menu.setActiveNode(node);
        this.menu.showAt(e.getXY());
    }
});

HAP.TreeMacro = function(){
    this.id = 'treeMacro';
    this.title = 'Macros';
    this.region = 'west';
    this.width = 175;
    this.split =  true;
    this.autoScroll = true;
    this.margins = '3 0 3 3';
    this.cmargins = '3 3 3 3';
    this.animate = true;
    this.rootVisible = true;
    this.root = new Ext.tree.AsyncTreeNode({
        loader: new Ext.tree.TreeLoader({
            dataUrl: '/treemacro/getTreeNodes'
        }),
        text: 'Macros',
        draggable: false,
        expanded: true,
        id: 'macro/0/root'
    });
    this.listeners = {
        'click': viewPanelMacro,
        'contextmenu': this.contextMenuHandler
    };
    HAP.TreeMacro.superclass.constructor.call(this);
}

Ext.extend(HAP.TreeMacro, Ext.tree.TreePanel, {
    addHapNode: function(url, type, newName, newId){
        if (this.getNodeById(url)) {
            if (!type) {
                type = url.split('/')[0];
            }
            this.getNodeById(url).expand();
            this.getNodeById(url).appendChild(new Ext.tree.TreeNode({
                text: newName,
                id: type + '/' + newId
            }));
            this.getNodeById(type + '/' + newId).select();
        }
    },
    updateHapNode: function(url, newName){
        if (this.getNodeById(url)) {
            if (this.getNodeById(url)) {// maybe a bug?: If tree-node isnt expanded, it doesnt exist in dom !
                this.getNodeById(url).setText(newName);
            }
            else {
                this.root.reload();
            }
        }
        else {
            this.root.reload();
        }
    },
    removeHapNode: function(url){
        if (this.getNodeById(url)) {
            this.getNodeById(url).remove();
        }
        else {
            this.root.reload();
        }
    },
    contextMenuHandler: function(node, e){
        if (!this.menu) {
            this.menu = new HAP.TreeContextMenu(node, e);
        }
        this.menu.setActiveNode(node);
        this.menu.showAt(e.getXY());
    }
});

var viewPanel = function(node, event){
    var center = Ext.getCmp('center-panel');
    var target = node.attributes.id.split('/');
    if (center.getItem(node.attributes.id) == null) {
        var p;
        switch (target[0]) {
            case 'module':
                p = new HAP.ModulePanel(node.attributes);
                break;
            case 'device':
                p = new HAP.DevicePanel(node.attributes);
                break;
            case 'logicalinput':
                p = new HAP.LogicalInputPanel(node.attributes);
                break;
            case 'analoginput':
                p = new HAP.AnalogInputPanel(node.attributes);
                break;
            case 'digitalinput':
                p = new HAP.DigitalInputPanel(node.attributes);
                break;
            case 'room':
                p = new HAP.RoomPanel(node.attributes);
                break;
            case 'shutter':
                p = new HAP.ShutterPanel(node.attributes);
                break;
            case 'rotaryencoder':
                p = new HAP.RotaryEncoderPanel(node.attributes);
                break;
            case 'rangeextender':
                p = new HAP.RangeExtenderPanel(node.attributes);
                break;
            case 'remotecontrolmapping':
                p = new HAP.RemoteControlMappingPanel(node.attributes);
                break;
            case 'remotecontrollearned':
                p = new HAP.RemoteControlLearnedPanel(node.attributes);
                break;
            case 'remotecontrol':
                p = new HAP.RemoteControlPanel(node.attributes);
                break;
            case 'autonomouscontrol':
                p = new HAP.ACPanel(node.attributes);
                break;
            case 'lcdgui':
                p = new HAP.LCDGuiPanel(node.attributes);
                break;
            case 'guiview':
                p = new HAP.GUIViewPanel(node.attributes);
                break;
            case 'guiscene':
                p = new HAP.GUIScenePanel(node.attributes);
                break;
        };
        center.add(p).show();
        p.syncSize();
        p.doLayout();
        center.syncSize(); // very important !
        center.ownerCt.doLayout(); // very, very important!
    }
    else {
        center.setActiveTab(node.attributes.id);
    }
}

var viewPanelMacro = function(node, event){
    var center = Ext.getCmp('center-panel-macro');
    var target = node.attributes.id.split('/');
    if (center.getItem(node.attributes.id) == null) {
        var p;
        switch (target[0]) {
            case 'macro':
                p = new HAP.MacroPanel(node.attributes);
                break;
        };
        center.add(p).show();
        p.syncSize();
        p.doLayout();
        center.syncSize(); // very important !
        center.ownerCt.doLayout(); // very, very important!
    }
    else {
        center.setActiveTab(node.attributes.id);
    }
}

HAP.TreeContextMenu = function(){
    this.id = 'treeContextMenu';
    this.items = [{
        text: 'Add',
        iconCls: 'add',
        scope: this,
        handler: function(){
            var target = this.node.id;
            if (target.split('/')[1] == 0) {
                this.node.fireEvent('click', this.node);
            }
            else {
                var tmpNode = this.node;
                tmpNode.attributes.id = this.node.id.split('/')[0] + '/0';
                this.node.fireEvent('click', tmpNode);
            }
        }
    }, {
        text: 'Edit',
        iconCls: 'edit',
        scope: this,
        handler: function(){
            this.node.select();
            this.node.fireEvent('click', this.node);
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        scope: this,
        handler: function(){
            this.node.select();
            HAP.deleteObject(this.node.id);
        }
    }];
    HAP.TreeContextMenu.superclass.constructor.call(this);
}

Ext.extend(HAP.TreeContextMenu, Ext.menu.Menu, {
    setActiveNode: function(node){
        this.node = node;
    }
});
HAP.ModulePanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Module';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
                deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
                saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        layout: 'absolute',
        width: 800,
        height: 900,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            defaults: {
                width: 224
            },
            width: 370,
            x: 5,
            y: 5,
            height: 275,
            items: [new HAP.TextName(attrib.id), new HAP.TextModuleUID(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModuleAddress(attrib.id), new HAP.ComboModule(attrib.id, {
                fieldLabel: 'Server Address',
                name: 'ccuaddress',
                allowBlank: true
            }), new HAP.ComboStartMode(attrib.id), {
                id: attrib.id + '/bridgemode',
                xtype: 'checkbox',
                fieldLabel: 'Bridge-Mode',
                name: 'bridgemode',
                inputValue: 1,
                //labelSeparator: '',
                //width: 128,
                value: 0
            }, new HAP.ComboUpstreamModules(attrib.id), new HAP.ComboUpstreamInterface(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Wireless',
            autoHeight: true,
            y: 285,
            x: 5,
            width: 370,
            height: 135,
            items: [{
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 255,
                fieldLabel: 'WLAN-ID',
                name: 'vlan',
                allowBlank: false
            }, {
                xtype: 'textfield',
                fieldLabel: 'Key',
                maxLength: 8,
                regex: /^[\w\_\:\;\/\(\)=\&\%\$\!\'\?\*\#\,\@<>\^]*$/, // avoid non ascii
                regexText: 'Invalid Cryptkey entered, dont use non ASCII-Characters',
                name: 'cryptkey'
            }, {
                xtype: 'checkbox',
                boxLabel: 'Encryption',
                name: 'cryptoption/1',
                inputValue: 1,
                labelSeparator: ''
            }, {
                xtype: 'checkbox',
                boxLabel: 'Encrypt VLAN-ID',
                name: 'cryptoption/2',
                inputValue: 1,
                labelSeparator: ''
            }]
        }, {
            xtype: 'fieldset',
            title: 'CAN',
            x: 5,
            y: 430,
            defaults: {
                width: 64
            },
            width: 370,
            height: 60,
            items: [{
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 255,
                fieldLabel: 'CAN-VLAN-ID',
                name: 'canvlan',
                allowBlank: false
            }]
        }, {
            xtype: 'fieldset',
            title: 'Signal Level',
            x: 5,
            y: 500,
            width: 370,
            height: 140,
            items: [{
                layout: 'column',
                items: [{
                    columnWidth: 0.5,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: 'System',
                        name: 'buzzerlevel/1',
                        inputValue: 1
                    
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'IR-Keypress',
                        name: 'buzzerlevel/16',
                        inputValue: 1
                    
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'IR-Command Ack',
                        name: 'buzzerlevel/32',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'IR-Error',
                        name: 'buzzerlevel/64',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'IR-Learn Ack',
                        name: 'buzzerlevel/128',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.5,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: 'GUI-Keypress',
                        name: 'buzzerlevel/256',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'GUI-Command Ack',
                        name: 'buzzerlevel/512',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'GUI-Error',
                        name: 'buzzerlevel/1024',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'GUI-Rotary-Encoder-Event',
                        name: 'buzzerlevel/2048',
                        inputValue: 1
                    }]
                }]
            }]
        }, {
            xtype: 'fieldset',
            title: 'Multicast-Groups',
            x: 5,
            y: 650,
            width: 370,
            height: 85,
            items: [{
                layout: 'column',
                items: [{
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '240',
                        name: 'mcastgroup/1',
                        inputValue: 1
                    
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '247',
                        name: 'mcastgroup/128',
                        inputValue: 1
                    
                    }]
                }, {
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '241',
                        name: 'mcastgroup/2',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '248',
                        name: 'mcastgroup/256',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '242',
                        name: 'mcastgroup/4',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '249',
                        name: 'mcastgroup/512',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '243',
                        name: 'mcastgroup/8',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '250',
                        name: 'mcastgroup/1024',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '244',
                        name: 'mcastgroup/16',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '251',
                        name: 'mcastgroup/2048',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '245',
                        name: 'mcastgroup/32',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '252',
                        name: 'mcastgroup/4096',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '246',
                        name: 'mcastgroup/64',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '253',
                        name: 'mcastgroup/8192',
                        inputValue: 1
                    }]
                }]
            }]
        }, {
            xtype: 'fieldset',
            title: 'Logical Input Defaults',
            x: 385,
            y: 5,
            width: 370,
            height: 110,
            labelWidth: 160,
            defaults: {
                width: 64
            },
            items: [{
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 65535,
                fieldLabel: 'Debounced (1/100s)',
                name: 'libouncedelay',
                value: 10,
                allowBlank: false
            }, {
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 65535,
                fieldLabel: 'Short Activation (1/100s)',
                name: 'lishortdelay',
                value: 50,
                allowBlank: false
            }, {
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 65535,
                fieldLabel: 'Long Activation (1/100s)',
                name: 'lilongdelay',
                value: 150,
                allowBlank: false
            }]
        }, {
            xtype: 'fieldset',
            title: 'Common Defaults',
            x: 385,
            y: 125,
            width: 370,
            height: 110,
            labelWidth: 160,
            defaults: {
                width: 64
            },
            items: [{
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 128,
                fieldLabel: 'Receive-Buffer-Size',
                name: 'receivebuffer',
                value: 4,
                allowBlank: false
            }, {
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 255,
                fieldLabel: 'Dimm-Time-Period (1/10s)',
                name: 'dimmercyclelength',
                value: 6,
                allowBlank: false
            }, {
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 65535,
                fieldLabel: 'Dimmer-Pulse-Length (Tics)',
                name: 'dimmerticlength',
                value: 60,
                allowBlank: false
            }]
        }, {
            xtype: 'fieldset',
            title: 'Server Settings',
            x: 385,
            y: 245,
            width: 370,
            height: 60,
            items: [{
                layout: 'column',
                items: [{
                    columnWidth: 0.5,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        id: attrib.id + '/isccu',
                        hapDBID: this.target.split('/')[1],
                        boxLabel: 'Is Server (CCU)',
                        name: 'isccu',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.5,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        id: attrib.id + '/isccumodule',
                        hapDBID: this.target.split('/')[1],
                        boxLabel: 'Is Server-Module (CU)',
                        name: 'isccumodule',
                        inputValue: 1
                    }]
                }]
            }]
        }, {
            xtype: 'fieldset',
            title: 'Firmware Options',
            x: 385,
            y: 315,
            width: 370,
            height: 420,
            defaults: {
                width: 224
            },
            items: [new HAP.ComboFirmware(attrib.id), {
                xtype: 'textfield',
                fieldLabel: 'Current',
                labelStyle: 'font-weight:bold;',
                disabled: true,
                name: 'currentfirmwareid'
            }, {
                layout: 'column',
                width: 333,
                height: 246,
                items: [{
                    columnWidth: 0.5,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'EEProm Support',
                        name: 'fwopt/1',
                        id: attrib.id + '/fwopt/1',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'External Reset',
                        name: 'fwopt/2',
                        id: attrib.id + '/fwopt/2',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Buzzer',
                        name: 'fwopt/4',
                        id: attrib.id + '/fwopt/4',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Wireless',
                        name: 'fwopt/8',
                        id: attrib.id + '/fwopt/8',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'CAN',
                        name: 'fwopt/16',
                        id: attrib.id + '/fwopt/16',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Infrared',
                        name: 'fwopt/32',
                        id: attrib.id + '/fwopt/32',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Shutter Control',
                        name: 'fwopt/8192',
                        id: attrib.id + '/fwopt/8192',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Rotary Encoder PEC11',
                        name: 'fwopt/16384/1',
                        id: attrib.id + '/fwopt/16384/1',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Rotary Encoder STEC',
                        name: 'fwopt/16384/2',
                        id: attrib.id + '/fwopt/16384/2',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Autonomous Control',
                        name: 'fwopt/131072',
                        id: attrib.id + '/fwopt/131072',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.5,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Dallas DS18S20',
                        name: 'fwopt/1024',
                        id: attrib.id + '/fwopt/1024',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'LCD GUI',
                        name: 'fwopt/65536',
                        id: attrib.id + '/fwopt/65536',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'LCD 1 Row',
                        name: 'fwopt/64/1',
                        id: attrib.id + '/fwopt/64/1',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'LCD 2 Row',
                        name: 'fwopt/64/2',
                        id: attrib.id + '/fwopt/64/2',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'LCD 3 Row',
                        name: 'fwopt/64/3',
                        id: attrib.id + '/fwopt/64/3',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Logical Input',
                        name: 'fwopt/256',
                        id: attrib.id + '/fwopt/256',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Analog Input',
                        name: 'fwopt/512',
                        id: attrib.id + '/fwopt/512',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Switch',
                        name: 'fwopt/2048',
                        id: attrib.id + '/fwopt/2048',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Dimmer',
                        name: 'fwopt/4096',
                        id: attrib.id + '/fwopt/4096',
                        inputValue: 1
                    }]
                }]
            }]
        }]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }]
    
    HAP.ModulePanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            if (action.result.data.id != 0) {
                Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            }
            Ext.getCmp(attrib.id + '/textName').focus();
            setCurrentFwLabels(action.result.data);
        }
    });
    
    storeFreeModuleAddresses.proxy = new Ext.data.HttpProxy({
        url: '/json/getFreeModuleAddresses/' + this.target.split('/')[1]
    });
    storeFreeModuleAddresses.load();
    
    var checkCCU = function(box, checked){
        if (checked) {
            if (this.name == 'isccu') {
                checkIsCCUModule.setValue(false);
            }
            else {
                checkIsCCU.setValue(false)
                Ext.getCmp(attrib.id + '/bridgemode').setValue(true);
            }
            Ext.getCmp(attrib.id).load({
                url: 'module/checkForCCU/' + this.name + '/' +
                this.hapDBID,
                method: 'GET',
                success: function(form, action){
                    var mString = '';
                    for (i = 0; i < action.result.data.length; i++) {
                        mString += action.result.data[i].name + '<br>';
                    }
                    Ext.MessageBox.show({
                        title: 'Warning',
                        msg: 'The following module(s) are already defined as a Server(-Module):' + '<br>' + mString,
                        buttons: Ext.Msg.OK,
                        icon: Ext.MessageBox.INFO
                    })
                }
            })
        }
    }
    
    var getFwOpts = function(combo, item){
        if (item.data.precompiled == 1 && item.data.id != 0) {
            Ext.getCmp(attrib.id).load({
                url: 'module/getFwOpts/fromFirmware/' + item.data.id,
                method: 'GET',
                success: function(form, action){
                    for (item in action.result.data) {
                        var cmp = Ext.getCmp(attrib.id + '/' + item);
                        if (cmp) {
                            cmp.disable()
                        }
                    }
                }
            })
        }
        else {
            var cmp = Ext.getCmp(attrib.id);
            cmp.load({
                url: 'module/getFwOpts/fromModule/' + attrib.id.split('/')[1],
                method: 'GET',
                success: function(form, action){
                    for (item in action.result.data) {
                        var cmp = Ext.getCmp(attrib.id + '/' + item);
                        if (cmp) {
                            cmp.enable()
                        }
                    }
                }
            })
        }
    }
    
    var setCurrentFwLabels = function(resultData){ //on Load ...
        for (var item in resultData) {
            if (item.search(/currfwopt\/.*/) != -1) {
                if (resultData[item] == 1) {
                    var obj = Ext.getCmp(attrib.id + '/' + item.replace(/currfwopt/g, 'fwopt'));
                    if (obj) {
                        obj.getEl().up('div').setStyle('font-weight', 'bold');
                    }
                }
            }
            if (resultData.precompiled == 1) {
                if (item.search(/fwopt\/.*/) != -1) {
                    var obj = Ext.getCmp(attrib.id + '/' + item);
                    if (obj) {
                        obj.disable();
                    }
                }
            }
        }
    }
    
    checkIsCCU = Ext.getCmp(attrib.id + '/isccu');
    checkIsCCU.on('check', checkCCU);
    checkIsCCUModule = Ext.getCmp(attrib.id + '/isccumodule');
    checkIsCCUModule.on('check', checkCCU);
    
    var comboFw = Ext.getCmp(attrib.id + '/comboFirmware');
    comboFw.on('select', getFwOpts);
    
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
    });
    
}

Ext.extend(HAP.ModulePanel, Ext.FormPanel, {});
HAP.LogicalInputPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Logical Input';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
                deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
                saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        layout: 'absolute',
        width: 800,
        height: 600,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            height: 240,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), new HAP.ComboAddress(attrib.id), new HAP.ComboPortPin(attrib.id), new HAP.ComboNotify(attrib.id), new HAP.TextFormulaDescription(attrib.id), new HAP.TextFormula(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            x: 5,
            y: 255,
            width: 370,
            height: 270,
            labelWidth: 90,
            items: [new HAP.ComboLogicalInputTemplates(attrib.id), {
                xtype: 'checkbox',
                fieldLabel: 'Detection',
                boxLabel: 'Rising Edge Detection',
                name: 'type/1',
                inputValue: 1,
                labelSeparator: ' '
            }, {
                xtype: 'checkbox',
                fieldLabel: '',
				itemCls: 'x-check-group',
                boxLabel: 'Falling Edge Detection',
                name: 'type/2',
                inputValue: 1,
                labelSeparator: ' '
            }, {
                xtype: 'radiogroup',
				name: 'type/x',
                fieldLabel: 'Options',
				labelSeparator: ' ',
                itemCls: 'x-check-group-alt',
                columns: 1,
                items: [{
                    boxLabel: 'None',
                    name: 'type/x',
                    inputValue: 0
                }, {
                    boxLabel: 'Disable Debounce',
                    name: 'type/x',
                    inputValue: 4
                }, {
                    boxLabel: 'Short Activation',
                    name: 'type/x',
                    inputValue: 8
                },
				{
                    boxLabel: 'Long Activation',
                    name: 'type/x',
                    inputValue: 12
                }]
            },            /*
             {
             xtype: 'checkbox',
             fieldLabel: '',
             boxLabel: 'Short Activation Delay',
             name: 'type/8',
             inputValue: 1,
             labelSeparator: ' '
             }, {
             xtype: 'checkbox',
             fieldLabel: '',
             boxLabel: 'Long Activation Delay',
             name: 'type/12',
             inputValue: 1,
             labelSeparator: ' '
             }, {
             xtype: 'checkbox',
             fieldLabel: '',
             boxLabel: 'Activate Pullup',
             name: 'type/16',
             inputValue: 1,
             labelSeparator: ' '
             },
             */
            {
                xtype: 'checkbox',
                fieldLabel: 'Options',
                boxLabel: 'Pullup',
                name: 'type/16',
                inputValue: 1,
                labelSeparator: ' '
            }, {
                xtype: 'checkbox',
                fieldLabel: '',
                boxLabel: 'Force Debounce',
                name: 'type/32',
                inputValue: 1,
                labelSeparator: ' '
            }]
        }]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }];
    
    HAP.LogicalInputPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            loadAddressAndPortPin(action.result.data.module, action.result.data.address, action.result.data.portPin);
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        Ext.getCmp(attrib.id + '/comboAddress').fireEvent('select'); // check for duplicate address
        Ext.getCmp(attrib.id + '/comboPortPin').fireEvent('select'); // check for duplicate address
        loadAddressAndPortPin(Ext.getCmp(attrib.id + '/comboModule').getValue(), Ext.getCmp(attrib.id + '/comboAddress').getValue(), Ext.getCmp(attrib.id + '/comboPortPin').getValue());
        
    });
}

Ext.extend(HAP.LogicalInputPanel, Ext.FormPanel, {});
HAP.AnalogInputPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Analog Input';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        layout: 'absolute',
        width: 800,
        height: 600,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            height: 240,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), new HAP.ComboAddress(attrib.id), new HAP.ComboPortPin(attrib.id), new HAP.ComboNotify(attrib.id), new HAP.TextFormulaDescription(attrib.id), new HAP.TextFormula(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            autoHeight: false,
            labelWidth: 120,
            defaults: {
                width: 230
            },
            width: 370,
            x: 385,
            y: 5,
            height: 240,
            items: [{
                xtype: 'textfield',
                fieldLabel: 'Measurement',
                name: 'measure',
                maskRe: /[\d\.\;]+/,
                regex: /^([\d\.]+\;[\d\.]+[\;]*)+$/,
                width: 200
            }, {
                xtype: 'textfield',
                fieldLabel: 'Unit',
                name: 'unit',
                allowBlank: false,
                width: 64
            }, {
                xtype: 'numberfield',
                fieldLabel: 'Reference Correction',
                name: 'correction',
                width: 64
            }, {
                xtype: 'numberfield',
                fieldLabel: 'Sample Rate 1/10s',
                name: 'samplerate',
                allowBlank: false,
                minValue: 1,
                maxValue: 65535,
                width: 64
            }]
        }, {
            xtype: 'fieldset',
            title: 'Trigger 0',
            autoHeight: true,
            y: 255,
            x: 5,
            width: 370,
            labelWidth: 90,
            items: [{
                xtype: 'numberfield',
                fieldLabel: 'Trigger-Level',
                width: 64,
                value: 0,
                decimalPrecision: 4,
                name: 'trigger0'
            }, {
                xtype: 'numberfield',
                fieldLabel: 'Hysteresis',
                decimalPrecision: 4,
                allowNegative: false,
                width: 64,
                value: 0,
                name: 'trigger0hyst'
            }, {
                xtype: 'checkbox',
                fieldLabel: ' ',
                boxLabel: 'Notify if value over trigger-level',
                name: 'trigger0notify/8',
                inputValue: 1,
                labelSeparator: ' '
            }, {
                xtype: 'checkbox',
                fieldLabel: ' ',
                boxLabel: 'Notify if under trigger-level',
                name: 'trigger0notify/4',
                inputValue: 1,
                labelSeparator: ' '
            }]
        }, {
            xtype: 'fieldset',
            title: 'Trigger 1',
            autoHeight: true,
            x: 385,
            y: 255,
            width: 370,
            items: [{
                xtype: 'numberfield',
                fieldLabel: 'Tigger-Level',
                width: 64,
                value: 0,
                decimalPrecision: 4,
                name: 'trigger1'
            }, {
                xtype: 'numberfield',
                fieldLabel: 'Hysteresis',
                decimalPrecision: 4,
                allowNegative: false,
                width: 64,
                value: 0,
                name: 'trigger1hyst'
            }, {
                xtype: 'checkbox',
                fieldLabel: '',
                boxLabel: 'Notify if value over trigger-level',
                name: 'trigger1notify/8',
                inputValue: 1,
                labelSeparator: ' '
            }, {
                xtype: 'checkbox',
                fieldLabel: '',
                boxLabel: 'Notify if under trigger-level',
                name: 'trigger1notify/4',
                inputValue: 1,
                labelSeparator: ' '
            }]
        }]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }];
    
    HAP.AnalogInputPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            loadAddressAndPortPin(action.result.data.module, action.result.data.address, action.result.data.portPin);
        }
    });
    
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        Ext.getCmp(attrib.id + '/comboAddress').fireEvent('select'); // check for duplicate address
        Ext.getCmp(attrib.id + '/comboPortPin').fireEvent('select'); // check for duplicate address
        loadAddressAndPortPin(Ext.getCmp(attrib.id + '/comboModule').getValue(), Ext.getCmp(attrib.id + '/comboAddress').getValue(), Ext.getCmp(attrib.id + '/comboPortPin').getValue());
        
    });
}

Ext.extend(HAP.AnalogInputPanel, Ext.FormPanel, {});
HAP.DigitalInputPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Digital Input';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        layout: 'absolute',
        width: 800,
        height: 600,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            height: 240,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), new HAP.ComboAddress(attrib.id), new HAP.ComboPortPin(attrib.id), new HAP.ComboNotify(attrib.id), new HAP.TextFormulaDescription(attrib.id), new HAP.TextFormula(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            autoHeight: false,
            labelWidth: 120,
            defaults: {
                width: 200
            },
            width: 370,
            x: 385,
            y: 5,
            height: 240,
            items: [new HAP.ComboDigitalInputType(attrib.id), {
                xtype: 'numberfield',
                fieldLabel: 'Sample Rate 1/10s',
                name: 'samplerate',
                allowBlank: false,
                minValue: 1,
                maxValue: 255,
                width: 64
            }]
        }, {
            xtype: 'fieldset',
            title: 'Trigger 0',
            autoHeight: true,
            y: 255,
            x: 5,
            width: 370,
            labelWidth: 90,
            items: [{
                xtype: 'numberfield',
                fieldLabel: 'Trigger-Level',
                width: 64,
                decimalPrecision: 4,
                value: 0,
                name: 'trigger0'
            }, {
                xtype: 'numberfield',
                fieldLabel: 'Hysteresis',
                decimalPrecision: 4,
                allowNegative: false,
                width: 64,
                value: 0,
                name: 'trigger0hyst'
            }, {
                xtype: 'checkbox',
                fieldLabel: ' ',
                boxLabel: 'Notify if value over trigger-level',
                name: 'trigger0notify/8',
                inputValue: 1,
                labelSeparator: ' '
            }, {
                xtype: 'checkbox',
                fieldLabel: ' ',
                boxLabel: 'Notify if under trigger-level',
                name: 'trigger0notify/4',
                inputValue: 1,
                labelSeparator: ' '
            }]
        }, {
            xtype: 'fieldset',
            title: 'Trigger 1',
            autoHeight: true,
            x: 385,
            y: 255,
            width: 370,
            items: [{
                xtype: 'numberfield',
                fieldLabel: 'Tigger-Level',
                decimalPrecision: 4,
                width: 64,
                value: 0,
                name: 'trigger1'
            }, {
                xtype: 'numberfield',
                fieldLabel: 'Hysteresis',
                decimalPrecision: 4,
                allowNegative: false,
                width: 64,
                value: 0,
                name: 'trigger1hyst'
            }, {
                xtype: 'checkbox',
                fieldLabel: '',
                boxLabel: 'Notify if value over trigger-level',
                name: 'trigger1notify/8',
                inputValue: 1,
                labelSeparator: ' '
            }, {
                xtype: 'checkbox',
                fieldLabel: '',
                boxLabel: 'Notify if under trigger-level',
                name: 'trigger1notify/4',
                inputValue: 1,
                labelSeparator: ' '
            }]
        }]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }];
    
    HAP.DigitalInputPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            loadAddressAndPortPin(action.result.data.module, action.result.data.address, action.result.data.portPin);
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        Ext.getCmp(attrib.id + '/comboAddress').fireEvent('select'); // check for duplicate address
        Ext.getCmp(attrib.id + '/comboPortPin').fireEvent('select'); // check for duplicate address
        loadAddressAndPortPin(Ext.getCmp(attrib.id + '/comboModule').getValue(), Ext.getCmp(attrib.id + '/comboAddress').getValue(), Ext.getCmp(attrib.id + '/comboPortPin').getValue());
        
    });
}

Ext.extend(HAP.DigitalInputPanel, Ext.FormPanel, {});
HAP.DevicePanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Device';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        layout: 'absolute',
        width: 800,
        height: 600,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            height: 240,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), new HAP.ComboAddress(attrib.id), new HAP.ComboPortPin(attrib.id), new HAP.ComboNotify(attrib.id), new HAP.TextFormulaDescription(attrib.id), new HAP.TextFormula(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            height: 60,
            width: 370,
            x: 5,
            y: 255,
            labelWidth: 90,
            items: [new HAP.ComboDeviceType(attrib.id)]
        }]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp);
        }
    }];
    
    HAP.DevicePanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name)
            Ext.getCmp(attrib.id + '/textName').focus();
            loadAddressAndPortPin(action.result.data.module, action.result.data.address, action.result.data.portPin);
        }
    });
    
    this.on('activate', function(){     
        Ext.getCmp(attrib.id + '/textName').focus();
        Ext.getCmp(attrib.id + '/comboAddress').fireEvent('select'); // check for duplicate address
        Ext.getCmp(attrib.id + '/comboPortPin').fireEvent('select'); // check for duplicate address
        loadAddressAndPortPin(Ext.getCmp(attrib.id + '/comboModule').getValue(), Ext.getCmp(attrib.id + '/comboAddress').getValue(), Ext.getCmp(attrib.id + '/comboPortPin').getValue());
    });
}

Ext.extend(HAP.DevicePanel, Ext.FormPanel, {});
HAP.ShutterPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Shutter';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        layout: 'absolute',
        width: 800,
        height: 600,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            height: 165,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), new HAP.ComboAddress(attrib.id), new HAP.ComboNotify(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            autoHeight: false,
            labelWidth: 100,
            defaults: {
                width: 220
            },
            width: 370,
            x: 5,
            y: 180,
            height: 135,
            items: [new HAP.ComboDevices(attrib.id, {
                label: 'Up-Device',
                name: 'childdevice0',
                instance: 1,
                shutter: true
            }), new HAP.ComboDevices(attrib.id, {
                label: 'Down-Device',
                name: 'childdevice1',
                instance: 2,
                shutter: true
            }), {
                xtype: 'numberfield',
                fieldLabel: 'Run time (sec)',
                name: 'attrib0',
                allowBlank: false,
                minValue: 1,
                maxValue: 255,
                width: 64
            }, {
                xtype: 'checkbox',
                fieldLabel: '',
                boxLabel: 'Impuls mode',
                name: 'attrib1',
                inputValue: 1,
                labelSeparator: ' '
            }]
        }]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }];
    
    HAP.ShutterPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            loadAddressAndPortPin(action.result.data.module, action.result.data.address, '');
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        Ext.getCmp(attrib.id + '/comboAddress').fireEvent('select'); // check for duplicate address
        loadAddressAndPortPin(Ext.getCmp(attrib.id + '/comboModule').getValue(), Ext.getCmp(attrib.id + '/comboAddress').getValue(), '');
    });
    
}

Ext.extend(HAP.ShutterPanel, Ext.FormPanel, {});
HAP.RotaryEncoderPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Rotary Encoder';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        layout: 'absolute',
        width: 800,
        height: 600,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            height: 170,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), new HAP.ComboAddress(attrib.id), new HAP.ComboNotify(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            autoHeight: false,
            labelWidth: 90,
            defaults: {
                width: 230
            },
            width: 370,
            x: 5,
            y: 185,
            height: 165,
            items: [new HAP.ComboLogicalInputs(attrib.id, {
                label: 'A',
                name: 'childdevice0',
                instance: 1,
                rotaryEncoder: true
            }), new HAP.ComboLogicalInputs(attrib.id, {
                label: 'B',
                name: 'childdevice1',
                instance: 2,
                rotaryEncoder: true
            }), new HAP.ComboLogicalInputs(attrib.id, {
                label: 'P1',
                name: 'childdevice2',
                instance: 3,
                rotaryEncoderPushButton: true
            }), new HAP.ComboAbstractDevices(attrib.id, {
                label: 'Associated GUI',
                name: 'childdevice3',
                instance: 1,
                gui: true
            }), {
                xtype: 'numberfield',
                fieldLabel: 'Speed 1/100s',
                name: 'attrib2',
                allowBlank: false,
                minValue: 1,
                maxValue: 255,
                value: 100,
                width: 64
            }]
        }]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }];
    
    HAP.RotaryEncoderPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            loadAddressAndPortPin(action.result.data.module, action.result.data.address, '');
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        Ext.getCmp(attrib.id + '/comboAddress').fireEvent('select'); // check for duplicate address
        loadAddressAndPortPin(Ext.getCmp(attrib.id + '/comboModule').getValue(), Ext.getCmp(attrib.id + '/comboAddress').getValue(), '');
    });
}

Ext.extend(HAP.RotaryEncoderPanel, Ext.FormPanel, {});
HAP.RangeExtenderPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Device';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        layout: 'absolute',
        width: 800,
        height: 600,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            height: 110,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id, {
                instance: 1
            })]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            height: 60,
            width: 370,
            x: 5,
            y: 125,
            labelWidth: 100,
            defaults: {
                width: 220
            },
            items: [new HAP.ComboModule(attrib.id, {
                fieldLabel: 'Extended Module',
                instance: 2,
                name: 'destmodule'
            })]
        }]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }];
    
    HAP.RangeExtenderPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            loadAddressAndPortPin(action.result.data.module, action.result.data.address, '');
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
    });
}

Ext.extend(HAP.RangeExtenderPanel, Ext.FormPanel, {});
HAP.RemoteControlPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Remote Control';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) 
                deleteButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) 
                saveButtonClicked(this.target, this);
        },
        scope: this
    }];
    this.items = [{
        layout: 'absolute',
        width: 800,
        height: 600,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            height: 110,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id, {})]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            height: 157,
            width: 370,
            x: 5,
            y: 125,
            labelWidth: 90,
            defaults: {
                width: 230
            },
            items: [{
                xtype: 'textfield',
                fieldLabel: 'Address',
                name: 'address',
                readOnly: true,
                width: 64
            }, {
                xtype: 'textfield',
                fieldLabel: 'Code',
                name: 'code',
                readOnly: true,
                width: 64
            }, {
                xtype: 'textfield',
                fieldLabel: 'Action',
                name: 'action',
                readOnly: true,
                width: 64
            }]
        }, {
            xtype: 'fieldset',
            title: 'Keypad',
            layout: 'absolute',
            height: 277,
            width: 145,
            x: 385,
            y: 5,
//            labelWidth: 90,
            defaults: {
 //               width: 230
            },
            items: [new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-1',
                label: '1',
                x: 5,
                y: 5
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-2',
                label: '2',
                x: 47,
                y: 5
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-3',
                label: '3',
                x: 89,
                y: 5
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-4',
                label: '4',
                x: 5,
                y: 47
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-5',
                label: '5',
                x: 47,
                y: 47
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-6',
                label: '6',
                x: 89,
                y: 47
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-7',
                label: '7',
                x: 5,
                y: 89
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-8',
                label: '8',
                x: 47,
                y: 89
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-9',
                label: '9',
                x: 89,
                y: 89
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-0',
                label: '0',
                x: 47,
                y: 131
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'minus',
                label: '-',
                x: 5,
                y: 131
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'plus',
                label: '+',
                x: 89,
                y: 131
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'makro',
                label: 'Macro',
                x: 5,
                y: 173,
                minWidth: 50
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'enter',
                label: 'Enter',
                x: 70,
                y: 173,
                minWidth: 50
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'all-on',
                label: 'AllOn',
                x: 5,
                y: 215,
                minWidth: 50
            
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'all-off',
                label: 'AllOff',
                x: 70,
                y: 215,
                minWidth: 50
            })]
        }]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }];
    
    HAP.RemoteControlPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        //waitMsg : 'Loading...',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
    });
}

Ext.extend(HAP.RemoteControlPanel, Ext.FormPanel, {});
HAP.RemoteControlLearnedPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'RC Learned';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        layout: 'absolute',
        width: 800,
        height: 600,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            height: 110,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            height: 157,
            width: 370,
            x: 5,
            y: 125,
            labelWidth: 90,
            defaults: {
                width: 230
            },
            items: [{
                xtype: 'textfield',
                fieldLabel: 'Address',
                name: 'address',
                readOnly: true,
                width: 64
            }, {
                xtype: 'textfield',
                fieldLabel: 'Code',
                name: 'code',
                readOnly: true,
                width: 64
            }, {
                xtype: 'textfield',
                fieldLabel: 'Action',
                name: 'action',
                readOnly: true,
                width: 64
            }]
        }, {
            xtype: 'fieldset',
            title: 'Keypad',
            layout: 'absolute',
            height: 277,
            width: 145,
            x: 385,
            y: 5,
//            labelWidth: 90,
            defaults: {
//                width: 230
            },
            items: [new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-1',
                label: '1',
                x: 5,
                y: 5
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-2',
                label: '2',
                x: 47,
                y: 5
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-3',
                label: '3',
                x: 89,
                y: 5
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-4',
                label: '4',
                x: 5,
                y: 47
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-5',
                label: '5',
                x: 47,
                y: 47
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-6',
                label: '6',
                x: 89,
                y: 47
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-7',
                label: '7',
                x: 5,
                y: 89
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-8',
                label: '8',
                x: 47,
                y: 89
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-9',
                label: '9',
                x: 89,
                y: 89
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-0',
                label: '0',
                x: 47,
                y: 131
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'minus',
                label: '-',
                x: 5,
                y: 131
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'plus',
                label: '+',
                x: 89,
                y: 131
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'makro',
                label: 'Macro',
                x: 5,
                y: 173,
                minWidth: 50
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'enter',
                label: 'Enter',
                x: 70,
                y: 173,
                minWidth: 50
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'all-on',
                label: 'AllOn',
                x: 5,
                y: 215,
                minWidth: 50
            
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'all-off',
                label: 'AllOff',
                x: 70,
                y: 215,
                minWidth: 50
            })]
        }]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }];
    
    HAP.RemoteControlLearnedPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
    });
    
}

Ext.extend(HAP.RemoteControlLearnedPanel, Ext.FormPanel, {});
HAP.RemoteControlMappingPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Remote Control';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        layout: 'absolute',
        width: 800,
        height: 600,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            height: 110,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id)]
        }, {
            xtype: 'fieldset',
            id: attrib.id + '/fieldset',
            title: 'Device Specification',
            height: 130,
            width: 370,
            x: 5,
            y: 125,
            labelWidth: 90,
            defaults: {
                width: 230
            },
            items: [{
                xtype: 'numberfield',
                id: attrib.id + '/irkey',
                fieldLabel: 'Key',
                name: 'irkey',
                minValue: 1,
                maxValue: 99,
                width: 64
            }, new HAP.ComboIRDestinations(attrib.id), new HAP.ComboDevices(attrib.id, {
                label: 'Device-Target',
                name: 'destdevice',
                standardOutputs: true
            }), new HAP.ComboMakros(attrib.id, {
                name: 'destmakronr'
            }), new HAP.ComboAbstractDevices(attrib.id, {
                label: 'Shutter',
                shutter: true,
                name: 'destvirtmodule'
            })]
        }]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }];
    
    HAP.RemoteControlMappingPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            if (action.result.data.destdevice != 0) {
              Ext.getCmp(attrib.id + '/comboIRDestinations').setValue('standardOutputs');
            }
            if (action.result.data.destvirtmodule != 0) {
              Ext.getCmp(attrib.id + '/comboIRDestinations').setValue('shutter');
            }
            if (action.result.data.destmakronr != 0) {
              Ext.getCmp(attrib.id + '/comboIRDestinations').setValue('makro');
            }
            Ext.getCmp(attrib.id + '/comboIRDestinations').fireEvent('select');
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
    });
}

Ext.extend(HAP.RemoteControlMappingPanel, Ext.FormPanel, {});
HAP.RoomPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Room';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        xtype: 'fieldset',
        title: 'Base Settings',
        width: 370,
        x: 5,
        y: 5,
        labelWidth: 90,
        autoHeight: true,
        items: [new HAP.TextName(attrib.id)]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }]
    
    HAP.RoomPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
    });
}

Ext.extend(HAP.RoomPanel, Ext.FormPanel, {});
HAP.ACPanel = function(attrib){
    var workflow;
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'AC';
    this.bodyStyle = 'padding:5px 5px 0';
    this.listeners = {
        resize: function(me){
            var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
            if (wfPanel) {
                wfPanel.fireEvent('resize');
            }
        }
    };
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            //saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
                deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
                saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        xtype: 'fieldset',
        title: 'Base Settings',
        collapsible: true,
        width: 380,
        x: 5,
        y: 5,
        autoHeight: true,
        labelWidth: 100,
        items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), {
            xtype: 'checkbox',
            fieldLabel: 'Direct Simulation',
            id: attrib.id + '/checkDirectSimulation',
            checked: true
        }],
        listeners: {
            collapse: function(panel){
                var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
                if (wfPanel) {
                    wfPanel.fireEvent('resize');
                }
            },
            expand: function(panel){
                var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
                if (wfPanel) {
                    wfPanel.fireEvent('resize');
                }
            }
        }
    }, {
        xtype: 'fieldset',
        title: 'Sequence Area',
        anchor: '100%', // IE7 needs it
        id: attrib.id + '/workflowSequenceScrollViewPort',
        bodyStyle: 'overflow: auto; background-color: #ffffff',
        listeners: {
            resize: function(me, adjWidth, adjHeight, rawWidth, rawHeight){
                var el = this.getEl();
                if (el) {
                    this.setHeight(Ext.get(attrib.id).getHeight() - el.getTop());
                }
            }
        },
        html: '<div id=' + attrib.id + '/workflowSequenceBody' + ' style=\'position:relative; width:1920px; height:1200px; background-color: #ffffff\'></div>'
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Simulate',
        iconCls: 'simulate',
        id: attrib.id + '/btnSimulate',
        handler: simulate
    }, {
        text: 'Sim-Reset',
        iconCls: 'simulate',
        id: attrib.id + '/btnSimulateReset',
        handler: simulateReset
    }, {
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            var sequence = getNodesAndConnection();
            saveButtonClicked(tmp.target, tmp, {
                data: Ext.util.JSON.encode(sequence)
            });
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }];
    
    function getNodesAndConnection(){
        var sequence = new Array();
        var fig = workflow.getDocument().getFigures();
        for (var i = 0; i < fig.getSize(); i++) {
            var figure = fig.get(i);
            figure.conf.x = figure.x;
            figure.conf.y = figure.y;
            figure.conf.uid = figure.getId();
            for (var j = 1; j <= figure.conf.outPorts; j++) { // this is only for missing outport-connection check
                var port = figure.getPort('outPort' + j);
                var conns = port.getConnections();
                if (conns.size == 0) {
                    Ext.MessageBox.show({
                        title: 'Warning',
                        msg: 'Detected port with no connection. Object:' + figure.conf.name,
                        buttons: Ext.Msg.OK
                    });
                    return;
                }
            }
            for (var j = 1; j <= figure.conf.inPorts; j++) {
                var port = figure.getPort('inPort' + j);
                var conns = port.getConnections();
                if (conns.size > 1) {
                    Ext.MessageBox.show({
                        title: 'Warning',
                        msg: 'Detected more than on connection. Object:' + figure.conf.name,
                        buttons: Ext.Msg.OK
                    });
                    return;
                }
                if (conns.size == 0) {
                    Ext.MessageBox.show({
                        title: 'Warning',
                        msg: 'Detected port with no connection. Object:' + figure.conf.name,
                        buttons: Ext.Msg.OK
                    });
                    return;
                }
                for (var p = 0; p < conns.size; p++) {
                    if (j == 1) {
                        figure.conf.inPort1 = conns.get(p).getSource().getParent().getId();
                        figure.conf.inPort1Style = conns.get(p).getRouter().type;
                    }
                    if (j == 2) {
                        figure.conf.inPort2 = conns.get(p).getSource().getParent().getId();
                        figure.conf.inPort2Style = conns.get(p).getRouter().type;
                    }
                    if (j == 3) {
                        figure.conf.inPort3 = conns.get(p).getSource().getParent().getId();
                        figure.conf.inPort2Style = conns.get(p).getRouter().type;
                    }
                }
            }
            sequence[i] = figure.conf;
        }
        return sequence;
    }
    
    function simulate(){
        var sequence = getNodesAndConnection();
        var currSelect = workflow.getCurrentSelection();
        var cId = null;
        if (currSelect) {
            cId = currSelect.id;
        }
        tmp.form.submit({
            url: '/autonomouscontrol/simulate',
            params: {
                data: Ext.util.JSON.encode(sequence),
                currSelection: cId
            },
            success: function(fp, action){
                var fig = workflow.getDocument().getFigures();
                for (var i = 0; i < fig.getSize(); i++) {
                    var figure = fig.get(i);
                    for (var z = 0; z < action.result.data.length; z++) {
                        if (figure.getId() == action.result.data[z].uid) {
                            figure.setSimValue(action.result.data[z]['calcVar'], action.result.data[z]['simValue'], action.result.data[z]['simText']);
                        }
                    }
                }
            }
        });
    }
    
    function simulateReset(){
        var sequence = getNodesAndConnection();
        var currSelect = workflow.getCurrentSelection();
        var cId = null;
        if (currSelect) {
            cId = currSelect.id;
        }
        tmp.form.submit({
            url: '/autonomouscontrol/simulatereset',
            params: {
                data: Ext.util.JSON.encode(sequence),
                currSelection: cId
            },
            success: function(fp, action){
                var fig = workflow.getDocument().getFigures();
                for (var i = 0; i < fig.getSize(); i++) {
                    var figure = fig.get(i);
                    for (var z = 0; z < action.result.data.length; z++) {
                        if (figure.getId() == action.result.data[z].uid) {
                            figure.setSimValue(action.result.data[z]['calcVar'], action.result.data[z]['simValue'], action.result.data[z]['simText']);
                        }
                    }
                }
            }
        });
    }
    
    HAP.ACPanel.superclass.constructor.call(this);
    var oThis = this;
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        waitMsg: 'Loading...',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            
            workflow = new draw2d.Workflow(attrib.id + '/workflowSequenceBody');
            //var bla = document.getElementById(attrib.id + '/workflowSequenceBody').getParent().id;
            //alert (bla);
            //workflow.setViewPort(attrib.id + '/workflowSequenceScrollViewPort');
            if (Ext.isIE) 
                workflow.setViewPort(document.getElementById(attrib.id + '/workflowSequenceBody').parentElement.id);
            else 
                workflow.setViewPort(document.getElementById(attrib.id + '/workflowSequenceBody').getParent().id);
            workflow.setBackgroundImage('/static/images/grid_10.png', true);
            workflow.setGridWidth(10, 10);
            workflow.setSnapToGrid(true);
            var listener = new HAP.ACWorkflowSelector(workflow);
            workflow.addSelectionListener(listener);
            
            var droptarget = new Ext.dd.DropTarget(attrib.id + '/workflowSequenceBody', {
                ddGroup: 'TreeDD'
            });
            droptarget.notifyDrop = function(dd, e, data){
                if (data.className) {
                    var xOffset = workflow.getAbsoluteX();
                    var yOffset = workflow.getAbsoluteY();
                    //var offX = Ext.getCmp(workflow.scrollArea.id).body.dom.scrollLeft;
                    //var offY = Ext.getCmp(workflow.scrollArea.id).body.dom.scrollTop;
                    var offX = workflow.getScrollLeft();
                    var offY = workflow.getScrollTop();
                    var fig = classFactory(data.className, data.conf);
                    workflow.addFigure(fig, Math.floor((e.xy[0] - xOffset + offX) / 10) * 10, Math.floor((e.xy[1] - yOffset + offY) / 10) * 10);
                    workflow.showResizeHandles(fig);
                    workflow.setCurrentSelection(fig);
                    return true;
                }
            }
            if (action.result.data.objects) {
                var map = new Object();
                for (var i = 0; i < action.result.data.objects.length; i++) {
                    var obj = action.result.data.objects[i];
                    if (obj.type == 256) {
                        map[obj.uid] = new HAP.ACObjectAnnotate(obj);
                    }
                    else {
                        map[obj.uid] = new HAP.ACObject(obj);
                    }
                    workflow.addFigure(map[obj.uid], obj.x, obj.y);
                }
                for (var i = 0; i < action.result.data.objects.length; i++) {
                    var obj = action.result.data.objects[i];
                    if (obj.inPort1) {
                        var con = new HAP.Connection();
                        if (obj.inPort1Style == 'draw2d.NullConnectionRouter') {
                            con.setRouter(new draw2d.NullConnectionRouter());
                        }
                        else 
                            if (obj.inPort1Style == 'draw2d.ManhattanConnectionRouter') {
                                con.setRouter(new draw2d.ManhattanConnectionRouter());
                            }
                            else 
                                if (obj.inPort1Style == 'draw2d.BezierConnectionRouter') {
                                    con.setRouter(new draw2d.BezierConnectionRouter());
                                }
                        con.setSource(map[obj.inPort1].getPort('outPort1'));
                        con.setTarget(map[obj.uid].getPort('inPort1'));
                        workflow.addFigure(con);
                    }
                    if (obj.inPort2) {
                        var con = new HAP.Connection();
                        if (obj.inPort2Style == 'draw2d.NullConnectionRouter') {
                            con.setRouter(new draw2d.NullConnectionRouter());
                        }
                        else 
                            if (obj.inPort2Style == 'draw2d.ManhattanConnectionRouter') {
                                con.setRouter(new draw2d.ManhattanConnectionRouter());
                            }
                            else 
                                if (obj.inPort2Style == 'draw2d.BezierConnectionRouter') {
                                    con.setRouter(new draw2d.BezierConnectionRouter());
                                }
                        con.setSource(map[obj.inPort2].getPort('outPort1'));
                        con.setTarget(map[obj.uid].getPort('inPort2'));
                        workflow.addFigure(con);
                    }
                    if (obj.inPort3) {
                        var con = new HAP.Connection();
                        if (obj.inPort3Style == 'draw2d.NullConnectionRouter') {
                            con.setRouter(new draw2d.NullConnectionRouter());
                        }
                        else 
                            if (obj.inPort3Style == 'draw2d.ManhattanConnectionRouter') {
                                con.setRouter(new draw2d.ManhattanConnectionRouter());
                            }
                            else 
                                if (obj.inPort3Style == 'draw2d.BezierConnectionRouter') {
                                    con.setRouter(new draw2d.BezierConnectionRouter());
                                }
                        con.setSource(map[obj.inPort3].getPort('outPort1'));
                        con.setTarget(map[obj.uid].getPort('inPort3'));
                        workflow.addFigure(con);
                    }
                }
            }
            Ext.getCmp('acPropertyGrid').blank();
            Ext.getCmp('east-panel').expand(true);
        }
    });
    
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        if (Ext.getCmp('acObjectTree') == null) {
            var tmp = Ext.getCmp('objectTreePanel');
            tmp.removeAll();
            tmp.add(new HAP.ACObjectTree());
            tmp.doLayout();
            
            tmp = Ext.getCmp('objectPropertyPanel');
            tmp.removeAll();
            tmp.add(new HAP.ACPropertyGrid());
            tmp.doLayout();
        }
    });
    this.on('destroy', function(){
        Ext.getCmp('acPropertyGrid').blank();
    });
}

Ext.extend(HAP.ACPanel, Ext.FormPanel, {});

HAP.LCDGuiPanel = function(attrib){
    var workflow;
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'LCD-GUI';
    this.bodyStyle = 'padding:5px 5px 0';
    this.listeners = {
        resize: function(me){
            var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
            if (wfPanel) {
                wfPanel.fireEvent('resize');
            }
        }
    };
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            //saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
                deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
                saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        xtype: 'fieldset',
        title: 'Base Settings',
        collapsible: true,
        width: 370,
        x: 5,
        y: 5,
        autoHeight: true,
        labelWidth: 90,
        items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), new HAP.ComboAddress(attrib.id), new HAP.ComboNotify(attrib.id), new Ext.form.NumberField({
            fieldLabel: 'Timeout (s)',
            name: 'timeout',
            maxValue: 255,
            allowNegative: false,
            width: 60
        }), new Ext.form.Checkbox({
            fieldLabel: 'Is Default',
            boxLabel: ' ',
            name: 'isDefault',
            inputValue: 1
        })],
        listeners: {
            collapse: function(panel){
                var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
                if (wfPanel) {
                    wfPanel.fireEvent('resize');
                }
            },
            expand: function(panel){
                var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
                if (wfPanel) {
                    wfPanel.fireEvent('resize');
                }
            }
        }
    }, {
        xtype: 'fieldset',
        title: 'Sequence Area',
        anchor: '100%', // IE7 needs it
        id: attrib.id + '/workflowSequenceScrollViewPort',
        bodyStyle: 'overflow: auto; background-color: #ffffff',
        listeners: {
            resize: function(me, adjWidth, adjHeight, rawWidth, rawHeight){
                var el = this.getEl();
                if (el) {
                    this.setHeight(Ext.get(attrib.id).getHeight() - el.getTop());
                }
            }
        },
        html: '<div id=' + attrib.id + '/workflowSequenceBody' + ' style=\'position:relative; width:1920px; height:1200px; background-color: #ffffff\'></div>'
    }];
    var oThis = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            var sequence = new Array()
            var fig = workflow.getDocument().getFigures();
            for (var i = 0; i < fig.getSize(); i++) {
                var figure = fig.get(i);
                figure.conf.x = figure.x;
                figure.conf.y = figure.y;
                figure.conf.width = figure.getWidth()
                figure.conf.height = figure.getHeight()
                figure.conf.uid = figure.getId();
                
                if (figure.conf.type == 1) { //Menu found.
                    var mItems = figure.getChildren();
                    var mItemsConf = new Array();
                    for (var j = 0; j < mItems.getSize(); j++) {
                        var child;
                        var tmp = mItems.get(j);
                        child = tmp.conf;
                        child.x = tmp.getX();
                        child.y = tmp.getY();
                        child.width = tmp.getWidth();
                        child.uid = tmp.getId();
                        var port = tmp.getPort('outPort1');
                        var conns = port.getConnections();
                        child.outPort1X = port.getX();
                        child.outPort1Y = port.getY();
                        for (var p = 0; p < conns.size; p++) {
                            child.outPort1 = conns.get(p).getTarget().getParent().getId();
                        }
                        mItemsConf[j] = child;
                    }
                    figure.conf.mItems = mItemsConf;
                }
                for (var j = 1; j <= figure.conf.inPorts; j++) {
                    var port = figure.getPort('inPort' + j);
                    var conns = port.getConnections();
                    for (var p = 0; p < conns.size; p++) {
                        if (j == 1) {
                            figure.conf.inPort1 = conns.get(p).getSource().getParent().getId();
                            figure.conf.inPort1X = port.getX();
                            figure.conf.inPort1Y = port.getY();
                        }
                        if (j == 2) {
                            figure.conf.inPort2 = conns.get(p).getSource().getParent().getId();
                            figure.conf.inPort2X = port.getX();
                            figure.conf.inPort2Y = port.getY();
                        }
                        if (j == 3) {
                            figure.conf.inPort3 = conns.get(p).getSource().getParent().getId();
                            figure.conf.inPort3X = port.getX();
                            figure.conf.inPort3Y = port.getY();
                        }
                    }
                }
                sequence[i] = figure.conf;
            }
            saveButtonClicked(oThis.target, oThis, {
                data: Ext.util.JSON.encode(sequence)
            });
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(oThis.target, oThis)
        }
    }];
    
    HAP.LCDGuiPanel.superclass.constructor.call(this);
    
    var oThis = this;
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        waitMsg: 'Loading...',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            
            workflow = new draw2d.Workflow(attrib.id + '/workflowSequenceBody');
            if (Ext.isIE) 
                workflow.setViewPort(document.getElementById(attrib.id + '/workflowSequenceBody').parentElement.id);
            else 
                workflow.setViewPort(document.getElementById(attrib.id + '/workflowSequenceBody').getParent().id);
            workflow.setBackgroundImage('/static/images/grid_10.png', true);
            workflow.setGridWidth(10, 10);
            workflow.setSnapToGrid(true);
            
            var listener = new HAP.LCDWorkflowSelector(workflow);
            workflow.addSelectionListener(listener);
            
            var droptarget = new Ext.dd.DropTarget(attrib.id + '/workflowSequenceBody', {
                ddGroup: 'TreeDD'
            });
            droptarget.notifyDrop = function(dd, e, data){
                if (data.className) {
                    var xOffset = workflow.getAbsoluteX();
                    var yOffset = workflow.getAbsoluteY();
                    //var offX = Ext.getCmp(workflow.scrollArea.id).body.dom.scrollLeft;
                    //var offY = Ext.getCmp(workflow.scrollArea.id).body.dom.scrollTop;
                    var offX = workflow.getScrollLeft();
                    var offY = workflow.getScrollTop();
                    if (data.className == 'HAP.LCDMenuItem') {
                        compFigure = workflow.getBestCompartmentFigure(e.xy[0] - xOffset + offX, e.xy[1] - yOffset + offY);
                        if (compFigure != null) {
                            var obj = classFactory(data.className, data.conf);
                            workflow.addFigure(obj, Math.floor((e.xy[0] - xOffset + offX) / 10) * 10, Math.floor((e.xy[1] - yOffset + offY) / 10) * 10);
                            compFigure.addChild(obj);
                            compFigure.onFigureDrop(obj);
                        }
                    }
                    else {
                        var fig = classFactory(data.className, data.conf);
                        workflow.addFigure(fig, Math.floor((e.xy[0] - xOffset + offX) / 10) * 10, Math.floor((e.xy[1] - yOffset + offY) / 10) * 10);
                        workflow.showResizeHandles(fig);
                        workflow.setCurrentSelection(fig);
                    }
                    return true;
                }
            }
            if (action.result.data.objects) {
                var map = new Object();
                for (var i = 0; i < action.result.data.objects.length; i++) {
                    var obj = action.result.data.objects[i];
                    if (obj.type == 1) {
                        map[obj.uid] = new HAP.LCDMenu(obj);
                        workflow.addFigure(map[obj.uid], obj.x, obj.y);
                        for (var z = 0; z < obj.mItems.length; z++) {
                            var mItem = new HAP.LCDMenuItem(obj.mItems[z]);
                            map[obj.mItems[z].uid] = mItem;
                            workflow.addFigure(map[obj.mItems[z].uid], obj.mItems[z].x, obj.mItems[z].y);
                            map[obj.uid].addChild(mItem);
                        }
                    }
                    else {
                        map[obj.uid] = new HAP.LCDObject(obj);
                        workflow.addFigure(map[obj.uid], obj.x, obj.y);
                    }
                }
                
                for (var i = 0; i < action.result.data.objects.length; i++) {
                    var obj = action.result.data.objects[i];
                    if (obj.inPort1 && map[obj.inPort1]) {
                        var con = new HAP.Connection();
                        con.setSource(map[obj.inPort1].getPort('outPort1'));
                        con.setTarget(map[obj.uid].getPort('inPort1'));
                        workflow.addFigure(con);
                    }
                    if (obj.inPort2 && map[obj.inPort2]) {
                        var con = new HAP.Connection();
                        con.setSource(map[obj.inPort2].getPort('outPort1'));
                        con.setTarget(map[obj.uid].getPort('inPort2'));
                        workflow.addFigure(con);
                    }
                    if (obj.inPort3 && map[obj.inPort3]) {
                        var con = new HAP.Connection();
                        con.setSource(map[obj.inPort3].getPort('outPort1'));
                        con.setTarget(map[obj.uid].getPort('inPort3'));
                        workflow.addFigure(con);
                    }
                }
            }
            Ext.getCmp('lcdPropertyGrid').blank();
            Ext.getCmp('east-panel').expand(true);
        }
    });
    
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        if (Ext.getCmp('lcdObjectTree') == null) {
            Ext.getCmp('objectTreePanel').removeAll();
            Ext.getCmp('objectTreePanel').add(new HAP.LCDObjectTree());
            Ext.getCmp('objectTreePanel').doLayout(); // needed here, not sure why
            Ext.getCmp('objectPropertyPanel').removeAll();
            Ext.getCmp('objectPropertyPanel').add(new HAP.LCDPropertyGrid());
            Ext.getCmp('objectPropertyPanel').doLayout(); // dito
        }
    });
    this.on('destroy', function(){
        Ext.getCmp('lcdPropertyGrid').blank();
    });
}

Ext.extend(HAP.LCDGuiPanel, Ext.FormPanel, {});

HAP.MacroPanel = function(attrib){
    this.target = attrib.id;
    //this.layout = 'fit';
    this.id = attrib.id;
    this.closable = true;
    this.height = 470;
    this.title = 'Macro-Editor';
    this.method = 'POST';
    this.frame = true;
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.listeners = {
        resize: function(me){
            var fieldset = Ext.getCmp('fieldsetScript');
            if (fieldset) {
                fieldset.fireEvent('resize');
            }
        }
    };
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            //     saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
                deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
                saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        xtype: 'fieldset',
        title: 'Base Settings',
        autoHeight: true,
        width: 370,
        x: 5,
        y: 5,
        id: 'bla',
        labelWidth: 90,
        items: [new HAP.TextName(attrib.id), new Ext.form.NumberField({
            fieldLabel: 'Macro-Number',
            id: attrib.id + '/textMacroNumber',
            width: 230,
            allowBlank: false,
            name: 'macronr',
            minValue: 0,
            maxValue: 65535
        })]
    }, {
        xtype: 'fieldset',
        title: 'Script Editor',
        id: 'fieldsetScript',
        layout: 'anchor',
        //height: 310,
        autoWidth: true,
        x: 5,
        y: 100,
        listeners: {
            resize: function(me, adjWidth, adjHeight, rawWidth, rawHeight){
                var el = this.getEl();
                
                if (el) {
                    this.setHeight(Ext.get(attrib.id).getHeight() - 160 );
                }
            }
        },
        items: [new Ext.form.TextArea({
            width: '100%',
            height: '100%',
            name: 'script',
            id: attrib.id + '/textMacroScript',
            hideLabel: true
        })]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp);
        }
    }];
    
    HAP.DevicePanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        //params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name)
            Ext.getCmp(attrib.id + '/textName').focus();
        }
    });
    
    var oThis = this;
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        oThis.doLayout();
    });
}

Ext.extend(HAP.MacroPanel, Ext.FormPanel, {});

HAP.ACPropertyGrid = function(){
    this.id = 'acPropertyGrid';
    this.region = 'center';
    this.split = true;
    this.iconCls = 'propertyGrid';
    //this.autoHeight = true; // if missing = no items displayed, bug?
    this.height = 250;
    if (Ext.isIE) {
        this.width = 250;
    }
    this.title = 'AC Object Properties';
    this.customRenderers = {
        'HAP-Module': gridRenderer,
        'HAP-Device': gridRenderer,
        'Time-Base': gridRenderer,
        'Start Value (d)': gridRenderer
    };
    this.customEditors = {
        'HAP-Module': new Ext.grid.GridEditor(new HAP.GridComboModules({
            id: 'gridComboModules'
        })),
        'HAP-Device': new Ext.grid.GridEditor(new HAP.GridComboDevices({
            id: 'gridComboDevices'
        })),
        'Start Value (s)': new Ext.grid.GridEditor(new Ext.form.NumberField({
            maxValue: 59.9,
            selectOnFocus: true,
            decimalPrecision: 1
        })),
        'Start Value (mm: ss)': new Ext.grid.GridEditor(new Ext.form.TextField({
            regex: /^[0-5]{0,1}[0-9]{1}:[0-5]{1}[0-9]{1}$/,
            selectOnFocus: true
        })),
        'Start Value (hh: mm)': new Ext.grid.GridEditor(new Ext.form.TextField({
            regex: /^(([0-2]{1}[0-3]{1})|([0-1]{1}[0-9]{1})):[0-5]{1}[0-9]{1}$/,
            selectOnFocus: true
        })),
        'Start Value (d)': new Ext.grid.GridEditor(new HAP.GridComboWeekdays({
            id: 'gridComboWeekdays'
        })),
        'Interval (1/10s)': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 1023,
            allowDecimals: false
        })),
        'Interval (s)': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 4095
        })),
        'Interval (m)': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 1023,
            allowDecimals: false
        })),
        'Init-Value': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 255,
            allowDecimals: false
        })),
        'Output-Value': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 255,
            allowDecimals: false
        })),
        'Delay (1/10s)': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 16383,
            allowDecimals: false
        })),
        'Shift-Bits': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 8,
            allowDecimals: false
        })),
        'Value': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 255,
            allowDecimals: false
        })),
        'Value0': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 255,
            allowDecimals: false
        })),
        'Value1': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 255,
            allowDecimals: false
        })),
        'Offset': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 255,
            allowDecimals: false
        })),
        'Multiplicator': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 255,
            allowDecimals: false
        })),
        'Divisor': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 255,
            allowDecimals: false
        })),
        'Reference': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 255,
            allowDecimals: false
        })),
        'Time-Base': new Ext.grid.GridEditor(new HAP.GridComboTimeBase({
            id: 'gridComboTimeBase'
        })),
        'Label': new Ext.grid.GridEditor(new HAP.GridTextLabel(this.id, {
            id: 'gridTextLabel'
        })),
        'Simulator-Value': new Ext.grid.GridEditor(new HAP.GridSimulatorValue(this.id, {
            id: 'gridSimulatorValue'
        })),
	'Activate (Simulator)': new Ext.grid.GridEditor(new HAP.GridActivateSimulatorValue(this.id, {
            id: 'gridActivateSimulatorValue'
        }))
    };
    this.source = {};
    HAP.ACPropertyGrid.superclass.constructor.call(this);
    
}

Ext.extend(HAP.ACPropertyGrid, Ext.grid.PropertyGrid, {
    setGrid: function(figure){
        this.figure = figure;
        this.conf = figure.conf;
        this.stopEditing();
        if (this.conf.display['HAP-Module'] && this.conf.display['HAP-Module'] != 0) {
            storeAllDevices.proxy = new Ext.data.HttpProxy({
                url: '/json/getAllDevices/' + this.conf.display['HAP-Module']
            });
            storeAllDevices.load({
                callback: function(){
                    this.setSource(this.conf.display);
                },
                scope: this
            });
        }
        else {
            this.setSource(this.conf.display);
        }
    },
    blank: function(){
        this.stopEditing();
        this.setSource({});
    },
    getCurrentFigure: function(){
        return this.figure;
    }
});
HAP.ACWorkflowSelector = function(workflow){
    this.workflow = workflow;
    this.currentSelection = null;
}

HAP.ACWorkflowSelector.prototype.type = 'ACWorkflowSelector';

HAP.ACWorkflowSelector.prototype.onSelectionChanged = function(figure){
		if (this.currentSelection != null) {
        this.currentSelection.detachMoveListener(this);
    }
    this.currentSelection = figure;
    if (figure != null && !(figure instanceof HAP.Connection)) {
      Ext.getCmp('acPropertyGrid').setGrid(figure);
      this.currentSelection.attachMoveListener(this);
    }
    else {
      Ext.getCmp('acPropertyGrid').blank();
    }
}

HAP.ACWorkflowSelector.prototype.onOtherFigureMoved = function(figure){
   
}
HAP.ACPopupWindow = function(simValue, callback){
    this.id = 'acPopUpWindow';
    this.modal = true;
    this.title = 'AC-Object';
    this.layout = 'fit';
    this.width = '360';
    this.autoHeight = true;
    this.plain = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            Ext.getCmp('btnOkACPopupWindow').handler.call();
        },
        scope: this
    }];
    this.items = [{
        id: 'formACPopUpWindow',
        xtype: 'form',
        frame: true,
        autoHeight: true,
        items: [{
            xtype: 'fieldset',
            title: 'Simulator Parameter',
            collapsible: false,
            autoHeight: true,
            defaultType: 'numberfield',
            items: [new HAP.ComboASInputValueTemplates(), {
                xtype: 'numberfield',
                id: 'simValue',
                tabIndex: 1,
                minValue: 0,
                maxValue: 255,
                allowNegative: false,
                allowBlank: false,
                allowDecimals: false,
                maxLength: 3,
                width: '30',
                fieldLabel: 'Simulator-Value',
                name: 'simValue',
                hiddenName: 'simValue',
                value: simValue,
                selectOnFocus: true,
                listeners: {
                    'show': function(){
                        this.focus();
                    }
                }
            }]
        }]
    }];
    var oThis = this;
    this.buttons = [{
        text: 'OK',
        id: 'btnOkACPopupWindow',
        iconCls: 'ok',
        scope: this,
        handler: function(){
            var field = Ext.getCmp('simValue');
            if (field.isValid()) {
                callback(field.getValue());
                oThis.destroy();
            }
        }
    }, {
        text: 'Cancel',
        iconCls: 'cancel',
        handler: function(){
            oThis.destroy();
        }
    }];
    HAP.ACPopupWindow.superclass.constructor.call(this);
};

Ext.extend(HAP.ACPopupWindow, Ext.Window, {
    'afterShow': function(){
        HAP.ACPopupWindow.superclass.afterShow.call(this);
        this.setZIndex(10001);
				Ext.getCmp('simValue').focus(false, 50);
    }
});
HAP.ACObject = function(config){
    this.conf = {
        'height': 60,
        'width': 60,
        'inPorts': 0,
        'outPorts': 0,
        'name': '',
        'calcVar': 0,
        'simValue': 0,
        'display': {}
    };
    this.conf = apply(this.conf, config);
    draw2d.ImageFigure.call(this, '/static/images/ac/' + 'acObject.png');
    this.outputPort = null;
    this.setDimension(this.conf.width, this.conf.height);
    return this;
}

HAP.ACObject.prototype = new draw2d.ImageFigure;
HAP.ACObject.prototype.type = 'HAP.ACObject';
HAP.ACObject.prototype.setWorkflow = function(workflow){
    draw2d.ImageFigure.prototype.setWorkflow.call(this, workflow);
    if (workflow != null && this.outputPort == null) {
        for (var i = 1; i <= this.conf.inPorts; i++) {
            var inP = new HAP.ACInPort();
            inP.setWorkflow(workflow);
            inP.setName('inPort' + i);
            this.addPort(inP, 0, this.conf.height / (this.conf.inPorts + 1) * i);
        }
        for (var i = 1; i <= this.conf.outPorts; i++) {
            var outP = new HAP.ACOutPort();
            outP.setWorkflow(workflow);
            outP.setName('outPort' + i);
            this.addPort(outP, this.conf.width, this.conf.height / (this.conf.outPorts + 1) * i);
        }
        this.setText(this.conf.display.Label);
    }
}

HAP.ACObject.prototype.createHTMLElement = function(){
    var item = draw2d.Node.prototype.createHTMLElement.call(this);
    item.style.width = this.conf.width + 'px';
    item.style.height = this.conf.height + 'px';
    item.style.margin = '0px';
    item.style.padding = '0px';
    item.style.border = '0px';
    if (this.url != null) {
        item.style.backgroundImage = 'url(' + this.url + ')';
    }
    else {
        item.style.backgroundImage = '';
    }
    textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center';
    textDiv.style.width = this.conf.width - 7 + 'px';
    textDiv.style.paddingLeft = 4 + 'px';
    textDiv.innerHTML = this.conf.name;
    textDiv.style.paddingTop = 10 + 'px';
    item.appendChild(textDiv);
    
    this.labelDiv = document.createElement('div');
    this.labelDiv.style.position = 'absolute';
    this.labelDiv.style.top = this.conf.height + 2 + 'px';
    this.labelDiv.style.left = -20 + 'px';
    this.labelDiv.style.textAlign = 'center';
    this.labelDiv.style.fontSize = '10px';
    this.labelDiv.style.width = this.conf.width + 40 + 'px';
    this.labelDiv.style.height = 12 + 'px';
    this.labelDiv.innerHTML = '';
    item.appendChild(this.labelDiv);
    
    this.simValue = document.createElement('div');
    this.simValue.style.position = 'absolute';
    this.simValue.style.top = this.conf.height / 2 + 'px';
    this.simValue.style.left = this.conf.width + 4 + 'px';
    this.simValue.style.textAlign = 'left';
    this.simValue.style.fontSize = '10px';
    this.simValue.style.width = 40 + 'px';
    this.simValue.style.height = 12 + 'px';
    this.simValue.innerHTML = '';
    item.appendChild(this.simValue);
    
    this.disableTextSelection(this.labelDiv);
    this.disableTextSelection(textDiv);
    
    return item;
}

HAP.ACObject.prototype.setText = function(text){
    this.labelDiv.innerHTML = text;
}

HAP.ACObject.prototype.setSimValue = function(calcVar, simValue, simText){
    if ((this.conf.type == 121 || this.conf.type == 122) && simText != "") {
        this.simValue.innerHTML = simValue + " [" + simText + "]";
        this.simValue.style.width = 120 + 'px';
    }
    else {
        this.simValue.innerHTML = simValue;
        this.simValue.style.width = 40 + 'px';
    }
    this.conf.calcVar = calcVar;
    this.conf.simValue = simValue;
    var t = this.conf.type;
    if (calcVar > 0 && (t == 32 || t == 33 || t == 34 || t == 35 || t == 63 || t == 112 || t == 113 || t == 114 || t == 115 || t == 120 || t == 121 || t == 122 || t == 127)) {
        this.setImage('/static/images/ac/acObjectGreen.png');
    }
    if (calcVar == 0 && (t == 32 || t == 33 || t == 34 || t == 35 || t == 63 || t == 112 || t == 113 || t == 114 || t == 115 || t == 120 || t == 121 || t == 122 || t == 127)) {
        this.setImage('/static/images/ac/acObject.png');
    }
}

HAP.ACObject.prototype.getContextMenu = function(){
    var menu = new draw2d.Menu();
    var figure = this;
    menu.appendMenuItem(new draw2d.MenuItem('Delete', null, function(){
        figure.getWorkflow().removeFigure(figure);
    }));
    return menu;
}

HAP.ACObject.prototype.onDoubleClick = function(){
    oThis = this;
    var tmp = oThis.getWorkflow().canvasId.split('/');
    if (this.conf.type >= 32 && this.conf.type <= 35) {
        if (this.conf.calcVar > 0) {
            this.conf.calcVar = 0;
            this.setImage('/static/images/ac/acObject.png');
        }
        else {
            this.conf.calcVar = 1;
            this.setImage('/static/images/ac/acObjectGreen.png');
        }
        if (Ext.getCmp(tmp[0] + '/' + tmp[1] + '/checkDirectSimulation').getValue()) {
            Ext.getCmp(tmp[0] + '/' + tmp[1] + '/btnSimulate').handler.call();
        }
    }
    else 
        if (this.conf.type == 56 || this.conf.type == 60 || this.conf.type == 61) {
            var pw = new HAP.ACPopupWindow(this.conf.simValue, function(value){
                oThis.setSimValue(oThis.conf.calcVar, value);
                var tmp = oThis.getWorkflow().canvasId.split('/');
                if (Ext.getCmp(tmp[0] + '/' + tmp[1] + '/checkDirectSimulation').getValue()) {
                    Ext.getCmp(tmp[0] + '/' + tmp[1] + '/btnSimulate').handler.call();
                }
            });
            pw.show();
        }
        else 
            if (this.conf.type >= 112 && this.conf.type <= 115 && this.conf.calcVar > 0) {
                this.conf.calcVar = 0;
                this.setImage('/static/images/ac/acObject.png');
                if (Ext.getCmp(tmp[0] + '/' + tmp[1] + '/checkDirectSimulation').getValue()) {
                    Ext.getCmp(tmp[0] + '/' + tmp[1] + '/btnSimulate').handler.call();
                }
            }
}

HAP.ACObjectImage = function(conf){ // for tree view
    this.conf = conf;
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.position = 'absolute';
    div.style.backgroundImage = 'url(/static/images/ac/' + this.conf.inPorts + '_' + this.conf.outPorts + '.png)';
    //div.style.backgroundColor = '#ff0000';
    textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center';
    textDiv.style.width = this.conf.width - 15 + 'px';
    textDiv.innerHTML = this.conf.name;
    //textDiv.style.backgroundColor = '#00ff00';
    textDiv.style.paddingLeft = 8 + 'px';
    textDiv.style.paddingTop = 10 + 'px';
    div.appendChild(textDiv);
    return div;
}

HAP.ACObjectAnnotate = function(conf){
    this.conf = conf;
    draw2d.Annotation.call(this, this.conf.display.Label);
    this.setDimension(300, 40);
    this.setBackgroundColor(new draw2d.Color(255, 255, 255));
    return this;
}

HAP.ACObjectAnnotate.prototype = new draw2d.Annotation();

HAP.ACObjectAnnotate.prototype.getContextMenu = function(){
    var menu = new draw2d.Menu();
    var figure = this;
    menu.appendMenuItem(new draw2d.MenuItem('Delete', null, function(){
        figure.getWorkflow().removeFigure(figure);
    }));
    return menu;
}

HAP.ACObjectAnnotate.prototype.onDoubleClick = function(){
    return;
}
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
/**
 * @author bendowski
 */
HAP.ACObjectTree = function(){
    this.id = 'acObjectTree';
    HAP.ACObjectTree.superclass.constructor.call(this);
}

Ext.extend(HAP.ACObjectTree, Ext.Panel, {
    onRender: function(ct, pos){
        HAP.ACObjectTree.superclass.onRender.call(this, ct, pos);
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'GET',
            url: '/autonomouscontrol/getAllObjects'
        });
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.util.JSON.decode(param.responseText);
            if (response.success) {
                var x;
                var y;
                var size = response.data.length;
                for (var i = 0; i < size; i++) {
                    if (i % 2 == 0) {
                        x = 10;
                    }
                    else {
                        x = 100;
                    }
                    y = parseInt(i / 2) * 70 + 10;
                    
                    var img = new HAP.ACObjectImage({
                        id: response.data[i].id,
                        name: response.data[i].shortName,
                        inPorts: response.data[i].inPorts,
                        outPorts: response.data[i].outPorts,
                        height: 60,
                        width: 68,
                        top: y,
                        left: x
                    });
                    ct.appendChild(img);
                     
                    var className = 'HAP.ACObject';
                    if (response.data[i].type == 256) { // its a comment
                      className = 'HAP.ACObjectAnnotate';
                    }
                    var dragsource = new Ext.dd.DragSource(img.id, {
                        ddGroup: 'TreeDD',
                        dragData: {
                            className: className,
                            conf: {
                                id: response.data[i].id,
                                type: response.data[i].type,
                                name: response.data[i].shortName,
                                inPorts: response.data[i].inPorts,
                                outPorts: response.data[i].outPorts,
                                display: response.data[i].display
                            }
                        }
                    });
                    
                }
            }
        });
    }
});



/**
 * @author Ben
 */
HAP.LCDPropertyGrid = function(){
    this.id = 'lcdPropertyGrid';
    this.region = 'center';
    this.split = true;
    this.iconCls = 'propertyGrid';
    //this.autoHeight = true; // if missing = no items displayed, bug?
    this.height = 250;
    if (Ext.isIE) {
        this.width = 250;
    }
    this.title = 'LCD Object Properties';
    this.customRenderers = {
        'HAP-Module': gridRenderer,
        'HAP-Device': gridRenderer
    };
    this.customEditors = {
        'HAP-Module': new Ext.grid.GridEditor(new HAP.GridComboModules({
            id: 'gridComboModules'
        })),
        'HAP-Device': new Ext.grid.GridEditor(new HAP.GridComboDevices({
            id: 'gridComboDevices'
        })),
        'Label': new Ext.grid.GridEditor(new HAP.GridTextLabel(this.id, {
            id: 'gridTextLabel',
            selectOnFocus: true
        })),
        'Label (14 max.)': new Ext.grid.GridEditor(new HAP.GridTextLabel(this.id, {
            id: 'gridTextLabel14',
            maxLength: 14,
            selectOnFocus: true
        })),
        'Label (16 max.)': new Ext.grid.GridEditor(new HAP.GridTextLabel(this.id, {
            id: 'gridTextLabel16',
            maxLength: 16,
            selectOnFocus: true
        })),
        'Refresh': new Ext.grid.GridEditor(new Ext.form.NumberField({
            selectOnFocus: true,
            maxValue: 255,
            allowDecimals: false
        }))
    };
    this.source = {};
    HAP.LCDPropertyGrid.superclass.constructor.call(this);
    
    //this.store.sortInfo = null; // this little fu** statement avoids sorting
}

Ext.extend(HAP.LCDPropertyGrid, Ext.grid.PropertyGrid, {
    setGrid: function(figure){
        this.figure = figure;
        this.conf = figure.conf;
        this.stopEditing(); // wichtig, sonst fehler
        if (this.conf.display['HAP-Module'] && this.conf.display['HAP-Module'] != 0) {
            storeAllDevices.proxy = new Ext.data.HttpProxy({
                url: 'getjson/getAllDevices/' + this.conf.display['HAP-Module']
            });
            storeAllDevices.load({
                callback: function(){
                    this.setSource(this.conf.display);
                },
                scope: this
            });
        }
        else {
            this.setSource(this.conf.display);
        }
    },
    blank: function(){
        this.stopEditing();
        this.setSource({});
    },
    getCurrentFigure: function(){
        return this.figure;
    }
});
HAP.LCDWorkflowSelector = function(workflow){
    this.workflow = workflow;
    this.currentSelection = null;
}

HAP.LCDWorkflowSelector.prototype.type = 'LCDWorkflowSelector';
HAP.LCDWorkflowSelector.prototype.onSelectionChanged = function(figure){
    if (this.currentSelection != null) {
        this.currentSelection.detachMoveListener(this);
    }
    this.currentSelection = figure;
    if (figure != null && !(figure instanceof HAP.Connection)) {
      Ext.getCmp('lcdPropertyGrid').setGrid(figure);
      this.currentSelection.attachMoveListener(this);
    }
    else {
      Ext.getCmp('lcdPropertyGrid').blank();
    }
}

HAP.LCDWorkflowSelector.prototype.onOtherFigureMoved = function(figure){
}
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
/**
 * @author Ben
 */

HAP.LCDObjectTree = function(){
    this.id = 'lcdObjectTree';
    HAP.LCDObjectTree.superclass.constructor.call(this);
}

Ext.extend(HAP.LCDObjectTree, Ext.Panel, {
    onRender: function(ct, pos){
        HAP.LCDObjectTree.superclass.onRender.call(this, ct, pos);
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'GET',
            url: '/lcdgui/getAllObjects'
        });
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.util.JSON.decode(param.responseText);
            if (response.success) {
                var x;
                var y;
                var size = response.data.length;
                for (var i = 0; i < size; i++) {
                    if (i % 2 == 0) {
                        x = 10;
                    }
                    else {
                        x = 100;
                    }
                    y = parseInt(i / 2) * 70 + 10;
                    var img;
                    switch (response.data[i].type) {
                        case 1: // menu
                            className = 'HAP.LCDMenu';
                            img = new HAP.LCDMenuImage({
                                id: response.data[i].id,
                                name: response.data[i].shortName,
                                inPorts: response.data[i].inPorts,
                                outPorts: response.data[i].outPorts,
                                height: 60,
                                width: 68,
                                top: y,
                                left: x
                            });
                            break;
                        case 0: // menu-item
                            className = 'HAP.LCDMenuItem';
                            img = new HAP.LCDMenuItemImage({
                                id: response.data[i].id,
                                name: response.data[i].shortName,
                                inPorts: response.data[i].inPorts,
                                outPorts: response.data[i].outPorts,
                                height: 60,
                                width: 68,
                                top: y,
                                left: x
                            });
                            break;
                        default:
                            className = 'HAP.LCDObject';
                            img = new HAP.LCDObjectImage({
                                id: response.data[i].id,
                                name: response.data[i].shortName,
                                inPorts: response.data[i].inPorts,
                                outPorts: response.data[i].outPorts,
                                height: 20,
                                width: 68,
                                top: y + 20,
                                left: x
                            });
                    }
                    ct.appendChild(img);
                    
                    var dragsource = new Ext.dd.DragSource(img.id, {
                        ddGroup: 'TreeDD',
                        dragData: {
                            className: className,
                            conf: {
                                id: response.data[i].id,
                                type: response.data[i].type,
                                name: response.data[i].shortName,
                                inPorts: response.data[i].inPorts,
                                outPorts: response.data[i].outPorts,
                                display: response.data[i].display
                            }
                        }
                    });
                    
                }
            }
        });
    }
});




HAP.GUIViewPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'GUI-View';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.layout = 'absolute';
    this.width = 800;
    this.height = 620;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    
    this.items = [{
        xtype: 'fieldset',
        title: 'Base Settings',
        width: 370,
        autoHeight: true,
        x: 5,
        y: 5,
        labelWidth: 90,
        items: [new HAP.TextName(attrib.id), new Ext.form.Checkbox({
            fieldLabel: 'Is Default',
            boxLabel: ' ',
            name: 'isDefault',
            inputValue: 1
        })]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }]
    
    HAP.GUIViewPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
    });
}

Ext.extend(HAP.GUIViewPanel, Ext.FormPanel, {});
/**
 * @author bendowski
 */
HAP.GUIScenePanel = function(attrib){
    var workflow;
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'GUI-Scene';
    this.bodyStyle = 'padding:5px 5px 0';
    this.listeners = {
        resize: function(me){
            var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
            if (wfPanel) {
                wfPanel.fireEvent('resize');
            };
                    }
    };
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            //saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
                deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
                saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        xtype: 'fieldset',
        title: 'Base Settings',
        collapsible: true,
        width: 370,
        x: 5,
        y: 5,
        autoHeight: true,
        labelWidth: 90,
        items: [new HAP.TextName(attrib.id), new HAP.ComboGuiViews(attrib.id), new Ext.form.Checkbox({
            fieldLabel: 'Is Default',
            boxLabel: ' ',
            name: 'isDefault',
            inputValue: 1
        }), new Ext.form.Checkbox({
            fieldLabel: 'Center X',
            boxLabel: ' ',
            name: 'centerX',
            inputValue: 1
        }), new Ext.form.Checkbox({
            fieldLabel: 'Center Y',
            boxLabel: ' ',
            name: 'centerY',
            inputValue: 1
        })],
        listeners: {
            collapse: function(panel){
                var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
                if (wfPanel) {
                    wfPanel.fireEvent('resize');
                }
            },
            expand: function(panel){
                var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
                if (wfPanel) {
                    wfPanel.fireEvent('resize');
                }
            }
        }
    }, {
        xtype: 'fieldset',
        title: 'Sequence Area',
        anchor: '100%', // IE7 needs it
        id: attrib.id + '/workflowSequenceScrollViewPort',
        bodyStyle: 'overflow: auto; background-color: #ffffff',
        listeners: {
            resize: function(me, adjWidth, adjHeight, rawWidth, rawHeight){
                var el = this.getEl();
                if (el) {
                    this.setHeight(Ext.get(attrib.id).getHeight() - el.getTop());
                }
            }
        },
        html: '<div id=' + attrib.id + '/workflowSequenceBody' + ' style=\'position:relative; width:1920px; height:1200px; background-color: #ffffff\'></div>'
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            var sequence = new Array()
            var fig = workflow.getDocument().getFigures();
            for (var i = 0; i < fig.getSize(); i++) {
                var figure = fig.get(i);
                sequence[i] = figure.guiObject.conf;
            }
            saveButtonClicked(oThis.target, oThis, {
                data: Ext.util.JSON.encode(sequence)
            });
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp);
        }
    }];
    
    HAP.GUIScenePanel.superclass.constructor.call(this);
    
    var oThis = this;
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room + '&viewId=' + attrib.viewId,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            
            workflow = new draw2d.Workflow(attrib.id + '/workflowSequenceBody');
            workflow.getContextMenu = function(){
                var menu = new draw2d.Menu();
                var wf = this;
                var figure = this.getCurrentSelection();
                if (figure) {
                  menu.appendMenuItem(new draw2d.MenuItem('Copy', null, function(){
                    figure.guiObject.id = 0;
                    figure.guiObject.conf.id = 0;
                    cutNPaste = Ext.ux.clone(figure.guiObject.conf);
                  }));
                  menu.appendMenuItem(new draw2d.MenuItem('Delete', null, function(){
                    wf.removeFigure(figure);
                    
                  }));
                }
                menu.appendMenuItem(new draw2d.MenuItem('Paste', null, function(){
                    //var offX = Ext.getCmp(wf.scrollArea.id).body.dom.scrollLeft;
                    //var offY = Ext.getCmp(wf.scrollArea.id).body.dom.scrollTop;
                    var offX = wf.getScrollLeft();
                    var offY = wf.getScrollTop();
                    var fig = new HAP.GUIObject(cutNPaste);
                    //wf.addFigure(fig, wf.mouseDownPosX + offX, wf.mouseDownPosY + offY);
                    wf.addFigure(fig, wf.currentMouseX + offX, wf.currentMouseY + offY);
                }));
                menu.appendMenuItem(new draw2d.MenuItem('Toggle Grid', null, function(){
                    if (wf.snap) {
                        wf.snap = false;
                    }
                    else {
                        wf.snap = true;
                    }
                    wf.setSnapToGrid(wf.snap);
                }));
                return menu;
                
            };
            if (Ext.isIE) 
                workflow.setViewPort(document.getElementById(attrib.id + '/workflowSequenceBody').parentElement.id);
            else 
                workflow.setViewPort(document.getElementById(attrib.id + '/workflowSequenceBody').getParent().id);
            workflow.setBackgroundImage('/static/images/grid_10.png', true);
            workflow.setGridWidth(10, 10);
            workflow.snap = true; // custom !
            workflow.setSnapToGrid(workflow.snap);
            var listener = new HAP.GUIWorkflowSelector(workflow);
            workflow.addSelectionListener(listener);
            
            var droptarget = new Ext.dd.DropTarget(attrib.id + '/workflowSequenceBody', {
                ddGroup: 'TreeDD'
            });
            droptarget.notifyDrop = function(dd, e, data){
                if (data.type) {
                    var xOffset = workflow.getAbsoluteX();
                    var yOffset = workflow.getAbsoluteY();
                    //var offX = Ext.getCmp(workflow.scrollArea.id).body.dom.scrollLeft;
                    //var offY = Ext.getCmp(workflow.scrollArea.id).body.dom.scrollTop;
                    var offX = workflow.getScrollLeft();
                    var offY = workflow.getScrollTop();
                    var fig = new HAP.GUIObject(data);
                    workflow.addFigure(fig, Math.floor((e.xy[0] - xOffset + offX) / 10) * 10, Math.floor((e.xy[1] - yOffset + offY) / 10) * 10);
                    workflow.showResizeHandles(fig);
                    workflow.setCurrentSelection(fig);
                    return true;
                }
            }
            if (action.result.data.objects) {
                for (var i = 0; i < action.result.data.objects.length; i++) {
                    var obj = action.result.data.objects[i];
                    workflow.addFigure(new HAP.GUIObject(obj), obj.display.x, obj.display.y);
                }
            }
            Ext.getCmp('guiPropertyGrid').blank();
            Ext.getCmp('east-panel').expand(true);
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        if (Ext.getCmp('guiObjectTree') == null) {
            var otp = Ext.getCmp('objectTreePanel');
            otp.removeAll();
            otp.add(new HAP.GUIObjectTree());
            otp.doLayout();
            var opp = Ext.getCmp('objectPropertyPanel');
            opp.removeAll();
            opp.add(new HAP.GUIPropertyGrid());
            opp.doLayout();
        }
    });
    this.on('destroy', function(){
        Ext.getCmp('guiPropertyGrid').blank();
    });
}

Ext.extend(HAP.GUIScenePanel, Ext.FormPanel, {});




HAP.GUIWorkflowSelector = function(workflow){
    this.workflow = workflow;
    this.currentSelection = null;
}

HAP.GUIWorkflowSelector.prototype.type = 'GUIWorkflowSelector';

HAP.GUIWorkflowSelector.prototype.onSelectionChanged = function(figure){
    
    if (this.currentSelection != null) {
        this.currentSelection.detachMoveListener(this);
    }
    this.currentSelection = figure;
    if (figure != null) {
      Ext.getCmp('guiPropertyGrid').setGrid(figure);
      this.currentSelection.attachMoveListener(this);
    }
    else {
      Ext.getCmp('guiPropertyGrid').blank();
    }
}


HAP.GUIWorkflowSelector.prototype.onOtherFigureMoved = function(figure){
}
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


/*
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
*/

HAP.GUIObject.prototype.setGUIObjectConfig = function(){
    this.guiObject.setConfig(this.guiObject.conf, true);
    if (this.guiObject.conf.display['Value'] != null) {
      this.guiObject.setValue(this.guiObject.conf.display['Value']);
    }
    this.setPosition(this.guiObject.conf.display['x'], this.guiObject.conf.display['y']);
    this.setDimension(this.guiObject.conf.display['width'], this.guiObject.conf.display['height'], true);
    this.setZIndex(this.guiObject.conf.display['z-Index']);
}


//draw2d.Workflow.prototype.showMenu = function(/*:draw2d.Menu*/menu,/*:int*/ xPos,/*:int*/ yPos){
//    if (this.menu != null) {
//        this.html.removeChild(this.menu.getHTMLElement());
//        this.menu.setWorkflow();
//    }
//    this.menu = menu;
//    if (this.menu != null) {
 //       this.menu.setWorkflow(this);
//				this.menu.setPosition(xPos, yPos);
 //       this.html.appendChild(this.menu.getHTMLElement());
  //      this.menu.paint();
  //  }
//}
/**
 * @author bendowski
 */
HAP.Switch = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.Switch';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        'HAP-Module': 0,
        'HAP-Device': 0,
        x: 0,
        y: 0,
        height: 60,
        width: 60,
        'On-Image': this.conf.imagePath + 'btnLightOn.png',
        'Off-Image': this.conf.imagePath + 'btnLightOff.png',
        'Transition-Image': this.conf.imagePath + 'btnLightOff.png',
        'z-Index': 2,
        'Show status text': true,
        'Font-family': 'sans-serif',
        'Font-size': 14,
        'Font-weight': 'bold',
        'Font-color': '000000',
        'Value-Suffix': '%',
        'Update Interval (s)': 10,
        'Value': 0,
        'Off-Value': 0,
        'On-Value': 100
    };
    this.conf = apply(this.conf, config);
    this.value = this.conf.display['Value'];
    this.create(this.conf)
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.Switch.prototype.create = function(conf){
    this.div = document.createElement('div');
    this.img = document.createElement('img');
    this.stat = document.createElement('div');
    this.layer = document.createElement('img');
    this.div.appendChild(this.img);
    this.div.appendChild(this.stat);
    this.div.appendChild(this.layer);
    return this.div;
}

HAP.Switch.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    this.div.style.position = 'absolute';
    this.div.style.width = this.conf.display['width'] + 'px';
    this.div.style.height = this.conf.display['height'] + 'px';
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
    
    this.img.style.position = 'absolute';
    this.img.style.width = this.conf.display['width'] + 'px';
    this.img.style.height = this.conf.display['height'] + 'px';
    this.img.style.zIndex = this.conf.display['z-Index'];
    this.img.src = this.conf.display['Off-Image'];
    
    this.stat.style.display = 'block';
    this.stat.style.position = 'absolute';
    this.stat.style.width = this.conf.display['width'] + 'px';
    this.stat.style.height = this.conf.display['height'] + 'px';
    this.stat.style.lineHeight = this.conf.display['height'] + 'px';
    this.stat.style.fontFamily = this.conf.display['Font-family'];
    this.stat.style.fontSize = this.conf.display['Font-size'] + 'px';
    this.stat.style.fontWeight = this.conf.display['Font-weight'];
    this.stat.style.color = '#' + this.conf.display['Font-color'];
    this.stat.align = 'center';
    this.stat.style.zIndex = this.conf.display['z-Index'];
    this.stat.innerHTML = this.value + this.conf.display['Value-Suffix'];
    
    if (this.conf.display['Show status text']) {
        this.stat.style.display = 'block';
    }
    else {
        this.stat.style.display = 'none';
    }
    
    this.layer.style.position = 'absolute';
    this.layer.style.width = this.conf.display['width'] + 'px';
    this.layer.style.height = this.conf.display['height'] + 'px';
    this.layer.style.zIndex = this.conf.display['z-Index'];
    this.layer.src = '/static/images/gui/null.gif';
    
    var oThis = this;
    this.attachEvent('onclick', function(){
        if (oThis.value > 0) {
            oThis.setRequest(oThis.conf.display['Off-Value'] || 0);
        }
        else {
            oThis.setRequest(oThis.conf.display['On-Value'] || 100);
        }
    }, viewPortCall);
}


HAP.Switch.prototype.attachEvent = function(event, handler, viewPortCall){
    if (!viewPortCall && event == 'onclick') {
        this.layer.onclick = handler;
    }
}

HAP.Switch.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    this.img.style.width = width + 'px';
    this.stat.style.width = width + 'px';
    this.layer.style.width = width + 'px';
}

HAP.Switch.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    this.img.style.height = height + 'px';
    this.stat.style.height = height + 'px';
    this.stat.style.lineHeight = height + 'px';
    this.layer.style.height = height + 'px';
}

HAP.Switch.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.Switch.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Switch.prototype.setImage = function(img){
    this.img.src = img;
}

HAP.Switch.prototype.setFontSize = function(size){
    this.stat.style.fontSize = size + 'px';
}

HAP.Switch.prototype.setFontWeight = function(weight){
    this.stat.style.fontWeight = weight;
}

HAP.Switch.prototype.setFontColor = function(color){
    this.stat.style.color = color;
}

HAP.Switch.prototype.showStatusText = function(show){
    if (show) {
        this.stat.style.display = 'block';
    }
    else {
        this.stat.style.display = 'none';
    }
}

HAP.Switch.prototype.setRequest = function(value){
    if (this.conf.display['Transition-Image']) {
        this.img.src = this.conf.display['Transition-Image'];
    }
    var oThis = this;
    YAHOO.util.Connect.asyncRequest('get', '/gui/setDevice/' + this.conf.display['HAP-Module'] + '/' + this.conf.display['HAP-Device'] + '/' + value, {
        success: function(o){
            if (YAHOO.lang.JSON.isValid(o.responseText)) {
                var response = YAHOO.lang.JSON.parse(o.responseText);
                if (response.success) {
                    oThis.setValue(response.data.value);
                }
            }
            else {
                document.getElementById('rootDiv').innerHTML = o.responseText;
            }
        }
    });
}

HAP.Switch.prototype.setValue = function(value){
    if (value > 0) {
        this.img.src = this.conf.display['On-Image'];
    }
    else {
        this.img.src = this.conf.display['Off-Image'];
    }
    this.value = value;
    this.stat.innerHTML = value + this.conf.display['Value-Suffix'];
    return;
}

HAP.SwitchImage = function(conf){
    this.conf = conf;
    this.conf.imagePath = '/static/images/gui/';
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.textAlign = 'center';
    div.style.position = 'absolute';
    
    var img = document.createElement('img');
    img.src = this.conf.imagePath + 'switch_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
/**
 * @author bendowski
 */
HAP.Macro = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.Macro';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        'HAP-Macro': 0,
        x: 0,
        y: 0,
        height: 60,
        width: 60,
        'On-Image': this.conf.imagePath + 'btnMacroOn.png',
        'Off-Image': this.conf.imagePath + 'btnMacroOff.png',
        'Transition-Image': this.conf.imagePath + 'btnMacroTransition.png',
        'z-Index': 2,
        'Show status text': false,
        'Font-family': 'sans-serif',
        'Font-size': 14,
        'Font-weight': 'bold',
        'Font-color': '000000',
        'Value-Suffix': '%',
        'Update Interval (s)': 3600,
        'Value': 0,
        'Off-Value': 0,
        'On-Value': 100
    };
    this.conf = apply(this.conf, config);
    this.value = this.conf.display['Value'];
    this.create(this.conf)
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.Macro.prototype.create = function(conf){
    this.div = document.createElement('div');
    this.img = document.createElement('img');
    this.stat = document.createElement('div');
    this.layer = document.createElement('img');
    this.div.appendChild(this.img);
    this.div.appendChild(this.stat);
    this.div.appendChild(this.layer);
    return this.div;
}

HAP.Macro.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    this.div.style.position = 'absolute';
    this.div.style.width = this.conf.display['width'] + 'px';
    this.div.style.height = this.conf.display['height'] + 'px';
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
    
    this.img.style.position = 'absolute';
    this.img.style.width = this.conf.display['width'] + 'px';
    this.img.style.height = this.conf.display['height'] + 'px';
    this.img.style.zIndex = this.conf.display['z-Index'];
    this.img.src = this.conf.display['Off-Image'];
    
    this.stat.style.display = 'block';
    this.stat.style.position = 'absolute';
    this.stat.style.width = this.conf.display['width'] + 'px';
    this.stat.style.height = this.conf.display['height'] + 'px';
    this.stat.style.lineHeight = this.conf.display['height'] + 'px';
    this.stat.style.fontFamily = this.conf.display['Font-family'];
    this.stat.style.fontSize = this.conf.display['Font-size'] + 'px';
    this.stat.style.fontWeight = this.conf.display['Font-weight'];
    this.stat.style.color = '#' + this.conf.display['Font-color'];
    this.stat.align = 'center';
    this.stat.style.zIndex = this.conf.display['z-Index'];
    this.stat.innerHTML = this.value + this.conf.display['Value-Suffix'];
    
    if (this.conf.display['Show status text']) {
        this.stat.style.display = 'block';
    }
    else {
        this.stat.style.display = 'none';
    }
    
    this.layer.style.position = 'absolute';
    this.layer.style.width = this.conf.display['width'] + 'px';
    this.layer.style.height = this.conf.display['height'] + 'px';
    this.layer.style.zIndex = this.conf.display['z-Index'];
    this.layer.src = '/static/images/gui/null.gif';
    
    var oThis = this;
    this.attachEvent('onclick', function(){
        if (oThis.value > 0) {
            oThis.setRequest(oThis.conf.display['Off-Value'] || 0);
        }
        else {
            oThis.setRequest(oThis.conf.display['On-Value'] || 100);
        }
    }, viewPortCall);
}


HAP.Macro.prototype.attachEvent = function(event, handler, viewPortCall){
    if (!viewPortCall && event == 'onclick') {
        this.layer.onclick = handler;
    }
}

HAP.Macro.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    this.img.style.width = width + 'px';
    this.stat.style.width = width + 'px';
    this.layer.style.width = width + 'px';
}

HAP.Macro.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    this.img.style.height = height + 'px';
    this.stat.style.height = height + 'px';
    this.stat.style.lineHeight = height + 'px';
    this.layer.style.height = height + 'px';
}

HAP.Macro.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.Macro.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Macro.prototype.setImage = function(img){
    this.img.src = img;
}

HAP.Macro.prototype.setFontSize = function(size){
    this.stat.style.fontSize = size + 'px';
}

HAP.Macro.prototype.setFontWeight = function(weight){
    this.stat.style.fontWeight = weight;
}

HAP.Macro.prototype.setFontColor = function(color){
    this.stat.style.color = color;
}

HAP.Macro.prototype.showStatusText = function(show){
    if (show) {
        this.stat.style.display = 'block';
    }
    else {
        this.stat.style.display = 'none';
    }
}

HAP.Macro.prototype.setRequest = function(value){
    if (this.conf.display['Transition-Image']) {
        this.img.src = this.conf.display['Transition-Image'];
    }
    var oThis = this;
    YAHOO.util.Connect.asyncRequest('get', '/gui/executeMacro/' + this.conf.display['HAP-Macro'], {
        success: function(o){
            if (YAHOO.lang.JSON.isValid(o.responseText)) {
                var response = YAHOO.lang.JSON.parse(o.responseText);
                if (response.success) {
                    oThis.setValue(response.data.value);
                }
            }
            else {
                document.getElementById('rootDiv').innerHTML = o.responseText;
            }
        }
    });
}

HAP.Macro.prototype.setValue = function(value){
    if (value > 0) {
        this.img.src = this.conf.display['On-Image'];
    }
    else {
        this.img.src = this.conf.display['Off-Image'];
    }
    this.value = value;
    this.stat.innerHTML = value + this.conf.display['Value-Suffix'];
    return;
}

HAP.MacroImage = function(conf){
    this.conf = conf;
    this.conf.imagePath = '/static/images/gui/';
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.textAlign = 'center';
    div.style.position = 'absolute';
    
    var img = document.createElement('img');
    img.src = this.conf.imagePath + 'Macro_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
/**
 * @author bendowski
 */
HAP.Trigger = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.Trigger';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        'HAP-Module': 0,
        'HAP-TriggerDevices': 0,
        'Trigger': 0,
        x: 0,
        y: 0,
        height: 60,
        width: 60,
        'On-Image': this.conf.imagePath + 'btnTriggerOn.png',
        'Off-Image': this.conf.imagePath + 'btnTriggerOff.png',
        'Transition-Image': this.conf.imagePath + 'btnTriggerTransition.png',
        'z-Index': 2,
        'Show status text': false,
        'Font-family': 'sans-serif',
        'Font-size': 14,
        'Font-weight': 'bold',
        'Font-color': '000000',
        'Value-Suffix': '%',
        'Update Interval (s)': 3600,
        'Value': 0
    };
    this.conf = apply(this.conf, config);
    this.value = this.conf.display['Value'];
    this.create(this.conf)
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.Trigger.prototype.create = function(conf){
    this.div = document.createElement('div');
    this.img = document.createElement('img');
    this.stat = document.createElement('div');
    this.layer = document.createElement('img');
    this.div.appendChild(this.img);
    this.div.appendChild(this.stat);
    this.div.appendChild(this.layer);
    return this.div;
}

HAP.Trigger.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    this.div.style.position = 'absolute';
    this.div.style.width = this.conf.display['width'] + 'px';
    this.div.style.height = this.conf.display['height'] + 'px';
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
    
    this.img.style.position = 'absolute';
    this.img.style.width = this.conf.display['width'] + 'px';
    this.img.style.height = this.conf.display['height'] + 'px';
    this.img.style.zIndex = this.conf.display['z-Index'];
    this.img.src = this.conf.display['Off-Image'];
    
    this.stat.style.display = 'block';
    this.stat.style.position = 'absolute';
    this.stat.style.width = this.conf.display['width'] + 'px';
    this.stat.style.height = this.conf.display['height'] + 'px';
    this.stat.style.lineHeight = this.conf.display['height'] + 'px';
    this.stat.style.fontFamily = this.conf.display['Font-family'];
    this.stat.style.fontSize = this.conf.display['Font-size'] + 'px';
    this.stat.style.fontWeight = this.conf.display['Font-weight'];
    this.stat.style.color = '#' + this.conf.display['Font-color'];
    this.stat.align = 'center';
    this.stat.style.zIndex = this.conf.display['z-Index'];
    this.stat.innerHTML = this.value + this.conf.display['Value-Suffix'];
    
    if (this.conf.display['Show status text']) {
        this.stat.style.display = 'block';
    }
    else {
        this.stat.style.display = 'none';
    }
    
    this.layer.style.position = 'absolute';
    this.layer.style.width = this.conf.display['width'] + 'px';
    this.layer.style.height = this.conf.display['height'] + 'px';
    this.layer.style.zIndex = this.conf.display['z-Index'];
    this.layer.src = '/static/images/gui/null.gif';
    
    var oThis = this;
    this.attachEvent('onclick', function(){
        if (oThis.value > 0) {
            oThis.setRequest(oThis.conf.display['Off-Value'] || 0);
        }
        else {
            oThis.setRequest(oThis.conf.display['On-Value'] || 100);
        }
    }, viewPortCall);
}


HAP.Trigger.prototype.attachEvent = function(event, handler, viewPortCall){
    if (!viewPortCall && event == 'onclick') {
        this.layer.onclick = handler;
    }
}

HAP.Trigger.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    this.img.style.width = width + 'px';
    this.stat.style.width = width + 'px';
    this.layer.style.width = width + 'px';
}

HAP.Trigger.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    this.img.style.height = height + 'px';
    this.stat.style.height = height + 'px';
    this.stat.style.lineHeight = height + 'px';
    this.layer.style.height = height + 'px';
}

HAP.Trigger.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.Trigger.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Trigger.prototype.setImage = function(img){
    this.img.src = img;
}

HAP.Trigger.prototype.setFontSize = function(size){
    this.stat.style.fontSize = size + 'px';
}

HAP.Trigger.prototype.setFontWeight = function(weight){
    this.stat.style.fontWeight = weight;
}

HAP.Trigger.prototype.setFontColor = function(color){
    this.stat.style.color = color;
}

HAP.Trigger.prototype.showStatusText = function(show){
    if (show) {
        this.stat.style.display = 'block';
    }
    else {
        this.stat.style.display = 'none';
    }
}

HAP.Trigger.prototype.setRequest = function(value){
    if (this.conf.display['Transition-Image']) {
        this.img.src = this.conf.display['Transition-Image'];
    }
    var oThis = this;
    YAHOO.util.Connect.asyncRequest('get', '/gui/modifyTrigger/' + this.conf.display['HAP-Module'] + '/' + this.conf.display['HAP-TriggerDevices'] + '/'+ this.conf.display['Trigger'] + '/' + this.conf.display['Value'], {
        success: function(o){
            if (YAHOO.lang.JSON.isValid(o.responseText)) {
                var response = YAHOO.lang.JSON.parse(o.responseText);
                if (response.success) {
                    oThis.setValue(response.data.value);
                }
            }
            else {
                document.getElementById('rootDiv').innerHTML = o.responseText;
            }
        }
    });
}

HAP.Trigger.prototype.setValue = function(value){
    if (value > (this.value-0.0625) && value < (this.value+0.0625)) {
        this.img.src = this.conf.display['On-Image'];
        this.value = value;
        this.stat.innerHTML = value + this.conf.display['Value-Suffix'];
    }
    else {
        this.img.src = this.conf.display['Off-Image'];
    }
    return;
}

HAP.TriggerImage = function(conf){
    this.conf = conf;
    this.conf.imagePath = '/static/images/gui/';
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.textAlign = 'center';
    div.style.position = 'absolute';
    
    var img = document.createElement('img');
    img.src = this.conf.imagePath + 'Trigger_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
/**
 * @author bendowski
 */
HAP.Slider = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.Slider';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        'HAP-Module': 0,
        'HAP-Device': 0,
        x: 0,
        y: 0,
        height: 364,
        width: 40,
        'Button X-Offset': -50,
        'Button Y-Offset': -50,
        'Button Height': 48,
        'Button Width': 48,
        'Button On-Image': this.conf.imagePath + 'ledgreen.png',
        'Button Off-Image': this.conf.imagePath + 'ledred.png',
        'Button Transition-Image': this.conf.imagePath + 'ledyellow.png',
        'Button z-Index': 2,
        'Button Show status text': true,
        'Button Font-size': 14,
        'Button Font-weight': 'bold',
        'Button Font-color': '000000',
        'Button Font-family': 'sans-serif',
        'Collapsed on Startup': true,
        'Slider Rotate': false,
        'Slider Invers': false,
        'Slider Image': this.conf.imagePath + 'slider_light_40x364.gif',
        'Slider Thumb-Image': this.conf.imagePath + 'sArrow_33px.gif',
        'Slider Thumb X-Offset': 40,
        'Slider Thumb Y-Offset': 364,
        'Slider Increment (px)': 33,
        'Slider Rest-Time (ms)': 500,
        'Slider min. Value': 0,
        'Slider max. Value': 100,
        'Slider hide after set': true,
        'Value Font-size': 13,
        'Value Font-align': 'center',
        'Value Font-VAlign': true,
        'Value Font-weight': 'bold',
        'Value Font-color': '000000',
        'Value Font-family': 'sans-serif',
        'Value X-Offset': 0,
        'Value Y-Offset': -20,
        'Value Width': 40,
        'Value Height': 20,
        'Value Background': 'FFFFFF',
        'Value Suffix': '%',
        'Value Visible': true,
        'z-Index': 3,
        'Update Interval (s)': 10,
        'Value': 0
    };
    this.conf = apply(this.conf, config);
    this.value = this.conf.display['Value'];
    this.create(this.conf);
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.Slider.prototype.create = function(conf){
    this.div = document.createElement('div');
    this.divSlider = document.createElement('div');
    this.divSliderThumb = document.createElement('div');
    this.imgSliderThumb = document.createElement('img');
    this.divValue = document.createElement('div');
    this.toggleButton = new HAP.Switch();
    
    this.div.appendChild(this.divSlider);
    this.divSliderThumb.appendChild(this.imgSliderThumb);
    this.divSlider.appendChild(this.divSliderThumb);
    this.div.appendChild(this.divValue);
    this.div.appendChild(this.toggleButton.div);
    
    return this.div;
}

HAP.Slider.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    
    this.div.id = 'slider/' + this.conf.id + '/wrapper';
    this.div.style.position = 'absolute';
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
    }
    if (viewPortCall) {
        this.div.style.width = this.conf.display['width'] + 'px';
        this.div.style.height = this.conf.display['height'] + 'px';
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
    
    this.divSlider.id = 'slider/' + this.conf.id;
    this.divSlider.style.position = 'absolute';
    this.divSlider.style.zIndex = this.conf.display['z-Index'];
    //if (this.conf.display['Collapsed on Startup']) {
    //  this.divSlider.style.display = 'none';
    //}    
    this.divSlider.style.backgroundImage = 'url(' + this.conf.display['Slider Image'] + ')';
    this.divSlider.style.width = this.conf.display['width'] + 'px';
    this.divSlider.style.height = this.conf.display['height'] + 'px';
    
    this.divSliderThumb.id = 'slider/' + this.conf.id + '/thumb';
    this.divSliderThumb.style.position = 'absolute';
    this.divSliderThumb.style.left = this.conf.display['Slider Thumb X-Offset'] + 'px';
    // thumb image is loaded at the end of this function, cause the thumb must be loaded at all, before some calculations can be done.
    if (this.conf.display['Value Visible']) {
        this.divValue.style.display = 'block';
    }
    else {
        this.divValue.style.display = 'none';
    }
    this.divValue.id = 'slider/' + this.conf.id + '-value';
    this.divValue.style.position = 'absolute';
    if (this.conf.display['Value Font-VAlign']) {
        this.divValue.style.lineHeight = this.conf.display['Value Height'] + 'px';
    }
    else {
        this.divValue.style.lineHeight = null;
    }
    this.divValue.style.left = this.conf.display['Value X-Offset'] + 'px';
    this.divValue.style.top = this.conf.display['Value Y-Offset'] + 'px';
    this.divValue.style.width = this.conf.display['Value Width'] + 'px';
    this.divValue.style.height = this.conf.display['Value Height'] + 'px';
    if (this.conf.display['Value Background']) {
        this.divValue.style.backgroundColor = '#' + this.conf.display['Value Background'];
    }
    else {
        this.divValue.style.backgroundColor = null;
    }
    this.divValue.style.fontSize = this.conf.display['Value Font-size'] + 'px';
    this.divValue.style.textAlign = this.conf.display['Value Font-align'];
    this.divValue.style.fontWeight = this.conf.display['Value Font-weight'];
    this.divValue.style.color = '#' + this.conf.display['Value Font-color'];
    this.divValue.style.fontFamily = this.conf.display['Value Font-family'];
    this.divValue.innerHTML = this.conf.display['Value'] + this.conf.display['Value Suffix'];
    
    this.toggleButton.setConfig({
        id: 'slider/' + this.conf.id + '-toggle',
        display: {
            x: this.conf.display['Button X-Offset'],
            y: this.conf.display['Button Y-Offset'],
            width: this.conf.display['Button Width'],
            height: this.conf.display['Button Height'],
            'Off-Image': this.conf.display['Button Off-Image'],
            'On-Image': this.conf.display['Button On-Image'],
            'Transition-Image': this.conf.display['Button Transition-Image'],
            'z-Index': this.conf.display['Button z-Index'],
            'Show status text': this.conf.display['Button Show status text'],
            'Font-size': this.conf.display['Button Font-size'],
            'Font-weight': this.conf.display['Button Font-weight'],
            'Font-color': this.conf.display['Button Font-color'],
            'Font-family': this.conf.display['Button Font-family'],
            'Value-Suffix': this.conf.display['Value Suffix']
        }
    }, false);
    var oThis = this;
    this.toggleButton.attachEvent('onclick', function(){
        oThis.toggleView();
    });
    
    var thumb = new Image();
    thumb.src = this.conf.display['Slider Thumb-Image'];
    thumb.onload = function(){
        oThis.thumbHeight = thumb.height;
        oThis.thumbWidth = thumb.width;
        oThis.divSliderThumb.style.top = oThis.conf.display['Slider Thumb Y-Offset'] - oThis.thumbHeight + 'px';
        oThis.imgSliderThumb.src = oThis.conf.display['Slider Thumb-Image'];
        if (!viewPortCall) {
            oThis.attachSliderLogic();
        }
    }
}

HAP.Slider.prototype.attachSliderLogic = function(){
    // Base calculations
    var upPixel;
    var leftPixel;
    var downPixel;
    var rightPixel;
    var factor;
    if (this.conf.display['Slider Invers']) { // from top to bottom  or right to left
        upPixel = 0;
        leftPixel = this.conf.display['width'] - this.thumbWidth;
        downPixel = this.conf.display['height'] - this.thumbHeight;
        rightPixel = 0;
        factor = (this.conf.display['Slider max. Value'] - this.conf.display['Slider min. Value']) / (upPixel + downPixel);
        factorHoriz = -1 * (this.conf.display['Slider max. Value'] - this.conf.display['Slider min. Value']) / (leftPixel + rightPixel);
    }
    else {
        upPixel = this.conf.display['height'] - this.thumbHeight;
        leftPixel = 0;
        downPixel = 0;
        rightPixel = this.conf.display['width'] - this.thumbWidth;
        factor = -1 * ((this.conf.display['Slider max. Value'] - this.conf.display['Slider min. Value']) / (upPixel + downPixel));
        factorHoriz = (this.conf.display['Slider max. Value'] - this.conf.display['Slider min. Value']) / (leftPixel + rightPixel);
    }
    
    var oThis = this;
    if (this.conf.display['Slider Rotate']) {
        YAHOO.util.Event.onDOMReady(function(){
            oThis.slider = YAHOO.widget.Slider.getHorizSlider('slider/' + oThis.conf.id, 'slider/' + oThis.conf.id + '/thumb', leftPixel, rightPixel, oThis.conf.display['Slider Increment (px)']);
            oThis.slider.factor = factorHoriz;
            oThis.slider.subscribe('change', function(){
                var trueValue = Math.round(this.getValue() * factorHoriz) + oThis.conf.display['Slider min. Value'];
                clearTimeout(this.restSchedule);
                this.restSchedule = setTimeout(function(){
                    oThis.setRequest(trueValue)
                }, oThis.conf.display['Slider Rest-Time (ms)']);
            });
            oThis.slider.onAvailable = function(){
                oThis.toggleView(oThis.conf.display['Collapsed on Startup']);
            }
            
        });
    }
    else {
        YAHOO.util.Event.onDOMReady(function(){
            oThis.slider = YAHOO.widget.Slider.getVertSlider('slider/' + oThis.conf.id, 'slider/' + oThis.conf.id + '/thumb', upPixel, downPixel, oThis.conf.display['Slider Increment (px)']);
            oThis.slider.factor = factor;
            oThis.slider.subscribe('change', function(){
                var trueValue = Math.round(this.getValue() * factor) + oThis.conf.display['Slider min. Value'];
                clearTimeout(this.restSchedule);
                this.restSchedule = setTimeout(function(){
                    oThis.setRequest(trueValue)
                }, oThis.conf.display['Slider Rest-Time (ms)']);
            });
            oThis.slider.onAvailable = function(){
                oThis.toggleView(oThis.conf.display['Collapsed on Startup']);
            }
        });
    }
}

HAP.Slider.prototype.toggleView = function(visible){
    if (visible != null) {
        this.visible = visible;
    }
    if (this.visible) {
        this.divSlider.style.display = 'none';
        this.divValue.style.display = 'none';
        this.visible = false;
    }
    else {
        this.divSlider.style.display = 'block';
        if (this.slider) {
            this.slider.setValue((this.value / this.slider.factor) - this.conf.display['Slider min. Value'], false, false, true);
        }
        if (this.conf.display['Value Visible']) {
            this.divValue.style.display = 'block';
        }
        this.visible = true;
    }
}

HAP.Slider.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.divSlider.style.width = width + 'px';
}
HAP.Slider.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.divSlider.style.height = height + 'px';
}

HAP.Slider.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}
HAP.Slider.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Slider.prototype.setRequest = function(value){
    if (this.conf.display['Button Transition-Image']) {
        this.toggleButton.img.src = this.conf.display['Button Transition-Image'];
    }
    var oThis = this;
    YAHOO.util.Connect.asyncRequest('get', '/gui/setDevice/' + this.conf.display['HAP-Module'] + '/' + this.conf.display['HAP-Device'] + '/' + value, {
        success: function(o){
            if (YAHOO.lang.JSON.isValid(o.responseText)) {
                var response = YAHOO.lang.JSON.parse(o.responseText);
                if (response.success) {
                    oThis.setValue(response.data.value);
                    if (oThis.conf.display['Slider hide after set']) {
                        oThis.toggleView(true);
                    }
                }
                else {
                    oThis.setValue(oThis.value); // rest Slider to old values
                }
            }
            else {
                document.getElementById('rootDiv').innerHTML = o.responseText;
            }
        }
    });
}

HAP.Slider.prototype.setValue = function(value){
    this.divValue.innerHTML = value + this.conf.display['Value Suffix'];
    this.toggleButton.setValue(value);
    if (this.slider && this.visible) {
        this.slider.setValue((value / this.slider.factor) - this.conf.display['Slider min. Value'], false, false, true);
    }
    this.value = value;
}

HAP.SliderImage = function(conf){
    this.conf = conf;
    this.conf.imagePath = '/static/images/gui/';
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.textAlign = 'center';
    div.style.position = 'absolute';
    
    var img = document.createElement('img');
    img.src = this.conf.imagePath + 'slider_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
HAP.ImageLayer = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.ImageLayer';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        x: 0,
        y: 0,
        height: 60,
        width: 60,
        'Image': this.conf.imagePath + 'ImageLayer_60x60.png',
        'z-Index': 2,
        'Font-size': 14,
        'Font-weight': 'bold',
        'Font-color': '000000',
        'Font-family': 'sans-serif',
        'Show text': true,
        'Text': '',
        'Text-Align': 'center',
        'Text-VAlign': true,
        'Target View': '',
        'Target Scene': '',
        'Target External': '',
        'Target Frame': '_self'
    };
    this.conf = apply(this.conf, config);
    this.create(this.conf);
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.ImageLayer.prototype.create = function(conf){
    this.div = document.createElement('div');
    this.img = document.createElement('img');
    this.text = document.createElement('div');
    this.layer = document.createElement('img');
    this.div.appendChild(this.img);
    this.div.appendChild(this.text);
    this.div.appendChild(this.layer);
    return this.div;
}

HAP.ImageLayer.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    
    this.div.style.position = 'absolute';
    this.div.style.width = this.conf.display['width'] + 'px';
    this.div.style.height = this.conf.display['height'] + 'px';
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
    
    this.img.style.position = 'absolute';
    this.img.style.width = this.conf.display['width'] + 'px';
    this.img.style.height = this.conf.display['height'] + 'px';
    this.img.style.zIndex = this.conf.display['z-Index'];
    if (this.conf.display['Image']) {
        this.img.src = this.conf.display['Image'];
    }
    else {
        this.img.src = this.conf.imagePath + 'null.gif';
    }
    
    this.text.style.position = 'absolute';
    this.text.style.width = this.conf.display['width'] + 'px';
    this.text.style.height = this.conf.display['height'] + 'px';
    if (this.conf.display['Text-VAlign']) {
        this.text.style.lineHeight = this.conf.display['height'] + 'px';
    }
    else {
        this.text.style.lineHeight = null;
    }
    this.text.style.fontSize = this.conf.display['Font-size'] + 'px';
    this.text.style.fontWeight = this.conf.display['Font-weight'];
    this.text.style.color = '#' + this.conf.display['Font-color'];
    this.text.style.fontFamily = this.conf.display['Font-family'];
    this.text.align = this.conf.display['Text-Align'];
    this.text.style.zIndex = this.conf.display['z-Index'];
    this.text.innerHTML = this.conf.display['Text'];
    
    if (this.conf.display['Show text']) {
        this.text.style.display = 'block';
    }
    else {
        this.text.style.display = 'none';
    }
    this.layer.style.position = 'absolute';
    this.layer.style.width = this.conf.display['width'] + 'px';
    this.layer.style.height = this.conf.display['height'] + 'px';
    this.layer.style.zIndex = this.conf.display['z-Index'];
    this.layer.src = this.conf.imagePath + 'null.gif';
    
    if (this.conf.display['Target View']) {
        var oThis = this;
        this.layer.onclick = function(){
            sceneBuilder.setScene('getView/' + oThis.conf.display['Target View']);
        }
    }
    else {
        if (this.conf.display['Target Scene']) {
            var oThis = this;
            this.layer.onclick = function(){
                sceneBuilder.setScene('getScene/' + oThis.conf.display['Target Scene']);
            }
        }
        else {
            if (this.conf.display['Target External']) {
                var lnk = this.conf.display['Target External'];
                var target = '_blank';
                if (this.conf.display['Target Frame']) {
                    target = this.conf.display['Target Frame'];
                }
                this.layer.onclick = function(){
                    window.open(lnk, target);
                }
            }
        }
    }
}

HAP.ImageLayer.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    this.img.style.width = width + 'px';
    this.text.style.width = width + 'px';
    this.layer.style.width = width + 'px';
}

HAP.ImageLayer.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    this.img.style.height = height + 'px';
    this.text.style.height = height + 'px';
    if (this.conf.display['Text-VAlign']) {
        this.text.style.lineHeight = height + 'px';
    }
    this.layer.style.height = height + 'px';
}

HAP.ImageLayer.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.ImageLayer.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.ImageLayer.prototype.setImage = function(img){
    this.img.src = img;
}

HAP.ImageLayer.prototype.setFontSize = function(size){
    this.text.style.fontSize = size + 'px';
}

HAP.ImageLayer.prototype.setFontWeight = function(weight){
    this.text.style.fontWeight = weight;
}

HAP.ImageLayer.prototype.setFontColor = function(color){
    this.text.style.color = color;
}

HAP.ImageLayer.prototype.showtextusText = function(bool){
    if (bool) {
        this.text.style.display = 'block';
    }
    else {
        this.text.style.display = 'none';
    }
}

HAP.ImageLayerImage = function(conf){
    this.conf = conf;
    this.conf.imagePath = '/static/images/gui/';
    
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.textAlign = 'center';
    div.style.position = 'absolute';
    
    var img = document.createElement('img');
    img.src = this.conf.imagePath + 'ImageLayer_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}

HAP.ValueLayer = function (config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.ValueLayer';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        'HAP-Module': 0,
        'HAP-Device': 0,
        x: 0,
        y: 0,
        height: 60,
        width: 60,
        Image: this.conf.imagePath + 'ImageLayer_60x60.png',
        'z-Index': 2,
		'Font-family' : 'sans-serif',
        'Font-size': 14,
        'Font-weight': 'bold',
        'Font-color': '000000',
        'Text-Align': 'center',
        'Text-VAlign': true,
        'Value Prefix': '',
        'Value Suffix': '%',
        'Value': 0,
        'Update Interval (s)': 10
    };
    this.conf = apply(this.conf, config);
    this.value = this.conf.display['Value'];
    this.create(this.conf);
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.ValueLayer.prototype.create = function(conf){
    this.div = document.createElement('div');
    this.img = document.createElement('img');
    this.text = document.createElement('div');
    this.layer = document.createElement('img');
    this.div.appendChild(this.img);
    this.div.appendChild(this.text);
    this.div.appendChild(this.layer);
    
    return this.div;
}

HAP.ValueLayer.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    this.div.style.position = 'absolute';
    this.div.style.width = this.conf.display['width'] + 'px';
    this.div.style.height = this.conf.display['height'] + 'px';
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
    }
    this.div.style.zIndex = this.conf.display['z-Index'];

    this.img.style.position = 'absolute';
    this.img.style.width = this.conf.display['width'] + 'px';
    this.img.style.height = this.conf.display['height'] + 'px';
    this.img.style.zIndex = this.conf.display['z-Index'];
    if (this.conf.display['Image']) {
      this.img.src = this.conf.display['Image'];
    }
    else {
      this.img.src = this.conf.imagePath + 'null.gif';
    }
    
    this.text.style.position = 'absolute';
	this.text.style.fontFamily = this.conf.display['Font-family'] || 'sans-serif'
    this.text.style.width = this.conf.display['width'] + 'px';
    this.text.style.height = this.conf.display['height'] + 'px';
    if (this.conf.display['Text-VAlign']) {
      this.text.style.lineHeight = this.conf.display['height'] + 'px';
    }
    else {
      this.text.style.lineHeight = null;
    }
    this.text.style.fontSize = this.conf.display['Font-size'] + 'px';
    this.text.style.fontWeight = this.conf.display['Font-weight'];
    this.text.style.color = '#' + this.conf.display['Font-color'];
    this.text.align = this.conf.display['Text-Align'];
    this.text.style.zIndex = this.conf.display['z-Index'];
    this.text.innerHTML = this.conf.display['Value Prefix'] + this.conf.display['Value'] + this.conf.display['Value Suffix'];
    
    this.layer.style.position = 'absolute';
    this.layer.style.width = this.conf.display['width'] + 'px';
    this.layer.style.height = this.conf.display['height'] + 'px';
    this.layer.style.zIndex = this.conf.display['z-Index'];
    this.layer.src = this.conf.imagePath + 'null.gif';
    
    var oThis = this;
    this.attachEvent('onclick', function(){
        oThis.setRequest(oThis.value);
    }, viewPortCall);
    
}

HAP.ValueLayer.prototype.attachEvent = function(event, handler, viewPortCall){
    if (!viewPortCall && event == 'onclick') {
      this.layer.onclick = handler;
    }
}

HAP.ValueLayer.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    this.img.style.width = width + 'px';
    this.text.style.width = width + 'px';
    this.layer.style.width = width + 'px';
}

HAP.ValueLayer.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    this.img.style.height = height + 'px';
    this.text.style.height = height + 'px';
    if (this.conf.display['Text-VAlign']) {
      this.text.style.lineHeight = height + 'px';
    }
    this.layer.style.height = height + 'px';
}

HAP.ValueLayer.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.ValueLayer.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.ValueLayer.prototype.setImage = function(img){
    this.img.src = img;
}

HAP.ValueLayer.prototype.setFontSize = function(size){
    this.text.style.fontSize = size + 'px';
}

HAP.ValueLayer.prototype.setFontWeight = function(weight){
    this.text.style.fontWeight = weight;
}

HAP.ValueLayer.prototype.setFontColor = function(color){
    this.text.style.color = color;
}

HAP.ValueLayer.prototype.showStatusText = function(bool){
    if (bool) {
      this.text.style.display = 'block';
    }
    else {
      this.text.style.display = 'none';
    }
}

HAP.ValueLayer.prototype.setRequest = function(value){
    var oThis = this;
    YAHOO.util.Connect.asyncRequest('get', '/gui/queryDevice/' + this.conf.display['HAP-Module'] + '/' + this.conf.display['HAP-Device'], {
        success: function(o){
            var response = YAHOO.lang.JSON.parse(o.responseText);
            if (response.success) {
              oThis.setValue(response.data.value);
            }
            else {
              oThis.setValue('--');
            }
        }
    });
}

HAP.ValueLayer.prototype.setValue = function(value){
    this.text.innerHTML = this.conf.display['Value Prefix'] + value + this.conf.display['Value Suffix'];
    this.value = value;
    return;
}

HAP.ValueLayerImage = function(conf){
    this.conf = conf;
    this.conf.imagePath = '/static/images/gui/';
    
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.textAlign = 'center';
    div.style.position = 'absolute';
    
    var img = document.createElement('img');
    img.src = this.conf.imagePath + 'ValueLayer_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '9px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
HAP.Chart = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.Chart';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        x: 0,
        y: 0,
        height: 100,
        width: 150,
        'z-Index': 2,
        'Update Interval (s)': 3600,
        'Start-Offset (m)': 60,
        'Chart-Data': '',
        'chart': {
            'bg_colour': '#FF0000',
            'title': {
                'text': 'Many data lines',
                'style': '{font-size: 14px; color:#000000; font-family: Verdana; text-align: center;}'
            },
            'x_legend': {
                'text': 'X-Legend',
                'style': '{color: #000000; font-size: 10px;}'
            },
            'y_legend': {
                'text': 'Y-Legend',
                'style': '{color: #000000; font-size: 10px;}'
            },
            'x_axis': {
                'stroke': 1,
                'tick_height': 10,
                'colour': '#000000',
                'offset': 0,
                'grid_colour': '#000000',
                '3d': false,
                'steps': 1,
                'rotate': 'vertical'
            },
            'x_axis_labels': {
                'stroke': 1,
                'tick_height': 10,
                'colour': '#000000',
                'offset': 0,
                'grid_colour': '#000000',
                '3d': false,
                'steps': 1,
                'rotate': 'vertical',
                'show_date': false // custom
            },
            'y_axis': {
                'stroke': 1,
                'tick_height': 10,
                'colour': '#000000',
                'offset': 0,
                'grid_colour': '#000000',
                '3d': false,
                'steps': 1,
                'max': 100,
                'min': 0
            },
            'y_axis_labels': {
                'stroke': 1,
                'tick_height': 10,
                'colour': '#000000',
                'offset': 0,
                'grid_colour': '#000000',
                '3d': false,
                'steps': 1,
                'max': 100,
                'min': 0
            },
            'elements': []
        },
        'templates': {
            'bar': {
                'type': 'bar',
                'HAP-Name': 'Bar',
                'HAP-Module': '',
                'HAP-Device': '',
                'Scale': 1,
                'alpha': 0.5,
                'colour': '#000000',
                'text': 'Data',
                'font-size': 10
            },
            'pie': {
                'type': 'pie',
                'HAP-Name': 'Pie',
                'HAP-Module': '',
                'HAP-Device': '',
                'Scale': 1,
                'start-angle': 180,
                'colours': ['#d01f3c', '#356aa0', '#C79810', '#73880A', '#D15600', '#6BBA70'],
                'alpha': 0.6,
                'stroke': 2,
                'animate': 1
            },
            'hbar': {
                'type': 'hbar',
                'HAP-Name': 'H-Bar',
                'HAP-Module': '',
                'HAP-Device': '',
                'Scale': 1,
                'colour': '#000000',
                'text': 'Data',
                'font-size': 10
            },
            'line': {
                'type': 'line',
                'HAP-Name': 'Line',
                'HAP-Module': '',
                'HAP-Device': '',
                'Scale': 1,
                'colour': '#000000',
                'text': 'Data',
                'width': 2,
                'font-size': 10,
                'dot-size': 2
            },
            'line_dot': {
                'type': 'line_dot',
                'HAP-Name': 'Line-Dot',
                'HAP-Module': '',
                'HAP-Device': '',
                'Scale': 1,
                'colour': '#000000',
                'width': 1,
                'text': 'Data',
                'font-size': 10,
                'dot-size': 2
            },
            'line_hollow': {
                'type': 'line_hollow',
                'HAP-Name': 'Line-Hollow',
                'HAP-Module': '',
                'HAP-Device': '',
                'Scale': 1,
                'colour': '#000000',
                'width': 1,
                'text': 'Data',
                'font-size': 10,
                'dot-size': 2,
                'fill-alpha': 0.35
            }
        }
    
    };
    this.conf = apply(this.conf, config);
    this.create(this.conf)
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.Chart.prototype.create = function(conf){
    this.div = document.createElement('div');
    this.div.id = this.conf.id;
    this.img = document.createElement('img');
    this.ofcDiv = document.createElement('div');
    this.ofcDiv.id = this.conf.id + '/ofc';
    this.div.appendChild(this.img);
    this.div.appendChild(this.ofcDiv);
    //this.div.id = this.conf.id;
    return this.div;
}

HAP.Chart.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    this.div.style.position = 'absolute';
    this.div.style.width = this.conf.display['width'] + 'px';
    this.div.style.height = this.conf.display['height'] + 'px';
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
        var oThis = this;
        YAHOO.util.Event.onDOMReady(function(){
            swfobject.embedSWF("/static/js/ofc/open-flash-chart.swf", oThis.conf.id + '/ofc', oThis.conf.display['width'], oThis.conf.display['height'], "9.0.0", "/static/js/ofc/expressInstall.swf");
        });
    }
    else {
        this.img.src = this.conf.imagePath + 'Chart.png';
        this.img.style.width = this.conf.display['width'] + 'px';
        this.img.style.height = this.conf.display['height'] + 'px';
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
}

function open_flash_chart_data(){
    return '{"bg_colour": "#FFFFFF","x-axis": {}, "y-axis":{}, "elements":[]}';
}

HAP.Chart.prototype.setValue = function(value){
    if (value) 
        this.conf.display.chart = value;
    var tmp = findSWF(this.conf.id + '/ofc');
    if (tmp.load) {
        tmp.load(YAHOO.lang.JSON.stringify(this.conf.display.chart));
    }
    else {  // not ready, try again later
			  var oThis = this;
        setTimeout(function() { oThis.setValue() }, 200);
    }
}

function findSWF(movieName){
    if (navigator.appName.indexOf("Microsoft") != -1) {
        return window[movieName];
    }
    else {
        return document[movieName];
    }
}

HAP.Chart.prototype.attachEvent = function(event, handler, viewPortCall){
    if (!viewPortCall && event == 'onclick') {
        this.layer.onclick = handler;
    }
}

HAP.Chart.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    this.img.style.width = width + 'px';
}

HAP.Chart.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    this.img.style.height = height + 'px';
}

HAP.Chart.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.Chart.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Chart.prototype.setRequest = function(value){
    var oThis = this;
    YAHOO.util.Connect.asyncRequest('get', '/gui/setDevice/' + this.conf.display['HAP-Module'] + '/' + this.conf.display['HAP-Device'] + '/' + value, {
        success: function(o){
            if (YAHOO.lang.JSON.isValid(o.responseText)) {
                var response = YAHOO.lang.JSON.parse(o.responseText);
                if (response.success) {
                    oThis.setValue(response.data.value);
                }
            }
            else {
                document.getElementById('rootDiv').innerHTML = o.responseText;
            }
        }
    });
}

HAP.ChartImage = function(conf){
    this.conf = conf;
    this.conf.imagePath = '/static/images/gui/';
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.textAlign = 'center';
    div.style.position = 'absolute';
    
    var img = document.createElement('img');
    img.src = this.conf.imagePath + 'Chart_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
HAP.Chart5 = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.tmpId = 'x' + Math.random() + 'x';
    this.conf.type = 'HAP.Chart5';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        x: 0,
        y: 0,
        height: 150,
        width: 150,
        'z-Index': 2,
        'Update Interval (s)': 3600,
        'Start-Offset (m)': 60,
        'Interval (m)': 60,
        'Chart-Properties': '',
        'Chart-Type': 'Line',
        'Chart-X-Interval': 1,
        'sourceTemplate': {
            'HAP-Module': '',
            'HAP-Device': '',
            'Description': '',
            'chart.colors': '',
            'chart.fillstyle': '',
            'chart.key': ''
        },
        'dataSources': [],
        'chart': {
            'Line': {
                'chart.background.barcolor1': 'rgba(0,0,0,0)',
                'chart.background.barcolor2': 'rgba(0,0,0,0)',
                'chart.background.grid': 1,
                'chart.background.grid.width': 1,
                'chart.background.grid.hsize': 25,
                'chart.background.grid.vsize': 25,
                'chart.background.grid.color': '#ddd',
                'chart.background.grid.vlines': true,
                'chart.background.grid.hlines': true,
                'chart.background.grid.border': true,
                'chart.background.grid.autofit': false,
                'chart.background.grid.autofit.numhlines': 7,
                'chart.background.grid.autofit.numvlines': 20,
                'chart.background.hbars': null,
                'chart.labels': null,
                'chart.labels.ingraph': null,
                'chart.xtickgap': 20,
                'chart.smallxticks': 3,
                'chart.largexticks': 5,
                'chart.ytickgap': 20,
                'chart.smallyticks': 3,
                'chart.largeyticks': 5,
                'chart.linewidth': 1,
                'chart.colors': ['red', '#0f0', '#00f', '#f0f', '#ff0', '#0ff'],
                'chart.hmargin': 0,
                'chart.tickmarks.dot.color': 'white',
                'chart.tickmarks': '',
                'chart.ticksize': 3,
                'chart.gutter': 45,
                'chart.tickdirection': -1,
                'chart.yaxispoints': 5,
                'chart.fillstyle': '',
                'chart.xaxispos': 'bottom',
                'chart.yaxispos': 'left',
                'chart.xticks': '',
                'chart.text.size': 10,
                'chart.text.angle': 90,
                'chart.text.color': 'black',
                'chart.text.font': 'Verdana',
                'chart.ymin': 0,
                'chart.ymax': 100,
                'chart.title': '',
                'chart.title.hpos': '',
                'chart.title.vpos': '',
                'chart.title.xaxis': '',
                'chart.title.yaxis': '',
                'chart.title.xaxis.pos': 0.25,
                'chart.title.yaxis.pos': 0.25,
                'chart.shadow': false,
                'chart.shadow.offsetx': 2,
                'chart.shadow.offsety': 2,
                'chart.shadow.blur': 3,
                'chart.shadow.color': 'rgba(0,0,0,0.5)',
                'chart.tooltips': [],
                'chart.tooltips.effect': 'fade',
                'chart.tooltips.css.class': 'RGraph_tooltip',
                'chart.tooltips.coords.adjust': [0, 0],
                'chart.tooltips.highlight': true,
                'chart.stepped': false,
                'chart.key': [],
                'chart.key.background': 'white',
                'chart.key.position': 'graph',
                'chart.key.shadow': false,
                'chart.key.shadow.color': '#666',
                'chart.key.shadow.blur': 3,
                'chart.key.shadow.offsetx': 2,
                'chart.key.shadow.offsety': 2,
                'chart.contextmenu': null,
                'chart.ylabels': true,
                'chart.ylabels.count': 5,
                'chart.ylabels.inside': false,
                'chart.ylabels.invert': false,
                'chart.xlabels.inside': false,
                'chart.xlabels.inside.color': 'rgba(255,255,255,0.5)',
                'chart.noaxes': false,
                'chart.noyaxis': false,
                'chart.noxaxis': false,
                'chart.noendxtick': false,
                'chart.units.post': '',
                'chart.units.pre': '',
                'chart.scale.decimals': 0,
                'chart.scale.point': '.',
                'chart.scale.thousand': ',',
                'chart.crosshairs': false,
                'chart.crosshairs.color': '#333',
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.axesontop': false,
                'chart.filled.range': false,
                'chart.variant': '',
                'chart.axis.color': 'black',
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 15,
                'chart.zoom.delay': 33,
                'chart.zoom.shadow': true,
                'chart.zoom.mode': 'canvas',
                'chart.zoom.thumbnail.width': 75,
                'chart.zoom.thumbnail.height': 75,
                'chart.zoom.background': true,
                'chart.zoom.action': 'zoom',
                'chart.backdrop': false,
                'chart.backdrop.size': 30,
                'chart.backdrop.alpha': 0.2,
                'chart.resizable': false,
                'chart.adjustable': false,
                'chart.noredraw': false,
            },
            'Bar': {
                'chart.background.barcolor1': 'rgba(0,0,0,0)',
                'chart.background.barcolor2': 'rgba(0,0,0,0)',
                'chart.background.grid': true,
                'chart.background.grid.color': '#ddd',
                'chart.background.grid.width': 1,
                'chart.background.grid.hsize': 20,
                'chart.background.grid.vsize': 20,
                'chart.background.grid.vlines': true,
                'chart.background.grid.hlines': true,
                'chart.background.grid.border': true,
                'chart.background.grid.autofit': false,
                'chart.background.grid.autofit.numhlines': 7,
                'chart.background.grid.autofit.numvlines': 20,
                'chart.ytickgap': 20,
                'chart.smallyticks': 3,
                'chart.largeyticks': 5,
                'chart.numyticks': 10,
                'chart.hmargin': 5,
                'chart.strokecolor': '#666',
                'chart.axis.color': 'black',
                'chart.gutter': 25,
                'chart.labels': null,
                'chart.labels.ingraph': null,
                'chart.labels.above': false,
                'chart.ylabels': true,
                'chart.ylabels.count': 5,
                'chart.ylabels.inside': false,
                'chart.xlabels.offset': 0,
                'chart.xaxispos': 'bottom',
                'chart.yaxispos': 'left',
                'chart.text.color': 'black',
                'chart.text.size': 10,
                'chart.text.angle': 0,
                'chart.text.font': 'Verdana',
                'chart.ymax': null,
                'chart.title': '',
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.title.xaxis': '',
                'chart.title.yaxis': '',
                'chart.title.xaxis.pos': 0.25,
                'chart.title.yaxis.pos': 0.25,
                'chart.colors': ['rgb(0,0,255)', '#0f0', '#00f', '#ff0', '#0ff', '#0f0'],
                'chart.grouping': 'grouped',
                'chart.variant': 'bar',
                'chart.shadow': false,
                'chart.shadow.color': '#666',
                'chart.shadow.offsetx': 3,
                'chart.shadow.offsety': 3,
                'chart.shadow.blur': 3,
                'chart.tooltips': [],
                'chart.tooltips.effect': 'fade',
                'chart.tooltips.css.class': 'RGraph_tooltip',
                'chart.tooltips.event': 'onclick',
                'chart.tooltips.coords.adjust': [0, 0],
                'chart.tooltips.highlight': true,
                'chart.background.hbars': null,
                'chart.key': [],
                'chart.key.background': 'white',
                'chart.key.position': 'graph',
                'chart.key.shadow': false,
                'chart.key.shadow.color': '#666',
                'chart.key.shadow.blur': 3,
                'chart.key.shadow.offsetx': 2,
                'chart.key.shadow.offsety': 2,
                'chart.contextmenu': null,
                'chart.line': null,
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.scale.decimals': 0,
                'chart.scale.point': '.',
                'chart.scale.thousand': ',',
                'chart.crosshairs': false,
                'chart.crosshairs.color': '#333',
                'chart.linewidth': 1,
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 10,
                'chart.zoom.delay': 50,
                'chart.zoom.shadow': true,
                'chart.zoom.mode': 'canvas',
                'chart.zoom.thumbnail.width': 75,
                'chart.zoom.thumbnail.height': 75,
                'chart.zoom.background': true,
                'chart.resizable': false,
                'chart.adjustable': false,
                'chart.ymax': 100
            },
            'HBar': {
                'chart.gutter': 25,
                'chart.background.grid': true,
                'chart.background.grid.color': '#ddd',
                'chart.background.grid.width': 1,
                'chart.background.grid.hsize': 25,
                'chart.background.grid.vsize': 25,
                'chart.background.barcolor1': 'white',
                'chart.background.barcolor2': 'white',
                'chart.background.grid.hlines': true,
                'chart.background.grid.vlines': true,
                'chart.background.grid.border': true,
                'chart.background.grid.autofit': false,
                'chart.background.grid.autofit.numhlines': 14,
                'chart.background.grid.autofit.numvlines': 20,
                'chart.title': '',
                'chart.title.xaxis': '',
                'chart.title.yaxis': '',
                'chart.title.xaxis.pos': 0.25,
                'chart.title.yaxis.pos': 0.5,
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.text.size': 10,
                'chart.text.color': 'black',
                'chart.text.font': 'Verdana',
                'chart.colors': ['rgb(0,0,255)', '#0f0', '#00f', '#ff0', '#0ff', '#0f0'],
                'chart.labels': [],
                'chart.labels.above': false,
                'chart.contextmenu': null,
                'chart.key': [],
                'chart.key.background': 'white',
                'chart.key.position': 'graph',
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.units.ingraph': false,
                'chart.strokestyle': 'black',
                'chart.xmax': 0,
                'chart.axis.color': 'black',
                'chart.shadow': false,
                'chart.shadow.color': '#666',
                'chart.shadow.blur': 3,
                'chart.shadow.offsetx': 3,
                'chart.shadow.offsety': 3,
                'chart.vmargin': 3,
                'chart.grouping': 'grouped',
                'chart.tooltips': [],
                'chart.tooltips.effect': 'fade',
                'chart.tooltips.css.class': 'RGraph_tooltip',
                'chart.tooltips.highlight': true,
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 10,
                'chart.zoom.delay': 50,
                'chart.zoom.shadow': true,
                'chart.zoom.mode': 'canvas',
                'chart.zoom.thumbnail.width': 75,
                'chart.zoom.thumbnail.height': 75,
                'chart.zoom.background': true,
                'chart.zoom.action': 'zoom',
                'chart.resizable': false,
                'chart.scale.point': '.',
                'chart.scale.thousand': ',',
                'chart.ymax': 100,
            },
            'HProgress': {
                'chart.colors': ['#0c0'],
                'chart.tickmarks': true,
                'chart.tickmarks.color': 'black',
                'chart.tickmarks.inner': false,
                'chart.gutter': 25,
                'chart.numticks': 10,
                'chart.numticks.inner': 50,
                'chart.background.color': '#eee',
                'chart.shadow': false,
                'chart.shadow.color': 'rgba(0,0,0,0.5)',
                'chart.shadow.blur': 3,
                'chart.shadow.offsetx': 3,
                'chart.shadow.offsety': 3,
                'chart.title': '',
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.width': 0,
                'chart.height': 0,
                'chart.text.size': 10,
                'chart.text.color': 'black',
                'chart.text.font': 'Verdana',
                'chart.contextmenu': null,
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.tooltips': [],
                'chart.tooltips.effect': 'fade',
                'chart.tooltips.css.class': 'RGraph_tooltip',
                'chart.tooltips.highlight': true,
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.zoom.mode': 'canvas',
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 10,
                'chart.zoom.delay': 50,
                'chart.zoom.shadow': true,
                'chart.zoom.background': true,
                'chart.zoom.action': 'zoom',
                'chart.arrows': false,
                'chart.margin': 0,
                'chart.resizable': false,
                'chart.label.inner': false,
                'chart.adjustable': false
            },
            'VProgress': {
                'chart.colors': ['#0c0'],
                'chart.tickmarks': true,
                'chart.tickmarks.color': 'black',
                'chart.tickmarks.inner': false,
                'chart.gutter': 25,
                'chart.numticks': 10,
                'chart.numticks.inner': 50,
                'chart.background.color': '#eee',
                'chart.shadow': false,
                'chart.shadow.color': 'rgba(0,0,0,0.5)',
                'chart.shadow.blur': 3,
                'chart.shadow.offsetx': 3,
                'chart.shadow.offsety': 3,
                'chart.title': '',
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.width': 0,
                'chart.height': 0,
                'chart.text.size': 10,
                'chart.text.color': 'black',
                'chart.text.font': 'Verdana',
                'chart.contextmenu': null,
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.tooltips': [],
                'chart.tooltips.effect': 'fade',
                'chart.tooltips.css.class': 'RGraph_tooltip',
                'chart.tooltips.highlight': true,
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.zoom.mode': 'canvas',
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 10,
                'chart.zoom.delay': 50,
                'chart.zoom.shadow': true,
                'chart.zoom.background': true,
                'chart.zoom.action': 'zoom',
                'chart.arrows': false,
                'chart.margin': 0,
                'chart.resizable': false,
                'chart.label.inner': false,
                'chart.adjustable': false
            },
            'Meter': {
                'chart.gutter': 25,
                'chart.linewidth': 2,
                'chart.border.color': 'black',
                'chart.text.font': 'Verdana',
                'chart.text.size': 10,
                'chart.text.color': 'black',
                'chart.title': '',
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.title.color': 'black',
                'chart.green.start': 0,
                'chart.green.end': 33,
                'chart.green.color': '#207A20',
                'chart.yellow.start': 33,
                'chart.yellow.end': 66,
                'chart.yellow.color': '#D0AC41',
                'chart.red.start': 66,
                'chart.red.end': 100,
                'chart.red.color': '#9E1E1E',
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.contextmenu': null,
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 15,
                'chart.zoom.delay': 33,
                'chart.zoom.shadow': true,
                'chart.zoom.mode': 'canvas',
                'chart.zoom.thumbnail.width': 75,
                'chart.zoom.thumbnail.height': 75,
                'chart.zoom.background': true,
                'chart.zoom.action': 'zoom',
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.shadow': false,
                'chart.shadow.color': 'rgba(0,0,0,0.5)',
                'chart.shadow.blur': 3,
                'chart.shadow.offsetx': 3,
                'chart.shadow.offsety': 3,
                'chart.resizable': false
            },
            'Odometer': {
                'chart.value.text': true,
                'chart.needle.color': 'black',
                'chart.needle.width': 2,
                'chart.needle.head': true,
                'chart.needle.tail': true,
                'chart.needle.type': 'pointer',
                'chart.needle.extra': [],
                'chart.text.size': 10,
                'chart.text.color': 'black',
                'chart.text.font': 'Verdana',
                'chart.green.max': 30,
                'chart.red.min': 50,
                'chart.green.color': 'green',
                'chart.yellow.color': 'yellow',
                'chart.red.color': 'red',
                'chart.label.area': 35,
                'chart.gutter': 25,
                'chart.title': '',
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.contextmenu': null,
                'chart.linewidth': 1,
                'chart.shadow.inner': false,
                'chart.shadow.inner.color': 'black',
                'chart.shadow.inner.offsetx': 3,
                'chart.shadow.inner.offsety': 3,
                'chart.shadow.inner.blur': 6,
                'chart.shadow.outer': false,
                'chart.shadow.outer.color': '#666',
                'chart.shadow.outer.offsetx': 0,
                'chart.shadow.outer.offsety': 0,
                'chart.shadow.outer.blur': 15,
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.scale.decimals': 0,
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 10,
                'chart.zoom.delay': 50,
                'chart.zoom.shadow': true,
                'chart.zoom.mode': 'canvas',
                'chart.zoom.thumbnail.width': 75,
                'chart.zoom.thumbnail.height': 75,
                'chart.zoom.background': true,
                'chart.zoom.action': 'zoom',
                'chart.resizable': false,
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.border': false,
                'chart.tickmarks.highlighted': false,
                'chart.zerostart': false,
                'chart.labels': null,
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.value.units.pre': '',
                'chart.value.units.post': ''
            }
        }
    };
    this.conf = apply(this.conf, config);
    this.create(this.conf)
    var oThis = this;
    //canvas creation takes some time, so we have to wait, until the element is available
    function check(){
        if (document.getElementById(oThis.conf.tmpId)) 
            oThis.setConfig(oThis.conf, viewPortCall);
        else 
            window.setTimeout(check, 100);
    }
    window.setTimeout(check, 100);
    return this;
}

HAP.Chart5.prototype.create = function(conf){
    this.div = document.createElement('canvas');
    this.div.id = this.conf.tmpId;
    return this.div;
}

HAP.Chart5.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    this.div.style.position = 'absolute';
    this.div.style.width = this.conf.display['width'] + 'px';
    this.div.style.height = this.conf.display['height'] + 'px';
    
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
    }
    
    if (document.getElementById(this.conf.tmpId)) {
        if (this.chart && viewPortCall) {
            RGraph.Clear(this.chart.canvas);
            var p = this.div.getParent();
            p.removeChild(document.getElementById(this.conf.tmpId));
            p.appendChild(this.create());
        }
        var type = this.conf.display['Chart-Type'];
        this.chart = new RGraph[type](this.conf.tmpId, [1, 2, 3]);
        this.chart.canvas.width = this.conf.display['width'];
        this.chart.canvas.height = this.conf.display['height'];
        
        
        // Prevent Javascript-failure
        if (type == 'HProgress' || type == 'VProgress') 
            this.chart.max = 100;
        if (type == 'Meter') {
            this.chart.min = 0;
            this.chart.max = 100;
            this.chart.value = 0;
        }
        if (type == 'Odometer') {
            this.chart.start = 0;
            this.chart.end = 100;
            this.chart.value = 0;
        }
        
        // To optimize : set properties directly not via loop !
        for (var prop in this.conf.display.chart[type]) {
            var val = this.conf.display.chart[type][prop];
            this.chart.Set(prop, val);
        }
        
        // set datasource props
        var size = this.conf.display.dataSources.length;
        for (var i = 0; i < size; i++) {
            var cObj = this.conf.display.dataSources[i];
            for (var cProp in cObj) {
                if (this.conf.display.chart[type][cProp] instanceof Array && this.conf.display.dataSources[i][cProp]) {
                    if (i == 0) 
                        this.conf.display.chart[type][cProp] = [];
                    this.conf.display.chart[type][cProp].push(this.conf.display.dataSources[i][cProp]);
                    this.chart.Set(cProp, this.conf.display.chart[type][cProp]);
                }
            }
        }
        if (viewPortCall) 
            this.fillChartData(this.conf.display.dataSources, viewPortCall);
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
}

HAP.Chart5.prototype.fillChartData = function(dataSources, viewPortCall){
    var oThis = this;
    if (viewPortCall) {
        Ext.Ajax.request({
            url: 'gui/getChartData',
            params: {
                'data': Ext.encode(dataSources),
                'startOffset': this.conf.display['Start-Offset (m)'],
                'xSkip': this.conf.display['Chart-X-Interval'],
                'type': this.conf.display['Chart-Type'],
                'interval': this.conf.display['Interval (m)']
            },
            success: function(res, req){
                var data = Ext.decode(res.responseText).data;
                process(data);
            }
        });
    }
    else {
        YAHOO.util.Connect.asyncRequest('POST', '/gui/getChartData', {
            success: function(o){
                if (YAHOO.lang.JSON.isValid(o.responseText)) {
                    var response = YAHOO.lang.JSON.parse(o.responseText);
                    if (response.success) {
                        var data = response.data;
                        process(data);
                    }
                }
            }
        }, 'data=' + YAHOO.lang.JSON.stringify(dataSources) + '&startOffset=' + this.conf.display['Start-Offset (m)'] + '&xSkip=' + this.conf.display['Chart-X-Interval'] + '&type=' + this.conf.display['Chart-Type'] + '&interval=' + this.conf.display['Interval (m)']);
    }
    function process(data){
        if (!data) { //some dummy data
            data = {
                labels: ['a', 'b', 'c'],
                values: [[1, 2, 3]],
                min: 0,
                max: 100,
                start: 0,
                end: 100,
                value: 1
            };
        }
        RGraph.Clear(oThis.chart.canvas);
        oThis.chart.Set('chart.labels', data.labels);
        
        switch (oThis.conf.display['Chart-Type']) {
            case 'Line':
                oThis.chart.original_data = data.values;
                break;
            case 'Bar':
                oThis.chart.data = data.values;
                break;
            case 'HBar':
                oThis.chart.data = data.values;
                break;
            case 'HProgress':
                oThis.chart.value = data.value;
                oThis.chart.max = data.max;
                break;
            case 'VProgress':
                oThis.chart.value = data.value;
                oThis.chart.max = data.max;
                break;
            case 'Odometer':
                oThis.chart.start = data.start;
                oThis.chart.end = data.end;
                oThis.chart.value = data.value;
                break;
            case 'Meter':
                oThis.chart.min = data.min;
                oThis.chart.max = data.max;
                oThis.chart.value = data.value;
                break;
        }
        oThis.chart.Draw();
    }
}

HAP.Chart5.prototype.setValue = function(){
    this.fillChartData(this.conf.display.dataSources, false);
}

HAP.Chart5.prototype.attachEvent = function(event, handler, viewPortCall){
    if (!viewPortCall && event == 'onclick') {
        this.layer.onclick = handler;
    }
}

HAP.Chart5.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    if (this.chart) {
        RGraph.Clear(this.chart.canvas);
        this.chart.canvas.width = width;
        this.chart.Draw();
    }
}

HAP.Chart5.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    if (this.chart) {
        RGraph.Clear(this.chart.canvas);
        this.chart.canvas.height = height;
        this.chart.Draw();
    }
}

HAP.Chart5.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.Chart5.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Chart5.prototype.setRequest = function(value){
}

HAP.Chart5Image = function(conf){
    this.conf = conf;
    this.conf.imagePath = '/static/images/gui/';
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.textAlign = 'center';
    div.style.position = 'absolute';
    
    var img = document.createElement('img');
    img.src = this.conf.imagePath + 'Chart_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
/**
 * @author bendowski
 */
HAP.GUIObjectTree = function(){
    this.id = 'GUIObjectTree';
    HAP.GUIObjectTree.superclass.constructor.call(this);
}

Ext.extend(HAP.GUIObjectTree, Ext.Panel, {
    onRender: function(ct, pos){
        HAP.GUIObjectTree.superclass.onRender.call(this, ct, pos);
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'GET',
            url: '/gui/getAllObjects'
        });
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.util.JSON.decode(param.responseText);
            if (response.success) {
                var x;
                var y;
                var size = response.data.length;
                for (var i = 0; i < size; i++) {
                    if (i % 2 == 0) {
                        x = 10;
                    }
                    else {
                        x = 100;
                    }
                    y = parseInt(i / 2) * 80 + 10;
                    
                    var img = classFactory(response.data[i].type + "Image", {
                        id: response.data[i].id,
                        name: response.data[i].name,
                        height: 60,
                        width: 60,
                        top: y,
                        left: x
                    });
                    ct.appendChild(img);
                    if (response.data[i].type) {
                      var dragsource = new Ext.dd.DragSource(img.id, {
                        ddGroup: 'TreeDD',
                        dragData: {
                          type: response.data[i].type
                        }
                      });
                    }
                }
            }
        });
    }
});
/**
 * @author Ben
 */
HAP.GUIPropertyGrid = function(confObj){
    if (confObj && confObj.id) {
        this.id = confObj.id;
    }
    else {
        this.id = 'guiPropertyGrid';
    }
    this.region = 'center';
    this.split = true;
    this.iconCls = 'propertyGrid';
    //this.autoHeight = true; // if missing = no items displayed, bug?
    this.height = 250;
    if (Ext.isIE) {
        this.width = 250;
    }
    this.layout = 'fit';
    this.autoScroll = true;
    this.viewConfig = {
        forceFit: true
    };
    this.title = 'GUI Object Properties';
    this.customRenderers = { //Extension
        'HAP-Module': gridRenderer,
        'HAP-Device': gridRenderer,
        'HAP-Macro': gridRenderer,
        'HAP-TriggerDevices': gridRenderer,
        'Target View': gridRenderer,
        'Target Scene': gridRenderer
    };
    //this.propertyNames = {
    //    'backgroundColor': 'Backround Color'
    //};
    this.customEditors = {
        'HAP-Module': new Ext.grid.GridEditor(new HAP.GridComboModules({
            id: 'gridComboModules'
        })),
        'HAP-Device': new Ext.grid.GridEditor(new HAP.GridComboDevices({
            id: 'gridComboDevices'
        })),
        'HAP-Macro': new Ext.grid.GridEditor(new HAP.GridComboMacros({
            id: 'gridMacros'
        })),
        'HAP-TriggerDevices': new Ext.grid.GridEditor(new HAP.GridComboTriggerDevices({
            id: 'gridComboTriggerDevices'
        })),
        'Label': new Ext.grid.GridEditor(new HAP.GridTextLabel(this.id, {
            id: 'gridTextLabel',
            selectOnFocus: true
        })),
        'Image': new Ext.grid.GridEditor(new HAP.GridImageTrigger({
            targetGrid: this.id,
            targetRowName: 'Image'
        })),
        'On-Image': new Ext.grid.GridEditor(new HAP.GridImageTrigger({
            targetGrid: this.id,
            targetRowName: 'On-Image'
        })),
        'Button On-Image': new Ext.grid.GridEditor(new HAP.GridImageTrigger({
            targetGrid: this.id,
            targetRowName: 'Button On-Image',
            redimWrapper: false
        })),
        'Button Off-Image': new Ext.grid.GridEditor(new HAP.GridImageTrigger({
            targetGrid: this.id,
            targetRowName: 'Button Off-Image',
            redimWrapper: false
        })),
        'Button Transition-Image': new Ext.grid.GridEditor(new HAP.GridImageTrigger({
            targetGrid: this.id,
            targetRowName: 'Button Transition-Image',
            redimWrapper: false
        })),
        'Off-Image': new Ext.grid.GridEditor(new HAP.GridImageTrigger({
            targetGrid: this.id,
            targetRowName: 'Off-Image'
        })),
        'Transition-Image': new Ext.grid.GridEditor(new HAP.GridImageTrigger({
            targetGrid: this.id,
            targetRowName: 'Transition-Image'
        })),
        'Slider Image': new Ext.grid.GridEditor(new HAP.GridImageTrigger({
            targetGrid: this.id,
            targetRowName: 'Slider Image'
        })),
        'Slider Thumb-Image': new Ext.grid.GridEditor(new HAP.GridImageTrigger({
            targetGrid: this.id,
            targetRowName: 'Slider Thumb-Image',
            redimWrapper: false
        })),
        'Font-color': new Ext.grid.GridEditor(new HAP.GridColorField(this.id, 'Font-color', {
            showHexValue: true
        })),
        'Value Font-color': new Ext.grid.GridEditor(new HAP.GridColorField(this.id, 'Font-color', {
            showHexValue: true
        })),
        'Target View': new Ext.grid.GridEditor(new HAP.GridComboView({
            id: 'gridComboView'
        })),
        'Target Scene': new Ext.grid.GridEditor(new HAP.GridComboScene({
            id: 'gridComboScene'
        })),
        'Target External': new Ext.grid.GridEditor(new Ext.form.TextField({
            id: 'gridTextExternalTarget',
            listeners: {
                'change': clearOtherViews
            }
        })),
        /* --- Chart ----*/
        'Chart-Data': new Ext.grid.GridEditor(new HAP.GridChartObject({
            targetGrid: this.id,
            targetRowName: 'Chart-Data',
            redimWrapper: false
        })),
        'Chart-Properties': new Ext.grid.GridEditor(new HAP.GridChart5Object({
            targetGrid: this.id,
            targetRowName: 'Chart-Properties',
            redimWrapper: false
        })),
        'backgroundColor': new Ext.grid.GridEditor(new HAP.GridColorField(this.id, 'Font-color', {
            showHexValue: true
        })),
        'fillColor': new Ext.grid.GridEditor(new HAP.GridColorField(this.id, 'Font-color', {
            showHexValue: true
        })),
        'color': new Ext.grid.GridEditor(new HAP.GridColorField(this.id, 'Font-color', {
            showHexValue: true
        })),
        'tickColor': new Ext.grid.GridEditor(new HAP.GridColorField(this.id, 'Font-color', {
            showHexValue: true
        })),
        'labelBackgroundColor': new Ext.grid.GridEditor(new HAP.GridColorField(this.id, 'Font-color', {
            showHexValue: true
        })),
        'Chart-Type': new Ext.grid.GridEditor(new HAP.GridComboChartType({
            id: 'gridComboChartType'
        }))
    };
    this.source = {};
    HAP.GUIPropertyGrid.superclass.constructor.call(this);
    
    //this.store.sortInfo = null; // this little fu** statement avoids sorting
    
    this.on('propertychange', function(prop , b){
        if (Ext.getCmp('guiPropertyGrid').getCurrentFigure()) {
          Ext.getCmp('guiPropertyGrid').getCurrentFigure().setGUIObjectConfig();
        }
        if (Ext.getCmp('treeChartProp')) {
          var node = Ext.getCmp('treeChartProp').getSelectionModel().getSelectedNode();
          if (node && prop.Description) {
            node.setText(prop.Description);
          }
        }
    });
    
}

Ext.extend(HAP.GUIPropertyGrid, Ext.grid.PropertyGrid, {
    setGrid: function(figure){
        this.figure = figure;
        if (figure.guiObject) {
            this.conf = figure.guiObject.conf;
        }
        else {
            this.conf = figure.conf;
        }
        this.stopEditing(); // wichtig, sonst fehler
        if (this.conf.display['HAP-Module'] && this.conf.display['HAP-Module'] != 0) {
            storeAllDevices.proxy = new Ext.data.HttpProxy({
                url: '/json/getAllDevices/' + this.conf.display['HAP-Module']
            });
            storeAllDevices.load({
                callback: function(){
                    this.setSource(this.conf.display);
                },
                scope: this
            });
        }
        else {
            this.setSource(this.conf.display);
        }
    },
    blank: function(){
        this.stopEditing();
        this.setSource({});
    },
    getCurrentFigure: function(){
        return this.figure;
    }
});
/*
 * Ext JS Library 2.0.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://extjs.com/license
 */
var ImageChooser = function(config){
    this.config = config;
}

ImageChooser.prototype = {
    // cache data by image name for easy lookup
    lookup: {},
    
    show: function(el, callback){
        if (!this.win) {
        
            this.initTemplates();
            
            this.store = new Ext.data.JsonStore({
                url: this.config.url,
                root: 'images',
                fields: ['name', 'url', 'w', 'h', {
                    name: 'size',
                    type: 'float'
                }],
                listeners: {
                    'load': {
                        fn: function(){
                            this.view.select(0);
                        },
                        scope: this,
                        single: true
                    }
                }
            });
            this.store.load();
            
            var formatSize = function(data){
                if (data.size < 1024) {
                    return data.size + " bytes";
                }
                else {
                    return (Math.round(((data.size * 10) / 1024)) / 10) + " KB";
                }
            };
            
            var formatData = function(data){
                data.shortName = data.name.ellipse(15);
                data.sizeString = formatSize(data);
                data.w = parseInt(data.w);
                data.h = parseInt(data.h);
                if (data.w > 60 || data.h > 60) {
                    var scale = 1;
                    if (data.w > data.h) {
                        scale = data.w / 60;
                    }
                    else {
                        scale = data.h / 60;
                    }
                    data.wS = data.w / scale;
                    data.hS = data.h / scale;
                }
                else {
                    data.wS = data.w;
                    data.hS = data.h;
                }
                this.lookup[data.name] = data;
                return data;
            };
            
            
            this.view = new Ext.DataView({
                tpl: this.thumbTemplate,
                singleSelect: true,
                overClass: 'x-view-over',
                itemSelector: 'div.thumb-wrap',
                emptyText: '<div style="padding:10px;">No images match the specified filter</div>',
                store: this.store,
                listeners: {
                    'selectionchange': {
                        fn: this.showDetails,
                        scope: this,
                        buffer: 100
                    },
                    'dblclick': {
                        fn: this.doCallback,
                        scope: this
                    },
                    'loadexception': {
                        fn: this.onLoadException,
                        scope: this
                    },
                    'beforeselect': {
                        fn: function(view){
                            return view.store.getRange().length > 0;
                        }
                    }
                },
                prepareData: formatData.createDelegate(this)
            });
            
            var oThis = this;
            var cfg = {
                title: 'Choose an Image',
                id: 'img-chooser-dlg',
                layout: 'border',
                width: 800,
                height: 500,
                modal: true,
                //closeAction: 'hide',
                border: false,
                items: [{
                    id: 'img-chooser-view',
                    region: 'center',
                    autoScroll: true,
                    items: this.view,
                    tbar: [{
                        text: 'Filter:'
                    }, {
                        xtype: 'textfield',
                        id: 'filter',
                        selectOnFocus: true,
                        width: 100,
                        listeners: {
                            'render': {
                                fn: function(){
                                    Ext.getCmp('filter').getEl().on('keyup', function(){
                                        this.filter();
                                    }, this, {
                                        buffer: 500
                                    });
                                },
                                scope: this
                            }
                        }
                    }, ' ', '-', {
                        text: 'Sort By:'
                    }, {
                        id: 'sortSelect',
                        xtype: 'combo',
                        typeAhead: true,
                        triggerAction: 'all',
                        width: 100,
                        editable: false,
                        mode: 'local',
                        displayField: 'desc',
                        valueField: 'name',
                        lazyInit: false,
                        value: 'name',
                        store: new Ext.data.SimpleStore({
                            fields: ['name', 'desc'],
                            data: [['name', 'Name'], ['size', 'File Size'], ['w', 'Width'], ['h', 'Height']]
                        }),
                        listeners: {
                            'select': {
                                fn: this.sortImages,
                                scope: this
                            }
                        }
                    }]
                }, {
                    id: 'img-detail-panel',
                    region: 'east',
                    autoScroll: true,
                    split: true,
                    width: 400
                }],
                
                buttons: [{
                    id: 'ok-btn',
                    text: 'OK',
                    handler: this.doCallback,
                    scope: this
                }, {
                    text: 'Cancel',
                    handler: function(){
                        this.win.close();
                    },
                    scope: this
                }, {
                    text: 'Upload..',
                    iconCls: 'upload',
                    handler: function(){
                        HAP.UploadFileWindow(null, null, function(){
                            oThis.store.reload(); //callback
                        });
                    }
                }, {
                    text: 'Delete',
                    iconCls: 'delete',
                    handler: this.deleteImage,
                    scope: this
                }],
                
                keys: {
                    key: 27, // Esc key
                    handler: function(){
                        this.win.close();
                    },
                    scope: this
                }
            
            };
            Ext.apply(cfg, this.config);
            this.win = new Ext.Window(cfg);
        }
        this.reset();
        this.win.show(el);
        this.win.setZIndex(10001); //fix for Firefox 3
        this.callback = callback;
        this.animateTarget = el;
    },
    
    initTemplates: function(){
        this.thumbTemplate = new Ext.XTemplate('<tpl for=".">', '<div class="thumb-wrap" id="{name}">', '<div class="thumb"><img style="width:{wS}px; height:{hS}px" src="{url}" title="{name}"></div>', '<span>{shortName}</span></div>', '</tpl>');
        this.thumbTemplate.compile();
        
        this.detailsTemplate = new Ext.XTemplate('<div class="details">', '<tpl for=".">', '<div class="details-info">', '<b>Image Name:</b>', '<span>{name}</span>', '<b> - Size:</b>', '<span>{sizeString}</span>', '<b> - Dimension:</b>', '<span>w:{w}px, h:{h}px</span>', '</div> <img src="{url}">', '</tpl>', '</div>');
        this.detailsTemplate.compile();
    },
    
    showDetails: function(){
        var selNode = this.view.getSelectedNodes();
        var detailEl = Ext.getCmp('img-detail-panel').body;
        if (selNode && selNode.length > 0) {
            selNode = selNode[0];
            Ext.getCmp('ok-btn').enable();
            var data = this.lookup[selNode.id];
            detailEl.hide();
            this.detailsTemplate.overwrite(detailEl, data);
            detailEl.slideIn('l', {
                stopFx: true,
                duration: 0.2
            });
        }
        else {
            Ext.getCmp('ok-btn').disable();
            detailEl.update('');
        }
    },
    
    filter: function(){
        var filter = Ext.getCmp('filter');
        this.view.store.filter('name', filter.getValue());
        this.view.select(0);
    },
    
    sortImages: function(){
        var v = Ext.getCmp('sortSelect').getValue();
        this.view.store.sort(v, v == 'name' ? 'asc' : 'desc');
        this.view.select(0);
    },
    
    reset: function(){
        if (this.win.rendered) {
            Ext.getCmp('filter').reset();
            this.view.getEl().dom.scrollTop = 0;
        }
        this.view.store.clearFilter();
        this.view.select(0);
    },
    
    doCallback: function(){
        var selNode = this.view.getSelectedNodes()[0];
        var callback = this.callback;
        var lookup = this.lookup;
        if (selNode && callback) {
            var data = lookup[selNode.id];
            callback(data);
            this.win.close();
        }
        /*
         this.win.hide(this.animateTarget, function(){
         if (selNode && callback) {
         var data = lookup[selNode.id];
         callback(data);
         }
         });
         */
    },
    deleteImage: function(){
        var selNode = this.view.getSelectedNodes()[0];
        var data = this.lookup[selNode.id];
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'POST',
            url: '/fileupload/deleteImage',
            params: {
                file: data.name
            }
        });
        var oThis = this;
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.util.JSON.decode(param.responseText);
            if (!response.success) 
                Ext.MessageBox.show({
                    title: 'Warning',
                    msg: "File delete failed.",
                    buttons: Ext.Msg.OK
                });
            else 
                oThis.store.reload();
        });
    },
    
    onLoadException: function(v, o){
        this.view.getEl().update('<div style="padding:10px;">Error loading images.</div>');
    }
};

String.prototype.ellipse = function(maxLength){
    if (this.length > maxLength) {
        return this.substr(0, maxLength - 3) + '...';
    }
    return this;
};
/**
 * @class Ext.form.ColorField
 * @extends Ext.form.TriggerField
 * Provides a very simple color form field with a ColorMenu dropdown.
 * Values are stored as a six-character hex value without the '#'.
 * I.e. 'ffffff'
 * @constructor
 * Create a new ColorField
 * <br />Example:
 * <pre><code>
var cf = new Ext.form.ColorField({
	fieldLabel: 'Color',
	hiddenName:'pref_sales',
	showHexValue:true
});
</code></pre>
 * @param {Object} config
 */
Ext.form.ColorField = function(config){
    Ext.form.ColorField.superclass.constructor.call(this, config);
	this.on('render', this.handleRender);
};

Ext.extend(Ext.form.ColorField, Ext.form.TriggerField,  {
    /**
     * @cfg {Boolean} showHexValue
     * True to display the HTML Hexidecimal Color Value in the field
     * so it is manually editable.
     */
    
    showHexValue : false,
	
	/**
     * @cfg {String} triggerClass
     * An additional CSS class used to style the trigger button.  The trigger will always get the
     * class 'x-form-trigger' and triggerClass will be <b>appended</b> if specified (defaults to 'x-form-color-trigger'
     * which displays a calendar icon).
     */
    triggerClass : 'x-form-color-trigger',
	
    /**
     * @cfg {String/Object} autoCreate
     * A DomHelper element spec, or true for a default element spec (defaults to
     * {tag: "input", type: "text", size: "10", autocomplete: "off"})
     */
    // private
    defaultAutoCreate : {tag: "input", type: "text", size: "10",
						 autocomplete: "off", maxlength:"6"},
	
	/**
	 * @cfg {String} lengthText
	 * A string to be displayed when the length of the input field is
	 * not 3 or 6, i.e. 'fff' or 'ffccff'.
	 */
	lengthText: "Color hex values must be either 3 or 6 characters.",
	
	//text to use if blank and allowBlank is false
	blankText: "Must have a hexidecimal value in the format ABCDEF.",
	
	/**
	 * @cfg {String} color
	 * A string hex value to be used as the default color.  Defaults
	 * to 'FFFFFF' (white).
	 */
	defaultColor: 'FFFFFF',
	
	maskRe: /[a-f0-9]/i,
	// These regexes limit input and validation to hex values
	regex: /[a-f0-9]/i,

	//private
	curColor: 'ffffff',
	
    // private
    validateValue : function(value){
		if(!this.showHexValue) {
			return true;
		}
		if(value.length<1) {
			this.el.setStyle({
				'background-color':'#' + this.defaultColor
			});
			if(!this.allowBlank) {
				this.markInvalid(String.format(this.blankText, value));
				return false
			}
			return true;
		}
		if(value.length!=3 && value.length!=6 ) {
			this.markInvalid(String.format(this.lengthText, value));
			return false;
		}
		this.setColor(value);
        return true;
    },

    // private
    validateBlur : function(){
        return !this.menu || !this.menu.isVisible();
    },
	  
	// Manually apply the invalid line image since the background
	// was previously cleared so the color would show through.
	markInvalid : function( msg ) {
		Ext.form.ColorField.superclass.markInvalid.call(this, msg);
		this.el.setStyle({
			'background-image': 'url(../lib/resources/images/default/grid/invalid_line.gif)'
		});
	},

    /**
     * Returns the current color value of the color field
     * @return {String} value The hexidecimal color value
     */
    getValue : function(){
		return this.curColor || this.defaultValue || "FFFFFF";
    },

    /**
     * Sets the value of the color field.  Format as hex value 'FFFFFF'
     * without the '#'.
     * @param {String} hex The color value
     */
    setValue : function(hex){
  	Ext.form.ColorField.superclass.setValue.call(this, hex);
	 	this.setColor(hex);
    },
	
	/**
	 * Sets the current color and changes the background.
	 * Does *not* change the value of the field.
	 * @param {String} hex The color value.
	 */
  
	setColor : function(hex) {
		this.curColor = hex;
		 //var gridStore = Ext.getCmp('guiPropertyGrid').getStore(); //modify Triggerfield via setValue wont work !
     //gridStore.getById("Font-color").set("value", this.curColor);
 
		this.el.setStyle( {
			'background-color': '#' + hex,
			'background-image': 'none'
		});
		if(!this.showHexValue) {
			this.el.setStyle({
				'text-indent': '-100px'
			});
			if(Ext.isIE) {
				this.el.setStyle({
					'margin-left': '100px'
				});
			}
		}
	},
	
	
	handleRender: function() {
		//this.setDefaultColor();
	},
	
	setDefaultColor : function() {
		//this.setValue(this.defaultColor);
	},


    // private
    menuListeners : {
        select: function(m, d){
            this.setValue(d);
        },
        show : function(){ // retain focus styling
            this.onFocus();
        },
        hide : function(){
            this.focus();
            var ml = this.menuListeners;
            this.menu.un("select", ml.select,  this);
            this.menu.un("show", ml.show,  this);
            this.menu.un("hide", ml.hide,  this);
        }
    },
	
	//private
	handleSelect : function(palette, selColor) {
		this.setValue(selColor);
	},
  
  //onBlur: function() {
  //  var gridStore = Ext.getCmp('guiPropertyGrid').getStore(); //modify Triggerfield via setValue wont work !
  //   gridStore.getById("Font-color").set("value", this.curColor);
  //},
  
    // private
    // Implements the default empty TriggerField.onTriggerClick function to display the ColorPicker
    onTriggerClick : function(){
        if(this.disabled){
            return;
        }
        if(this.menu == null){
            this.menu = new Ext.menu.ColorMenu();
			      this.menu.palette.on('select', this.handleSelect, this );
        }
        this.menu.on(Ext.apply({}, this.menuListeners, {
            scope:this
        }));
        this.menu.show(this.el, "tl-bl?");
    }
});