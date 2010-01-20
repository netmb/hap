HAP.MacroPanel = function(attrib){
    this.target = attrib.id;
    //this.layout = 'fit';
    this.id = attrib.id;
    this.closable = true;
    this.height = 470;
    this.title = 'Macro-Editor';
    this.method = 'POST';
    this.frame = true;
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.listeners = {
        resize: function(me){
            var fieldset = Ext.getCmp('fieldsetScript');
            if (fieldset) {
                fieldset.fireEvent('resize');
            }
        }
    };
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            //     saveButtonClicked(this.target, this);
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
        xtype: 'fieldset',
        title: 'Base Settings',
        autoHeight: true,
        width: 370,
        x: 5,
        y: 5,
        id: 'bla',
        labelWidth: 90,
        items: [new HAP.TextName(attrib.id), new Ext.form.NumberField({
            fieldLabel: 'Macro-Number',
            id: attrib.id + '/textMacroNumber',
            width: 230,
            allowBlank: false,
            name: 'macronr',
            minValue: 0,
            maxValue: 65535
        })]
    }, {
        xtype: 'fieldset',
        title: 'Script Editor',
        id: 'fieldsetScript',
        layout: 'anchor',
        //height: 310,
        autoWidth: true,
        x: 5,
        y: 100,
        listeners: {
            resize: function(me, adjWidth, adjHeight, rawWidth, rawHeight){
                var el = this.getEl();
                
                if (el) {
                    this.setHeight(Ext.get(attrib.id).getHeight() - 160 );
                }
            }
        },
        items: [new Ext.form.TextArea({
            width: '100%',
            height: '100%',
            name: 'script',
            id: attrib.id + '/textMacroScript',
            hideLabel: true
        })]
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
            deleteButtonClicked(tmp.target, tmp);
        }
    }];
    
    HAP.DevicePanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        //params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name)
            Ext.getCmp(attrib.id + '/textName').focus();
        }
    });
    
    var oThis = this;
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        oThis.doLayout();
    });
}

Ext.extend(HAP.MacroPanel, Ext.FormPanel, {});

