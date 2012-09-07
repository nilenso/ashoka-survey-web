##= require ./question_view
SurveyBuilder.Views.Questions ||= {}

# The settings of a single radio question in the DOM
class SurveyBuilder.Views.Questions.QuestionWithOptionsView extends SurveyBuilder.Views.Questions.QuestionView

  events:
    'keyup  input[type=text]': 'handle_textbox_keyup'
    'change input[type=checkbox]': 'handle_checkbox_change'
    'click .add_option': 'add_new_option_model'

  initialize: (model, template) ->
    super
    this.options = []
    this.model.on('add:options', this.add_new_option, this)

  add_new_option_model: ->
    this.model.create_new_option()

  add_new_option: (option_model) ->
    option = new SurveyBuilder.Views.Questions.OptionView(option_model)
    this.options.push option
    $(this.el).append($(option.render().el))
