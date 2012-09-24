SurveyBuilder.Views.Questions ||= {}

#  The settings of a single option in the settings pane
class SurveyBuilder.Views.Questions.OptionView extends Backbone.View
  events:
    'keyup': 'update_model'

  initialize: (@model, @template) ->
    this.model.on('change:errors', this.render, this)

  render: ->
    data = _.extend(this.model.toJSON(), {errors: this.model.errors})
    $(this.el).html(Mustache.render(@template, data))
    $(this.el).children('.delete_option').bind('click', this.delete)
    return this

  update_model: (event) ->
    input = $(event.target)
    this.model.set({content: input.val()})
    event.stopImmediatePropagation()

  delete: =>
    this.model.destroy()