/**
 * @author Ben
 */

HAP.LCDObjectTree = function(){
    this.id = 'lcdObjectTree';
    HAP.LCDObjectTree.superclass.constructor.call(this);
}

Ext.extend(HAP.LCDObjectTree, Ext.Panel, {
    onRender: function(ct, pos){
        HAP.LCDObjectTree.superclass.onRender.call(this, ct, pos);
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'GET',
            url: '/lcdgui/getAllObjects'
        });
        conn.on('requestcomplete', function(sender, param){
            var response = Ext.util.JSON.decode(param.responseText);
            if (response.success) {
                var x;
                var y;
                var size = response.data.length;
                for (var i = 0; i < size; i++) {
                    if (i % 2 == 0) {
                        x = 10;
                    }
                    else {
                        x = 100;
                    }
                    y = parseInt(i / 2) * 70 + 10;
                    var img;
                    switch (response.data[i].type) {
                        case 1: // menu
                            className = 'HAP.LCDMenu';
                            img = new HAP.LCDMenuImage({
                                id: response.data[i].id,
                                name: response.data[i].shortName,
                                inPorts: response.data[i].inPorts,
                                outPorts: response.data[i].outPorts,
                                height: 60,
                                width: 68,
                                top: y,
                                left: x
                            });
                            break;
                        case 0: // menu-item
                            className = 'HAP.LCDMenuItem';
                            img = new HAP.LCDMenuItemImage({
                                id: response.data[i].id,
                                name: response.data[i].shortName,
                                inPorts: response.data[i].inPorts,
                                outPorts: response.data[i].outPorts,
                                height: 60,
                                width: 68,
                                top: y,
                                left: x
                            });
                            break;
                        default:
                            className = 'HAP.LCDObject';
                            img = new HAP.LCDObjectImage({
                                id: response.data[i].id,
                                name: response.data[i].shortName,
                                inPorts: response.data[i].inPorts,
                                outPorts: response.data[i].outPorts,
                                height: 20,
                                width: 68,
                                top: y + 20,
                                left: x
                            });
                    }
                    ct.appendChild(img);
                    
                    var dragsource = new Ext.dd.DragSource(img.id, {
                        ddGroup: 'TreeDD',
                        dragData: {
                            className: className,
                            conf: {
                                id: response.data[i].id,
                                type: response.data[i].type,
                                name: response.data[i].shortName,
                                inPorts: response.data[i].inPorts,
                                outPorts: response.data[i].outPorts,
                                display: response.data[i].display
                            }
                        }
                    });
                    
                }
            }
        });
    }
});



