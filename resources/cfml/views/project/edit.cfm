<div class="subnav">
    <div class="row">
    	<div class="col-6">
        	<a href="/" class="btn btn-outline btn-outline-brand">Back to Projects</a>
        </div>
        <div class="col-6 text-right">
        	<cfset session.projectRemoveCSRF = createUUID()>
        	<cfoutput>
        	<a href="#event.buildLink('project.remove?projectID=#encodeForURL(rc.projectID)#&csrf=#encodeForURL(session.projectRemoveCSRF)#')#" class="btn btn-outline btn-outline-brand">Remove Project</a>
        	</cfoutput>
        </div>
    </div>
</div>
<div class="container pt-4">

<div class="card bg-brand">
  <h2 class="card-header">Project Settings</h2>

  <div class="card-body">
    <cfoutput>
    <form action="#event.buildLink('project.save')#" method="POST">
		<input type="hidden" name="id" value="#encodeForHTMLAttribute(rc.projectID)#">
		<div class="form-group">
			<label for="name">Project Name:</label>
			<input type="text" name="name" class="form-control" value="#encodeForHTMLAttribute(prc.project.name)#" required="required">
		</div>
		<div class="form-group">
			<label for="path">Root File Path:</label>
			<input type="text" class="form-control" name="path" value="#encodeForHTMLAttribute(prc.project.path)#" required="required">
		</div>
		<cfparam name="prc.project.config" default="#structNew()#">

		<cfparam name="prc.project.config.minConfidence" default="high">
		
		<div class="form-group">
			<label for="minConfidence">Confidence Level:</label>

			<select name="minConfidence" id="minConfidence" class="form-control">
				<option value="high"<cfif prc.project.config.minConfidence IS "high"> selected="selected"</cfif>>High - Only show results we are highly confident to be a security issue</option>
				<option value="medium"<cfif prc.project.config.minConfidence IS "medium"> selected="selected"</cfif>>Medium</option>
				<option value="low"<cfif prc.project.config.minConfidence IS "low"> selected="selected"</cfif>>Low - Includes results that may not be a security issue</option>
				<option value="none"<cfif prc.project.config.minConfidence IS "none"> selected="selected"</cfif>>None - Includes suggestions</option>
			</select>
		</div>

		<cfparam name="prc.project.config.minSeverity" default="low">
		<div class="form-group">
			<label for="minSeverity">Severity Level:</label>

			<select name="minSeverity" id="minSeverity" class="form-control">
				<option value="high"<cfif prc.project.config.minSeverity IS "high"> selected="selected"</cfif>>High - Only show most severe issues</option>
				<option value="medium"<cfif prc.project.config.minSeverity IS "medium"> selected="selected"</cfif>>Medium</option>
				<option value="low"<cfif prc.project.config.minSeverity IS "low"> selected="selected"</cfif>>Low - Includes results that may be very low risk security issues</option>
			</select>
		</div>

		<cfparam name="prc.project.config.ignoreExtensions" default="#arrayNew(1)#">
		<div class="form-group">
			<label for="ignorePaths">Ignored File Extensions:</label>
			<input type="text" name="ignoreExtensions" class="form-control" value="#encodeForHTMLAttribute(arrayToList(prc.project.config.ignoreExtensions))#">
			<small class="form-text text-muted">Comma seperated list of file extensions, eg: txt,xyz,abc</small>
		</div>

		<cfparam name="prc.project.config.ignorePaths" default="#arrayNew(1)#">
		<div class="form-group">
			<label for="ignorePaths">Ignored Paths:</label>
			<textarea name="ignorePaths" class="form-control" rows="8" id="ignorePaths">#encodeForHTML(arrayToList(prc.project.config.ignorePaths, chr(13)))#</textarea>
			<small class="form-text text-muted">Add one path per line to exclude files or folders from the scan.</small>
			
		</div>

		<cfparam name="prc.project.config.ignoreScanners" default="#arrayNew(1)#">
		<div class="form-group">
			<label for="ignorePaths">Ignored Scanners:</label>
			<input type="text" name="ignoreScanners" class="form-control" value="#encodeForHTMLAttribute(arrayToList(prc.project.config.ignoreScanners))#">
			<small class="form-text text-muted">Comma seperated list of fixinator scanners to ignore, eg: xss,sql-injection</small>
		</div>


      
		<div class="form-group">
			<input type="submit" class="btn btn-outline-secondary" value="Save Project">
		</div>
    </form>
    </cfoutput>
  </div>
</div>
</div>