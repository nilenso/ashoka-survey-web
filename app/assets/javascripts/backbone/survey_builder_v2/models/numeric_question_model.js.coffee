class SurveyBuilderV2.Models.NumericQuestionModel extends SurveyBuilderV2.Backbone.Model
  urlRoot: "/api/questions"

  defaults:
    "type": "NumericQuestion"
    
  toJSON: =>
    acc = _(@attr_accessible()).reduce((acc, elem) =>
            acc[elem] = @get(elem)
            acc
          , {})
    { question: acc }

  attr_accessible: =>
    _.filter ["id", "content", "survey_id", "mandatory", "max_length", "type", "max_value", "min_value",
    "order_number", "parent_id", "identifier", "category_id", "image", "private", "finalized"], (elem) =>
      @get(elem) != null

  initialize: =>
    @set("order_number", Math.floor(Math.random() * 100000))