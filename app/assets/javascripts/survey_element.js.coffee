# Binding between the actual and dummy fieldsets

class SurveyElement
  constructor: (@actual, @dummy, @sidebar_div, @dummy_div) ->
    @actual.find('*').bind('keyup change', @mirrorKeyup)
    @dummy.bind('click', @showActual)

  mirrorKeyup: (event) =>
    name = $(event.target).attr('name')
    @dummy.find("*[name=\"#{name}\"]").val($(event.target).val());
    @dummy.find("*[name=\"#{name}\"]").text($(event.target).val());

  showActual: (event) =>
    @sidebar_div.find("#survey_details").hide()
    @sidebar_div.find("#questions").show()
    @sidebar_div.find("#questions").find('fieldset').hide()
    @actual.show()
    $(".tabs li").last().click()

    @dummy_div.find('fieldset').removeClass("active")
    @dummy_div.find('fieldset').removeClass("details_active")

    if @dummy.attr('id') == "dummy_survey_details"
      @dummy.addClass("details_active")
      @sidebar_div.find("#questions").hide()

    else
      @dummy.addClass("active")

SurveyApp.SurveyElement = SurveyElement