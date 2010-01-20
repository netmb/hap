
HAP.GUIViewPanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'GUI-View';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
    this.layout = 'absolute';
    this.width = 800;
    this.height = 620;
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
        xtype: 'fieldset',
        title: 'Base Settings',
        width: 370,
        autoHeight: true,
        x: 5,
        y: 5,
        labelWidth: 90,
        items: [new HAP.TextName(attrib.id), new Ext.form.Checkbox({
            fieldLabel: 'Is Default',
            boxLabel: ' ',
            name: 'isDefault',
            inputValue: 1
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
            deleteButtonClicked(tmp.target, tmp)
        }
    }]
    
    HAP.GUIViewPanel.superclass.constructor.call(this);
    
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

Ext.extend(HAP.GUIViewPanel, Ext.FormPanel, {});
