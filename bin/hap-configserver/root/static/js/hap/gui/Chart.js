HAP.Chart = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.Chart';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        x: 0,
        y: 0,
        height: 100,
        width: 150,
        'z-Index': 2,
        'Update Interval (s)': 3600,
        'Start-Offset (m)': 60,
        'Chart-Data': '',
        'chart': {
            'bg_colour': '#FF0000',
            'title': {
                'text': 'Many data lines',
                'style': '{font-size: 14px; color:#000000; font-family: Verdana; text-align: center;}'
            },
            'x_legend': {
                'text': 'X-Legend',
                'style': '{color: #000000; font-size: 10px;}'
            },
            'y_legend': {
                'text': 'Y-Legend',
                'style': '{color: #000000; font-size: 10px;}'
            },
            'x_axis': {
                'stroke': 1,
                'tick_height': 10,
                'colour': '#000000',
                'offset': 0,
                'grid_colour': '#000000',
                '3d': false,
                'steps': 1,
                'rotate': 'vertical'
            },
            'x_axis_labels': {
                'stroke': 1,
                'tick_height': 10,
                'colour': '#000000',
                'offset': 0,
                'grid_colour': '#000000',
                '3d': false,
                'steps': 1,
                'rotate': 'vertical',
                'show_date': false // custom
            },
            'y_axis': {
                'stroke': 1,
                'tick_height': 10,
                'colour': '#000000',
                'offset': 0,
                'grid_colour': '#000000',
                '3d': false,
                'steps': 1,
                'max': 100,
                'min': 0
            },
            'y_axis_labels': {
                'stroke': 1,
                'tick_height': 10,
                'colour': '#000000',
                'offset': 0,
                'grid_colour': '#000000',
                '3d': false,
                'steps': 1,
                'max': 100,
                'min': 0
            },
            'elements': []
        },
        'templates': {
            'bar': {
                'type': 'bar',
                'HAP-Name': 'Bar',
                'HAP-Module': '',
                'HAP-Device': '',
                'Scale': 1,
                'alpha': 0.5,
                'colour': '#000000',
                'text': 'Data',
                'font-size': 10
            },
            'pie': {
                'type': 'pie',
                'HAP-Name': 'Pie',
                'HAP-Module': '',
                'HAP-Device': '',
                'Scale': 1,
                'start-angle': 180,
                'colours': ['#d01f3c', '#356aa0', '#C79810', '#73880A', '#D15600', '#6BBA70'],
                'alpha': 0.6,
                'stroke': 2,
                'animate': 1
            },
            'hbar': {
                'type': 'hbar',
                'HAP-Name': 'H-Bar',
                'HAP-Module': '',
                'HAP-Device': '',
                'Scale': 1,
                'colour': '#000000',
                'text': 'Data',
                'font-size': 10
            },
            'line': {
                'type': 'line',
                'HAP-Name': 'Line',
                'HAP-Module': '',
                'HAP-Device': '',
                'Scale': 1,
                'colour': '#000000',
                'text': 'Data',
                'width': 2,
                'font-size': 10,
                'dot-size': 2
            },
            'line_dot': {
                'type': 'line_dot',
                'HAP-Name': 'Line-Dot',
                'HAP-Module': '',
                'HAP-Device': '',
                'Scale': 1,
                'colour': '#000000',
                'width': 1,
                'text': 'Data',
                'font-size': 10,
                'dot-size': 2
            },
            'line_hollow': {
                'type': 'line_hollow',
                'HAP-Name': 'Line-Hollow',
                'HAP-Module': '',
                'HAP-Device': '',
                'Scale': 1,
                'colour': '#000000',
                'width': 1,
                'text': 'Data',
                'font-size': 10,
                'dot-size': 2,
                'fill-alpha': 0.35
            }
        }
    
    };
    this.conf = apply(this.conf, config);
    this.create(this.conf)
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.Chart.prototype.create = function(conf){
    this.div = document.createElement('div');
    this.div.id = this.conf.id;
    this.img = document.createElement('img');
    this.ofcDiv = document.createElement('div');
    this.ofcDiv.id = this.conf.id + '/ofc';
    this.div.appendChild(this.img);
    this.div.appendChild(this.ofcDiv);
    //this.div.id = this.conf.id;
    return this.div;
}

HAP.Chart.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    this.div.style.position = 'absolute';
    this.div.style.width = this.conf.display['width'] + 'px';
    this.div.style.height = this.conf.display['height'] + 'px';
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
        var oThis = this;
        YAHOO.util.Event.onDOMReady(function(){
            swfobject.embedSWF("/static/js/ofc/open-flash-chart.swf", oThis.conf.id + '/ofc', oThis.conf.display['width'], oThis.conf.display['height'], "9.0.0", "/static/js/ofc/expressInstall.swf");
        });
    }
    else {
        this.img.src = this.conf.imagePath + 'Chart.png';
        this.img.style.width = this.conf.display['width'] + 'px';
        this.img.style.height = this.conf.display['height'] + 'px';
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
}

function open_flash_chart_data(){
    return '{"bg_colour": "#FFFFFF","x-axis": {}, "y-axis":{}, "elements":[]}';
}

HAP.Chart.prototype.setValue = function(value){
    if (value) 
        this.conf.display.chart = value;
    var tmp = findSWF(this.conf.id + '/ofc');
    if (tmp.load) {
        tmp.load(YAHOO.lang.JSON.stringify(this.conf.display.chart));
    }
    else {  // not ready, try again later
			  var oThis = this;
        setTimeout(function() { oThis.setValue() }, 200);
    }
}

function findSWF(movieName){
    if (navigator.appName.indexOf("Microsoft") != -1) {
        return window[movieName];
    }
    else {
        return document[movieName];
    }
}

HAP.Chart.prototype.attachEvent = function(event, handler, viewPortCall){
    if (!viewPortCall && event == 'onclick') {
        this.layer.onclick = handler;
    }
}

HAP.Chart.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    this.img.style.width = width + 'px';
}

HAP.Chart.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    this.img.style.height = height + 'px';
}

HAP.Chart.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.Chart.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Chart.prototype.setRequest = function(value){
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

HAP.ChartImage = function(conf){
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
