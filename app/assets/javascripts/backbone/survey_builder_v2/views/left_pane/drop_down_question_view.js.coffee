##= require ./question_with_options_view

class SurveyBuilderV2.Views.LeftPane.DropDownQuestionView extends SurveyBuilderV2.Views.LeftPane.QuestionWithOptionsView
  events:
    "click": "makeActive"
    "click .question-delete-button": "destroyQuestion"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.DropDownQuestionModel(attributes.question)
    super(attributes)

    @template = SMT["v2_survey_builder/surveys/left_pane/drop_down_question"]

    rightPaneParams = model: @model, leftPaneView: this, question: attributes.question
    @rightPaneView = new SurveyBuilderV2.Views.RightPane.DropDownQuestionView(rightPaneParams)

  loadOptions: =>
    optionsParent = this.$el.find('.question-options')

    @model.get('options').each((optionModel) =>
      optionView = new SurveyBuilderV2.Views.LeftPane.DropDownOptionView(model: optionModel)
      optionsParent.append(optionView.render().el))
