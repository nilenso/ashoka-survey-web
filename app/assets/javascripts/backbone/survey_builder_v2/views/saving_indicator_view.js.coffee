class SurveyBuilderV2.Views.SavingIndicatorView extends Backbone.View
  el: "#saving-indicator"

  getSpinner: => this.$el.find(".saving-indicator-spinner")
  getLabel: => this.$el.find(".saving-indicator-label")
  getTimeAgoLabel: => this.$el.find(".saving-indicator-time-ago-label")

  initialize: =>
    @timeAgoIndicator = new SurveyBuilderV2.Views.TimeAgoIndicatorView

  show: =>
    @getSpinner().show()
    @getLabel().show()
    @getTimeAgoLabel().hide()
    @timeAgoIndicator.reset()

  hide: =>
    @getSpinner().hide()
    @getLabel().hide()
    @timeAgoIndicator.start()


