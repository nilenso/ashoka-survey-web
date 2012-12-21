# Interfaces between the views and the rails model for a multiline category
class SurveyBuilder.Models.CategoryModel extends Backbone.RelationalModel
  urlRoot: '/api/categories'

  defaults:
    content: 'Untitled Category'

  initialize: ->
    this.set('content', I18n.t('js.untitled_category'))
    @sub_question_order_counter = 0
    @sub_question_models = []

  save_model: ->
    this.save({}, {error: this.error_callback, success: this.success_callback})

  has_errors: ->
    false

  fetch: ->
    super({error: this.error_callback, success: this.success_callback})

  success_callback: (model, response) =>
    this.errors = []
    this.trigger('change:errors')
    this.trigger('save:completed')
    @preload_sub_questions()

  error_callback: (model, response) =>
    this.errors = JSON.parse(response.responseText)
    this.trigger('change:errors')

  toJSON: ->
    category_attrs = {}
    _.each @attributes, (val, key) ->
      category_attrs[key] = val  if val? and not _.isObject(val)
    { category: _.omit( category_attrs, ['created_at', 'id', 'updated_at']) }

  next_sub_question_order_number: ->
    ++@sub_question_order_counter

  delete_sub_question: (sub_question_model) ->
    @sub_question_models = _(@sub_question_models).without(sub_question_model)

  preload_sub_questions: ->
    _.each this.get('questions'), (question, counter) =>
      _(question).extend({ order_number: counter })
      switch question.type
        when 'MultiChoiceQuestion'
          question_model = new SurveyBuilder.Models.QuestionWithOptionsModel(question)
        when 'DropDownQuestion'
          question_model = new SurveyBuilder.Models.QuestionWithOptionsModel(question)
        when 'RadioQuestion'
          question_model = new SurveyBuilder.Models.QuestionWithOptionsModel(question)
        else
          question_model = new SurveyBuilder.Models.QuestionModel(question)

      @sub_question_models.push question_model
      question_model.on('destroy', this.delete_sub_question, this)
      #@set_question_number_for_sub_question(question_model)
      question_model.fetch()

    this.trigger('change:preload_sub_questions', @sub_question_models)
    @sub_question_order_counter = this.get('questions').length

SurveyBuilder.Models.CategoryModel.setup()
