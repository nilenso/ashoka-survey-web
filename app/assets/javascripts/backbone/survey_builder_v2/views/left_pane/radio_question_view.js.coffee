##= require ./question_with_options_view

class SurveyBuilderV2.Views.LeftPane.RadioQuestionView extends SurveyBuilderV2.Views.LeftPane.QuestionWithOptionsView
  events:
    "click": "makeActive"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.RadioQuestionModel(attributes.question)
    super(attributes)

    rightPaneParams = model: @model, leftPaneView: this, question: attributes.question
    @rightPaneView = new SurveyBuilderV2.Views.RightPane.RadioQuestionView(rightPaneParams)

  loadOptions: =>
    optionsParent = this.$el.find('.question-options')

    @model.get('options').each((optionModel) =>
      new SurveyBuilderV2.Views.LeftPane.RadioOptionView(el: optionsParent, model: optionModel).render())
