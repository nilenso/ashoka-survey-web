class SurveyBuilderV2.Views.SurveyView extends Backbone.View
  events:
    "click .survey-header": "toggleCollapse"

  initialize: =>
    @editableView = this.$el.find(".survey-header-edit")

  toggleCollapse: =>
    @editableView.toggle('slow')