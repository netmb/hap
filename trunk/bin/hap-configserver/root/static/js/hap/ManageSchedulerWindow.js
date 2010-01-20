HAP.ManageSchedulerWindow = function(item){

    storeSchedules.load();
    
    var sm = new Ext.grid.CheckboxSelectionModel({
        singleSelect: false
    });
    
    var newSchedule = Ext.data.Record.create([{
        name: 'cron',
        type: 'string'
    }, {
        name: 'cmd'
    }, {
        name: 'args'
    },{
        name: 'description'
    }, {
        name: 'status'
    }]);
    
    var cm = new Ext.grid.ColumnModel([sm, {
        id: 'manageSchedulerCron',
        header: 'Cron',
        dataIndex: 'cron',
        sortable: true,
        editor: new Ext.form.TextField({
            allowBlank: false
        })
    }, {
        id: 'manageSchedulerCmd',
        header: 'Command',
        dataIndex: 'cmd',
        sortable: true,
        editor: new HAP.ComboSchedulerCommands({})
    }, {
        id: 'manageSchedulerArgs',
        header: 'Arguments',
        dataIndex: 'args',
        sortable: true,
        width: 200,
        editor: new Ext.form.TextField({
            allowBlank: true
        })
    },{
        id: 'manageSchedulerDescription',
        header: 'Description',
        dataIndex: 'description',
        width: 100,
        sortable: true,
        editor: new Ext.form.TextField({
            allowBlank: true
        })
    }, {
        id: 'manageSchedulerStatus',
        header: 'Status',
        dataIndex: 'status',
        width: 60,
        sortable: true
    }]);
    
    var grid = new Ext.grid.EditorGridPanel({
        ds: storeSchedules,
        cm: cm,
        width: 700,
        autoWidth: true,
        autoHeight: true,
        autoExpandColumn: 'cron',
        frame: false,
        sm: sm,
        clicksToEdit: 1,
        viewConfig: {
            forceFit: true
        },
        tbar: [{
            text: 'Save Changes',
            handler: saveChanges,
            iconCls: 'save'
        }, '-', {
            text: 'Add',
            handler: addSchedule,
            iconCls: 'add'
        }, '-', {
            text: 'Delete',
            handler: deleteSchedule,
            iconCls: 'delete'
        }, '-', {
            id: 'schedulerLiveMonitorButton',
            enableToggle: true,
            text: 'Start Live Monitoring',
            iconCls: 'start',
            toggleHandler: toggleMonitoring
        
        }]
    });
    
    function saveChanges(){
        var mr = storeSchedules.getModifiedRecords();
        if (mr.length > 0) {
            var data = new Array;
            for (var index in mr) {
                data.push(mr[index].data);
            }
            var conn = new Ext.data.Connection();
            conn.request({
                method: 'POST',
                url: '/managescheduler/setSchedules',
                params: {
                    data: Ext.util.JSON.encode(data)
                }
            });
            conn.on('requestcomplete', function(sender, param){
                var response = Ext.util.JSON.decode(param.responseText);
                if (response.permissiondenied) {
                  var loginWindow = new HAP.LoginWindow();
                  loginWindow.show();
                }
                else {
                  if (response.success) {
                    storeSchedules.reload();
                  }
                  else {
                    Ext.MessageBox.alert('Warning', response.info);
                  }
                }
            }, {
                scope: this
            });
        }
    }
    
    function addSchedule(){
        grid.stopEditing();
        var c = new newSchedule({
            cron: '',
            cmd: '',
            args: '',
			description: '',
            id: 0
        });
        storeSchedules.insert(0, c);
        grid.getSelectionModel().selectRow(0);
        grid.startEditing(0, 1);
    }
    
    function deleteSchedule(){
        var sel = grid.getSelectionModel().getSelections();
        var data = new Array;
        for (var index in sel) {
            data.push(sel[index].data);
        }
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'POST',
            url: '/managescheduler/delSchedules',
            params: {
                data: Ext.util.JSON.encode(data)
            }
        });
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.util.JSON.decode(param.responseText);
            if (response.permissiondenied) {
              var loginWindow = new HAP.LoginWindow();
              loginWindow.show();
            }
            else {
              if (response.success) {
                storeSchedules.reload();
              }
              else {
                Ext.MessageBox.alert('Warning', response.info);
              }
            }
        }, {
            scope: this
        });
    }
    
    function stopSpeedLog(){
        Ext.getCmp('schedulerLiveMonitorButton').toggle(false);
        Ext.getCmp('logLiveMonitorButton').toggle(false);
        win.hide();
        win.destroy();
    }
    
    function toggleMonitoring(button, state){
        if (state) {
            Ext.TaskMgr.start(taskSpeedSchedulerUpdate);
            button.setText('Stop Live Monitoring');
            button.setIconClass('stop');
            Ext.getCmp('logLiveMonitorButton').toggle(true);
        }
        else {
            Ext.TaskMgr.stop(taskSpeedSchedulerUpdate);
            button.setText('Start Live Monitoring');
            button.setIconClass('start');
            Ext.getCmp('logLiveMonitorButton').toggle(false);
            storeSchedules.reload({
                params: {}
            });
        }
    }
    
    var win = new Ext.Window({
        title: 'Manage Scheduler',
        closable: true,
        iconCls: 'scheduler',
        width: 715,
        autoHeight: true,
        autoScroll: true,
        close: stopSpeedLog,
        items: [grid]
    });
    win.show(this);
};
