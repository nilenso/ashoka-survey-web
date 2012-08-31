# Choice that belongs to a radio question
class SurveyBuilder.Models.OptionModel extends Backbone.RelationalModel
  urlRoot: '/api/options'
  defaults: {
    content: 'untitled'
  }

SurveyBuilder.Models.OptionModel.setup()

# Collecttion of all choices for radio question
class SurveyBuilder.Collections.OptionCollection extends Backbone.Collection
  model: SurveyBuilder.Models.OptionModel
  url: '/api/options'