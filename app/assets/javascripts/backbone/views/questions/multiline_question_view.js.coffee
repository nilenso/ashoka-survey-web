##= require ./question_view
SurveyBuilder.Views.Questions ||= {}

# The settings of a single multiline question in the DOM
class SurveyBuilder.Views.Questions.MultilineQuestionView extends SurveyBuilder.Views.Questions.QuestionView

  events:
    'keyup  input[type=text]': 'handle_textbox_keyup'
    'change input[type=number]': 'handle_textbox_keyup'
    'change input[type=checkbox]': 'handle_checkbox_change'

  render: ->
    template = $('#multiline_question_template').html()
    super template
    