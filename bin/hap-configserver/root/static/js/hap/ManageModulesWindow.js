HAP.ManageModulesWindow = function(item){

    storeModuleProps.load();
    
    var sm = new Ext.grid.CheckboxSelectionModel({
        singleSelect: false
    });
    
    var checkColumnFullConfig = new Ext.grid.CheckColumn({
        header: 'Push Config',
        dataIndex: 'devoption/4',
        inputValue: 4,
        width: 75
    });
    
    var checkColumnWireless = new Ext.grid.CheckColumn({
        header: 'Via Wireless',
        dataIndex: 'devoption/2',
        inputValue: 2,
        width: 85
    });
    
    var checkColumnLcd = new Ext.grid.CheckColumn({
        header: 'Push LCD',
        dataIndex: 'devoption/1',
        inputValue: 1,
        width: 75
    });
    
    var cm = new Ext.grid.ColumnModel([sm, {
        id: 'manageModulesName',
        header: 'Name',
        dataIndex: 'name',
        sortable: true,
        width: 230,
        editor: new Ext.form.TextField({
            allowBlank: false
        })
    }, checkColumnFullConfig, checkColumnLcd, checkColumnWireless, {
        id: 'manageModulesFirmware',
        header: 'Firmware',
        dataIndex: 'firmwareid',
        sortable: true,
        width: 200,
        editor: new HAP.ComboFirmware({}),
        renderer: function(data){
            record = storeFirmware.getById(data);
            if (record) {
                return record.data.name;
            }
            else {
                return data;
            }
        }
    }]);
    
    var grid = new Ext.grid.EditorGridPanel({
        ds: storeModuleProps,
        cm: cm,
        width: 665,
        autoHeight: true,
        autoExpandColumn: 'name',
        frame: false,
        sm: sm,
        plugins: [checkColumnFullConfig, checkColumnWireless, checkColumnLcd],
        clicksToEdit: 1,
        viewConfig: {
            forceFit: true
        },
        tbar: [{
            text: 'Save Changes',
            handler: saveChanges,
            iconCls: 'save'
        }, '-', {
            text: 'Run Task',
            handler: pushConfig,
            iconCls: 'go'
        }, '-', {
            text: 'Flash',
            handler: flash,
            iconCls: 'flash'
        }, '-', {
            text: 'Reset',
            handler: reset,
            iconCls: 'reset'
        }]
    });
    
    function saveChanges(){
        var mr = storeModuleProps.getModifiedRecords();
        var data = new Array;
        for (var index in mr) {
            data.push(mr[index].data);
        }
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'POST',
            url: '/managemodules/setModules',
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
                    storeModuleProps.commitChanges();
                    for (var i in response.data) {
                        Ext.getCmp('treeModule').updateHapNode(response.data[i].url, response.data[i].name);
                        Ext.getCmp('treeRoom').updateHapNode(response.data[i].url, response.data[i].name);
                    }
                    storeModules.reload();
                }
        }, {
            scope: this
        });
    }
    
    function pushConfig(){
        saveChanges();
        if (grid.getSelectionModel().getSelected() == null) {
            Ext.MessageBox.alert('Warning', 'No module selected');
            return;
        }
        var sel = grid.getSelectionModel().getSelections();
        var data = new Array;
        for (var index in sel) {
            data.push(sel[index].data);
        }
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'POST',
            url: '/managemodules/pushConfig',
            params: {
                data: Ext.util.JSON.encode(data)
            }
        });
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.decode(param.responseText);
            if (response.permissiondenied) {
                var loginWindow = new HAP.LoginWindow();
                loginWindow.show();
            }
            else 
                if (response.success) {
                    storeModuleProps.commitChanges();
                    win.hide();
                    win.destroy();
                    HAP.ManageSchedulerWindow();
                    Ext.getCmp('schedulerLiveMonitorButton').toggle(true);
                    Ext.getCmp('logLiveMonitorButton').toggle(true);
                }
                else {
                    Ext.MessageBox.alert('Warning', response.info);
                }
        }, {
            scope: this
        });
    }
    
    function flash(){
        saveChanges();
        if (grid.getSelectionModel().getSelected() == null) {
            Ext.MessageBox.alert('Warning', 'No module selected');
            return;
        }
        Ext.MessageBox.show({
            title: 'Warning',
            msg: 'Are you sure that you want start the flash-process?',
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
                        url: '/managemodules/flashFirmware',
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
                                storeModuleProps.commitChanges();
                                win.hide();
                                win.destroy();
                                HAP.ManageSchedulerWindow();
                                Ext.getCmp('schedulerLiveMonitorButton').toggle(true);
                                Ext.getCmp('logLiveMonitorButton').toggle(true);
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
    
    function reset(){
        if (grid.getSelectionModel().getSelected() == null) {
            Ext.MessageBox.alert('Warning', 'No module selected');
            return;
        }
        var sel = grid.getSelectionModel().getSelections();
        var data = new Array;
        for (var index in sel) {
            data.push(sel[index].data);
        }
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'POST',
            url: '/managemodules/resetModules',
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
                    storeModuleProps.commitChanges();
                    win.hide();
                    win.destroy();
                    HAP.ManageSchedulerWindow();
                    Ext.getCmp('schedulerLiveMonitorButton').toggle(true);
                    Ext.getCmp('logLiveMonitorButton').toggle(true);
                }
                else {
                    Ext.MessageBox.alert('Warning', response.info);
                }
        }, {
            scope: this
        });
    }
    
    var win = new Ext.Window({
        title: 'Manage Modules',
        iconCls: 'module',
        closable: true,
        width: 680,
        autoHeight: true,
        autoScroll: true,
        items: [grid]
    });
    win.show(this);
    
}

