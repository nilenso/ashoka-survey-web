SurveyBuilder.Views.Questions ||= {}

# The settings of a single single line question in the DOM
class SurveyBuilder.Views.Questions.QuestionView extends Backbone.View

  events:
    'keyup  input[type=text]': 'handle_textbox_keyup'
    'change input[type=number]': 'handle_textbox_keyup'
    'change input[type=checkbox]': 'handle_checkbox_change'

  initialize: (@model, @template) =>
    this.model.actual_view = this
    this.model.on('save:completed', this.renderImageUploader, this)
    this.model.on('change', this.render, this)

  render:(template) =>
    $(this.el).html(Mustache.render(this.template, this.model.toJSON().question))
    return this

  handle_textbox_keyup: (event) =>
    this.model.off('change', this.render)
    input = $(event.target)
    propertyHash = {}
    propertyHash[input.attr('name')] = input.val()
    this.update_model(propertyHash)

  handle_checkbox_change: (event) =>
    this.model.off('change', this.render)
    input = $(event.target)
    propertyHash = {}
    propertyHash[input.attr('name')] = input.is(':checked')
    this.update_model(propertyHash)

  update_model: (propertyHash) =>
    this.model.set(propertyHash)

  renderImageUploader: =>
    $(this.el).children(".upload_files").children(".fileupload").fileupload
      dataType: "json"
      url: @model.imageUploadUrl()
      done: (e, data) =>
        this.model.set('image_url', data.result.image_url)
        @renderImageUploader()

  hide : =>
    $(this.el).hide()
