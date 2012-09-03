# Controls the Rails flash_messages div.
class SurveyBuilder.Views.FlashView extends Backbone.View
  el: "#flash_messages"

  CLEAR_TIMEOUT: 5000 

  set_notice: (message) ->
    $(this.el).html("<p class='notice'>#{message}</p>")
    setTimeout(this.clear, this.CLEAR_TIMEOUT)

  set_error: (message) ->
    $(this.el).html("<p class='error'>#{message}</p>")
    setTimeout(this.clear, this.CLEAR_TIMEOUT)

  clear: =>
    $(this.el).empty()