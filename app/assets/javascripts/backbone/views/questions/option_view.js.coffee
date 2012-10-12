SurveyBuilder.Views.Questions ||= {}

#  The settings of a single option in the settings pane
class SurveyBuilder.Views.Questions.OptionView extends Backbone.View
  events:
    'keyup': 'update_model'
    'click .add_sub_question' : 'add_sub_question_model'

  initialize: (@model, @template) ->
    this.model.on('change:errors', this.render, this)
    this.model.on('add:sub_question', this.add_sub_question)

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

  add_sub_question_model: ->
    this.model.add_sub_question('SingleLineQuestion')

  add_sub_question: (sub_question_model) =>
    $(this.el).trigger('add_actual_sub_question', sub_question_model)