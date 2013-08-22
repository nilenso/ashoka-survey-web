class SurveyBuilderV2.Models.DateQuestionModel extends SurveyBuilderV2.Backbone.Model
  urlRoot: "/api/questions"

  defaults:
    "type": "DateQuestion"

  initialize: =>
    @set("order_number", Math.floor(Math.random() * 100000))