component singleton extends="DataService" {

	property name="wirebox" inject="wirebox";

	function getProjects() {
		if (fileExists(getProjectsFile())) {
			local.fileData = fileRead(getProjectsFile());
			if (isJSON(local.fileData)) {
				return deserializeJSON(local.fileData);
			} else {
				throw(message="The projects file was not valid JSON.", detail="File Path: #getProjectsFile()#");
			}
		} else {
			return [];
		}
	}

	function getProject(id) {
		var projects = getProjects();
		for (local.p in projects) {
			if (local.p.id == arguments.id) {
				return local.p;
			}
		}
		throw(message="Invalid Project ID");
	}

	function removeProject(id) {
		var projects = "";
		var i = 0;
		var removeIndex = 0;
		var p = "";
		cflock(name="fixinator-gui", timeout="10", type="exclusive") {
			projects = getProjects();
			for (p in projects) {
				i++;
				if (p.id == arguments.id) {
					removeIndex = i;
					break;
				}
			}
			if (removeIndex != 0) {
				if (arrayDeleteAt(projects, removeIndex)) {
						fileWrite(getProjectsFile(), serializeJSON(projects));
				}
			}
		}
	}

	function save(data) {
		var config = {};
		var fixinatorClient = wirebox.getInstance("FixinatorClient@fixinator");
		if (!data.keyExists("id") || !isValid("uuid", data.id)) {
			throw(message="Invalid ID. Either it was not passed or was not a valid UUID.");
		}

		if (!data.keyExists("name") || len(data.name) == 0) {
			throw(message="Please Specify a Project Name");
		} 

		if (!data.keyExists("path")) {
			throw(message="Missing Path");
		}
		if (!directoryExists(data.path) && !fileExists(data.path)) {
			throw(message="The path must point to a directory (or file) that exists on the local file system.");
		}

		if (directoryExists(data.path)) {
			if (right( fixinatorClient.normalizeSlashes(data.path), 1) != "/") {
				data.path = fixinatorClient.normalizeSlashes(data.path & "/");
			}
		}




		cflock(name="fixinator-gui", timeout="10", type="exclusive") {
			var projects = getProjects();
			var i = 0;
			local.wasUpdate = false;
			for (i=1;i<=arrayLen(projects);i++) {
				local.p = projects[i];
				if (local.p.id == data.id) {
					//update
					projects[i]["path"] = data.path;
					projects[i]["name"] = data.name;
					if (data.keyExists("last_scan_id")) {
						projects[i]["last_scan_id"] = data.last_scan_id;	
					} 
					if (data.keyExists("last_scan_date")) {
						projects[i]["last_scan_date"] = data.last_scan_date;	
					}
					if (!projects[i].keyExists("config")) {
						projects[i]["config"] = {};
					}
					if (data.keyExists("minConfidence")) {
						projects[i].config["minConfidence"] = data.minConfidence;
					}
					if (data.keyExists("minSeverity")) {
						projects[i].config["minSeverity"] = data.minSeverity;
					}
					if (data.keyExists("ignoreExtensions")) {
						if (len(data.ignoreExtensions)) {
							projects[i].config["ignoreExtensions"] = trimArray(listToArray(data.ignoreExtensions));
						} else if (projects[i].config.keyExists("ignoreExtensions")) {
							structDelete(projects[i].config, "ignoreExtensions");
						}
					}
					if (data.keyExists("ignoreScanners")) {
						if (len(data.ignoreScanners)) {
							projects[i].config["ignoreScanners"] = trimArray(listToArray(data.ignoreScanners));
						} else if (projects[i].config.keyExists("ignoreScanners")) {
							structDelete(projects[i].config, "ignoreScanners");
						}
					}
					if (data.keyExists("config") && data.config.keyExists("ignorePaths")) {
						projects[i].config["ignorePaths"] = data.config.ignorePaths;
					} else if (data.keyExists("ignorePaths")) {
						if (len(data.ignorePaths)) {
							projects[i].config["ignorePaths"] = trimArray(listToArray(trim(data.ignorePaths), chr(13)));
						} else if (projects[i].config.keyExists("ignorePaths")) {
							structDelete(projects[i].config, "ignorePaths");
						}
					}


					local.wasUpdate = true;
					break;
				} 
			}
			if (!local.wasUpdate) {
				var p = {"id"=data.id, "path"=data.path, "name"=data.name, "config"={}};
				arrayAppend(projects, p);	
			}
			fileWrite(getProjectsFile(), serializeJSON(projects));
		}
		
		return data.id;
	}

	public function setLastScanID(uuid projectID,uuid scanID) {
		var p = getProject(projectID);
		p["last_scan_id"] = arguments.scanID;
		p["last_scan_date"] = dateTimeFormat(now(), "yyyy-mm-dd HH:mm");
		save(p);
	}

	private function getProjectsFile() {
		return getDataDirectory() & "projects.json";
	}

	private function trimArray(arrayToTrim) {
		var i = 0;
		for (i=1;i<arrayLen(arguments.arrayToTrim);i++) {
			arguments.arrayToTrim[i] = trim(arguments.arrayToTrim[i]);
		}
		return arguments.arrayToTrim;
	}

	

}