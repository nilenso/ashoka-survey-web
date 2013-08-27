##= require ./question_view

class SurveyBuilderV2.Views.LeftPane.DropDownQuestionView extends SurveyBuilderV2.Views.LeftPane.QuestionView
  events:
    "click": "makeActive"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.DropDownQuestionModel(attributes.question)
    @template = SMT["v2_survey_builder/surveys/left_pane/drop_down_question"]
    super(attributes)

    rightPaneParams = model: @model, leftPaneView: this, question: attributes.question
    @rightPaneView = new SurveyBuilderV2.Views.RightPane.DropDownQuestionView(rightPaneParams)
