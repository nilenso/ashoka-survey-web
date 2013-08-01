class SurveyBuilderV2.Views.ActionBarView extends Backbone.View
  el: "#survey-action-bar"

  initialize: =>
    console.log "foo"
    header = this.$el.offset().top
    $(window).scroll =>
      if $(window).scrollTop() > header
        this.$el.addClass "sticky"
      else
        this.$el.removeClass "sticky"