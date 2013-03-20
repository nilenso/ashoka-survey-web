class window.ExcelDownloader
  constructor: (survey_id) ->
    $('.download_excel').click =>
      @dialog = $("#dialog" ).dialog
        dialogClass: "no-close"
      $.getJSON("/surveys/#{survey_id}/responses/generate_excel", (data) =>
        @filename = data.excel_path
        @interval = setInterval(@poll, 5000)
      )

  poll: =>
    console.log "Polling for the excel file."
    $.ajax
      type: "HEAD"
      async: true
      url: "https://s3.amazonaws.com/surveywebexcel/#{@filename}"
      success: (message, text, response) =>
        console.log "Generated excel. Downloading..."
        clearInterval(@interval)
        window.location = "https://s3.amazonaws.com/surveywebexcel/#{@filename}"
        @close_dialog()
      error: (message, text, response) =>
        console.log "404. Polling again. File still being generated."

  close_dialog: =>
    @dialog.dialog('close')
