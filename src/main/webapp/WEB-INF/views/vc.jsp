<%--
  Created by IntelliJ IDEA.
  User: jksong
  Date: 2022/03/06
  Time: 2:12 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko" dir="ltr">
<head>
  <meta charset="utf-8">
  <title>Video Conference</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0">
  <style>
    html {
      overflow-y: scroll;
    }

    /*body {*/
    /*    background:radial-gradient(ellipse at center, rgba(255,254,234,1) 0%, rgba(255,254,234,1) 35%, #B7E8EB 100%);*/
    /*}*/

    .name {
      text-align: center;
    }

    video {
      position: relative;
      left: 0;
      top: 0;
      opacity: 1;
    }

    .video-mask{
      border-radius: 20px;
      overflow: hidden;
      position: relative;
      margin-right: 10px;
    }

    .pdiv{
      float: left;
    }

    .out {
      width: 100%;
      text-align: center;
    }

    .in {
      display: inline-block;
      align-self: center;
      height: 520px;
    }

    .in2 {
      display: inline-block;
      align-self: center;
    }

    #conversation-panel {
      margin-bottom: 20px;
      text-align: left;
      max-height: 100px;
      overflow: auto;
      width: 100%;
    }

    #conversation-panel .message {
      padding: 5px 10px;
    }

    #conversation-panel .message img, #conversation-panel .message video, #conversation-panel .message iframe {
      max-width: 640px;
    }

    #btn-attach-file {
      width: 25px;
      vertical-align: middle;
      cursor: pointer;
    }
  </style>
</head>
<body>

<div class="out">
  <div class="in" id="videos-container"></div>
  <%
    String roomName = request.getParameter("roomName");
    String userName  = request.getParameter("userName");
  %>
  <input type="hidden" id="roomName" name="roomName" value=<%=roomName%> />
  <input type="hidden" id="userName" name="userName" value=<%=userName%> />

  <div>
    <section class="experiment">
      <button id="share-screen" >화면 공유</button>
      <br>
      <br>
    </section>
    <div class="in2" id="attachZone">
      <div id="conversation-panel"></div>
      <div id="key-press" style="text-align: right; display: none; font-size: 11px;">
        <span style="vertical-align: middle;"></span>
        <img src="../img/key-press.gif" style="height: 12px; vertical-align: middle;">
      </div>
      <textarea id="chatArea" rows="4" cols="80" style="font-size: large" readonly></textarea><br>
      <div style="float: left;"><img id="btn-attach-file" src="../img/attach-file.png" title="Attach a File"></div>
      <div id="sendZone" style="float: left;"><input type="text" id="chatInput" placeholder="메세지를 입력하세요." style="width: 620px"/></div>
    </div>
    <br><br>
    <button id="refresh">새로고침</button> <button id="close_page">나가기</button>
  </div>
</div>
<script src="https://www.webrtc-experiment.com/common.js"></script>
<script src="../node_server/node_modules/rtcmulticonnection/dist/RTCMultiConnection.min.js"></script>
<script src="../node_server/node_modules/webrtc-adapter/out/adapter.js"></script>
<script src="../node_server/node_modules/socket.io-client/dist/socket.io.js"></script>
<script src="../node_server/node_modules/recordrtc/RecordRTC.js"></script>
<script src="../node_server/node_modules/fbr/FileBufferReader.js"></script>
<script src="../bower_components/jquery/jquery.min.js"></script>

<script>

  $("#close_page").click(function() {
    var confirm_result = confirm("화상회의에서 나가시겠습니까?");
    if (confirm_result == true) {
      location.replace("https://songjaekyung.com/login")
      return false;
    }
  });

  $("#refresh").click(function() {
    location.reload();
  });

  var connection = new RTCMultiConnection();

  connection.socketURL = 'https://songjaekyung.com:8880/';

  connection.socketMessageEvent = 'video-conference';

  connection.userid = document.getElementById('userName').value;

  connection.autoCloseEntireSession = true;
  connection.chunkSize = 80000;
  connection.enableFileSharing = true;
  connection.maxParticipantsAllowed = 10000;

  connection.session = {
    audio: true,
    video: true,
    data: true
  };

  connection.sdpConstraints.mandatory = {
    OfferToReceiveAudio: true,
    OfferToReceiveVideo: true
  };

  connection.onclose = connection.onerror = connection.onleave = function(event) {

  };

  var bitrates = 512;
  //var resolutions = 'Ultra-HD';
  var videoConstraints = {};
  var isFirstLine = true;
  var clientcnt = 0;
  var streamlist = [];

  //if (resolutions == 'Ultra-HD') {
  videoConstraints = {
    width: {
      ideal: 320
    },
    height: {
      ideal: 240
    },
    frameRate: 60,
    facingMode: "user"
  };
  //}

  connection.mediaConstraints = {
    video: videoConstraints,
    audio: true
  };

  var CodecsHandler = connection.CodecsHandler;

  connection.processSdp = function(sdp) {
    var codecs = 'vp8';

    if (codecs.length) {
      sdp = CodecsHandler.preferCodec(sdp, codecs.toLowerCase());
    }

    //if (resolutions == 'Ultra-HD') {
    sdp = CodecsHandler.setApplicationSpecificBandwidth(sdp, {
      audio: 128,
      video: bitrates,
      screen: bitrates
    });

    sdp = CodecsHandler.setVideoBitrates(sdp, {
      min: bitrates * 8 * 1024,
      max: bitrates * 8 * 1024,
    });
    //}

    return sdp;
  };

  connection.iceServers = [];

  connection.iceServers.push({
    urls: 'stun:stun.l.google.com:19302'
  });

  connection.iceServers.push({
    urls: 'turn:numb.viagenie.ca:3478',
    credential: 'worudthd1124~',
    username: 'jaek81@gmail.com'
  });

  //connection.videosContainer = document.getElementById('videos-container');
  connection.onstream = function(event) {
    // var existing = document.getElementById(event.streamid);
    // if(existing && existing.parentNode) {
    //     existing.parentNode.removeChild(existing);
    // }

    for (var i = 0; i < streamlist.length; i++) {
      if (event.streamid == streamlist[i]) {
        return
      }
    }

    streamlist.push(event.streamid);

    connection.videosContainer = document.getElementById('videos-container');

    event.mediaElement.removeAttribute('src');
    event.mediaElement.removeAttribute('srcObject');
    event.mediaElement.muted = true;
    event.mediaElement.volume = 0;

    var video = document.createElement('video');
    var pdiv = document.createElement('div');
    var div = document.createElement('div');
    var input = document.createElement('input');
    var inputdiv = document.createElement('div');
    var br = document.createElement('br');

    try {
      video.setAttributeNode(document.createAttribute('autoplay'));
      video.setAttributeNode(document.createAttribute('playsinline'));
    } catch (e) {
      video.setAttribute('autoplay', true);
      video.setAttribute('playsinline', true);
    }

    if(event.type === 'local') {
      video.volume = 0;
      try {
        video.setAttributeNode(document.createAttribute('muted'));
      } catch (e) {
        video.setAttribute('muted', true);
      }
    }
    video.srcObject = event.stream;

    div.className = 'video-mask';
    input.className = 'name';
    input.type = 'text'
    input.value = event.userid;
    input.readOnly = true;
    br.id = 'br';
    inputdiv.appendChild(input);
    div.appendChild(video);
    pdiv.appendChild(div);
    pdiv.appendChild(inputdiv);
    pdiv.className = 'pdiv';

    // var mediaElement = getHTMLMediaElement(video, {
    //     title: event.userid,
    //     buttons: ['full-screen'],
    //     width: width,
    //     showOnMouseEnter: false
    // });

    video.id = event.streamid;
    video.controls = true
    //mediaElement.id = event.streamid;

    localStorage.setItem(connection.socketMessageEvent, connection.sessionid);

    if(event.type === 'local') {

      connection.socket.on('infores', function (message) {
        var data = JSON.parse(message);
        var state = data.state;
        if (state == "full") {
          alert("해당 방에 인원이 찼습니다.");
          location.replace("https://songjaekyung.com/chat");
        }
      });

      connection.socket.on('chat', function (message) {
        var msg = JSON.parse(message);
        var room = document.getElementById('roomName').value;
        if (msg.room == room) {
          $('#chatArea').append(msg.user + ": " + msg.msg + "\n");
          $('#chatArea').scrollTop($('#chatArea')[0].scrollHeight);
        }
      });

      connection.socket.on('chat-enter', function (message) {
        var msg = JSON.parse(message);
        var room = document.getElementById('roomName').value;
        if (msg.room == room) {
          $('#chatArea').append(msg.user + "(이)가 입장하였습니다.\n");
          $('#chatArea').scrollTop($('#chatArea')[0].scrollHeight);
        }
      });

      connection.socket.on('chat-out', function (message) {
        var msg = JSON.parse(message);
        var room = document.getElementById('roomName').value;
        if (msg.room == room) {
          clientcnt--;

          $('#chatArea').append(msg.user + "(이)가 퇴장하였습니다.\n");
          $('#chatArea').scrollTop($('#chatArea')[0].scrollHeight);

          /* var br = document.getElementById('br');
           if (br && clientcnt <= 3) {
               connection.videosContainer.removeChild(br);
               isFirstLine = true;
           }*/
        }
      });

      connection.socket.on('disconnect', function() {
        alert('네트워크 문제로 연결이 끊겼습니다.')
        location.replace('https://songjaekyung.com/chat')
        // if(!connection.getAllParticipants().length) {
        //     location.reload();
        // }
      });
    }

    if(event.type === 'local' && event.stream.isVideo) {
      RMCMediaTrack.cameraStream = event.stream;
      RMCMediaTrack.cameraTrack = getTracks(event.stream, 'video')[0];
    }

    video.play();
    setTimeout(function() {
      console.log("width => " + video.width + " " + video.videoWidth + " " + video.videoHeight);
      if (video.videoHeight == 0 || video.videoHeight == 240 || video.videoHeight == 320) {
        video.width = 300;
        video.height = 220;
        div.style.width = '300px';
      } else if (video.videoHeight > 1000) {
        video.width = 386;
        video.height = 220;
        div.style.width = '386px';
      } else {
        video.width = 386;
        video.height = 220;
        div.style.width = '300px';
      }

      /* if (clientcnt >= 3 && isFirstLine) {
           isFirstLine = false;
           connection.videosContainer.appendChild(br);
       }*/

      clientcnt++;
      connection.videosContainer.appendChild(pdiv);
      //var width = parseInt(connection.videosContainer.clientWidth);

    }, 100);
  };

  connection.onstreamended = function(event) {
    // var room = document.getElementById('roomName').value;
    // //var user = document.getElementById('userName').value;
    // connection.socket.emit("deletedb", JSON.stringify({"room" : room, "user" : event.userid}))
    var mediaElement = document.getElementById(event.streamid);
    if (mediaElement) {
      mediaElement.parentNode.parentNode.parentNode.removeChild(mediaElement.parentNode.parentNode);
      connection.videosContainer = document.getElementById('videos-container');
    }
  };

  connection.onMediaError = function(e) {
    if (e.message === 'Concurrent mic process limit.') {
      if (DetectRTC.audioInputDevices.length <= 1) {
        alert('외부 마이크를 선택해주세요.');
        return;
      }

      var secondaryMic = DetectRTC.audioInputDevices[1].deviceId;
      connection.mediaConstraints.audio = {
        deviceId: secondaryMic
      };

      connection.join(connection.sessionid);
    } else {
      alert(e.message);
    }
  };

  (function() {
    var input = document.getElementById("chatInput");
    input.onkeyup = function(e){
      if(e.keyCode == 13){
        console.log("chat send~~");
        chatSend();
        document.getElementById('chatInput').value = "";
      }
    }

    // var params = {},
    //     r = /([^&=]+)=?([^&]*)/g;
    //
    // function d(s) {
    //     return decodeURIComponent(s.replace(/\+/g, ' '));
    // }
    // var match, search = window.location.search;
    // while (match = r.exec(search.substring(1)))
    //     params[d(match[1])] = d(match[2]);
    var params = {};
    params.roomid = document.getElementById('roomName').value;
    if (params.roomid == "") {
      alert("잘못된 접근입니다.");
      return;
    }
    params.user = document.getElementById('userName').value;
    window.params = params;

    connection.openOrJoin(document.getElementById('roomName').value, function(isRoomExist, roomid, error) {
      if(error) {
        alert(error);
      }

      var room = document.getElementById('roomName').value;
      var user = document.getElementById('userName').value;
      console.log("open room !! " + room + " " + user);
      connection.socket.emit("info", JSON.stringify({"room" : room, "user" : user}))
    });

  })();
  //////////////////////////////////////////////////////////////////////////////////////////
  var conversationPanel = document.getElementById('conversation-panel');
  var recentFile;
  document.getElementById('btn-attach-file').onclick = function() {
    var file = new FileSelector();
    file.selectSingleFile(function(file) {
      recentFile = file;
      if(connection.getAllParticipants().length >= 1) {
        recentFile.userIndex = 0;
        connection.send(file, connection.getAllParticipants()[recentFile.userIndex]);
      }
    });
  };

  var holder1 = document.getElementById('attachZone');
  holder1.ondrop = function (e) {
    e.stopPropagation();
    e.preventDefault();
    var file = e.dataTransfer.files[0];
    recentFile = file;
    if(connection.getAllParticipants().length >= 1) {
      recentFile.userIndex = 0;
      connection.send(file, connection.getAllParticipants()[recentFile.userIndex]);
    }
  };

  function getFileHTML(file) {
    var url = file.url || URL.createObjectURL(file);
    var attachment = '<a href="' + url + '" target="_blank" download="' + file.name + '">Download: <b>' + file.name + '</b></a>';
    if (file.name.match(/\.jpg|\.png|\.jpeg|\.gif/gi)) {
      attachment += '<br><img crossOrigin="anonymous" src="' + url + '">';
    } else if (file.name.match(/\.wav|\.mp3/gi)) {
      attachment += '<br><audio src="' + url + '" controls></audio>';
    } else if (file.name.match(/\.pdf|\.js|\.txt|\.sh/gi)) {
      attachment += '<iframe class="inline-iframe" src="' + url + '"></iframe></a>';
    }
    return attachment;
  }

  function getFullName(userid) {
    var _userFullName = userid;
    if (connection.peers[userid] && connection.peers[userid].extra.userFullName) {
      _userFullName = connection.peers[userid].extra.userFullName;
    }
    return _userFullName;
  }

  connection.onFileEnd = function(file) {
    var html = getFileHTML(file);
    var div = progressHelper[file.uuid].div;

    if (file.userid === connection.userid) {
      div.innerHTML = '<b>You:</b><br>' + html;
      div.style.background = '#cbffcb';

      if(recentFile) {
        recentFile.userIndex++;
        var nextUserId = connection.getAllParticipants()[recentFile.userIndex];
        if(nextUserId) {
          connection.send(recentFile, nextUserId);
        }
        else {
          recentFile = null;
        }
      }
      else {
        recentFile = null;
      }
    } else {
      div.innerHTML = '<b>' + getFullName(file.userid) + ':</b><br>' + html;
    }
  };

  // to make sure file-saver dialog is not invoked.
  connection.autoSaveToDisk = false;

  var progressHelper = {};

  connection.onFileProgress = function(chunk, uuid) {
    var helper = progressHelper[chunk.uuid];
    helper.progress.value = chunk.currentPosition || chunk.maxChunks || helper.progress.max;
    updateLabel(helper.progress, helper.label);
  };

  connection.onFileStart = function(file) {
    var div = document.createElement('div');
    div.className = 'message';

    if (file.userid === connection.userid) {
      var userFullName = file.remoteUserId;
      if(connection.peersBackup[file.remoteUserId]) {
        userFullName = connection.peersBackup[file.remoteUserId].extra.userFullName;
      }

      div.innerHTML = '<b>You (to: ' + userFullName + '):</b><br><label>0%</label> <progress></progress>';
      div.style.background = '#cbffcb';
    } else {
      div.innerHTML = '<b>' + getFullName(file.userid) + ':</b><br><label>0%</label> <progress></progress>';
    }

    div.title = file.name;
    conversationPanel.appendChild(div);
    progressHelper[file.uuid] = {
      div: div,
      progress: div.querySelector('progress'),
      label: div.querySelector('label')
    };
    progressHelper[file.uuid].progress.max = file.maxChunks;

    conversationPanel.scrollTop = conversationPanel.clientHeight;
    conversationPanel.scrollTop = conversationPanel.scrollHeight - conversationPanel.scrollTop;
  };

  function updateLabel(progress, label) {
    if (progress.position == -1) return;
    var position = +progress.position.toFixed(2).split('.')[1] || 100;
    label.innerHTML = position + '%';
  }

</script>
<script>
  var RMCMediaTrack = {
    cameraStream: null,
    cameraTrack: null,
    screen: null
  };

  var btnShareScreen = document.getElementById('share-screen');
  connection.onUserStatusChanged = function() {
    btnShareScreen.disabled = connection.getAllParticipants().length <= 0;
  };

  btnShareScreen.onclick = function() {
    isShareEnd = false;
    this.disabled = true;

    getScreenStream(function(screen) {
      var isLiveSession = connection.getAllParticipants().length > 0;
      if (isLiveSession) {
        replaceTrack(RMCMediaTrack.screen);
      }

      // now remove old video track from "attachStreams" array
      // so that newcomers can see screen as well
      connection.attachStreams.forEach(function(stream) {
        getTracks(stream, 'video').forEach(function(track) {
          stream.removeTrack(track);
        });

        // now add screen track into that stream object
        stream.addTrack(RMCMediaTrack.screen);
      });
    });
  };

  function screenHelper(callback) {
    if(navigator.mediaDevices.getDisplayMedia) {
      navigator.mediaDevices.getDisplayMedia({video: true}).then(stream => {
        callback(stream);
      }, error => {
        //alert('Please make sure to use Edge 17 or higher.');
      });
    }
    else if(navigator.getDisplayMedia) {
      navigator.getDisplayMedia({video: true}).then(stream => {
        callback(stream);
      }, error => {
        //alert('Please make sure to use Edge 17 or higher.');
      });
    }
    else {
      alert('getDisplayMedia API is not available in this browser.');
    }
  }

  function getScreenStream(callback) {
    screenHelper(function(screen) {
      RMCMediaTrack.screen = getTracks(screen, 'video')[0];

      RMCMediaTrack.screen.srcObject = screen;

      // in case if onedned event does not fire
      (function looper() {
        // readyState can be "live" or "ended"
        if (RMCMediaTrack.screen.readyState === 'ended') {
          RMCMediaTrack.screen.onended();
          return;
        }
        setTimeout(looper, 1000);
      })();

      var firedOnce = false;
      RMCMediaTrack.screen.onended = RMCMediaTrack.screen.onmute = RMCMediaTrack.screen.oninactive = function() {
        if (firedOnce) return;
        firedOnce = true;

        if (getTracks(RMCMediaTrack.cameraStream, 'video')[0].readyState) {
          getTracks(RMCMediaTrack.cameraStream, 'video').forEach(function(track) {
            RMCMediaTrack.cameraStream.removeTrack(track);
          });
          RMCMediaTrack.cameraStream.addTrack(RMCMediaTrack.cameraTrack);
        }

        RMCMediaTrack.screen.srcObject = RMCMediaTrack.cameraStream;

        connection.socket && connection.socket.emit(connection.socketCustomEvent, {
          justStoppedMyScreen: true,
          userid: connection.userid
        });

        // share camera again
        replaceTrack(RMCMediaTrack.cameraTrack);

        // now remove old screen from "attachStreams" array
        connection.attachStreams = [RMCMediaTrack.cameraStream];

        // so that user can share again
        btnShareScreen.disabled = false;
      };

      connection.socket && connection.socket.emit(connection.socketCustomEvent, {
        justSharedMyScreen: true,
        userid: connection.userid
      });

      callback(screen);
    });
  }

  function replaceTrack(videoTrack) {
    if (!videoTrack) return;
    if (videoTrack.readyState === 'ended') {
      alert('Can not replace an "ended" track. track.readyState: ' + videoTrack.readyState);
      return;
    }
    connection.getAllParticipants().forEach(function(pid) {
      var peer = connection.peers[pid].peer;
      if (!peer.getSenders) return;

      var trackToReplace = videoTrack;

      peer.getSenders().forEach(function(sender) {
        if (!sender || !sender.track) return;

        if (sender.track.kind === 'video' && trackToReplace) {
          sender.replaceTrack(trackToReplace);
          trackToReplace = null;
        }
      });
    });
  }

</script>

<script>

  function chatSend() {
    var input = document.getElementById('chatInput').value;
    var room = document.getElementById('roomName').value;
    var user = document.getElementById('userName').value;
    if (input.length > 0) {
      connection.socket.emit("chat", JSON.stringify({"room" : room, "user" : user, "msg" : input}))
    }
  }
</script>


</body>
</html>
