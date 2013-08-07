class SurveyBuilderV2.Views.LeftPane.SingleLineQuestionView extends Backbone.View
  events: =>
    "click": "handleClick"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.SingleLineQuestionModel(attributes.question)
    @model.on("change", @render)
    @template = SMT["v2_survey_builder/surveys/left_pane/single_line_question"]

  render: =>
    this.$el.html(@template(@model.attributes))
    return this

  handleClick: =>
    # Bubble up event

