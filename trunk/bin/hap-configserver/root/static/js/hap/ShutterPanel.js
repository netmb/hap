HAP.ShutterPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Shutter';
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
            height: 165,
            width: 370,
            x: 5,
            y: 5,
            labelWidth: 90,
            items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), new HAP.ComboAddress(attrib.id), new HAP.ComboNotify(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Device Specification',
            autoHeight: false,
            labelWidth: 100,
            defaults: {
                width: 220
            },
            width: 370,
            x: 5,
            y: 180,
            height: 135,
            items: [new HAP.ComboDevices(attrib.id, {
                label: 'Up-Device',
                name: 'childdevice0',
                instance: 1,
                shutter: true
            }), new HAP.ComboDevices(attrib.id, {
                label: 'Down-Device',
                name: 'childdevice1',
                instance: 2,
                shutter: true
            }), {
                xtype: 'numberfield',
                fieldLabel: 'Stroke Time (sec)',
                name: 'attrib0',
                allowBlank: false,
                minValue: 1,
                maxValue: 255,
                width: 64
            }, {
                xtype: 'checkbox',
                fieldLabel: '',
                boxLabel: 'Impuls mode',
                name: 'attrib1',
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
    
    HAP.ShutterPanel.superclass.constructor.call(this);
    
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

Ext.extend(HAP.ShutterPanel, Ext.FormPanel, {});
