/**
* Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
*/
component{
	// Application properties
	this.name = hash( getCurrentTemplatePath() );
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,30,0);
	this.setClientCookies = true;
	this.sessionCookie.httpOnly = true;
	this.sessionCookie.samesite = "strict";
	this.clientStorage="memory";

	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = getDirectoryFromPath( getCurrentTemplatePath() );
	// The web server mapping to this application. Used for remote purposes or static purposes
	COLDBOX_APP_MAPPING   = "";
	// COLDBOX PROPERTIES
	COLDBOX_CONFIG_FILE 	 = "";
	// COLDBOX APPLICATION KEY OVERRIDE
	COLDBOX_APP_KEY 		 = "";

	// application start
	public boolean function onApplicationStart(){
		application.cbBootstrap = new coldbox.system.Bootstrap( COLDBOX_CONFIG_FILE, COLDBOX_APP_ROOT_PATH, COLDBOX_APP_KEY, COLDBOX_APP_MAPPING );
		application.cbBootstrap.loadColdbox();
		return true;
	}

	// application end
	public void function onApplicationEnd( struct appScope ){
		arguments.appScope.cbBootstrap.onApplicationEnd( arguments.appScope );
	}

	// request start
	public boolean function onRequestStart( string targetPage ){
		// Process ColdBox Request
		request.isNativeApp = false;
		if (server.system.environment.keyExists("FIXINATOR_GUI_KEY")) {
			request.isNativeApp = true;
			if (!find(server.system.environment.FIXINATOR_GUI_KEY, cgi.http_user_agent)) {
				include template="views/Main/invalid-key.cfm";
				return false;
			}
		}
		request.cspNonce = createUUID();
		/*
			style hashes 
			    ace:
				  new:
				  'sha256-Rc2a7SfB50KoFAIR0X5+ul5uQbsJSujId4MzcmbUx8s='
				  'sha256-qEpFNF1Fp0ubO1jN1GWZPNX0btdFLOmn1g2V0f1FnYs='
				  'sha256-RbXap8DThrtn0GXWVWVLAiidfpCw+pWF6BZUhesiLg8='
				  'sha256-WED0SddB76QKxvUxiNsC4yBV4q+h2VmeED+HOmw3QcE='
				  'sha256-2IIKf8z5gnZ15Bf4Bzph2gOuGgFlmkZ9nw7BL4SXRIA='
				  old:
			      'sha256-gixU7LtMo8R4jqjOifcbHB/dd61eJUxZHCC6RXtUKOQ='
			      'sha256-Dn0vMZLidJplZ4cSlBMg/F5aa7Vol9dBMHzBF4fGEtk='
			      'sha256-sA0hymKbXmMTpnYi15KmDw4u6uRdLXqHyoYIaORFtjU='
			    ace theme monokai:
			      'sha256-MQjIdoaT+4ud/MEvS1P0oGESZb94X2E976aC2zlTfhs='
			    ace-diff:
			      img-src data:
		*/
		cfheader(name="Content-Security-Policy", value="default-src 'none';script-src 'self' 'nonce-#request.cspNonce#';style-src 'self' 'unsafe-hashes' 'sha256-Rc2a7SfB50KoFAIR0X5+ul5uQbsJSujId4MzcmbUx8s=' 'sha256-qEpFNF1Fp0ubO1jN1GWZPNX0btdFLOmn1g2V0f1FnYs=' 'sha256-RbXap8DThrtn0GXWVWVLAiidfpCw+pWF6BZUhesiLg8=' 'sha256-WED0SddB76QKxvUxiNsC4yBV4q+h2VmeED+HOmw3QcE=' 'sha256-2IIKf8z5gnZ15Bf4Bzph2gOuGgFlmkZ9nw7BL4SXRIA=';font-src 'self';img-src 'self' data:;connect-src 'self';base-uri 'self';form-action 'self';");
		application.cbBootstrap.onRequestStart( arguments.targetPage );

		return true;
	}


	public void function onSessionStart(){
		application.cbBootStrap.onSessionStart();
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		arguments.appScope.cbBootStrap.onSessionEnd( argumentCollection=arguments );
	}

	public boolean function onMissingTemplate( template ){
		return application.cbBootstrap.onMissingTemplate( argumentCollection=arguments );
	}

}