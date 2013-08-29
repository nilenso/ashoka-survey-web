class SurveyBuilderV2.Views.LeftPane.OptionView extends SurveyBuilderV2.Backbone.View
  initialize: (attributes) =>
    @model.on("sync", @render)

  render: =>
    this.$el.append(@template(@model.attributes))
    return this

