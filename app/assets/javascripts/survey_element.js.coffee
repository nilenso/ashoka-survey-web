# Binding between the actual and dummy fieldsets

class SurveyElement
  constructor: (@actual, @dummy) ->
    @actual.find('*').bind('keyup change', @mirror)
    @actual.find("*[type='checkbox']").bind('click', @toggle_mandatory)

  mirror: (event) =>
    name = $(event.target).attr('name')

    dummy_val = $(event.target).val()
    if dummy_val == ""
      dummy_val = @dummy.find("*[name=\"#{name}\"]").attr('default_value')

    @dummy.find("*[name=\"#{name}\"]").val(dummy_val);
    @dummy.find("*[name=\"#{name}\"]").text(dummy_val);

  toggle_mandatory: (event) =>
    @dummy.find('abbr').toggle()

  show: (event) =>
    @actual.show()
    if @dummy.attr('id') == "dummy_survey_details"
      @dummy.addClass("details_active")
    else
      @dummy.addClass("active")    

  hide: =>
    @actual.hide()
    @dummy.removeClass("active")
    @dummy.removeClass("details_active")

SurveyApp.SurveyElement = SurveyElement