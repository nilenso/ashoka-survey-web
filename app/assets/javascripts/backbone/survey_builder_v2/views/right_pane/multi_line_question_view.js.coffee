##= require ./question_without_options_view

class SurveyBuilderV2.Views.RightPane.MultiLineQuestionView extends SurveyBuilderV2.Views.RightPane.QuestionWithoutOptionsView
  events:
    "change .question-content-textarea": "updateModelContent"
    "change .question-answer-type-select": "updateView"
    "click .question-settings input": "updateModelSettings"
    "click .question-update": "saveQuestion"

  updateModelContent: (event) =>
    content = $(event.target).val()
    @model.set(content: content)

  viewType: =>
    "MultilineQuestion"
