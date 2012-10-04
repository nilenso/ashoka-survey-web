SurveyBuilder.Views.Dummies ||= {}

class SurveyBuilder.Views.Dummies.SurveyDetailsView extends Backbone.View

  initialize: ->
    @template = this.options.template
    
  render: ->
    data = _.extend(this.model.toJSON(), {errors: this.model.errors})
    $(this.el).html(Mustache.render(@template, data))
    return this