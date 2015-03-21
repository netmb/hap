var HAP = {}; // Namespace
var objects = {};

classFactory = function(className, arg0, arg1){
    var subClass = className.split('.')[1];
    if (!arg1) {
      return new HAP[subClass](arg0);
    }
    else {
      return new HAP[subClass](arg0, arg1);
    }
}

apply = function(rcv, config){
    if (rcv && config && typeof config == 'object') {
        for (var p in config) {
            if (p == "display") {
              //rcv.display = {};
              for (var dp in config.display) {
                rcv.display[dp] = config.display[dp];
              }
            }
            else {
              rcv[p] = config[p];
            }
        }
    }
    return rcv;
}