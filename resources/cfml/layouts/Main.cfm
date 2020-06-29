<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>Fixinator GUI</title>
  
	<link rel="stylesheet" href="/assets/node_modules/roboto-fontface/css/roboto/roboto-fontface.css">
	<link rel="stylesheet" href="/assets/node_modules/bootstrap-material-design/dist/css/bootstrap-material-design.min.css">
  <link rel="stylesheet" href="/assets/node_modules/ace-diff/dist/ace-diff-dark.min.css">
	<link rel="stylesheet" href="/assets/style.css">
  <link rel="icon" href="/assets/images/icon.png" type="image/png">
</head>
<body class="bg-dark">


	<header>
      
      <nav id="top" class="navbar navbar-light fixed-top bg-brand">
        <a class="navbar-brand" href="/" title="Fixinator"><img src="/assets/images/icon.png" alt="Fixinator" height="60" width="60"> Fixinator</a>
        <!---
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="##navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarCollapse">
          <hr>
          <ul class="navbar-nav mr-auto">
            <li class="nav-item active">
              <a class="nav-link" href="##">Projects <span class="sr-only">(current)</span></a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#event.buildLink('Main.settings')#">Settings</a>
            </li>
            
          </ul>
         --->
      </div>
      </nav>
    </header>

	
	<!---Container And Views --->
	<div id="main">#renderView()#</div>


<!---
<div class="bmd-layout-container bmd-drawer-f-r bmd-drawer-overlay">
  <header class="bmd-layout-header">
    <div class="navbar navbar-light bg-light">
      <ul class="nav navbar-nav">
        <li class="nav-item">Title</li>
      </ul>
      <button class="navbar-toggler" type="button" data-toggle="drawer" data-target="##dw-p2">
        <span class="sr-only">Toggle drawer</span>
        <i class="material-icons">menu</i>
      </button>
      
    </div>
  </header>
  <div id="dw-p2" class="bmd-layout-drawer bg-faded">
    <header>
      <a class="navbar-brand">Title</a>
    </header>
    <ul class="list-group">
      <a class="list-group-item">Link 1</a>
      <a class="list-group-item">Link 2</a>
      <a class="list-group-item">Link 3</a>
    </ul>
  </div>
  <main class="bmd-layout-content">
    <div class="container" id="main">
      <!-- main content -->
      #renderView()#
    </div>
  </main>
</div>
--->

	
  <script src="/assets/loader.js"></script>
  <script src="/assets/node_modules/jquery/dist/jquery.min.js"></script>
  <script src="/assets/node_modules/popper.js/dist/umd/popper.js"></script>
	<script src="/assets/node_modules/bootstrap-material-design/dist/js/bootstrap-material-design.js"></script>
  <script src="/assets/node_modules/ace-builds/src-min/ace.js"></script>
  <script src="/assets/node_modules/ace-diff/dist/ace-diff.min.js"></script>
  
  <script src="/assets/scripts.js"></script>
</body>
</html>
</cfoutput>
