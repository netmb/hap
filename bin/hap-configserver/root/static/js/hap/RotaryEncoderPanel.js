HAP.RotaryEncoderPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Rotary Encoder';
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
            height: 170,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), new HAP.ComboAddress(attrib.id), new HAP.ComboNotify(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            autoHeight: false,
            labelWidth: 90,
            defaults: {
                width: 230
            },
            width: 370,
            x: 5,
            y: 185,
            height: 165,
            items: [new HAP.ComboLogicalInputs(attrib.id, {
                label: 'A',
                name: 'childdevice0',
                instance: 1,
                rotaryEncoder: true
            }), new HAP.ComboLogicalInputs(attrib.id, {
                label: 'B',
                name: 'childdevice1',
                instance: 2,
                rotaryEncoder: true
            }), new HAP.ComboLogicalInputs(attrib.id, {
                label: 'P1',
                name: 'childdevice2',
                instance: 3,
                rotaryEncoderPushButton: true
            }), new HAP.ComboAbstractDevices(attrib.id, {
                label: 'Associated GUI',
                name: 'childdevice3',
                instance: 1,
                gui: true
            }), {
                xtype: 'numberfield',
                fieldLabel: 'Speed 1/100s',
                name: 'attrib2',
                allowBlank: false,
                minValue: 1,
                maxValue: 255,
                value: 100,
                width: 64
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
    
    HAP.RotaryEncoderPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            loadAddressAndPortPin(action.result.data.module, action.result.data.address, '');
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        Ext.getCmp(attrib.id + '/comboAddress').fireEvent('select'); // check for duplicate address
        loadAddressAndPortPin(Ext.getCmp(attrib.id + '/comboModule').getValue(), Ext.getCmp(attrib.id + '/comboAddress').getValue(), '');
    });
}

Ext.extend(HAP.RotaryEncoderPanel, Ext.FormPanel, {});
