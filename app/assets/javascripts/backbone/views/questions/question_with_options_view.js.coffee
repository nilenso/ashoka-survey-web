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
    switch this.model.get('type')
      when 'RadioQuestion'
        template = $('#radio_option_template').html()
      when 'MultiChoiceQuestion'
        template = $('#multi_choice_option_template').html()
      when 'DropDownQuestion'
        template = $('#drop_down_option_template').html()

    option = new SurveyBuilder.Views.Questions.OptionView(option_model, template)
    this.options.push option
    $(this.el).append($(option.render().el))
