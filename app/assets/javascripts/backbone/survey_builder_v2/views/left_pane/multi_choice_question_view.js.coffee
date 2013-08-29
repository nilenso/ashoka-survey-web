##= require ./question_with_options_view

class SurveyBuilderV2.Views.LeftPane.MultiChoiceQuestionView extends SurveyBuilderV2.Views.LeftPane.QuestionWithOptionsView
  events:
    "click": "makeActive"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.MultiChoiceQuestionModel(attributes.question)
    super(attributes)

    rightPaneParams = model: @model, leftPaneView: this, question: attributes.question
    @rightPaneView = new SurveyBuilderV2.Views.RightPane.MultiChoiceQuestionView(rightPaneParams)

  loadOptions: =>
    optionsParent = this.$el.find('.question-options')

    @model.get('options').each((optionModel) =>
      new SurveyBuilderV2.Views.LeftPane.MultiChoiceOptionView(el: optionsParent, model: optionModel).render())
