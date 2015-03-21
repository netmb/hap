
HAP.Container = function (config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.Container';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        x: 0,
        y: 0,
        height: 60,
        width: 60,
        //Image: this.conf.imagePath + 'ImageLayer_60x60.png',
        'z-Index': 2,
        'Inner-HTML': '<img width="100%" height="100%" src="' + this.conf.imagePath + 'Container.png" alt="container-placeholder">',
        'Update Interval (s)': 10
    };
    this.conf = apply(this.conf, config);
    this.create(this.conf);
    this.setConfig(this.conf, viewPortCall);
    this.setInnerHtml(this.conf.display['Inner-HTML']);
    return this;
}

HAP.Container.prototype.create = function(conf){
    this.div = document.createElement('div');
    return this.div;
}

HAP.Container.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    this.div.style.position = 'absolute';
    this.div.style.width = this.conf.display['width'] + 'px';
    this.div.style.height = this.conf.display['height'] + 'px';
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
    this.setInnerHtml(this.conf.display['Inner-HTML']);
}

HAP.Container.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.div.style.width = width + 'px';
}

HAP.Container.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.div.style.height = height + 'px';
}

HAP.Container.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}

HAP.Container.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Container.prototype.setInnerHtml = function(value){
    this.div.innerHTML = value;
    return;
}

HAP.ContainerImage = function(conf){
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
    textDiv.style.fontSize = '9px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
