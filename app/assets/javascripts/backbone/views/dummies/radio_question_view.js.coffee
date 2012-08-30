SurveyBuilder.Views.Dummies ||= {}

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

  render: ->
    template = $('#dummy_radio_question_template').html()
    $(this.el).html(Mustache.render(template, this.model.toJSON()))
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