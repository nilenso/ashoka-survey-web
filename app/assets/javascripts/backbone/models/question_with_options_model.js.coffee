##= require ./question_model
# Interfaces between the views and the rails model for a radio question with a collection of options
class SurveyBuilder.Models.QuestionWithOptionsModel extends SurveyBuilder.Models.QuestionModel

  relations: [
    {
      type: Backbone.HasMany,
      key: 'options'
      includeInJSON: 'id'
      relatedModel: 'SurveyBuilder.Models.OptionModel'
      collectionType: 'SurveyBuilder.Collections.OptionCollection'
      reverseRelation: {
        key: 'question'
        keyDestination: 'question_id'
        includeInJSON: 'id'
      }
    }
  ]

  initialize: =>
    super
    @order_counter = 0

  has_errors: =>
    !_.isEmpty(this.errors) || this.get('options').has_errors()

  #Can't have a blank radio question. Initialize with 3 radio options
  seed: =>
    unless this.seeded
      this.create_new_option('First Option')
      this.create_new_option('Second Option')
      this.create_new_option('Third Option')
      this.seeded = true

  save_model: =>
    super
    this.get('options').each (option) =>
      option.save_model()

  fetch: =>
    super
    this.get('options').fetch
      success: (model, response) =>
        model.preload_sub_questions()
    this.seeded = true

  success_callback: (model, response) =>
    this.seed()
    super

  create_new_option: (content) =>
    content = "Another Option" unless _(content).isString()
    this.get('options').create({content: content, order_number: @order_counter++ })

  has_drop_down_options: =>
    this.get('type') == "DropDownQuestion" && this.get('options').first()

  get_first_option_value: =>
    this.get('options').first().get('content')

  destroy_options: =>
    collection = this.get('options')
    model.destroy() while model = collection.pop()

SurveyBuilder.Models.QuestionWithOptionsModel.setup()
