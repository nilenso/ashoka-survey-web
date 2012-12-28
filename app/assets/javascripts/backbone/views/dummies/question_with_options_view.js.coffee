##= require ./question_view
SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy radio question on the DOM
class SurveyBuilder.Views.Dummies.QuestionWithOptionsView extends SurveyBuilder.Views.Dummies.QuestionView

  initialize: (model, template) =>
    super
    this.options = []
    this.model.get('options').on('change', this.render, this)
    this.model.get('options').on('destroy', this.delete_option_view, this)
    this.model.on('add:options', this.add_new_option, this)
    this.model.on('reset:options', this.preload_options, this)

  render: =>
    super
    $(this.el).children(".dummy_question_content").click (e) =>
      @show_actual(e)

    $(this.el).children('.dummy_question_content').children(".delete_question").click (e) => @delete(e)

    _.each(this.options, (option) =>
        $(this.el).children('.dummy_question_content').append(option.render().el)
      )

    _(this.options).each (option) =>
      group = $("<div class='sub_question_group'>")
      group.sortable({items: "> div", update: @reorder_questions})
      group.append("<p class='sub_question_group_message'> #{I18n.t('js.questions_for')} #{option.model.get('content')}</p>")
      _(option.sub_questions).each (sub_question) =>
        group.append(sub_question.render().el)
      $(this.el).append(group) unless _(option.sub_questions).isEmpty()

    if this.model.has_drop_down_options()
      option_value = this.model.get_first_option_value()
      $(this.el).find('option').text(option_value)

    return this

  preload_options: (collection) =>
    collection.each( (model) =>
      this.add_new_option(model, { do_not_render: true })
    )
    @render()

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
    this.render() unless options.do_not_render

  delete_option_view: (model) =>
    option = _(@options).find((option) => option.model == model )
    @options = _(@options).without(option)
    this.render()

  unfocus: =>
    super
    _(this.options).each (option) =>
      _(option.sub_questions).each (sub_question) =>
        sub_question.unfocus()

  reorder_questions: (event, ui) =>
    _(@options).each (option) =>
      unless _(option.sub_questions).isEmpty()
        last_order_number = _.chain(option.sub_questions)
          .map((sub_question) => sub_question.model.get('order_number'))
          .max().value()
        _(option.sub_questions).each (sub_question) =>
            index = $(sub_question.el).index()
            sub_question.model.set({order_number: last_order_number + index + 1})
            sub_question.model.question_number = option.model.get('question').question_number + '.' + (index)
            sub_question.reorder_questions() if sub_question instanceof SurveyBuilder.Views.Dummies.CategoryView
            sub_question.reorder_questions() if sub_question instanceof SurveyBuilder.Views.Dummies.QuestionWithOptionsView
        option.sub_questions = _(option.sub_questions).sortBy (sub_question) =>
          sub_question.model.get('order_number')
    @render()
