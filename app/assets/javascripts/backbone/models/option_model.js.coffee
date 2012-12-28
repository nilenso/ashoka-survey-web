# Interfaces between the views and the rails model for an option
class SurveyBuilder.Models.OptionModel extends Backbone.RelationalModel
  urlRoot: '/api/options'
  defaults: {
    content: 'untitled'
  }

  initialize: =>
    @sub_question_order_counter = 0
    @sub_question_models = []

  has_errors: =>
    !_.isEmpty(this.errors)

  save_model: =>
    this.save({}, {error: this.error_callback, success: this.success_callback})
    _.each @sub_question_models, (question) =>
      question.save_model()

  success_callback: (model, response) =>
    this.errors = []
    this.trigger('change:errors')

  error_callback: (model, response) =>
    this.errors = JSON.parse(response.responseText)
    this.trigger('change:errors')

  next_sub_question_order_number: =>
    ++@sub_question_order_counter

  add_sub_question: (type) =>

    question = {
      type: type,
      parent_id: this.id,
      survey_id: this.get('question').get('survey_id'),
      order_number: @next_sub_question_order_number(),
      parent_question: this.get('question')
    }

    sub_question_model = SurveyBuilder.Views.QuestionFactory.model_for(question.type, question)

    @sub_question_models.push sub_question_model
    sub_question_model.on('destroy', this.delete_sub_question, this)
    @set_question_number_for_sub_question(sub_question_model)
    sub_question_model.save_model()
    this.trigger('add:sub_question', sub_question_model)

  set_question_number_for_sub_question: (sub_question_model) =>
    parent_question_number = this.get('question').question_number
    sub_question_model.question_number = "#{parent_question_number}.#{@sub_question_models.length}"

  delete_sub_question: (sub_question_model) =>
    @sub_question_models = _(@sub_question_models).without(sub_question_model)

  preload_sub_questions: =>
    elements = _((this.get('questions')).concat(this.get('categories'))).sortBy('order_number')
    _.each elements, (question, counter) =>
      console.log("HELLO")
      parent_question = this.get('question')
      _(question).extend({parent_question: parent_question, order_number: counter})

      question_model = SurveyBuilder.Views.QuestionFactory.model_for(question.type, question)

      @sub_question_models.push question_model
      question_model.on('destroy', this.delete_sub_question, this)
      @set_question_number_for_sub_question(question_model)
      question_model.fetch()

    this.trigger('change:preload_sub_questions', @sub_question_models)
    @sub_question_order_counter = elements.length

SurveyBuilder.Models.OptionModel.setup()

# Collection of all options for radio question
class SurveyBuilder.Collections.OptionCollection extends Backbone.Collection
  model: SurveyBuilder.Models.OptionModel

  url: =>
    '/api/options?question_id=' + this.question.id

  has_errors: =>
    this.any((option) => option.has_errors())
 
  preload_sub_questions: =>
    _.each this.models, (option_model) =>
      option_model.preload_sub_questions()
