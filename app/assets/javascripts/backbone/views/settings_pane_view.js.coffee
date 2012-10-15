# Collection of all questions' settings
class SurveyBuilder.Views.SettingsPaneView extends Backbone.View
  el: "#settings_pane"

  initialize: (survey_model) ->
    @questions = []
    @add_survey_details(survey_model)

  add_question: (type, model) ->
    switch type
      when 'SingleLineQuestion'
        template = $('#single_line_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'MultilineQuestion'
        template = $('#multiline_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'NumericQuestion'
        template = $('#numeric_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'DateQuestion'
        template = $('#date_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'RadioQuestion'
        template = $('#radio_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionWithOptionsView(model, template)
      when 'MultiChoiceQuestion'
        template = $('#multi_choice_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionWithOptionsView(model, template)
      when 'DropDownQuestion'
        template = $('#drop_down_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionWithOptionsView(model, template)
      when 'PhotoQuestion'
        template = $('#photo_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'RatingQuestion'
        template = $('#rating_question_template').html()
        question = new SurveyBuilder.Views.Questions.QuestionView(model, template)

    @questions.push(question)
    model.on('destroy', this.delete_question_view, this)
    $(this.el).append($(question.render().el))
    $(question.render().el).hide()

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