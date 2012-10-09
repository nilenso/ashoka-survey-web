# Interfaces between the views and the rails model for a multiline question
class SurveyBuilder.Models.QuestionModel extends Backbone.RelationalModel
  urlRoot: '/api/questions'

  defaults:
    content: 'Untitled question'
    mandatory: false

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

  toJSON: ->
    question_attrs = {}
    _.each @attributes, (val, key) ->
      question_attrs[key] = val  if val? and not _.isObject(val)
    { question: _.omit( question_attrs, ['created_at', 'updated_at', 'id']) }

SurveyBuilder.Models.QuestionModel.setup()