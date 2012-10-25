HAP.LCDGuiPanel = function(attrib){
    var workflow;
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'LCD-GUI';
    this.bodyStyle = 'padding:5px 5px 0';
    this.listeners = {
        resize: function(me){
            var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
            if (wfPanel) {
                wfPanel.fireEvent('resize');
            }
        }
    };
    this.keys = [{
        key: Ext.EventObject.ENTER,
        fn: function(el, key, normEvtCode){
            //saveButtonClicked(this.target, this);
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
        collapsible: true,
        width: 370,
        x: 5,
        y: 5,
        autoHeight: true,
        labelWidth: 90,
        items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), new HAP.ComboAddress(attrib.id), new HAP.ComboNotify(attrib.id), new Ext.form.NumberField({
            fieldLabel: 'Timeout (s)',
            name: 'timeout',
            maxValue: 255,
            allowNegative: false,
            width: 60
        }), new Ext.form.Checkbox({
            fieldLabel: 'Is Default',
            boxLabel: ' ',
            name: 'isDefault',
            inputValue: 1
        })],
        listeners: {
            collapse: function(panel){
                var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
                if (wfPanel) {
                    wfPanel.fireEvent('resize');
                }
            },
            expand: function(panel){
                var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
                if (wfPanel) {
                    wfPanel.fireEvent('resize');
                }
            }
        }
    }, {
        xtype: 'fieldset',
        title: 'Sequence Area',
        anchor: '100%', // IE7 needs it
        id: attrib.id + '/workflowSequenceScrollViewPort',
        bodyStyle: 'overflow: auto; background-color: #ffffff',
        listeners: {
            resize: function(me, adjWidth, adjHeight, rawWidth, rawHeight){
                var el = this.getEl();
                if (el) {
                    this.setHeight(Ext.get(attrib.id).getHeight() - el.getTop());
                }
            }
        },
        html: '<div id=' + attrib.id + '/workflowSequenceBody' + ' style=\'position:relative; width:1920px; height:1200px; background-color: #ffffff\'></div>'
    }];
    var oThis = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            var sequence = new Array()
            var fig = workflow.getDocument().getFigures();
            for (var i = 0; i < fig.getSize(); i++) {
                var figure = fig.get(i);
                figure.conf.x = figure.x;
                figure.conf.y = figure.y;
                figure.conf.width = figure.getWidth()
                figure.conf.height = figure.getHeight()
                figure.conf.uid = figure.getId();
                
                if (figure.conf.type == 1) { //Menu found.
                    var mItems = figure.getChildren();
                    var mItemsConf = new Array();
                    for (var j = 0; j < mItems.getSize(); j++) {
                        var child;
                        var tmp = mItems.get(j);
                        child = tmp.conf;
                        child.x = tmp.getX();
                        child.y = tmp.getY();
                        child.width = tmp.getWidth();
                        child.uid = tmp.getId();
                        var port = tmp.getPort('outPort1');
                        var conns = port.getConnections();
                        child.outPort1X = port.getX();
                        child.outPort1Y = port.getY();
                        for (var p = 0; p < conns.size; p++) {
                            child.outPort1 = conns.get(p).getTarget().getParent().getId();
                        }
                        mItemsConf[j] = child;
                    }
                    figure.conf.mItems = mItemsConf;
                }
                for (var j = 1; j <= figure.conf.inPorts; j++) {
                    var port = figure.getPort('inPort' + j);
                    var conns = port.getConnections();
                    for (var p = 0; p < conns.size; p++) {
                        if (j == 1) {
                            figure.conf.inPort1 = conns.get(p).getSource().getParent().getId();
                            figure.conf.inPort1X = port.getX();
                            figure.conf.inPort1Y = port.getY();
                        }
                        if (j == 2) {
                            figure.conf.inPort2 = conns.get(p).getSource().getParent().getId();
                            figure.conf.inPort2X = port.getX();
                            figure.conf.inPort2Y = port.getY();
                        }
                        if (j == 3) {
                            figure.conf.inPort3 = conns.get(p).getSource().getParent().getId();
                            figure.conf.inPort3X = port.getX();
                            figure.conf.inPort3Y = port.getY();
                        }
                    }
                }
                sequence[i] = figure.conf;
            }
            saveButtonClicked(oThis.target, oThis, {
                data: Ext.util.JSON.encode(sequence)
            });
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(oThis.target, oThis)
        }
    }];
    
    HAP.LCDGuiPanel.superclass.constructor.call(this);
    
    var oThis = this;
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        waitMsg: 'Loading...',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            
            workflow = new draw2d.Workflow(attrib.id + '/workflowSequenceBody');
            if (Ext.isIE) 
                workflow.setViewPort(document.getElementById(attrib.id + '/workflowSequenceBody').parentElement.id);
            else 
                workflow.setViewPort(document.getElementById(attrib.id + '/workflowSequenceBody').getParent().id);
            workflow.setBackgroundImage('/static/images/grid_10.png', true);
            workflow.setGridWidth(10, 10);
            workflow.setSnapToGrid(true);
            
            var listener = new HAP.LCDWorkflowSelector(workflow);
            workflow.addSelectionListener(listener);
            
            var droptarget = new Ext.dd.DropTarget(attrib.id + '/workflowSequenceBody', {
                ddGroup: 'TreeDD'
            });
            droptarget.notifyDrop = function(dd, e, data){
                if (data.className) {
                    var xOffset = workflow.getAbsoluteX();
                    var yOffset = workflow.getAbsoluteY();
                    //var offX = Ext.getCmp(workflow.scrollArea.id).body.dom.scrollLeft;
                    //var offY = Ext.getCmp(workflow.scrollArea.id).body.dom.scrollTop;
                    var offX = workflow.getScrollLeft();
                    var offY = workflow.getScrollTop();
                    if (data.className == 'HAP.LCDMenuItem') {
                        compFigure = workflow.getBestCompartmentFigure(e.xy[0] - xOffset + offX, e.xy[1] - yOffset + offY);
                        if (compFigure != null) {
                            var obj = classFactory(data.className, data.conf);
                            workflow.addFigure(obj, Math.floor((e.xy[0] - xOffset + offX) / 10) * 10, Math.floor((e.xy[1] - yOffset + offY) / 10) * 10);
                            compFigure.addChild(obj);
                            compFigure.onFigureDrop(obj);
                        }
                    }
                    else {
                        var fig = classFactory(data.className, data.conf);
                        workflow.addFigure(fig, Math.floor((e.xy[0] - xOffset + offX) / 10) * 10, Math.floor((e.xy[1] - yOffset + offY) / 10) * 10);
                        workflow.showResizeHandles(fig);
                        workflow.setCurrentSelection(fig);
                    }
                    return true;
                }
            }
            if (action.result.data.objects) {
                var map = new Object();
                for (var i = 0; i < action.result.data.objects.length; i++) {
                    var obj = action.result.data.objects[i];
                    if (obj.type == 1) {
                        map[obj.uid] = new HAP.LCDMenu(obj);
                        workflow.addFigure(map[obj.uid], obj.x, obj.y);
                        for (var z = 0; z < obj.mItems.length; z++) {
                            var mItem = new HAP.LCDMenuItem(obj.mItems[z]);
                            map[obj.mItems[z].uid] = mItem;
                            workflow.addFigure(map[obj.mItems[z].uid], obj.mItems[z].x, obj.mItems[z].y);
                            map[obj.uid].addChild(mItem);
                        }
                    }
                    else {
                        map[obj.uid] = new HAP.LCDObject(obj);
                        workflow.addFigure(map[obj.uid], obj.x, obj.y);
                    }
                }
                
                for (var i = 0; i < action.result.data.objects.length; i++) {
                    var obj = action.result.data.objects[i];
                    if (obj.inPort1 && map[obj.inPort1]) {
                        var con = new HAP.Connection();
                        con.setSource(map[obj.inPort1].getPort('outPort1'));
                        con.setTarget(map[obj.uid].getPort('inPort1'));
                        workflow.addFigure(con);
                    }
                    if (obj.inPort2 && map[obj.inPort2]) {
                        var con = new HAP.Connection();
                        con.setSource(map[obj.inPort2].getPort('outPort1'));
                        con.setTarget(map[obj.uid].getPort('inPort2'));
                        workflow.addFigure(con);
                    }
                    if (obj.inPort3 && map[obj.inPort3]) {
                        var con = new HAP.Connection();
                        con.setSource(map[obj.inPort3].getPort('outPort1'));
                        con.setTarget(map[obj.uid].getPort('inPort3'));
                        workflow.addFigure(con);
                    }
                }
            }
            Ext.getCmp('lcdPropertyGrid').blank();
            Ext.getCmp('east-panel').expand(true);
        }
    });
    
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        if (Ext.getCmp('lcdObjectTree') == null) {
            Ext.getCmp('objectTreePanel').removeAll();
            Ext.getCmp('objectTreePanel').add(new HAP.LCDObjectTree());
            Ext.getCmp('objectTreePanel').doLayout(); // needed here, not sure why
            Ext.getCmp('objectPropertyPanel').removeAll();
            Ext.getCmp('objectPropertyPanel').add(new HAP.LCDPropertyGrid());
            Ext.getCmp('objectPropertyPanel').doLayout(); // dito
        }
    });
    this.on('destroy', function(){
        Ext.getCmp('lcdPropertyGrid').blank();
    });
}

Ext.extend(HAP.LCDGuiPanel, Ext.FormPanel, {});

