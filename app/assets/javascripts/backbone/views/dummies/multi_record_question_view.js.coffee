##= require ./question_view
SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy category on the DOM
class SurveyBuilder.Views.Dummies.MultiRecordQuestionView extends SurveyBuilder.Views.Dummies.QuestionView
  ORDER_NUMBER_STEP: 2

  initialize: (model, @template) =>
    super
    @sub_questions = []
    @template = $('#dummy_multi_record_question_template').html()
    @can_have_sub_questions = true
    @model.on('change', @render, this)
    @model.on('change:errors', @render, this)
    @model.on('change:preload_sub_questions', @preload_sub_questions)
    @model.on('add:sub_question', @add_sub_question)
    @on('destroy:sub_question', @reorder_questions, this)

  render: =>
    super

    group = $("<div class='sub_question_group'>")
    _(@sub_questions).each (sub_question) =>
      group.sortable({
        items: "> div",
        update: ((event, ui) =>
          window.loading_overlay.show_overlay("Reordering Questions")
          _.delay(=>
            @reorder_questions(event,ui)
          , 10)
        )
      })
      group.append(sub_question.render().el)

    $(@el).append(group) unless _(@sub_questions).isEmpty()
    @collapse(false) if @collapsed

    return this

  add_sub_question: (sub_question_model) =>
    sub_question_model.on('set:errors', =>
      @uncollapse()
      @model.trigger('set:errors')
    , this)
    sub_question_model.on('destroy', @delete_sub_question, this)
    type = sub_question_model.get('type')
    question = SurveyBuilder.Views.QuestionFactory.dummy_view_for(type, sub_question_model)
    @sub_questions.push question
    @uncollapse()
    @render()

  preload_sub_questions: (sub_question_models) =>
    _.each(sub_question_models, (sub_question_model) =>
      @add_sub_question(sub_question_model)
    )

  delete_sub_question: (sub_question_model) =>
    view = sub_question_model.dummy_view
    @sub_questions = _(@sub_questions).without(view)
    view.remove()
    @trigger('destroy:sub_question')

  show_actual: (event) =>
    $(@el).trigger("dummy_click")
    $(@model.actual_view.el).show()
    $(@el).children('.dummy_category_content').addClass("active")

  collapse: (animate=true) =>
    @collapsed = true
    $(@el).children('div.sub_question_group').hide(animate ? 'slow' : '')
    $(@el).children('.dummy_category_content').children('.collapse_category').html('&#9658;')

  uncollapse: =>
    @collapsed = false
    $(@el).children('div.sub_question_group').show('slow')
    $(@el).children('.dummy_category_content').children('.collapse_category').html('&#9660;')

  toggle_collapse: =>
    if @collapsed
      @uncollapse()
    else
      @collapse()

  unfocus: =>
    $(@el).children('.dummy_category_content').removeClass("active")
    _(@sub_questions).each (sub_question) =>
      sub_question.unfocus()

  reorder_questions: (event, ui) =>
    last_order_number = @last_sub_question_order_number()

    _(@sub_questions).each (sub_question) =>
      index = $(sub_question.el).index()
      sub_question.model.set({order_number: last_order_number + (index * @ORDER_NUMBER_STEP)}, {silent: true})
      @model.sub_question_order_counter = last_order_number + (index * @ORDER_NUMBER_STEP)

    @sub_questions = _(@sub_questions).sortBy (sub_question) =>
      sub_question.model.get('order_number')

    @reset_sub_question_numbers()
    @hide_overlay(event)

  hide_overlay: (event) =>
    window.loading_overlay.hide_overlay() if event

  last_sub_question_order_number: =>
    _.chain(@sub_questions)
      .map((sub_question) => sub_question.model.get('order_number'))
      .max().value()

  reset_sub_question_numbers: =>
    _(@sub_questions).each (sub_question) =>
      index = $(sub_question.el).index()
      sub_question.model.question_number = @model.question_number + '.' + (index + 1)

      sub_question.reset_sub_question_numbers() if sub_question.can_have_sub_questions
    @render()
