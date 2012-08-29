SurveyBuilder.Views.Dummies ||= {}

class SurveyBuilder.Views.Dummies.OptionView extends Backbone.View
  initialize: (question_id) ->
    this.model = new SurveyBuilder.Models.OptionModel
    this.model.on('change', this.render, this)

  render: ->
    template = $('#dummy_option_template').html()
    $(this.el).html(Mustache.render(template, this.model.toJSON()))
    return this