class SurveyBuilderV2.Models.RatingQuestionModel extends SurveyBuilderV2.Backbone.Model
  urlRoot: "/api/questions"

  defaults:
    "type": "RatingQuestion"

  initialize: =>
    @set("order_number", Math.floor(Math.random() * 100000))