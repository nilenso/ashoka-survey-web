# Wr
class SurveyBuilder.Models.SurveyModel extends Backbone.RelationalModel  
  initialize:(@survey_id) ->
    @question_models = []
    this.urlRoot = "/api/surveys"
    this.set('id', survey_id)
    this.set('questions_order_changed', false)

  add_new_question_model:(type, parent) ->
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
    @set_order_number_for_question(question_model, parent)
    question_model.set('parent_id' : parent.get('id')) if parent
    @remove_image_attributes(question_model)
    @question_models.push question_model
    question_model.on('destroy', this.delete_question_model, this)
    question_model

  get_order_counter: ->
    if _(@question_models).isEmpty()
      0
    else
      prev_order_counter = _(@question_models).last().get('order_number')
      prev_order_counter + 1 

  set_order_number_for_question: (model, parent) ->
    if parent
      model.set('order_number' : parent.get_sub_question_order_counter())
    else
      model.set('order_number' : this.get_order_counter())

  remove_image_attributes: (model) ->
    model.unset('image', {silent: true})
    model.unset('image_content_type', {silent: true})
    model.unset('image_file_name', {silent: true})
    model.unset('image_file_size', {silent: true})
    model.unset('image_updated', {silent: true})

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
    if this.get('questions_order_changed')
      this.reset_and_save_reordered_questions()
    else
      for question_model in @question_models
        question_model.save_model()

  reset_and_save_reordered_questions: ->
    $("#survey_builder").bind('ajaxStop.save', this.save_reordered_questions)
    for question_model in @question_models
      question_model.set( {temp_order_number : question_model.get('order_number')} )
      question_model.set( {order_number : ""} )
      question_model.save_model()
    this.set('questions_order_changed', false)

  save_reordered_questions: =>
    $("#survey_builder").unbind('ajaxStop.save')
    for question_model in @question_models
      question_model.set( {order_number : question_model.get('temp_order_number')} )
      question_model.save_model()

  delete_question_model: (model) ->
    @question_models = _(@question_models).without(model)

  has_errors: ->
    _.any(@question_models, (question_model) -> question_model.has_errors())

  questions_order_changed: ->
    this.set('questions_order_changed', true)

SurveyBuilder.Models.SurveyModel.setup()