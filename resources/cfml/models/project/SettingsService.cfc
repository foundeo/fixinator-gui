component singleton extends="DataService" {

	function getSettings() {
		if (fileExists(getSettingsFile())) {
			local.fileData = fileRead(getSettingsFile());
			if (isJSON(local.fileData)) {
				return deserializeJSON(local.fileData);
			} else {
				throw(message="The settings file was not valid JSON.", detail="File Path: #getSettingsFile()#");
			}
		} else {
			return {};
		}
	}

	
	function getFixinatorAPIKey() {
		var s = getSettings();
		if (s.keyExists("api_key") && len(s.api_key)) {
			return s.api_key;
		}
		if (server.system.environment.keyExists("FIXINATOR_API_KEY")) {
			return server.system.environment.FIXINATOR_API_KEY;
		}
		return "";
	}

	function getFixinatorAPIURL() {
		var s = getSettings();
		if (s.keyExists("api_url") && len(s.api_url)) {
			return s.api_url;
		}
		if (server.system.environment.keyExists("FIXINATOR_API_URL")) {
			return server.system.environment.FIXINATOR_API_URL;
		}
		return "";
	}
	

	function save(data) {
		local.settings = {"api_key"="", "api_url"=""};
		local.settings.api_key = data.api_key;
		local.settings.api_url = data.api_url;
		

		cflock(name="fixinator-gui", timeout="10", type="exclusive") {
			fileWrite(getSettingsFile(), serializeJSON(local.settings));
		}
		

	}

	private function getSettingsFile() {
		return getDataDirectory() & "settings.json";
	}

	

}