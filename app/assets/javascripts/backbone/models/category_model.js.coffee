# Interfaces between the views and the rails model for a multiline category
class SurveyBuilder.Models.CategoryModel extends Backbone.RelationalModel
  urlRoot: '/api/categories'

  defaults:
    content: 'Untitled Category'

  initialize: ->
    this.set('content', I18n.t('js.untitled_category'))

  save_model: ->
    this.save({}, {error: this.error_callback, success: this.success_callback})

  fetch: ->
    super({error: this.error_callback, success: this.success_callback})

  success_callback: (model, response) =>
    this.errors = []
    this.trigger('change:errors')
    this.trigger('save:completed')

  error_callback: (model, response) =>
    this.errors = JSON.parse(response.responseText)
    this.trigger('change:errors')

  toJSON: ->
    category_attrs = {}
    _.each @attributes, (val, key) ->
      category_attrs[key] = val  if val? and not _.isObject(val)
    { category: _.omit( category_attrs, ['order_number', 'created_at', 'id', 'updated_at']) }

SurveyBuilder.Models.CategoryModel.setup()
