SurveyBuilder.Views.Questions ||= {}

# The settings of a single single line question in the DOM
class SurveyBuilder.Views.Questions.SurveyDetailsView extends Backbone.View

  events:
    'keyup  input[type=text]': 'handle_textbox_keyup'
    'keyup  textarea': 'handle_textbox_keyup'
    'change textarea': 'handle_textbox_keyup'
    'change input[type=text]': 'handle_textbox_keyup'
    'change input[type=checkbox]': 'handle_checkbox_change'

  initialize: =>
    this.model.actual_view = this
    @template = this.options.template
    this.model.on('change', this.render, this)

  render:(template) =>
    $(this.el).html(Mustache.render(this.template, this.model.toJSON()))
    $('#expiry_date').datepicker({ dateFormat: "yy-mm-dd" });
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

  hide : =>
    $(this.el).hide()

  limit_edit: =>
    $(this.el).find(":input").attr("disabled", true)
