SurveyBuilder.Views.Questions ||= {}

# The settings of a single single line question in the DOM
class SurveyBuilder.Views.Questions.SingleLineQuestionView extends Backbone.View

  events:
    'keyup  input[type=text]': 'handle_textbox_keyup'
    'change input[type=number]': 'handle_textbox_keyup'
    'change input[type=checkbox]': 'handle_checkbox_change'

  initialize: (model) ->
    this.model = model
    this.model.actual_view = this

  render: ->
    template = $('#single_line_question_template').html()
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
