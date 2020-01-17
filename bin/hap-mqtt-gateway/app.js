var net = require('net');
var mqtt = require('mqtt')
var isnumeric = require('isnumeric');

var hapMpIp = "127.0.0.1";
var hapMpPort = 7891;
var mqttIp = "127.0.0.1";
var mqttPort = "1883";

var timeout = 1000;
var retrying = false;


/////////////////////////////////////////////////////////////////
// MQTT handler
////////////////////////////////////////////////////////////////


function mqttConnectHandler() {
    console.log("Connected to MQTT-Server:" + mqttIp + ':' + mqttPort);
    console.log("Subscribing: /hap/+/+/set");
    console.log("Subscribing: /hap/+/+/query");
    mqttClient.subscribe('/hap/+/+/set');
    mqttClient.subscribe('/hap/+/+/query');
}

function mqttMessageHandler(topic, message) {
    console.log("Topic:" + topic + ", Message:" + message);
    //Process incoming messages from Openhab
    var topicParts = topic.split("/");
    var hapDestination = topicParts[2];
    var hapDevice = topicParts[3];
    var hapCmd = topicParts[4];
    var toggleState = false;
    message = String.fromCharCode.apply(null, message);
    var hapValue = message;
    if (message.match(/ON/) || message.match(/DOWN/) || message.match(/CLOSE/)) {
        hapValue = 100;
    }
    else if (message.match(/OFF/) || message.match(/UP/) || message.match(/OPEN/)) {
        hapValue = 0;
    }
    else if (message.match(/TOGGLE/)) {
        toggleState = true;
        hapValue = 100;
    }
    if (hapCmd == "query") {
        console.log("destination " + hapDestination + " " +  hapCmd  +" device " + hapDevice + "\n");
        socket.write("destination " + hapDestination + " " +  hapCmd  +" device " + hapDevice + "\n");
    }
    else if (hapCmd == "set") {
        var setValueCmd = isnumeric(hapValue) ? "value " : "";

        console.log("destination " + hapDestination + " " +  hapCmd  + " device " + hapDevice  + " " + setValueCmd + hapValue + "\n");
        socket.write("destination " + hapDestination + " " +  hapCmd  + " device " + hapDevice  + " " + setValueCmd + hapValue + "\n");

        if (toggleState) { 
            setTimeout(function() {
                hapValue = 0;
                console.log("destination " + hapDestination + " " +  hapCmd  + " device " + hapDevice  + " value " + hapValue + " - toggle off\n");
                socket.write("destination " + hapDestination + " " +  hapCmd  + " device " + hapDevice  + " value " + hapValue + "\n");
            }, 100);
        }
    }
}

/////////////////////////////////////////////////////////////////
// Socket handler
////////////////////////////////////////////////////////////////

// Functions to handle socket events
function socketMakeConnection () {
    socket.connect(hapMpPort, hapMpIp);
}

function socketConnectEventHandler() {
    console.log('Connected to HAP-Messageprocessor:'  + hapMpIp + ':' + hapMpPort);
    retrying = false;
}
function socketDataEventHandler(data) {
    console.log('Received: ' + data);
    var strData = String.fromCharCode.apply(null, data);
    
    if (strData.match(/.*SessionSource.*/)) {        
        socket.write('{"Debug" : 1}' + "\n");
        return;
    } 

    //parse hap message and publish to mqtt
    var regexOne = /.*vlan:(\d+).*source:(\d+).*destination:(\d+).*mtype:(\d+).*device:(\d+).*v0:(\d+).*v1:(\d+).*v2:(\d+)/; 
    var regexTwo = /.*\[C:\d+,V:(\d+),S:(\d+),D:(\d+),MT:(\d+),DEV:(\d+),V1:(\d+),V2:(\d+),V3:(\d+)\].*/;
    var result = strData.match(regexOne);
    var hapMessage = {};
    if (result) {
        hapMessage['vlan'] = result[1];
        hapMessage['source'] = result[2];
        hapMessage['destination'] = result[3];
        hapMessage['mType'] = result[4];
        hapMessage['device'] = result[5];
        hapMessage['v0'] = result[6];
        hapMessage['v1'] = result[7];
        hapMessage['v2'] = result[8];
    }
    else {
        result = strData.match(regexTwo);
        if (result) {
            hapMessage['vlan'] = result[1];
            hapMessage['source'] = result[2];
            hapMessage['destination'] = result[3];
            hapMessage['mType'] = result[4];
            hapMessage['device'] = result[5];
            hapMessage['v0'] = result[6];
            hapMessage['v1'] = result[7];
            hapMessage['v2'] = result[8];            
        }
    }

    if (result) {
        var value = "OFF";
        //Switch states
        if (hapMessage.v0 == 100 && hapMessage.v1 == 0 && hapMessage.v2 == 0) {
            value = "ON";
        } 
        //Dimmer or Logical-Input state
        else if (hapMessage.v0 > 0 && hapMessage.v1 == 0 && hapMessage.v2 == 0) {
            value = hapMessage.v0;
        } 
        //Digital-Input state 
        else if (hapMessage.v0 > 0 && (hapMessage.v1 > 0 || hapMessage.v2 > 0)) { 
            value = parseInt(hapMessage.v2)*256*256 + parseInt(hapMessage.v1)*256 + parseInt(hapMessage.v0);
            value = value.toString();
        }
        var topic = '/hap/' + hapMessage.source + '/' + hapMessage.device+ '/status';
        console.log('Publishing:' + topic + ' with value:' + value);
        mqttClient.publish(topic, value, {retain: true});
    }
}

function socketErrorEventHandler() {
    // console.log('error');
}
function socketCloseEventHandler () {
    console.log('Connection to Message-Processor closed');
    if (!retrying) {
        retrying = true;
        console.log('Reconnecting...');
    }
    setTimeout(socketMakeConnection, timeout);
}

// Create socket and bind callbacks
var socket = new net.Socket();
socket.on('connect', socketConnectEventHandler);
socket.on('data',    socketDataEventHandler);
socket.on('error',   socketErrorEventHandler);
socket.on('close',   socketCloseEventHandler);

// Connect
console.log('Connecting to HAP-Messageprocessor:' + hapMpIp + ':' + hapMpPort + '...');
socketMakeConnection();
console.log('Connecting to MQTT-Server:' + mqttIp + ':' + mqttPort + '...');
var mqttClient = mqtt.connect('mqtt://' + hapMpIp);
mqttClient.on('connect', mqttConnectHandler);
mqttClient.on('message', mqttMessageHandler);
mqttClient.reconnecting = true;
