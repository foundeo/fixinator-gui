<cfoutput>
<div class="container subnav d-flex justify-content-between">
	<div class="btn-group" role="group">
		<button id="btnGroupDrop1" type="button" class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
			<cfoutput>#encodeForHTML(prc.project.name)#</cfoutput>
		</button>
		<div class="dropdown-menu" aria-labelledby="btnGroupDrop1">
			<cfloop array="#prc.projects#" index="p">
			<cfif p.keyExists("last_scan_date") AND isDate(p.last_scan_date)>
				<a class="dropdown-item" href="#event.buildLink('scan.view?projectID=#encodeForURL(p.id)#&scanID=#encodeForURL(p.last_scan_id)#')#">#encodeForHTML(p.name)#</a>
			</cfif>
			</cfloop>
			
			<div class="dropdown-divider"></div>
			<a class="dropdown-item" href="#event.buildLink('project.create')#">Add Project</a>
		</div>
	</div>
	<div class="text-right">
		<a href="#event.buildLink('project.edit?projectID=#encodeForURL(prc.project.id)#')#" class="btn btn-outline-secondary btn-outline mr-4">Project Settings</a>
		<a href="#event.buildLink('scan.scan?projectID=#encodeForURL(prc.project.id)#')#" class="btn btn-outline-brand btn-outline">Re-Scan</a>
	</div>
</div>
</cfoutput>



<cfloop list="#prc.scan.categories.keyList()#" index="cat">
	<cfset prc.scan.categories[cat].issues = 0>
	<cfloop array="#prc.scan.results#" index="result">
		<cfif result.id IS cat>
			<cfset prc.scan.categories[cat].issues++>
		</cfif>
	</cfloop>
</cfloop>

<div class="container mt-4">
<cfoutput>
<cfif arrayLen(prc.scan.results) EQ 0>
	<div class="alert alert-success">Yay! No issues.</div>

	<div class="row m-4 p-4">
		<div class="col-2"></div>
		<div class="col-8">
			<cfif randRange(1,2, "SHA1PRNG") EQ 1>
				<img src="/assets/images/undraw_festivities_tvvj.svg" class="img-fluid" alt="festivities">
			<cfelse>
				<img src="/assets/images/undraw_confirmation_2uy0.svg" class="img-fluid" alt="check mark">
			</cfif>
		</div>
		<div class="col-2"></div>
	</div>
	
	<cfif NOT prc.scan.config.keyExists("minConfidence") OR prc.scan.config.minConfidence IS "high">
		<div class="alert alert-warning">Tip: Your last scan was conducted in <em>High Confidence</em> mode, you can try decreasing the confidence level and you may see more results.</div>
	<cfelseif prc.scan.config.keyExists("minSeverity") AND prc.scan.config.minSeverity IS NOT "low">
		<div class="alert alert-warning">Tip: Your last scan was conducted with a minimum severity level of <em>#encodeForHTML(prc.scan.config.minSeverity)#</em>, you can try lowering the severity level and you may see more results.</div>
	</cfif>
	
<cfelse>
	<cfset hasIssues = false>
	<cfloop list="#prc.scan.categories.keyList()#" index="cat">
		<cfif prc.scan.categories[cat].issues GT 0>
			<cfset hasIssues = true>
			<div class="card mb-2">
				<a href="##cat_#encodeForHTMLAttribute(cat)#" class="headerLink" data-toggle="collapse" data-bs-toggle="collapse" aria-controls="cat_#encodeForHTMLAttribute(cat)#">
					<h4 class="card-header d-flex justify-content-between">
						<div class="catTitle">#encodeForHTML(prc.scan.categories[cat].name)# </div>
						
						<div class="catCount">
							<cfset findings = prc.scan.categories[cat].issues>
							<span class="badge bg-secondary">#int(findings)#<!--- <cfif findings EQ 1>Finding<cfelse>Findings</cfif>---></span>
						</div>
					</h4>
				</a>
				
				<div class="card-body collapse" id="cat_#encodeForHTMLAttribute(cat)#">
					<div class="catDescription">#encodeForHTML(prc.scan.categories[cat].description)#</div>
					<div class="" >
					<cfloop array="#prc.scan.results#" index="result">
						<cfif result.id EQ cat>
							<cfset bClasses = ["bg-secondary","bg-info","bg-warning","bg-danger"]>
							<cfset sevText = ["INFO","LOW","MEDIUM","HIGH"]>
							<cfset confText = ["NO CONFIDENCE","LOW CONFIDENCE", "MEDIUM CONFIDENCE", "HIGH CONFIDENCE"]>
							<cfset sev = val(result.severity)+1>
							<cfif sev GT 4><cfset sev = 4><cfelseif sev LT 1><cfset sev = 1></cfif>
							<cfset conf = val(result.confidence)+1>
							<cfif conf GT 4><cfset conf = 4><cfelseif conf LT 1><cfset conf = 1></cfif>
							<div class="card m-2">
								<cfif NOT result.keyExists("uid")><cfset result.uid=createUUID()></cfif>
								
									<div class="card-header d-flex justify-content-between">
										<div>
											<a href="##item_#encodeForHTMLAttribute(result.uid)#" class="headerLink" data-toggle="collapse" data-bs-toggle="collapse" aria-controls="item_#encodeForHTMLAttribute(result.uid)#">
												<h5>
													<cfif result.title IS prc.scan.categories[cat].name>
														#encodeForHTML(listLast(result.path, "/\"))#<cfif val(result.line) NEQ 0> on line #encodeForHTML(result.line)#</cfif>
													<cfelse>
														#encodeForHTML(result.title)#
													</cfif>
												</h5>
											</a>
										</div>
										<div>
											<span class="badge bg-secondary">#encodeForHTML(confText[conf])#</span>
											<span class="badge #encodeForHTMLAttribute(bClasses[sev])#" title="Severity">#encodeForHTML(sevText[sev])#</span>
										</div>
									</div>
								
								<div class="card-body">
									
									<!---<div class="issuePath"><a href="#event.buildLink('scan.file?projectID=#encodeForURL(rc.projectID)#&scanID=#encodeForURL(rc.scanID)#&path=#urlEncodedFormat(result.path)#')#">#encodeForHTML(result.path)#</a> <span class="badge">Line: #encodeForHTML(result.line)#</span></div>--->
										
									<cfif result.keyExists("context") AND len(result.context)>
										<div class="row code-context">
											<div class="col-1 text-right line"><pre>#encodeForHTML(result.line)#:</pre></div>
											<div class="col-11"><pre>#encodeForHTML(trim(result.context))#</pre></div>
										</div>
									</cfif>
									<div class="collapse" id="item_#encodeForHTMLAttribute(result.uid)#">
										<div class="issueMessage"><small class="text-muted">#encodeForHTML(result.description)#<br>#encodeForHTML(result.message)#</small></div>
										<div><span class="badge bg-secondary">#encodeForHTML(confText[conf])#</span></div>
										<cfset local.fixable = false>									
										<cfif result.keyExists("fixes") AND isArray(result.fixes) AND arrayLen(result.fixes) GT 0>
											<hr>
											<cfset local.fixable = true>
											<h4 class="mb-3">Possible Fixes</h4>
											<cfloop array="#result.fixes#" index="fix">
												<strong>#encodeForHTML(fix.title)#</strong>
												<div class="row justify-content-end">
													<div class="col-11">
														<cfif NOT len(fix.fixCode)>
															Remove <code>#encodeForHTML(fix.replaceString)#</code>
														<cfelseif NOT len(fix.replaceString)>
															Insert <code>#encodeForHTML(fix.fixCode)#</code>
														<cfelse>
															Replace <code>#encodeForHTML(fix.replaceString)#</code> with <code>#encodeForHTML(fix.fixCode)#</code>
														</cfif>
													</div>
												</div>
											</cfloop>
										</cfif>
									</div>
								</div>
								<div class="card-footer d-flex justify-content-between">
									<div>
										<cfif NOT request.isNativeApp>
											<cfset fullPath = prc.fixinatorClient.normalizeSlashes(prc.scan.gui.base_path & result.path)>
											<a href="vscode://file/#encodeForHTMLAttribute(fullPath)#:#encodeForHTML(result.line)#" class="openInEditor" title="Open file in VS Code">
										</cfif>
										<small><code>#encodeForHTML(result.path)#:#encodeForHTML(result.line)#</code></small>
										<cfif NOT request.isNativeApp>
											</a>
										</cfif>
									</div>
									<div>
										<a href="#event.buildLink('scan.file?projectID=#encodeForURL(rc.projectID)#&scanID=#encodeForURL(rc.scanID)#&path=#urlEncodedFormat(result.path)#')#" class="btn btn-outline btn-outline-secondary">
											<cfif local.fixable>Fix File<cfelse>View File</cfif>
										</a>
									</div>
									
								</div>
							</div>
						</cfif>
					</cfloop>
					</div>
				</div>
				
			</div>
		</cfif>
	</cfloop>

	<div class="card mb-2">
		<cfset byFile = {}>
		<cfloop array="#prc.scan.results#" index="result">
			<cfif NOT byFile.keyExists(result.path)>
				<cfset byFile[result.path] = {"issues":0}>
			</cfif>
			<cfset byFile[result.path].issues++>
		</cfloop>
		<a href="##byFile" class="headerLink " data-toggle="collapse" data-bs-toggle="collapse" aria-controls="byFile">
			<h4 class="card-header d-flex justify-content-between">
				<div>By File</div>
				<div><span class="badge bg-secondary">#structCount(byFile)# Files</span></div>
			</h4>

		</a>
		<div class="card-body collapse" id="byFile">
			
			<table class="table table-striped">
				<tr>
					<th>Path</th>
					<th>Issues</th>
					<th>&nbsp;</th>
				</tr>
				<cfloop collection="#byFile#" item="filePath">
					<tr>
						<td>
							<cfif NOT request.isNativeApp>
								<cfset fullPath = prc.fixinatorClient.normalizeSlashes(prc.scan.gui.base_path & filePath)>
								<a href="vscode://file/#encodeForHTMLAttribute(fullPath)#" class="openInEditor" title="Open file in VS Code"><small><code>#encodeForHTML(filePath)#</code></small></a>
							<cfelse>
								<small><code>#encodeForHTML(filePath)#</code></small>
							</cfif>
						</td>
						<td>#int(byFile[filePath].issues)#</td>
						<td>
							<a href="#event.buildLink('scan.file?projectID=#encodeForURL(rc.projectID)#&scanID=#encodeForURL(rc.scanID)#&path=#urlEncodedFormat(filePath)#')#" class="btn btn-outline btn-outline-secondary btn-sm">
								View
							</a>
						</td>
					</tr>
				</cfloop>
			</table>
		</div>
	</div>

</cfif>

<div class="card">
	<a href="##scanSummary" class="headerLink" data-toggle="collapse" data-bs-toggle="collapse" aria-controls="scanSummary">
		<h4 class="card-header">Scan Summary</h4>
	</a>
	<div class="card-body collapse" id="scanSummary">
		
		<div class="row props">
	      <div class="col-4 text-right"><strong>Files Scanned:</strong></div>
	      <div class="col-8"><code>#int(prc.scan.gui.file_count)#</code></div>
	    </div>
	    <div class="row props">
	      <div class="col-4 text-right"><strong>Issue Count:</strong></div>
	      <div class="col-8"><code>#arrayLen(prc.scan.results)#</code></div>
	    </div>
	    <div class="row props">
	      <div class="col-4 text-right"><strong>Base Path:</strong></div>
	      <div class="col-8"><code>#encodeForHTML(prc.scan.gui.base_path)#</code></div>
	    </div>
	    <div class="row props">
	      <div class="col-4 text-right"><strong>Full Scan Date:</strong></div>
	      <div class="col-8"><code>#encodeForHTML(prc.scan.gui.scan_date)#</code></div>
	    </div>
	    <cfif prc.scan.gui.keyExists("updated") AND prc.scan.gui.updated IS NOT prc.scan.gui.scan_date>
		    <div class="row props">
		      <div class="col-4 text-right"><strong>Scan Updated:</strong></div>
		      <div class="col-8"><code>#encodeForHTML(prc.scan.gui.updated)#</code></div>
		    </div>
		</cfif>
		<cfif prc.scan.config.keyExists("minConfidence")>
			<div class="row props">
		      <div class="col-4 text-right"><strong>Confidence Level:</strong></div>
		      <div class="col-8"><code>#encodeForHTML(prc.scan.config.minConfidence)#</code></div>
		    </div>
		</cfif>
		<cfif prc.scan.config.keyExists("minSeverity")>
			<div class="row props">
		      <div class="col-4 text-right"><strong>Severity Level:</strong></div>
		      <div class="col-8"><code>#encodeForHTML(prc.scan.config.minSeverity)#</code></div>
		    </div>
		</cfif>
		<div class="row props">
	      <div class="col-4 text-right"><strong>Ignored Paths:</strong></div>
	      <div class="col-8">
	      	<cfif prc.scan.config.keyExists("ignorePaths") AND arrayLen(prc.scan.config.ignorePaths)>
      			<cfloop array="#prc.scan.config.ignorePaths#" index="p">
      				<code>#encodeForHTML(p)#</code><br>
      			</cfloop>
	      	<cfelse>
	      		<code>None</code>
	      	</cfif>
	      </div>
	    </div>
	    <div class="row props">
	      <div class="col-4 text-right"><strong>Ignored Scanners:</strong></div>
	      <div class="col-8">
	      	<cfif prc.scan.config.keyExists("ignoreScanners") AND arrayLen(prc.scan.config.ignoreScanners)>
	      		
      			<cfloop array="#prc.scan.config.ignoreScanners#" index="s">
      				<code>#encodeForHTML(s)#</code><br>
      			</cfloop>
	      		
	      	<cfelse>
	      		<code>None</code>
	      	</cfif>
	      </div>
	    </div>
		<div class="row props">
	      <div class="col-4 text-right"><strong>Include Scanners:</strong></div>
	      <div class="col-8">
	      	<cfif prc.scan.config.keyExists("includeScanners") AND arrayLen(prc.scan.config.includeScanners)>
	      		
      			<cfloop array="#prc.scan.config.includeScanners#" index="s">
      				<code>#encodeForHTML(s)#</code><br>
      			</cfloop>
	      		
	      	<cfelse>
	      		<code>None</code>
	      	</cfif>
	      </div>
	    </div>
	    <div class="row props">
	      <div class="col-4 text-right"><strong>Ignored Extensions:</strong></div>
	      <div class="col-8">
	      	<cfif prc.scan.config.keyExists("ignoreExtensions") AND arrayLen(prc.scan.config.ignoreExtensions)>
	      		<code>#encodeForHTML( listChangeDelims( arrayToList(prc.scan.config.ignoreExtensions), ", ") )#</code>
	      	<cfelse>
	      		<code>None</code>
	      	</cfif>
	      </div>
	    </div>
		<br>
		
	</div>

</div>

</cfoutput>

</div>
<br><br>