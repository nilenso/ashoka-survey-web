#TODO: remove this comment line
# Interfaces between the views and the rails model for a multiline question
class SurveyBuilder.Models.QuestionModel extends Backbone.RelationalModel
  urlRoot: '/api/questions'

  defaults:
    # TODO: i18n this
    # TODO: why set default when it's done in the initializer?
    content: 'Untitled question'
    mandatory: false
    identifier: false

  initialize: =>
    this.set('content', I18n.t('js.untitled_question'))
    this.on('change', @make_dirty, this)
    @make_dirty()

  has_errors: =>
    !_.isEmpty(this.errors)

  make_dirty: =>
    @dirty = true

  make_clean: =>
    @dirty = false

  is_dirty: =>
    @dirty

  save_model: =>
    if @is_dirty()
      this.save({}, {error: this.error_callback, success: this.success_callback})

  fetch: =>
    super({error: this.error_callback, success: this.success_callback})

  duplicate: =>
    $.post(
      "#{@url()}/duplicate"
    ).success(=>
      alert "success"
    ).error(=>
      alert "error"
    ).complete(=>
      alert "complete"
    )

  remove_image_attributes: =>
    this.unset('image', {silent: true})
    this.unset('image_content_type', {silent: true})
    this.unset('image_file_name', {silent: true})
    this.unset('image_file_size', {silent: true})
    this.unset('image_updated_at', {silent: true})

  success_callback: (model, response) =>
    @make_clean()
    @remove_image_attributes()
    # TODO: use @
    this.errors = []
    this.trigger('change:errors')
    this.trigger('save:completed')

  error_callback: (model, response) =>
    this.errors = JSON.parse(response.responseText)
    this.trigger('change:errors')
    this.trigger('set:errors')

  # TODO: why camelCase?
  imageUploadUrl: =>
    "/api/questions/"+this.id+'/image_upload'

  toJSON: =>
    question_attrs = {}
    _.each @attributes, (val, key) =>
      question_attrs[key] = val  if val? and not _.isObject(val)
    # TODO: _(question_attrs).omit
    { question: _.omit( question_attrs, ['created_at', 'updated_at', 'image_url', 'image_in_base64', 'photo_secure_token', 'image_tmp']) }

SurveyBuilder.Models.QuestionModel.setup()
