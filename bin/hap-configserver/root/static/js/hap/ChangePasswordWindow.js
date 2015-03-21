HAP.ChangePasswordWindow = function(){
	var oThis = this;
    function saveButtonClick(){
        if (Ext.getCmp('npassword1').getValue() == Ext.getCmp('npassword2').getValue()) {
            if (Ext.getCmp('npassword1').getValue() == '' || Ext.getCmp('npassword2').getValue() == '') {
                Ext.MessageBox.alert('Warning', 'Password not set');
            }
            else {
                var conn = new Ext.data.Connection();
                conn.request({
                    method: 'POST',
                    url: 'users/setUserPassword',
                    params: {
                        password: Ext.getCmp('npassword1').getValue()
                    }
                });
                conn.on('requestcomplete', function(sender, param){
                    var response = Ext.util.JSON.decode(param.responseText);
                    if (response.success) {
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
    };
    
    this.id = 'changePasswordWindow';
    this.modal = true;
    this.title = 'Change Password';
	this.iconCls = 'password';
    this.layout = 'fit';
    this.width = '400';
    this.autoHeight = true;
    this.plain = true;
    this.items = [{
        id: 'formChangePassword',
        xtype: 'form',
        frame: true,
        labelWidth: 120,
        autoHeight: true,
        //height: '200',
        items: [{
            xtype: 'textfield',
            fieldLabel: 'Password',
            inputType: 'password',
            name: 'npassword1',
            id: 'npassword1',
            hiddenname: 'npassword1',
            anchor: '100%'
        }, {
            xtype: 'textfield',
            fieldLabel: 'Password (re-type)',
            inputType: 'password',
            id: 'npassword2',
            name: 'npassword2',
            hiddenname: 'npassword2',
            anchor: '100%'
        }]
    }];
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClick();
        },
        scope: this
    }];
    this.buttons = [{
        text: 'OK',
        iconCls: 'ok',
        scope: this,
        handler: saveButtonClick
    }, {
        text: 'Cancel',
        iconCls: 'cancel',
        handler: function(){
            oThis.close();
        }
    }];
    HAP.ChangePasswordWindow.superclass.constructor.call(this);
};

Ext.extend(HAP.ChangePasswordWindow, Ext.Window, {});
