<cftry>
	<cfset request.exception = prc.exception>
	<cffunction name="renderView" output="true">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		<div class="subnav">
			<button type="button" class="btn btn-outline btn-outline-brand btn-back">Back</button>
		</div>
		
		<div class="container pt-4">
			<div class="card card-brand">
				<h4 class="card-header">Fixinator GUI Internal Exception</h4>
				<div class="card-body">
					<div class="alert alert-danger">#encodeForHTML(request.exception.getMessage())# #encodeForHTML(request.exception.getDetail())#</div>
					<p>For assistance please contact Foundeo Inc: <code>https://foundeo.com/contact/</code></p>
					<cfif isArray(request.exception.getTagContext())>
						<h5>Context</h5>
						<ul>
							<cfloop array="#request.exception.getTagContext()#" index="local.ctx">
								<li>#encodeForHTML(local.ctx.template)#:#val(local.ctx.line)#</li>
							</cfloop> 
						</ul>
					</cfif>
					<h5>Stacktrace</h5>
					<pre>#encodeForHTML(request.exception.getStacktrace())#</pre>
				</div>
			</div>
		</div>
	</cffunction>
	<cfinclude template="../../layouts/Main.cfm">

	<cfcatch type="any">
		<h2>Exception in the Exception Handler...</h2>
		<cfif getFunctionList().keyExists("encodeForHTML")>
			<p>#encodeForHTML(cfcatch.exception)#</p>
		<cfelse>
			<p>#xmlFormat(cfcatch.exception)#</p>
		</cfif>
	</cfcatch>
</cftry>	