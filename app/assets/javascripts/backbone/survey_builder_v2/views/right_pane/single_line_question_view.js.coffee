class SurveyBuilderV2.Views.RightPane.SingleLineQuestionView extends Backbone.View
  el: ".survey-panes-right-pane"

  initialize: (attributes) =>
    @model = attributes.model
    @template = SMT["v2_survey_builder/surveys/right_pane/single_line_question"]

  render: =>
    this.$el.html(@template(@model.attributes))

