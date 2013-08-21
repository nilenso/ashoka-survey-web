##= require ./question_view

class SurveyBuilderV2.Views.LeftPane.NumericQuestionView extends SurveyBuilderV2.Views.LeftPane.QuestionView
  events:
    "click": "makeActive"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.NumericQuestionModel(attributes.question)
    @template = SMT["v2_survey_builder/surveys/left_pane/numeric_question"]
    super(attributes)
    @createRightView()

  createRightView: =>
    @rightPaneView = new SurveyBuilderV2.Views.RightPane.NumericQuestionView(model: @model, offset: @getOffset(), leftPaneView: this)

