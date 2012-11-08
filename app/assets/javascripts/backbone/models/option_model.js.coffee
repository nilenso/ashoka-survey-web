# Interfaces between the views and the rails model for an option
class SurveyBuilder.Models.OptionModel extends Backbone.RelationalModel
  urlRoot: '/api/options'
  defaults: {
    content: 'untitled'
  }

  initialize: ->
    @sub_question_order_counter = 0
    @sub_question_models = []

  has_errors: ->
    !_.isEmpty(this.errors)

  save_model: ->
    this.save({}, {error: this.error_callback, success: this.success_callback})
    _.each @sub_question_models, (question) ->
      question.save_model()

  success_callback: (model, response) =>
    this.errors = []
    this.trigger('change:errors')

  error_callback: (model, response) =>
    this.errors = JSON.parse(response.responseText)
    this.trigger('change:errors')

  next_sub_question_order_number: ->
    @sub_question_order_counter++

  add_sub_question: (type) ->

    question = {
      type: type,
      parent_id: this.id,
      survey_id: this.get('question').get('survey_id'),
      order_number: @next_sub_question_order_number(),
      parent_question: this.get('question')
    };

    switch question.type
      when 'MultiChoiceQuestion'
        sub_question_model = new SurveyBuilder.Models.QuestionWithOptionsModel(question)
      when 'DropDownQuestion'
        sub_question_model = new SurveyBuilder.Models.QuestionWithOptionsModel(question)
      when 'RadioQuestion'
        sub_question_model = new SurveyBuilder.Models.QuestionWithOptionsModel(question)
      else
        sub_question_model = new SurveyBuilder.Models.QuestionModel(question)


    @sub_question_models.push sub_question_model
    sub_question_model.on('destroy', this.delete_sub_question, this)
    sub_question_model.save_model()
    this.trigger('add:sub_question', sub_question_model)

  delete_sub_question: (sub_question_model) ->
    @sub_question_models = _(@sub_question_models).without(sub_question_model)

  preload_sub_questions: ->
    _.each this.get('questions'), (question) =>
      _(question).extend({parent_question: this.get('question')})
      switch question.type
        when 'MultiChoiceQuestion'
          question_model = new SurveyBuilder.Models.QuestionWithOptionsModel(question)
        when 'DropDownQuestion'
          question_model = new SurveyBuilder.Models.QuestionWithOptionsModel(question)
        when 'RadioQuestion'
          question_model = new SurveyBuilder.Models.QuestionWithOptionsModel(question)
        else
          question_model = new SurveyBuilder.Models.QuestionModel(question)

      @sub_question_models.push question_model
      question_model.fetch()

    this.trigger('change:preload_sub_questions', @sub_question_models)
    @sub_question_order_counter = _(@sub_question_models).max (question) -> question.get('order_number')

SurveyBuilder.Models.OptionModel.setup()

# Collection of all options for radio question
class SurveyBuilder.Collections.OptionCollection extends Backbone.Collection
  model: SurveyBuilder.Models.OptionModel

  url: ->
    '/api/options?question_id=' + this.question.id

  has_errors: ->
    this.any((option) -> option.has_errors())
 
  preload_sub_questions: ->
    _.each this.models, (option_model) ->
      option_model.preload_sub_questions()
