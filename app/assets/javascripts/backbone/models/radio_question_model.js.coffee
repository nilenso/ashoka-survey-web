# Interfaces between the views and the rails model for a radio question with a collection of options
class SurveyBuilder.Models.RadioQuestionModel extends SurveyBuilder.Models.QuestionModel

  defaults: {
    type: 'RadioQuestion'
    content: 'Untitled question'
    mandatory: false
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
    !_.isEmpty(this.errors) || this.get('options').has_errors()

  #Can't have a blank radio question. Initialize with 3 radio options
  seed: ->
    unless this.seeded
      this.get('options').create({content: "First Option"})
      this.get('options').create({content: "Second Option"})
      this.get('options').create({content: "Third Option"})
      this.seeded = true

  save_model: ->
    super
    this.get('options').each (option) ->
      option.save_model()

  success_callback: (model, response) =>
    this.seed()
    super

  create_new_option: ->
    this.get('options').create({content: "Another Option"})

SurveyBuilder.Models.RadioQuestionModel.setup()