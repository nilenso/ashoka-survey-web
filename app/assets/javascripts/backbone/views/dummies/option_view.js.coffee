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
    template = $('#dummy_single_line_question_template').html()
    question = new SurveyBuilder.Views.Dummies.QuestionView(sub_question_model, template)
    this.sub_questions.push question
    this.trigger('change:added_sub_question')
    this.render()

  preload_sub_questions: (collection) =>
    _.each(collection, (question) =>
      this.add_sub_question(question)
    )
    this.trigger('change:preloaded_sub_questions')
    this.render()
