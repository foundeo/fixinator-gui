<cfoutput>
<div class="subnav">
	<div class="row">
		<div class="col-8 text-secondary">
			<div class="btn-group" role="group">
			    <button id="btnGroupDrop1" type="button" class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
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
		</div>
		<div class="col-4 text-right">
			<a href="#event.buildLink('scan.scan?projectID=#encodeForURL(prc.project.id)#')#" class="btn btn-outline-brand btn-outline">Re-Scan</a>
		</div>
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
	<cfloop list="#prc.scan.categories.keyList()#" index="cat">
		<cfif prc.scan.categories[cat].issues GT 0>
			<div class="card bg-brand text-dark mb-2">
				<a href="##cat_#encodeForHTMLAttribute(cat)#" data-toggle="collapse" aria-controls="cat_#encodeForHTMLAttribute(cat)#">
					<h3 class="card-header">
						<div class="row">
							<div class="col-10">
								<div class="catTitle">#encodeForHTML(prc.scan.categories[cat].name)# </div>
							</div>
							<div class="col-2 text-right">
								<cfset findings = prc.scan.categories[cat].issues>
								<span class="badge badge-pill badge-dark">#int(findings)#<!--- <cfif findings EQ 1>Finding<cfelse>Findings</cfif>---></span>
							</div>
						</div>
					</h3>
				</a>
				
				<div class="card-body">
					<div class="catDescription">#encodeForHTML(prc.scan.categories[cat].description)#</div>
					<div class="collapse" id="cat_#encodeForHTMLAttribute(cat)#">
					<cfloop array="#prc.scan.results#" index="result">
						<cfif result.id EQ cat>
							<cfset bClasses = ["badge-secondary","badge-info","badge-warning","badge-danger"]>
							<cfset sevText = ["INFO","LOW","MEDIUM","HIGH"]>
							<cfset confText = ["NO CONFIDENCE","LOW CONFIDENCE", "MEDIUM CONFIDENCE", "HIGH CONFIDENCE"]>
							<cfset sev = val(result.severity)+1>
							<cfif sev GT 4><cfset sev = 4><cfelseif sev LT 1><cfset sev = 1></cfif>
							<cfset conf = val(result.confidence)+1>
							<cfif conf GT 4><cfset conf = 4><cfelseif conf LT 1><cfset conf = 1></cfif>
							<div class="card text-dark m-2">
								<div class="card-header">
									<div class="row">
										<div class="col-8">
											<h4>#encodeForHTML(result.title)#</h4>
										</div>
										<div class="col-4 text-right">
											<h4><span class="badge #encodeForHTMLAttribute(bClasses[sev])#">#encodeForHTML(sevText[sev])#</span></h4>
										</div>	
									</div>
								</div>
								<div class="card-body">
									
									<div class="issuePath"><a href="#event.buildLink('scan.file?projectID=#encodeForURL(rc.projectID)#&scanID=#encodeForURL(rc.scanID)#&path=#urlEncodedFormat(result.path)#')#">#encodeForHTML(result.path)#</a> <span class="badge badge-light">Line: #encodeForHTML(result.line)#</span></div>
										
									<cfif result.keyExists("context") AND len(result.context)>
										<div class="row code-context">
											<div class="col-1 text-right line"><pre>#encodeForHTML(result.line)#:</pre></div>
											<div class="col-11"><pre>#encodeForHTML(trim(result.context))#</pre></div>
										</div>
									</cfif>
									<div class="issueMessage"><small class="text-muted">#encodeForHTML(result.description)#<br>#encodeForHTML(result.message)#</small></div>
									<div><span class="badge badge-light">#encodeForHTML(confText[conf])#</span></div>
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
								<div class="card-footer text-right">
									<a href="#event.buildLink('scan.file?projectID=#encodeForURL(rc.projectID)#&scanID=#encodeForURL(rc.scanID)#&path=#urlEncodedFormat(result.path)#')#" class="btn btn-outline btn-outline-secondary">
										<cfif local.fixable>Fix File<cfelse>View File</cfif>
									</a>
								</div>
							</div>
						</cfif>
					</cfloop>
					</div>
				</div>
				
			</div>
		</cfif>
	</cfloop>
</cfif>

<div class="card">
	<h4 class="card-header">Scan Summary</h4>
	<div class="card-body">
		
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
	      <div class="col-4 text-right"><strong>Ignored Extensions:</strong></div>
	      <div class="col-8">
	      	<cfif prc.scan.config.keyExists("ignoreExtensions") AND arrayLen(prc.scan.config.ignoreExtensions)>
	      		<code>#encodeForHTML( listChangeDelims( arrayToList(prc.scan.config.ignoreExtensions), ", ") )#</code>
	      	<cfelse>
	      		<code>None</code>
	      	</cfif>
	      </div>
	    </div>

	</div>
	<div class="card-footer text-right">
    	<a href="#event.buildLink('project.edit?projectID=#encodeForURL(prc.project.id)#')#" class="btn btn-outline-secondary btn-outline">Settings</a>
    </div>
</div>

</cfoutput>

</div>
