# Controls the survey building process
class SurveyBuilder.Views.SurveyBuilderView extends Backbone.View
  el: "#survey_builder"

  events:
    'new_question': 'new_question'
    'dummy_click': 'handle_dummy_click'
    'click #save': 'save_all_questions'

  initialize:(survey_id) ->
    this.picker_pane   = new SurveyBuilder.Views.PickerPaneView
    this.settings_pane = new SurveyBuilder.Views.SettingsPaneView
    this.dummy_pane    = new SurveyBuilder.Views.DummyPaneView
    this.survey        = new SurveyBuilder.Models.SurveyModel(survey_id)
    $(this.el).ajaxStart(window.notifications_view.show_spinner)
    $(this.el).ajaxStop(this.display_save_status)
    $( "#sidebar" ).tabs();

  new_question: (event, type) ->
    #TODO: Switch tab here.
    model = this.survey.add_new_question_model(type)
    this.dummy_pane.add_question(type, model)
    this.settings_pane.add_question(type, model)
    switch type
      when 'radio'
        model.save_with_options()
      when 'single_line'
        model.save_model()

  handle_dummy_click: ->
    this.hide_all()
    this.switch_tab()

  hide_all: (event) ->
    this.dummy_pane.unfocus_all()
    this.settings_pane.hide_all()

  switch_tab: ->
    $("#sidebar").tabs('select', 1)

  save_all_questions: ->
    this.survey.save_all_questions()

  display_save_status: =>
    window.notifications_view.hide_spinner()
    if this.survey.has_errors()
      window.notifications_view.set_error('We had trouble saving your survey.')
    else
      window.notifications_view.set_notice('Your survey was saved!')