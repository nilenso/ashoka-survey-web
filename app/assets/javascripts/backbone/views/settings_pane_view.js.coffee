# Collection of all questions' settings
class SurveyBuilder.Views.SettingsPaneView extends Backbone.View
  el: "#settings_pane"

  events:
    'settings_pane_move': 'move'

  initialize: (survey_model) ->
    @questions = []
    @add_survey_details(survey_model)

  add_question: (type, model) ->
    view = SurveyBuilder.Views.QuestionFactory.settings_view_for(type, model)    
    @questions.push(view)
    model.on('destroy', this.delete_question_view, this)
    $(this.el).append($(view.render().el))
    $(view.render().el).hide()

  add_survey_details: (survey_model) ->
    template = $("#survey_details_template").html()
    question = new SurveyBuilder.Views.Questions.SurveyDetailsView({ model: survey_model, template: template })
    @questions.push(question)
    $(this.el).append($(question.render().el))
    $(question.render().el).hide()

  render: ->
    $(this.el).append($(question.render().el)) for question in @questions
    return this

  delete_question_view: (model) ->
    question = _(@questions).find((question) -> question.model == model )
    @questions = _(@questions).without(question)
    question.remove()

  hide_all: ->
    question.hide() for question in @questions

  move: ->
    yPosition = 0
    if $("div#dummy_pane div.active, div#dummy_survey_details div.active").length > 0
      activeElementPosition = $("div#dummy_pane div.active").offset().top
      containerPosition = $('#content').offset().top

      topMargin = (activeElementPosition - containerPosition - 150) + 'px';
      $("#settings_pane").css('margin-top', topMargin)
