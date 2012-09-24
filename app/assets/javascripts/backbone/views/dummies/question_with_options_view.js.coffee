##= require ./question_view
SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy radio question on the DOM
class SurveyBuilder.Views.Dummies.QuestionWithOptionsView extends SurveyBuilder.Views.Dummies.QuestionView

  events:
    "click": 'show_actual'
    "click .delete_question": 'delete'

  initialize: (model, template) ->
    super
    this.options = []
    this.model.get('options').on('change', this.render, this)
    this.model.on('add:options', this.add_new_option, this)

  render: ->
    super
    _.each(this.options, (option) =>
        $(this.el).append(option.render().el)
      )
    if this.model.has_drop_down_options()
      option_value = this.model.get_first_option_value()
      $(this.el).find('option').text(option_value)

    return this

  add_new_option: (model) ->
    switch this.model.get('type')
      when 'RadioQuestion'
        template = $('#dummy_radio_option_template').html()
      when 'MultiChoiceQuestion'
        template = $('#dummy_multi_choice_option_template').html()
      when 'DropDownQuestion'
        return

    this.options.push new SurveyBuilder.Views.Dummies.OptionView(model, template)
    this.render()

