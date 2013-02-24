var storeLog = new Ext.data.Store({
    autoLoad: true,
    url: '/log/getNewLogEntries/',
    reader: new Ext.data.JsonReader({
        totalProperty: 'total',
        root: 'log',
        id: 'id',
        lastID: 'lastID' // custom attribute
    }, [{
        name: 'pid',
        type: 'int'
    }, {
        name: 'time',
        type: 'date',
        dateFormat: 'Y-m-d H:i:s'
    }, {
        name: 'source',
        type: 'string'
    }, {
        name: 'type',
        type: 'string'
    }, {
        name: 'message',
        type: 'string'
    }])
});

storeLog.on('load', function(){
    storeLog.sort('time', 'DESC');
    var count = storeLog.getCount();
    if (count > 50) {
        var firstOut = storeLog.getRange(50, count);
        for (var i = 0; i < firstOut.length; i++) {
            storeLog.remove(firstOut[i]);
        }
    }
});

var storeRooms = new Ext.data.Store({
    url: '/json/getRooms',
    reader: new Ext.data.JsonReader({
        root: 'rooms'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeUpstreamInterfaces = new Ext.data.Store({
    url: '/json/getUpstreamInterfaces',
    reader: new Ext.data.JsonReader({
        root: 'upstreaminterfaces'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});


var storeModules = new Ext.data.Store({
    url: '/json/getModules',
    reader: new Ext.data.JsonReader({
        root: 'modules'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeModuleProps = new Ext.data.Store({
    url: '/managemodules/getModules',
    pruneModifiedRecords: true,
    reader: new Ext.data.JsonReader({
        root: 'modules',
        id: 'id'
    }, [{
        name: 'name',
        type: 'string',
        mapping: 'name'
    }, {
        name: 'id',
        mapping: 'id'
    }, {
        name: 'firmwareid',
        mapping: 'firmwareid'
    }, {
        name: 'devoption/1',
        mapping: 'devoption/1'
    }, {
        name: 'devoption/2',
        mapping: 'devoption/2'
    }, {
        name: 'devoption/4',
        mapping: 'devoption/4'
    }])
});

var storeNotifyModules = new Ext.data.Store({
    url: '/json/getNotifyModules',
    reader: new Ext.data.JsonReader({
        root: 'modules'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeUpstreamModules = new Ext.data.Store({
    url: '/json/getUpstreamModules',
    reader: new Ext.data.JsonReader({
        root: 'modules'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeFreeModuleAddresses = new Ext.data.Store({
    url: '/json/getFreeModuleAddresses/',
    reader: new Ext.data.JsonReader({
        root: 'addresses'
    }, [{
        name: 'address'
    }])
});

var storeAddresses = new Ext.data.Store({
    url: '/json/getAddresses/',
    reader: new Ext.data.JsonReader({
        root: 'addresses'
    }, [{
        name: 'name'
    }])
});

var storePortPins = new Ext.data.Store({
    url: '/json/getPortPins/',
    reader: new Ext.data.JsonReader({
        root: 'portpins'
    }, [{
        name: 'name'
    }])
});

var storeDeviceTypes = new Ext.data.Store({
    url: '/json/getDeviceTypes',
    reader: new Ext.data.JsonReader({
        root: 'devicetypes'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeHomematicDeviceTypes = new Ext.data.Store({
    url: '/json/getHomematicDeviceTypes',
    reader: new Ext.data.JsonReader({
        root: 'homematicdevicetypes'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeTimeBase = new Ext.data.Store({
    autoLoad: true,
    url: '/json/getTimeBase',
    reader: new Ext.data.JsonReader({
        root: 'timebase'
    }, [{
        name: 'value'
    }, {
        name: 'name'
    }])
});

var storeWeekdays = new Ext.data.Store({
    autoLoad: true,
    url: '/json/getWeekdays',
    reader: new Ext.data.JsonReader({
        root: 'days'
    }, [{
        name: 'value'
    }, {
        name: 'name'
    }])
});


var storeDigitalInputTypes = new Ext.data.Store({
    url: '/json/getDigitalInputTypes',
    reader: new Ext.data.JsonReader({
        root: 'devicetypes'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeDevices = new Ext.data.Store({
    url: '/json/getDevices',
    reader: new Ext.data.JsonReader({
        root: 'devices'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeShutterDevices = new Ext.data.Store({
    url: '/json/getShutterDevices',
    reader: new Ext.data.JsonReader({
        root: 'devices'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])

});

var storeAllDevices = new Ext.data.Store({
    url: '/json/getAllDevices',
    reader: new Ext.data.JsonReader({
        root: 'devices'
    }, [{
        name: 'name'
    }, {
        name: 'address'
    }, {
        name: 'module'
    }])
});

var storeAllTriggerDevices = new Ext.data.Store({
    url: '/json/getAllTriggerDevices',
    reader: new Ext.data.JsonReader({
        root: 'devices'
    }, [{
        name: 'name'
    }, {
        name: 'address'
    }, {
        name: 'module'
    }])
});

var storeLogicalInputs = new Ext.data.Store({
    url: '/json/getLogicalInputs',
    reader: new Ext.data.JsonReader({
        root: 'logicalinputs'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeLogicalInputs1 = new Ext.data.Store({
    url: '/json/getLogicalInputs',
    reader: new Ext.data.JsonReader({
        root: 'logicalinputs'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeAbstractDevices = new Ext.data.Store({
    url: '/json/getAbstractDevices',
    reader: new Ext.data.JsonReader({
        root: 'abstractdevices'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeLogicalInputTemplates = new Ext.data.Store({
    url: '/json/getLogicalInputTemplates',
    reader: new Ext.data.JsonReader({
        root: 'templates',
        id: 'id'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }, {
        name: 'type'
    }])
});

var storeASInputValueTemplates = new Ext.data.Store({
    url: '/json/getASInputValueTemplates',
    reader: new Ext.data.JsonReader({
        root: 'templates',
        id: 'id'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }, {
        name: 'type'
    }])
});

var storeStartModes = new Ext.data.Store({
    url: '/json/getStartModes',
    reader: new Ext.data.JsonReader({
        root: 'startmodes'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeFirmware = new Ext.data.Store({
    url: '/managefirmware/getFirmware',
    pruneModifiedRecords: true,
    reader: new Ext.data.JsonReader({
        root: 'firmware',
        id: 'id' // wichtig, sonst passt das mapping nicht (combobox in grid)
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }, {
        name: 'date'
    }, {
        name: 'version'
    }, {
        name: 'precompiled'
    }, {
        name: 'compileoptions'
    }, {
        name: 'filename'
    }])
});

var storeMacros = new Ext.data.Store({
    url: '/json/getMacros',
    reader: new Ext.data.JsonReader({
        root: 'macros'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeIRDestinations = new Ext.data.SimpleStore({
    fields: ['id', 'name'],
    data: [['standardOutputs', 'Device'], ['shutter', 'Shutter'], ['makro', 'Makro']]
});

var storeConfig = new Ext.data.Store({
    url: '/manageconfigs/getConfigs',
    pruneModifiedRecords: true,
    reader: new Ext.data.JsonReader({
        root: 'results',
        id: 'id'
    }, [{
        name: 'name',
        type: 'string',
        mapping: 'name'
    }, {
        name: 'id',
        mapping: 'id'
    }, {
        name: 'isdefault',
        mapping: 'isdefault'
    }])
});

var storeSchedulerCommands = new Ext.data.Store({
    url: '/json/getSchedulerCommands',
    reader: new Ext.data.JsonReader({
        root: 'scheduler',
        id: 'id'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeSchedules = new Ext.data.Store({
    url: '/managescheduler/getSchedules',
    pruneModifiedRecords: true, //get modifiedRecords in grid persists on store-load()
    reader: new Ext.data.JsonReader({
        root: 'schedules',
        id: 'id'
    }, [{
        name: 'cron',
        type: 'string',
        mapping: 'cron'
    }, {
        name: 'id',
        mapping: 'id'
    }, {
        name: 'cmd',
        mapping: 'cmd'
    }, {
        name: 'args',
        mapping: 'args'
    }, {
        name: 'description',
        mapping: 'description'
    }, {
        name: 'status',
        mapping: 'status'
    }])
});

var storeGuiViews = new Ext.data.Store({
    url: '/json/getGuiViews',
    reader: new Ext.data.JsonReader({
        root: 'views'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeGuiScenes = new Ext.data.Store({
    url: '/json/getGuiScenes',
    reader: new Ext.data.JsonReader({
        root: 'scenes'
    }, [{
        name: 'id'
    }, {
        name: 'name'
    }])
});

var storeUsers = new Ext.data.Store({
    url: '/users/get',
    reader: new Ext.data.JsonReader({
        root: 'users',
        id: 'id'
    }, [{
        name: 'id'
    }, {
        name: 'username'
    }, {
        name: 'password'
    }, {
        name: 'prename'
    }, {
        name: 'surname'
    }, {
        name: 'email'
    }, {
        name: 'password1'
    }, {
        name: 'password2'
    }])
});

var storeUserRoles = new Ext.data.Store({
    url: '/users/getUserRoles',
    reader: new Ext.data.JsonReader({
        root: 'userRoles',
        id: 'id'
    }, [{
        name: 'id'
    }, {
        name: 'role'
    }, {
        name: 'status'
    }])
});


var loadStores = function(){
    storeModules.load();
    storeNotifyModules.load();
    storeUpstreamModules.load();
    storeAddresses.load();
    storePortPins.load();
    storeDeviceTypes.load();
    storeHomematicDeviceTypes.load();
    storeUpstreamInterfaces.load();
    storeRooms.load();
    storeFirmware.load();
    storeStartModes.load();
    storeLogicalInputTemplates.load();
    storeDigitalInputTypes.load();
    storeMacros.load();
    storeSchedulerCommands.load();
    storeGuiViews.load();
    storeGuiScenes.load();
    storeASInputValueTemplates.load();
}
