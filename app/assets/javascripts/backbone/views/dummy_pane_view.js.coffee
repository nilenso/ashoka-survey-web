##= require ./question_factory
# Collection of dummy questions
class SurveyBuilder.Views.DummyPaneView extends Backbone.View
  el: "#dummy_pane"
  DETAILS: "#dummy_survey_details"
  QUESTIONS_CONTAINER: "#dummy_questions"

  initialize: (survey_model) =>
    @questions = []
    @survey_model = survey_model
    @add_survey_details(survey_model)
    @init_sortable()

  init_sortable: =>
    ($(@el).find(@QUESTIONS_CONTAINER)).sortable({
      update : ((event, ui) =>
        window.loading_overlay.show_overlay(I18n.t('js.reordering_questions'))
        _.delay(=>
          @reorder_questions(event,ui)
        , 10)
      )
    })

  add_question: (type, model, parent) =>
    view = SurveyBuilder.Views.QuestionFactory.dummy_view_for(type, model)
    @questions.push(view)
    model.on('destroy', @delete_question_view, this)
    $(@el).children(@QUESTIONS_CONTAINER).append(view.render().el)

  add_category: (model) =>
    view = new SurveyBuilder.Views.Dummies.CategoryView(model)
    @questions.push(view)
    model.on('destroy', @delete_question_view, this)
    $(@el).children(@QUESTIONS_CONTAINER).append(view.render().el)

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
    @sort_question_views_by_order_number()
    @render()
    @hide_overlay(event)

  hide_overlay: (event) =>
      window.loading_overlay.hide_overlay() if event

  sort_question_views_by_order_number: =>
    @questions = _(@questions).sortBy (question) =>
      question.model.get('order_number')

  set_order_numbers: =>
    last_order_number = @survey_model.next_order_number()
    for question_view in @questions
      question_view.set_order_number(last_order_number)
      question_view.reset_question_number() if question_view.can_have_sub_questions

  show_survey_details: =>
    @dummy_survey_details.show_actual()

