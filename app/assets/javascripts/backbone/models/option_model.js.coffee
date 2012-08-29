class SurveyBuilder.Models.OptionModel extends Backbone.Model
  initialize: (content) ->
    this.set({content: (content || "untitled option")})

class SurveyBuilder.Collections.OptionsCollection extends Backbone.Collection
  model: SurveyBuilder.Models.OptionModel

  initialize: (question_id) ->
    base_url = window.location.pathname.replace('/build', '')
    this.url = "#{base_url}/questions/#{question_id}/options"
    this.add_initial_options()

  add_initial_options: ->
    this.add(new SurveyBuilder.Models.OptionModel('First option'))
    this.add(new SurveyBuilder.Models.OptionModel('Second option'))
    this.add(new SurveyBuilder.Models.OptionModel('Third option'))
