class window.ExcelDownloader
  constructor: (@container, download_button, @survey_id) ->
    download_button.click(@initialize)

  initialize: =>
    @container.find(".polling").hide()
    @prepare_datepickers()
    @container.find(".cancel-button").click(@close_dialog)
    @container.find(".generate-button").click(@start)
    @dialog = $("#excel-dialog" ).dialog
      dialogClass: "no-close"
      modal: true
      width: 600
      height: 200
    @container.find("#date-range-checkbox").click =>
      @toggle_date_pickers()

  prepare_datepickers: =>
    date_format = "yy-mm-dd"
    @container.find(".from-date").datepicker({ dateFormat: date_format })
    @container.find(".to-date").datepicker({ dateFormat: date_format })

  toggle_date_pickers:  =>
    pickers = @container.find(".date-picker")
    if pickers.attr('disabled')
      pickers.removeAttr('disabled')
    else
      pickers.attr('disabled', 'disabled')

  start: =>
    @container.find(".setup").hide()
    @container.find(".polling").show()

    $.ajax "/surveys/#{@survey_id}/responses/generate_excel",
      type: "GET"
      data:
        from: @container.find(".from-date").val()
        to: @container.find(".to-date").val()
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
