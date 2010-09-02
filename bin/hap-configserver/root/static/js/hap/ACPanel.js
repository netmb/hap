HAP.ACPanel = function(attrib){
    var workflow;
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'AC';
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
        width: 380,
        x: 5,
        y: 5,
        autoHeight: true,
        labelWidth: 100,
        items: [new HAP.TextName(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModule(attrib.id), {
            xtype: 'checkbox',
            fieldLabel: 'Direct Simulation',
            id: attrib.id + '/checkDirectSimulation',
            checked: true
        }],
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
    var tmp = this;
    this.buttons = [{
        text: 'Simulate',
        iconCls: 'simulate',
        id: attrib.id + '/btnSimulate',
        handler: simulate
    }, {
        text: 'Sim-Reset',
        iconCls: 'simulate',
        id: attrib.id + '/btnSimulateReset',
        handler: simulateReset
    }, {
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            var sequence = getNodesAndConnection();
            saveButtonClicked(tmp.target, tmp, {
                data: Ext.util.JSON.encode(sequence)
            });
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp)
        }
    }];
    
    function getNodesAndConnection(){
        var sequence = new Array();
        var fig = workflow.getDocument().getFigures();
        for (var i = 0; i < fig.getSize(); i++) {
            var figure = fig.get(i);
            figure.conf.x = figure.x;
            figure.conf.y = figure.y;
            figure.conf.uid = figure.getId();
            for (var j = 1; j <= figure.conf.outPorts; j++) { // this is only for missing outport-connection check
                var port = figure.getPort('outPort' + j);
                var conns = port.getConnections();
                if (conns.size == 0) {
                    Ext.MessageBox.show({
                        title: 'Warning',
                        msg: 'Detected port with no connection. Object:' + figure.conf.name,
                        buttons: Ext.Msg.OK
                    });
                    return;
                }
            }
            for (var j = 1; j <= figure.conf.inPorts; j++) {
                var port = figure.getPort('inPort' + j);
                var conns = port.getConnections();
                if (conns.size > 1) {
                    Ext.MessageBox.show({
                        title: 'Warning',
                        msg: 'Detected more than on connection. Object:' + figure.conf.name,
                        buttons: Ext.Msg.OK
                    });
                    return;
                }
                if (conns.size == 0) {
                    Ext.MessageBox.show({
                        title: 'Warning',
                        msg: 'Detected port with no connection. Object:' + figure.conf.name,
                        buttons: Ext.Msg.OK
                    });
                    return;
                }
                for (var p = 0; p < conns.size; p++) {
                    if (j == 1) {
                        figure.conf.inPort1 = conns.get(p).getSource().getParent().getId();
                        figure.conf.inPort1Style = conns.get(p).getRouter().type;
                    }
                    if (j == 2) {
                        figure.conf.inPort2 = conns.get(p).getSource().getParent().getId();
                        figure.conf.inPort2Style = conns.get(p).getRouter().type;
                    }
                    if (j == 3) {
                        figure.conf.inPort3 = conns.get(p).getSource().getParent().getId();
                        figure.conf.inPort2Style = conns.get(p).getRouter().type;
                    }
                }
            }
            sequence[i] = figure.conf;
        }
        return sequence;
    }
    
    function simulate(){
        var sequence = getNodesAndConnection();
        var currSelect = workflow.getCurrentSelection();
        var cId = null;
        if (currSelect) {
            cId = currSelect.id;
        }
        tmp.form.submit({
            url: '/autonomouscontrol/simulate',
            params: {
                data: Ext.util.JSON.encode(sequence),
                currSelection: cId
            },
            success: function(fp, action){
                var fig = workflow.getDocument().getFigures();
                for (var i = 0; i < fig.getSize(); i++) {
                    var figure = fig.get(i);
                    for (var z = 0; z < action.result.data.length; z++) {
                        if (figure.getId() == action.result.data[z].uid) {
                            figure.setSimValue(action.result.data[z]['calcVar'], action.result.data[z]['simValue'], action.result.data[z]['simText']);
                        }
                    }
                }
            }
        });
    }
    
    function simulateReset(){
        var sequence = getNodesAndConnection();
        var currSelect = workflow.getCurrentSelection();
        var cId = null;
        if (currSelect) {
            cId = currSelect.id;
        }
        tmp.form.submit({
            url: '/autonomouscontrol/simulatereset',
            params: {
                data: Ext.util.JSON.encode(sequence),
                currSelection: cId
            },
            success: function(fp, action){
                var fig = workflow.getDocument().getFigures();
                for (var i = 0; i < fig.getSize(); i++) {
                    var figure = fig.get(i);
                    for (var z = 0; z < action.result.data.length; z++) {
                        if (figure.getId() == action.result.data[z].uid) {
                            figure.setSimValue(action.result.data[z]['calcVar'], action.result.data[z]['simValue'], action.result.data[z]['simText']);
                        }
                    }
                }
            }
        });
    }
    
    HAP.ACPanel.superclass.constructor.call(this);
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
            //var bla = document.getElementById(attrib.id + '/workflowSequenceBody').getParent().id;
						//alert (bla);
						//workflow.setViewPort(attrib.id + '/workflowSequenceScrollViewPort');
						workflow.setViewPort(document.getElementById(attrib.id + '/workflowSequenceBody').getParent().id);
            workflow.setBackgroundImage('/static/images/grid_10.png', true);
            workflow.setGridWidth(10, 10);
            workflow.setSnapToGrid(true);
            var listener = new HAP.ACWorkflowSelector(workflow);
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
										var fig = classFactory(data.className, data.conf);
                    workflow.addFigure(fig, Math.floor((e.xy[0] - xOffset + offX) / 10) * 10, Math.floor((e.xy[1] - yOffset + offY) / 10) * 10);
                    workflow.showResizeHandles(fig);
                    workflow.setCurrentSelection(fig);
                    return true;
                }
            }
            if (action.result.data.objects) {
                var map = new Object();
                for (var i = 0; i < action.result.data.objects.length; i++) {
                    var obj = action.result.data.objects[i];
                    if (obj.type == 256) {
                        map[obj.uid] = new HAP.ACObjectAnnotate(obj);
                    }
                    else {
                        map[obj.uid] = new HAP.ACObject(obj);
                    }
                    workflow.addFigure(map[obj.uid], obj.x, obj.y);
                }
                for (var i = 0; i < action.result.data.objects.length; i++) {
                    var obj = action.result.data.objects[i];
                    if (obj.inPort1) {
                        var con = new HAP.Connection();
                        if (obj.inPort1Style == 'draw2d.NullConnectionRouter') {
                            con.setRouter(new draw2d.NullConnectionRouter());
                        }
                        else 
                            if (obj.inPort1Style == 'draw2d.ManhattanConnectionRouter') {
                                con.setRouter(new draw2d.ManhattanConnectionRouter());
                            }
                            else 
                                if (obj.inPort1Style == 'draw2d.BezierConnectionRouter') {
                                    con.setRouter(new draw2d.BezierConnectionRouter());
                                }
                        con.setSource(map[obj.inPort1].getPort('outPort1'));
                        con.setTarget(map[obj.uid].getPort('inPort1'));
                        workflow.addFigure(con);
                    }
                    if (obj.inPort2) {
                        var con = new HAP.Connection();
                        if (obj.inPort2Style == 'draw2d.NullConnectionRouter') {
                            con.setRouter(new draw2d.NullConnectionRouter());
                        }
                        else 
                            if (obj.inPort2Style == 'draw2d.ManhattanConnectionRouter') {
                                con.setRouter(new draw2d.ManhattanConnectionRouter());
                            }
                            else 
                                if (obj.inPort2Style == 'draw2d.BezierConnectionRouter') {
                                    con.setRouter(new draw2d.BezierConnectionRouter());
                                }
                        con.setSource(map[obj.inPort2].getPort('outPort1'));
                        con.setTarget(map[obj.uid].getPort('inPort2'));
                        workflow.addFigure(con);
                    }
                    if (obj.inPort3) {
                        var con = new HAP.Connection();
                        if (obj.inPort3Style == 'draw2d.NullConnectionRouter') {
                            con.setRouter(new draw2d.NullConnectionRouter());
                        }
                        else 
                            if (obj.inPort3Style == 'draw2d.ManhattanConnectionRouter') {
                                con.setRouter(new draw2d.ManhattanConnectionRouter());
                            }
                            else 
                                if (obj.inPort3Style == 'draw2d.BezierConnectionRouter') {
                                    con.setRouter(new draw2d.BezierConnectionRouter());
                                }
                        con.setSource(map[obj.inPort3].getPort('outPort1'));
                        con.setTarget(map[obj.uid].getPort('inPort3'));
                        workflow.addFigure(con);
                    }
                }
            }
            Ext.getCmp('acPropertyGrid').blank();
            Ext.getCmp('east-panel').expand(true);
        }
    });
    
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        if (Ext.getCmp('acObjectTree') == null) {
            var tmp = Ext.getCmp('objectTreePanel');
            tmp.removeAll();
            tmp.add(new HAP.ACObjectTree());
            tmp.doLayout();
            
            tmp = Ext.getCmp('objectPropertyPanel');
            tmp.removeAll();
            tmp.add(new HAP.ACPropertyGrid());
            tmp.doLayout();
        }
    });
    this.on('destroy', function(){
        Ext.getCmp('acPropertyGrid').blank();
    });
}

Ext.extend(HAP.ACPanel, Ext.FormPanel, {});

