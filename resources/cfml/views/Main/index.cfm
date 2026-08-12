<cfoutput>
<div class="subnav container d-flex justify-content-end ">
	<div>
		<cfif prc.wizard IS "none">
			<a href="#event.buildLink("main.settings")#" class="btn btn-outline-secondary">Settings</a>

			<a href="#event.buildLink("project.create")#" class="btn btn-outline btn-outline-brand">Add Project</a>
		</cfif>

	</div>
</div>

<br>
<div class="container mb-4">
<cfif prc.wizard IS "login">
	<div class="card bg-brand mt-4 mb-4">
		<h4 class="card-header">Enter Your Fixinator Application Password</h4>
		<div class="card-body">
			<form method="POST">
				<cfif len(prc.message)>
					<div class="alert alert-danger mb-4">#encodeForHTML(prc.message)#</div>
				</cfif>
				<div class="mb-3">
		    		<label for="password sr-only">Password</label>
		    		<input type="password" id="password" name="password" class="form-control">
		    	</div>
		    	<div class="mb-3 text-right">
		    		<button type="submit" class="btn btn-outline-primary">Login</button>
		    	</div>	
			</form>
		</div>
	</div>

	

<cfelseif prc.wizard IS "setup">
	<cfparam name="prc.api_key" default="">
	<cfparam name="prc.api_url" default="">
	<cfparam name="prc.enterprise_path" default="">

	<cfif len(prc.message)>
		<div class="alert alert-danger mb-4">#encodeForHTML(prc.message)#</div>
	</cfif>

	<form method="POST">
		<div class="card mt-4 mb-4" id="setupWizardStep1">
			<h4 class="card-header">Fixinator Setup Wizard - Step 1</h4>
			<div class="card-body p-5">
				<cfoutput>
					<cfset isEnterprise = false>
					<cfif len(prc.enterprise_path) OR (len(prc.api_url) AND NOT find("api.fixinator.app", prc.api_url))>
						<cfset isEnterprise = true>
					</cfif>
					
					<div class="form-check mb-4">
					<h4>
						<input class="form-check-input apiTypeCheck" type="radio" name="apiType" id="apiTypeCloud" value="cloud" <cfif NOT isEnterprise> checked="checked"</cfif>>
						<label class="form-check-label" for="apiTypeCloud">
							Fixinator Cloud Scanning Service (api.fixinator.app)
						</label>
					</h4>
					</div>
					<div class="mt-2<cfif isEnterprise> hidden</cfif>" id="cloudApiConfig">
						<div class="m-4 p-4">
							<label for="name sr-only">Your Fixinator API Key</label>
							<input type="text" name="api_key" value="#encodeForHTMLAttribute(prc.api_key)#" class="form-control">
							<small class="form-text">Need an API Key? You can request a free, trial API key here: <cfif NOT request.isNativeApp><a href="https://fixinator.app/try/" target="_blank" rel="noopener"><code>fixinator.app/try/</code></a><cfelse><code>https://fixinator.app/try/</code></cfif></small>
						</div>
					</div>
					<div class="form-check mb-4">
					
					<h4>
						<input class="form-check-input apiTypeCheck" type="radio" name="apiType" id="apiTypeEnterprise" value="enterprise" <cfif isEnterprise> checked="checked"</cfif>>
						<label class="form-check-label" for="apiTypeEnterprise">
							Fixinator Enterprise (Scan Code Locally)
						</label>
					</h4>
					</div>
					<div class="mt-2<cfif NOT isEnterprise> hidden</cfif>" id="enterpriseURL">
						<div class="m-4 p-4">
							<div class="mb-2">
								<label for="name sr-only">Fixinator Enterprise Code Path</label>
								<input type="text" name="enterprise_path" class="form-control" value="#encodeForHTMLAttribute(prc.enterprise_path)#">
								<small class="form-text">Enter the path to an unzipped Fixinator Enterprise Installation folder, then click <em>Next</em>. This option requires a Fixinator Enterprise License.</small>
							</div>
							<input type="hidden" name="api_url" value="#encodeForHTMLAttribute(prc.api_url)#">
						</div>
					</div>

					

					<div class="mb-3 text-right">
						<cfif request.isNativeApp>
							<!--- for native app skip password (step 2 ) - it passes a secret through the userAgent --->
							<button type="submit" class="btn btn-outline-secondary">Finish</button>
						<cfelse>
							<!--- when running as a web app, allow a password (step 2) --->
							<button type="button" id="setupWizardStep1Button" class="btn btn-outline-secondary">Next</button>
						</cfif>
						
					</div>	
				
				</cfoutput>
			</div>
		</div>
		<div class="hidden card mt-4 mb-4" id="setupWizardStep2">
			<h4 class="card-header">Fixinator Setup Wizard - Step 2</h4>
			<div class="card-body p-5">

				<div class="mt-2">
					<label for="name sr-only">Application Password</label>
					<input type="password" name="password" class="form-control">
					<small class="form-text">Enter a password which you will use to access this application, or leave it blank if you do not want to password protect this application.</small>
				</div>

				<div class="mt-2 mb-3 text-right">
					<button type="submit" class="btn btn-outline-secondary">Finish</button>
				</div>	
			</div>
		</div>
	</form>
<cfelseif arrayLen(prc.projects) EQ 0>
	<div class="alert alert-info">
		Please add a project to get started
	</div>
<cfelse>
	<cfloop array="#prc.projects#" index="p">
		<div class="mt-4">

			<div class="card">
				
				<h5 class="card-header">#encodeForHTML(p.name)#</h5>
				
				<div class="card-body">
					<div class="row props">
						<div class="col-3 text-right"><strong>Path:</strong></div>
						<div class="col-9 text-muted">#encodeForHTML(p.path)#</div>
					</div>
					<div class="row props">
						<div class="col-3 text-right"><strong>Last Scan:</strong></div>
						<div class="col-9 text-muted"><cfif p.keyExists("last_scan_date") AND isDate(p.last_scan_date)>#encodeForHTML(p.last_scan_date)#<cfelse><em>Never</em><br><br><div class="alert alert-warning">Click the <em>Scan</em> button to run your first full scan</div></cfif></div>
					</div>
			    	<cfif p.keyExists("last_scan_id") AND len(p.last_scan_id)>

			    	</cfif>
				</div>
				<div class="card-footer">
					<cfif p.keyExists("last_scan_id") AND len(p.last_scan_id)>
						<a href="#event.buildLink('scan.view?projectID=#encodeForURL(p.id)#&scanID=#encodeForURL(p.last_scan_id)#')#" class="btn btn-outline btn-outline-secondary mr-2">Issues</a>
					</cfif>
				    <a href="#event.buildLink('scan.scan?projectID=#encodeForURL(p.id)#')#" class="btn btn-outline btn-outline-secondary mr-2">Scan</a>
				    <a href="#event.buildLink('project.edit?projectID=#encodeForURL(p.id)#')#" class="btn btn-outline btn-outline-secondary mr-2">Settings</a>
				</div>
			</div>
			
		</div>
	</cfloop>
</cfif>

</div>
</cfoutput>