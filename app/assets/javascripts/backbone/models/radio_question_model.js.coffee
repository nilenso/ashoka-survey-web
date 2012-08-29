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
        key: 'question_id'
        includeInJSON: 'id'
      }
    }
  ]

SurveyBuilder.Models.RadioQuestionModel.setup()