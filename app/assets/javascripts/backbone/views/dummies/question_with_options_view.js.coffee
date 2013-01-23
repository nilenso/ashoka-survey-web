##= require ./question_view
SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy radio question on the DOM
class SurveyBuilder.Views.Dummies.QuestionWithOptionsView extends SurveyBuilder.Views.Dummies.QuestionView

  initialize: (model, template) =>
    super
    this.options = []
    this.can_have_sub_questions = true
    this.model.get('options').on('destroy', this.delete_option_view, this)
    this.model.on('add:options', this.add_new_option, this)
    this.model.on('reset:options', this.preload_options, this)

  render: =>
    super
    $(this.el).children(".dummy_question_content:not(:has(div.children_content))").append('<div class="children_content"></div>')
    $(this.el).children(".dummy_question_content").click (e) =>
      @show_actual(e)

    $(this.el).children('.dummy_question_content').children(".delete_question").click (e) => @delete(e)

    $(this.el).children(".sub_question_group").html('')
    _(this.options).each (option) =>
      group = $("<div class='sub_question_group'>")
      group.sortable({
        items: "> div",
        update: ((event, ui) =>
          window.loading_overlay.show_overlay("Reordering Questions")
          _.delay(=>
            this.reorder_questions(event,ui)
          , 10)
        )
      })
      group.append("<p class='sub_question_group_message'> #{I18n.t('js.questions_for')} #{option.model.get('content')}</p>")
      _(option.sub_questions).each (sub_question) =>
        group.append(sub_question.render().el)
      $(this.el).append(group) unless _(option.sub_questions).isEmpty()

    @render_dropdown()

    return this

  preload_options: (collection) =>
    collection.each( (model) =>
      this.add_new_option(model)
    )

  render_dropdown: () =>
    if this.model.has_drop_down_options()
      option_value = this.model.get_first_option_value()
      $(this.el).find('option').text(option_value)

  add_new_option: (model, options={}) =>
    switch this.model.get('type')
      when 'RadioQuestion'
        template = $('#dummy_radio_option_template').html()
      when 'MultiChoiceQuestion'
        template = $('#dummy_multi_choice_option_template').html()
      when 'DropDownQuestion'
        template = $('#dummy_drop_down_option_template').html()

    view = new SurveyBuilder.Views.Dummies.OptionView(model, template)
    this.options.push view
    view.on('render_preloaded_sub_questions', this.render, this)
    view.on('render_added_sub_question', this.render, this)
    view.on('destroy:sub_question', this.reorder_questions, this)
    $(this.el).children('.dummy_question_content').children('.children_content').append(view.render().el)
    @render_dropdown()

  delete_option_view: (model) =>
    option = _(@options).find((option) => option.model == model )
    @options = _(@options).without(option)
    @render()

  unfocus: =>
    super
    _(this.options).each (option) =>
      _(option.sub_questions).each (sub_question) =>
        sub_question.unfocus()

  reorder_questions: (event, ui) =>
    _(@options).each (option) =>
      unless _(option.sub_questions).isEmpty()
        last_order_number =  @last_sub_question_order_number(option)

        _(option.sub_questions).each (sub_question) =>
            index = $(sub_question.el).index()
            sub_question.model.set({order_number: last_order_number + index + 1}, {silent: true})
            option.model.sub_question_order_counter = last_order_number + index + 1

        option.sub_questions = _(option.sub_questions).sortBy (sub_question) =>
          sub_question.model.get('order_number')

    @reset_question_number()
    @hide_overlay(event)


  hide_overlay: (event) =>
      window.loading_overlay.hide_overlay() if event

  last_sub_question_order_number: (option) =>
    _.chain(option.sub_questions)
      .map((sub_question) => sub_question.model.get('order_number'))
      .max().value()


  reset_question_number: =>
    for option in @options
      for sub_question in option.sub_questions
        index = $(sub_question.el).index()
        parent_question_number = option.model.get('question').question_number
        sub_question.model.question_number = '' + parent_question_number + @parent_option_character(option) + '.' + index

        sub_question.reset_question_number() if sub_question.can_have_sub_questions
    @render()

  parent_is_multichoice: (option) =>
    option.model.get('question').get('type') == "MultiChoiceQuestion"

  parent_option_character: (option) =>
    return '' unless @parent_is_multichoice(option)
    first_order_number = option.model.get('question').first_order_number()
    parent_option_number = option.model.get('order_number') - first_order_number
    String.fromCharCode(65 + parent_option_number)



