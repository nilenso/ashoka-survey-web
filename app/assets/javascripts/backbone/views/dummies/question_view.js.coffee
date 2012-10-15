SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy question on the DOM
class SurveyBuilder.Views.Dummies.QuestionView extends Backbone.View

  events:
    "click .delete_question": 'delete'

  initialize: (model, template) ->
    this.model = model
    this.template = template
    this.model.dummy_view = this
    this.model.on('change', this.render, this)
    this.model.on('change:errors', this.render, this)

  render: ->
    this.model.set('content', 'Untitled question') if _.isEmpty(this.model.get('content'))
    data = _.extend(this.model.toJSON().question, {errors: this.model.errors, image_url: this.model.get('image_url')})
    $(this.el).html('<div class="dummy_question_content">' + Mustache.render(this.template, data) + '</div>')
    $(this.el).addClass("dummy_question")
    $(this.el).find('abbr').show() if this.model.get('mandatory')
    $(this.el).find('.star').raty({
      readOnly: true,
      number: this.model.get('max_length') || 5  
    });

    $(this.el).children(".dummy_question_content").click (e) =>
      @show_actual(e)

    return this

  delete: ->
    this.model.destroy()

  show_actual: (event) ->
    $(this.el).trigger("dummy_click")
    $(this.model.actual_view.el).show()
    $(this.el).children('.dummy_question_content').addClass("active")

  unfocus: ->
    $(this.el).children('.dummy_question_content').removeClass("active")    