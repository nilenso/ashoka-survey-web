# Controls the survey building process
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
    this.survey        = new SurveyBuilder.Models.SurveyModel(survey_id)
    $(this.el).ajaxStop(this.display_save_status)

  new_question: (event, type) ->
    #TODO: Switch tab here.
    switch type
      when 'radio'
        model = this.survey.add_new_question_model()
        this.dummy_pane.add_question(type, model)
        this.settings_pane.add_question(type, model)
        model.save_with_options()

  hide_all: (event) ->
    this.settings_pane.hide_all()

  save_all_questions: ->
    this.survey.save_all_questions()

  display_save_status: =>
    if this.survey.has_errors()
      window.flash_view.set_error('We had trouble saving your survey.')
    else
      window.flash_view.set_notice('Your survey was saved!')
