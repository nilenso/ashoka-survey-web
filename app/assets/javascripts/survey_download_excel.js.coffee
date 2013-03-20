class window.ExcelDownloader
  constructor: (survey_id) ->
    $('.download_excel').click =>
      @dialog = $("#dialog" ).dialog
        dialogClass: "no-close"
      $.getJSON("/surveys/#{survey_id}/responses/generate_excel", (data) =>
        @filename = data.excel_path
        @id = data.id
        @interval = setInterval(@poll, 5000)
      )

  poll: =>
    console.log "Polling for the excel file."
    $.getJSON("/api/jobs/#{id}/alive", (data) =>
      if(data.alive)
        console.log "Generated excel. Downloading..."
        clearInterval(@interval)
        window.location = "https://s3.amazonaws.com/surveywebexcel/#{@filename}"
        @close_dialog()
      else
        console.log "404. Polling again. File still being generated."
    )

  close_dialog: =>
    @dialog.dialog('close')
