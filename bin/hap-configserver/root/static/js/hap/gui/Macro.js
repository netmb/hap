/**
 * @author bendowski
 */
HAP.Macro = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.Macro';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        'HAP-Macro': 0,
        x: 0,
        y: 0,
        height: 60,
        width: 60,
        'On-Image': this.conf.imagePath + 'btnMacroOn.png',
        'Off-Image': this.conf.imagePath + 'btnMacroOff.png',
        'Transition-Image': this.conf.imagePath + 'btnMacroTransition.png',
        'z-Index': 2,
        'Show status text': false,
        'Font-family': 'sans-serif',
        'Font-size': 14,
        'Font-weight': 'bold',
        'Font-color': '000000',
        'Value-Suffix': '%',
        'Update Interval (s)': 3600,
        'Value': 0,
        'Off-Value': 0,
        'On-Value': 100
    };
    this.conf = apply(this.conf, config);
    this.value = this.conf.display['Value'];
    this.create(this.conf)
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.Macro.prototype.create = function(conf){
    this.div = document.createElement('div');
    this.img = document.createElement('img');
    this.stat = document.createElement('div');
    this.layer = document.createElement('img');
    this.div.appendChild(this.img);
    this.div.appendChild(this.stat);
    this.div.appendChild(this.layer);
    return this.div;
}

HAP.Macro.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    this.div.style.position = 'absolute';
    this.div.style.width = this.conf.display['width'] + 'px';
    this.div.style.height = this.conf.display['height'] + 'px';
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
    
    this.img.style.position = 'absolute';
    this.img.style.width = this.conf.display['width'] + 'px';
    this.img.style.height = this.conf.display['height'] + 'px';
    this.img.style.zIndex = this.conf.display['z-Index'];
    this.img.src = this.conf.display['Off-Image'];
    
    this.stat.style.display = 'block';
    this.stat.style.position = 'absolute';
    this.stat.style.width = this.conf.display['width'] + 'px';
    this.stat.style.height = this.conf.display['height'] + 'px';
    this.stat.style.lineHeight = this.conf.display['height'] + 'px';
    this.stat.style.fontFamily = this.conf.display['Font-family'];
    this.stat.style.fontSize = this.conf.display['Font-size'] + 'px';
    this.stat.style.fontWeight = this.conf.display['Font-weight'];
    this.stat.style.color = '#' + this.conf.display['Font-color'];
    this.stat.align = 'center';
    this.stat.style.zIndex = this.conf.display['z-Index'];
    this.stat.innerHTML = this.value + this.conf.display['Value-Suffix'];
    
    if (this.conf.display['Show status text']) {
        this.stat.style.display = 'block';
    }
    else {
        this.stat.style.display = 'none';
    }
    
    this.layer.style.position = 'absolute';
    this.layer.style.width = this.conf.display['width'] + 'px';
    this.layer.style.height = this.conf.display['height'] + 'px';
    this.layer.style.zIndex = this.conf.display['z-Index'];
    this.layer.src = '/static/images/gui/null.gif';
    
    var oThis = this;
    this.attachEvent('onclick', function(){
        if (oThis.value > 0) {
            oThis.setRequest(oThis.conf.display['Off-Value'] || 0);
        }
        else {
            oThis.setRequest(oThis.conf.display['On-Value'] || 100);
        }
    }, viewPortCall);
}


HAP.Macro.prototype.attachEvent = function(event, handler, viewPortCall){
    if (!viewPortCall && event == 'onclick') {
        this.layer.onclick = handler;
    }
}

HAP.Macro.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    this.img.style.width = width + 'px';
    this.stat.style.width = width + 'px';
    this.layer.style.width = width + 'px';
}

HAP.Macro.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    this.img.style.height = height + 'px';
    this.stat.style.height = height + 'px';
    this.stat.style.lineHeight = height + 'px';
    this.layer.style.height = height + 'px';
}

HAP.Macro.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.Macro.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Macro.prototype.setImage = function(img){
    this.img.src = img;
}

HAP.Macro.prototype.setFontSize = function(size){
    this.stat.style.fontSize = size + 'px';
}

HAP.Macro.prototype.setFontWeight = function(weight){
    this.stat.style.fontWeight = weight;
}

HAP.Macro.prototype.setFontColor = function(color){
    this.stat.style.color = color;
}

HAP.Macro.prototype.showStatusText = function(show){
    if (show) {
        this.stat.style.display = 'block';
    }
    else {
        this.stat.style.display = 'none';
    }
}

HAP.Macro.prototype.setRequest = function(value){
    if (this.conf.display['Transition-Image']) {
        this.img.src = this.conf.display['Transition-Image'];
    }
    var oThis = this;
    YAHOO.util.Connect.asyncRequest('get', '/gui/executeMacro/' + this.conf.display['HAP-Macro'], {
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

HAP.Macro.prototype.setValue = function(value){
    if (value > 0) {
        this.img.src = this.conf.display['On-Image'];
    }
    else {
        this.img.src = this.conf.display['Off-Image'];
    }
    this.value = value;
    this.stat.innerHTML = value + this.conf.display['Value-Suffix'];
    return;
}

HAP.MacroImage = function(conf){
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
    img.src = this.conf.imagePath + 'Macro_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
