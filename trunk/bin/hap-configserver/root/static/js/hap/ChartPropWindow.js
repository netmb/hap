
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
