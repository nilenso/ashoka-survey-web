class SurveyBuilder.Models.RadioQuestionModel extends Backbone.RelationalModel
  urlRoot: '/api/questions'

  defaults: {
    type: 'RadioQuestion',
    content: 'Untitled question'
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

  #Can't have a blank radio question. Initialize with 3 radio options
  seed: ->
    this.get('options').add({content: "First Option"})
    this.get('options').add({content: "Second Option"})
    this.get('options').add({content: "Third Option"})

SurveyBuilder.Models.RadioQuestionModel.setup()