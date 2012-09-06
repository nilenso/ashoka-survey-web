# Controls the Rails flash_messages div.
class SurveyBuilder.Views.NotificationsView extends Backbone.View
  el: "#notifications"

  CLEAR_TIMEOUT: 5000 

  set_notice: (message) ->
    $(this.el).html("<p class='notice'>#{message}</p>")
    setTimeout(this.clear, this.CLEAR_TIMEOUT)

  set_error: (message) ->
    $(this.el).html("<p class='error'>#{message}</p>")
    setTimeout(this.clear, this.CLEAR_TIMEOUT)

  clear: =>
    $(this.el).empty()