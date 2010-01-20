HAP.RemoteControlLearnedPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'RC Learned';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            saveButtonClicked(this.target, this);
        },
        scope: this
    }, {
        key: 'x',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              deleteButtonClicked(this.target, this);
            }
        },
        scope: this
    }, {
        key: 's',
        fn: function(el, key, normEvtCode){
            if (key.ctrlKey) {
              saveButtonClicked(this.target, this);
            }
        },
        scope: this
    }];
    this.items = [{
        layout: 'absolute',
        width: 800,
        height: 600,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            height: 110,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            height: 157,
            width: 370,
            x: 5,
            y: 125,
            labelWidth: 90,
            defaults: {
                width: 230
            },
            items: [{
                xtype: 'textfield',
                fieldLabel: 'Address',
                name: 'address',
                readOnly: true,
                width: 64
            }, {
                xtype: 'textfield',
                fieldLabel: 'Code',
                name: 'code',
                readOnly: true,
                width: 64
            }, {
                xtype: 'textfield',
                fieldLabel: 'Action',
                name: 'action',
                readOnly: true,
                width: 64
            }]
        }, {
            xtype: 'fieldset',
            title: 'Keypad',
            layout: 'absolute',
            height: 277,
            width: 145,
            x: 385,
            y: 5,
            labelWidth: 90,
            defaults: {
                width: 230
            },
            items: [new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-1',
                label: '1',
                x: 5,
                y: 5
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-2',
                label: '2',
                x: 47,
                y: 5
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-3',
                label: '3',
                x: 89,
                y: 5
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-4',
                label: '4',
                x: 5,
                y: 47
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-5',
                label: '5',
                x: 47,
                y: 47
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-6',
                label: '6',
                x: 89,
                y: 47
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-7',
                label: '7',
                x: 5,
                y: 89
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-8',
                label: '8',
                x: 47,
                y: 89
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-9',
                label: '9',
                x: 89,
                y: 89
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'button-0',
                label: '0',
                x: 47,
                y: 131
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'minus',
                label: '-',
                x: 5,
                y: 131
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'plus',
                label: '+',
                x: 89,
                y: 131
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'makro',
                label: 'Macro',
                x: 5,
                y: 173,
                minWidth: 50
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'enter',
                label: 'Enter',
                x: 70,
                y: 173,
                minWidth: 50
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'all-on',
                label: 'AllOn',
                x: 5,
                y: 215,
                minWidth: 50
            
            }), new HAP.ButtonKeyPad(attrib.id, {
                key: 'all-off',
                label: 'AllOff',
                x: 70,
                y: 215,
                minWidth: 50
            })]
        }]
    }];
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            saveButtonClicked(tmp.target, tmp)
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }];
    
    HAP.RemoteControlLearnedPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
    });
    
}

Ext.extend(HAP.RemoteControlLearnedPanel, Ext.FormPanel, {});
