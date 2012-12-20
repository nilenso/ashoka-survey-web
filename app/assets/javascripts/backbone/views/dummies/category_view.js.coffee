SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy category on the DOM
class SurveyBuilder.Views.Dummies.CategoryView extends Backbone.View
  initialize: (model) ->
    this.model = model
    this.template = $('#dummy_category_template').html()
    this.model.dummy_view = this
    this.model.on('change', this.render, this)
    this.model.on('change:errors', this.render, this)

  render: ->
    this.model.set('content', I18n.t('js.untitled_category')) if _.isEmpty(this.model.get('content'))
    data = this.model.toJSON().category
    #data = _(data).extend({ question_number: this.model.question_number })
    $(this.el).html('<div class="dummy_category_content">' + Mustache.render(this.template, data) + '</div>')
    $(this.el).addClass("dummy_category")

#   $(this.el).children(".dummy_category_content").click (e) =>
#      @show_actual(e)

    $(this.el).children('.dummy_category_content').children(".delete_category").click (e) => @delete(e)

    return this

  delete: ->
    this.model.destroy()

  show_actual: (event) ->
    $(this.el).trigger("dummy_click")
    #$(this.model.actual_view.el).show()
    $(this.el).children('.dummy_category_content').addClass("active")
    $(this.el).trigger("settings_pane_move")

  unfocus: ->
    $(this.el).children('.dummy_category_content').removeClass("active")
