# Interfaces between the views and the rails model for a multiline question
class SurveyBuilder.Models.QuestionModel extends Backbone.RelationalModel
  urlRoot: '/api/questions'

  defaults:
    content: I18n.t('js.untitled_question')
    mandatory: false
    identifier: false

  initialize: =>
    @on('change', @make_dirty, this)
    @make_dirty()

  has_errors: =>
    !_.isEmpty(@errors)

  make_dirty: =>
    @dirty = true

  make_clean: =>
    @dirty = false

  is_dirty: =>
    @dirty

  save_model: =>
    if @is_dirty()
      @save({}, {error: @error_callback, success: @success_callback})

  fetch: =>
    super({error: @error_callback, success: @success_callback})

  remove_image_attributes: =>
    @unset('image', {silent: true})
    @unset('image_content_type', {silent: true})
    @unset('image_file_name', {silent: true})
    @unset('image_file_size', {silent: true})
    @unset('image_updated_at', {silent: true})

  success_callback: (model, response) =>
    @make_clean()
    @remove_image_attributes()
    @errors = []
    @trigger('change:errors')
    @trigger('save:completed')

  error_callback: (model, response) =>
    @errors = JSON.parse(response.responseText)
    @trigger('change:errors')
    @trigger('set:errors')

  image_upload_url: =>
    "/api/questions/"+@id+'/image_upload'

  duplicate_url: =>
    "/api/questions/"+@id+'/duplicate'

  toJSON: =>
    question_attrs = {}
    _.each @attributes, (val, key) =>
      question_attrs[key] = val  if val? and not _.isObject(val)
    { question: _.omit( question_attrs, ['created_at', 'updated_at', 'image_url', 'image_in_base64', 'photo_secure_token', 'image_tmp']) }

SurveyBuilder.Models.QuestionModel.setup()
