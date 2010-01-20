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
