SurveyBuilder.Views.Questions ||= {}

# The settings of a single multiline question in the DOM
class SurveyBuilder.Views.Questions.MultilineQuestionView extends Backbone.View

  events:
    'keyup  textarea': 'handle_textbox_keyup'
    'change input[type=number]': 'handle_textbox_keyup'
    'change input[type=checkbox]': 'handle_checkbox_change'

  initialize: (model) ->
    this.model = model
    this.model.actual_view = this
    this.model.on('save:completed', this.renderImageUploader, this)

  render: ->
    template = $('#multiline_question_template').html()
    $(this.el).html(Mustache.render(template, this.model.toJSON()))
    return this

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
      send: (e, data) =>
        opts =
          length: 0 # The length of each line
          width: 4 # The line thickness
          radius: 8 # The radius of the inner circle
          corners: 0.9 # Corner roundness (0..1)

        @spinner = $('.spinner').spin(opts)
      done: (e, data) =>
        @spinner.spin(false)
