class Survey
  constructor: (@settings_div, @form_div) ->
    @question_count = 0
    @settings_div.find(".add_question_field").click(@add_new_question)

  add_new_question: =>
    template = Mustache.render($('#question_template').html(), id: @question_count++)
    @form_div.find('#questions').append(template)

SurveyApp.Survey = Survey