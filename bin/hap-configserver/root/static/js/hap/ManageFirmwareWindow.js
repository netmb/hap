HAP.ManageFirmwareWindow = function(id){

    storeFirmware.load();
    
    var sm = new Ext.grid.CheckboxSelectionModel({
        singleSelect: false
    });
    
    var checkColumnPreCompiled = new Ext.grid.CheckColumn({
        header: 'Pre-Compiled',
        dataIndex: 'precompiled',
        inputValue: 1,
        width: 75
    });
    
    var cm = new Ext.grid.ColumnModel([sm, {
        header: 'Name',
        dataIndex: 'name',
        sortable: true,
        width: 200,
        editor: new Ext.form.TextField({
            allowBlank: false
        })
    }, checkColumnPreCompiled, {
        header: 'Version',
        dataIndex: 'version',
        sortable: true,
        width: 60
    }, {
        header: 'Date',
        dataIndex: 'date',
        sortable: true,
        width: 60
    }, {
        header: 'Filename',
        dataIndex: 'filename',
        sortable: true,
        width: 160
    }]);
    
    var newConfig = Ext.data.Record.create([{
        name: 'name',
        type: 'string'
    }, {
        name: 'id'
    }]);
    
    var grid = new Ext.grid.EditorGridPanel({
        store: storeFirmware,
        cm: cm,
        width: 565,
        autoWidth: true,
        autoHeight: true,
        autoExpandColumn: 'name',
        frame: false,
        sm: sm,
        plugins: [checkColumnPreCompiled],
        viewConfig: {
            forceFit: true
        },
        tbar: [{
            text: 'Save Changes',
            handler: saveChanges,
            iconCls: 'save'
        }, '-', {
            text: 'Add',
            handler: addFirmware,
            iconCls: 'add'
        }, '-', {
            text: 'Delete',
            handler: deleteFirmware,
            iconCls: 'delete'
        }]
    });
    
    function saveChanges(){
        var mr = storeFirmware.getModifiedRecords();
        if (mr.length > 0) {
            var data = new Array;
            for (var index in mr) {
                data.push(mr[index].data);
            }
            var conn = new Ext.data.Connection();
            conn.request({
                method: 'POST',
                url: '/managefirmware/setFirmware',
                params: {
                    data: Ext.util.JSON.encode(data)
                }
            });
            conn.on('requestcomplete', function(sender, param){
                var response = Ext.util.JSON.decode(param.responseText);
                if (response.success) {
                    storeFirmware.reload();
                }
                else {
                    Ext.MessageBox.alert('Warning', response.info);
                }
            }, {
                scope: this
            });
        }
    }
    
    function addFirmware(){
        HAP.UploadFileWindow();
    }
    
    function deleteFirmware(){
        Ext.MessageBox.show({
            title: 'Warning',
            msg: 'Are you sure that you want to remove the selected firmware(s)?',
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
                        url: '/managefirmware/delFirmware',
                        params: {
                            data: Ext.util.JSON.encode(data)
                        }
                    });
                    conn.on('requestcomplete', function(sender, param){
                        var response = Ext.decode(param.responseText);
                        if (response.success) {
                            storeFirmware.reload();
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
    
    var win = new Ext.Window({
        title: 'Firmware Repository',
        iconCls: 'firmwareRepository',
        closable: true,
        width: 585,
        autoScroll: true,
        items: [grid]
    });
    
    win.show(this);
    
    // mark uploaded firmware (lastOptions.parms get set when upload finished - see HAP.UploadFileWindow)
    storeFirmware.on('load', function(){
        if (storeFirmware.lastOptions.parms) {
            var selRecords = grid.getSelectionModel().getSelections();
            selRecords.push(storeFirmware.getById(storeFirmware.lastOptions.parms.firmwareid));
            sm.selectRecords(selRecords);
        }
    })
    
}
