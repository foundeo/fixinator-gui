component extends="coldbox.system.EventHandler"{

	property name="projectService" inject="project.ProjectService";
	property name="settingsService" inject="project.SettingsService";
	property name="scanService" inject="project.ScanService";
	//property name="fixinatorClient" inject="FixinatorClient@fixinator";

	function index( event, rc, prc ){
		prc.projects = projectService.getProjects();
		prc.wizard = "none";
		if (!arrayLen(prc.projects)) {
			prc.settings = settingsService.getSettings();
			
			if (structIsEmpty(prc.settings)) {
				prc.wizard = "api_key";
				local.apiKey = "";//settingsService.getFixinatorAPIKey();
				if (len(local.apiKey) || rc.keyExists("api_key")) {
					prc.wizard = "api_url";
					rc.api_url = settingsService.getFixinatorAPIURL();
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

		}
		

	}
	



}