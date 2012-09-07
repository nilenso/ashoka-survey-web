# Interfaces between the views and the rails model for a multiline question
##= require ./question_model
class SurveyBuilder.Models.MultilineQuestionModel extends SurveyBuilder.Models.QuestionModel

  defaults: {
    type: 'MultilineQuestion',
    content: 'Untitled question'
    mandatory: false
  }

SurveyBuilder.Models.MultilineQuestionModel.setup()