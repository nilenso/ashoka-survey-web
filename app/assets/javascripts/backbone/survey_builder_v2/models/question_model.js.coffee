class SurveyBuilderV2.Models.QuestionModel extends SurveyBuilderV2.Backbone.Model
  urlRoot: "/api/questions"

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
