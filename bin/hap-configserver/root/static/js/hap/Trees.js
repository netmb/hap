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
                text: newName + ' [' + newId + ']',
                scriptName : newId + "." + newName, 
                id: type + '/' + newId
            }));
            this.getNodeById(type + '/' + newId).select();
        }
    },
    updateHapNode: function(url, newName){
        if (this.getNodeById(url)) {
            if (this.getNodeById(url)) {// maybe a bug?: If tree-node isnt expanded, it doesnt exist in dom !
                var node = this.getNodeById(url);
                node.setText(newName + ' [' + node.id.split('/')[1] + ']');
                node.attributes.scriptName = node.id.split('/')[1] + "." + newName; 
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
            case 'homematic':
                p = new HAP.HomematicPanel(node.attributes);
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
