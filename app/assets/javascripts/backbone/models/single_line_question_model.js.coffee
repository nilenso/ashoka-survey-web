# Interfaces between the views and the rails model for a single line question
class SurveyBuilder.Models.SingleLineQuestionModel extends SurveyBuilder.Models.QuestionModel

  defaults: {
    type: 'SingleLineQuestion',
    content: 'Untitled question'
    mandatory: false
  }

SurveyBuilder.Models.SingleLineQuestionModel.setup()