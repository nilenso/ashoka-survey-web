SurveyBuilder.Views.Dummies ||= {}

class SurveyBuilder.Views.Dummies.OptionView extends Backbone.View
  initialize: (model) ->
    this.model = model

  render: ->
    template = $('#dummy_option_template').html()
    $(this.el).html(Mustache.render(template, this.model.toJSON()))
    return this