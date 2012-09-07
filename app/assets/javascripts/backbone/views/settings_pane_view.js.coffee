# Collection of all questions' settings
class SurveyBuilder.Views.SettingsPaneView extends Backbone.View
  el: "#settings_pane"

  initialize: ->
    @questions = []

  add_question: (type, model) ->
    switch type
      when 'radio'
        template = $('#radio_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionWithOptionsView(model, template)
      when 'single_line'
        template = $('#single_line_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'multiline'
        template = $('#multiline_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'numeric'
        template = $('#numeric_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionView(model, template)

    @questions.push(question)
    $(this.el).append($(question.render().el))
    $(question.render().el).hide()

  render: ->
    $(this.el).append($(question.render().el)) for question in @questions
    return this

  hide_all: ->
    $(question.el).hide() for question in @questions