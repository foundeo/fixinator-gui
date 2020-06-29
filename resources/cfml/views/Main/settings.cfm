<div class="subnav">
  <cfoutput><a href="#event.buildLink('main')#" class="btn btn-outline-brand btn-outline">Back</a></cfoutput>
</div>
<div class="container pt-4 mb-4">
  <div class="card bg-brand">
  <h4 class="card-header">Settings</h4>
  <div class="card-body">
    <cfoutput>
    <form action="#event.buildLink('main.saveSettings')#" method="POST">
    	<cfset api_key = "">
      <cfset api_url = "">
      <cfif prc.settings.keyExists("api_key")>
        <cfset api_key = prc.settings.api_key>
      </cfif>
      <cfif prc.settings.keyExists("api_url")>
        <cfset api_url = prc.settings.api_url>
      </cfif>
    	<div class="form-group">
    		<label for="name">Fixinator API Key</label>
    		<input type="text" name="api_key" class="form-control" value="#encodeForHTML(api_key)#">
        <small class="form-text">Your Fixinator API Key. Leave empty to use environment variable.</small>
    	</div>

      <div class="form-group">
        <label for="name">Fixinator Enterprise API Endpoint URL</label>
        <input type="text" name="api_url" class="form-control" value="#encodeForHTML(api_url)#">
        <small class="form-text">This is a URL pointing to a Fixinator Enterprise Scanning Server. Leave blank to use environment variable or the Fixinator Cloud Scanning Server</small>
      </div>

      <div class="form-group">
        <input type="submit" value="Save Settings" class="btn btn-outline btn-outline-secondary">
      </div>
    </form>
    </cfoutput>
  </div>
</div>
<cfoutput>
<div class="card mt-4">
  <h4 class="card-header">Fixinator Information</h4>
  <div class="card-body">
    <div class="row props">
      <div class="col-2 text-right"><strong>Fixinator GUI Version:</strong></div>
      <div class="col-10"><code>#encodeForHTML(prc.fixinatorGUIVersion)#</code></div>
    </div>
    <div class="row props">
      <div class="col-2 text-right"><strong>Fixinator Client Version:</strong></div>
      <div class="col-10"><code>#encodeForHTML(prc.fixinatorClientVersion)#</code></div>
    </div>
    <div class="row props">
      <div class="col-2 text-right"><strong>Fixinator API URL:</strong></div>
      <div class="col-10"><code>#encodeForHTML(prc.fixinatorClient.getAPIURL())#</code></div>
    </div>
    <div class="row props">
      <div class="col-2 text-right"><strong>Fixinator API Key:</strong></div>
      <div class="col-10">
        <cfset key = prc.fixinatorClient.getAPIKey()>
        <cfif key IS NOT "UNDEFINED">
          <cfset key = left(key, 5) & repeatString("*", len(key)-5)>
        </cfif>
        <code>#encodeForHTML(key)#</code>
      </div>
    </div>
    <div class="row props">
      <div class="col-2 text-right"><strong>Fixinator GUI Data Directory:</strong></div>
      <div class="col-10"><code>#encodeForHTML(prc.dataDir)#</code></div>
    </div>

    
  </div>
</div>
</cfoutput>
