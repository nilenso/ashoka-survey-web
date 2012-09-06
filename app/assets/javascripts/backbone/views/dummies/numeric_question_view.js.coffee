SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy single line question on the DOM
class SurveyBuilder.Views.Dummies.NumericQuestionView extends Backbone.View

  events:
    "click": 'show_actual'

  initialize: (model) ->
    this.model = model
    this.model.dummy_view = this
    this.options = []
    this.model.on('change', this.render, this)
    this.model.on('change:errors', this.render, this)

  render: ->
    template = $('#dummy_numeric_question_template').html()
    data = _.extend(this.model.toJSON(), {errors: this.model.errors})
    $(this.el).html(Mustache.render(template, data))
    $(this.el).find('abbr').show() if this.model.get('mandatory')
    _.each(this.options, (option) =>
        $(this.el).append(option.render().el)
      )
    return this

  show_actual: (event) ->
    $(this.el).trigger("dummy_click")
    $(this.model.actual_view.el).show()
    $(this.el).addClass("active")