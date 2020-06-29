component extends="coldbox.system.EventHandler"{

	property name="scanService" inject="project.ScanService";
	property name="projectService" inject="project.ProjectService";
	property name="progressBar" inject="scan.ProgressBar";

	//property name="fixinatorClient" inject="FixinatorClient@fixinator";
	
	function index() {
		
	}

	function scan(event, rc, prc) {
		//reset progress bar
		progressBar.reset();
	}

	function progress(event, rc, prc) {
		event.renderData(type="json", data=progressBar.getValues(), statusCode=200);
	}

	function run(event, rc, prc) {
		prc.success = false;
		try {
			local.result = { "scanID": scanService.scan(projectID=rc.projectID), "success":true};	
			prc.success=true;
			event.renderData( type="json", data=local.result, statusCode=200 );
		} catch (local.e) {
			prc.message = local.e.message;
			if (local.e.keyExists("detail") && len(local.e.detail)) {
				prc.message &= " -- " & local.e.detail;
			}
			local.result = { "error" = prc.message, "success":false };
			event.renderData( type="json", data=local.result, statusCode=500 );
		}
	}

	function view(event, rc, prc) {
		prc.scan = scanService.getScan(rc.scanID);
		prc.project = projectService.getProject(rc.projectID);
		prc.projects = projectService.getProjects();

	}

	private function populateFixable(event, rc, prc) {
		var fixinatorClient = getInstance("FixinatorClient@fixinator");
		param name="rc.scanID" type="uuid";
		param name="rc.projectID" type="uuid";
		param name="rc.path" type="string";
		param name="rc.csrf" type="string" default="";
		prc.issues = [];
		prc.fixable = false;
		prc.fileChangedSinceScan = false;
		prc.fileIsPartOfScan = false;
		if (!len(rc.csrf) || rc.csrf != getCurrentCSRFToken()) {
			//invalid csrf token
			throw(message="Invalid CSRF");
		}
		if (rc.path contains "..") {
			return;
		}
		prc.scan = scanService.getScan(rc.scanID);
		
		for (local.result in prc.scan.results) {
			if (result.path == rc.path) {
				arrayAppend(prc.issues, result);
				if (result.keyExists("fixes") && arrayLen(result.fixes)) {
					prc.fixable = true;
				}
			}
		}
		
		prc.fullPath = fixinatorClient.normalizeSlashes(prc.scan.gui.base_path & rc.path);
		if (prc.scan.hashes.keyExists(prc.fullPath)) {
			prc.fileStillExists = fileExists(prc.fullPath);
			if (!prc.fileStillExists || fixinatorClient.fileSha1(prc.fullPath) != prc.scan.hashes[prc.fullPath]) {
					prc.fileChangedSinceScan = true;
			}
			prc.fileIsPartOfScan = true;
		}
		

	}

	


	function file(event, rc, prc) {
		rc.csrf = generateCSRFToken();
		prc.csrf = rc.csrf;
		populateFixable(event, rc, prc);
		
	}

	private function generateCSRFToken() {
		session.fixinator_gui_file_csrf = createUUID();
		return session.fixinator_gui_file_csrf;
	}

	private function getCurrentCSRFToken() {
		if (!session.keyExists("fixinator_gui_file_csrf")) {
			return generateCSRFToken();
		}
		return session.fixinator_gui_file_csrf;
	}

	function differ(event, rc, prc) {
		var fixinatorClient = getInstance("FixinatorClient@fixinator");
		var result = { "source": "", "fixed": "", "mode": "javascript", "issues":[], "warnings":[] };
		var fixes = [];
		var ext = "";
		var i = "";
		var f = "";
		var fixArray = [];
		try {


			populateFixable(event, rc, prc);
			
			if (arrayLen(prc.issues)) {
				result["issues"] = prc.issues;	
				ext = listLast(prc.fullPath, ".");
				result.source = fileRead(prc.fullPath);
				if (ext == "cfm") {
					result.mode = "coldfusion";
				}
			}
			
			if (prc.fixable) {
				if (isJSON(rc.fixes)) {
					fixArray = deserializeJSON(rc.fixes);
				}
				for (f in fixArray) {
					if (val(f.fix) == 0) {
						//skip this fix
						continue;
					}
					for (i in prc.issues) {
						if (i.uid == f.uid) {
							if (isNumeric(f.fix) && arrayLen(i.fixes) >= f.fix) {
								arrayAppend(fixes, {"fix":i.fixes[f.fix], "issue":i} );
							}
						}
					}		
				}
				
				
				if (arrayLen(fixes) == 0) {
					result.fixed = result.source;
				} else {
					local.fixResults = fixinatorClient.fixCode(basePath=prc.scan.gui.base_path, fixes=fixes, writeFiles=false);
					result.warnings = local.fixResults.warnings;
					if (local.fixResults.fixes.keyExists(prc.fullPath)) {
						result.fixed = local.fixResults.fixes[prc.fullPath];
					} else {
						result.fixed = serializeJSON(local.fixResults);//"";
					}
				}
				
			} else if (arrayLen(prc.issues) == 0) {
				result["error"] = "Invalid Scan, Project or Path";
				event.renderData( type="json", data=result, statusCode=500 );
				return;
			}
			event.renderData( type="json", data=result, statusCode=200 );
		} catch (any e) {
			result["error"] = toString(e.message) & " " & toString(e.detail);
			event.renderData( type="json", data=result, statusCode=500 );
		}
		
	}

	function ignore(event, rc, prc) {
		populateFixable(event, rc, prc);
		if (prc.fileIsPartOfScan) {
			local.proj = projectService.getProject(rc.projectID);
			if (!structIsEmpty(local.proj)) {
				if (local.proj.config.keyExists("ignorePaths")) {
					arrayAppend(local.proj.config.ignorePaths, rc.path);
				} else {
					local.proj.config.ignorePaths = [rc.path];
				}
				projectService.save(local.proj);
				scanService.removeIssuesByPath(rc.scanID, rc.path);
				event.renderData( type="json", data={"success":true}, statusCode=200 );
				return;
			}
		}
		event.renderData( type="json", data={"error"="Invalid Path to Ignore"}, statusCode=500 );
	}

	function changed(event, rc, prc) {
		populateFixable(event, rc, prc);
		var response = false;
		if (!prc.fileIsPartOfScan || !prc.fileStillExists || prc.fileChangedSinceScan) {
			changed = true;
		}
		event.renderData( type="json", data={"changed"=changed}, statusCode=200 );
	}

	function rescan(event, rc, prc) {
		populateFixable(event, rc, prc);
		if (prc.fileIsPartOfScan) {
			scanService.rescan(rc.projectID, rc.scanID, rc.path, prc.fullPath);
			relocate( "scan.file?projectID=" & rc.projectID & "&scanID=" & rc.scanID & "&path=" & urlEncodedFormat(rc.path) );
		} else {
			throw(message="Cannot Rescan a file that is not part of the scan.");
		}
	}

	function save(event, rc, prc) {
		try {
			populateFixable(event, rc, prc);
			if (!prc.fileIsPartOfScan) {
				throw(message="Invalid Path");
			} else if (!prc.fileStillExists) {
				throw(message="The file you are attempting to save was deleted from the file system, and failed to save.");
			} else if (prc.fileChangedSinceScan) {
				throw(message="The file appears to have changed since it was scanned, so saving from Fixinator has failed");
			} else {
				fileWrite(prc.fullPath, rc.content);
				event.renderData( type="json", data={"success"=true, "error"=""}, statusCode=200 );
			}	
			
		} catch (any e) {
			event.renderData( type="json", data={"success"=false,"error"=e.message}, statusCode=200 );
		}
		
	}



}