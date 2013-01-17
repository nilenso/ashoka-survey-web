# Interfaces between the views and the rails model for an option
class SurveyBuilder.Models.OptionModel extends Backbone.RelationalModel
  urlRoot: '/api/options'
  defaults: {
    content: 'untitled'
  }

  initialize: =>
    @sub_question_order_counter = 0
    @sub_question_models = []
    this.on('change', @make_dirty, this)

  has_errors: =>
    !_.isEmpty(this.errors)

  make_dirty: =>
    @dirty = true

  make_clean: =>
    @dirty = false

  is_dirty: =>
    @dirty

  save_model: =>
    if @is_dirty()
      this.save({}, {error: this.error_callback, success: this.success_callback})
    _.each @sub_question_models, (question) =>
      question.save_model()

  success_callback: (model, response) =>
    @make_clean()
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
    multichoice_parent = this.get('question').get('type') == "MultiChoiceQuestion"
    parent_question_number +=  '' + String.fromCharCode(65 + this.get('order_number')) if multichoice_parent
    sub_question_model.question_number = "#{parent_question_number}.#{@sub_question_models.length}"

  delete_sub_question: (sub_question_model) =>
    @sub_question_models = _(@sub_question_models).without(sub_question_model)
    @reset_sub_questions_models_order_number()

  has_sub_questions: =>
    this.get('questions').length > 0 || this.get('categories').length > 0

  reset_sub_questions_models_order_number: =>
    @reset_order_number_counter()
    _.each @sub_question_models, (question) =>
      question.set('order_number', @next_sub_question_order_number())
    @save_model()

  reset_order_number_counter: =>
    @sub_question_order_counter = 0

  preload_sub_questions: =>
    return unless @has_sub_questions()
    elements = _((this.get('questions')).concat(this.get('categories'))).sortBy('order_number')
    _.each elements, (question, counter) =>
      parent_question = this.get('question')
      _(question).extend({parent_question: parent_question})

      question_model = SurveyBuilder.Views.QuestionFactory.model_for(question.type, question)

      @sub_question_models.push question_model
      question_model.on('destroy', this.delete_sub_question, this)
      @set_question_number_for_sub_question(question_model)
      question_model.fetch()

    this.trigger('change:preload_sub_questions', @sub_question_models)    
    @sub_question_order_counter = _(elements).last().order_number

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
