# Collection of dummy questions
class SurveyBuilder.Views.DummyPaneView extends Backbone.View
  el: "#dummy_pane"

  initialize: ->
    @questions = []

  add_question: (type, model) ->
    switch type
     when 'radio'
      @questions.push(new SurveyBuilder.Views.Dummies.RadioQuestionView(model))
     when 'single_line'
      @questions.push(new SurveyBuilder.Views.Dummies.SingleLineQuestionView(model))
    this.render()

  render: ->
    $(this.el).append(question.render().el) for question in @questions
    return this

  unfocus_all: ->
    $(question.el).removeClass("active") for question in @questions