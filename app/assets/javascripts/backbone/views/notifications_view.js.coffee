# Controls the Rails flash_messages div.
class SurveyBuilder.Views.NotificationsView extends Backbone.View
  el: "#notifications"

  CLEAR_TIMEOUT: 5000

  set_notice: (message, options = {}) =>
    @clear_text()
    $(this.el).children('p').html(message)
    $(this.el).children('p').addClass('flash notice')
    unless options['no_timeout']
      setTimeout(this.clear_text, this.CLEAR_TIMEOUT)

  set_error: (message, options = {}) =>
    @clear_text()
    $(this.el).children('p').html(message)
    $(this.el).children('p').addClass('flash error')
    unless options['no_timeout']
      setTimeout(this.clear_text, this.CLEAR_TIMEOUT)

  show_spinner: =>
    opts =
      lines: 9 # The number of lines to draw
      length: 0 # The length of each line
      width: 4 # The line thickness
      radius: 8 # The radius of the inner circle
      speed: 1.6 # Rounds per second
      trail: 41 # Afterglow percentage
      top: "5px" # Top position relative to parent in px
      left: "25px" # Left position relative to parent in px
      zIndex: 99998 # The z-index (defaults to 2000000000)

    $("#spinner").spin(opts)

  hide_spinner: =>
    $(this.el).find("#spinner").spin(false)

  clear_text: =>
    $(this.el).children('p').empty()
    $(this.el).children('p').removeClass()
