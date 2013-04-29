class window.ExcelDownloader
  constructor: (@container, download_button, survey_id) ->
    download_button.click =>
      @container.find(".from-date").datepicker({ dateFormat: "yy-mm-dd" });
      @container.find(".to-date").datepicker({ dateFormat: "yy-mm-dd" });
      @dialog = $("#excel-dialog" ).dialog
        dialogClass: "no-close"
        modal: true
        width: 600
        height: 200

  start: =>
    $.getJSON("/surveys/#{survey_id}/responses/generate_excel", (data) =>
      @filename = data.excel_path
      @id = data.id
      @interval = setInterval(@poll, 5000)
    )

  poll: =>
    console.log "Polling for the excel file."
    $.getJSON("/api/jobs/#{@id}/alive", (data) =>
      if(data.alive)
        console.log "404. Polling again. File still being generated."
      else
        console.log "Generated excel. Downloading..."
        clearInterval(@interval)
        window.location = "https://s3.amazonaws.com/surveywebexcel/#{@filename}"
        @close_dialog()
    )

  close_dialog: =>
    @dialog.dialog('close')
