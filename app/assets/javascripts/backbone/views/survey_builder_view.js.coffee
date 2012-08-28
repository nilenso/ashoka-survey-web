class SurveyBuilder.Views.SurveyBuilderView extends Backbone.View
  el: "#survey_builder"

  events:
    'new_question': 'new_question'

  initialize: ->
    this.picker_pane   = new SurveyBuilder.Views.PickerPaneView
    this.settings_pane = new SurveyBuilder.Views.SettingsPaneView
    this.dummy_pane    = new SurveyBuilder.Views.DummyPaneView

  new_question: (event, type) ->
    #TODO: Switch tab here.
    model = new SurveyBuilder.Models.RadioQuestionModel
    #this.dummy_pane.add_question(type, model)
    this.settings_pane.add_question(type, model)
