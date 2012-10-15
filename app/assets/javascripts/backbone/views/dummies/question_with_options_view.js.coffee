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
    this.model.get('options').on('destroy', this.delete_option_view, this)
    this.model.on('add:options', this.add_new_option, this)
    this.model.on('reset:options', this.preload_options, this)

  render: ->
    super
    _.each(this.options, (option) =>
        $(this.el).append(option.render().el)
      )

    _(this.options).each (option) =>
      _(option.sub_questions).each (sub_question) =>
        $(this.el).append(sub_question.render().el)

    if this.model.has_drop_down_options()
      option_value = this.model.get_first_option_value()
      $(this.el).find('option').text(option_value)

    return this

  preload_options: (collection) ->
    collection.each( (model) =>
      this.add_new_option(model)
    )

  add_new_option: (model) ->
    switch this.model.get('type')
      when 'RadioQuestion'
        template = $('#dummy_radio_option_template').html()
      when 'MultiChoiceQuestion'
        template = $('#dummy_multi_choice_option_template').html()
      when 'DropDownQuestion'
        return

    view = new SurveyBuilder.Views.Dummies.OptionView(model, template)
    this.options.push view
    view.on('change:preloaded_sub_questions', this.render, this)
    view.on('change:added_sub_question', this.render, this)
    this.render()

  delete_option_view: (model) ->
    option = _(@options).find((option) -> option.model == model )
    @options = _(@options).without(option)
    this.render()
