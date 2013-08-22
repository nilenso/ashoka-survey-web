class SurveyBuilderV2.Models.NumericQuestionModel extends SurveyBuilderV2.Backbone.Model
  urlRoot: "/api/questions"

  defaults:
    "type": "NumericQuestion"

  initialize: =>
    @set("order_number", Math.floor(Math.random() * 100000))
