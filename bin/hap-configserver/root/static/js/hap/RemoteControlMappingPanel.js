HAP.RemoteControlMappingPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Remote Control';
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
            id: attrib.id + '/fieldset',
            title: 'Device Specification',
            height: 130,
            width: 370,
            x: 5,
            y: 125,
            labelWidth: 90,
            defaults: {
                width: 230
            },
            items: [{
                xtype: 'numberfield',
                id: attrib.id + '/irkey',
                fieldLabel: 'Key',
                name: 'irkey',
                minValue: 10,
                maxValue: 99,
                width: 64
            }, new HAP.ComboIRDestinations(attrib.id), new HAP.ComboDevices(attrib.id, {
                label: 'Device-Target',
                name: 'destdevice',
                standardOutputs: true
            }), new HAP.ComboMakros(attrib.id, {
                name: 'destmakronr'
            }), new HAP.ComboAbstractDevices(attrib.id, {
                label: 'Shutter',
                shutter: true,
                name: 'destvirtmodule'
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
    
    HAP.RemoteControlMappingPanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            if (action.result.data.destdevice != 0) {
              Ext.getCmp(attrib.id + '/comboIRDestinations').setValue('standardOutputs');
            }
            if (action.result.data.destvirtmodule != 0) {
              Ext.getCmp(attrib.id + '/comboIRDestinations').setValue('shutter');
            }
            if (action.result.data.destmakronr != 0) {
              Ext.getCmp(attrib.id + '/comboIRDestinations').setValue('makro');
            }
            Ext.getCmp(attrib.id + '/comboIRDestinations').fireEvent('select');
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
    });
}

Ext.extend(HAP.RemoteControlMappingPanel, Ext.FormPanel, {});
