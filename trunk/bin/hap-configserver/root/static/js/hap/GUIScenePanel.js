/**
 * @author bendowski
 */
HAP.GUIScenePanel = function(attrib){
    var workflow;
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.labelWidth = 75;
    this.method = 'POST';
    this.frame = true;
    this.title = 'GUI-Scene';
    this.bodyStyle = 'padding:5px 5px 0';
    this.listeners = {
        resize: function(me){
            var wfPanel = Ext.getCmp(attrib.id + '/workflowSequenceScrollViewPort');
            if (wfPanel) {
                wfPanel.fireEvent('resize');
            };
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
        items: [new HAP.TextName(attrib.id), new HAP.ComboGuiViews(attrib.id), new Ext.form.Checkbox({
            fieldLabel: 'Is Default',
            boxLabel: ' ',
            name: 'isDefault',
            inputValue: 1
        }), new Ext.form.Checkbox({
            fieldLabel: 'Center X',
            boxLabel: ' ',
            name: 'centerX',
            inputValue: 1
        }), new Ext.form.Checkbox({
            fieldLabel: 'Center Y',
            boxLabel: ' ',
            name: 'centerY',
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
    var tmp = this;
    this.buttons = [{
        text: 'Save',
        iconCls: 'ok',
        handler: function(){
            var sequence = new Array()
            var fig = workflow.getDocument().getFigures();
            for (var i = 0; i < fig.getSize(); i++) {
                var figure = fig.get(i);
                sequence[i] = figure.guiObject.conf;
            }
            saveButtonClicked(oThis.target, oThis, {
                data: Ext.util.JSON.encode(sequence)
            });
        }
    }, {
        text: 'Delete',
        iconCls: 'delete',
        handler: function(){
            deleteButtonClicked(tmp.target, tmp);
        }
    }];
    
    HAP.GUIScenePanel.superclass.constructor.call(this);
    
    var oThis = this;
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room + '&viewId=' + attrib.viewId,
        method: 'GET',
        success: function(form, action){
            Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            Ext.getCmp(attrib.id + '/textName').focus();
            
            workflow = new draw2d.Workflow(attrib.id + '/workflowSequenceBody');
            workflow.getContextMenu = function(){
                var menu = new draw2d.Menu();
                var wf = this;
                var figure = this.getCurrentSelection();
                if (figure) {
                  menu.appendMenuItem(new draw2d.MenuItem('Copy', null, function(){
                    figure.guiObject.id = 0;
                    figure.guiObject.conf.id = 0;
                    cutNPaste = Ext.ux.clone(figure.guiObject.conf);
                  }));
                  menu.appendMenuItem(new draw2d.MenuItem('Delete', null, function(){
                    wf.removeFigure(figure);
                    
                  }));
                }
                menu.appendMenuItem(new draw2d.MenuItem('Paste', null, function(){
                    //var offX = Ext.getCmp(wf.scrollArea.id).body.dom.scrollLeft;
                    //var offY = Ext.getCmp(wf.scrollArea.id).body.dom.scrollTop;
                    var offX = wf.getScrollLeft();
                    var offY = wf.getScrollTop();
                    var fig = new HAP.GUIObject(cutNPaste);
                    //wf.addFigure(fig, wf.mouseDownPosX + offX, wf.mouseDownPosY + offY);
                    wf.addFigure(fig, wf.currentMouseX + offX, wf.currentMouseY + offY);
                }));
                menu.appendMenuItem(new draw2d.MenuItem('Toggle Grid', null, function(){
                    if (wf.snap) {
                        wf.snap = false;
                    }
                    else {
                        wf.snap = true;
                    }
                    wf.setSnapToGrid(wf.snap);
                }));
                return menu;
                
            };
            if (Ext.isIE) 
                workflow.setViewPort(document.getElementById(attrib.id + '/workflowSequenceBody').parentElement.id);
            else 
                workflow.setViewPort(document.getElementById(attrib.id + '/workflowSequenceBody').getParent().id);
            workflow.setBackgroundImage('/static/images/grid_10.png', true);
            workflow.setGridWidth(10, 10);
            workflow.snap = true; // custom !
            workflow.setSnapToGrid(workflow.snap);
            var listener = new HAP.GUIWorkflowSelector(workflow);
            workflow.addSelectionListener(listener);
            
            var droptarget = new Ext.dd.DropTarget(attrib.id + '/workflowSequenceBody', {
                ddGroup: 'TreeDD'
            });
            droptarget.notifyDrop = function(dd, e, data){
                if (data.type) {
                    var xOffset = workflow.getAbsoluteX();
                    var yOffset = workflow.getAbsoluteY();
                    //var offX = Ext.getCmp(workflow.scrollArea.id).body.dom.scrollLeft;
                    //var offY = Ext.getCmp(workflow.scrollArea.id).body.dom.scrollTop;
                    var offX = workflow.getScrollLeft();
                    var offY = workflow.getScrollTop();
                    var fig = new HAP.GUIObject(data);
                    workflow.addFigure(fig, Math.floor((e.xy[0] - xOffset + offX) / 10) * 10, Math.floor((e.xy[1] - yOffset + offY) / 10) * 10);
                    workflow.showResizeHandles(fig);
                    workflow.setCurrentSelection(fig);
                    return true;
                }
            }
            if (action.result.data.objects) {
                for (var i = 0; i < action.result.data.objects.length; i++) {
                    var obj = action.result.data.objects[i];
                    workflow.addFigure(new HAP.GUIObject(obj), obj.display.x, obj.display.y);
                }
            }
            Ext.getCmp('guiPropertyGrid').blank();
            Ext.getCmp('east-panel').expand(true);
        }
    });
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
        if (Ext.getCmp('guiObjectTree') == null) {
            var otp = Ext.getCmp('objectTreePanel');
            otp.removeAll();
            otp.add(new HAP.GUIObjectTree());
            otp.doLayout();
            var opp = Ext.getCmp('objectPropertyPanel');
            opp.removeAll();
            opp.add(new HAP.GUIPropertyGrid());
            opp.doLayout();
        }
    });
    this.on('destroy', function(){
        Ext.getCmp('guiPropertyGrid').blank();
    });
}

Ext.extend(HAP.GUIScenePanel, Ext.FormPanel, {});




