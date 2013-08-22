##= require ./question_view

class SurveyBuilderV2.Views.LeftPane.RatingQuestionView extends SurveyBuilderV2.Views.LeftPane.QuestionView
  events:
    "click": "makeActive"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.RatingQuestionModel(attributes.question)
    @template = SMT["v2_survey_builder/surveys/left_pane/rating_question"]
    super(attributes)

    @rightPaneView = new SurveyBuilderV2.Views.RightPane.RatingQuestionView(model: @model, offset: @getOffset(), leftPaneView: this)
