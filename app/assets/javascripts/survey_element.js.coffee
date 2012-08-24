# Binding between the actual and dummy fieldsets

class SurveyElement
  constructor: (@actual, @dummy) ->
    @actual.find('*').bind('keyup change', @mirrorKeyup)

  mirrorKeyup: (event) =>
    name = $(event.target).attr('name')
    @dummy.find("*[name=\"#{name}\"]").val($(event.target).val());
    @dummy.find("*[name=\"#{name}\"]").text($(event.target).val());

  show: (event) =>
    @actual.show()
    if @dummy.attr('id') == "dummy_survey_details"
      @dummy.addClass("details_active")
      @sidebar_div.find("#questions").hide()

    else
      @dummy.addClass("active")    

  hide: =>
    @actual.hide()
    @dummy.removeClass("active")
    @dummy.removeClass("details_active")

SurveyApp.SurveyElement = SurveyElement