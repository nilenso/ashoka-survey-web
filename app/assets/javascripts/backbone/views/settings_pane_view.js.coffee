# Collection of all questions' settings
class SurveyBuilder.Views.SettingsPaneView extends Backbone.View
  el: "#settings_pane"

  initialize: ->
    @questions = []

  add_question: (type, model) ->
    switch type
      when 'radio'
        question = new SurveyBuilder.Views.Questions.RadioQuestionView(model)
      when 'single_line'
        question = new SurveyBuilder.Views.Questions.SingleLineQuestionView(model)

    @questions.push(question)
    $(this.el).append($(question.render().el))
    $(question.render().el).hide()

  render: ->
    $(this.el).append($(question.render().el)) for question in @questions
    return this

  hide_all: ->
    $(question.el).hide() for question in @questions