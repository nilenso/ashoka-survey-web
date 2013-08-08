class SurveyBuilderV2.Views.ActionBarView extends SurveyBuilderV2.Backbone.View
  el: "#survey-action-bar"

  initialize: =>
    header = this.$el.offset().top
    $(window).scroll =>
      if $(window).scrollTop() > header
        this.$el.addClass "sticky"
      else
        this.$el.removeClass "sticky"