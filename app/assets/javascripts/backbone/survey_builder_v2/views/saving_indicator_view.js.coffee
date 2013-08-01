class SurveyBuilderV2.Views.SavingIndicatorView extends Backbone.View
  el: "#saving-indicator"

  getProgress: => this.$el.find(".saving-indicator-progress")
  getTimeAgo: => this.$el.find(".saving-indicator-time-ago")
  getError: => this.$el.find(".saving-indicator-failure")

  initialize: =>
    @timeAgoIndicator = new SurveyBuilderV2.Views.TimeAgoIndicatorView

  show: =>
    @reset()
    @getProgress().show()

  hide: =>
    @reset()
    console.log @getTimeAgo()
    @getTimeAgo().show()
    @timeAgoIndicator.start()

  error: =>
    @reset()
    @getError().show()


  reset: =>
    @getProgress().hide()
    @getTimeAgo().hide()
    @getError().hide()
    @timeAgoIndicator.reset()
