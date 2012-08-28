class SurveyBuilder.Views.SurveyBuilderView extends Backbone.View

  initalize: ->
    this.el = $("#survey_builder")
    this.dummy_pane = new SurveyBuilder.Views.DummyPaneView