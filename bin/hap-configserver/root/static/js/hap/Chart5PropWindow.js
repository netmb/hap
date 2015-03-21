
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
