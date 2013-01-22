##= require ./question_model
# Interfaces between the views and the rails model for a radio question with a collection of options
class SurveyBuilder.Models.MultiRecordQuestionModel extends SurveyBuilder.Models.QuestionModel

  initialize: =>
    super
    @order_counter = 0

  has_errors: =>
    !_.isEmpty(this.errors) || this.get('questions').has_errors()

  save_model: =>
    super
    this.get('questions').each (option) =>
      option.save_model()

  first_order_number: =>
    this.get('questions').first().get('order_number')

  get_order_counter: =>
    if this.get('questions').isEmpty()
      0
    else
      prev_order_counter = this.get('questions').last().get('order_number')
      prev_order_counter + 1

  fetch: =>
    super
    this.seeded = true

  success_callback: (model, response) =>
    console.log this.get('questions')
    super

  create_new_question: (content) =>
    content = "Another question" unless _(content).isString()
    this.get('questions').create({content: content, order_number: @order_counter++ })

  # get_first_option_value: =>
  #   this.get('questions').first().get('content')

  destroy_options: =>
    collection = this.get('questions')
    model.destroy() while model = collection.pop()

SurveyBuilder.Models.MultiRecordQuestionModel.setup()
