SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy radio question on the DOM
class SurveyBuilder.Views.Dummies.RadioQuestionView extends Backbone.View

  events:
    "click": 'show_actual'

  initialize: (model) ->
    this.model = model
    this.model.dummy_view = this
    this.options = []
    this.model.on('change', this.render, this)
    this.model.get('options').on('change', this.render, this)
    this.model.on('add:options', this.add_new_option, this)
    this.model.on('change:errors', this.render, this)

  render: ->
    template = $('#dummy_radio_question_template').html()
    data = _.extend(this.model.toJSON(), {errors: this.model.errors})
    $(this.el).html(Mustache.render(template, data))
    $(this.el).find('abbr').show() if this.model.get('mandatory')
    _.each(this.options, (option) =>
        $(this.el).append(option.render().el)
      )
    return this

  add_new_option: (model) ->
    this.options.push new SurveyBuilder.Views.Dummies.OptionView(model)
    this.render()

  show_actual: (event) ->
    $(this.el).trigger("dummy_click")
    $(this.model.actual_view.el).show()