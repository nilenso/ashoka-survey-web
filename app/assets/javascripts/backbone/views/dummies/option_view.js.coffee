# Represents a dummy option in the DOM
SurveyBuilder.Views.Dummies ||= {}

class SurveyBuilder.Views.Dummies.OptionView extends Backbone.View
  initialize: (model) ->
    this.model = model
    this.model.on('change:errors', this.render, this)

  render: ->
    template = $('#dummy_option_template').html()
    data = _.extend(this.model.toJSON(), {errors: this.model.errors})
    $(this.el).html(Mustache.render(template, data))
    return this