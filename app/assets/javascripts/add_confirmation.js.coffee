class SurveyApp.AddConfirmation
  constructor: (@confirmable) ->
    @initialize()

  initialize: =>
    @confirmable.click =>
      confirm("Are you sure you want to archive this response?")
