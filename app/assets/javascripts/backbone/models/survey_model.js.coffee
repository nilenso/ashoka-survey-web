# Wr
class SurveyBuilder.Models.SurveyModel extends Backbone.RelationalModel
  initialize:(@survey_id) ->
    @question_models = []
    this.urlRoot = "/api/surveys"
    this.set('id', survey_id)

  add_new_question_model:(type) ->
    switch type
      when 'MultiChoiceQuestion'
        question_model = new SurveyBuilder.Models.QuestionWithOptionsModel({type: 'MultiChoiceQuestion'})
      when 'DropDownQuestion'
        question_model = new SurveyBuilder.Models.QuestionWithOptionsModel({type: 'DropDownQuestion'})
      when 'RadioQuestion'
        question_model = new SurveyBuilder.Models.QuestionWithOptionsModel({type: 'RadioQuestion'})
      else
        question_model = new SurveyBuilder.Models.QuestionModel({type: type})

    question_model.set('survey_id' : this.survey_id)
    @set_order_number_for_question(question_model)
    @question_models.push question_model
    @set_question_number_for_question(question_model)
    question_model.on('destroy', this.delete_question_model, this)
    question_model

  add_new_category_model: ->
    question_model = new SurveyBuilder.Models.CategoryModel
    question_model.set('survey_id' : this.survey_id)
    @set_order_number_for_question(question_model)
    @question_models.push question_model
    @set_question_number_for_question(question_model)
    question_model.on('destroy', this.delete_question_model, this)
    question_model


  next_order_number: ->
    if _(@question_models).isEmpty()
      0
    else
      _.max(@question_models, (question_model) ->
        question_model.get "order_number"
      ).get('order_number') + 1

  set_order_number_for_question: (question_model) ->
    question_model.set('order_number' : this.next_order_number())

  set_question_number_for_question: (question_model) ->
    question_model.question_number = @question_models.length

  save: ->
    super({}, {error: this.error_callback, success: this.success_callback})

  success_callback: (model, response) =>
    this.errors = []
    this.trigger('change:errors')
    this.trigger('save:completed')

  error_callback: (model, response) =>
    this.errors = JSON.parse(response.responseText)
    this.trigger('change:errors')

  save_all_questions: ->
    for question_model in @question_models
      question_model.save_model()

  delete_question_model: (model) ->
    @question_models = _(@question_models).without(model)

  has_errors: ->
    _.any(@question_models, (question_model) -> question_model.has_errors())

SurveyBuilder.Models.SurveyModel.setup()
