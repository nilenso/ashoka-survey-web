# Represents a dummy option in the DOM
SurveyBuilder.Views.Dummies ||= {}

class SurveyBuilder.Views.Dummies.OptionView extends Backbone.View

  initialize: (@model, @template) ->
    this.sub_questions = []
    this.model.on('change:errors', this.render, this)
    this.model.on('add:sub_question', this.add_sub_question)
    this.model.on('change:preload_questions', this.preload_sub_questions)

  render: ->
    data = _.extend(this.model.toJSON(), {errors: this.model.errors})
    $(this.el).html(Mustache.render(@template, data))
    return this

  add_sub_question: (sub_question_model) =>
    sub_question_model.on('destroy', this.delete_sub_question, this)
    template = $('#dummy_radio_question_template').html()
    question = new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(sub_question_model, template)
    this.sub_questions.push question
    this.trigger('render_added_sub_question')
    this.render()

  preload_sub_questions: (collection) =>
    _.each(collection, (question) =>
      this.add_sub_question(question)
    )
    this.trigger('render_preloaded_sub_questions')

  delete_sub_question: (sub_question_model) ->
    view = sub_question_model.dummy_view
    @sub_questions = _(@sub_questions).without(view)
    view.remove()