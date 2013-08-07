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

  preload_sub_elements: =>
    null

  remove_image_attributes: =>
    @unset('image', {silent: true})
    @unset('image_content_type', {silent: true})
    @unset('image_file_name', {silent: true})
    @unset('image_updated_at', {silent: true})

  success_callback: (model, response) =>
    @make_clean()
    @remove_image_attributes()
    @errors = []
    @trigger('change:errors')
    @trigger('save:completed')

  error_callback: (model, response) =>
    @errors = JSON.parse(response.responseText).full_errors
    @trigger('change:errors')
    @trigger('set:errors')

  image_upload_url: =>
    "/api/questions/"+@id+'/image_upload'

  duplicate_url: =>
    "/api/questions/"+@id+'/duplicate'

  toJSON: =>
    acc = _(@attr_accessible()).reduce((acc,elem) =>
            acc[elem] = @get(elem)
            acc
          , {})
    { question: acc }

  attr_accessible: =>
    _.filter ["id", "content", "survey_id", "mandatory", "max_length", "type", "max_value", "min_value",
    "order_number", "parent_id", "identifier", "category_id", "image", "private", "finalized"], (elem) =>
      @get(elem) != null

SurveyBuilder.Models.QuestionModel.setup()
