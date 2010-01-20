HAP.LoginWindow = function(){
    this.loginButtonHandler = function(){
        if (!this.loginForm.getForm().isValid()) {
            return;
        }
        var user = this.username.getValue();
        var pass = this.password.getValue();
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'POST',
            url: 'login/check',
            params: {
                user: user,
                pass: pass
            }
        });
        var oThis = this;
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.util.JSON.decode(param.responseText);
            if (response.success) {
                userRoles = response.roles;
                if (!Ext.getCmp('vp')) {
                    var viewport = new HAP.Viewport();
                    viewport.show();
					Ext.getCmp('currentUser').setText(user);
                    configRequest();
                }
                oThis.destroy();
            }
						else {
							var wel = oThis.getEl();
							var pos = wel.getXY();
							wel.sequenceFx().shift({
                    duration:   0.1,
                    x:          pos[0] - 15
                }).shift({
                    duration:   0.1,
                    x:          pos[0] + 15
                }).shift({
                    duration:   0.1,
                    x:          pos[0] - 10
                }).shift({
                    duration:   0.1,
                    x:          pos[0] + 10
                }).shift({
                    duration:   0.1,
                    x:          pos[0] - 5
                }).shift({
                    duration:   0.1,
                    x:          pos[0] + 5
                }).shift({
                    duration:   0.1,
                    x:          pos[0]
                }); 
						}
        }, {
            scope: this
        });
    };
    this.username = new Ext.form.TextField({
        id: 'textfieldUsername',
        msgTarget: 'side',
        fieldLabel: 'User',
        name: 'f_email',
        width: 175,
        allowBlank: true,
        value: Ext.state.Manager.get('UserName', ''),
        invalidText: 'Username missing'
    });
    this.password = new Ext.form.TextField({
        id: 'textfieldPassword',
        msgTarget: 'side',
        fieldLabel: 'Password',
        allowBlank: false,
        name: 'f_pass',
        width: 175,
        inputType: 'password'
    });
    this.password.on('specialkey', function(A, B){
        if (B.getKey() == 13) {
            this.loginButtonHandler()
        }
    }, this);
    this.loginForm = new Ext.FormPanel({
        id: 'formLoginForm',
        labelWidth: 75,
        defaults: {
            width: 230
        },
        baseCls: 'x-plain',
        defaultType: 'textfield',
        labelAlign: 'left',
        bodyStyle: {
            padding: '10px'
        },
        border: false,
        items: [this.username, this.password]
    });
    Ext.QuickTips.init();
    HAP.LoginWindow.superclass.constructor.call(this, {
        id: 'windowLoginDialog',
        width: 400,
        autoHeight: true,
        modal: true,
        shadow: true,
        bodyBorder: false,
        plain: true,
        collapsible: false,
        resizable: false,
        closable: true,
        title: 'Login',
        iconCls: 'password',
        defaultButton: 'textfieldUsername', //autoFocus
        buttons: [{
            text: 'Login',
            handler: this.loginButtonHandler,
            scope: this
        }],
        items: [this.loginForm]
    });
}
Ext.extend(HAP.LoginWindow, Ext.Window, {});
