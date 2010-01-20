HAP.LogicalInputPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Logical Input';
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
            x: 5,
            y: 255,
            width: 370,
            height: 270,
            labelWidth: 90,
            items: [new HAP.ComboLogicalInputTemplates(attrib.id), {
                xtype: 'checkbox',
                fieldLabel: 'Detection',
                boxLabel: 'Rising Edge Detection',
                name: 'type/1',
                inputValue: 1,
                labelSeparator: ' '
            }, {
                xtype: 'checkbox',
                fieldLabel: '',
				itemCls: 'x-check-group',
                boxLabel: 'Falling Edge Detection',
                name: 'type/2',
                inputValue: 1,
                labelSeparator: ' '
            }, {
                xtype: 'radiogroup',
				name: 'type/x',
                fieldLabel: 'Options',
				labelSeparator: ' ',
                itemCls: 'x-check-group-alt',
                columns: 1,
                items: [{
                    boxLabel: 'None',
                    name: 'type/x',
                    inputValue: 0
                }, {
                    boxLabel: 'Disable Debounce',
                    name: 'type/x',
                    inputValue: 4
                }, {
                    boxLabel: 'Short Activation',
                    name: 'type/x',
                    inputValue: 8
                },
				{
                    boxLabel: 'Long Activation',
                    name: 'type/x',
                    inputValue: 12
                }]
            },            /*
             {
             xtype: 'checkbox',
             fieldLabel: '',
             boxLabel: 'Short Activation Delay',
             name: 'type/8',
             inputValue: 1,
             labelSeparator: ' '
             }, {
             xtype: 'checkbox',
             fieldLabel: '',
             boxLabel: 'Long Activation Delay',
             name: 'type/12',
             inputValue: 1,
             labelSeparator: ' '
             }, {
             xtype: 'checkbox',
             fieldLabel: '',
             boxLabel: 'Activate Pullup',
             name: 'type/16',
             inputValue: 1,
             labelSeparator: ' '
             },
             */
            {
                xtype: 'checkbox',
                fieldLabel: 'Options',
                boxLabel: 'Pullup',
                name: 'type/16',
                inputValue: 1,
                labelSeparator: ' '
            }, {
                xtype: 'checkbox',
                fieldLabel: '',
                boxLabel: 'Force Debounce',
                name: 'type/32',
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
    
    HAP.LogicalInputPanel.superclass.constructor.call(this);
    
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

Ext.extend(HAP.LogicalInputPanel, Ext.FormPanel, {});
