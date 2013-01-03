##= require ./question_view
SurveyBuilder.Views.Questions ||= {}

# The settings of a single radio question in the DOM
class SurveyBuilder.Views.Questions.QuestionWithOptionsView extends SurveyBuilder.Views.Questions.QuestionView

  events:
    'keyup  input[type=text]': 'handle_textbox_keyup'
    'change input[type=checkbox]': 'handle_checkbox_change'
    'click button.add_option': 'add_new_option_model'
    'click button.add_options_in_bulk': 'add_options_in_bulk'

  initialize: (model, template) =>
    super
    this.options = []
    this.model.on('add:options', this.add_new_option, this)
    this.model.get('options').on('destroy', this.delete_option_view, this)
    this.model.on('reset:options', this.preload_options, this)
    this.model.on('change', this.render, this)

  preload_options: (collection) =>
    collection.each( (model) =>
      this.add_new_option(model)
    )

  add_new_option_model: (content) =>
    this.model.create_new_option(content)

  add_new_option: (option_model) =>
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

  render: =>
    super
    $(this.el).append($(option.render().el)) for option in @options
    return this

  delete_option_view: (model) =>
    option = _(@options).find((option) => option.model == model)
    @options = _(@options).without(option)
    option.remove()

  hide : =>
    super
    _(this.options).each (option) =>
        _(option.sub_questions).each (sub_question) =>
          sub_question.hide()

  add_options_in_bulk: =>
    csv = $(this.el).children('textarea.add_options_in_bulk').val()
    return if csv == ""
    parsed_csv = $.csv.toArray(csv)
    window.loading_overlay.show_overlay("Adding your options. Please wait.")    
    _.delay(=>
      @model.destroy_options()
      for content in parsed_csv
        @add_new_option_model(content) if content && content.trim().length > 0
      window.loading_overlay.hide_overlay()
    , 10)
    
