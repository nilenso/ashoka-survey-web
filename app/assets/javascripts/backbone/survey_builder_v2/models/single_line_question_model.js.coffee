class SurveyBuilderV2.Models.SingleLineQuestionModel extends Backbone.Model
  urlRoot: "/api/questions"

  defaults:
    "type": "SingleLineQuestion"

  initialize: =>
    @set("order_number", Math.floor(Math.random() * 100000))