##= require ./question_view

class SurveyBuilderV2.Views.RightPane.RatingQuestionView extends SurveyBuilderV2.Views.RightPane.QuestionView
  events:
    "change .question-answer-type-select": "updateView"
    "click .question-settings input": "updateModelSettings"
    "click .question-update": "saveQuestion"

  initialize: (attributes) =>
    @template = SMT["v2_survey_builder/surveys/right_pane/rating_question"]
    super(attributes)

    @switcher = new SurveyBuilderV2.Views.AnswerTypeSwitcher("RatingQuestion",
      @leftPaneView)

  updateModelContent: (event) =>
    content = $(event.target).val()
    @model.set(content: content)
