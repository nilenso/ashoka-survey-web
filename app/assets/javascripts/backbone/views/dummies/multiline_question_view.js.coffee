##= require ./question_view
SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy multiline question on the DOM
class SurveyBuilder.Views.Dummies.MultilineQuestionView extends SurveyBuilder.Views.Dummies.QuestionView

  events:
    "click": 'show_actual'

  render: ->
    template = $('#dummy_multiline_question_template').html()
    super template
