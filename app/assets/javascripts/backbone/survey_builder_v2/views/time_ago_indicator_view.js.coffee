class SurveyBuilderV2.Views.TimeAgoIndicatorView extends Backbone.View
  el: ".saving-indicator-time-ago-label"

  getTimeAgoLabel: => this.$el

  reset: =>
    @getTimeAgoLabel().hide()
    clearTimeout(@interval) if @interval

  start: =>
    @getTimeAgoLabel().show()
    @getTimeAgoLabel().text("Saved!")
    @now = moment()
    @interval = setInterval(@updateTimeAgo, 5000)

  updateTimeAgo: =>
    @getTimeAgoLabel().text("Last saved #{@now.fromNow()}")