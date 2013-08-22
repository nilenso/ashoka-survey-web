##= require ./question_view

class SurveyBuilderV2.Views.LeftPane.DateQuestionView extends SurveyBuilderV2.Views.LeftPane.QuestionView
  events:
    "click": "makeActive"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.DateQuestionModel(attributes.question)
    @template = SMT["v2_survey_builder/surveys/left_pane/date_question"]
    super(attributes)

    rightPaneParams = model: @model, offset: @getOffset(), leftPaneView: this, question: attributes.question
    @rightPaneView = new SurveyBuilderV2.Views.RightPane.DateQuestionView(rightPaneParams)
