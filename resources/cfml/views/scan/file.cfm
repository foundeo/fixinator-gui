<cfset issues = []>
<cfparam name="rc.path" default="">

<cfif prc.fileIsPartOfScan>
	<cfset fileName = getFileFromPath(prc.fullPath)>
	<cfoutput>
		

		<cfif prc.fileChangedSinceScan>
			<div class="subnav">
				<div class="row">
					<div class="col-6">
						<a href="#event.buildLink('scan.view?projectID=#encodeForURL(rc.projectID)#&scanID=#encodeForURL(rc.scanID)#')#" class="btn btn-outline btn-outline-brand">Back to Results</a>
					</div>
					<div class="col-6 text-right">
						<a href="#event.buildLink('scan.rescan?projectID=#encodeForURL(rc.projectID)#&scanID=#encodeForURL(rc.scanID)#')#&path=#urlEncodedFormat(rc.path)#&csrf=#encodeForHTML(prc.csrf)#" class="btn btn-outline btn-outline-brand">Re-Scan File</a>
					</div>
				</div>
			</div>
			<div class="alert alert-warning">
				<cfif prc.fileStillExists>
					This file has changed on disk since it was last scanned. You can rescan this file to see if your changes have fixed the issues.
				<cfelse>
					It appears that the file has been deleted. You can click rescan to remove any issues in this file from the scan report.
				</cfif>	
				<br><small>
			</div>

		<cfelseif arrayLen(prc.issues) EQ 0>
			<div class="subnav">
				<a href="#event.buildLink('scan.view?projectID=#encodeForURL(rc.projectID)#&scanID=#encodeForURL(rc.scanID)#')#" class="btn btn-outline btn-outline-brand">Back to Results</a>
			</div>
			<div class="alert alert-success">
				No issues found in: <strong>#encodeForHTML(rc.path)#</strong>
			</div>
		<cfelse>
			<div class="subnav mb-4">
				<div class="row">
					<div class="col-6">
						<button type="button" class="btn btn-back btn-outline btn-outline-brand">Back to Results</button>
					</div>
					<div class="col-6 text-right">
						<button type="button" id="ignoreFileButton" class="btn btn-outline-secondary btn-secondary mr-4">Ignore File</button>
						<a href="#event.buildLink('scan.rescan?projectID=#encodeForURL(rc.projectID)#&scanID=#encodeForURL(rc.scanID)#')#&path=#urlEncodedFormat(rc.path)#&csrf=#encodeForHTML(prc.csrf)#" id="rescanButton" class="btn hidden btn-outline btn-outline-brand">Re-Scan File</a>
						<button type="button" id="saveFileButton" class="btn btn-outline-brand btn-outline">Save File</button>
					</div>
				</div>
			</div>
			
			<div id="differ" data-project-id="#encodeForHTMLAttribute(rc.projectID)#" data-scan-id="#encodeForHTMLAttribute(rc.scanID)#" data-path="#encodeForHTMLAttribute(rc.path)#" data-csrf="#encodeForHTMLAttribute(prc.csrf)#">
				<div class="acediff"></div>
			</div>
			<!--- reopen container --->
			<div class="container">

			<div id="differ-warnings"></div>

			<div class="card bg-brand mb-4 mt-4">
				<h2 class="card-header"><code>#encodeForHTML(fileName)#</code> <small>in <code>#encodeForHTML(getDirectoryFromPath(prc.issues[1].path))#</code></small></h2>
				<div class="card-body">
					<p><small><code>#encodeForHTML(prc.fullPath)#</code></small></p>
					<p>#arrayLen(prc.issues)# Issue<cfif arrayLen(prc.issues) NEQ 1>s</cfif> found in #encodeForHTML(fileName)#</p>
				</div>
			
			</div>


			<cfif arrayLen(prc.issues)>
				
				<cfset issueIndex = 0>
				<form>
				<cfloop array="#prc.issues#" index="issue">
					<cfset issueIndex++>
					<cfset bClasses = ["badge-secondary","badge-info","badge-warning","badge-danger"]>
					<cfset sevText = ["INFO","LOW","MEDIUM","HIGH"]>
					<cfset confText = ["NO CONFIDENCE","LOW CONFIDENCE", "MEDIUM CONFIDENCE", "HIGH CONFIDENCE"]>
					<cfset sev = val(issue.severity)+1>
					<cfif sev GT 4><cfset sev = 4><cfelseif sev LT 1><cfset sev = 1></cfif>
					<cfset conf = val(issue.confidence)+1>
					<cfif conf GT 4><cfset conf = 4><cfelseif conf LT 1><cfset conf = 1></cfif>
					<div class="card text-dark mb-4">
						<div class="card-header">
							<div class="row">
								<div class="col-8">
									<h4>#encodeForHTML(issue.title)#</h4>
								</div>
								<div class="col-4 text-right">
									<h4><span class="badge #encodeForHTMLAttribute(bClasses[sev])#">#encodeForHTML(sevText[sev])#</span></h4>
								</div>	
							</div>
						</div>
						<div class="card-body">

								
							<small class="text-muted"><cfif issue.keyExists("description")>#encodeForHTML(issue.description)#<br></cfif> #encodeForHTML(issue.message)# </small>

								
								
							<div><span class="badge badge-light">#encodeForHTML(confText[conf])#</span></div>

							<cfif issue.keyExists("context") AND len(issue.context)>
								<div class="row code-context">
									<div class="col-1 text-right line"><pre>#encodeForHTML(issue.line)#:</pre></div>
									<div class="col-11"><pre>#encodeForHTML(trim(issue.context))#</pre></div>
								</div>
							</cfif>
							
					
							<cfif issue.keyExists("fixes") AND arrayLen(issue.fixes)>
								<div class="form-group">
									<label for="fix_issue_#encodeForHTMLAttribute(issue.uid)#" class="bmd-label-floating">Fix Options:</label>
									<select name="fix_issue_#encodeForHTMLAttribute(issue.uid)#" id="fix_issue_#encodeForHTMLAttribute(issue.uid)#" class="form-control fix-select" data-uid="#encodeForHTMLAttribute(issue.uid)#">
									<cfset fixIndex = 0>	
									<cfloop array="#issue.fixes#" index="fix">
										<cfset fixIndex++>
										<option value="#int(fixIndex)#">
												<cfif NOT len(fix.fixCode)>
													Remove <code>#encodeForHTML(fix.replaceString)#</code>
												<cfelse>
													#encodeForHTML(fix.fixCode)#
												</cfif>
										</option>
									</cfloop>
										<option value="0">Don't Fix -- Keep As Is</option>
									</select>
								</div>
							<cfelse>
								<!--- not fixable but could be ignored --->

							</cfif>
						</div><!--- card-body --->
					</div><!--- card --->
				</cfloop>
				</form>
			</cfif>
		</cfif>

	
	
	

	</cfoutput>

	</div>

<cfelse>
	<div class="alert alert-danger">
		Invalid Path
	</div>
</cfif>