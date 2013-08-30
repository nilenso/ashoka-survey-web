class SurveyBuilderV2.Models.OptionModel extends SurveyBuilderV2.Backbone.RelationalModel
  urlRoot: '/api/options'

  relations: [
    {
      type: SurveyBuilderV2.Backbone.HasMany,
      key: 'elements'
      includeInJSON: 'id'
      relatedModel: 'SurveyBuilderV2.Models.QuestionWithOptionsModel'
      collectionType: 'SurveyBuilderV2.Collections.QuestionWithOptionsCollection'
      reverseRelation: {
        key: 'parent'
        keyDestination: 'parent_id'
        includeInJSON: 'id'
      }
    }
  ]

  defaults:
    content: 'New Option'

  initialize: =>
    @set("order_number", Math.floor(Math.random() * 100000))

SurveyBuilderV2.Models.OptionModel.setup()
