# Interfaces between the views and the rails model for an option
class SurveyBuilder.Models.OptionModel extends Backbone.RelationalModel
  urlRoot: '/api/options'
  defaults: {
    content: 'untitled'
  }

  save_model: ->
    this.save({}, {error: this.error_callback, success: this.success_callback})

  success_callback: (model, response) ->
    console.log("saved options successfully!")
    console.log(model, response)

  error_callback: (model, response) ->
    console.log("Error saving options!")
    console.log(model, JSON.parse(response.responseText))

SurveyBuilder.Models.OptionModel.setup()

# Collection of all options for radio question
class SurveyBuilder.Collections.OptionCollection extends Backbone.Collection
  model: SurveyBuilder.Models.OptionModel
  url: '/api/options'