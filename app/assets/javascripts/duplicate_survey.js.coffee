class SurveyApp.DuplicateSurvey
  constructor: (@container, @survey_id) ->
    @dialog = @container.dialog
      dialogClass: "no-close"
      modal: true
      width: 600
    @duplicate()

  duplicate: =>
    $.ajax "/api/surveys/#{@survey_id}/duplicate",
      type: "POST"
      success: (data) =>
        @job_id = data.job_id
        @interval = setInterval(@poll, 5000)
      error: (data) =>
        console.log(data)

  poll: =>
    console.log "Polling for the duplication job's status."
    $.getJSON("/api/jobs/#{@job_id}/alive", (data) =>
      if(data.alive)
        console.log "404. Polling again. Duplication is still happening."
      else
        console.log "Duplication finished."
        clearInterval(@interval)
        window.location = Routes.surveys_path({ filter: 'drafts' })
        @close_dialog()
    )

  close_dialog: =>
    @dialog.dialog('close')
