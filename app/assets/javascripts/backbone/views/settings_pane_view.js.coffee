class SurveyBuilder.Views.SettingsPaneView extends Backbone.View
  el: "#settings_pane"

  initialize: ->
    @questions = []


  add_question: (type, model) ->
    if type == 'radio'
      @questions.push new SurveyBuilder.Views.Questions.RadioQuestionView(model)
      this.render()

  render: ->
    $(this.el).html('')
    $(this.el).append(question.render().el) for question in @questions
    return this

      
