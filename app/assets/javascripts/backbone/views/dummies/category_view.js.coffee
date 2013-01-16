SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy category on the DOM
class SurveyBuilder.Views.Dummies.CategoryView extends Backbone.View
  initialize: (model) =>
    this.model = model
    this.sub_questions = []
    this.template = $('#dummy_category_template').html()
    this.model.dummy_view = this
    this.model.on('change', this.render, this)
    this.model.on('change:errors', this.render, this)
    this.model.on('change:preload_sub_questions', this.preload_sub_questions)
    this.model.on('add:sub_question', this.add_sub_question)

  render: =>
    this.model.set('content', I18n.t('js.untitled_category')) if _.isEmpty(this.model.get('content'))
    data = this.model.toJSON().category
    data = _(data).extend({ question_number: this.model.question_number })
    $(this.el).html('<div class="dummy_category_content">' + Mustache.render(this.template, data) + '</div>')
    $(this.el).addClass("dummy_category")

    $(this.el).children(".dummy_category_content").click (e) =>
      @show_actual(e)

    $(this.el).children('.dummy_category_content').children(".delete_category").click (e) => @delete(e)
    $(this.el).children(".dummy_category_content").children('.collapse_category').click (e) => @toggle_collapse()

    group = $("<div class='sub_question_group'>")
    _(this.sub_questions).each (sub_question) =>
      group.sortable({items: "> div", update: @reorder_questions})
      group.append(sub_question.render().el)
    
    $(this.el).append(group) unless _(this.sub_questions).isEmpty()
    @collapse(false) if @collapsed

    return this

  delete: =>
    this.model.destroy()

  add_sub_question: (sub_question_model) =>
    sub_question_model.on('set:errors', =>
      this.uncollapse()
      this.model.trigger('set:errors')
    , this)
    sub_question_model.on('destroy', this.delete_sub_question, this)
    type = sub_question_model.get('type')
    question = SurveyBuilder.Views.QuestionFactory.dummy_view_for(type, sub_question_model)
    this.sub_questions.push question
    @uncollapse()
    this.render()

  preload_sub_questions: (sub_question_models) =>
    _.each(sub_question_models, (sub_question_model) =>
      this.add_sub_question(sub_question_model)
    )

  delete_sub_question: (sub_question_model) =>
    view = sub_question_model.dummy_view
    @sub_questions = _(@sub_questions).without(view)
    view.remove()
    this.trigger('destroy:sub_question')

  show_actual: (event) =>
    $(this.el).trigger("dummy_click")
    $(this.model.actual_view.el).show()
    $(this.el).children('.dummy_category_content').addClass("active")

  collapse: (animate=true) =>
    @collapsed = true
    $(this.el).children('div.sub_question_group').hide(animate ? 'slow' : '')
    $(this.el).children('.dummy_category_content').children('.collapse_category').html('&#9658;')

  uncollapse: =>
    @collapsed = false
    $(this.el).children('div.sub_question_group').show('slow')
    $(this.el).children('.dummy_category_content').children('.collapse_category').html('&#9660;')

  toggle_collapse: =>
    if @collapsed
      @uncollapse()
    else
      @collapse()

  unfocus: =>
    $(this.el).children('.dummy_category_content').removeClass("active")
    _(this.sub_questions).each (sub_question) =>
      sub_question.unfocus()

  reorder_questions: (event, ui) =>
    last_order_number = _.chain(this.sub_questions)
      .map((sub_question) => sub_question.model.get('order_number'))
      .max().value()
    _(@sub_questions).each (sub_question) =>
      index = $(sub_question.el).index()
      sub_question.model.set({order_number: last_order_number + index + 1})
      sub_question.model.question_number = this.model.question_number + '.' + (index + 1)
      sub_question.reorder_questions() if sub_question instanceof SurveyBuilder.Views.Dummies.QuestionWithOptionsView
      sub_question.reorder_questions() if sub_question instanceof SurveyBuilder.Views.Dummies.CategoryView
    this.sub_questions = _(this.sub_questions).sortBy (sub_question) =>
      sub_question.model.get('order_number')
    @render()
