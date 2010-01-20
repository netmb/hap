HAP.ACPopupWindow = function(simValue, callback){
    this.id = 'acPopUpWindow';
    this.modal = true;
    this.title = 'AC-Object';
    this.layout = 'fit';
    this.width = '360';
    this.autoHeight = true;
    this.plain = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            Ext.getCmp('btnOkACPopupWindow').handler.call();
        },
        scope: this
    }];
    this.items = [{
        id: 'formACPopUpWindow',
        xtype: 'form',
        frame: true,
        autoHeight: true,
        items: [{
            xtype: 'fieldset',
            title: 'Simulator Parameter',
            collapsible: false,
            autoHeight: true,
            defaultType: 'numberfield',
            items: [new HAP.ComboASInputValueTemplates(), {
                xtype: 'numberfield',
                id: 'simValue',
                tabIndex: 1,
                minValue: 0,
                maxValue: 255,
                allowNegative: false,
                allowBlank: false,
                allowDecimals: false,
                maxLength: 3,
                width: '30',
                fieldLabel: 'Simulator-Value',
                name: 'simValue',
                hiddenName: 'simValue',
                value: simValue,
                selectOnFocus: true,
                listeners: {
                    'show': function(){
                        this.focus();
                    }
                }
            }]
        }]
    }];
    var oThis = this;
    this.buttons = [{
        text: 'OK',
        id: 'btnOkACPopupWindow',
        iconCls: 'ok',
        scope: this,
        handler: function(){
            var field = Ext.getCmp('simValue');
            if (field.isValid()) {
                callback(field.getValue());
                oThis.destroy();
            }
        }
    }, {
        text: 'Cancel',
        iconCls: 'cancel',
        handler: function(){
            oThis.destroy();
        }
    }];
    HAP.ACPopupWindow.superclass.constructor.call(this);
};

Ext.extend(HAP.ACPopupWindow, Ext.Window, {
    'afterShow': function(){
        HAP.ACPopupWindow.superclass.afterShow.call(this);
        this.setZIndex(10001);
				Ext.getCmp('simValue').focus(false, 50);
    }
});
