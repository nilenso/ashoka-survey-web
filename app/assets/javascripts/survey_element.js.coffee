# Binding between the actual and dummy fieldsets

class SurveyElement
  constructor: (@actual, @dummy, @sidebar_div) ->
    @actual.find('*').bind('keyup change', @mirrorKeyup)
    @dummy.bind('click', @showActual)

  mirrorKeyup: (event) =>
    name = $(event.target).attr('name')
    @dummy.find("*[name=\"#{name}\"]").val($(event.target).val());
    @dummy.find("*[name=\"#{name}\"]").text($(event.target).val());

  showActual: (event) =>
    @sidebar_div.find("#survey_details").hide()
    @sidebar_div.find("#questions").find('fieldset').hide()
    @actual.show()
    $(".tabs li").last().click()

SurveyApp.SurveyElement = SurveyElement