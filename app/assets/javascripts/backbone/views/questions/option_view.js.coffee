SurveyBuilder.Views.Questions ||= {}

#  The settings of a single option in the settings pane
class SurveyBuilder.Views.Questions.OptionView extends Backbone.View
  events:
    'keyup': 'update_model'

  initialize: (model) ->
    this.model = model
    this.model.on('change:errors', this.render, this)

  render: ->
    template = $('#option_template').html()
    data = _.extend(this.model.toJSON(), {errors: this.model.errors})
    $(this.el).html(Mustache.render(template, data))
    return this

  update_model: (event) ->
    input = $(event.target)
    this.model.set({content: input.val()})
    event.stopImmediatePropagation()