const fs = require('fs');
const path = require('path');
const url = require('url');
var httpServer = require('http');

const ioServer = require('socket.io');
const RTCMultiConnectionServer = require('rtcmulticonnection-server');

var PORT = 8880;
var isUseHTTPs = true;

const jsonPath = {
    config: 'config.json',
    logs: 'logs.json'
};

const mysql = require('mysql');

var sqloption = {
    host: '127.0.0.1',
    port: 3306,
    user: 'root',
    password: 'jae549712',
    database: 'jaekhome'
};

const BASH_COLORS_HELPER = RTCMultiConnectionServer.BASH_COLORS_HELPER;
const getValuesFromConfigJson = RTCMultiConnectionServer.getValuesFromConfigJson;
const getBashParameters = RTCMultiConnectionServer.getBashParameters;
const resolveURL = RTCMultiConnectionServer.resolveURL;

var config = getValuesFromConfigJson(jsonPath);
config = getBashParameters(config, BASH_COLORS_HELPER);

// if user didn't modifed "PORT" object
// then read value from "config.json"
if(PORT === 8880) {
    PORT = config.port;
}
if(isUseHTTPs === false) {
    isUseHTTPs = config.isUseHTTPs;
}

function serverHandler(request, response) {
}

var httpApp;

if (isUseHTTPs) {
    httpServer = require('https');

    // See how to use a valid certificate:
    // https://github.com/muaz-khan/WebRTC-Experiment/issues/62
    var options = {
        key: null,
        cert: null,
        ca: null
    };

    var pfx = false;

    if (!fs.existsSync(config.sslKey)) {
        console.log(BASH_COLORS_HELPER.getRedFG(), 'sslKey:\t ' + config.sslKey + ' does not exist.');
    } else {
        pfx = config.sslKey.indexOf('.pfx') !== -1;
        options.key = fs.readFileSync(config.sslKey);
    }

    if (!fs.existsSync(config.sslCert)) {
        console.log(BASH_COLORS_HELPER.getRedFG(), 'sslCert:\t ' + config.sslCert + ' does not exist.');
    } else {
        options.cert = fs.readFileSync(config.sslCert);
    }

    if (config.sslCabundle) {
        if (!fs.existsSync(config.sslCabundle)) {
            console.log(BASH_COLORS_HELPER.getRedFG(), 'sslCabundle:\t ' + config.sslCabundle + ' does not exist.');
        }

        options.ca = fs.readFileSync(config.sslCabundle);
    }

    if (pfx === true) {
        options = {
            pfx: sslKey
        };
    }

    httpApp = httpServer.createServer(options, serverHandler);
} else {
    httpApp = httpServer.createServer(serverHandler);
}

RTCMultiConnectionServer.beforeHttpListen(httpApp, config);
httpApp = httpApp.listen(process.env.PORT || PORT, process.env.IP || "0.0.0.0", function() {
    RTCMultiConnectionServer.afterHttpListen(httpApp, config);
});

const soc = ioServer(httpApp);
var clientcnt = 0;
soc.on('connection', function(socket) {
    RTCMultiConnectionServer.addSocket(socket, config);
    clientcnt++;

    const params = socket.handshake.query;

    if (!params.socketCustomEvent) {
        params.socketCustomEvent = 'custom-message';
    }

    console.log("socket connect!!");

    socket.on('disconnect', function() {
        clientcnt--;
        console.log("socket disconnect!!");
        var room = socket.d.room;
        var user = socket.d.user;

        var dbconn = mysql.createConnection(sqloption);
        dbconn.connect(function(err) {
            if (err) {
                console.error('error connecting: ' + err.stack);
                return;
            }

            socket.broadcast.emit('chat-out', JSON.stringify({"room" : room, "user" : user}));

            var sql ="Delete FROM room where room_code = '" + room + "' and user = '" + user + "'";
            console.log("sql => " + sql);
            dbconn.query(sql, function(err, rows, cols) {
                if (err) throw err;
                dbconn.end();
            });
        });
    });

    var temp = JSON.stringify({"room": "", "user": ""});
    socket.d = JSON.parse(temp);

    socket.on("info", function (message) {
        console.log("info !!!!")
        var data = JSON.parse(message);
        var room = data.room;
        var user = data.user;
        socket.d = data;

        var dbconn = mysql.createConnection(sqloption);
        dbconn.connect(function(err) {
            if (err) {
                console.error('error connecting: ' + err.stack);
                return;
            }

            console.log("client cnt => " + clientcnt);
            // if (clientcnt == 1) {
            //     var sql ="Delete FROM room";
            //     console.log("sql => " + sql);
            //     dbconn.query(sql, function(err, rows, cols) {
            //         if (err) throw err;
            //     });
            // }

            var sql ="SELECT COUNT(user) AS user_cnt FROM room WHERE room_code = '" + room + "'";
            dbconn.query(sql, function(err, rows, cols){
                if(err) throw err;

                var cnt = Number(rows[0].user_cnt);

                var value = "";
                console.log("room => " + room + " cnt => " + cnt);

                if (cnt <= 5) {

                    socket.broadcast.emit('chat-enter', JSON.stringify({"room" : room, "user" : user}));

                    var sql ="SELECT COUNT(user) AS data_cnt FROM room WHERE room_code = '" + room + "' and user = '" + user + "'";

                    dbconn.query(sql, function(err, rows, cols){
                        if(err) throw err;
                        var datacnt = Number(rows[0].data_cnt);
                        console.log("data cnt => " + datacnt);

                        if (datacnt == 0) {
                            sql ="Insert into room(room_code, user) values ";
                            sql += "('" + room + "' , " + "'" + user + "'" + ")";
                            console.log(sql);
                            dbconn.query(sql, function(err, rows, cols){
                                if(err) throw err;
                                dbconn.end();
                            });
                        } else {
                            dbconn.end();
                        }
                    });;
                } else {
                    // funll
                    value = "full";
                    dbconn.end();
                }
                socket.emit("infores", JSON.stringify({"state": value}));
            });
        });
    });

    socket.on('chat', function(message) {
        console.log("chat " + message);
        soc.emit('chat', message);
    });

    socket.on(params.socketCustomEvent, function(message) {
        socket.broadcast.emit(params.socketCustomEvent, message);
    });
});