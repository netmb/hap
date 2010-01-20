HAP.GridImageTrigger = function(config){
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
        Ext.getCmp('gridComboDevices').loadDevices(this.value);
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
