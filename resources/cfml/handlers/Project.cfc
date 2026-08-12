component extends="coldbox.system.EventHandler"{

	property name="projectService" inject="project.ProjectService";

	function index() {
		relocate( "main.index" );
	}

	function create(event, rc, prc) {
		
	}

	function edit(event, rc, prc) {
		param name="rc.projectID" type="uuid";
		prc.project = projectService.getProject(rc.projectID);
		prc.fixinatorJSON = "";
		prc.fixinatorJSONPath = getDirectoryFromPath(prc.project.path) & ".fixinator.json";
		if ( fileExists(prc.fixinatorJSONPath)) {
			prc.fixinatorJSON = fileRead(prc.fixinatorJSONPath, "UTF-8");
		}
	}

	function save(event, rc, prc) {
		prc.success = false;
		try {
			prc.projectID = projectService.save(data=rc);	
			prc.success=true;
		} catch (any local.e) {
			prc.message = e.message;
		}
		
	}

	function remove(event, rc, prc) {
		param name="rc.projectID" type="uuid";
		param name="rc.csrf" type="uuid";
		param name="session.projectRemoveCSRF" default="#createUUID()#";
		if (rc.csrf == session.projectRemoveCSRF) {
			projectService.removeProject(rc.projectID);	
		}
		
	}


}