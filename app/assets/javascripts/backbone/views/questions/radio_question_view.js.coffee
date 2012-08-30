SurveyBuilder.Views.Questions ||= {}

class SurveyBuilder.Views.Questions.RadioQuestionView extends Backbone.View

  events:
    'keyup': 'update_model_for_content'
    'change': 'update_model_for_mandatory'

  initialize: (model) ->
    this.model = model
    this.model.actual_view = this
    this.options = []
    this.model.on('add:options', this.add_new_option, this)

  render: ->
    template = $('#radio_question_template').html()
    $(this.el).html(Mustache.render(template, this.model.toJSON()))
    return this

  update_model_for_content: (event) ->
    input = $(event.target)
    this.model.set({content: input.val()})

  update_model_for_mandatory: (event) ->
    this.model.set({mandatory: $(event.target).is(':checked')})

  add_new_option: (model) ->
    option = new SurveyBuilder.Views.Questions.OptionView(model)
    this.options.push option
    $(this.el).append($(option.render().el))