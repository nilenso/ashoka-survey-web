class SurveyBuilder
  constructor: (@sidebar_div) ->
    @question_count = 0
    @sidebar_div.find(".add_question_field").click(@add_new_question)

  add_new_question: =>
    template = Mustache.render(@sidebar_div.find('#question_template').html(), id: @question_count++)
    @sidebar_div.find('#questions').append(template)

SurveyApp.SurveyBuilder = SurveyBuilder