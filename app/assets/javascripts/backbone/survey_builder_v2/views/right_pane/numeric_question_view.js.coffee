##= require ./question_without_options_view

class SurveyBuilderV2.Views.RightPane.NumericQuestionView extends SurveyBuilderV2.Views.RightPane.QuestionWithoutOptionsView
  events:
    "change .question-answer-type-select": "updateView"
    "change .question-content-textarea": "updateModelContent"
    "click .question-settings input": "updateModelSettings"
    "keyup .question-max-value-text": "updateModelMaxValue"
    "keyup .question-min-value-text": "updateModelMinValue"
    "click .question-update": "saveQuestion"

  templatePath: =>
    "v2_survey_builder/surveys/right_pane/numeric_question"

  updateModelContent: (event) =>
    content = $(event.target).val()
    @model.set(content: content)

  updateModelMaxValue: (event) =>
    val = parseInt($(event.target).val())
    @model.set(max_value: val)

  updateModelMinValue: (event) =>
    val = parseInt($(event.target).val())
    @model.set(min_value: val)

  viewType: =>
    "NumericQuestion"

