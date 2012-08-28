SurveyBuilder.Views.Dummies ||= {}

class SurveyBuilder.Views.Dummies.RadioQuestionView extends Backbone.View

  initialize: (model) ->
    this.model = model
    this.model.on('change', this.render, this)

  render: ->
    template = $('#dummy_radio_question_template').html()
    $(this.el).html(Mustache.render(template, this.model.toJSON()))
    return this