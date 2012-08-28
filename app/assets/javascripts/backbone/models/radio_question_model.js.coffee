class SurveyBuilder.Models.RadioQuestionModel extends Backbone.Model
  urlRoot: window.location.pathname.replace('/build', '') + '/questions'

  defaults: {
    type: 'RadioQuestion',
    content: 'Untitled question'
  }

  initialize: ->
    survey_id_match = window.location.pathname.match(/surveys\/build\/(\d+)/)
    this.set({survey_id: survey_id_match[1]}) if survey_id_match
    this.save()
