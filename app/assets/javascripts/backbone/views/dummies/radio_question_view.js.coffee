SurveyBuilder.Views.Dummies ||= {}

class SurveyBuilder.Views.Dummies.RadioQuestionView extends Backbone.View

  initialize: (model) ->
    this.model = model
    this.model.set
    this.model.on('change:id', this.add_collection, this) #Can't create options until we have question_id
    this.model.on('change', this.render, this)

  render: ->
    template = $('#dummy_radio_question_template').html()
    $(this.el).html(Mustache.render(template, this.model.toJSON()))

    if(this.options instanceof Array)
      _.each(this.options, (option) => 
        $(this.el).append(option.render().el)
        console.log($(option.render().el))
      )
    return this

  add_collection: ->
    this.model.off('change:id')
    this.options = []
    _.each(_.range(3), => 
      this.options.push new SurveyBuilder.Views.Dummies.OptionView(this.id)
    )
    this.render()