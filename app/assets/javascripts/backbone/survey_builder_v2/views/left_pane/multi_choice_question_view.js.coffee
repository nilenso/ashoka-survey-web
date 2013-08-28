##= require ./question_view

class SurveyBuilderV2.Views.LeftPane.MultiChoiceQuestionView extends SurveyBuilderV2.Views.LeftPane.QuestionView
  events:
    "click": "makeActive"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.MultiChoiceQuestionModel(attributes.question)
    @template = SMT["v2_survey_builder/surveys/left_pane/multi_choice_question"]
    @loadOptions()
    super(attributes)

    rightPaneParams = model: @model, leftPaneView: this, question: attributes.question
    @rightPaneView = new SurveyBuilderV2.Views.RightPane.MultiChoiceQuestionView(rightPaneParams)

  loadOptions: =>
    options = @model.get('options')

    for option in options
      optionModel = @model.createNewOption(option)
      new SurveyBuilderV2.Views.LeftPane.MultiChoiceOptionView(model: optionModel)
