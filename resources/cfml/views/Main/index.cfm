<cfoutput>
<div class="subnav">
	<div class="text-right">
		<cfif prc.wizard IS "none">
			<a href="#event.buildLink("main.settings")#" class="btn btn-outline-secondary">Settings</a>

			<a href="#event.buildLink("project.create")#" class="btn btn-outline btn-outline-brand">Add Project</a>
		</cfif>

	</div>
</div>

<br>
<div class="container mb-4">
<cfif prc.wizard IS "api_key">
	<div class="card bg-brand mt-4 mb-4">
		<h4 class="card-header">Enter Your Fixinator API Key</h4>
		<div class="card-body">
			<form method="POST">
				<div class="form-group">
		    		<label for="name sr-only">Your Fixinator API Key</label>
		    		<input type="text" name="api_key" class="form-control">
		        	<small class="form-text">Paste in your Fixinator API key, then click <em>Next</em></small>
		    	</div>
		    	<div class="form-group text-right">
		    		<button type="submit" class="btn btn-outline-secondary">Next</button>
		    	</div>	
			</form>
		</div>
	</div>

	<div class="card mt-4 mb-4">
		<h4 class="card-header">Need an API Key?</h4>
		<div class="card-body">
			<p>You can request a free, trial API key here: <code>https://fixinator.app/try/</code></p>
		</div>
	</div>

<cfelseif prc.wizard IS "api_url">
	<cfparam name="rc.api_key" default="">
	<cfparam name="rc.api_url" default="">
	<div class="card bg-brand mt-4 mb-4">
		<h4 class="card-header">Fixinator Scanning Server</h4>
		<div class="card-body">
			<cfoutput>
			<form action="#event.buildLink('main.saveSettings')#" method="POST">
				<input type="hidden" name="api_key" value="#encodeForHTMLAttribute(rc.api_key)#">
				<div class="form-check mb-4">
				  <input class="form-check-input apiTypeCheck" type="radio" name="apiType" id="apiTypeCloud" value="cloud" <cfif NOT len(rc.api_url)> checked="checked"</cfif>>
				  <label class="form-check-label" for="apiTypeCloud">
				    Fixinator Cloud Scanning Service (api.fixinator.app)
				  </label>
				</div>
				<div class="form-check mb-4">
				  <cfset checked = len(rc.api_url)>
		    	  <cfif NOT checked>
		    			<cfset rc.api_url = "http://127.0.0.1:48443/scan/">
		    	  </cfif>
				  <input class="form-check-input apiTypeCheck" type="radio" name="apiType" id="apiTypeEnterprise" value="enterprise" <cfif checked> checked="checked"</cfif>>
				  <label class="form-check-label" for="apiTypeEnterprise">
				    Fixinator Enterprise Scanning Server (Scan Code Locally)
				  </label>
				</div>
				<div class="mt-2form-group hidden" id="enterpriseURL">
		    		<label for="name sr-only">Fixinator API URL</label>
		    		<input type="text" name="api_url" class="form-control" value="#encodeForHTMLAttribute(rc.api_url)#">
		        	<small class="form-text">Enter your Fixinator API Server address, then click <em>Next</em>. This option requires a Fixinator Enterprise License.</small>
				</div>
		    	<div class="form-group text-right">
		    		<button type="submit" class="btn btn-outline-secondary">Next</button>
		    	</div>	
			</form>
			</cfoutput>
		</div>
	</div>
<cfelseif arrayLen(prc.projects) EQ 0>
	<div class="alert alert-warning">
		Please add a project to get started
	</div>
<cfelse>
	<cfloop array="#prc.projects#" index="p">
		<div class="row mt-4">

			<div class="card text-dark bg-brand" style="width:100%;">
				
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
				<div class="card-footer bg-brand">
					<cfif p.keyExists("last_scan_id") AND len(p.last_scan_id)>
						<a href="#event.buildLink('scan.view?projectID=#encodeForURL(p.id)#&scanID=#encodeForURL(p.last_scan_id)#')#" class="btn btn-outline mr-2">Issues</a>
					</cfif>
				    <a href="#event.buildLink('scan.scan?projectID=#encodeForURL(p.id)#')#" class="btn btn-outline mr-2">Scan</a>
				    <a href="#event.buildLink('project.edit?projectID=#encodeForURL(p.id)#')#" class="btn btn-outline mr-2">Settings</a>
				</div>
			</div>
			
		</div>
	</cfloop>
</cfif>

</div>
</cfoutput>