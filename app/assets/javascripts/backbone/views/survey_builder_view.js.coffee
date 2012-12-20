# Controls the survey building process
class SurveyBuilder.Views.SurveyBuilderView extends Backbone.View
  el: "#survey_builder"

  events:
    'new_question': 'new_question'
    'new_category': 'new_category'
    'dummy_click': 'handle_dummy_click'
    'settings_pane_move': 'settings_pane_move'
    'click #save': 'save_all_questions'

  initialize:(survey_id) ->
    this.picker_pane   = new SurveyBuilder.Views.PickerPaneView
    this.survey        = new SurveyBuilder.Models.SurveyModel(survey_id)
    this.settings_pane = new SurveyBuilder.Views.SettingsPaneView(this.survey)
    this.dummy_pane    = new SurveyBuilder.Views.DummyPaneView(this.survey)
    $(this.el).ajaxStart(window.notifications_view.show_spinner)
    $(this.el).ajaxStop(window.notifications_view.hide_spinner)

    # $( "#sidebar" ).tabs()

    this.survey.fetch({
        success: (data) =>
          this.dummy_pane.render()
          $.getJSON("/api/questions?survey_id=#{survey_id}", this.preload_questions)
      })

  new_question: (event, data) ->
    type = data.type
    parent = data.parent
    model = this.survey.add_new_question_model(type, parent)
    this.dummy_pane.add_question(type, model, parent)
    this.settings_pane.add_question(type, model)
    model.save_model()

  new_category: ->
    model = this.survey.add_new_category_model()
    this.dummy_pane.add_category(model)
    #this.settings_pane.add_category(model)
    model.save_model()

  preload_questions: (data) =>
    $(this.el).bind('ajaxStop.preload', ->
      window.loading_overlay.hide_overlay()
      $(this.el).unbind('ajaxStop.preload')
    )
    _(data).each (question) =>
      model = this.survey.add_new_question_model(question.type)
      model.set('id', question.id)
      this.dummy_pane.add_question(question.type, model)
      this.settings_pane.add_question(question.type, model)
      model.fetch()

  handle_dummy_click: ->
    this.hide_all()
    # this.switch_tab()
  settings_pane_move: ->
    this.settings_pane.move()

  hide_all: (event) ->
    this.dummy_pane.unfocus_all()
    this.settings_pane.hide_all()

  switch_tab: ->
    $("#sidebar").tabs('select', 1)

  save_all_questions: ->
    $(this.el).bind('ajaxStart.save', window.loading_overlay.show_overlay)
    $(this.el).bind('ajaxStop.save', this.handle_save_finished)
    $(this.el).find("#save input").prop('disabled', true)
    this.survey.save()
    this.survey.save_all_questions()

  handle_save_finished: =>
    $(this.el).unbind('ajaxStart.save')
    $(this.el).unbind('ajaxStop.save')
    $(this.el).find("#save input").prop('disabled', false)
    $(this.el).trigger('save_finished')
    @display_save_status()
    window.loading_overlay.hide_overlay()

  display_save_status: ->
    if this.survey.has_errors()
      window.notifications_view.set_error(I18n.t('js.save_unsuccessful'),)
    else
      window.notifications_view.set_notice(I18n.t('js.save_successful'),)
