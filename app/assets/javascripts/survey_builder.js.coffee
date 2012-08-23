class SurveyBuilder
  constructor: (@sidebar_div, @dummy_div) ->
    @question_count = 0
    @sidebar_div.find(".add_question_field").click(@add_new_question)

  add_new_question: =>
    actual = $(Mustache.render(@sidebar_div.find('#question_template').html(), id: @question_count))
    dummy = $(Mustache.render(@sidebar_div.find('#dummy_question_template').html(), id: @question_count++))
    @sidebar_div.find('#questions').append(actual)
    @sidebar_div.find('#questions').find('fieldset').hide()
    @dummy_div.find('#dummy_questions').append(dummy)
    new SurveyApp.SurveyElement(actual, dummy)

SurveyApp.SurveyBuilder = SurveyBuilder