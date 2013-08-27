class SurveyBuilderV2.Models.OptionModel extends SurveyBuilderV2.Backbone.RelationalModel
  urlRoot: '/api/options'

  defaults:
    content: 'New Option'

  initialize: =>
    @set("order_number", Math.floor(Math.random() * 100000))

SurveyBuilderV2.Models.OptionModel.setup()
