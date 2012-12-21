SurveyBuilder.Views.Questions ||= {}

# The settings of a single category in the DOM
class SurveyBuilder.Views.Questions.CategoryView extends Backbone.View

  events:
    'keyup  input[type=text]': 'handle_textbox_keyup'

  initialize: (@model) ->
    this.template = $('#category_template').html()
    this.model.actual_view = this
    this.sub_questions = []
    this.model.on('save:completed', this.renderImageUploader, this)
    this.model.on('change', this.render, this)
    this.model.on('change:preload_sub_questions', this.preload_sub_questions)

  render:(template) ->
    $(this.el).html(Mustache.render(this.template, this.model.toJSON().category))
    return this

  handle_textbox_keyup: (event) ->
    this.model.off('change', this.render)
    input = $(event.target)
    propertyHash = {}
    propertyHash[input.attr('name')] = input.val()
    this.update_model(propertyHash)

  update_model: (propertyHash) ->
    this.model.set(propertyHash)

  hide : ->
    $(this.el).hide()
    sub_question.hide() for sub_question in @sub_questions

  add_sub_question: (sub_question_model) =>
    sub_question_model.on('destroy', this.delete_sub_question, this)
    type = sub_question_model.get('type')
    question = SurveyBuilder.Views.QuestionFactory.settings_view_for(type, sub_question_model)
    this.sub_questions.push question
    $('#settings_pane').append($(question.render().el))
    $(question.render().el).hide()

  preload_sub_questions: (collection) =>
    _.each(collection, (question) =>
      this.add_sub_question(question)
    )

  delete_sub_question: (sub_question_model) ->
    view = sub_question_model.actual_view
    @sub_questions = _(@sub_questions).without(view)
    view.remove()
