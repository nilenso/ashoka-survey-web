SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy question on the DOM
class SurveyBuilder.Views.Dummies.QuestionView extends Backbone.View

  events:
    "click": 'show_actual'
    "click .delete_question": 'delete'

  initialize: (model, template) ->
    this.model = model
    this.template = template
    this.model.dummy_view = this
    this.model.on('change', this.render, this)
    this.model.on('change:errors', this.render, this)

  render: ->
    this.model.set('content', 'Untitled question') if _.isEmpty(this.model.get('content'))
    data = _.extend(this.model.toJSON(), {errors: this.model.errors})
    $(this.el).html(Mustache.render(this.template, data))
    $(this.el).find('abbr').show() if this.model.get('mandatory')
    $(this.el).find('.star').raty({
      readOnly: true,
      number: this.model.get('max_length') || 5  
    });
    return this

  delete: ->
    this.model.destroy()
    $(this.el).trigger('dummy_question_view:delete')
    $(this.el).remove()


  show_actual: (event) ->
    $(this.el).trigger("dummy_click")
    $(this.model.actual_view.el).show()
    $(this.el).addClass("active")