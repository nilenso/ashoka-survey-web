SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy question on the DOM
class SurveyBuilder.Views.Dummies.QuestionView extends Backbone.View

  events:
    "click": 'show_actual'

  initialize: (model, template) ->
    this.model = model
    this.template = template
    this.model.dummy_view = this
    this.model.on('change', this.render, this)
    this.model.on('change:errors', this.render, this)

  render: ->
    data = _.extend(this.model.toJSON(), {errors: this.model.errors})
    $(this.el).html(Mustache.render(this.template, data))
    $(this.el).find('abbr').show() if this.model.get('mandatory')
    return this

  show_actual: (event) ->
    $(this.el).trigger("dummy_click")
    $(this.model.actual_view.el).show()
    $(this.el).addClass("active")