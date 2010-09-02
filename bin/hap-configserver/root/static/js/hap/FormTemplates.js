HAP.TextName = function(url){
    this.id = url + '/textName';
    this.fieldLabel = 'Name';
    this.name = 'name';
    this.width = 230;
    this.allowBlank = false;
    this.tabIndex = 0;
    HAP.TextName.superclass.constructor.call(this);
}

Ext.extend(HAP.TextName, Ext.form.TextField, {});

HAP.TextModuleUID = function(url){
    this.id = url + '/uid';
    this.fieldLabel = 'UID';
    this.name = 'uid';
    this.width = 230;
    this.allowBlank = false;
    this.maskRe = /[ABCDEF\d]+/;
    this.regex = /^([ABCDEF\d]){6}$/;
    this.regexText = 'Only digits from 0-9 and characters from A-F allowed.\n A valid UID looks like: 00AF4C and is noted on every Control-Unit';
    this.invalidText = this.regexText;
    HAP.TextModuleUID.superclass.constructor.call(this);
}

Ext.extend(HAP.TextModuleUID, Ext.form.TextField, {});

HAP.TextFormulaDescription = function(url){
    this.fieldLabel = 'Formula Descr.';
    this.name = 'formuladescription';
    this.id = url + '/textFormulaDescription';
    this.width = 230;
    this.allowBlank = true;
    HAP.TextFormulaDescription.superclass.constructor.call(this);
}

Ext.extend(HAP.TextFormulaDescription, Ext.form.TextField, {});

HAP.TextFormula = function(url){
    this.fieldLabel = 'Formula';
    this.name = 'formula';
    this.id = url + '/textFormula';
    this.width = 230;
    this.allowBlank = true;
    HAP.TextFormula.superclass.constructor.call(this);
}

Ext.extend(HAP.TextFormula, Ext.form.TextField, {});

HAP.ComboRoom = function(url){
    this.id = url + '/comboRoom';
    this.store = storeRooms;
    this.fieldLabel = 'Room';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'room';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a room...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboRoom.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboRoom, Ext.form.ComboBox, {});


HAP.ComboUpstreamInterface = function(url){
    this.id = url + '/comboUpstreamInterface';
    this.store = storeUpstreamInterfaces;
    this.fieldLabel = 'Upstream Interf.';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'upstreaminterface';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select an interface...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboUpstreamInterface.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboUpstreamInterface, Ext.form.ComboBox, {});


HAP.ComboModule = function(url, confObj){
    this.id = url + '/comboModule';
    if (confObj && confObj.instance) {
        this.id = url + '/comboModule/' + confObj.instance;
    }
    this.store = storeModules;
    this.fieldLabel = 'Module';
    if (confObj && confObj.fieldLabel) {
        this.fieldLabel = confObj.fieldLabel;
    }
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'module';
    if (confObj && confObj.name) {
        this.name = confObj.name;
        this.hiddenName = confObj.name;
    }
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a module...';
    this.forceSelection = true;
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    if (confObj && confObj.allowBlank) {
        this.allowBlank = true;
    }
    HAP.ComboModule.superclass.constructor.call(this);
    
    this.on('select', function(){
        changeAddressAndPortPin(url, this.value)
    });
}

Ext.extend(HAP.ComboModule, Ext.form.ComboBox, {});

HAP.ComboAddress = function(url){
    this.id = url + '/comboAddress';
    this.store = storeAddresses;
    this.fieldLabel = 'Address';
    this.valueField = 'name';
    this.forceSelection = true;
    this.displayField = 'name';
    this.hiddenName = 'address';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select an address...';
    this.selectOnFocus = true;
    this.width = 60;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboAddress.superclass.constructor.call(this);
    
    this.on('select', function(){
        var comboModule = Ext.getCmp(url + '/comboModule');
        if (comboModule.getValue() != '' && this.getValue != '') {
            var conn = new Ext.data.Connection();
            conn.request({
                method: 'GET',
                url: '/json/checkAddress/' + comboModule.getValue() + '/' + this.getValue() + '/' + this.id.split('/')[1]
            });
            var oThis = this;
            conn.on('requestcomplete', function(sender, param){
                var response = Ext.util.JSON.decode(param.responseText);
                if (!response.success) {
                    oThis.reset();
                }
            }, {
                scope: this
            });
        }
    });
}

Ext.extend(HAP.ComboAddress, Ext.form.ComboBox, {});

HAP.ComboPortPin = function(url){
    this.id = url + '/comboPortPin';
    this.store = storePortPins;
    this.fieldLabel = 'Port-Pin';
    this.forceSelection = true;
    this.valueField = 'name';
    this.displayField = 'name';
    this.hiddenName = 'portPin';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select an port-pin...';
    this.selectOnFocus = true;
    this.width = 60;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboPortPin.superclass.constructor.call(this);
    
    this.on('select', function(){
        var comboModule = Ext.getCmp(url + '/comboModule');
        if (comboModule.getValue() != '' && this.getValue != '') {
            var conn = new Ext.data.Connection();
            conn.request({
                method: 'GET',
                url: '/json/checkPortPin/' + comboModule.getValue() + '/' + this.getValue() + '/' + this.id.split('/')[1]
            });
            var oThis = this;
            conn.on('requestcomplete', function(sender, param){
                var response = Ext.util.JSON.decode(param.responseText);
                if (!response.success) {
                    oThis.reset();
                }
            }, {
                scope: this
            });
        }
    });
}

Ext.extend(HAP.ComboPortPin, Ext.form.ComboBox, {});

HAP.ComboDeviceType = function(url){
    this.id = url + '/comboDeviceType';
    this.store = storeDeviceTypes;
    this.fieldLabel = 'Type';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'type';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a type...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboDeviceType.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboDeviceType, Ext.form.ComboBox, {});

HAP.ComboDigitalInputType = function(url){
    this.id = url + '/comboDigitalInputType';
    this.store = storeDigitalInputTypes;
    this.fieldLabel = 'Type';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'type';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a type...';
    this.selectOnFocus = true;
    this.width = 200;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboDigitalInputType.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboDigitalInputType, Ext.form.ComboBox, {});

HAP.ComboIRDestinations = function(url){
    this.id = url + '/comboIRDestinations';
    this.store = storeIRDestinations;
    this.fieldLabel = 'Type';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'type';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a type...';
    this.selectOnFocus = true;
    this.width = 64;
    this.editable = false;
    this.allowBlank = false;
    
    HAP.ComboIRDestinations.superclass.constructor.call(this);
    var oThis = this;
    this.on('select', function(){
        Ext.getCmp(url).doLayout();
        oThis.hideField(Ext.getCmp(url + '/comboDevices'));
        oThis.hideField(Ext.getCmp(url + '/comboAbstractDevices'));
        oThis.hideField(Ext.getCmp(url + '/comboMakros'));
        switch (this.value) {
            case 'makro':
                oThis.showField(Ext.getCmp(url + '/comboMakros'), {
                    allowBlank: false
                });
                Ext.getCmp(url + '/irkey').minValue = 0;
                Ext.getCmp(url + '/irkey').maxValue = 9;
                break;
            case 'standardOutputs':
                oThis.showField(Ext.getCmp(url + '/comboDevices'), {
                    allowBlank: false
                });
                Ext.getCmp(url + '/irkey').minValue = 10;
                Ext.getCmp(url + '/irkey').maxValue = 99;
                break;
            case 'shutter':
                oThis.showField(Ext.getCmp(url + '/comboAbstractDevices'), {
                    allowBlank: false
                });
                Ext.getCmp(url + '/irkey').minValue = 10;
                Ext.getCmp(url + '/irkey').maxValue = 99;
                break;
        }
        Ext.getCmp(url).doLayout();
    });
}

Ext.extend(HAP.ComboIRDestinations, Ext.form.ComboBox, {
    hideField: function(field){
        field.allowBlank = true;
        field.hide();
        field.getEl().up('.x-form-item').setDisplayed(false);
    },
    showField: function(field, confObj){
        if (confObj) {
            field.allowBlank = confObj.allowBlank;
        }
        field.show();
        field.getEl().up('.x-form-item').setDisplayed(true);
    }
});

HAP.ComboMakros = function(url, confObj){
    this.id = url + '/comboMakros';
    this.store = storeMacros;
    this.fieldLabel = 'Makro';
    this.valueField = 'id';
    this.displayField = 'name';
    this.name = 'makro';
    this.hiddenName = 'makro';
    if (confObj && confObj.name) {
        this.name = confObj.name;
        this.hiddenName = confObj.name;
    }
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a makro...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    HAP.ComboMakros.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboMakros, Ext.form.ComboBox, {});

HAP.ComboDevices = function(url, confObj){
    this.id = url + '/comboDevices';
    if (confObj && confObj.instance) {
        this.id = url + '/comboDevices/' + confObj.instance;
    }
    if (confObj && confObj.shutter) {
        this.store = storeShutterDevices;
        storeShutterDevices.load();
    }
    else {
        this.store = storeDevices;
        storeDevices.load();
    }
    //    storeDevices.proxy = new Ext.data.HttpProxy({
    //        url: '/json/getDevices/standardOutputs'
    //    });
    //    storeDevices.load();
    
    this.fieldLabel = 'Type';
    if (confObj && confObj.label) {
        this.fieldLabel = confObj.label;
    }
    if (confObj && confObj.name) {
        this.name = confObj.name;
        this.hiddenName = confObj.name;
    }
    this.valueField = 'id';
    this.displayField = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a device...';
    this.selectOnFocus = true;
    this.width = 200;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboDevices.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboDevices, Ext.form.ComboBox, {});

HAP.ComboLogicalInputs = function(url, confObj){
    this.id = url + '/comboLogicalInputs';
    if (confObj && confObj.instance) {
        this.id = url + '/comboLogicalInputs/' + confObj.instance;
    }
    if (confObj && confObj.rotaryEncoder) {
        this.store = storeLogicalInputs;
        storeLogicalInputs.proxy = new Ext.data.HttpProxy({
            url: '/json/getLogicalInputs/151'
        });
        storeLogicalInputs.load();
    }
    else {
        if (confObj && confObj.pushButton) {
            this.store = storeLogicalInputs1;
            storeLogicalInputs1.proxy = new Ext.data.HttpProxy({
                url: '/json/getLogicalInputs/186'
            });
            storeLogicalInputs1.load();
        }
        else 
            if (confObj && confObj.rotaryEncoderPushButton) {
                this.store = storeLogicalInputs1;
                storeLogicalInputs1.proxy = new Ext.data.HttpProxy({
                    url: '/json/getLogicalInputs/158'
                });
                storeLogicalInputs1.load();
            }
    }
    this.fieldLabel = 'Type';
    if (confObj && confObj.label) {
        this.fieldLabel = confObj.label;
    }
    if (confObj && confObj.name) {
        this.name = confObj.name;
        this.hiddenName = confObj.name;
    }
    this.valueField = 'id';
    this.displayField = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a device...';
    this.selectOnFocus = true;
    this.width = 200;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboLogicalInputs.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboLogicalInputs, Ext.form.ComboBox, {});

HAP.ComboAbstractDevices = function(url, confObj){
    this.id = url + '/comboAbstractDevices';
    if (confObj && confObj.instance) {
        this.id = url + '/comboAbstractDevices/' + confObj.instance;
    }
    this.store = storeAbstractDevices;
    if (confObj && confObj.gui) {
        storeAbstractDevices.proxy = new Ext.data.HttpProxy({
            url: '/json/getAbstractDevices/96/240'
        });
        storeAbstractDevices.load();
    }
    if (confObj && confObj.shutter) {
        storeAbstractDevices.proxy = new Ext.data.HttpProxy({
            url: '/json/getAbstractDevices/192/0'
        });
        storeAbstractDevices.load();
    }
    this.fieldLabel = 'Type';
    if (confObj && confObj.label) {
        this.fieldLabel = confObj.label;
    }
    if (confObj && confObj.name) {
        this.name = confObj.name;
        this.hiddenName = confObj.name;
    }
    this.valueField = 'id';
    this.displayField = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a device...';
    this.selectOnFocus = true;
    this.width = 200;
    this.editable = false;
    HAP.ComboAbstractDevices.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboAbstractDevices, Ext.form.ComboBox, {});

HAP.ComboLogicalInputTemplates = function(url){
    this.id = url + '/comboLogicalInputTemplates';
    this.store = storeLogicalInputTemplates;
    this.fieldLabel = 'Template';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'type';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a template...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = true;
    HAP.ComboLogicalInputTemplates.superclass.constructor.call(this);
    
    this.on('select', function(){
        Ext.getCmp(url).load({
            url: 'logicalinput/getCheckedCheckboxes/' + this.value,
            method: 'GET',
            success: function(form, action){
                // Ext.getCmp(url).setTitle(action.result.data.name)
            }
        });
    });
}
Ext.extend(HAP.ComboLogicalInputTemplates, Ext.form.ComboBox, {});

HAP.ComboNotify = function(url){
    this.id = url + 'comboNotify';
    this.store = storeNotifyModules;
    this.fieldLabel = 'Notify';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'notify';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a module...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    storeModules.clearFilter();
    HAP.ComboNotify.superclass.constructor.call(this);
    
}

Ext.extend(HAP.ComboNotify, Ext.form.ComboBox, {});

HAP.ComboUpstreamModules = function(url){
    this.id = url + 'comboUpstreamModule';
    this.store = storeUpstreamModules;
    this.fieldLabel = 'Upstream Module';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'upstreammodule';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a module...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    storeModules.clearFilter();
    HAP.ComboUpstreamModules.superclass.constructor.call(this);
    
}

Ext.extend(HAP.ComboUpstreamModules, Ext.form.ComboBox, {});

HAP.ComboModuleAddress = function(url){
    this.id = url + '/comboModuleAddress';
    this.store = storeFreeModuleAddresses;
    this.fieldLabel = 'Module Address';
    this.valueField = 'address';
    this.displayField = 'address';
    this.hiddenName = 'address';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select an address...';
    this.forceSelection = true;
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboModuleAddress.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboModuleAddress, Ext.form.ComboBox, {});

HAP.ComboStartMode = function(url){
    this.id = url + '/comboStartMode';
    this.store = storeStartModes;
    this.fieldLabel = 'Startmode';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'startmode';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select an startmode...';
    this.forceSelection = true;
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboStartMode.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboStartMode, Ext.form.ComboBox, {});

HAP.ComboFirmware = function(url){
    this.id = url + '/comboFirmware';
    this.tabIndex = 99;
    this.store = storeFirmware;
    this.fieldLabel = 'Firmware';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'firmwareid';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a firmware...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboFirmware.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboFirmware, Ext.form.ComboBox, {});

HAP.ComboSchedulerCommands = function(url){
    this.id = url + '/comboSchedulerCommands';
    this.store = storeSchedulerCommands;
    this.fieldLabel = 'Scheduler Commands';
    this.valueField = 'name';
    this.displayField = 'name';
    this.hiddenName = 'name';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a command...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboFirmware.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboSchedulerCommands, Ext.form.ComboBox, {});

HAP.ComboGuiViews = function(url){
    this.id = url + '/comboGuiViews';
    this.store = storeGuiViews;
    this.fieldLabel = 'View';
    this.valueField = 'id';
    this.displayField = 'name';
    this.hiddenName = 'viewId';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a view...';
    this.selectOnFocus = true;
    this.width = 230;
    this.editable = false;
    this.allowBlank = false;
    HAP.ComboGuiViews.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboGuiViews, Ext.form.ComboBox, {});

HAP.ButtonKeyPad = function(url, confObj){
    this.id = url + '/' + confObj.key;
    this.style = {
        left: confObj.x,
        top: confObj.y
    };
//    this.x = confObj.x;
//    this.y = confObj.y;
    this.minWidth = 30;
    if (confObj && confObj.minWidth) {
        this.minWidth = confObj.minWidth;
    }
    this.text = confObj.label;
    this.handler = function(){
        comboModule = Ext.getCmp(url + '/comboModule');
        if (comboModule.value) {
            Ext.getCmp(url).load({
                url: url.split('/')[0] + '/learn/' + confObj.key,
                method: 'POST',
                params: {
                    rcId: url.split('/')[1],
                    module: Ext.getCmp(url + '/comboModule').value,
                    room: Ext.getCmp(url + '/comboRoom').value
                },
                waitMsg: 'Press the desired Key on your Remote-Control now!',
                success: function(form, action){
                    if (action.result.data.keyName != null) { //keyName is set, if called from Remote-Control-Panel and not from the learned-Key-Panel
                        Ext.getCmp('treeDevice').addIRCode(url, 'remotecontrollearned', action.result.data.keyName, action.result.data.id);
                        Ext.getCmp('treeModule').addIRCode(url, 'remotecontrollearned', action.result.data.keyName, action.result.data.id);
                        Ext.getCmp('treeRoom').addIRCode(url, 'remotecontrollearned', action.result.data.keyName, action.result.data.id);
                    }
                },
                failure: function(form, action){
                    Ext.MessageBox.show({
                        title: 'Warning',
                        msg: action.result.info,
                        buttons: Ext.Msg.OK,
                        icon: Ext.MessageBox.INFO
                    });
                    
                }
            });
        }
        else {
            Ext.MessageBox.show({
                title: 'Warning',
                msg: 'No module selected!',
                buttons: Ext.Msg.OK,
                icon: Ext.MessageBox.INFO
            });
        }
    };
    HAP.ButtonKeyPad.superclass.constructor.call(this);
}

Ext.extend(HAP.ButtonKeyPad, Ext.Button, {});

HAP.ComboASInputValueTemplates = function(){
    this.store = storeASInputValueTemplates;
    this.fieldLabel = 'Template';
    this.valueField = 'type';
    this.displayField = 'name';
    this.hiddenName = 'type';
    this.typeAhead = true;
    this.mode = 'local';
    this.triggerAction = 'all';
    this.emptyText = 'Select a template...';
    this.selectOnFocus = true;
    this.width = 200;
    this.editable = false;
    this.allowBlank = true;
    this.listeners = {
        'select': function(){
					Ext.getCmp('simValue').setValue(this.getValue());
        }
    };
    HAP.ComboASInputValueTemplates.superclass.constructor.call(this);
}

Ext.extend(HAP.ComboASInputValueTemplates, Ext.form.ComboBox, {});


var changeAddressAndPortPin = function(url, module){
    if (Ext.getCmp(url + '/comboAddress')) {
        Ext.getCmp(url + '/comboAddress').reset();
        storeAddresses.proxy = new Ext.data.HttpProxy({
            url: '/json/getAddresses/' + module
        });
        storeAddresses.load();
    }
    if (Ext.getCmp(url + '/comboPortPin')) {
        Ext.getCmp(url + '/comboPortPin').reset();
        storePortPins.proxy = new Ext.data.HttpProxy({
            url: '/json/getPortPins/' + module
        });
        storePortPins.load();
    }
}

var loadAddressAndPortPin = function(module, currentAddress, currentPortPin){
    if (module != '' && currentAddress != '') {
        storeAddresses.proxy = new Ext.data.HttpProxy({
            url: '/json/getAddresses/' + module + '/' + currentAddress
        });
        storeAddresses.load();
    }
    if (module != '' && currentPortPin != '') {
        storePortPins.proxy = new Ext.data.HttpProxy({
            url: '/json/getPortPins/' + module + '/' + currentPortPin
        });
        storePortPins.load();
    }
}

var saveButtonClicked = function(url, formPanel, params){
    var target = url.split('/');
    formPanel.form.submit({
        url: target[0] + '/submit/' + target[1],
        params: params,
        success: function(fp, action){
            //log.addEntry('hapConfig', 'Info', 'Saved changes:' + url +
            //' - Server response: ' +
            //action.result.info);
            
            formPanel.target = target[0] + '/' + action.result.data.id;
            Ext.getCmp(url).setTitle(action.result.data.name);
            
            if (target[0] == 'macro' && target[1] == 0) {
                Ext.getCmp('treeMacro').addHapNode(url, null, action.result.data.name, action.result.data.id);
            }
            else 
                if (target[0] == 'macro' && target[1] != 0) {
                    Ext.getCmp('treeMacro').updateHapNode(url, action.result.data.name);
                }
                else 
                    if (target[1] == 0) {
                        Ext.getCmp('treeDevice').addHapNode(url, null, action.result.data.name, action.result.data.id);
                        Ext.getCmp('treeModule').addHapNode(url, null, action.result.data.name, action.result.data.id);
                        Ext.getCmp('treeRoom').addHapNode(url, null, action.result.data.name, action.result.data.id);
                        Ext.getCmp('treeGUI').addHapNode(url, null, action.result.data.name, action.result.data.id);
                    }
                    else {
                        Ext.getCmp('treeDevice').updateHapNode(url, action.result.data.name);
                        Ext.getCmp('treeModule').updateHapNode(url, action.result.data.name);
                        Ext.getCmp('treeRoom').updateHapNode(url, action.result.data.name);
                        Ext.getCmp('treeGUI').updateHapNode(url, action.result.data.name);
                    }
            // update stores
            switch (target[0]) {
                case 'module':
                    storeModules.load();
                    storeNotifyModules.load();
                    storeUpstreamModules.load();
                    break;
                case 'device':
                    storeDevices.load();
                    break;
                case 'logicalinput':
                    storeLogicalInputs.load();
                    storeLogicalInputs1.load();
                    break;
                case 'abstractdevice':
                    storeAbstractDevices.load();
                    break;
                case 'room':
                    storeRooms.load();
                    break;
                case 'guiview':
                    storeGuiViews.load();
                    break;
                case 'guiscene':
                    storeGuiScenes.load();
                    break;
                case 'macro':
                    storeMacros.load();
                    break;
            };
            if (target[0] == 'macro') {
                Ext.getCmp('center-panel-macro').remove(url);
                Ext.getCmp('center-panel-macro').doLayout();
            }
            else {
                Ext.getCmp('center-panel').remove(url);
                Ext.getCmp('center-panel').doLayout();
            }
        },
        failure: function(fp, action){
            if (action.result && action.result.sessionexpired) {
                Ext.MessageBox.show({
                    title: 'Warning',
                    msg: 'Session expired ! Please Reload this Page (F5)',
                    buttons: Ext.Msg.OK
                });
            }
            else 
                if (action.result && action.result.permissiondenied) {
                    var loginWindow = new HAP.LoginWindow();
                    loginWindow.show();
                }
                else {
                    var msg = 'Data processing failed.';
                    if (action.result) {
                        msg = 'Data processing failed.<br>Response:' + action.result.data;
                    }
                    Ext.MessageBox.show({
                        title: 'Warning',
                        msg: msg,
                        buttons: Ext.Msg.OK
                    });
                }
        }
    });
}

var deleteButtonClicked = function(url, formPanel){
    var target = url.split('/');
    if (target[0] == 'macro' && target[1] == 0) {
        Ext.getCmp('center-panel-macro').remove(url);
        Ext.getCmp('center-panel-macro').doLayout();
        return;
    }
    if (target[1] == 0) {
        Ext.getCmp('center-panel').remove(url);
        Ext.getCmp('center-panel').doLayout();
        return;
    }
    HAP.deleteObject(url);
}

HAP.deleteObject = function(url){
    var target = url.split('/');
    if (target[1] == 0) {
        return;
    }
    Ext.MessageBox.show({
        title: 'Warning',
        msg: 'Are you sure that you want to delete this item?',
        buttons: Ext.Msg.YESNO,
        icon: Ext.MessageBox.QUESTION,
        fn: function(btn, txt){
            if (btn == 'yes') {
                Ext.Ajax.request({
                    url: target[0] + '/delete/' + target[1],
                    params: {
                        id: target[1]
                    },
                    callback: function(options, success, response){
                        var r = Ext.decode(response.responseText);
                        if (r.success) {
                            switch (target[0]) {
                                case 'module':
                                    storeModules.load();
                                    storeNotifyModules.load();
                                    storeUpstreamModules.load();
                                    break;
                                case 'device':
                                    storeDevices.load();
                                    break;
                                case 'logicalinput':
                                    storeLogicalInputs.load();
                                    storeLogicalInputs1.load();
                                    break;
                                case 'abstractdevice':
                                    storeAbstractDevices.load();
                                    break;
                                case 'room':
                                    storeRooms.load();
                                    break;
                                case 'guiview':
                                    storeGuiViews.load();
                                    break;
                                case 'guiscene':
                                    storeGuiViews.load();
                                    break;
                                case 'macro':
                                    storeMacros.load();
                                    break;
                            };
                            if (target[0] == 'macro') {
                                Ext.getCmp('treeMacro').removeHapNode(url);
                                Ext.getCmp('center-panel-macro').remove(url);
                                Ext.getCmp('center-panel-macro').doLayout();
                            }
                            else {
                                Ext.getCmp('treeDevice').removeHapNode(url);
                                Ext.getCmp('treeModule').removeHapNode(url);
                                Ext.getCmp('treeRoom').removeHapNode(url);
                                Ext.getCmp('treeGUI').removeHapNode(url);
                                Ext.getCmp('center-panel').remove(url);
                                Ext.getCmp('center-panel').doLayout();
                            }
                        }
                        else {
                            if (r.sessionexpired) {
                                Ext.MessageBox.show({
                                    title: 'Warning',
                                    msg: 'Session expired ! Please Reload this Page (F5)',
                                    buttons: Ext.Msg.OK
                                });
                            }
                            else 
                                if (r.permissiondenied) {
                                    var loginWindow = new HAP.LoginWindow();
                                    loginWindow.show();
                                }
                                else {
                                    Ext.MessageBox.show({
                                        title: 'Warning',
                                        msg: 'Database-Action failed:' + r.info,
                                        buttons: Ext.Msg.OK
                                    });
                                }
                        }
                    }
                });
                
            }
        }
    });
}
