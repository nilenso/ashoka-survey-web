class window.ExcelDownloader
  constructor: (@container, download_button, survey_id) ->
    download_button.click(@initialize)

  initialize: =>
    @pickers = @container.find(".date-picker")
    @container.find(".from-date").datepicker({ dateFormat: "yy-mm-dd" });
    @container.find(".to-date").datepicker({ dateFormat: "yy-mm-dd" });
    @dialog = $("#excel-dialog" ).dialog
      dialogClass: "no-close"
      modal: true
      width: 600
      height: 200
    @container.find("#date-range-checkbox").click =>
      @toggle_date_pickers()

  toggle_date_pickers:  =>
    if @pickers.attr('disabled')
      @pickers.removeAttr('disabled')
    else
      @pickers.attr('disabled', 'disabled')

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
