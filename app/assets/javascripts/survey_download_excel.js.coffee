class SurveyApp.ExcelDownloader
  constructor: (@container, download_button, @survey_id) ->
    download_button.click(@initialize)

  initialize: =>
    @container.find(".polling").hide()
    @date_range = new SurveyApp.DateRangePicker(@container.find(".pick-date-range"))
    @container.find(".cancel-button").click(@close_dialog)
    @container.find(".generate-button").click(@start)
    @dialog = $("#excel-dialog" ).dialog
      dialogClass: "no-close"
      modal: true
      width: 600
      height: 200

  start: =>
    @container.find(".setup").hide()
    @container.find(".polling").show()

    $.ajax "/surveys/#{@survey_id}/responses/generate_excel",
      type: "GET"
      data: @date_range.prepare_params()
      success: (data) =>
        @filename = data.excel_path
        @id = data.id
        @interval = setInterval(@poll, 5000)
      error: (data) =>
        console.log(data)

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
