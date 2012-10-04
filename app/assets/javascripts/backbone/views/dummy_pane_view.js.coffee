# Collection of dummy questions
class SurveyBuilder.Views.DummyPaneView extends Backbone.View
  el: "#dummy_pane"

  initialize: (survey_model) ->
    @questions = []
    @add_survey_details(survey_model)

  add_question: (type, model) ->
    switch type
      when 'SingleLineQuestion'
        template = $('#dummy_single_line_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionView(model, template))
      when 'MultilineQuestion'
        template = $('#dummy_multiline_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionView(model, template))
      when 'NumericQuestion'
        template = $('#dummy_numeric_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionView(model, template))
      when 'DateQuestion'
        template = $('#dummy_date_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionView(model, template))
      when 'RadioQuestion'
        template = $('#dummy_radio_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template))
      when 'MultiChoiceQuestion'
        template = $('#dummy_multi_choice_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template))
      when 'DropDownQuestion'
        template = $('#dummy_drop_down_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template))
      when 'PhotoQuestion'
        template = $('#dummy_photo_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionView(model, template))
      when 'RatingQuestion'
        template = $('#dummy_rating_question_template').html()
        @questions.push(new SurveyBuilder.Views.Dummies.QuestionView(model, template))

    model.on('destroy', this.delete_question_view, this)
    this.render()

  add_survey_details: (survey_model) ->
    template = $("#dummy_survey_details_template").html()
    @questions.push(new SurveyBuilder.Views.Dummies.SurveyDetailsView({ model: survey_model, template: template}))

  render: ->
    ($(this.el).append(question.render().el)) for question in @questions 
    return this

  unfocus_all: ->
    $(question.el).removeClass("active") for question in @questions

  delete_question_view: (model) ->
    question = _(@questions).find((question) -> question.model == model )
    @questions = _(@questions).without(question)
    question.remove()
    
