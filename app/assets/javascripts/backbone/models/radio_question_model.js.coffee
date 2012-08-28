class SurveyBuilder.Models.RadioQuestionModel extends Backbone.Model
  urlRoot: window.location.pathname.replace('/build', '') + '/questions'

  defaults: {
    type: 'RadioQuestion'
  }

  initialize: ->
    this.save()
