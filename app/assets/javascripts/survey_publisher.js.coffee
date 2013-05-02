class SurveyApp.SurveyPublisher
  constructor: (@container) ->
    @crowd_source_toggle = @container.find(".crowd-source-toggle")
    @thank_you_message_container = @container.find(".thank-you-message")
    @expiry_date = @container.find(".expiry-date")
    @initialize()

  initialize: =>
    @thank_you_message_container.hide()
    @crowd_source_toggle.click(@show_thank_you)
    @show_thank_you()
    @expiry_date.datepicker
      dateFormat: "yy/mm/dd"
      changeMonth: true
      changeYear: true

  show_thank_you: =>
    if @crowd_source_toggle.attr("checked")
      @thank_you_message_container.show()
    else
      @thank_you_message_container.hide()

