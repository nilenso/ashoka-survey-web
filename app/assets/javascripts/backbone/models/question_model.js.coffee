# Interfaces between the views and the rails model for a multiline question
class SurveyBuilder.Models.QuestionModel extends Backbone.RelationalModel
  urlRoot: '/api/questions'

  defaults:
    content: 'Untitled question'
    mandatory: false
    identifier: false


  initialize: =>
    this.set('content', I18n.t('js.untitled_question'))
  has_errors: =>
    !_.isEmpty(this.errors)

  save_model: =>
    this.save({}, {error: this.error_callback, success: this.success_callback})

  fetch: =>
    super({error: this.error_callback, success: this.success_callback})

  remove_image_attributes: =>
    this.unset('image', {silent: true})
    this.unset('image_content_type', {silent: true})
    this.unset('image_file_name', {silent: true})
    this.unset('image_file_size', {silent: true})
    this.unset('image_updated_at', {silent: true})

  success_callback: (model, response) =>
    @remove_image_attributes()
    this.errors = []
    this.trigger('change:errors')
    this.trigger('save:completed')

  error_callback: (model, response) =>
    this.errors = JSON.parse(response.responseText)
    this.trigger('change:errors')
    this.trigger('set:errors')

  imageUploadUrl: =>
    "/api/questions/"+this.id+'/image_upload'

  toJSON: =>
    question_attrs = {}
    _.each @attributes, (val, key) =>
      question_attrs[key] = val  if val? and not _.isObject(val)
    { question: _.omit( question_attrs, ['created_at', 'updated_at', 'id', 'temp_order_number', 'image_url', 'image_in_base64', 'photo_secure_token']) }

SurveyBuilder.Models.QuestionModel.setup()
