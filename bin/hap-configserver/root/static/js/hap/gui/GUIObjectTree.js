/**
 * @author bendowski
 */
HAP.GUIObjectTree = function(){
    this.id = 'GUIObjectTree';
    HAP.GUIObjectTree.superclass.constructor.call(this);
}

Ext.extend(HAP.GUIObjectTree, Ext.Panel, {
    onRender: function(ct, pos){
        HAP.GUIObjectTree.superclass.onRender.call(this, ct, pos);
        var conn = new Ext.data.Connection();
        conn.request({
            method: 'GET',
            url: '/gui/getAllObjects'
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
                    y = parseInt(i / 2) * 80 + 10;
                    
                    var img = classFactory(response.data[i].type + "Image", {
                        id: response.data[i].id,
                        name: response.data[i].name,
                        height: 60,
                        width: 60,
                        top: y,
                        left: x
                    });
                    ct.appendChild(img);
                    if (response.data[i].type) {
                      var dragsource = new Ext.dd.DragSource(img.id, {
                        ddGroup: 'TreeDD',
                        dragData: {
                          type: response.data[i].type
                        }
                      });
                    }
                }
            }
        });
    }
});
