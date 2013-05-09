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
    this.model.on('change:id', this.render, this)

  render:(template) =>
    json = this.model.toJSON().question
    json.allow_identifier = @allow_identifier()
    $(this.el).html(Mustache.render(this.template, json))
    @renderImageUploader()
    return this

  allow_identifier: =>
    !(this.model.get('parent_id') || this.model.get('has_multi_record_ancestor'))

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
      url: @model.image_upload_url()
      done: (e, data) =>
        this.model.set('image_url', data.result.image_url)
        @renderImageUploader()

  hide : =>
    $(this.el).hide()


  show: =>
    $(this.el).show()
    first_input = $($(this.el).find('input:text'))[0]
    $(first_input).select()

  freeze_view: =>
    $(this.el).find(":input").attr("disabled", true)

