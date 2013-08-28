class SurveyBuilderV2.Views.LeftPane.OptionView extends SurveyBuilderV2.Backbone.View
  el: ".question-options"

  render: () =>
    this.$el.append(@template(@model.attributes))
    return this

