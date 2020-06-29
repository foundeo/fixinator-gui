component{

	// Configure ColdBox Application
	function configure(){

		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "fixinator-gui",

			//Development Settings
			reinitPassword			= "",
			handlersIndexAutoReload = true,

			//Implicit Events
			defaultEvent			= "",
			requestStartHandler		= "",
			requestEndHandler		= "",
			applicationStartHandler = "",
			applicationEndHandler	= "",
			sessionStartHandler 	= "",
			sessionEndHandler		= "",
			missingTemplateHandler	= "",

			//Error/Exception Handling
			invalidHTTPMethodHandler = "",
			exceptionHandler		= "",
			invalidEventHandler			= "",
			customErrorTemplate		= "/views/Main/exception.cfm",

			//Application Aspects
			handlerCaching 			= false,
			eventCaching			= false
		};

		

		// Module Directives
		modules = {
			// An array of modules names to load, empty means all of them
			include = [],
			// An array of modules names to NOT load, empty means none
			exclude = []
		};

		//Register interceptors as an array, we need order
		interceptors = [
		];

	}

	/**
	* Development environment
	*/
	function development(){
		//coldbox.customErrorTemplate = "/coldbox/system/includes/BugReport.cfm";
	}

	function detectEnvironment() {
		return "production";
	}

}