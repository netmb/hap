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
    
    this.on('propertychange', function(){
        if (Ext.getCmp('guiPropertyGrid').getCurrentFigure()) {
          Ext.getCmp('guiPropertyGrid').getCurrentFigure().setGUIObjectConfig();
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
