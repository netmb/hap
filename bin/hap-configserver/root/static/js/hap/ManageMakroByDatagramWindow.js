HAP.ManageMakroByDatagramWindow = function(item) {

	storeMessageTypes.load();
	storeMakroByDatagram.load();

	var sm = new Ext.grid.CheckboxSelectionModel({
		singleSelect : false
	});

	var checkActive = new Ext.grid.CheckColumn({
		header : 'Active',
		dataIndex : 'active',
		inputValue : 1,
		width : 75
	});

	var newMakroByDatagram = Ext.data.Record.create([{
		name : 'active'
	}, {
		name : 'description'
	}, {
		name : 'vlan'
	}, {
		name : 'source'
	}, {
		name : 'destination'
	}, {
		name : 'mtype'
	}, {
		name : 'address'
	}, {
		name : 'v0'
	}, {
		name : 'v1'
	}, {
		name : 'v2'
	}, {
		name : 'makro'
	}]);

	var cm = new Ext.grid.ColumnModel([sm, checkActive, {
		id : 'manageMakroByDatagramDescription',
		header : 'Description',
		dataIndex : 'description',
		sortable : true,
		width : 150,
		editor : new Ext.form.TextField({
			allowBlank : true
		})
	}, {
		id : 'manageMakroByDatagramVlan',
		header : 'VLAN',
		dataIndex : 'vlan',
		sortable : true,
		width: 70,
		editor : new Ext.form.TextField({
			allowBlank : true
		})
	}, {
		id : 'manageMakroByDatagramSource',
		header : 'Source',
		dataIndex : 'source',
		sortable : true,
		width : 200,
		editor : new HAP.ComboModule({}),
		renderer : function(data) {
			record = storeModules.getById(data);
			if (record) {
				return record.data.name;
			} else {
				return data;
			}
		}
	}, {
		id : 'manageMakroByDatagramDestination',
		header : 'Destination',
		dataIndex : 'destination',
		sortable : true,
		width : 200,
		editor : new HAP.ComboModule('', {
			instance : 2
		}),
		renderer : function(data) {
			record = storeModules.getById(data);
			if (record) {
				return record.data.name;
			} else {
				return data;
			}
		}
	}, {
		id : 'manageMakroByDatagramAddress',
		header : 'Address',
		dataIndex : 'address',
		width : 100,
		sortable : true,
		editor : new Ext.form.TextField({
			allowBlank : true
		})
	}, {
		id : 'manageMakroByDatagramMType',
		header : 'Messagetype',
		dataIndex : 'mtype',
		sortable : true,
		width : 200,
		editor : new HAP.ComboMessageType({}),
		renderer : function(data) {
			record = storeMessageTypes.getById(data);
			if (record) {
				return record.data.name;
			} else {
				return data;
			}
		}
	}, {
		id : 'manageMakroByDatagramV0',
		header : 'V0',
		dataIndex : 'v0',
		sortable : true,
		width : 60,
		editor : new Ext.form.TextField({
			allowBlank : true
		})
	}, {
		id : 'manageMakroByDatagramV1',
		header : 'V1',
		dataIndex : 'v1',
		sortable : true,
		width : 60,
		editor : new Ext.form.TextField({
			allowBlank : true
		})
	}, {
		id : 'manageMakroByDatagramV2',
		header : 'V2',
		dataIndex : 'v2',
		sortable : true,
		width : 60,
		editor : new Ext.form.TextField({
			allowBlank : true
		})
	}, {
		id : 'manageMakroByDatagramMakro',
		header : 'Makro',
		dataIndex : 'makro',
		sortable : true,
		width : 250,
		editor : new HAP.ComboMakros({}),
		renderer : function(data) {
			record = storeMacros.getById(data);
			if (record) {
				return record.data.name;
			} else {
				return data;
			}
		}
	}]);

	var grid = new Ext.grid.EditorGridPanel({
		ds : storeMakroByDatagram,
		cm : cm,
		//width: 700,
		//height: 200,
		autoWidth : true,
		autoHeight : true,
		autoExpandColumn : 'description',
		frame : false,
		sm : sm,
		plugins : [checkActive],
		clicksToEdit : 1,
		viewConfig : {
			forceFit : true
		},
		tbar : [{
			text : 'Save Changes',
			handler : saveChanges,
			iconCls : 'save'
		}, '-', {
			text : 'Add',
			handler : addMakroByDatagram,
			iconCls : 'add'
		}, '-', {
			text : 'Delete',
			handler : deleteMakroByDatagram,
			iconCls : 'delete'
		}]
	});

	function saveChanges() {
		var mr = storeMakroByDatagram.getModifiedRecords();
		if (mr.length > 0) {
			var data = new Array;
			for (var index in mr) {
				data.push(mr[index].data);
			}
			var conn = new Ext.data.Connection();
			conn.request({
				method : 'POST',
				url : '/managemakrobydatagram/submit',
				params : {
					data : Ext.util.JSON.encode(data)
				}
			});
			conn.on('requestcomplete', function(sender, param) {
				var response = Ext.util.JSON.decode(param.responseText);
				if (response.permissiondenied) {
					var loginWindow = new HAP.LoginWindow();
					loginWindow.show();
				} else {
					if (response.success) {
						storeMakroByDatagram.reload();
					} else {
						Ext.MessageBox.alert('Warning', response.info);
					}
				}
			}, {
				scope : this
			});
		}
	}

	function addMakroByDatagram() {
		grid.stopEditing();
		var c = new newMakroByDatagram({
			active : 1,
			description : '',
			vlan : '',
			source : '',
			destination : '',
			mtype : '',
			address : '',
			v0 : '',
			v1 : '',
			v2 : '',
			makro : '',
			id : 0
		});
		storeMakroByDatagram.insert(0, c);
		grid.getSelectionModel().selectRow(0);
		grid.startEditing(0, 1);
	}

	function deleteMakroByDatagram() {
		var sel = grid.getSelectionModel().getSelections();
		var data = new Array;
		for (var index in sel) {
			data.push(sel[index].data);
		}
		var conn = new Ext.data.Connection();
		conn.request({
			method : 'POST',
			url : '/managemakrobydatagram/delete',
			params : {
				data : Ext.util.JSON.encode(data)
			}
		});
		conn.on('requestcomplete', function(sender, param) {
			var response = Ext.util.JSON.decode(param.responseText);
			if (response.permissiondenied) {
				var loginWindow = new HAP.LoginWindow();
				loginWindow.show();
			} else {
				if (response.success) {
					storeMakroByDatagram.reload();
				} else {
					Ext.MessageBox.alert('Warning', response.info);
				}
			}
		}, {
			scope : this
		});
	}

	var win = new Ext.Window({
		title : 'Manage Makro by Datagram',
		closable : true,
		iconCls : 'scheduler',
		width : 800,
		autoHeight : true,
		autoScroll : true,
		items : [grid]
	});
	win.show(this);
};
