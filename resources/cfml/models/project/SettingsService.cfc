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

	

	public function save(data) {
		var settings = getSettings();
		var keys = ["api_key","api_url", "enterprise_path", "password"];
		var k = "";
		for (k in keys) {
			if (data.keyExists(k)) {
				settings[k] = data[k];
			} else if (!settings.keyExists(k)) {
				settings[k] = "";
			}
		}
		

		if (len(local.settings.enterprise_path)) {
			//ensure trailing slash
			if (!listFind("/,\", right(local.settings.enterprise_path, 1))) {
				local.settings.enterprise_path &= "/";
			}
			if (directoryExists(local.settings.enterprise_path)) {
				if (fileExists(local.settings.enterprise_path & "app/models/fixinator.cfc")) {
					//try creating an instance of it
					createComponentMapping("/fixinatorapi", local.settings.enterprise_path);
					var fixinatorInstance = new fixinatorapi.app.models.fixinator();
					fixinatorInstance.getVersion();
				} else {
					throw(message="Enterprise Path expected to find app/models/fixinator.cfc");
				}
				
			} else {
				throw(message="Enterprise Path directory does not exist.");
			}
		}

		if (len(settings.password)) {
			var salt = generateSecretKey("AES", 128);
			var iterations = "50000";
			var keySize = 128;
			var alg = "PBKDF2WithHmacSHA256";
			settings.password = "#alg#|#salt#|#iterations#|#keySize#|" & GeneratePBKDFkey(alg, data.password, salt, iterations, keySize);
		}

		cflock(name="fixinator-gui", timeout="10", type="exclusive") {
			fileWrite(getSettingsFile(), serializeJSON(settings));
		}
		

	}

	public boolean function authenticateByPassword(password) {
		var settings = getSettings();
		var pwd = "";
		if (settings.keyExists("password") && len(settings.password)) {
			var alg = listFirst(settings.password, "|");
			if (left(alg, 6)  == "PBKDF2") {
				var salt = listGetAt(settings.password, 2, "|");
				var iterations = listGetAt(settings.password, 3, "|");
				var keySize = listGetAt(settings.password, 4, "|");
				var h = listGetAt(settings.password, 5, "|");
				if (compare(h, GeneratePBKDFkey(alg, arguments.password, salt, iterations, keySize)) == 0) {
					//set cookie
					var cook = reReplace(generateSecretKey("AES", 128) & createUUID(), "[^a-zA-Z0-9]", "","ALL");
					var today = dateFormat(now(), "yymmdd");
					if (!application.keyExists("fixinator_gui_auth")) {
						application.fixinator_gui_auth = {};
					} else {
						//do some cleanup
						var k = "";
						for (k in application.fixinator_gui_auth) {
							var v = application.fixinator_gui_auth[k];
							if (len(v) == 6 && isValid("integer", v) && v < (dateFormat(dateAdd('d', -7, now()), "yymmdd"))) {
								structDelete(application.fixinator_gui_auth, k);
							}
						}
					}
					application.fixinator_gui_auth[cook] = today;
					cfcookie(name="fixinator_gui_auth", value=cook, httponly=true, secure=(cgi.https IS "on"), samesite="lax");
					return true;
				}
			}
		}
		return false;
	}

	public boolean function hasRequiredSettings() {
		var settings = getSettings();
		if (structIsEmpty(settings)) {
			return false;
		}
		//missing password 
		if (!structKeyExists(settings, "password")) {
			return false;
		}

		return true;
	}

	public boolean function needsAuth() {
		var settings = getSettings();
		if (!hasRequiredSettings()) {
			return true;
		}
		
		if (settings.keyExists("password")) {
			
			if (len(settings.password) == 0) {
				//no password needed based on config
				return false;
			}
			if (cookie.keyExists("fixinator_gui_auth")) {
				if (application.keyExists("fixinator_gui_auth")) {
					if (application.fixinator_gui_auth.keyExists(cookie.fixinator_gui_auth)) {
						application.fixinator_gui_auth[cookie.fixinator_gui_auth] = dateFormat(now(), "yymmdd");
						return false;
					}
				}
			}
		}

		

		return true;
	}

	

	public boolean function hasEnterprisePath() {
		var settings = getSettings();
		return settings.keyExists("enterprise_path") && len(settings.enterprise_path);
	}

	public function getFixinatorEnterpriseInstance() {
		var settings = getSettings();
		var mappings = getComponentMappings();
		if (settings.keyExists("enterprise_path") && len(settings.enterprise_path)) {
			if (!mappings.keyExists("/fixinatorapi")) {
				//we are missing the mapping, create it
				createComponentMapping("/fixinatorapi", local.settings.enterprise_path);
			}
			return new fixinatorapi.app.models.fixinator();
		} else {
			throw(message="You must set enterprise_path setting in order to obtain an enterprise instance.");
		}
	}

	private function createComponentMapping(mapping, path) {
		var mappings = {};
		mappings[arguments.mapping] = arguments.path;
		if (server.keyExists("lucee") || server.keyExists("boxlang")) {
			application action="update" mappings=getApplicationSettings().mappings.append( mappings );
		} else {
			getApplicationMetadata().mappings.append( mappings );
		}
	}

	private struct function getComponentMappings() {
		var appSettings = {};
		if (server.keyExists("lucee") || server.keyExists("boxlang")) {
			appSettings = getApplicationSettings();
		} else {
			appSettings = getApplicationMetadata();
		}
		if (appSettings.keyExists("mappings")) {
			return appSettings.mappings;
		} else {
			return {};
		}
	}


	private function getSettingsFile() {
		return getDataDirectory() & "settings.json";
	}

	

}