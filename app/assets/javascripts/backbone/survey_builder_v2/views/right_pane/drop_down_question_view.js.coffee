##= require ./question_with_options_view

class SurveyBuilderV2.Views.RightPane.DropDownQuestionView extends SurveyBuilderV2.Views.RightPane.QuestionWithOptionsView
  events:
    "change .question-content-textarea": "updateModelContent"
    "change .question-answer-type-select": "updateView"
    "click .question-settings input": "updateModelSettings"
    "click .question-update": "saveQuestion"
    "change input[name=question-option-fields-text]": "addOptionsInBulk"

  updateModelContent: (event) =>
    content = $(event.target).val()
    @model.set(content: content)

  viewType: =>
    "DropDownQuestion"
