##= require ./question_view

class SurveyBuilderV2.Views.RightPane.DateQuestionView extends SurveyBuilderV2.Views.RightPane.QuestionView
  events:
    "change .question-answer-type-select": "updateView"
    "click .question-settings input": "updateModelSettings"
    "click .question-update": "saveQuestion"

  initialize: (attributes) =>
    @template = SMT["v2_survey_builder/surveys/right_pane/date_question"]
    super(attributes)

  updateModelContent: (event) =>
    content = $(event.target).val()
    @model.set(content: content)

  updateView: (event) =>
    SurveyBuilderV2.Views.AnswerTypeSwitcher.switch("DateQuestion", event, @leftPaneView, @model.dup())
