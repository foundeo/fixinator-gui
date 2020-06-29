<div class="subnav">
    <div class="">
        <a href="/" class="btn btn-outline btn-outline-brand">Back to Projects</a>
    </div>
</div>
<div class="container pt-4">
<div class="card bg-brand">
  <h2 class="card-header">Add Project</h2>
  <div class="card-body">
    <cfoutput>
    <form action="#event.buildLink('project.save')#" method="POST">
    	<input type="hidden" name="id" value="#createUUID()#">
    	<div class="form-group">
    		<label for="name">Project Name:</label>
    		<input type="text" name="name" class="form-control" required="required">
            <small class="form-text">The name of a chunk of code you want to scan.</small>
    	</div>
    	<div class="form-group">
        	<label for="path">Root File Path:</label>
        	<cfif server.os.name contains "Windows">
        		<cfset placeholder = "c:\my\code\">
        	<cfelse>
        		<cfset placeholder = "/path/to/my/code/">
        	</cfif>
        	<input type="text" class="form-control" name="path" value="" placeholder="#encodeForHTMLAttribute(placeholder)#" required="required">
            <small class="form-text">A file system path to a folder or file.</small>
      </div>

      
      
    	<div class="form-group">
    		<input type="submit" class="btn btn-outline-secondary" value="Save Project">
    	</div>
    </form>
    </cfoutput>
  </div>
</div>
</div>