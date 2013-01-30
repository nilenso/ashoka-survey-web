##= require ./question_model
# Interfaces between the views and the rails model for a radio question with a collection of options
class SurveyBuilder.Models.MultiRecordQuestionModel extends SurveyBuilder.Models.QuestionModel

  initialize: =>
    super
    @order_counter = 0
    @sub_question_order_counter = 0
    @sub_question_models = []

  save_model: =>
    super
    _(@sub_question_models).each (sub_question) =>
      sub_question.save_model()

  first_order_number: =>
    this.get('questions').first().get('order_number')

  get_order_counter: =>
    if this.get('questions').isEmpty()
      0
    else
      prev_order_counter = this.get('questions').last().get('order_number')
      prev_order_counter + 1

  fetch: =>
    super({success: =>
        @preload_sub_questions()
    })

  create_new_question: (content) =>
    content = "Another question" unless _(content).isString()
    this.get('questions').create({content: content, order_number: @order_counter++ })

  # get_first_option_value: =>
  #   this.get('questions').first().get('content')

  destroy_options: =>
    collection = this.get('questions')
    model.destroy() while model = collection.pop()

  has_sub_questions: =>
    this.get('questions').length > 0 || this.get('categories').length > 0

  preload_sub_questions: =>
    return unless @has_sub_questions()
    # TODO: Make this work for categories as well.  
    #elements = _((this.get('questions')).concat(this.get('categories'))).sortBy('order_number')
    elements = _(this.get('questions')).sortBy("order_number")
    _.each elements, (question, counter) =>
      parent_question = this.get('question')
      _(question).extend({parent_question: parent_question})

      question_model = SurveyBuilder.Views.QuestionFactory.model_for(question)

      @sub_question_models.push question_model
      question_model.on('destroy', this.delete_sub_question, this)
      #TODO
      #@set_question_number_for_sub_question(question_model)
      question_model.fetch()

    this.trigger('change:preload_sub_questions', @sub_question_models)
    @sub_question_order_counter = _(elements).last().order_number  

SurveyBuilder.Models.MultiRecordQuestionModel.setup()
