class SurveyBuilder.Models.OptionModel extends Backbone.RelationalModel
  urlRoot: '/api/options'
  defaults: {
    content: 'untitled'
  }
  ORDER_NUMBER_STEP: 2

  initialize: =>
    @sub_question_order_counter = 0
    @sub_question_models = []
    this.on('change', @make_dirty, this)
    @make_dirty()

  has_errors: =>
    !_.isEmpty(this.errors)

  make_dirty: =>
    @dirty = true

  make_clean: =>
    @dirty = false

  is_dirty: =>
    @dirty

  save_model: =>
    this.save({}, {error: this.error_callback, success: this.success_callback}) if @is_dirty()
    for sub_question_model in @sub_question_models
      sub_question_model.save_model()

  toJSON: =>
    acc = _(@attr_accessible()).reduce((acc,elem) =>
            acc[elem] = @get(elem)
            acc
          , {})
    { option: acc }


  success_callback: (model, response) =>
    @make_clean()
    this.errors = []
    this.trigger('change:errors')

  error_callback: (model, response) =>
    this.errors = JSON.parse(response.responseText)
    this.trigger('change:errors')

  next_sub_question_order_number: =>
    @sub_question_order_counter += @ORDER_NUMBER_STEP

  add_sub_question: (type) =>

    question = {
      type: type,
      parent_id: this.id,
      survey_id: this.get('question').get('survey_id'),
      order_number: @next_sub_question_order_number(),
      parent_question: this.get('question')
    }

    sub_question_model = SurveyBuilder.Views.QuestionFactory.model_for(question)

    @sub_question_models.push sub_question_model
    sub_question_model.on('destroy', this.delete_sub_question, this)
    @set_question_number_for_sub_question(sub_question_model)
    sub_question_model.save_model()
    this.trigger('add:sub_question', sub_question_model)

  set_question_number_for_sub_question: (sub_question_model) =>
    parent_question = this.get('question')
    multichoice_parent = parent_question.get('type') == "MultiChoiceQuestion"
    option_order_number = this.get('order_number') - parent_question.first_order_number()
    parent_question_number = parent_question.question_number
    parent_question_number +=  '' + String.fromCharCode(65 + option_order_number) if multichoice_parent
    sub_question_model.question_number = "#{parent_question_number}.#{@sub_question_models.length}"

  delete_sub_question: (sub_question_model) =>
    @sub_question_models = _(@sub_question_models).without(sub_question_model)
    @reorder_sub_questions_models()

  has_sub_questions: =>
    this.get('elements').length > 0

  reorder_sub_questions_models: =>
    for sub_question_model in @sub_question_models
      sub_question_model.set('order_number', @next_sub_question_order_number())
    @save_model()

  preload_sub_elements: =>
    return unless @has_sub_questions()
    elements = @get('elements')
    _.each elements, (question) =>
      parent_question = this.get('question')
      _(question).extend({parent_question: parent_question})

      question_model = SurveyBuilder.Views.QuestionFactory.model_for(question)

      @sub_question_models.push question_model
      question_model.on('destroy', this.delete_sub_question, this)
      @set_question_number_for_sub_question(question_model)

    this.trigger('change:preload_sub_questions', @sub_question_models)
    _.each(@sub_question_models, (question) =>
      question.preload_sub_elements()
    )
    @sub_question_order_counter = _(elements).last().order_number

  attr_accessible: =>
    ['id', 'content', 'order_number', 'question_id']

SurveyBuilder.Models.OptionModel.setup()

# Collection of all options for radio question
class SurveyBuilder.Collections.OptionCollection extends Backbone.Collection
  model: SurveyBuilder.Models.OptionModel

  has_errors: =>
    this.any((option) => option.has_errors())
