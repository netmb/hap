HAP.ACObject = function(config){
    this.conf = {
        'height': 60,
        'width': 60,
        'inPorts': 0,
        'outPorts': 0,
        'name': '',
        'calcVar': 0,
        'simValue': 0,
        'display': {}
    };
    this.conf = apply(this.conf, config);
    draw2d.ImageFigure.call(this, '/static/images/ac/' + 'acObject.png');
    this.outputPort = null;
    this.setDimension(this.conf.width, this.conf.height);
    return this;
}

HAP.ACObject.prototype = new draw2d.ImageFigure;
HAP.ACObject.prototype.type = 'HAP.ACObject';
HAP.ACObject.prototype.setWorkflow = function(workflow){
    draw2d.ImageFigure.prototype.setWorkflow.call(this, workflow);
    if (workflow != null && this.outputPort == null) {
        for (var i = 1; i <= this.conf.inPorts; i++) {
            var inP = new HAP.ACInPort();
            inP.setWorkflow(workflow);
            inP.setName('inPort' + i);
            this.addPort(inP, 0, this.conf.height / (this.conf.inPorts + 1) * i);
        }
        for (var i = 1; i <= this.conf.outPorts; i++) {
            var outP = new HAP.ACOutPort();
            outP.setWorkflow(workflow);
            outP.setName('outPort' + i);
            this.addPort(outP, this.conf.width, this.conf.height / (this.conf.outPorts + 1) * i);
        }
        this.setText(this.conf.display.Label);
    }
}

HAP.ACObject.prototype.createHTMLElement = function(){
    var item = draw2d.Node.prototype.createHTMLElement.call(this);
    item.style.width = this.conf.width + 'px';
    item.style.height = this.conf.height + 'px';
    item.style.margin = '0px';
    item.style.padding = '0px';
    item.style.border = '0px';
    if (this.url != null) {
        item.style.backgroundImage = 'url(' + this.url + ')';
    }
    else {
        item.style.backgroundImage = '';
    }
    textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center';
    textDiv.style.width = this.conf.width - 7 + 'px';
    textDiv.style.paddingLeft = 4 + 'px';
    textDiv.innerHTML = this.conf.name;
    textDiv.style.paddingTop = 10 + 'px';
    item.appendChild(textDiv);
    
    this.labelDiv = document.createElement('div');
    this.labelDiv.style.position = 'absolute';
    this.labelDiv.style.top = this.conf.height + 2 + 'px';
    this.labelDiv.style.left = -20 + 'px';
    this.labelDiv.style.textAlign = 'center';
    this.labelDiv.style.fontSize = '10px';
    this.labelDiv.style.width = this.conf.width + 40 + 'px';
    this.labelDiv.style.height = 12 + 'px';
    this.labelDiv.innerHTML = '';
    item.appendChild(this.labelDiv);
    
    this.simValue = document.createElement('div');
    this.simValue.style.position = 'absolute';
    this.simValue.style.top = this.conf.height / 2 + 'px';
    this.simValue.style.left = this.conf.width + 4 + 'px';
    this.simValue.style.textAlign = 'left';
    this.simValue.style.fontSize = '10px';
    this.simValue.style.width = 40 + 'px';
    this.simValue.style.height = 12 + 'px';
    this.simValue.innerHTML = '';
    item.appendChild(this.simValue);
    
    this.disableTextSelection(this.labelDiv);
    this.disableTextSelection(textDiv);
    
    return item;
}

HAP.ACObject.prototype.setText = function(text){
    this.labelDiv.innerHTML = text;
}

HAP.ACObject.prototype.setSimValue = function(calcVar, simValue, simText){
    if ((this.conf.type == 121 || this.conf.type == 122) && simText != "") {
        this.simValue.innerHTML = simValue + " [" + simText + "]";
        this.simValue.style.width = 120 + 'px';
    }
    else {
        this.simValue.innerHTML = simValue;
        this.simValue.style.width = 40 + 'px';
    }
    this.conf.calcVar = calcVar;
    this.conf.simValue = simValue;
    var t = this.conf.type;
    if (calcVar > 0 && (t == 32 || t == 33 || t == 34 || t == 35 || t == 63 || t == 112 || t == 113 || t == 114 || t == 115 || t == 120 || t == 121 || t == 122 || t == 127)) {
        this.setImage('/static/images/ac/acObjectGreen.png');
    }
    if (calcVar == 0 && (t == 32 || t == 33 || t == 34 || t == 35 || t == 63 || t == 112 || t == 113 || t == 114 || t == 115 || t == 120 || t == 121 || t == 122 || t == 127)) {
        this.setImage('/static/images/ac/acObject.png');
    }
}

HAP.ACObject.prototype.getContextMenu = function(){
    var menu = new draw2d.Menu();
    var figure = this;
    menu.appendMenuItem(new draw2d.MenuItem('Delete', null, function(){
        figure.getWorkflow().removeFigure(figure);
    }));
    return menu;
}

HAP.ACObject.prototype.onDoubleClick = function(){
    oThis = this;
    var tmp = oThis.getWorkflow().canvasId.split('/');
    if (this.conf.type >= 32 && this.conf.type <= 35) {
        if (this.conf.calcVar > 0) {
            this.conf.calcVar = 0;
            this.setImage('/static/images/ac/acObject.png');
        }
        else {
            this.conf.calcVar = 1;
            this.setImage('/static/images/ac/acObjectGreen.png');
        }
        if (Ext.getCmp(tmp[0] + '/' + tmp[1] + '/checkDirectSimulation').getValue()) {
            Ext.getCmp(tmp[0] + '/' + tmp[1] + '/btnSimulate').handler.call();
        }
    }
    else 
        if (this.conf.type == 56 || this.conf.type == 60 || this.conf.type == 61) {
            var pw = new HAP.ACPopupWindow(this.conf.simValue, function(value){
                oThis.setSimValue(oThis.conf.calcVar, value);
                var tmp = oThis.getWorkflow().canvasId.split('/');
                if (Ext.getCmp(tmp[0] + '/' + tmp[1] + '/checkDirectSimulation').getValue()) {
                    Ext.getCmp(tmp[0] + '/' + tmp[1] + '/btnSimulate').handler.call();
                }
            });
            pw.show();
        }
        else 
            if (this.conf.type >= 112 && this.conf.type <= 115 && this.conf.calcVar > 0) {
                this.conf.calcVar = 0;
                this.setImage('/static/images/ac/acObject.png');
                if (Ext.getCmp(tmp[0] + '/' + tmp[1] + '/checkDirectSimulation').getValue()) {
                    Ext.getCmp(tmp[0] + '/' + tmp[1] + '/btnSimulate').handler.call();
                }
            }
}

HAP.ACObjectImage = function(conf){ // for tree view
    this.conf = conf;
    var div = document.createElement('div');
    div.id = this.conf.id;
    div.style.height = this.conf.height + 'px';
    div.style.width = this.conf.width + 'px';
    div.style.top = this.conf.top + 'px';
    div.style.left = this.conf.left + 'px';
    div.style.position = 'absolute';
    div.style.backgroundImage = 'url(/static/images/ac/' + this.conf.inPorts + '_' + this.conf.outPorts + '.png)';
    //div.style.backgroundColor = '#ff0000';
    textDiv = document.createElement('div');
    textDiv.style.fontSize = '10px';
    textDiv.style.textAlign = 'center';
    textDiv.style.width = this.conf.width - 15 + 'px';
    textDiv.innerHTML = this.conf.name;
    //textDiv.style.backgroundColor = '#00ff00';
    textDiv.style.paddingLeft = 8 + 'px';
    textDiv.style.paddingTop = 10 + 'px';
    div.appendChild(textDiv);
    return div;
}

HAP.ACObjectAnnotate = function(conf){
    this.conf = conf;
    draw2d.Annotation.call(this, this.conf.display.Label);
    this.setDimension(300, 40);
    this.setBackgroundColor(new draw2d.Color(255, 255, 255));
    return this;
}

HAP.ACObjectAnnotate.prototype = new draw2d.Annotation();

HAP.ACObjectAnnotate.prototype.getContextMenu = function(){
    var menu = new draw2d.Menu();
    var figure = this;
    menu.appendMenuItem(new draw2d.MenuItem('Delete', null, function(){
        figure.getWorkflow().removeFigure(figure);
    }));
    return menu;
}

HAP.ACObjectAnnotate.prototype.onDoubleClick = function(){
    return;
}
