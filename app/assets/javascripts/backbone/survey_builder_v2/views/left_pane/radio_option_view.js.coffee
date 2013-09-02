##= require ./option_view

class SurveyBuilderV2.Views.LeftPane.RadioOptionView extends SurveyBuilderV2.Views.LeftPane.OptionView

  events:
    "click": "makeActive"
    "click .option-delete-button": "destroyOption"

  initialize: (attributes) =>
    @model = attributes.model
    @template = SMT["v2_survey_builder/surveys/left_pane/radio_option"]

    super(attributes)

  render: =>
    super

  loadSubQuestions: =>
    elementContainer = this.$el.find("div.question-input > div.question-sub-questions")

    @model.get('elements').each((questionModel) =>
      SurveyBuilderV2.Views.QuestionCreator.render(questionModel.type, elementContainer, questionModel.attributes))
