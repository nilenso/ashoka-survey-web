# Binding between the actual and dummy fieldsets

class SurveyElement
  constructor: (@actual, @dummy) ->
    @actual.find('*').bind('keyup change', @mirrorKeyup)

  mirrorKeyup: (event) =>
    name = $(event.target).attr('name')
    @dummy.find("*[name=\"#{name}\"]").val($(event.target).val());
    @dummy.find("*[name=\"#{name}\"]").text($(event.target).val());

SurveyApp.SurveyElement = SurveyElement