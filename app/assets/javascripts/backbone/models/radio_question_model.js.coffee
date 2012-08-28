class SurveyBuilder.Models.RadioQuestionModel extends Backbone.Model
  urlRoot: window.location.pathname.replace('/build', '') + '/questions'

  defaults: {
    type: 'RadioQuestion',
    content: 'Untitled question'
  }

  initialize: ->
    this.save()
