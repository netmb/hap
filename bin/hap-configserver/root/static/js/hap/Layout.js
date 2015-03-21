Ext.onReady(function(){
    Ext.Ajax.request({
        url: 'login/status',
        success: function(result, request){
            var userStatus = Ext.decode(result.responseText);
            if (userStatus.roles) {
                userRoles = userStatus.roles;
            }
            if (!userStatus.status) {
                var loginWindow = new HAP.LoginWindow();
                loginWindow.show();
            }
            else {
                var viewport = new HAP.Viewport();
                viewport.show();
                Ext.getCmp('currentUser').setText(userStatus.user);
                Ext.TaskMgr.start(taskLogUpdate);
                configRequest();
            }
        }
    });
    
});

HAP.Viewport = function(){

    /* Init Log Table */
    log = new HAP.LogTable();
    
    var menu = new Ext.menu.Menu({
        id: 'mainMenu',
        items: [{
            text: 'Manage/Select Config',
            iconCls: 'config',
            handler: HAP.ManageConfigWindow
        }, {
            text: 'Manage Modules',
            iconCls: 'module',
            handler: HAP.ManageModulesWindow
        }, {
            text: 'Manage Macros',
            iconCls: 'macro',
            handler: HAP.ManageMacrosWindow
        }, {
            text: 'Manage Macros by datagram',
            iconCls: 'macro',
            handler: HAP.ManageMakroByDatagramWindow
        }, {
            text: 'Manage Scheduler',
            iconCls: 'scheduler',
            handler: HAP.ManageSchedulerWindow
        }, {
            text: 'Firmware Repository',
            iconCls: 'firmwareRepository',
            handler: HAP.ManageFirmwareWindow
        }, new Ext.menu.Separator(), {
            text: 'Change Password',
            iconCls: 'password',
            handler: function(){
                var win = new HAP.ChangePasswordWindow();
                win.show();
            }
        }, {
            text: 'Manage Users',
            iconCls: 'user',
            handler: HAP.ManageUserWindow
        }]
    });
    
    var menuTools = new Ext.menu.Menu({
        id: 'toolsMenu',
        items: [{
            text: 'File Upload',
            iconCls: 'upload',
            handler: HAP.UploadFileWindow
        }, {
            text: 'Download Bootloader',
            iconCls: 'download',
            handler: function(){
                window.open('/bootloader/get');
            }
        }]
    });
    
    var toolbar = new Ext.Toolbar({
        region: 'north',
        height: 27,
        items: [{
            text: 'Manage',
            iconCls: 'config',
            menu: menu
        }, '-', {
            text: 'Tools',
            iconCls: 'manage',
            menu: menuTools
        }, new Ext.Toolbar.Fill(), new Ext.Toolbar.Button({
            id: 'currentUser',
            iconCls: 'user',
            disabled: true,
            text: 'undefined'
        }), new Ext.Toolbar.Button({
            id: 'currentConfig',
            iconCls: 'config',
            disabled: true,
            text: 'undefined'
        }), new Ext.Toolbar.Separator(), new Ext.Toolbar.Button({
            text: 'Logout',
            iconCls: 'logout',
            handler: function(){
                var conn = new Ext.data.Connection();
                conn.request({
                    method: 'GET',
                    url: 'logout'
                });
                conn.on('requestcomplete', function(sender, param){
                    var loginWindow = new HAP.LoginWindow();
                    loginWindow.show();
                    Ext.TaskMgr.stop(taskSpeedLogUpdate);
                    Ext.TaskMgr.stop(taskLogUpdate);
                    Ext.getCmp('vp').destroy();
                }, {
                    scope: this
                });
            }
        })]
    });
    
    this.id = 'vp';
    this.layout = 'border';
    this.items = [toolbar, 
    {
        region: 'south',
        title: 'Log',
        iconCls: 'log',
        collapsible: true,
        collapsed: false,
        split: true,
        minSize: 100,
        height: 150,
        layout: 'fit',
        margins: '0 5 0 0',
        items: [log]
    }, 
    {
        region: 'east',
        id: 'east-panel',
        title: 'Object-Explorer',
        iconCls: 'objectExplorer',
        collapsible: true,
        collapsed: false,
        split: true,
        width: 225,
        minSize: 175,
        margins: '0 5 0 0',
        layout: 'fit',
        xtype: 'panel', //wichtig !
        layout: 'border', // wichtig !
        items: [new HAP.ObjectTreePanel(), new HAP.ObjectPropertyPanel()]
    }, {
        region: 'west',
        id: 'west-panel',
        title: 'Navigation',
        iconCls: 'navigation',
        //hideCollapseTool: true,
        tools: [{
            id: 'refresh',
            qtip: 'Refresh Trees',
            handler: function(event, toolEl, panel){
                Ext.getCmp('treeDevice').root.reload();
                Ext.getCmp('treeModule').root.reload();
                Ext.getCmp('treeRoom').root.reload();
                Ext.getCmp('treeGUI').root.reload();
            }
        }
        /*, {
            id: 'left',
            handler: function(event, toolEl, panel){
                panel.collapse();
            }
        }*/],
        split: true,
        width: 200,
        minSize: 175,
        collapsible: true,
        margins: '0 0 0 5',
        layout: 'accordion',
        layoutConfig: {
            animate: true
        },
        items: [new HAP.TreeDevice, new HAP.TreeModule, new HAP.TreeRoom, new HAP.TreeGUI]
    }, new Ext.TabPanel({
        region: 'center',
        id: 'center-panel',
        enableTabScroll: true,
        deferredRender: false,
        activeTab: 0
    })];
    HAP.Viewport.superclass.constructor.call(this);
};

Ext.extend(HAP.Viewport, Ext.Viewport, {});

var configRequest = function(){
    Ext.Ajax.request({
        url: '/manageconfigs/getCurrentConfig',
        success: function(result, request){
            currentConfig = Ext.decode(result.responseText);
            if (currentConfig.id != 0) {
                loadStores();
                Ext.getCmp('currentConfig').setText(currentConfig.name);
            }
            else {
                var confWindow = new HAP.ManageConfigWindow();
            }
        }
    });
}

