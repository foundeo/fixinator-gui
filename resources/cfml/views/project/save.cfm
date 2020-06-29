<cfparam name="prc.message" default="">
<cfparam name="prc.success" type="boolean" default="false">
<cfparam name="prc.projectID" default="#createUUID()#" type="uuid">
<div class="subnav">
	<div class="row">
		<div class="col-6">
			<cfoutput><a href="#event.buildLink('main')#" class="btn btn-outline-brand btn-outline">Back</a></cfoutput>
		</div>
		<div class="col-6 text-right">
			<cfif prc.success>
				<cfoutput>
					<a href="#event.buildLink('scan.scan?projectID=#encodeForURL(prc.projectID)#')#" class="btn btn-outline-brand btn-outline">Scan Project</a>
				</cfoutput>
			</cfif>
		</div>
	</div>
</div>


<div class="container pt-4">
	<cfif prc.success>
		<div class="alert alert-success">Project Saved Successfully</div>
		<p>
	<cfelse>
		<div class="alert alert-danger"><cfoutput>#encodeForHTML(prc.message)#</cfoutput></div>
	</cfif>
</div>