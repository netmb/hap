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
