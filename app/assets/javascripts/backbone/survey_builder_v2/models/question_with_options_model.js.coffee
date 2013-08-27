class SurveyBuilderV2.Models.QuestionWithOptionsModel extends SurveyBuilderV2.Backbone.RelationalModel
  urlRoot: "/api/questions"

  relations: [
    {
      type: SurveyBuilderV2.Backbone.HasMany
      key: 'options'
      includeInJSON: 'id'
      relatedModel: 'SurveyBuilderV2.Models.OptionModel'
      collectionType: 'SurveyBuilderV2.Collections.OptionCollection'
      reverseRelation: {
        key: 'question'
        keyDestination: 'question_id'
        includeInJSON: 'id'
      }
    }
  ]

  initialize: =>
    @set("order_number", Math.floor(Math.random() * 100000))

  dup: =>
    newObject = {}
    for attr in @dupedAttributes()
      newObject[attr] = @get(attr)
    newObject

  dupedAttributes: =>
    _(@accessibleAttrs()).without("id", "type", "max_value", "min_value")

  toJSON: =>
    attributes = _(@accessibleAttrs()).reduce((acc, elem) =>
      acc[elem] = @get(elem)
      acc
    , {})
    { question: attributes }

  accessibleAttrs: =>
    _(@allAttributes()).filter (elem) =>
      @get(elem) != null

  allAttributes: =>
    ["id", "type", "content", "survey_id", "mandatory", "max_length", "max_value", "min_value",
    "order_number", "parent_id", "identifier", "category_id", "image", "private", "finalized"]

  destroyOptions: =>
    optionCollection = @get('options')
    optionModel.destroy() while optionModel = optionCollection.pop()

  createNewOption: (content) =>
    @get('options').add({content: content, question_id: @get('id')})

SurveyBuilderV2.Models.QuestionWithOptionsModel.setup()
