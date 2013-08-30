##= require ./option_view

class SurveyBuilderV2.Views.LeftPane.MultiChoiceOptionView extends SurveyBuilderV2.Views.LeftPane.OptionView
  initialize: (attributes) =>
    @model = attributes.model
    @template = SMT["v2_survey_builder/surveys/left_pane/multi_choice_option"]

    super(attributes)
