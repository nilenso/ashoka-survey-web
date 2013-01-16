SurveyBuilder.Views.Dummies ||= {}

class SurveyBuilder.Views.Dummies.SurveyDetailsView extends Backbone.View
  events:
    "click": 'show_actual'

  initialize: =>
    @template = this.options.template
    @model.on('change', this.render, this)
    this.model.on('change:errors', this.render, this)
    
  render: =>
    data = _.extend(this.model.toJSON(), {errors: this.model.errors})
    $(this.el).html(Mustache.render(@template, data))
    return this

  show_actual: (event) =>
    $(this.el).trigger("dummy_click")
    $(this.model.actual_view.el).show()
    $(this.el).addClass("active")
