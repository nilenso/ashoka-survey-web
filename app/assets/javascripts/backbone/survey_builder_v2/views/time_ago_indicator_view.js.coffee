class SurveyBuilderV2.Views.TimeAgoIndicatorView extends Backbone.View
  el: ".saving-indicator-time-ago"

  getTimeAgoLabel: => this.$el

  reset: =>
    @getTimeAgoLabel().hide()
    clearTimeout(@interval) if @interval

  start: =>
    @getTimeAgoLabel().show()
    @getTimeAgoLabel().text(I18n.t("v2_survey_builder.surveys.build.saving_indicator_progress_complete_label"))
    @now = moment()
    @interval = setInterval(@updateTimeAgo, 5000)

  updateTimeAgo: =>
    @getTimeAgoLabel().text(I18n.t("v2_survey_builder.surveys.build.saving_indicator_time_ago_label", { time: @now.fromNow() }))