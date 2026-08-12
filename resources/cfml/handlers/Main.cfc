component extends="coldbox.system.EventHandler"{

	property name="projectService" inject="project.ProjectService";
	property name="settingsService" inject="project.SettingsService";
	property name="scanService" inject="project.ScanService";
	//property name="fixinatorClient" inject="FixinatorClient@fixinator";

	public function onRequestStart(event, rc, prc) {
		if (settingsService.needsAuth()) {
			if (event.getCurrentHandler() == "Main" && event.getCurrentAction() == "index") {
				//this is where you belong
			} else {
				//relocate to index
				relocate(event="Main.index");
			}
		}
	}

	function index( event, rc, prc ){
		prc.projects = projectService.getProjects();
		prc.settings = settingsService.getSettings();
		prc.wizard = "login";
		prc.message = "";

		if (!settingsService.hasRequiredSettings()) {
			prc.wizard = "setup";
			if (rc.keyExists("api_key")) {
				//call saveSettings
				prc.success = false;
				saveSettings(event=event, rc=rc, prc=prc);
				if (prc.success) {
					if (len(rc.password)) {
						prc.wizard = "login";
					} else {
						prc.wizard = "none";
					}
				}
			} 	
			prc.api_url = settingsService.getFixinatorAPIURL();
			prc.api_key = settingsService.getFixinatorAPIKey();
			prc.enterprise_path = "";
			if (prc.settings.keyExists("enterprise_path")) {
				prc.enterprise_path = prc.settings.enterprise_path;
			}
			
		} else {
			//is login skipped?
			if (prc.settings.keyExists("password") && len(prc.settings.password) == 0) {
				prc.wizard = "none";
			} else if (rc.keyExists("password")) {
				var d = dateFormat(now(), "yyyymmdd");
				//simple rate limit
				if (application.keyExists("login_rate_limit") && application.login_rate_limit.keyExists(d) && application.login_rate_limit[d] > 100) {
					prc.message = "Sorry, too many failed login attempts, please try again tomorrow";
				} else {
					if (settingsService.authenticateByPassword(rc.password)) {
						prc.wizard = "none";
					} else {
						prc.message = "Incorrect Password";
					}
				}
				
			} else if (!settingsService.needsAuth()) {
				//already logged in or no pwd needed
				prc.wizard = "none";
			}
		}

		if (!arrayLen(prc.projects)) {
			prc.settings = settingsService.getSettings();
			
			if (structIsEmpty(prc.settings)) {
				prc.wizard = "api_key";
				local.apiKey = "";//settingsService.getFixinatorAPIKey();
				if (len(local.apiKey) || rc.keyExists("api_key")) {
					prc.wizard = "api_url";
					
				}
			}
			
		} 
		event.setView("main/index");
	}

	function settings( event, rc, prc ) {
		var fixinatorClient = getInstance("FixinatorClient@fixinator");
		prc.fixinatorGUIVersion = settingsService.getFixinatorGUIVersion();
		prc.fixinatorClientVersion = fixinatorClient.getClientVersion();
		prc.fixinatorClient = scanService.getFixinatorClient();
		prc.dataDir = settingsService.getDataDirectory();
		prc.settings = settingsService.getSettings();
		prc.hasEnterprisePath = settingsService.hasEnterprisePath();
		prc.enterpriseVersion = "";
		prc.enterpriseInstanceError = "";
		if (prc.hasEnterprisePath) {
			try {
				prc.enterpriseInstance = settingsService.getFixinatorEnterpriseInstance();
				prc.enterpriseVersion = prc.enterpriseInstance.getVersion();
			} catch (any err) {
				prc.enterpriseInstanceError = err.message;
			}
		}
	}

	function saveSettings( event, rc, prc ) {
		try {
			if (rc.keyExists("apiType") && rc.apiType == "cloud") {
				rc.api_url = "";
			}
			settingsService.save(data=rc);
			prc.success = true;
		} catch (any e) {
			prc.success = false;
			prc.message = e.message;
		}
		

	}
	



}