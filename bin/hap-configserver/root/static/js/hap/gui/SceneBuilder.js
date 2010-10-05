/**
 * @author bendowski
 */
HAP.SceneBuilder = function(){
}

HAP.SceneBuilder.prototype.setScene = function(target){
    document.getElementById('rootDiv').innerHTML = '';
    var oThis = this;
    YAHOO.util.Connect.asyncRequest('GET', '/gui/' + target, {
        success: function(o){
            response = YAHOO.lang.JSON.parse(o.responseText);
            objects = {};
            for (var obj in response.data.objects) {
                var cObj = response.data.objects[obj];
                objects[cObj.id] = classFactory(cObj.type, cObj);
            }
            var offset = {};
            if (response.data.centerX || response.data.centerY) {
                offset = oThis.getCenterOffset();
            }
            for (var obj in objects) {
                if (response.data.centerX) {
                    objects[obj].setX(objects[obj].conf.display['x'] + offset.x);
                }
                if (response.data.centerY) {
                    objects[obj].setY(objects[obj].conf.display['y'] + offset.y);
                }
                document.getElementById('rootDiv').appendChild(objects[obj].div);
            }
            oThis.refresh();
        }
    });
}

HAP.SceneBuilder.prototype.getCenterOffset = function(){
    var minX = [];
    var maxX = []
    var minY = [];
    var maxY = [];
    var i = 0;
    for (var obj in objects) {
        minX[i] = objects[obj].conf.display['x'];
        maxX[i] = objects[obj].conf.display['x'] + objects[obj].conf.display['width'];
        minY[i] = objects[obj].conf.display['y'];
        maxY[i] = objects[obj].conf.display['y'] + objects[obj].conf.display['height'];
        i++;
    }
    numSort = function(a, b){
        return a - b
    };
    minX.sort(numSort);
    maxX.sort(numSort);
    minY.sort(numSort);
    maxY.sort(numSort);
    var x = ((YAHOO.util.Dom.getViewportWidth() - (maxX[i - 1] - minX[0])) / 2);
    var y = ((YAHOO.util.Dom.getViewportHeight() - (maxY[i - 1] - minY[0])) / 2);
    return {
        x: x,
        y: y
    };
}

HAP.SceneBuilder.prototype.refresh = function(){
    var time = new Date().getTime();
    var request = new Array();
    for (var obj in objects) {
        var cObj = objects[obj];
        if (objects[obj].conf.display['Update Interval (s)'] && (!objects[obj].time || objects[obj].time <= time)) {
            var tmpObj = {};
            tmpObj.id = objects[obj].conf.id;
            tmpObj.type = objects[obj].conf.type;
            if (objects[obj].conf.type == 'HAP.Chart' || objects[obj].conf.type == 'HAP.Chart5') {
              tmpObj.startOffset = objects[obj].conf.display['Start-Offset (m)'];
            }
            tmpObj.module = objects[obj].conf.display['HAP-Module'];
            tmpObj.address = objects[obj].conf.display['HAP-Device'];
            request.push(tmpObj);
            objects[obj].time = time + objects[obj].conf.display['Update Interval (s)'] * 1000;
        }
    }
    if (request.length > 0) {
        YAHOO.util.Connect.asyncRequest('POST', '/gui/refresh', {
            success: function(o){
                var response = YAHOO.lang.JSON.parse(o.responseText);
                for (var obj in response.data) {
                    var cObj = response.data[obj];
                    objects[cObj.id].setValue(cObj.value);
                }
            }
        }, 'data=' + YAHOO.lang.JSON.stringify(request));
    }
}
