class SurveyBuilder.Views.SettingsPaneView extends Backbone.View
  el: "#settings_pane"

  initialize: ->
    @questions = []


  add_question: (type, model) ->
    if type == 'radio'
      question = new SurveyBuilder.Views.Questions.RadioQuestionView(model)
      @questions.push(question)
      $(this.el).append($(question.render().el))

  render: ->
    $(this.el).append($(question.render().el)) for question in @questions
    return this
      
