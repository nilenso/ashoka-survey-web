# Interfaces between the views and the rails model for a multiline question
class SurveyBuilder.Models.MultilineQuestionModel extends Backbone.RelationalModel
  urlRoot: '/api/questions'

  defaults: {
    type: 'MultilineQuestion',
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
    this.trigger('save:completed')

  error_callback: (model, response) =>
    this.errors = JSON.parse(response.responseText)
    this.trigger('change:errors')

  imageUploadUrl: ->
    "/api/questions/"+this.id+'/image_upload'

SurveyBuilder.Models.MultilineQuestionModel.setup()