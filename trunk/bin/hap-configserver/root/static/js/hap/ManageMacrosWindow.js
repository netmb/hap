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

