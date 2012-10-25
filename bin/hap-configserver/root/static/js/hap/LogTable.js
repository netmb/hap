var newEntry = Ext.data.Record.create([{
    name: 'time',
    type: 'date'
}, {
    name: 'source',
    type: 'string'
}, {
    name: 'type',
    type: 'string'
}, {
    name: 'message',
    type: 'string'
}]);

var logAutoUpdater = function(filter){
    if (storeLog.reader.jsonData) {
        storeLog.proxy.conn.url = '/log/getNewLogEntries/1/' +
        storeLog.reader.jsonData.lastID;
        storeLog.proxy.conn.method = 'GET', storeLog.reload({
            add: true
        });
        storeLog.proxy.conn.url = '/log/getNewLogEntries/0/' +
        storeLog.reader.jsonData.lastID;
        var pBar = Ext.getCmp('logPagingToolbar');
        pBar.getPageData().activePage;
    }
}

HAP.LogTable = function(){
    var sm = new Ext.grid.CheckboxSelectionModel({});
    var cm = new Ext.grid.ColumnModel([sm, {
        id: 'logTableTime',
        header: 'Time',
        dataIndex: 'time',
        sortable: true,
        width: 40
    }, {
        id: 'logTableSource',
        header: 'Source',
        dataIndex: 'source',
        sortable: true,
        width: 30
    }, {
        id: 'logTableType',
        header: 'Type',
        dataIndex: 'type',
        sortable: true,
        width: 20
    }, {
        id: 'logTableMessage',
        header: 'Message',
        dataIndex: 'message',
        sortable: true,
        width: 400
    }]);
    
    this.id = 'logTable';
    this.ds = storeLog;
    this.cm = cm;
    this.sm = sm;
    this.region = 'south';
    this.viewConfig = {
        forceFit: true
    };
    
    this.tbar = new Ext.Toolbar([{
        id: 'logLiveMonitorButton',
        enableToggle: true,
        text: 'Start Live Monitoring',
        iconCls: 'start',
        toggleHandler: function(button, state){
            if (state) {
                Ext.TaskMgr.stop(taskLogUpdate);
                Ext.TaskMgr.start(taskSpeedLogUpdate);
                button.setText('Stop Live Monitoring');
                button.setIconClass('stop');
            }
            else {
                Ext.TaskMgr.stop(taskSpeedLogUpdate);
                Ext.TaskMgr.start(taskLogUpdate);
                button.setText('Start Live Monitoring');
                button.setIconClass('start');
            }
        }
    }, {
        text: 'Clear Log',
        iconCls: 'delete',
        handler: function(){
            var win = new Ext.Window({
                title: 'Clear Log',
                width: 200,
                height: 100,
                resizable: false,
                bodyBorder: false,
                border: false,
                buttonAlign: 'center',
                bodyStyle: 'padding:10px 10px 0',
                items: [new Ext.form.Checkbox({
                    id: 'checkClearAllLog',
                    inputValue: 1,
                    boxLabel: 'Clear all entries'
                })],
                buttons: [{
                    text: 'Ok',
                    iconCls: 'ok',
                    handler: function(){
                        var ids = new Array();
                        var i = 0;
                        var recs = sm.getSelections();
                        for (i in recs) {
                            ids[i] = recs[i].id;
                        }
                        var conn = new Ext.data.Connection();
                        conn.request({
                            method: 'POST',
                            url: '/log/clear',
                            params: {
                                all: Ext.getCmp('checkClearAllLog').getValue(),
                                data: Ext.util.JSON.encode(ids)
                            }
                        });
                        conn.on('requestcomplete', function(sender, response){
                            var r = Ext.decode(response.responseText);
                            if (r.permissiondenied) {
                                var loginWindow = new HAP.LoginWindow();
                                loginWindow.show();
                            }
                            else {
                                storeLog.load();
                            }
                        });
                        win.hide();
                        win.destroy();
                    }
                }, {
                    text: 'Cancel',
                    iconCls: 'cancel',
                    handler: function(){
                        win.hide();
                        win.destroy();
                    }
                }]
            
            });
            win.show();
        }
    }, {
        text: 'Download Log',
        iconCls: 'download',
        handler: function(){
            var win = new Ext.Window({
                title: 'Download Log',
                width: 200,
                height: 100,
                resizable: false,
                bodyBorder: false,
                border: false,
                buttonAlign: 'center',
                bodyStyle: 'padding:10px 10px 0',
                items: [new Ext.form.Checkbox({
                    id: 'downloadAllLog',
                    inputValue: 1,
                    boxLabel: 'Download complete log'
                })],
                buttons: [{
                    text: 'Ok',
                    iconCls: 'ok',
                    handler: function(){
                        var ids = new Array();
                        var recs = sm.getSelections();
                        for (var i in recs) {
                            ids[i] = recs[i].id;
                        }
                        //window.open('/log/getPDF?all=' + Ext.getCmp('downloadAllLog').getValue() + '&ids=' + ids);
                        window.open('/log/getLog?all=' + Ext.getCmp('downloadAllLog').getValue() + '&ids=' + ids);
                        win.hide();
                        win.destroy();
                    }
                }, {
                    text: 'Cancel',
                    iconCls: 'cancel',
                    handler: function(){
                        win.hide();
                        win.destroy();
                    }
                }]
            
            });
            win.show();
        }
    }]);
    
    this.bbar = new Ext.PagingToolbar({
        id: 'logPagingToolbar',
        pageSize: 50,
        store: storeLog,
        displayInfo: true,
        autoHeight: true,
        displayMsg: 'Displaying Record {0} - {1} of {2}',
        emptyMsg: 'No records to display'
    });
    
    HAP.LogTable.superclass.constructor.call(this);
    
    var pBar = Ext.getCmp('logPagingToolbar');
    pBar.getPageData().activePage;
    pBar.doLoad(pBar.cursor);
    
}

Ext.extend(HAP.LogTable, Ext.grid.EditorGridPanel, {
    addEntry: function(source, type, message){
        var c = new newEntry({
            time: (new Date()).dateFormat('Y-m-j G:i:s'),
            source: source,
            type: type,
            message: message
        })
        storeLog.insert(0, c);
    }
});
