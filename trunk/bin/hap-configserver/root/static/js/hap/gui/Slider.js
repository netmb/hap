/**
 * @author bendowski
 */
HAP.Slider = function(config, viewPortCall){
    this.conf = {};
    this.conf.id = 0;
    this.conf.type = 'HAP.Slider';
    this.conf.imagePath = '/static/images/gui/';
    this.conf.display = {
        'HAP-Module': 0,
        'HAP-Device': 0,
        x: 0,
        y: 0,
        height: 364,
        width: 40,
        'Button X-Offset': -50,
        'Button Y-Offset': -50,
        'Button Height': 48,
        'Button Width': 48,
        'Button On-Image': this.conf.imagePath + 'ledgreen.png',
        'Button Off-Image': this.conf.imagePath + 'ledred.png',
        'Button Transition-Image': this.conf.imagePath + 'ledyellow.png',
        'Button z-Index': 2,
        'Button Show status text': true,
        'Button Font-size': 14,
        'Button Font-weight': 'bold',
        'Button Font-color': '000000',
        'Button Font-family': 'sans-serif',
        'Collapsed on Startup': true,
        'Slider Rotate': false,
        'Slider Invers': false,
        'Slider Image': this.conf.imagePath + 'slider_light_40x364.gif',
        'Slider Thumb-Image': this.conf.imagePath + 'sArrow_33px.gif',
        'Slider Thumb X-Offset': 40,
        'Slider Thumb Y-Offset': 364,
        'Slider Increment (px)': 33,
        'Slider Rest-Time (ms)': 500,
        'Slider min. Value': 0,
        'Slider max. Value': 100,
        'Slider hide after set': true,
        'Value Font-size': 13,
        'Value Font-align': 'center',
        'Value Font-VAlign': true,
        'Value Font-weight': 'bold',
        'Value Font-color': '000000',
        'Value Font-family': 'sans-serif',
        'Value X-Offset': 0,
        'Value Y-Offset': -20,
        'Value Width': 40,
        'Value Height': 20,
        'Value Background': 'FFFFFF',
        'Value Suffix': '%',
        'Value Visible': true,
        'z-Index': 3,
        'Update Interval (s)': 10,
        'Value': 0
    };
    this.conf = apply(this.conf, config);
    this.value = this.conf.display['Value'];
    this.create(this.conf);
    this.setConfig(this.conf, viewPortCall);
    return this;
}

HAP.Slider.prototype.create = function(conf){
    this.div = document.createElement('div');
    this.divSlider = document.createElement('div');
    this.divSliderThumb = document.createElement('div');
    this.imgSliderThumb = document.createElement('img');
    this.divValue = document.createElement('div');
    this.toggleButton = new HAP.Switch();
    
    this.div.appendChild(this.divSlider);
    this.divSliderThumb.appendChild(this.imgSliderThumb);
    this.divSlider.appendChild(this.divSliderThumb);
    this.div.appendChild(this.divValue);
    this.div.appendChild(this.toggleButton.div);
    
    return this.div;
}

HAP.Slider.prototype.setConfig = function(conf, viewPortCall){
    this.conf = conf;
    
    this.div.id = 'slider/' + this.conf.id + '/wrapper';
    this.div.style.position = 'absolute';
    if (!viewPortCall) {
        this.div.style.left = this.conf.display['x'] + 'px';
        this.div.style.top = this.conf.display['y'] + 'px';
    }
    if (viewPortCall) {
        this.div.style.width = this.conf.display['width'] + 'px';
        this.div.style.height = this.conf.display['height'] + 'px';
    }
    this.div.style.zIndex = this.conf.display['z-Index'];
    
    this.divSlider.id = 'slider/' + this.conf.id;
    this.divSlider.style.position = 'absolute';
    this.divSlider.style.zIndex = this.conf.display['z-Index'];
    //if (this.conf.display['Collapsed on Startup']) {
    //  this.divSlider.style.display = 'none';
    //}    
    this.divSlider.style.backgroundImage = 'url(' + this.conf.display['Slider Image'] + ')';
    this.divSlider.style.width = this.conf.display['width'] + 'px';
    this.divSlider.style.height = this.conf.display['height'] + 'px';
    
    this.divSliderThumb.id = 'slider/' + this.conf.id + '/thumb';
    this.divSliderThumb.style.position = 'absolute';
    this.divSliderThumb.style.left = this.conf.display['Slider Thumb X-Offset'] + 'px';
    // thumb image is loaded at the end of this function, cause the thumb must be loaded at all, before some calculations can be done.
    if (this.conf.display['Value Visible']) {
        this.divValue.style.display = 'block';
    }
    else {
        this.divValue.style.display = 'none';
    }
    this.divValue.id = 'slider/' + this.conf.id + '-value';
    this.divValue.style.position = 'absolute';
    if (this.conf.display['Value Font-VAlign']) {
        this.divValue.style.lineHeight = this.conf.display['Value Height'] + 'px';
    }
    else {
        this.divValue.style.lineHeight = null;
    }
    this.divValue.style.left = this.conf.display['Value X-Offset'] + 'px';
    this.divValue.style.top = this.conf.display['Value Y-Offset'] + 'px';
    this.divValue.style.width = this.conf.display['Value Width'] + 'px';
    this.divValue.style.height = this.conf.display['Value Height'] + 'px';
    if (this.conf.display['Value Background']) {
        this.divValue.style.backgroundColor = '#' + this.conf.display['Value Background'];
    }
    else {
        this.divValue.style.backgroundColor = null;
    }
    this.divValue.style.fontSize = this.conf.display['Value Font-size'] + 'px';
    this.divValue.style.textAlign = this.conf.display['Value Font-align'];
    this.divValue.style.fontWeight = this.conf.display['Value Font-weight'];
    this.divValue.style.color = '#' + this.conf.display['Value Font-color'];
    this.divValue.style.fontFamily = this.conf.display['Value Font-family'];
    this.divValue.innerHTML = this.conf.display['Value'] + this.conf.display['Value Suffix'];
    
    this.toggleButton.setConfig({
        id: 'slider/' + this.conf.id + '-toggle',
        display: {
            x: this.conf.display['Button X-Offset'],
            y: this.conf.display['Button Y-Offset'],
            width: this.conf.display['Button Width'],
            height: this.conf.display['Button Height'],
            'Off-Image': this.conf.display['Button Off-Image'],
            'On-Image': this.conf.display['Button On-Image'],
            'Transition-Image': this.conf.display['Button Transition-Image'],
            'z-Index': this.conf.display['Button z-Index'],
            'Show status text': this.conf.display['Button Show status text'],
            'Font-size': this.conf.display['Button Font-size'],
            'Font-weight': this.conf.display['Button Font-weight'],
            'Font-color': this.conf.display['Button Font-color'],
            'Font-family': this.conf.display['Button Font-family'],
            'Value-Suffix': this.conf.display['Value Suffix']
        }
    }, false);
    var oThis = this;
    this.toggleButton.attachEvent('onclick', function(){
        oThis.toggleView();
    });
    
    var thumb = new Image();
    thumb.src = this.conf.display['Slider Thumb-Image'];
    thumb.onload = function(){
        oThis.thumbHeight = thumb.height;
        oThis.thumbWidth = thumb.width;
        oThis.divSliderThumb.style.top = oThis.conf.display['Slider Thumb Y-Offset'] - oThis.thumbHeight + 'px';
        oThis.imgSliderThumb.src = oThis.conf.display['Slider Thumb-Image'];
        if (!viewPortCall) {
            oThis.attachSliderLogic();
        }
    }
}

HAP.Slider.prototype.attachSliderLogic = function(){
    // Base calculations
    var upPixel;
    var leftPixel;
    var downPixel;
    var rightPixel;
    var factor;
    if (this.conf.display['Slider Invers']) { // from top to bottom  or right to left
        upPixel = 0;
        leftPixel = this.conf.display['width'] - this.thumbWidth;
        downPixel = this.conf.display['height'] - this.thumbHeight;
        rightPixel = 0;
        factor = (this.conf.display['Slider max. Value'] - this.conf.display['Slider min. Value']) / (upPixel + downPixel);
        factorHoriz = -1 * (this.conf.display['Slider max. Value'] - this.conf.display['Slider min. Value']) / (leftPixel + rightPixel);
    }
    else {
        upPixel = this.conf.display['height'] - this.thumbHeight;
        leftPixel = 0;
        downPixel = 0;
        rightPixel = this.conf.display['width'] - this.thumbWidth;
        factor = -1 * ((this.conf.display['Slider max. Value'] - this.conf.display['Slider min. Value']) / (upPixel + downPixel));
        factorHoriz = (this.conf.display['Slider max. Value'] - this.conf.display['Slider min. Value']) / (leftPixel + rightPixel);
    }
    
    var oThis = this;
    if (this.conf.display['Slider Rotate']) {
        YAHOO.util.Event.onDOMReady(function(){
            oThis.slider = YAHOO.widget.Slider.getHorizSlider('slider/' + oThis.conf.id, 'slider/' + oThis.conf.id + '/thumb', leftPixel, rightPixel, oThis.conf.display['Slider Increment (px)']);
            oThis.slider.factor = factorHoriz;
            oThis.slider.subscribe('change', function(){
                var trueValue = Math.round(this.getValue() * factorHoriz) + oThis.conf.display['Slider min. Value'];
                clearTimeout(this.restSchedule);
                this.restSchedule = setTimeout(function(){
                    oThis.setRequest(trueValue)
                }, oThis.conf.display['Slider Rest-Time (ms)']);
            });
            oThis.slider.onAvailable = function(){
                oThis.toggleView(oThis.conf.display['Collapsed on Startup']);
            }
            
        });
    }
    else {
        YAHOO.util.Event.onDOMReady(function(){
            oThis.slider = YAHOO.widget.Slider.getVertSlider('slider/' + oThis.conf.id, 'slider/' + oThis.conf.id + '/thumb', upPixel, downPixel, oThis.conf.display['Slider Increment (px)']);
            oThis.slider.factor = factor;
            oThis.slider.subscribe('change', function(){
                var trueValue = Math.round(this.getValue() * factor) + oThis.conf.display['Slider min. Value'];
                clearTimeout(this.restSchedule);
                this.restSchedule = setTimeout(function(){
                    oThis.setRequest(trueValue)
                }, oThis.conf.display['Slider Rest-Time (ms)']);
            });
            oThis.slider.onAvailable = function(){
                oThis.toggleView(oThis.conf.display['Collapsed on Startup']);
            }
        });
    }
}

HAP.Slider.prototype.toggleView = function(visible){
    if (visible != null) {
        this.visible = visible;
    }
    if (this.visible) {
        this.divSlider.style.display = 'none';
        this.divValue.style.display = 'none';
        this.visible = false;
    }
    else {
        this.divSlider.style.display = 'block';
        if (this.slider) {
            this.slider.setValue((this.value / this.slider.factor) - this.conf.display['Slider min. Value'], false, false, true);
        }
        if (this.conf.display['Value Visible']) {
            this.divValue.style.display = 'block';
        }
        this.visible = true;
    }
}

HAP.Slider.prototype.setWidth = function(width){
    this.conf.display['width'] = width;
    this.divSlider.style.width = width + 'px';
}
HAP.Slider.prototype.setHeight = function(height){
    this.conf.display['height'] = height;
    this.divSlider.style.height = height + 'px';
}

HAP.Slider.prototype.setX = function(x, viewPortCall){
    this.conf.display['x'] = x;
    if (!viewPortCall) {
        this.div.style.left = x + 'px';
    }
}
HAP.Slider.prototype.setY = function(y, viewPortCall){
    this.conf.display['y'] = y;
    if (!viewPortCall) {
        this.div.style.top = y + 'px';
    }
}

HAP.Slider.prototype.setRequest = function(value){
    if (this.conf.display['Button Transition-Image']) {
        this.toggleButton.img.src = this.conf.display['Button Transition-Image'];
    }
    var oThis = this;
    YAHOO.util.Connect.asyncRequest('get', '/gui/setDevice/' + this.conf.display['HAP-Module'] + '/' + this.conf.display['HAP-Device'] + '/' + value, {
        success: function(o){
            if (YAHOO.lang.JSON.isValid(o.responseText)) {
                var response = YAHOO.lang.JSON.parse(o.responseText);
                if (response.success) {
                    oThis.setValue(response.data.value);
                    if (oThis.conf.display['Slider hide after set']) {
                        oThis.toggleView(true);
                    }
                }
                else {
                    oThis.setValue(oThis.value); // rest Slider to old values
                }
            }
            else {
                document.getElementById('rootDiv').innerHTML = o.responseText;
            }
        }
    });
}

HAP.Slider.prototype.setValue = function(value){
    this.divValue.innerHTML = value + this.conf.display['Value Suffix'];
    this.toggleButton.setValue(value);
    if (this.slider && this.visible) {
        this.slider.setValue((value / this.slider.factor) - this.conf.display['Slider min. Value'], false, false, true);
    }
    this.value = value;
}

HAP.SliderImage = function(conf){
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
    img.src = this.conf.imagePath + 'slider_60x60.png';
    img.style.textAlign = 'center'; // required for d&d
    div.appendChild(img);
    
    var textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center'; // required for d&d
    textDiv.innerHTML = this.conf.name;
    div.appendChild(textDiv);
    
    return div;
}
