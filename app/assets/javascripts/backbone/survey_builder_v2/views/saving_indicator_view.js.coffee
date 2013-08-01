class SurveyBuilderV2.Views.SavingIndicatorView extends Backbone.View
  el: "#saving-indicator"

  getSpinner: => this.$el.find(".saving-indicator-spinner")
  getLabel: => this.$el.find(".saving-indicator-label")

  show: =>
    @getSpinner().show()
    @getLabel().show()

  hide: =>
    @getSpinner().hide()
    @getLabel().hide()
