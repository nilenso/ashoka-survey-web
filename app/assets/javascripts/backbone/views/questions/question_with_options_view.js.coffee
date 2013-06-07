##= require ./question_view
SurveyBuilder.Views.Questions ||= {}

# The settings of a single radio question in the DOM
class SurveyBuilder.Views.Questions.QuestionWithOptionsView extends SurveyBuilder.Views.Questions.QuestionView

  events:
    'keyup  input[type=text]': 'handle_textbox_keyup'
    'change input[type=checkbox]': 'handle_checkbox_change'
    'click button.add_option': 'add_new_option_model'
    'click button.add_options_in_bulk': 'add_options_in_bulk'

  initialize: (model, template, @survey_frozen) =>
    super
    this.options = []
    this.model.on('add:options', this.add_new_option, this)
    this.model.get('options').on('destroy', this.delete_option_view, this)
    this.model.on('preload_options', this.preload_options, this)
    this.model.on('change', this.render, this)

  preload_options: (collection) =>
    collection.each( (model) =>
      this.add_new_option(model)
    )

  add_new_option_model: (content) =>
    this.model.create_new_option(content) if @confirm_if_frozen()

  add_new_option: (option_model) =>
    switch this.model.get('type')
      when 'RadioQuestion'
        template = $('#radio_option_template').html()
      when 'MultiChoiceQuestion'
        template = $('#multi_choice_option_template').html()
      when 'DropDownQuestion'
        template = $('#drop_down_option_template').html()

    option = new SurveyBuilder.Views.Questions.OptionView(option_model, template, @survey_frozen)
    this.options.push option
    $(this.el).append($(option.render().el))

  render: =>
    super
    $(this.el).append($(option.render().el)) for option in @options
    @limit_edit() if @survey_frozen
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
    try
      parsed_csv = $.csv.toArray(csv)
    catch error
      alert I18n.t("js.require_csv_format")
      return

    window.loading_overlay.show_overlay("Adding your options. Please wait.")
    _.delay(=>
      @model.destroy_options()
      for content in parsed_csv
        @add_new_option_model(content.trim()) if content && content.trim().length > 0
      window.loading_overlay.hide_overlay()
    , 10)

  confirm_if_frozen: =>
    if @survey_frozen
      confirm(I18n.t("js.confirm_add_option_to_finalized_survey"))
    else
      true

  limit_edit: =>
    super
    if @model.get("finalized")
      $(this.el).find("div.add_options_in_bulk").hide()
      $(this.el).find("textarea.add_options_in_bulk").hide()
      $(this.el).find(".add_option").attr("disabled", false)
