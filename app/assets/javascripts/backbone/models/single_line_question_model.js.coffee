# Interfaces between the views and the rails model for a single line question
class SurveyBuilder.Models.SingleLineQuestionModel extends Backbone.RelationalModel
  urlRoot: '/api/questions'

  defaults: {
    type: 'SingleLineQuestion',
    content: 'Untitled question'
    mandatory: false
    image: null
    max_length: null
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
    console.log(this.errors)
    this.trigger('change:errors')

SurveyBuilder.Models.SingleLineQuestionModel.setup()