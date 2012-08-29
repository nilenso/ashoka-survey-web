class SurveyBuilder.Models.OptionModel extends Backbone.Model
  defaults: {
    content: 'untitled'
  }

  initialize: ->
    this.on('change:question_id', this.set_url, this)

  set_url: ->
    base_url = window.location.pathname.replace('/build', '')
    question_id = this.get('question_id')
    this.url = "#{base_url}/questions/#{question_id}/options"
    this.save()

