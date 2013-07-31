class SurveyBuilderV2.Views.SurveyView extends Backbone.View
  events:
    "click .survey-header": "toggleCollapse"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.SurveyModel(attributes.survey)
    @model.on("change", @render)
    @template = SMT["v2_survey_builder/surveys/header"]

  # Using a method because we want do the `find` every time.
  getEditableView: => this.$el.find(".survey-header-edit")

  toggleCollapse: =>
    @getEditableView().toggle('slow')

  render: =>
    this.$el.html(@template(@model.attributes))
    return this