HAP.ModulePanel = function(attrib){
    this.target = attrib.id;
    this.id = attrib.id;
    this.buttonAlign = 'center';
    this.closable = true;
    this.method = 'POST';
    this.frame = true;
    this.title = 'Module';
    this.bodyStyle = 'padding:5px 5px 0';
    this.autoScroll = true;
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
        layout: 'absolute',
        width: 800,
        height: 900,
        items: [{
            xtype: 'fieldset',
            title: 'Base Settings',
            defaults: {
                width: 224
            },
            width: 370,
            x: 5,
            y: 5,
            height: 275,
            items: [new HAP.TextName(attrib.id), new HAP.TextModuleUID(attrib.id), new HAP.ComboRoom(attrib.id), new HAP.ComboModuleAddress(attrib.id), new HAP.ComboModule(attrib.id, {
                fieldLabel: 'Server Address',
                name: 'ccuaddress',
                allowBlank: true
            }), new HAP.ComboStartMode(attrib.id), {
                id: attrib.id + '/bridgemode',
                xtype: 'checkbox',
                fieldLabel: 'Bridge-Mode',
                name: 'bridgemode',
                inputValue: 1,
                //labelSeparator: '',
                //width: 128,
                value: 0
            }, new HAP.ComboUpstreamModules(attrib.id), new HAP.ComboUpstreamInterface(attrib.id)]
        }, {
            xtype: 'fieldset',
            title: 'Wireless',
            autoHeight: true,
            y: 285,
            x: 5,
            width: 370,
            height: 135,
            items: [{
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 255,
                fieldLabel: 'WLAN-ID',
                name: 'vlan',
                allowBlank: false
            }, {
                xtype: 'textfield',
                fieldLabel: 'Key',
                maxLength: 8,
                regex: /^[\w\_\:\;\/\(\)=\&\%\$\!\'\?\*\#\,\@<>\^]*$/, // avoid non ascii
                regexText: 'Invalid Cryptkey entered, dont use non ASCII-Characters',
                name: 'cryptkey'
            }, {
                xtype: 'checkbox',
                boxLabel: 'Encryption',
                name: 'cryptoption/1',
                inputValue: 1,
                labelSeparator: ''
            }, {
                xtype: 'checkbox',
                boxLabel: 'Encrypt VLAN-ID',
                name: 'cryptoption/2',
                inputValue: 1,
                labelSeparator: ''
            }]
        }, {
            xtype: 'fieldset',
            title: 'CAN',
            x: 5,
            y: 430,
            defaults: {
                width: 64
            },
            width: 370,
            height: 60,
            items: [{
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 255,
                fieldLabel: 'CAN-VLAN-ID',
                name: 'canvlan',
                allowBlank: false
            }]
        }, {
            xtype: 'fieldset',
            title: 'Signal Level',
            x: 5,
            y: 500,
            width: 370,
            height: 140,
            items: [{
                layout: 'column',
                items: [{
                    columnWidth: 0.5,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: 'System',
                        name: 'buzzerlevel/1',
                        inputValue: 1
                    
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'IR-Keypress',
                        name: 'buzzerlevel/16',
                        inputValue: 1
                    
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'IR-Command Ack',
                        name: 'buzzerlevel/32',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'IR-Error',
                        name: 'buzzerlevel/64',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'IR-Learn Ack',
                        name: 'buzzerlevel/128',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.5,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: 'GUI-Keypress',
                        name: 'buzzerlevel/256',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'GUI-Command Ack',
                        name: 'buzzerlevel/512',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'GUI-Error',
                        name: 'buzzerlevel/1024',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: 'GUI-Rotary-Encoder-Event',
                        name: 'buzzerlevel/2048',
                        inputValue: 1
                    }]
                }]
            }]
        }, {
            xtype: 'fieldset',
            title: 'Multicast-Groups',
            x: 5,
            y: 650,
            width: 370,
            height: 85,
            items: [{
                layout: 'column',
                items: [{
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '240',
                        name: 'mcastgroup/1',
                        inputValue: 1
                    
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '247',
                        name: 'mcastgroup/128',
                        inputValue: 1
                    
                    }]
                }, {
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '241',
                        name: 'mcastgroup/2',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '248',
                        name: 'mcastgroup/256',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '242',
                        name: 'mcastgroup/4',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '249',
                        name: 'mcastgroup/512',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '243',
                        name: 'mcastgroup/8',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '250',
                        name: 'mcastgroup/1024',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '244',
                        name: 'mcastgroup/16',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '251',
                        name: 'mcastgroup/2048',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '245',
                        name: 'mcastgroup/32',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '252',
                        name: 'mcastgroup/4096',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.13,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        boxLabel: '246',
                        name: 'mcastgroup/64',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        boxLabel: '253',
                        name: 'mcastgroup/8192',
                        inputValue: 1
                    }]
                }]
            }]
        }, {
            xtype: 'fieldset',
            title: 'Logical Input Defaults',
            x: 385,
            y: 5,
            width: 370,
            height: 110,
            labelWidth: 160,
            defaults: {
                width: 64
            },
            items: [{
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 65535,
                fieldLabel: 'Debounced (1/100s)',
                name: 'libouncedelay',
                value: 10,
                allowBlank: false
            }, {
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 65535,
                fieldLabel: 'Short Activation (1/100s)',
                name: 'lishortdelay',
                value: 50,
                allowBlank: false
            }, {
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 65535,
                fieldLabel: 'Long Activation (1/100s)',
                name: 'lilongdelay',
                value: 150,
                allowBlank: false
            }]
        }, {
            xtype: 'fieldset',
            title: 'Common Defaults',
            x: 385,
            y: 125,
            width: 370,
            height: 110,
            labelWidth: 160,
            defaults: {
                width: 64
            },
            items: [{
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 128,
                fieldLabel: 'Receive-Buffer-Size',
                name: 'receivebuffer',
                value: 4,
                allowBlank: false
            }, {
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 255,
                fieldLabel: 'Dimm-Time-Period (1/10s)',
                name: 'dimmercyclelength',
                value: 6,
                allowBlank: false
            }, {
                xtype: 'numberfield',
                minValue: 0,
                maxValue: 65535,
                fieldLabel: 'Dimmer-Pulse-Length (Tics)',
                name: 'dimmerticlength',
                value: 60,
                allowBlank: false
            }]
        }, {
            xtype: 'fieldset',
            title: 'Server Settings',
            x: 385,
            y: 245,
            width: 370,
            height: 60,
            items: [{
                layout: 'column',
                items: [{
                    columnWidth: 0.5,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        id: attrib.id + '/isccu',
                        hapDBID: this.target.split('/')[1],
                        boxLabel: 'Is Server (CCU)',
                        name: 'isccu',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.5,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        id: attrib.id + '/isccumodule',
                        hapDBID: this.target.split('/')[1],
                        boxLabel: 'Is Server-Module (CU)',
                        name: 'isccumodule',
                        inputValue: 1
                    }]
                }]
            }]
        }, {
            xtype: 'fieldset',
            title: 'Firmware Options',
            x: 385,
            y: 315,
            width: 370,
            height: 420,
            defaults: {
                width: 224
            },
            items: [new HAP.ComboFirmware(attrib.id), {
                xtype: 'textfield',
                fieldLabel: 'Current',
                labelStyle: 'font-weight:bold;',
                disabled: true,
                name: 'currentfirmwareid'
            }, {
                layout: 'column',
                width: 333,
                height: 246,
                items: [{
                    columnWidth: 0.5,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'EEProm Support',
                        name: 'fwopt/1',
                        id: attrib.id + '/fwopt/1',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'External Reset',
                        name: 'fwopt/2',
                        id: attrib.id + '/fwopt/2',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Buzzer',
                        name: 'fwopt/4',
                        id: attrib.id + '/fwopt/4',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Wireless',
                        name: 'fwopt/8',
                        id: attrib.id + '/fwopt/8',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'CAN',
                        name: 'fwopt/16',
                        id: attrib.id + '/fwopt/16',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Infrared',
                        name: 'fwopt/32',
                        id: attrib.id + '/fwopt/32',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Shutter Control',
                        name: 'fwopt/8192',
                        id: attrib.id + '/fwopt/8192',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Rotary Encoder PEC11',
                        name: 'fwopt/16384/1',
                        id: attrib.id + '/fwopt/16384/1',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Rotary Encoder STEC',
                        name: 'fwopt/16384/2',
                        id: attrib.id + '/fwopt/16384/2',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Autonomous Control',
                        name: 'fwopt/131072',
                        id: attrib.id + '/fwopt/131072',
                        inputValue: 1
                    }]
                }, {
                    columnWidth: 0.5,
                    layout: 'form',
                    defaults: '',
                    hideLabels: true,
                    items: [{
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Dallas DS18S20',
                        name: 'fwopt/1024',
                        id: attrib.id + '/fwopt/1024',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'LCD GUI',
                        name: 'fwopt/65536',
                        id: attrib.id + '/fwopt/65536',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'LCD 1 Row',
                        name: 'fwopt/64/1',
                        id: attrib.id + '/fwopt/64/1',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'LCD 2 Row',
                        name: 'fwopt/64/2',
                        id: attrib.id + '/fwopt/64/2',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'LCD 3 Row',
                        name: 'fwopt/64/3',
                        id: attrib.id + '/fwopt/64/3',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Logical Input',
                        name: 'fwopt/256',
                        id: attrib.id + '/fwopt/256',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Analog Input',
                        name: 'fwopt/512',
                        id: attrib.id + '/fwopt/512',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Switch',
                        name: 'fwopt/2048',
                        id: attrib.id + '/fwopt/2048',
                        inputValue: 1
                    }, {
                        xtype: 'checkbox',
                        fieldLabel: 'Label',
                        boxLabel: 'Dimmer',
                        name: 'fwopt/4096',
                        id: attrib.id + '/fwopt/4096',
                        inputValue: 1
                    }]
                }]
            }]
        }]
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
    
    HAP.ModulePanel.superclass.constructor.call(this);
    
    this.load({
        url: '/' + this.target.split('/')[0] + '/get/' + this.target.split('/')[1],
        params: 'module=' + attrib.module + '&room=' + attrib.room,
        method: 'GET',
        success: function(form, action){
            if (action.result.data.id != 0) {
                Ext.getCmp(attrib.id).setTitle(action.result.data.name);
            }
            Ext.getCmp(attrib.id + '/textName').focus();
            setCurrentFwLabels(action.result.data);
        }
    });
    
    storeFreeModuleAddresses.proxy = new Ext.data.HttpProxy({
        url: '/json/getFreeModuleAddresses/' + this.target.split('/')[1]
    });
    storeFreeModuleAddresses.load();
    
    var checkCCU = function(box, checked){
        if (checked) {
            if (this.name == 'isccu') {
                checkIsCCUModule.setValue(false);
            }
            else {
                checkIsCCU.setValue(false)
                Ext.getCmp(attrib.id + '/bridgemode').setValue(true);
            }
            Ext.getCmp(attrib.id).load({
                url: 'module/checkForCCU/' + this.name + '/' +
                this.hapDBID,
                method: 'GET',
                success: function(form, action){
                    var mString = '';
                    for (i = 0; i < action.result.data.length; i++) {
                        mString += action.result.data[i].name + '<br>';
                    }
                    Ext.MessageBox.show({
                        title: 'Warning',
                        msg: 'The following module(s) are already defined as a Server(-Module):' + '<br>' + mString,
                        buttons: Ext.Msg.OK,
                        icon: Ext.MessageBox.INFO
                    })
                }
            })
        }
    }
    
    var getFwOpts = function(combo, item){
        if (item.data.precompiled == 1 && item.data.id != 0) {
            Ext.getCmp(attrib.id).load({
                url: 'module/getFwOpts/fromFirmware/' + item.data.id,
                method: 'GET',
                success: function(form, action){
                    for (item in action.result.data) {
                        var cmp = Ext.getCmp(attrib.id + '/' + item);
                        if (cmp) {
                            cmp.disable()
                        }
                    }
                }
            })
        }
        else {
            var cmp = Ext.getCmp(attrib.id);
            cmp.load({
                url: 'module/getFwOpts/fromModule/' + attrib.id.split('/')[1],
                method: 'GET',
                success: function(form, action){
                    for (item in action.result.data) {
                        var cmp = Ext.getCmp(attrib.id + '/' + item);
                        if (cmp) {
                            cmp.enable()
                        }
                    }
                }
            })
        }
    }
    
    var setCurrentFwLabels = function(resultData){ //on Load ...
        for (var item in resultData) {
            if (item.search(/currfwopt\/.*/) != -1) {
                if (resultData[item] == 1) {
                    var obj = Ext.getCmp(attrib.id + '/' + item.replace(/currfwopt/g, 'fwopt'));
                    if (obj) {
                        obj.getEl().up('div').setStyle('font-weight', 'bold');
                    }
                }
            }
            if (resultData.precompiled == 1) {
                if (item.search(/fwopt\/.*/) != -1) {
                    var obj = Ext.getCmp(attrib.id + '/' + item);
                    if (obj) {
                        obj.disable();
                    }
                }
            }
        }
    }
    
    checkIsCCU = Ext.getCmp(attrib.id + '/isccu');
    checkIsCCU.on('check', checkCCU);
    checkIsCCUModule = Ext.getCmp(attrib.id + '/isccumodule');
    checkIsCCUModule.on('check', checkCCU);
    
    var comboFw = Ext.getCmp(attrib.id + '/comboFirmware');
    comboFw.on('select', getFwOpts);
    
    this.on('activate', function(){
        Ext.getCmp(attrib.id + '/textName').focus();
    });
    
}

Ext.extend(HAP.ModulePanel, Ext.FormPanel, {});
