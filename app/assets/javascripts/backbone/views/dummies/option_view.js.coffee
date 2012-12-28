# Represents a dummy option in the DOM
SurveyBuilder.Views.Dummies ||= {}

class SurveyBuilder.Views.Dummies.OptionView extends Backbone.View

  initialize: (@model, @template) =>
    this.sub_questions = []
    this.model.on('change', this.render, this)
    this.model.on('change:errors', this.render, this)
    this.model.on('add:sub_question', this.add_sub_question)
    this.model.on('change:preload_sub_questions', this.preload_sub_questions)

  render: =>
    data = _.extend(this.model.toJSON(), {errors: this.model.errors})
    $(this.el).html(Mustache.render(@template, data))
    return this

  add_sub_question: (sub_question_model) =>
    sub_question_model.on('destroy', this.delete_sub_question, this)
    type = sub_question_model.get('type')    
    question = SurveyBuilder.Views.QuestionFactory.dummy_view_for(type, sub_question_model)
    this.sub_questions.push question
    this.trigger('render_added_sub_question')
    this.render()

  preload_sub_questions: (sub_question_models) =>
    _.each(sub_question_models, (sub_question_model) =>
      this.add_sub_question(sub_question_model)
    )
    this.trigger('render_preloaded_sub_questions')

  delete_sub_question: (sub_question_model) =>
    view = sub_question_model.dummy_view
    @sub_questions = _(@sub_questions).without(view)
    view.remove()
    this.trigger('destroy:sub_question')