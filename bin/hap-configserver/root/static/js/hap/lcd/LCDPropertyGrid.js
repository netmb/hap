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
