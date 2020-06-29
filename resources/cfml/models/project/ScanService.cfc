component singleton extends="DataService" {

	//property name="fixinatorClient" inject="FixinatorClient@fixinator";

	property name="wirebox" inject="wirebox";

	property name="injector" inject="coldbox.system.ioc.Injector";

	property name="projectService" inject="project.ProjectService";

	property name="settingsService" inject="project.SettingsService";

	property name="progressBar" inject="scan.ProgressBar";

	function scan(projectID) {
		var p = projectService.getProject(projectID);
		var scanID = createUUID();
		var result = "";
		var r = "";
		progressBar.reset();
		cfsetting(requesttimeout="9000");//9000 seconds, 2.5h
		result = getFixinatorClient().run(path=p.path, config=p.config, progressBar=progressBar);

		result["gui"] = {"scan_date"="#dateTimeFormat(now(), "yyyy-mm-dd HH:mm:ss")#", "project_id"=projectID, "base_path"=getFixinatorClient().normalizeSlashes(p.path), "file_count"=arrayLen(result.files), "updated"="#dateTimeFormat(now(), "yyyy-mm-dd HH:mm:ss")#"};
		//add uid to each issue
		for (r in result.results) {
			if (!r.keyExists("uid")) {
				r["uid"] = createUUID();	
			}
		}
		//add file hashes
		result["hashes"] = {};
		for (r in result.files) {
			result.hashes[getFixinatorClient().normalizeSlashes(r)] = getFixinatorClient().fileSha1(r);
		}
		save(scanID, result);
		projectService.setLastScanID(projectID, scanID);
		return scanID;	
	}

	function removeIssuesByPath(scanID, path) {
		var data = getScan(arguments.scanID);
		var p = arguments.path;
		data.results = arrayFilter(data.results, function(item) {
			return (item.path != p);
		});
		save(arguments.scanID, data);
	}

	function rescan(projectID, scanID, relativePath, fullPath) {
		var p = projectService.getProject(projectID);
		var data = "";
		var result = "";
		var relPath = arguments.relativePath;
		var fixinatorClient = getFixinatorClient();
		if (!fileExists(arguments.fullPath)) {
			//if file was deleted on the file system can't scan, just remove issues linked to it
			removeIssuesByPath(scanID, relativePath);
			return;
		}
		result = fixinatorClient.run(path=p.path, config=p.config, paths=[fullPath]);
		data = getScan(arguments.scanID);
		//update file hash
		data.hashes[arguments.fullPath] = fixinatorClient.fileSha1(arguments.fullPath);
		//first remove all issues with this path
		data.results = arrayFilter(data.results, function(item) {
			return (item.path != relPath);
		});
		if (arrayLen(result.results) != 0) {
			
			//next add issues back in
			for (local.i in result.results) {
				local.i["uid"] = createUUID();
				arrayAppend(data.results, local.i);
			}
			
			
			
		} 
		save(arguments.scanID, data);
	}

	function getFixinatorClient() {
		//var injector = new wirebox.system.ioc.Injector();
		var fixinatorClient = wirebox.getInstance("FixinatorClient@fixinator");
		var settings = settingsService.getSettings();
		if (settings.keyExists("api_url") && len(settings.api_url)) {
			fixinatorClient.setAPIURL(settings.api_url);	
		}
		if (settings.keyExists("api_key") && len(settings.api_key)) {
			fixinatorClient.setAPIKey(settings.api_key);		
		}
		return fixinatorClient;
	}


	function save(scanID, data) {
		if (isValid("uuid", scanID)) {
			data.gui.updated = "#dateTimeFormat(now(), "yyyy-mm-dd HH:mm:ss")#";
			fileWrite(getScanDataDirectory() & scanID & ".json", serializeJSON(data) );
		}
	}

	function getScan(scanID) {
		var data = "";
		var filePath = getScanDataDirectory() & scanID & ".json";
		if (isValid("uuid", scanID) && fileExists(filePath) ) {
			data = fileRead( filePath );
			if ( isJSON(data) ) {
				return deserializeJSON( data );
			}
		}
		return {};
	}


	private function getScanDataDirectory() {
		var d = getDataDirectory() & "scans/";
		if (!directoryExists(d)) {
			directoryCreate(d);
		}
		return d;
	}

	

}