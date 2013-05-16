SurveyBuilder.Views.Questions ||= {}

# The settings of a single category in the DOM
class SurveyBuilder.Views.Questions.CategoryView extends Backbone.View

  events:
    'keyup  input[type=text]': 'handle_textbox_keyup'
    'change input[type=checkbox]': 'handle_checkbox_change'

  initialize: (@model, @template, @survey_frozen) =>
    this.model.actual_view = this
    this.sub_questions = []
    this.model.on('save:completed', this.renderImageUploader, this)
    this.model.on('add:sub_question', this.add_sub_question, this)
    this.model.on('change', this.render, this)
    this.model.on('change:id', this.render, this)
    this.model.on('change:preload_sub_questions', this.preload_sub_questions)

  render:(template) =>
    data = this.model.toJSON().category
    _(data).extend({ has_multi_record_ancestor: @model.get('has_multi_record_ancestor') })
    _(data).extend({ finalized: @model.get('finalized') })
    $(this.el).html(Mustache.render(this.template, data))
    $(this.el).children('div').children('.add_sub_question').bind('click', this.add_sub_question_model)
    $(this.el).children('div').children('.add_sub_category').bind('click', this.add_sub_category_model)
    $(this.el).children('div').children('.add_sub_multi_record').bind('click', this.add_sub_category_model)
    @limit_edit() if @survey_frozen
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
    sub_question.hide() for sub_question in @sub_questions

  add_sub_question_model: (event) =>
    type = $(event.target).prev().val()
    this.model.add_sub_question(type)

  add_sub_category_model: (event) =>
    type = $(event.target).data('type')
    this.model.add_sub_question(type)

  add_sub_question: (sub_question_model) =>
    sub_question_model.on('destroy', this.delete_sub_question, this)
    type = sub_question_model.get('type')
    question = SurveyBuilder.Views.QuestionFactory.settings_view_for(type, sub_question_model, @survey_frozen)
    this.sub_questions.push question
    $('#settings_pane').append($(question.render().el))
    $(question.render().el).hide()

  preload_sub_questions: (collection) =>
    _.each(collection, (question) =>
      this.add_sub_question(question)
    )

  delete_sub_question: (sub_question_model) =>
    view = sub_question_model.actual_view
    @sub_questions = _(@sub_questions).without(view)
    view.remove()

  limit_edit: =>
