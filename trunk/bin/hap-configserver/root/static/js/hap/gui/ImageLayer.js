HAP.ImageLayer = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.ImageLayer';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        x: 0,
        y: 0,
        height: 60,
        width: 60,
        'Image': this.conf.imagePath + 'ImageLayer_60x60.png',
        'z-Index': 2,
        'Font-size': 14,
        'Font-weight': 'bold',
        'Font-color': '000000',
        'Font-family': 'sans-serif',
        'Show text': true,
        'Text': '',
        'Text-Align': 'center',
        'Text-VAlign': true,
        'Target View': '',
        'Target Scene': '',
        'Target External': '',
        'Target Frame': '_self'
    };
    this.conf = apply(this.conf, config);
    this.create(this.conf);
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.ImageLayer.prototype.create = function(conf){
    this.div = document.createElement('div');
    this.img = document.createElement('img');
    this.text = document.createElement('div');
    this.layer = document.createElement('img');
    this.div.appendChild(this.img);
    this.div.appendChild(this.text);
    this.div.appendChild(this.layer);
    return this.div;
}

HAP.ImageLayer.prototype.setConfig = function(conf, viewPortCall){
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
    if (this.conf.display['Image']) {
        this.img.src = this.conf.display['Image'];
    }
    else {
        this.img.src = this.conf.imagePath + 'null.gif';
    }
    
    this.text.style.position = 'absolute';
    this.text.style.width = this.conf.display['width'] + 'px';
    this.text.style.height = this.conf.display['height'] + 'px';
    if (this.conf.display['Text-VAlign']) {
        this.text.style.lineHeight = this.conf.display['height'] + 'px';
    }
    else {
        this.text.style.lineHeight = null;
    }
    this.text.style.fontSize = this.conf.display['Font-size'] + 'px';
    this.text.style.fontWeight = this.conf.display['Font-weight'];
    this.text.style.color = '#' + this.conf.display['Font-color'];
    this.text.style.fontFamily = this.conf.display['Font-family'];
    this.text.align = this.conf.display['Text-Align'];
    this.text.style.zIndex = this.conf.display['z-Index'];
    this.text.innerHTML = this.conf.display['Text'];
    
    if (this.conf.display['Show text']) {
        this.text.style.display = 'block';
    }
    else {
        this.text.style.display = 'none';
    }
    this.layer.style.position = 'absolute';
    this.layer.style.width = this.conf.display['width'] + 'px';
    this.layer.style.height = this.conf.display['height'] + 'px';
    this.layer.style.zIndex = this.conf.display['z-Index'];
    this.layer.src = this.conf.imagePath + 'null.gif';
    
    if (this.conf.display['Target View']) {
        var oThis = this;
        this.layer.onclick = function(){
            sceneBuilder.setScene('getView/' + oThis.conf.display['Target View']);
        }
    }
    else {
        if (this.conf.display['Target Scene']) {
            var oThis = this;
            this.layer.onclick = function(){
                sceneBuilder.setScene('getScene/' + oThis.conf.display['Target Scene']);
            }
        }
        else {
            if (this.conf.display['Target External']) {
                var lnk = this.conf.display['Target External'];
                var target = '_blank';
                if (this.conf.display['Target Frame']) {
                    target = this.conf.display['Target Frame'];
                }
                this.layer.onclick = function(){
                    window.open(lnk, target);
                }
            }
        }
    }
}

HAP.ImageLayer.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
    this.img.style.width = width + 'px';
    this.text.style.width = width + 'px';
    this.layer.style.width = width + 'px';
}

HAP.ImageLayer.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
    this.img.style.height = height + 'px';
    this.text.style.height = height + 'px';
    if (this.conf.display['Text-VAlign']) {
        this.text.style.lineHeight = height + 'px';
    }
    this.layer.style.height = height + 'px';
}

HAP.ImageLayer.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.ImageLayer.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.ImageLayer.prototype.setImage = function(img){
    this.img.src = img;
}

HAP.ImageLayer.prototype.setFontSize = function(size){
    this.text.style.fontSize = size + 'px';
}

HAP.ImageLayer.prototype.setFontWeight = function(weight){
    this.text.style.fontWeight = weight;
}

HAP.ImageLayer.prototype.setFontColor = function(color){
    this.text.style.color = color;
}

HAP.ImageLayer.prototype.showtextusText = function(bool){
    if (bool) {
        this.text.style.display = 'block';
    }
    else {
        this.text.style.display = 'none';
    }
}

HAP.ImageLayerImage = function(conf){
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
    img.src = this.conf.imagePath + 'ImageLayer_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
