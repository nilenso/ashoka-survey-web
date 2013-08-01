##= require ./question_factory
# Collection of dummy questions
class SurveyBuilder.Views.DummyPaneView extends Backbone.View
  el: "#dummy_pane"
  DETAILS: "#dummy_survey_details"
  QUESTIONS_CONTAINER: "#dummy_questions"

  events:
    'copy_question.save_all_changes': 'save_all_changes'

  initialize: (survey_model, @survey_frozen) =>
    @questions = []
    @survey_model = survey_model
    @add_survey_details(survey_model)
    @init_sortable()

  init_sortable: =>
    ($(@el).find(@QUESTIONS_CONTAINER)).sortable({
      start: ((event, ui) =>
          ui.item.startPos = ui.item.index()
      ),
      update : ((event, ui) =>
        window.loading_overlay.show_overlay(I18n.t('js.reordering_questions'))
        _.delay(=>
          @reorder_questions(event,ui)
        , 10)
      )
    })

  add_element: (type, model, parent) =>
    view = SurveyBuilder.Views.QuestionFactory.dummy_view_for(type, model, @survey_frozen)
    @questions.push(view)
    model.on('destroy', @delete_question_view, this)
    $(@el).children(@QUESTIONS_CONTAINER).append(view.render().el)
    return view

  insert_view_at_index: (view, index) =>
    if index == -1
      @questions.push(view)
    else
      @questions.splice(index + 1, 0, view)

  add_survey_details: (survey_model) =>
    template = $("#dummy_survey_details_template").html()
    @dummy_survey_details = new SurveyBuilder.Views.Dummies.SurveyDetailsView({ model: survey_model, template: template})
    @show_survey_details()

  render: =>
    ($(@el).find(@DETAILS).append(@dummy_survey_details.render().el))
    ($(@el).find(@QUESTIONS_CONTAINER).append(question.render().el)) for question in @questions
    return this

  unfocus_all: =>
    $(@dummy_survey_details.el).removeClass("active")
    question.unfocus() for question in @questions

  delete_question_view: (model) =>
    question = _(@questions).find((question) => question.model == model )
    question.remove()
    @questions = _(@questions).without(question)
    @set_order_numbers()
    @render()

  reorder_questions: (event, ui) =>
    @set_order_numbers()
    @reorder_questions_views_by_index(ui)
    @render()
    @hide_overlay(event)

  hide_overlay: (event) =>
    window.loading_overlay.hide_overlay() if event

  reorder_questions_views_by_index: (ui) =>
    return unless ui
    start = ui.item.startPos
    end = ui.item.index()
    if start > end
        rotate = @questions.slice(end, start)
        rotated_questions = [@questions[start]].concat(rotate)
        @questions = _.union(@questions.slice(0, end), rotated_questions, @questions.slice(start+1))
    else
        rotate = @questions.slice(start+1, end+1)
        rotated_questions = rotate.concat(@questions[start])
        @questions = _.union(@questions.slice(0, start), rotated_questions, @questions.slice(end+1))

  sort_question_views_by_order_number: =>
    @questions = _(@questions).sortBy (question) =>
      question.model.get('order_number')
    @render()

  set_order_numbers: =>
    last_order_number = @survey_model.next_order_number()
    for question_view in @questions
      question_view.set_order_number(last_order_number)
      question_view.reset_question_number()
      question_view.reset_sub_question_numbers() if question_view.can_have_sub_questions

  show_survey_details: =>
    @dummy_survey_details.show_actual()

  save_all_changes: (event, question_view) =>
    $(this.el).bind "ajaxStop.copy_question", =>
      $(this.el).unbind "ajaxStop.copy_question"
      question_view.copy_question() unless @survey_model.has_errors()
    $(@el).trigger('save_all_questions')

