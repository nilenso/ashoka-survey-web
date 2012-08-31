class SurveyBuilder.Views.SurveyBuilderView extends Backbone.View
  el: "#survey_builder"

  events:
    'new_question': 'new_question'
    'dummy_click': 'hide_all'
    'click #save': 'save_all_questions'

  initialize:(survey_id) ->
    this.picker_pane   = new SurveyBuilder.Views.PickerPaneView
    this.settings_pane = new SurveyBuilder.Views.SettingsPaneView
    this.dummy_pane    = new SurveyBuilder.Views.DummyPaneView
    this.survey_id = survey_id
    @models = []

  new_question: (event, type) ->
    #TODO: Switch tab here.
    switch type
      when 'radio'
        model = new SurveyBuilder.Models.RadioQuestionModel
        model.attributes['survey_id'] = this.survey_id
        @models.push model
        this.dummy_pane.add_question(type, model)
        this.settings_pane.add_question(type, model)
        model.seed()
        model.save_with_options()

  hide_all: (event) ->
    this.settings_pane.hide_all()

  save_all_questions: ->
    for model in @models when model.attributes['type'] == "RadioQuestion"
      model.save_with_options()
