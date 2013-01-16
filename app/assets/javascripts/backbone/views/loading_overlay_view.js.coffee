# Controls the Rails flash_messages div.
class SurveyBuilder.Views.LoadingOverlayView extends Backbone.View
  el: "#loading_overlay"

  show_overlay: (text) =>
    opts =
      lines: 17 # The number of lines to draw
      length: 9 # The length of each line
      width: 4 # The line thickness
      radius: 36 # The radius of the inner circle
      speed: 1.0 # Rounds per second
      trail: 64 # Afterglow percentage
      top: "5px" # Top position relative to parent in px
      left: "25px" # Left position relative to parent in px
      color: '#ddd'

    $(this.el).css('display', 'block')
    $(this.el).children(".spinner").spin(opts)

    if text
      @old_text = $(this.el).children("p.text").text()
      $(this.el).children("p.text").text(text)

  hide_overlay: =>
    $(this.el).hide()
    $(this.el).children("p.text").text(@old_text) if @old_text