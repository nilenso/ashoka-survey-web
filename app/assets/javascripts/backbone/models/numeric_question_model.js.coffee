# Interfaces between the views and the rails model for a single line question
##= require ./question_model
class SurveyBuilder.Models.NumericQuestionModel extends SurveyBuilder.Models.QuestionModel

  defaults: {
    type: 'NumericQuestion',
    content: 'Untitled question'
    mandatory: false
  }

SurveyBuilder.Models.NumericQuestionModel.setup()