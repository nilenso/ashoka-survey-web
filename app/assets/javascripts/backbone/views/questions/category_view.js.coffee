SurveyBuilder.Views.Questions ||= {}

# The settings of a single category in the DOM
class SurveyBuilder.Views.Questions.CategoryView extends Backbone.View

  events:
    'keyup  input[type=text]': 'handle_textbox_keyup'

  initialize: (@model) ->
    this.template = $('#category_template').html()
    this.model.actual_view = this
    this.model.on('save:completed', this.renderImageUploader, this)
    this.model.on('change', this.render, this)

  render:(template) ->
    $(this.el).html(Mustache.render(this.template, this.model.toJSON().category))
    return this

  handle_textbox_keyup: (event) ->
    this.model.off('change', this.render)
    input = $(event.target)
    propertyHash = {}
    propertyHash[input.attr('name')] = input.val()
    this.update_model(propertyHash)

  update_model: (propertyHash) ->
    this.model.set(propertyHash)

  hide : ->
    $(this.el).hide()
