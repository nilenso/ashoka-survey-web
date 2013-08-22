class SurveyBuilderV2.Models.MultiLineQuestionModel extends SurveyBuilderV2.Backbone.Model
  urlRoot: "/api/questions"

  defaults:
    "type": "MultiLineQuestion"

  initialize: =>
    @set("order_number", Math.floor(Math.random() * 100000))