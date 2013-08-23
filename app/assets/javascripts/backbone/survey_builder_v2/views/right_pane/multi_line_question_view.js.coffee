##= require ./question_view

class SurveyBuilderV2.Views.RightPane.MultiLineQuestionView extends SurveyBuilderV2.Views.RightPane.QuestionView
  events:
    "change .question-content-textarea": "updateModelContent"
    "change .question-answer-type-select": "updateView"
    "click .question-settings input": "updateModelSettings"
    "click .question-update": "saveQuestion"

  initialize: (attributes) =>
    @template = SMT["v2_survey_builder/surveys/right_pane/multi_line_question"]
    super(attributes)

  updateModelContent: (event) =>
    console.log "updating content"
    content = $(event.target).val()
    @model.set(content: content)

  viewType: =>
    "MultilineQuestion"
