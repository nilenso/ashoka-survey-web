##= require ./question_model

# Job of the class goes here

class SurveyBuilder.Models.<%= class_name %>Model extends SurveyBuilder.Models.QuestionModel
  defaults: {
    type: '<%= class_name %>',
    content: 'Untitled question'
    mandatory: false
  }

SurveyBuilder.Models.<%= class_name %>QuestionModel.setup()