SurveyBuilder.Views.Questions ||= {}

# The settings of a single radio question in the DOM
class SurveyBuilder.Views.Questions.RadioQuestionView extends Backbone.View

  events:
    'keyup  input[type=text]': 'handle_textbox_keyup'
    'change input[type=checkbox]': 'handle_checkbox_change'
    'click .add_option': 'add_new_option_model'

  initialize: (model) ->
    this.model = model
    this.model.actual_view = this
    this.options = []
    this.model.on('add:options', this.add_new_option, this)
    this.model.on('save:completed', this.renderImageUploader, this)

  render: ->
    template = $('#radio_question_template').html()
    $(this.el).html(Mustache.render(template, this.model.toJSON()))
    return this

  add_new_option_model: ->
    this.model.create_new_option()

  add_new_option: (option_model) ->
    option = new SurveyBuilder.Views.Questions.OptionView(option_model)
    this.options.push option
    $(this.el).append($(option.render().el))

  handle_textbox_keyup: (event) ->
    input = $(event.target)
    propertyHash = {}
    propertyHash[input.attr('name')] = input.val()
    this.update_model(propertyHash)

  handle_checkbox_change: (event) ->
    input = $(event.target)
    propertyHash = {}
    propertyHash[input.attr('name')] = input.is(':checked')
    this.update_model(propertyHash)

  update_model: (propertyHash) ->
    this.model.set(propertyHash)

  renderImageUploader: ->
    $(".fileupload").fileupload
      dataType: "json"
      url: @model.imageUploadUrl()
      replaceFileInput: false
      done: (e, data) =>
        this.model.set('image_url', data.result.image_url)

