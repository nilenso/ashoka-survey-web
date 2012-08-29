class SurveyBuilder.Models.RadioQuestionModel extends Backbone.Model
  urlRoot: window.location.pathname.replace('/build', '') + '/questions'

  defaults: {
    type: 'RadioQuestion',
    content: 'Untitled question'
  }

  initialize: ->
    this.on('change:id', this.create_collection, this)
    survey_id_match = window.location.pathname.match(/surveys\/build\/(\d+)/)
    this.set({survey_id: survey_id_match[1]}) if survey_id_match
    this.save()

  create_collection: =>
    this.off('change:id')
    this.set({ options: new SurveyBuilder.Collections.OptionsCollection(this.id) })