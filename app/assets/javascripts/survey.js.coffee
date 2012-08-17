class Survey
  constructor: (@survey_div) ->
    @question_count = 0
    @survey_div.find(".add_question_field").click(@add_new_question)

  add_new_question: =>
    template = Mustache.render($('#question_template').html(), id: @question_count++)
    @survey_div.find('#questions').append(template)

SurveyApp.Survey = Survey