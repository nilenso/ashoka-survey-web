class SurveyBuilder.Models.SurveyModel extends Backbone.RelationalModel
  ORDER_NUMBER_STEP: 2

  initialize:(@survey_id) =>
    @question_models = []
    @urlRoot = "/api/surveys"
    @set('id', survey_id)

  add_new_question_model: (element_attrs) =>
    #REFACTOR: Rename question to element
    question_model = SurveyBuilder.Views.QuestionFactory.model_for(element_attrs)
    @set_order_number_for_question(question_model)
    @question_models.push question_model
    @set_question_number_for_question(question_model)
    question_model.on('destroy', @delete_question_model, this)
    question_model

  next_order_number: =>
    return 0 if _(@question_models).isEmpty()
    _.max(@question_models, (question_model) =>
      question_model.get "order_number"
    ).get('order_number') + @ORDER_NUMBER_STEP

  set_order_number_for_question: (question_model) =>
    question_model.set('order_number' : @next_order_number())

  set_question_number_for_question: (question_model) =>
    question_model.question_number = @question_models.length

  save: =>
    super({}, {error: @error_callback, success: @success_callback})

  success_callback: (model, response) =>
    @errors = []
    @trigger('change:errors')
    @trigger('save:completed')

  error_callback: (model, response) =>
    @errors = JSON.parse(response.responseText)
    @trigger('change:errors')

  save_all_questions: =>
    for question_model in @question_models
      question_model.save_model()

  delete_question_model: (model) =>
    @question_models = _(@question_models).without(model)

  has_errors: =>
    _.any(@question_models, (question_model) => question_model.has_errors())

SurveyBuilder.Models.SurveyModel.setup()
