HAP.DigitalInputPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Digital Input';
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
            height: 240,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), new HAP.ComboAddress(attrib.id), new HAP.ComboPortPin(attrib.id), new HAP.ComboNotify(attrib.id), new HAP.TextFormulaDescription(attrib.id), new HAP.TextFormula(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            autoHeight: false,
            labelWidth: 120,
            defaults: {
                width: 200
            },
            width: 370,
            x: 385,
            y: 5,
            height: 240,
            items: [new HAP.ComboDigitalInputType(attrib.id), {
                xtype: 'numberfield',
                fieldLabel: 'Sample Rate 1/10s',
                name: 'samplerate',
                allowBlank: false,
                minValue: 1,
                maxValue: 255,
                width: 64
            }]
        }, {
            xtype: 'fieldset',
            title: 'Trigger 0',
            autoHeight: true,
            y: 255,
            x: 5,
            width: 370,
            labelWidth: 90,
            items: [{
                xtype: 'numberfield',
                fieldLabel: 'Trigger-Level',
                width: 64,
                decimalPrecision: 4,
                value: 0,
                name: 'trigger0'
            }, {
                xtype: 'numberfield',
                fieldLabel: 'Hysteresis',
                decimalPrecision: 4,
                allowNegative: false,
                width: 64,
                value: 0,
                name: 'trigger0hyst'
            }, {
                xtype: 'checkbox',
                fieldLabel: ' ',
                boxLabel: 'Notify if value over trigger-level',
                name: 'trigger0notify/8',
                inputValue: 1,
                labelSeparator: ' '
            }, {
                xtype: 'checkbox',
                fieldLabel: ' ',
                boxLabel: 'Notify if under trigger-level',
                name: 'trigger0notify/4',
                inputValue: 1,
                labelSeparator: ' '
            }]
        }, {
            xtype: 'fieldset',
            title: 'Trigger 1',
            autoHeight: true,
            x: 385,
            y: 255,
            width: 370,
            items: [{
                xtype: 'numberfield',
                fieldLabel: 'Tigger-Level',
                decimalPrecision: 4,
                width: 64,
                value: 0,
                name: 'trigger1'
            }, {
                xtype: 'numberfield',
                fieldLabel: 'Hysteresis',
                decimalPrecision: 4,
                allowNegative: false,
                width: 64,
                value: 0,
                name: 'trigger1hyst'
            }, {
                xtype: 'checkbox',
                fieldLabel: '',
                boxLabel: 'Notify if value over trigger-level',
                name: 'trigger1notify/8',
                inputValue: 1,
                labelSeparator: ' '
            }, {
                xtype: 'checkbox',
                fieldLabel: '',
                boxLabel: 'Notify if under trigger-level',
                name: 'trigger1notify/4',
                inputValue: 1,
                labelSeparator: ' '
            }]
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
    
    HAP.DigitalInputPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            loadAddressAndPortPin(action.result.data.module, action.result.data.address, action.result.data.portPin);
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        Ext.getCmp(attrib.id + '/comboAddress').fireEvent('select'); // check for duplicate address
        Ext.getCmp(attrib.id + '/comboPortPin').fireEvent('select'); // check for duplicate address
        loadAddressAndPortPin(Ext.getCmp(attrib.id + '/comboModule').getValue(), Ext.getCmp(attrib.id + '/comboAddress').getValue(), Ext.getCmp(attrib.id + '/comboPortPin').getValue());
        
    });
}

Ext.extend(HAP.DigitalInputPanel, Ext.FormPanel, {});
