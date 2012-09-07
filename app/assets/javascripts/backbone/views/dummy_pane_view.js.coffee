# Collection of dummy questions
class SurveyBuilder.Views.DummyPaneView extends Backbone.View
  el: "#dummy_pane"

  initialize: ->
    @questions = []

  add_question: (type, model) ->
    switch type
      when 'radio'
        template = $('#dummy_radio_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template))
      when 'single_line'
        template = $('#dummy_single_line_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionView(model, template))
      when 'multiline'
        template = $('#dummy_multiline_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionView(model, template))
      when 'numeric'
        template = $('#dummy_numeric_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionView(model, template))
      when 'date'
        template = $('#dummy_date_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionView(model, template))

    this.render()

  render: ->
    $(this.el).append(question.render().el) for question in @questions
    return this

  unfocus_all: ->
    $(question.el).removeClass("active") for question in @questions