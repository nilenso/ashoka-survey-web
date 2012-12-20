# Controls the Rails flash_messages div.
class SurveyBuilder.Views.NotificationsView extends Backbone.View
  el: "#notifications"

  CLEAR_TIMEOUT: 5000 

  set_notice: (message) ->
    @clear_text()
    $(this.el).children('p').html(message)
    $(this.el).children('p').addClass('notice')
    setTimeout(this.clear_text, this.CLEAR_TIMEOUT)

  set_error: (message) ->
    @clear_text()
    $(this.el).children('p').html(message)
    $(this.el).children('p').addClass('error')
    setTimeout(this.clear_text, this.CLEAR_TIMEOUT)

  clear_text: =>
    $(this.el).children('p').empty()
    $(this.el).children('p').removeClass()