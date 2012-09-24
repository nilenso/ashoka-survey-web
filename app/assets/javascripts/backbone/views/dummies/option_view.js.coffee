# Represents a dummy option in the DOM
SurveyBuilder.Views.Dummies ||= {}

class SurveyBuilder.Views.Dummies.OptionView extends Backbone.View

  initialize: (@model, @template) ->
    this.model.on('change:errors', this.render, this)

  render: ->
    data = _.extend(this.model.toJSON(), {errors: this.model.errors})
    $(this.el).html(Mustache.render(@template, data))
    $(this.el).children('.delete_option').bind('click', this.delete)
    return this

  delete: =>
    this.model.destroy()
