class SurveyBuilderV2.Views.ActionBarView extends SurveyBuilderV2.Backbone.View
  el: "#survey_builder_v2"

  initialize: =>
    header = @getActionBar().offset().top
    $(window).scroll =>
      if $(window).scrollTop() > header
        @getActionBar().addClass "sticky"
        @getSurveyPanes().addClass "sticky"
      else
        @getActionBar().removeClass "sticky"
        @getSurveyPanes().removeClass "sticky"

  getActionBar: => this.$el.find("#survey-action-bar")
  getSurveyPanes: => this.$el.find(".survey-panes")