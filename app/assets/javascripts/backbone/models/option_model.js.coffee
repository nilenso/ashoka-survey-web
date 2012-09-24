# Interfaces between the views and the rails model for an option
class SurveyBuilder.Models.OptionModel extends Backbone.RelationalModel
  urlRoot: '/api/options'
  defaults: {
    content: 'untitled'
  }

  has_errors: ->
    !_.isEmpty(this.errors)

  save_model: ->
    this.save({}, {error: this.error_callback, success: this.success_callback})

  success_callback: (model, response) =>
    this.errors = []
    this.trigger('change:errors')

  error_callback: (model, response) =>
    this.errors = JSON.parse(response.responseText)
    this.trigger('change:errors')

SurveyBuilder.Models.OptionModel.setup()

# Collection of all options for radio question
class SurveyBuilder.Collections.OptionCollection extends Backbone.Collection
  model: SurveyBuilder.Models.OptionModel

  url: ->
    '/api/options?question_id=' + this.question.id

  has_errors: ->
    this.any((option) -> option.has_errors())
