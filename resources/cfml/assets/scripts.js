if (window.module) module = window.module;
$(document).ready(function() {

	$('.apiTypeCheck').change(function() {
		if ($(this).is(':checked') && $(this).val() == "enterprise") {
			$('#enterpriseURL').removeClass("hidden");
		} else {
			$('#enterpriseURL').addClass("hidden");
		}
	})

	$('.progress').each(function() {

		var projectID = $(this).data("project-id");
		if (projectID && projectID.length == 35) {
			var done = false;
			$.ajax({method:'POST', url:'/scan/run?projectID=' + projectID})
				.done(function(data) {
					done=true;
					console.log(data);
					if (data.error) {
						$('.alert').addClass('alert-danger');
						$('.alert').removeClass('alert-info');
						$('.alert').text(err.error);
						$('.progress-bar').addClass('bg-danger');
						$('.progress-bar').css('width', '100%');
						$('#errorHelp').removeClass('hidden');
					} else {
						if (data.scanID && data.scanID.length == 35) {
							$('.alert').addClass('alert-success');
							$('.alert').removeClass('alert-info');
							$('.alert').text("Finished Scanning");
							$('.progress-bar').addClass('bg-success');
							$('.progress-bar').css('width', '100%');
							$('#textProgress').text('');
							$('#loadingFileLeft').addClass("hidden");
							$('#loadingFileRight').addClass("hidden");
							$('#loadingFunction').addClass("hidden");
							$('#loadingComplete').removeClass("hidden");
							$('#loadingComplete').addClass("appear");
							setTimeout(function() {
								document.location = '/scan/view?projectID=' + projectID + '&scanID=' + data.scanID;
							}, 2500);
						} 
					}

				}).fail(function(jqXHR, textStatus, errorThrown) {
					done=true;
					$('.alert').addClass('alert-danger');
					$('.alert').removeClass('alert-info');
					$('.progress-bar').addClass('bg-danger');
					$('.progress-bar').css('width', '100%');
					$('#textProgress').text('The scan did not complete due to errors.');
					$('.alert').text("An error occurred while scanning your code.");
					$('#errorHelp').removeClass('hidden');
					$('#loadingImages').addClass('hidden');
					if (jqXHR.responseJSON && jqXHR.responseJSON.error && jqXHR.responseJSON.error.length > 0) {
						$('.alert').text(jqXHR.responseJSON.error);
						if (jqXHR.responseJSON.error.indexOf("Free API") != -1) {
							$('#textProgress').text('Update your project settings to point to a file instead of a directory. The scan did not complete due to license restrictions.');
						}
					}
				});
			updateProgress();
			function updateProgress() {
				if (done) {
					return;
				}
				$.ajax({method:'POST', url:'/scan/progress?projectID=' + projectID}).done(function(data) {
					if (!done) {
						console.log(data);
						if (typeof(data.percent) != 'undefined') {
							$('.progress-bar').css('width', data.percent + '%');
							if (data.totalCount) {
								var txt = data.currentCount + ' of ' + data.totalCount;
								$('#textProgress').text(txt);
							}
							setTimeout(updateProgress, 300);
						}
					}
				});
			}
		}
	});

	//disable js editor suggestions
	if (window.ace && window.ace.config) {
		window.ace.config.setDefaultValue("session", "useWorker", false);
		window.ace.config.setDefaultValue("editor", "theme", "ace/theme/monokai");
	}

	var differ = null;

	function loadDiff() {
		var data = getDifferData();
		var fixSelects =  $('select.fix-select').toArray();
		var fixArray = [];
		data.fixes = "[]";
		for (var i=0;i<fixSelects.length;i++) {
			fixArray.push( { uid: $(fixSelects[i]).data('uid'), fix: $(fixSelects[i]).val() })
		}
		data.fixes = JSON.stringify(fixArray);

		$.ajax({method:'POST', url:'/scan/differ', data:data}).done(function(result) {
			
			$('.acediff').html('');
			if (!result.fixed || result.fixed.length == 0) {
				result.fixed = result.source;
			}
			differ = new AceDiff({
			  
			  element: '.acediff',
			  left: {
			    content: result.source,
			    mode: 'ace/mode/' + result.mode,
			    theme: 'ace/theme/monokai',
			    editable: false,
			    copyLinkEnabled: false
			  },
			  right: {
			    content: result.fixed,
			    mode: 'ace/mode/' + result.mode,
			    theme: 'ace/theme/monokai',
	    		editable: true,
	    		copyLinkEnabled: false
			  },
			});
			var annotations = [];
			for (var i=0;i<result.issues.length;i++) {
				var msg = result.issues[i].title + "\n";
				if (result.issues[i].description) {
					msg += "\n" + result.issues[i].description;
				}
				if (result.issues[i].message) {
					msg += "\n[" + result.issues[i].message + "]";
				}
				

				var a = {
					row: result.issues[i].line-1,
					text: msg,
					type: "error"

				}
				annotations.push(a);
			}
			
			differ.editors.left.ace.getSession().setAnnotations(annotations);

			if (result.warnings && result.warnings.length > 0) {
				$('#differ-warnings').addClass('alert').addClass('alert-warning');
				$('#differ-warnings').html("<h5>Warnings</h5><ul></ul>");
				for (var i=0;i<result.warnings.length;i++) {
					var li = $('#differ-warnings ul').append("<li></li>");
					$(li).text(result.warnings[i]);
				}
			}

		}).fail( function (jqXHR, textStatus, errorThrown) {
			$('.acediff').addClass('alert').addClass('alert-danger');
			var msg = "Error computing fix code";
			if (jqXHR.responseJSON && jqXHR.responseJSON.error && jqXHR.responseJSON.error.length > 0) {
				msg += " " + jqXHR.responseJSON.error;
			}
			$('.acediff').text(msg);
		});
	}

	$('select.fix-select').change(function() {
		loadDiff();
	});

	$('#differ').each(function() {
		loadDiff();
		var checkCount = 0;
		var interval = setInterval(function() {
			//runs every 10 seconds
			checkCount++;
			if (checkCount < 10 || checkCount % (checkCount/10) == 0) {
				console.log("checkCount", checkCount, checkCount % (checkCount/10));
				var data = getDifferData();
				$.ajax({method:'POST', url:'/scan/changed', data:data}).done(function(result) {
					if (result.changed && result.changed === true) {
						clearInterval(interval);
						$('#saveFileButton').addClass('hidden');
						$('#rescanButton').removeClass('hidden');
						if (confirm("The file appears to have changed on disk. Would you like to rescan this file?")) {
							window.location = $('#rescanButton').attr('href');
						}
					}
				}).fail(function() {
					clearInterval(interval);
				});
			}
		}, 10000);
	});

	$(window).focus(function() {
		if ($('#differ').lenght == 1) {
			var data = getDifferData();
			$.ajax({method:'POST', url:'/scan/changed', data:data}).done(function(result) {
				if (result.changed && result.changed === true) {
					clearInterval(interval);
					$('#saveFileButton').addClass('hidden');
					$('#rescanButton').removeClass('hidden');
					if (confirm("The file appears to have changed on disk. Would you like to rescan this file?")) {
						window.location = $('#rescanButton').attr('href');
					}
				}
			}).fail(function() {
				clearInterval(interval);
			});
		}
	})

	$('#ignoreFileButton').click(function() {
		var data = getDifferData();
		if (confirm("Are you sure you want to ignore this file in all future scans for all types of issues?")) {
			$.ajax({method:'POST', url:'/scan/ignore', data:data}).done(function(result) {
				document.location = "/scan/view?projectID=" + encodeURIComponent(data.projectID) + "&scanID=" + encodeURIComponent(data.scanID);
			}).fail(function(jqXHR, textStatus, errorThrown) {
				alert('Failed to Ignore File');
			});
		}
	});

	$('#saveFileButton').click(function() {
		if (differ == null) {
			alert('Differ is null');
		} else {
			var rightContent = differ.editors.right.ace.getValue();
			var leftContent = differ.editors.left.ace.getValue();
			var data = getDifferData();
			data.content = rightContent;
			if (rightContent == leftContent) {
				alert('Did not save the file, because the content appears to be unchanged.')
			} else {
				if (confirm("Are you sure you want to save the changes in the right editor? This will update: " + data.path + " on disk, there is no undo.")) {
					$.ajax({method:'POST', url:'/scan/save', data:data}).done(function(result) {
						if (result.error && result.error.length > 0) {
							alert(result.error);
						} else if (result.success && result.success === true) {
							window.location = $('#rescanButton').attr('href');
						}
					}).fail(function() {
						alert("Failed to Save");
					});
				}
			}
		}
	});



	$('.btn-back').click(function() {
		window.history.back();
		return true;
	});

	function getDifferData() {
		var data = {
			projectID: $('#differ').data("project-id"),
			scanID: $('#differ').data("scan-id"),
			path: $('#differ').data("path"),
			csrf: $('#differ').data("csrf")
		};
		return data;
	}

});