##= require ./option_view

class SurveyBuilderV2.Views.LeftPane.DropDownOptionView extends SurveyBuilderV2.Views.LeftPane.OptionView
  initialize: (attributes) =>
    @model = attributes.model
    @template = SMT["v2_survey_builder/surveys/left_pane/drop_down_option"]

    super(attributes)
