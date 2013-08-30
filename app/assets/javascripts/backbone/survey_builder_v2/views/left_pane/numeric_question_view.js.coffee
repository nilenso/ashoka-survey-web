##= require ./question_view

class SurveyBuilderV2.Views.LeftPane.NumericQuestionView extends SurveyBuilderV2.Views.LeftPane.QuestionView
  events:
    "click": "makeActive"
    "click .question-delete-button": "destroyQuestion"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.NumericQuestionModel(attributes.question)
    @template = SMT["v2_survey_builder/surveys/left_pane/numeric_question"]
    super(attributes)

    rightPaneParams = model: @model, leftPaneView: this, question: attributes.question
    @rightPaneView = new SurveyBuilderV2.Views.RightPane.NumericQuestionView(rightPaneParams)

