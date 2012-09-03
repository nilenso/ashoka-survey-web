# Interfaces between the views and the rails model for a radio question with a collection of options
class SurveyBuilder.Models.RadioQuestionModel extends Backbone.RelationalModel
  urlRoot: '/api/questions'

  defaults: {
    type: 'RadioQuestion',
    content: 'Untitled question'
    mandatory: false
    image: null
  }

  relations: [
    {
      type: Backbone.HasMany,
      key: 'options'
      includeInJSON: 'id'
      relatedModel: 'SurveyBuilder.Models.OptionModel'
      collectionType: 'SurveyBuilder.Collections.OptionCollection'
      reverseRelation: {
        key: 'question'
        keyDestination: 'question_id'
        includeInJSON: 'id'
      }
    }
  ]

  has_errors: ->
    this.errors || this.get('options').has_errors()

  #Can't have a blank radio question. Initialize with 3 radio options
  seed: ->
    this.get('options').add({content: "First Option"})
    this.get('options').add({content: "Second Option"})
    this.get('options').add({content: "Third Option"})

  save_with_options: ->
    this.save({}, {error: this.error_callback, success: this.success_callback})
    this.get('options').each (option) ->
      option.save_model()

  success_callback: (model, response) =>
    this.errors = false

  error_callback: (model, response) =>
    this.errors = true

SurveyBuilder.Models.RadioQuestionModel.setup()