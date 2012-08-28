SurveyBuilder.Views.Questions ||= {}

class SurveyBuilder.Views.Questions.RadioQuestionView extends Backbone.View

  events:
    'keyup': 'update_model'

  initialize: (model) ->
    this.model = model

  render: ->
    template = $('#radio_question_template').html()
    $(this.el).html(Mustache.render(template, this.model.toJSON()))
    return this

  update_model: ->
    input = $(this.el).find('input')
    this.model.set({content: input.val()})