SurveyBuilder.Views.Questions ||= {}

# The settings of a single radio question in the DOM
class SurveyBuilder.Views.Questions.RadioQuestionView extends Backbone.View

  events:
    'keyup': 'update_model'
    'change': 'update_model'

  initialize: (model) ->
    this.model = model
    this.model.actual_view = this
    this.options = []
    this.model.on('add:options', this.add_new_option, this)

  render: ->
    template = $('#radio_question_template').html()
    $(this.el).html(Mustache.render(template, this.model.toJSON()))
    return this

  update_model: (event) ->
    input = $(event.target)

    propertyHash = {}
    if input.attr('name') == "mandatory"
      propertyHash[input.attr('name')] = input.is(':checked')
    else
      propertyHash[input.attr('name')] = input.val()
    this.model.set(propertyHash)

  add_new_option: (model) ->
    option = new SurveyBuilder.Views.Questions.OptionView(model)
    this.options.push option
    $(this.el).append($(option.render().el))