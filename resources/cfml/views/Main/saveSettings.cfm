<cfparam name="prc.message" default="">
<cfparam name="prc.success" type="boolean" default="false">
<cfoutput>
<div class="subnav">
  <div class="row">
  	<div class="col-6">
  		<a href="#event.buildLink('main')#" class="btn btn-outline-brand btn-outline">Projects</a>
  	</div>
  	<div class="col-6 text-right">
  		<a href="#event.buildLink("main.settings")#" class="btn btn-outline-secondary">Settings</a>

  		<a href="#event.buildLink("project.create")#" class="btn btn-outline btn-outline-brand">Add Project</a>
  	</div>	
  </div>
</div>
</cfoutput>
<div class="container pt-4">
	<cfif prc.success>
		<div class="alert alert-success">Settings Saved Successfully</div>
	<cfelse>
		<div class="alert alert-danger"><cfoutput>#encodeForHTML(prc.message)#</cfoutput></div>
	</cfif>
</div>