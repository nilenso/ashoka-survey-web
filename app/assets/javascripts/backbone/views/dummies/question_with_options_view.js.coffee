##= require ./question_view
SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy radio question on the DOM
class SurveyBuilder.Views.Dummies.QuestionWithOptionsView extends SurveyBuilder.Views.Dummies.QuestionView

  events:
    "click": 'show_actual'

  initialize: (model, template) ->
    super
    this.options = []
    this.model.get('options').on('change', this.render, this)
    this.model.on('add:options', this.add_new_option, this)

  render: ->    
    super
    _.each(this.options, (option) =>
        $(this.el).append(option.render().el)
      )
    return this

  add_new_option: (model) ->
    this.options.push new SurveyBuilder.Views.Dummies.OptionView(model)
    this.render()
