HAP.UserPropWindow = function(userId){
    this.id = 'winUser';
    this.iconCls = 'user';
	this.modal = true;
    this.title = 'Edit user';
    this.layout = 'fit';
    this.width = '400';
    this.autoHeight = true;
    this.plain = true;
    this.items = [{
        id: 'formUser',
        xtype: 'form',
        frame: true,
        autoHeight: true,
        items: [{
            xtype: 'fieldset',
            title: 'User-details',
            collapsible: false,
            autoHeight: true,
            defaultType: 'textfield',
            items: [{
                xtype: 'textfield',
                fieldLabel: 'Username',
                name: 'username',
                hiddenName: 'username',
                anchor: '100%'
            }, {
                xtype: 'textfield',
                fieldLabel: 'Prename',
                name: 'prename',
                hiddenName: 'prename',
                anchor: '100%'
            }, {
                xtype: 'textfield',
                fieldLabel: 'Surname',
                name: 'surname',
                hiddenName: 'surname',
                anchor: '100%'
            }, {
                xtype: 'textfield',
                fieldLabel: 'E-Mail',
                name: 'email',
                hiddenName: 'email',
                anchor: '100%'
            }]
        }, {
            xtype: 'fieldset',
            title: 'Password',
            autoHeight: true,
            defaultType: 'textfield',
            labelWidth: 130,
            items: [{
                fieldLabel: 'Password',
                inputType: 'password',
                name: 'password1',
                id: 'password1',
                hiddenname: 'password1',
                anchor: '100%'
            }, {
                fieldLabel: 'Password (re-type)',
                inputType: 'password',
                id: 'password2',
                name: 'password2',
                hiddenname: 'password2',
                anchor: '100%'
            }]
        }, {
            xtype: 'fieldset',
            title: 'Roles',
            autoHeight: true,
            items: [new HAP.GridUserRoles(userId)]
        }]
    }];
    var oThis = this;
    this.buttons = [{
        text: 'OK',
        iconCls: 'ok',
        scope: this,
        handler: function(){
            if (Ext.getCmp('password1').getValue() == Ext.getCmp('password2').getValue()) {
                if (Ext.getCmp('password1').getValue() == '' || Ext.getCmp('password2').getValue() == '') {
                    Ext.MessageBox.alert('Warning', 'Password not set');
                }
                else {
                    var mr = storeUserRoles.getModifiedRecords();
                    var roleData = new Array;
                    for (var index in mr) {
                        roleData.push(mr[index].data);
                    }
                    
                    var form = Ext.getCmp('formUser');
                    form.getForm().updateRecord(form.record);
                    
                    var data = new Array;
                    form.record.data.roles = roleData;
                    data.push(form.record.data);
                    
                    var conn = new Ext.data.Connection();
                    conn.request({
                        method: 'POST',
                        url: 'users/submit',
                        params: {
                            data: Ext.util.JSON.encode(data)
                        }
                    });
                    conn.on('requestcomplete', function(sender, param){
                        var response = Ext.util.JSON.decode(param.responseText);
                        if (response.success) {
                            storeUsers.reload();
                            storeUsers.commitChanges();
                            storeUserRoles.commitChanges();
                            var form = Ext.getCmp('formUser');
                            form.getForm().updateRecord(form.record);
                            oThis.close();
                        }
                        else {
                            if (response.permissiondenied) {
                                var loginWindow = new HAP.LoginWindow();
                                loginWindow.show();
                            }
                        }
                    }, {
                        scope: this
                    });
                }
            }
            else {
                Ext.MessageBox.alert('Warning', 'Check password');
            }
        }
    }, {
        text: 'Cancel',
        iconCls: 'cancel',
        handler: function(){
            oThis.close();
        }
    }];
    HAP.UserPropWindow.superclass.constructor.call(this);
    Ext.getCmp('formUser').on('render', function(){
        this.record = Ext.getCmp('gridUsers').getSelectionModel().getSelected();
        Ext.getCmp('formUser').getForm().loadRecord(this.record);
    });
    
};

Ext.extend(HAP.UserPropWindow, Ext.Window, {});
