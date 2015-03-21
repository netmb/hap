/**
 * @author bendowski
 */
HAP.Trigger = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.Trigger';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        'HAP-Module': 0,
        'HAP-TriggerDevices': 0,
        'Trigger': 0,
        x: 0,
        y: 0,
        height: 60,
        width: 60,
        'On-Image': this.conf.imagePath + 'btnTriggerOn.png',
        'Off-Image': this.conf.imagePath + 'btnTriggerOff.png',
        'Transition-Image': this.conf.imagePath + 'btnTriggerTransition.png',
        'z-Index': 2,
        'Show status text': false,
        'Font-family': 'sans-serif',
        'Font-size': 14,
        'Font-weight': 'bold',
        'Font-color': '000000',
        'Value-Suffix': '%',
        'Update Interval (s)': 3600,
        'Value': 0
    };
    this.conf = apply(this.conf, config);
    this.value = this.conf.display['Value'];
    this.create(this.conf)
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.Trigger.prototype.create = function(conf){
    this.div = document.createElement('div');
    this.img = document.createElement('img');
    this.stat = document.createElement('div');
    this.layer = document.createElement('img');
    this.div.appendChild(this.img);
    this.div.appendChild(this.stat);
    this.div.appendChild(this.layer);
    return this.div;
}

HAP.Trigger.prototype.setConfig = function(conf, viewPortCall){
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


HAP.Trigger.prototype.attachEvent = function(event, handler, viewPortCall){
    if (!viewPortCall && event == 'onclick') {
        this.layer.onclick = handler;
    }
}

HAP.Trigger.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    this.img.style.width = width + 'px';
    this.stat.style.width = width + 'px';
    this.layer.style.width = width + 'px';
}

HAP.Trigger.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    this.img.style.height = height + 'px';
    this.stat.style.height = height + 'px';
    this.stat.style.lineHeight = height + 'px';
    this.layer.style.height = height + 'px';
}

HAP.Trigger.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.Trigger.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Trigger.prototype.setImage = function(img){
    this.img.src = img;
}

HAP.Trigger.prototype.setFontSize = function(size){
    this.stat.style.fontSize = size + 'px';
}

HAP.Trigger.prototype.setFontWeight = function(weight){
    this.stat.style.fontWeight = weight;
}

HAP.Trigger.prototype.setFontColor = function(color){
    this.stat.style.color = color;
}

HAP.Trigger.prototype.showStatusText = function(show){
    if (show) {
        this.stat.style.display = 'block';
    }
    else {
        this.stat.style.display = 'none';
    }
}

HAP.Trigger.prototype.setRequest = function(value){
    if (this.conf.display['Transition-Image']) {
        this.img.src = this.conf.display['Transition-Image'];
    }
    var oThis = this;
    YAHOO.util.Connect.asyncRequest('get', '/gui/modifyTrigger/' + this.conf.display['HAP-Module'] + '/' + this.conf.display['HAP-TriggerDevices'] + '/'+ this.conf.display['Trigger'] + '/' + this.conf.display['Value'], {
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

HAP.Trigger.prototype.setValue = function(value){
    if (value > (this.value-0.0625) && value < (this.value+0.0625)) {
        this.img.src = this.conf.display['On-Image'];
        this.value = value;
        this.stat.innerHTML = value + this.conf.display['Value-Suffix'];
    }
    else {
        this.img.src = this.conf.display['Off-Image'];
    }
    return;
}

HAP.TriggerImage = function(conf){
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
    img.src = this.conf.imagePath + 'Trigger_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
