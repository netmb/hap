Ext.BLANK_IMAGE_URL = '/../static/js/ext/resources/images/default/s.gif'; // Ext 2.0

HAP.WinRole = function(){
    this.id = 'winRole';
    this.modal = true;
    this.title = 'Rolle bearbeiten';
    this.layout = 'fit';
    this.width = '500';
    this.autoHeight = true;
    this.plain = true;
    this.items = [{
        id: 'formRole',
        xtype: 'form',
        frame: true,
        autoHeight: true,
        items: [{
            xtype: 'textfield',
            fieldLabel: 'Rolle',
            name: 'role',
            hiddenName: 'role',
            anchor: '100%'
        }]
    }];
    this.buttons = [{
        text: 'OK',
        iconCls: 'ok',
        scope: this,
        handler: function(){
            saveButtonHandler('formRole', 'winRole');
        }
    }, {
        text: 'Abbrechen',
        iconCls: 'cancel',
        handler: function(){
            cancelButtonHandler('winRole');
        }
    }];
		HAP.WinRole.superclass.constructor.call(this);
    Ext.getCmp('formRole').on('render', function(){
        this.record = Ext.getCmp('gridRoles').getSelectionModel().getSelected();
        Ext.getCmp('formRole').getForm().loadRecord(this.record);
    });
};

Ext.extend(HAP.WinRole, Ext.Window, {});
