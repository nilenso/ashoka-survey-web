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
    _.each(this.options, (option) =>
        $(this.el).append(option.render().el)
      )
    return this


  update_model: ->
    input = $(this.el).find('input')
    this.model.set({content: input.val()})

  add_new_option: (model) ->
    this.options.push new SurveyBuilder.Views.Questions.OptionView(model)
    this.render()