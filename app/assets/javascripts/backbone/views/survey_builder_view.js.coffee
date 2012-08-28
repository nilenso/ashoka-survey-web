class SurveyBuilder.Views.SurveyBuilderView extends Backbone.View

  initalize: ->
    this.el = $("#survey_builder")
    this.picker_pane   = new SurveyBuilder.Views.PickerPaneView
    this.settings_pane = new SurveyBuilder.Views.SettingsPaneView
    this.dummy_pane    = new SurveyBuilder.Views.DummyPaneView