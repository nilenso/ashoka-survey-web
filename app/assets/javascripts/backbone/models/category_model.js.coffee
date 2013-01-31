# Interfaces between the views and the rails model for a multiline category
class SurveyBuilder.Models.CategoryModel extends Backbone.RelationalModel
  urlRoot: '/api/categories'

  ORDER_NUMBER_STEP: 2

  initialize: =>
    this.set('content', I18n.t('js.untitled_category'))
    @sub_question_order_counter = 0
    @sub_question_models = []
    this.on('change', @make_dirty, this)
    @make_dirty()

  duplicate_url: =>
    '/api/categories/'+ @id + '/duplicate'

  make_dirty: =>
    @dirty = true

  make_clean: =>
    @dirty = false

  is_dirty: =>
    @dirty

  save_model: =>
    if @is_dirty()
      this.save({}, {error: this.error_callback, success: this.success_callback})
    sub_question.save_model() for sub_question in this.sub_question_models

  has_errors: =>
    false

  fetch: =>
    super({error: this.error_callback, success: =>
      this.success_callback
      this.preload_sub_questions()
    })

  success_callback: (model, response) =>
    @make_clean()
    this.errors = []
    this.trigger('change:errors')
    this.trigger('save:completed')

  error_callback: (model, response) =>
    this.errors = JSON.parse(response.responseText)
    this.trigger('change:errors')
    this.trigger('set:errors')

  toJSON: =>
    category_attrs = {}
    _.each @attributes, (val, key) =>
      category_attrs[key] = val  if val? and not _.isObject(val)
    { category: _.omit( category_attrs, ['created_at', 'updated_at']) }

  add_sub_question: (type) =>
    question = {
      type: type,
      category_id: this.id,
      survey_id: this.get('survey_id'),
      order_number: @next_sub_question_order_number(),
    }

    sub_question_model = SurveyBuilder.Views.QuestionFactory.model_for(question)

    @sub_question_models.push sub_question_model
    sub_question_model.on('destroy', this.delete_sub_question, this)
    @set_question_number_for_sub_question(sub_question_model)
    sub_question_model.save_model()
    this.trigger('add:sub_question', sub_question_model)

  next_sub_question_order_number: =>
    @sub_question_order_counter += @ORDER_NUMBER_STEP

  delete_sub_question: (sub_question_model) =>
    @sub_question_models = _(@sub_question_models).without(sub_question_model)

  preload_sub_questions: =>
    elements = _((this.get('questions')).concat(this.get('categories'))).sortBy('order_number')
    _.each elements, (question, counter) =>
      _(question).extend({category_id: this.get('id')})
      question_model = SurveyBuilder.Views.QuestionFactory.model_for(question)

      @sub_question_models.push question_model
      question_model.on('destroy', this.delete_sub_question, this)
      @set_question_number_for_sub_question(question_model)
      question_model.fetch()

    this.trigger('change:preload_sub_questions', @sub_question_models)
    if elements.length > 0
      @sub_question_order_counter = _(elements).last().order_number
    else
      @sub_question_order_counter = 0

  set_question_number_for_sub_question: (sub_question_model) =>
    parent_question_number = this.question_number
    index = _(@sub_question_models).indexOf(sub_question_model) + 1
    sub_question_model.question_number = "#{parent_question_number}.#{index}"

SurveyBuilder.Models.CategoryModel.setup()
