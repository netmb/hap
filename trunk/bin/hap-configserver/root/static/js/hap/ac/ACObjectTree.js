/**
 * @author bendowski
 */
HAP.ACObjectTree = function(){
    this.id = 'acObjectTree';
    HAP.ACObjectTree.superclass.constructor.call(this);
}

Ext.extend(HAP.ACObjectTree, Ext.Panel, {
    onRender: function(ct, pos){
        HAP.ACObjectTree.superclass.onRender.call(this, ct, pos);
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'GET',
            url: '/autonomouscontrol/getAllObjects'
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
                    
                    var img = new HAP.ACObjectImage({
                        id: response.data[i].id,
                        name: response.data[i].shortName,
                        inPorts: response.data[i].inPorts,
                        outPorts: response.data[i].outPorts,
                        height: 60,
                        width: 68,
                        top: y,
                        left: x
                    });
                    ct.appendChild(img);
                     
                    var className = 'HAP.ACObject';
                    if (response.data[i].type == 256) { // its a comment
                      className = 'HAP.ACObjectAnnotate';
                    }
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



