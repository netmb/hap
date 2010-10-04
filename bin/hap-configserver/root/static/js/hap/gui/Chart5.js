HAP.Chart5 = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.tmpId = 'x' + Math.random() + 'x';
    this.conf.type = 'HAP.Chart5';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        x: 0,
        y: 0,
        height: 100,
        width: 150,
        'z-Index': 2,
        'Update Interval (s)': 3600,
        'Start-Offset (m)': 60,
        'Chart-Properties': '',
        'Chart-Type': 'Line',
        'Chart-X-Interval': 1,
        'sourceTemplate': {
            'HAP-Module': '',
            'HAP-Device': '',
            'Description': '',
            'chart.colors': '',
            'chart.fillstyle': '',
            'chart.key': ''
            //'chart.labels': ''
        },
        'dataSources': [],
        'chart': {
            'Line': {
                'chart.background.barcolor1': 'rgba(0,0,0,0)',
                'chart.background.barcolor2': 'rgba(0,0,0,0)',
                'chart.background.grid': 1,
                'chart.background.grid.width': 1,
                'chart.background.grid.hsize': 25,
                'chart.background.grid.vsize': 25,
                'chart.background.grid.color': '#ddd',
                'chart.background.grid.vlines': true,
                'chart.background.grid.hlines': true,
                'chart.background.grid.border': true,
                'chart.background.grid.autofit': false,
                'chart.background.grid.autofit.numhlines': 7,
                'chart.background.grid.autofit.numvlines': 20,
                'chart.background.hbars': null,
                'chart.labels': null,
                'chart.labels.ingraph': null,
                'chart.xtickgap': 20,
                'chart.smallxticks': 3,
                'chart.largexticks': 5,
                'chart.ytickgap': 20,
                'chart.smallyticks': 3,
                'chart.largeyticks': 5,
                'chart.linewidth': 1,
                'chart.colors': ['red', '#0f0', '#00f', '#f0f', '#ff0', '#0ff'],
                'chart.hmargin': 0,
                'chart.tickmarks.dot.color': 'white',
                'chart.tickmarks': null,
                'chart.ticksize': 3,
                'chart.gutter': 25,
                'chart.tickdirection': -1,
                'chart.yaxispoints': 5,
                'chart.fillstyle': null,
                'chart.xaxispos': 'bottom',
                'chart.yaxispos': 'left',
                'chart.xticks': null,
                'chart.text.size': 10,
                'chart.text.angle': 0,
                'chart.text.color': 'black',
                'chart.text.font': 'Verdana',
                'chart.ymin': null,
                'chart.ymax': null,
                'chart.title': '',
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.title.xaxis': '',
                'chart.title.yaxis': '',
                'chart.title.xaxis.pos': 0.25,
                'chart.title.yaxis.pos': 0.25,
                'chart.shadow': false,
                'chart.shadow.offsetx': 2,
                'chart.shadow.offsety': 2,
                'chart.shadow.blur': 3,
                'chart.shadow.color': 'rgba(0,0,0,0.5)',
                'chart.tooltips': [],
                'chart.tooltips.effect': 'fade',
                'chart.tooltips.css.class': 'RGraph_tooltip',
                'chart.tooltips.coords.adjust': [0, 0],
                'chart.tooltips.highlight': true,
                'chart.stepped': false,
                'chart.key': [],
                'chart.key.background': 'white',
                'chart.key.position': 'graph',
                'chart.key.shadow': false,
                'chart.key.shadow.color': '#666',
                'chart.key.shadow.blur': 3,
                'chart.key.shadow.offsetx': 2,
                'chart.key.shadow.offsety': 2,
                'chart.contextmenu': null,
                'chart.ylabels': true,
                'chart.ylabels.count': 5,
                'chart.ylabels.inside': false,
                'chart.ylabels.invert': false,
                'chart.xlabels.inside': false,
                'chart.xlabels.inside.color': 'rgba(255,255,255,0.5)',
                'chart.noaxes': false,
                'chart.noyaxis': false,
                'chart.noxaxis': false,
                'chart.noendxtick': false,
                'chart.units.post': '',
                'chart.units.pre': '',
                'chart.scale.decimals': 0,
                'chart.scale.point': '.',
                'chart.scale.thousand': ',',
                'chart.crosshairs': false,
                'chart.crosshairs.color': '#333',
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.axesontop': false,
                'chart.filled.range': false,
                'chart.variant': null,
                'chart.axis.color': 'black',
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 15,
                'chart.zoom.delay': 33,
                'chart.zoom.shadow': true,
                'chart.zoom.mode': 'canvas',
                'chart.zoom.thumbnail.width': 75,
                'chart.zoom.thumbnail.height': 75,
                'chart.zoom.background': true,
                'chart.zoom.action': 'zoom',
                'chart.backdrop': false,
                'chart.backdrop.size': 30,
                'chart.backdrop.alpha': 0.2,
                'chart.resizable': false,
                'chart.adjustable': false,
                'chart.noredraw': false,
                'chart.xticks': ''
            },
            'Bar': {
                'chart.background.barcolor1': 'rgba(0,0,0,0)',
                'chart.background.barcolor2': 'rgba(0,0,0,0)',
                'chart.background.grid': true,
                'chart.background.grid.color': '#ddd',
                'chart.background.grid.width': 1,
                'chart.background.grid.hsize': 20,
                'chart.background.grid.vsize': 20,
                'chart.background.grid.vlines': true,
                'chart.background.grid.hlines': true,
                'chart.background.grid.border': true,
                'chart.background.grid.autofit': false,
                'chart.background.grid.autofit.numhlines': 7,
                'chart.background.grid.autofit.numvlines': 20,
                'chart.ytickgap': 20,
                'chart.smallyticks': 3,
                'chart.largeyticks': 5,
                'chart.numyticks': 10,
                'chart.hmargin': 5,
                'chart.strokecolor': '#666',
                'chart.axis.color': 'black',
                'chart.gutter': 25,
                'chart.labels': null,
                'chart.labels.ingraph': null,
                'chart.labels.above': false,
                'chart.ylabels': true,
                'chart.ylabels.count': 5,
                'chart.ylabels.inside': false,
                'chart.xlabels.offset': 0,
                'chart.xaxispos': 'bottom',
                'chart.yaxispos': 'left',
                'chart.text.color': 'black',
                'chart.text.size': 10,
                'chart.text.angle': 0,
                'chart.text.font': 'Verdana',
                'chart.ymax': null,
                'chart.title': '',
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.title.xaxis': '',
                'chart.title.yaxis': '',
                'chart.title.xaxis.pos': 0.25,
                'chart.title.yaxis.pos': 0.25,
                'chart.colors': ['rgb(0,0,255)', '#0f0', '#00f', '#ff0', '#0ff', '#0f0'],
                'chart.grouping': 'grouped',
                'chart.variant': 'bar',
                'chart.shadow': false,
                'chart.shadow.color': '#666',
                'chart.shadow.offsetx': 3,
                'chart.shadow.offsety': 3,
                'chart.shadow.blur': 3,
                'chart.tooltips': [],
                'chart.tooltips.effect': 'fade',
                'chart.tooltips.css.class': 'RGraph_tooltip',
                'chart.tooltips.event': 'onclick',
                'chart.tooltips.coords.adjust': [0, 0],
                'chart.tooltips.highlight': true,
                'chart.background.hbars': null,
                'chart.key': [],
                'chart.key.background': 'white',
                'chart.key.position': 'graph',
                'chart.key.shadow': false,
                'chart.key.shadow.color': '#666',
                'chart.key.shadow.blur': 3,
                'chart.key.shadow.offsetx': 2,
                'chart.key.shadow.offsety': 2,
                'chart.contextmenu': null,
                'chart.line': null,
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.scale.decimals': 0,
                'chart.scale.point': '.',
                'chart.scale.thousand': ',',
                'chart.crosshairs': false,
                'chart.crosshairs.color': '#333',
                'chart.linewidth': 1,
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 10,
                'chart.zoom.delay': 50,
                'chart.zoom.shadow': true,
                'chart.zoom.mode': 'canvas',
                'chart.zoom.thumbnail.width': 75,
                'chart.zoom.thumbnail.height': 75,
                'chart.zoom.background': true,
                'chart.resizable': false,
                'chart.adjustable': false
            },
            'HBar': {
                'chart.gutter': 25,
                'chart.background.grid': true,
                'chart.background.grid.color': '#ddd',
                'chart.background.grid.width': 1,
                'chart.background.grid.hsize': 25,
                'chart.background.grid.vsize': 25,
                'chart.background.barcolor1': 'white',
                'chart.background.barcolor2': 'white',
                'chart.background.grid.hlines': true,
                'chart.background.grid.vlines': true,
                'chart.background.grid.border': true,
                'chart.background.grid.autofit': false,
                'chart.background.grid.autofit.numhlines': 14,
                'chart.background.grid.autofit.numvlines': 20,
                'chart.title': '',
                'chart.title.xaxis': '',
                'chart.title.yaxis': '',
                'chart.title.xaxis.pos': 0.25,
                'chart.title.yaxis.pos': 0.5,
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.text.size': 10,
                'chart.text.color': 'black',
                'chart.text.font': 'Verdana',
                'chart.colors': ['rgb(0,0,255)', '#0f0', '#00f', '#ff0', '#0ff', '#0f0'],
                'chart.labels': [],
                'chart.labels.above': false,
                'chart.contextmenu': null,
                'chart.key': [],
                'chart.key.background': 'white',
                'chart.key.position': 'graph',
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.units.ingraph': false,
                'chart.strokestyle': 'black',
                'chart.xmax': 0,
                'chart.axis.color': 'black',
                'chart.shadow': false,
                'chart.shadow.color': '#666',
                'chart.shadow.blur': 3,
                'chart.shadow.offsetx': 3,
                'chart.shadow.offsety': 3,
                'chart.vmargin': 3,
                'chart.grouping': 'grouped',
                'chart.tooltips': [],
                'chart.tooltips.effect': 'fade',
                'chart.tooltips.css.class': 'RGraph_tooltip',
                'chart.tooltips.highlight': true,
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 10,
                'chart.zoom.delay': 50,
                'chart.zoom.shadow': true,
                'chart.zoom.mode': 'canvas',
                'chart.zoom.thumbnail.width': 75,
                'chart.zoom.thumbnail.height': 75,
                'chart.zoom.background': true,
                'chart.zoom.action': 'zoom',
                'chart.resizable': false,
                'chart.scale.point': '.',
                'chart.scale.thousand': ','
            },
            'HProgress': {
                'chart.colors': ['#0c0'],
                'chart.tickmarks': true,
                'chart.tickmarks.color': 'black',
                'chart.tickmarks.inner': false,
                'chart.gutter': 25,
                'chart.numticks': 10,
                'chart.numticks.inner': 50,
                'chart.background.color': '#eee',
                'chart.shadow': false,
                'chart.shadow.color': 'rgba(0,0,0,0.5)',
                'chart.shadow.blur': 3,
                'chart.shadow.offsetx': 3,
                'chart.shadow.offsety': 3,
                'chart.title': '',
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.width': 0,
                'chart.height': 0,
                'chart.text.size': 10,
                'chart.text.color': 'black',
                'chart.text.font': 'Verdana',
                'chart.contextmenu': null,
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.tooltips': [],
                'chart.tooltips.effect': 'fade',
                'chart.tooltips.css.class': 'RGraph_tooltip',
                'chart.tooltips.highlight': true,
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.zoom.mode': 'canvas',
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 10,
                'chart.zoom.delay': 50,
                'chart.zoom.shadow': true,
                'chart.zoom.background': true,
                'chart.zoom.action': 'zoom',
                'chart.arrows': false,
                'chart.margin': 0,
                'chart.resizable': false,
                'chart.label.inner': false,
                'chart.adjustable': false
            },
            'VProgress': {
                'chart.colors': ['#0c0'],
                'chart.tickmarks': true,
                'chart.tickmarks.color': 'black',
                'chart.tickmarks.inner': false,
                'chart.gutter': 25,
                'chart.numticks': 10,
                'chart.numticks.inner': 50,
                'chart.background.color': '#eee',
                'chart.shadow': false,
                'chart.shadow.color': 'rgba(0,0,0,0.5)',
                'chart.shadow.blur': 3,
                'chart.shadow.offsetx': 3,
                'chart.shadow.offsety': 3,
                'chart.title': '',
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.width': 0,
                'chart.height': 0,
                'chart.text.size': 10,
                'chart.text.color': 'black',
                'chart.text.font': 'Verdana',
                'chart.contextmenu': null,
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.tooltips': [],
                'chart.tooltips.effect': 'fade',
                'chart.tooltips.css.class': 'RGraph_tooltip',
                'chart.tooltips.highlight': true,
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.zoom.mode': 'canvas',
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 10,
                'chart.zoom.delay': 50,
                'chart.zoom.shadow': true,
                'chart.zoom.background': true,
                'chart.zoom.action': 'zoom',
                'chart.arrows': false,
                'chart.margin': 0,
                'chart.resizable': false,
                'chart.label.inner': false,
                'chart.adjustable': false
            },
            'Meter': {
                'chart.gutter': 25,
                'chart.linewidth': 2,
                'chart.border.color': 'black',
                'chart.text.font': 'Verdana',
                'chart.text.size': 10,
                'chart.text.color': 'black',
                'chart.title': '',
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.title.color': 'black',
                'chart.green.start': ((this.max - this.min) * 0.35) + this.min,
                'chart.green.end': this.max,
                'chart.green.color': '#207A20',
                'chart.yellow.start': ((this.max - this.min) * 0.1) + this.min,
                'chart.yellow.end': ((this.max - this.min) * 0.35) + this.min,
                'chart.yellow.color': '#D0AC41',
                'chart.red.start': this.min,
                'chart.red.end': ((this.max - this.min) * 0.1) + this.min,
                'chart.red.color': '#9E1E1E',
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.contextmenu': null,
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 15,
                'chart.zoom.delay': 33,
                'chart.zoom.shadow': true,
                'chart.zoom.mode': 'canvas',
                'chart.zoom.thumbnail.width': 75,
                'chart.zoom.thumbnail.height': 75,
                'chart.zoom.background': true,
                'chart.zoom.action': 'zoom',
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.shadow': false,
                'chart.shadow.color': 'rgba(0,0,0,0.5)',
                'chart.shadow.blur': 3,
                'chart.shadow.offsetx': 3,
                'chart.shadow.offsety': 3,
                'chart.reszable': false
            },
            'Odometer': {
                'chart.value.text': false,
                'chart.needle.color': 'black',
                'chart.needle.width': 2,
                'chart.needle.head': true,
                'chart.needle.tail': true,
                'chart.needle.type': 'pointer',
                'chart.needle.extra': [],
                'chart.text.size': 10,
                'chart.text.color': 'black',
                'chart.text.font': 'Verdana',
                'chart.green.max': this.end * 0.75,
                'chart.red.min': this.end * 0.9,
                'chart.green.color': 'green',
                'chart.yellow.color': 'yellow',
                'chart.red.color': 'red',
                'chart.label.area': 35,
                'chart.gutter': 25,
                'chart.title': '',
                'chart.title.hpos': null,
                'chart.title.vpos': null,
                'chart.contextmenu': null,
                'chart.linewidth': 1,
                'chart.shadow.inner': false,
                'chart.shadow.inner.color': 'black',
                'chart.shadow.inner.offsetx': 3,
                'chart.shadow.inner.offsety': 3,
                'chart.shadow.inner.blur': 6,
                'chart.shadow.outer': false,
                'chart.shadow.outer.color': '#666',
                'chart.shadow.outer.offsetx': 0,
                'chart.shadow.outer.offsety': 0,
                'chart.shadow.outer.blur': 15,
                'chart.annotatable': false,
                'chart.annotate.color': 'black',
                'chart.scale.decimals': 0,
                'chart.zoom.factor': 1.5,
                'chart.zoom.fade.in': true,
                'chart.zoom.fade.out': true,
                'chart.zoom.hdir': 'right',
                'chart.zoom.vdir': 'down',
                'chart.zoom.frames': 10,
                'chart.zoom.delay': 50,
                'chart.zoom.shadow': true,
                'chart.zoom.mode': 'canvas',
                'chart.zoom.thumbnail.width': 75,
                'chart.zoom.thumbnail.height': 75,
                'chart.zoom.background': true,
                'chart.zoom.action': 'zoom',
                'chart.resizable': false,
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.border': false,
                'chart.tickmarks.highlighted': false,
                'chart.zerostart': false,
                'chart.labels': null,
                'chart.units.pre': '',
                'chart.units.post': '',
                'chart.value.units.pre': '',
                'chart.value.units.post': ''
            }
        }
    };
    this.conf = apply(this.conf, config);
    this.create(this.conf)
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.Chart5.prototype.create = function(conf){
    this.div = document.createElement('canvas');
    this.div.id = this.conf.tmpId;
    return this.div;
}

HAP.Chart5.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    this.div.style.position = 'absolute';
    this.div.style.width = this.conf.display['width'] + 'px';
    this.div.style.height = this.conf.display['height'] + 'px';
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
        // stuff for gui
    }
    else {
        var data = [1, 2, 3];
        if (document.getElementById(this.conf.tmpId)) {
            if (this.chart) {
                RGraph.Clear(this.chart.canvas);
                var p = this.div.getParent();
                p.removeChild(document.getElementById(this.conf.tmpId));
                p.appendChild(this.create());
            }
            var type = this.conf.display['Chart-Type'];
            this.chart = new RGraph[type](this.conf.tmpId, data);
            this.chart.canvas.width = this.conf.display['width'];
            this.chart.canvas.height = this.conf.display['height'];
            
            // To optimize : set properties directly not via loop !
            for (var prop in this.conf.display.chart[type]) {
                var val = this.conf.display.chart[type][prop];
                this.chart.Set(prop, val);
            }
            
            // set datasource props
            var size = this.conf.display.dataSources.length;
            for (var i = 0; i < size; i++) {
                var cObj = this.conf.display.dataSources[i];
                for (var cProp in cObj) {
                    if (this.conf.display.chart[type][cProp] instanceof Array && this.conf.display.dataSources[i][cProp]) {
                        if (i == 0) 
                            this.conf.display.chart[type][cProp] = [];
                        this.conf.display.chart[type][cProp].push(this.conf.display.dataSources[i][cProp]);
                        this.chart.Set(cProp, this.conf.display.chart[type][cProp]);
                    }
                }
            }
            var data = this.getData(this.conf.display.dataSources, true);
            //this.chart.Set('chart.labels', data.labels);
            //this.chart.original_data = data.values;
            //this.chart.Draw();
            
            
        }
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
}

HAP.Chart5.prototype.getData = function(dataSources, viewPortCall){
    var data = {
        labels: ['a', 'b', 'c'],
        values: [[1, 2, 3]]
    };
    if (viewPortCall) {
        var oThis = this;
        Ext.Ajax.request({
            url: 'gui/getChartData',
            params: {
                'data': Ext.encode(dataSources),
                'startOffset': this.conf.display['Start-Offset (m)'],
                'xSkip': this.conf.display['Chart-X-Interval']
            },
            success: function(res, req){
                data = Ext.decode(res.responseText).data;
                RGraph.Clear(oThis.chart.canvas);
                oThis.chart.Set('chart.labels', data.labels);
                oThis.chart.original_data = data.values;
                oThis.chart.Draw();
            },
            failure: function(res, req){
                alert('FAIL');
            }
        });
    }
    else {
        YAHOO.util.Connect.asyncRequest('get', '/gui/getChartData', {
            success: function(o){
                if (YAHOO.lang.JSON.isValid(o.responseText)) {
                    var response = YAHOO.lang.JSON.parse(o.responseText);
                    if (response.success) {
                        data = response;
                    }
                }
            }
        });
    }
    return data;
}

HAP.Chart5.prototype.setValue = function(value){
    if (value) 
        this.conf.display.chart = value;
}

HAP.Chart5.prototype.attachEvent = function(event, handler, viewPortCall){
    if (!viewPortCall && event == 'onclick') {
        this.layer.onclick = handler;
    }
}

HAP.Chart5.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    if (this.chart) {
        RGraph.Clear(this.chart.canvas);
        this.chart.canvas.width = width;
        this.chart.Draw();
    }
}

HAP.Chart5.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    if (this.chart) {
        RGraph.Clear(this.chart.canvas);
        this.chart.canvas.height = height;
        this.chart.Draw();
    }
}

HAP.Chart5.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.Chart5.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Chart5.prototype.setRequest = function(value){
    var oThis = this;
    YAHOO.util.Connect.asyncRequest('get', '/gui/setDevice/' + this.conf.display['HAP-Module'] + '/' + this.conf.display['HAP-Device'] + '/' + value, {
        success: function(o){
            if (YAHOO.lang.JSON.isValid(o.responseText)) {
                var response = YAHOO.lang.JSON.parse(o.responseText);
                if (response.success) {
                    oThis.setValue(response.data.value);
                }
            }
            else {
                document.getElementById('rootDiv').innerHTML = o.responseText;
            }
        }
    });
}

HAP.Chart5Image = function(conf){
    this.conf = conf;
    this.conf.imagePath = '/static/images/gui/';
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.textAlign = 'center';
    div.style.position = 'absolute';
    
    var img = document.createElement('img');
    img.src = this.conf.imagePath + 'Chart_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
