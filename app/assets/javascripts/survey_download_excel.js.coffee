class SurveyApp.ExcelDownloader
  constructor: (@container, download_button, @survey_id) ->
    download_button.click(@initialize)
    @container.find(".polling").hide()
    @date_range = new SurveyApp.DateRangePicker(@container.find(".pick-date-range"))
    @container.find(".cancel-button").click(@close_dialog)
    @container.find(".generate-button").click(@start)
    @error_message_container = @container.find(".error-message")
    @filter_private_checkbox = @container.find("#filter-private-checkbox")

  initialize: =>
    @dialog = $("#excel-dialog" ).dialog
      dialogClass: "no-close"
      modal: true
      width: 600

  start: =>
    return unless @is_valid()
    @container.find(".setup").hide()
    @container.find(".polling").show()

    $.ajax "/surveys/#{@survey_id}/responses/generate_excel",
      type: "GET"
      data:
        date_range: @date_range.prepare_params()
        disable_filtering: @filter_private_checkbox.is(":checked")
      success: (data) =>
        @filename = data.excel_path
        @id = data.id
        @password = data.password
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
        window.location = "https://s3.amazonaws.com/surveywebexcel/#{@filename}.zip"
        @close_dialog()
        new SurveyApp.ExcelPasswordDialog(@password).show()
    )

  is_valid: =>
    valid = @date_range.is_valid()
    @set_error_message(@date_range.errors.toString()) unless valid
    return valid

  set_error_message: (error_message) =>
    @error_message_container.html(error_message)

  close_dialog: =>
    @reset()
    @dialog.dialog('close')

  reset: =>
    @container.find(".polling").hide()
    @container.find(".setup").show()
    @date_range.reset()
    @error_message_container.val('')
