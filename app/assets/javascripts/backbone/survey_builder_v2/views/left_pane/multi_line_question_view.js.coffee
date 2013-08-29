##= require ./question_view

class SurveyBuilderV2.Views.LeftPane.MultiLineQuestionView extends SurveyBuilderV2.Views.LeftPane.QuestionView
  events:
    "click": "makeActive"
    "click .question-delete-button": "destroyAll"


  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.MultiLineQuestionModel(attributes.question)
    @template = SMT["v2_survey_builder/surveys/left_pane/multi_line_question"]
    super(attributes)

    rightPaneParams = model: @model, leftPaneView: this, question: attributes.question
    @rightPaneView = new SurveyBuilderV2.Views.RightPane.MultiLineQuestionView(rightPaneParams)
