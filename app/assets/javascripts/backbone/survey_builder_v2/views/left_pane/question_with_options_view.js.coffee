##= require ./question_view

class SurveyBuilderV2.Views.LeftPane.QuestionWithOptionsView extends SurveyBuilderV2.Views.LeftPane.QuestionView

  events:
    "click .question-delete-button": "destroyAll"


  initialize: (attributes) =>
    @template = SMT["v2_survey_builder/surveys/left_pane/question_details_with_options"]
    super(attributes)

  render: =>
    super
    @loadOptions()
