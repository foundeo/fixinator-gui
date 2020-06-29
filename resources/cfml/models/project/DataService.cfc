component singleton {

	
	function getDataDirectory() {
		var d = "";
		if (server.system.environment.keyExists("FIXINATOR_GUI_HOME")) {
			d = server.system.environment.FIXINATOR_GUI_HOME;
		} else {
			if (server.system.environment.keyExists("HOME") && directoryExists(server.system.environment.HOME)) {
				d = server.system.environment.HOME & "/.fixinator-gui";
				if (!directoryExists(d)) {
					directoryCreate(d);
				}
			} else {
				throw(message="Unable to construct data dir, missing FIXINATOR_GUI_HOME environment variable and unable to fall back to user HOME env var.");
			}
		}
		d = d & "/data/";
		if (!directoryExists(d)) {
			directoryCreate(d);
		}
		return d;
	}

	function getFixinatorGUIVersion() {
		var d = getDirectoryFromPath(getCurrentTemplatePath());
		d = replace(d, "\", "/", "ALL");
		d = replace(d, "models/project/", "box.json");
		if (fileExists(d)) {
			local.box = fileRead(d);
			if (isJSON(local.box)) {
				local.box = deserializeJSON(local.box);
				if (local.box.keyExists("version")) {
					return local.box.version;	
				}
				
			}
		}
		return "0.0.0";
	}

}