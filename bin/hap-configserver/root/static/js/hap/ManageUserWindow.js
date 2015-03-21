HAP.ManageUserWindow = function(item){

    storeUsers.load();
    
    var sm = new Ext.grid.CheckboxSelectionModel({});
    
    var cm = new Ext.grid.ColumnModel([sm, {
        id: 'name',
        header: 'Username',
        dataIndex: 'username',
        sortable: true,
        width: 350,
        editor: new Ext.form.TextField({
            allowBlank: false
        })
    }]);
    
    var newUser = Ext.data.Record.create([{
        name: 'id'
    }, {
        name: 'username',
        type: 'text'
    }, {
        name: 'password',
        type: 'text'
    }, {
        name: 'password1',
        type: 'text'
    }, {
        name: 'password2',
        type: 'text'
    }, {
        name: 'prename',
        type: 'text'
    }, {
        name: 'surname',
        type: 'text'
    }, {
        name: 'email',
        type: 'text'
    }])
    
    var grid = new Ext.grid.EditorGridPanel({
        id: 'gridUsers',
        store: storeUsers,
        cm: cm,
        height: 300,
        autoExpandColumn: 'username',
        frame: false,
        sm: sm,
        viewConfig: {
            forceFit: true
        }
    });
    
    function saveChanges(){
        var mr = storeUsers.getModifiedRecords();
        if (mr.length > 0) {
            var data = new Array;
            for (var index in mr) {
                data.push(mr[index].data);
            }
            var conn = new Ext.data.Connection();
            conn.request({
                method: 'POST',
                url: '/users/submit',
                params: {
                    data: Ext.util.JSON.encode(data)
                }
            });
            conn.on('requestcomplete', function(sender, param){
                var response = Ext.util.JSON.decode(param.responseText);
                if (response.success) {
                    storeUsers.reload({
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
    
    function addUser(){
        grid.stopEditing();
        var c = new newUser({
            id: 0,
            username: "",
            password: "",
            prename: "",
            surname: "",
            email: ""
        });
        storeUsers.insert(0, c);
        grid.getSelectionModel().selectRow(0);
        grid.startEditing(0, 1);
    }
    
    function deleteUser(){
        Ext.MessageBox.show({
            title: 'Warning',
            msg: 'Are you sure that you want to delete this user?',
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
                        url: '/users/delete',
                        params: {
                            data: Ext.util.JSON.encode(data)
                        }
                    });
                    conn.on('requestcomplete', function(sender, param){
                        var response = Ext.util.JSON.decode(param.responseText);
                        if (response.success) {
                            storeUsers.reload();
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
    
    function editUser(){
        var sm = grid.getSelectionModel();
        if (sm.getSelected() == null) {
            Ext.MessageBox.alert('Warning', 'No selections');
            return;
        }
        if (sm.getCount() > 1) {
            Ext.MessageBox.alert('Warning', 'No multiple selections allowed');
            return;
        }
        var mr = sm.getSelections();
        
        var win = new HAP.UserPropWindow(sm.getSelected().data.id);
        win.show();
    }
    
    var win = new Ext.Window({
        title: 'Manage Users',
        iconCls: 'user',
        modal: true,
        closable: true,
        width: 350,
        height: 350,
        autoScroll: true,
        layout: 'fit', // important -> tells sub-components to fit (showing scrollbars correctly)
        items: [grid],
        tbar: [{
            text: 'Save Changes',
            handler: saveChanges,
            iconCls: 'save'
        }, '-', {
            text: 'Add',
            handler: addUser,
            iconCls: 'add'
        }, {
            text: 'Edit',
            handler: editUser,
            iconCls: 'edit'
        }, '-', {
            text: 'Delete',
            handler: deleteUser,
            iconCls: 'delete'
        }]
    });
    
    win.show(this);
    
}
