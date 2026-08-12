<div class="subnav container d-flex justify-content-between">
	<a href="/" class="btn btn-outline btn-outline-brand">Back to Projects</a>
    <div class="text-right">
        	<cfset session.projectRemoveCSRF = createUUID()>
        	<cfoutput>
        	<a href="#event.buildLink('project.remove?projectID=#encodeForURL(rc.projectID)#&csrf=#encodeForURL(session.projectRemoveCSRF)#')#" class="btn btn-outline btn-outline-brand">Remove Project</a>
        	</cfoutput>
    </div>
</div>
<div class="container pt-4">

<div class="card bg-brand">
  <h2 class="card-header">Project Settings</h2>

  <cfif len(prc.fixinatorJSON)>
	<cfif NOT isJSON(prc.fixinatorJSON)>
		<div class="alert alert-danger m-4">
			This project has a <code>.fixinator.json</code> but it doesn't contain valid JSON
		</div>
	<cfelse>
		<div class="alert alert-warning m-4">Some settings are defined in your <code>.fixinator.json</code> file</div>
	</cfif>
  <cfelse>
	<div class="alert alert-info m-4">Tip: You can place a <code>.fixinator.json</code> file in the project root to share settings among several developers.</div>
  </cfif>

  <div class="card-body">
    <cfoutput>
    <form action="#event.buildLink('project.save')#" method="POST">
		<input type="hidden" name="id" value="#encodeForHTMLAttribute(rc.projectID)#">
		<div class="mb-3">
			<label for="name" class="form-label">Project Name:</label>
			<input type="text" name="name" class="form-control" value="#encodeForHTMLAttribute(prc.project.name)#" required="required">
		</div>
		<div class="mb-3">
			<label for="path" class="form-label">Root File Path:</label>
			<input type="text" class="form-control" name="path" value="#encodeForHTMLAttribute(prc.project.path)#" required="required">
		</div>
		<cfparam name="prc.project.config" default="#structNew()#">

		<cfparam name="prc.project.config.minConfidence" default="high">
		
		<div class="mb-3">
			<label for="minConfidence" class="form-label">Confidence Level:</label>

			<select name="minConfidence" id="minConfidence" class="form-control">
				<option value="high"<cfif prc.project.config.minConfidence IS "high"> selected="selected"</cfif>>High - Only show results we are highly confident to be a security issue</option>
				<option value="medium"<cfif prc.project.config.minConfidence IS "medium"> selected="selected"</cfif>>Medium</option>
				<option value="low"<cfif prc.project.config.minConfidence IS "low"> selected="selected"</cfif>>Low - Includes results that may not be a security issue</option>
				<option value="none"<cfif prc.project.config.minConfidence IS "none"> selected="selected"</cfif>>None - Includes suggestions</option>
			</select>
		</div>

		<cfparam name="prc.project.config.minSeverity" default="low">
		<div class="mb-3">
			<label for="minSeverity" class="form-label">Severity Level:</label>

			<select name="minSeverity" id="minSeverity" class="form-control">
				<option value="high"<cfif prc.project.config.minSeverity IS "high"> selected="selected"</cfif>>High - Only show most severe issues</option>
				<option value="medium"<cfif prc.project.config.minSeverity IS "medium"> selected="selected"</cfif>>Medium</option>
				<option value="low"<cfif prc.project.config.minSeverity IS "low"> selected="selected"</cfif>>Low - Includes results that may be very low risk security issues</option>
			</select>
		</div>

		<cfparam name="prc.project.config.ignoreExtensions" default="#arrayNew(1)#">
		<div class="mb-3" class="form-label">
			<label for="ignorePaths" class="form-label">Ignored File Extensions:</label>
			<input type="text" name="ignoreExtensions" class="form-control" value="#encodeForHTMLAttribute(arrayToList(prc.project.config.ignoreExtensions))#">
			<small class="form-text text-muted">Comma separated list of file extensions, eg: txt,xyz,abc</small>
		</div>

		<cfparam name="prc.project.config.ignorePaths" default="#arrayNew(1)#">
		<div class="mb-3">
			<label for="ignorePaths" class="form-label">Ignored Paths:</label>
			<textarea name="ignorePaths" class="form-control" rows="8" id="ignorePaths">#encodeForHTML(arrayToList(prc.project.config.ignorePaths, chr(13)))#</textarea>
			<small class="form-text text-muted">Add one path per line to exclude files or folders from the scan.</small>
			
		</div>

		<cfparam name="prc.project.config.ignoreScanners" default="#arrayNew(1)#">
		<div class="mb-3">
			<label for="ignorePaths" class="form-label">Ignored Scanners:</label>
			<input type="text" name="ignoreScanners" class="form-control" value="#encodeForHTMLAttribute(arrayToList(prc.project.config.ignoreScanners))#">
			<small class="form-text text-muted">Comma separated list of fixinator scanners to ignore, eg: xss,sqlinjection</small>
		</div>

		<cfparam name="prc.project.config.includeScanners" default="#arrayNew(1)#">
		<div class="mb-3">
			<label for="includeScanners" class="form-label">Include Scanners:</label>
			<input type="text" name="includeScanners" class="form-control" value="#encodeForHTMLAttribute(arrayToList(prc.project.config.includeScanners))#">
			<small class="form-text text-muted">Comma separated list of fixinator scanners to use, eg: xss,sqlinjection - if specified only these scanners will be used.</small>
		</div>

		<cfparam name="prc.project.config.goals" default="#arrayNew(1)#">
		<div class="mb-3">
			<label for="goals" class="form-label">Goals:</label>
			<select name="goals" id="goals" class="form-control">
				<option value="security"<cfif arrayIsEmpty(prc.project.config.goals) OR arrayFindNoCase(prc.project.config.goals, "security")> selected="selected"</cfif>>Security Only</option>
				<option value="compatibility"<cfif arrayFindNoCase(prc.project.config.goals, "compatibility")> selected="selected"</cfif>>Compatibility Only</option>
				<option value="security,compatibility"<cfif arrayFindNoCase(prc.project.config.goals, "security") AND arrayFindNoCase(prc.project.config.goals, "compatibility")> selected="selected"</cfif>>Security and Compatibility</option>
			</select>
			<small class="form-text text-muted">Does fixinator look for security issues, compatibility issues or both.</small>
		</div>

		<cfparam name="prc.project.config.engines" default="#arrayNew(1)#">
		<div class="mb-3">
			<label for="engines" class="form-label">Engines:</label>
			<input type="text" name="engines" class="form-control" value="#encodeForHTMLAttribute(arrayToList(prc.project.config.engines))#">
			<small class="form-text text-muted">Comma separated list of cfml engines your code runs on. For example: adobe@2025,lucee@7 omitting the version defaults to the latest.</small>
		</div>
      
		<div class="mb-3">
			<input type="submit" class="btn btn-outline-secondary" value="Save Project">
		</div>
    </form>
    </cfoutput>
  </div>
</div>
</div>