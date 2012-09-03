# Controls the Rails flash_messages div.
class SurveyBuilder.Views.FlashView extends Backbone.View
  el: "#flash_messages"

  update_notice: (message) ->
    $(this.el).html("<p class='notice'>#{message}</p>")

  update_error: (message) ->
    $(this.el).html("<p class='error'>#{message}</p>")