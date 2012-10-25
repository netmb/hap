/*
 * Ext JS Library 2.0.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://extjs.com/license
 */
var ImageChooser = function(config){
    this.config = config;
}

ImageChooser.prototype = {
    // cache data by image name for easy lookup
    lookup: {},
    
    show: function(el, callback){
        if (!this.win) {
        
            this.initTemplates();
            
            this.store = new Ext.data.JsonStore({
                url: this.config.url,
                root: 'images',
                fields: ['name', 'url', 'w', 'h', {
                    name: 'size',
                    type: 'float'
                }],
                listeners: {
                    'load': {
                        fn: function(){
                            this.view.select(0);
                        },
                        scope: this,
                        single: true
                    }
                }
            });
            this.store.load();
            
            var formatSize = function(data){
                if (data.size < 1024) {
                    return data.size + " bytes";
                }
                else {
                    return (Math.round(((data.size * 10) / 1024)) / 10) + " KB";
                }
            };
            
            var formatData = function(data){
                data.shortName = data.name.ellipse(15);
                data.sizeString = formatSize(data);
                data.w = parseInt(data.w);
                data.h = parseInt(data.h);
                if (data.w > 60 || data.h > 60) {
                    var scale = 1;
                    if (data.w > data.h) {
                        scale = data.w / 60;
                    }
                    else {
                        scale = data.h / 60;
                    }
                    data.wS = data.w / scale;
                    data.hS = data.h / scale;
                }
                else {
                    data.wS = data.w;
                    data.hS = data.h;
                }
                this.lookup[data.name] = data;
                return data;
            };
            
            
            this.view = new Ext.DataView({
                tpl: this.thumbTemplate,
                singleSelect: true,
                overClass: 'x-view-over',
                itemSelector: 'div.thumb-wrap',
                emptyText: '<div style="padding:10px;">No images match the specified filter</div>',
                store: this.store,
                listeners: {
                    'selectionchange': {
                        fn: this.showDetails,
                        scope: this,
                        buffer: 100
                    },
                    'dblclick': {
                        fn: this.doCallback,
                        scope: this
                    },
                    'loadexception': {
                        fn: this.onLoadException,
                        scope: this
                    },
                    'beforeselect': {
                        fn: function(view){
                            return view.store.getRange().length > 0;
                        }
                    }
                },
                prepareData: formatData.createDelegate(this)
            });
            
            var oThis = this;
            var cfg = {
                title: 'Choose an Image',
                id: 'img-chooser-dlg',
                layout: 'border',
                width: 800,
                height: 500,
                modal: true,
                //closeAction: 'hide',
                border: false,
                items: [{
                    id: 'img-chooser-view',
                    region: 'center',
                    autoScroll: true,
                    items: this.view,
                    tbar: [{
                        text: 'Filter:'
                    }, {
                        xtype: 'textfield',
                        id: 'filter',
                        selectOnFocus: true,
                        width: 100,
                        listeners: {
                            'render': {
                                fn: function(){
                                    Ext.getCmp('filter').getEl().on('keyup', function(){
                                        this.filter();
                                    }, this, {
                                        buffer: 500
                                    });
                                },
                                scope: this
                            }
                        }
                    }, ' ', '-', {
                        text: 'Sort By:'
                    }, {
                        id: 'sortSelect',
                        xtype: 'combo',
                        typeAhead: true,
                        triggerAction: 'all',
                        width: 100,
                        editable: false,
                        mode: 'local',
                        displayField: 'desc',
                        valueField: 'name',
                        lazyInit: false,
                        value: 'name',
                        store: new Ext.data.SimpleStore({
                            fields: ['name', 'desc'],
                            data: [['name', 'Name'], ['size', 'File Size'], ['w', 'Width'], ['h', 'Height']]
                        }),
                        listeners: {
                            'select': {
                                fn: this.sortImages,
                                scope: this
                            }
                        }
                    }]
                }, {
                    id: 'img-detail-panel',
                    region: 'east',
                    autoScroll: true,
                    split: true,
                    width: 400
                }],
                
                buttons: [{
                    id: 'ok-btn',
                    text: 'OK',
                    handler: this.doCallback,
                    scope: this
                }, {
                    text: 'Cancel',
                    handler: function(){
                        this.win.close();
                    },
                    scope: this
                }, {
                    text: 'Upload..',
                    iconCls: 'upload',
                    handler: function(){
                        HAP.UploadFileWindow(null, null, function(){
                            oThis.store.reload(); //callback
                        });
                    }
                }, {
                    text: 'Delete',
                    iconCls: 'delete',
                    handler: this.deleteImage,
                    scope: this
                }],
                
                keys: {
                    key: 27, // Esc key
                    handler: function(){
                        this.win.close();
                    },
                    scope: this
                }
            
            };
            Ext.apply(cfg, this.config);
            this.win = new Ext.Window(cfg);
        }
        this.reset();
        this.win.show(el);
        this.win.setZIndex(10001); //fix for Firefox 3
        this.callback = callback;
        this.animateTarget = el;
    },
    
    initTemplates: function(){
        this.thumbTemplate = new Ext.XTemplate('<tpl for=".">', '<div class="thumb-wrap" id="{name}">', '<div class="thumb"><img style="width:{wS}px; height:{hS}px" src="{url}" title="{name}"></div>', '<span>{shortName}</span></div>', '</tpl>');
        this.thumbTemplate.compile();
        
        this.detailsTemplate = new Ext.XTemplate('<div class="details">', '<tpl for=".">', '<div class="details-info">', '<b>Image Name:</b>', '<span>{name}</span>', '<b> - Size:</b>', '<span>{sizeString}</span>', '<b> - Dimension:</b>', '<span>w:{w}px, h:{h}px</span>', '</div> <img src="{url}">', '</tpl>', '</div>');
        this.detailsTemplate.compile();
    },
    
    showDetails: function(){
        var selNode = this.view.getSelectedNodes();
        var detailEl = Ext.getCmp('img-detail-panel').body;
        if (selNode && selNode.length > 0) {
            selNode = selNode[0];
            Ext.getCmp('ok-btn').enable();
            var data = this.lookup[selNode.id];
            detailEl.hide();
            this.detailsTemplate.overwrite(detailEl, data);
            detailEl.slideIn('l', {
                stopFx: true,
                duration: 0.2
            });
        }
        else {
            Ext.getCmp('ok-btn').disable();
            detailEl.update('');
        }
    },
    
    filter: function(){
        var filter = Ext.getCmp('filter');
        this.view.store.filter('name', filter.getValue());
        this.view.select(0);
    },
    
    sortImages: function(){
        var v = Ext.getCmp('sortSelect').getValue();
        this.view.store.sort(v, v == 'name' ? 'asc' : 'desc');
        this.view.select(0);
    },
    
    reset: function(){
        if (this.win.rendered) {
            Ext.getCmp('filter').reset();
            this.view.getEl().dom.scrollTop = 0;
        }
        this.view.store.clearFilter();
        this.view.select(0);
    },
    
    doCallback: function(){
        var selNode = this.view.getSelectedNodes()[0];
        var callback = this.callback;
        var lookup = this.lookup;
        if (selNode && callback) {
            var data = lookup[selNode.id];
            callback(data);
            this.win.close();
        }
        /*
         this.win.hide(this.animateTarget, function(){
         if (selNode && callback) {
         var data = lookup[selNode.id];
         callback(data);
         }
         });
         */
    },
    deleteImage: function(){
        var selNode = this.view.getSelectedNodes()[0];
        var data = this.lookup[selNode.id];
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'POST',
            url: '/fileupload/deleteImage',
            params: {
                file: data.name
            }
        });
        var oThis = this;
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.util.JSON.decode(param.responseText);
            if (!response.success) 
                Ext.MessageBox.show({
                    title: 'Warning',
                    msg: "File delete failed.",
                    buttons: Ext.Msg.OK
                });
            else 
                oThis.store.reload();
        });
    },
    
    onLoadException: function(v, o){
        this.view.getEl().update('<div style="padding:10px;">Error loading images.</div>');
    }
};

String.prototype.ellipse = function(maxLength){
    if (this.length > maxLength) {
        return this.substr(0, maxLength - 3) + '...';
    }
    return this;
};
