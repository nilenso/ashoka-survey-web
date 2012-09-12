# Wr
class SurveyBuilder.Models.SurveyModel extends Backbone.RelationalModel

  initialize:(survey_id) ->
    this.survey_id = survey_id
    this.order_counter = 0
    @question_models = []

  add_new_question_model:(type) ->
    switch type
      when 'single_line'
        question_model = new SurveyBuilder.Models.QuestionModel({type: 'SingleLineQuestion'})
      when 'multiline'
        question_model = new SurveyBuilder.Models.QuestionModel({type: 'MultilineQuestion'})
      when 'numeric'
        question_model = new SurveyBuilder.Models.QuestionModel({type: 'NumericQuestion'})
      when 'date'
        question_model = new SurveyBuilder.Models.QuestionModel({type: 'DateQuestion'})
      when 'radio'
        question_model = new SurveyBuilder.Models.QuestionWithOptionsModel({type: 'RadioQuestion'})
      when 'multi_choice'
        question_model = new SurveyBuilder.Models.QuestionWithOptionsModel({type: 'MultiChoiceQuestion'})
      when 'drop_down'
        question_model = new SurveyBuilder.Models.QuestionWithOptionsModel({type: 'DropDownQuestion'})

    this.order_counter++
    question_model.set('survey_id' : this.survey_id)
    question_model.set('order_number' : this.order_counter)
    @remove_image_attributes(question_model)
    @question_models.push question_model
    question_model

  remove_image_attributes: (model) ->
    model.unset('image', {silent: true})
    model.unset('image_content_type', {silent: true})
    model.unset('image_file_name', {silent: true})
    model.unset('image_file_size', {silent: true})
    model.unset('image_updated', {silent: true})

  save_all_questions: ->
    for question_model in @question_models
      question_model.save_model()

  has_errors: ->
    _.any(@question_models, (question_model) -> question_model.has_errors())

SurveyBuilder.Models.SurveyModel.setup()