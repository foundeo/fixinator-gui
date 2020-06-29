<cfparam name="prc.message" default="">
<cfparam name="prc.success" type="boolean" default="false">

<!---
<cfif prc.success>
	<div class="alert alert-success">Scan Finished</div>
<cfelse>
	<div class="alert alert-danger"><cfoutput>#encodeForHTML(prc.message)#</cfoutput></div>
</cfif>
--->
<cfoutput>
<div class="container pt-4">
<div class="alert alert-info mt-4">
	Scanning your code
</div>

<div class="progress" data-project-id="#encodeForHTMLAttribute(rc.projectID)#">
  <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" aria-valuemin="0" aria-valuemax="100"></div>
</div>
<div class="mt-2 text-light" id="textProgress"></div>

<div class="row" id="loadingImages">
	<div class="col-2"></div>
	<div class="col-8 text-center">
		<img src="/assets/images/undraw_sync_files_xb3r.svg" width="100" height="100" id="loadingFileLeft" alt="file check">
		<img src="/assets/images/undraw_sync_files_green.svg" width="100" height="100" id="loadingFileRight" alt="file check">
		<img src="/assets/images/undraw_functions_egi3.svg" class="img-fluid" alt="Loading Functions" id="loadingFunction">
		<img src="/assets/images/undraw_completed_ngx6.svg" class="img-fluid hidden" alt="Scan Complete" id="loadingComplete">
		
	</div>
	<div class="col-2"></div>
</div>

<div id="errorHelp" class="mt-4 hidden">
	<div class="card bg-brand">
		<h4 class="card-header">It looks like you hit a snag</h4>
		
		<div class="card-body">
			<h5 class="card-title mb-4">Here are some things you can try to figure out the problem.</h5>
			
			<h6>Are you attempting to scan a directory using a Free Trial API Key?</h6>
			<p class="">If so you can <a href="#event.buildLink('project.edit?projectID=#encodeForURL(rc.projectID)#')#">Edit Project Settings</a> and set the path to point to a file instead of a directory. We know this limitation is annoying, but we can't give away the farm for free.</p>

			<h6 class="mt-4">Did you specify the correct path in project settings?</h6>
			<p class="">If not you can <a href="#event.buildLink('project.edit?projectID=#encodeForURL(rc.projectID)#')#">Edit Project Settings</a> to fix the path.</p>
			<h6 class="mt-4">Did you specify the correct API Key?</h6>
			<p>Make sure you have entered the API key correctly in settings.</p>

			<h6 class="mt-4">Is your API key over its monthly quota? (429 Errors)</h6>
			<p class="">You may need to upgrade your Fixinator Plan to allow more scans per month, or if it is a one time thing you can contact us and we can give you some extra scans for the month. We'll only do that once or twice however, so if you expect you will hit the limit frequently you are better off upgrading. Contact Us.</p>

			<h6 class="mt-4">Still not sure?</h6>
			<p class="">Try contacting Foundeo Inc. for help: <code>https://foundeo.com/contact/</code></p>
		</div>
	</div>

</div>

</div>
</cfoutput>
