<%--
  Created by IntelliJ IDEA.
  User: jksong
  Date: 2022/03/06
  Time: 2:06 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <link id="bs-css" href="css/bootstrap-cerulean.min.css" rel="stylesheet">

  <link href="css/charisma-app.css" rel="stylesheet">
  <link href='bower_components/fullcalendar/dist/fullcalendar.css' rel='stylesheet'>
  <link href='bower_components/fullcalendar/dist/fullcalendar.print.css' rel='stylesheet' media='print'>
  <link href='bower_components/chosen/chosen.min.css' rel='stylesheet'>
  <link href='bower_components/colorbox/example3/colorbox.css' rel='stylesheet'>
  <link href='bower_components/responsive-tables/responsive-tables.css' rel='stylesheet'>
  <link href='bower_components/bootstrap-tour/build/css/bootstrap-tour.min.css' rel='stylesheet'>
  <link href='css/jquery.noty.css' rel='stylesheet'>
  <link href='css/noty_theme_default.css' rel='stylesheet'>
  <link href='css/elfinder.min.css' rel='stylesheet'>
  <link href='css/elfinder.theme.css' rel='stylesheet'>
  <link href='css/jquery.iphone.toggle.css' rel='stylesheet'>
  <link href='css/uploadify.css' rel='stylesheet'>
  <link href='css/animate.min.css' rel='stylesheet'>

  <!-- jQuery -->
  <script src="bower_components/jquery/jquery.min.js"></script>

  <!-- The HTML5 shim, for IE6-8 support of HTML5 elements -->
  <!--[if lt IE 9]>
  <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
  <![endif]-->

  <script src="bower_components/bootstrap/dist/js/bootstrap.min.js"></script>

  <!-- library for cookie management -->
  <script src="js/jquery.cookie.js"></script>
  <!-- calender plugin -->
  <script src='bower_components/moment/min/moment.min.js'></script>
  <script src='bower_components/fullcalendar/dist/fullcalendar.min.js'></script>
  <!-- data table plugin -->
  <script src='js/jquery.dataTables.min.js'></script>

  <!-- select or dropdown enhancer -->
  <script src="bower_components/chosen/chosen.jquery.min.js"></script>
  <!-- plugin for gallery image view -->
  <script src="bower_components/colorbox/jquery.colorbox-min.js"></script>
  <!-- notification plugin -->
  <script src="js/jquery.noty.js"></script>
  <!-- library for making tables responsive -->
  <script src="bower_components/responsive-tables/responsive-tables.js"></script>
  <!-- tour plugin -->
  <script src="bower_components/bootstrap-tour/build/js/bootstrap-tour.min.js"></script>
  <!-- star rating plugin -->
  <script src="js/jquery.raty.min.js"></script>
  <!-- for iOS style toggle switch -->
  <script src="js/jquery.iphone.toggle.js"></script>
  <!-- autogrowing textarea plugin -->
  <script src="js/jquery.autogrow-textarea.js"></script>
  <!-- multiple file upload plugin -->
  <script src="js/jquery.uploadify-3.1.min.js"></script>
  <!-- history.js for cross-browser state change on ajax -->
  <script src="js/jquery.history.js"></script>
  <!-- application script for Charisma demo -->
  <script src="js/charisma.js"></script>

<%--  <!-- The fav icon -->--%>
<%--  <link rel="shortcut icon" href="img/favicon.ico">--%>
    <title>Song Jae Kyung</title>
    <script>
      // chkVal
      function submitChk(){
        var roomName = $('#roomName').val();
        var userName = $('#userName').val();

        if(roomName.trim() == ""){
          alert("방번호를 입력해 주세요.");
          $('#roomName').focus();
          return false;
        }

        if(userName.trim() == ""){
          alert("이름을 입력해 주세요.");
          $('#userName').focus();
          return false;
        }
      }
    </script>
</head>
<body>
<div class="ch-container">
  <div class="row">

    <div class="row">
      <div class="col-md-12 center login-header">
        <h2 style="font-weight: bold;">화상 회의</h2>
      </div>
      <!--/span-->
    </div><!--/row-->

    <div class="row">
      <div class="well col-md-5 center login-box">
        <form id="login" class="form-horizontal" action="/vc" method="post" onsubmit="return submitChk();">
          <fieldset>
            <div class="input-group input-group-lg">
              <span class="input-group-addon"><i class="glyphicon glyphicon-eye-open"></i></span>
              <input type="text" id="roomName" name="roomName" class="form-control" placeholder="방 이름 입력">
            </div>
            <div class="clearfix"></div><br>

            <div class="input-group input-group-lg">
              <span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
              <input type="text" id="userName" name="userName" class="form-control" placeholder="사용자 이름 입력">
            </div>
            <div class="clearfix"></div>

            <p class="center col-md-5">
              <button type="submit" class="btn btn-primary">접속</button>
            </p>
          </fieldset>
        </form>
      </div>
      <!--/span-->
    </div><!--/row-->
  </div><!--/fluid-row-->

</div><!--/.fluid-container-->

</body>
</html>
