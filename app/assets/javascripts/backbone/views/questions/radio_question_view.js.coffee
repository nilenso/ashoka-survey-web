SurveyBuilder.Views.Questions ||= {}

class SurveyBuilder.Views.Questions.RadioQuestionView extends Backbone.View

  events:
    'keyup': 'update_model'

  initialize: (model) ->
    this.model = model
    this.options = []
    this.model.on('add:options', this.add_new_option, this)

  render: ->
    template = $('#radio_question_template').html()
    $(this.el).html(Mustache.render(template, this.model.toJSON()))
    return this

  update_model: (event) ->
    input = $(event.target)
    this.model.set({content: input.val()})

  add_new_option: (model) ->
    option = new SurveyBuilder.Views.Questions.OptionView(model)
    this.options.push option
    $(this.el).append($(option.render().el))