# Wr
class SurveyBuilder.Models.SurveyModel extends Backbone.RelationalModel

  initialize:(survey_id) ->
  	this.survey_id = survey_id
  	@question_models = []

  add_new_question_model: ->
    question_model = new SurveyBuilder.Models.RadioQuestionModel
    question_model.set('survey_id' : this.survey_id)
    @question_models.push question_model
    question_model

  save_all_questions: ->
    for question_model in @question_models when question_model.attributes['type'] == "RadioQuestion"
      question_model.save_with_options()

  has_errors: ->
    _.any(@question_models, (question_model) -> question_model.has_errors())

SurveyBuilder.Models.SurveyModel.setup()