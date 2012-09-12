##= require ./question_model
# Interfaces between the views and the rails model for a radio question with a collection of options
class SurveyBuilder.Models.QuestionWithOptionsModel extends SurveyBuilder.Models.QuestionModel

  initialize: ->
    @order_counter = 0

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

  has_errors: ->
    !_.isEmpty(this.errors) || this.get('options').has_errors()

  #Can't have a blank radio question. Initialize with 3 radio options
  seed: ->
    unless this.seeded
      this.get('options').create({content: "First Option", order_number: ++@order_counter})
      this.get('options').create({content: "Second Option", order_number: ++@order_counter})
      this.get('options').create({content: "Third Option", order_number: ++@order_counter})
      this.seeded = true

  save_model: ->
    super
    this.get('options').each (option) ->
      option.save_model()

  success_callback: (model, response) =>
    this.seed()
    super

  create_new_option: ->
    this.get('options').create({content: "Another Option", order_number: ++@order_counter})

  has_drop_down_options: ->
    this.get('type') == "DropDownQuestion" && this.get('options').first()

  get_first_option_value: ->
    this.get('options').first().get('content')

SurveyBuilder.Models.QuestionWithOptionsModel.setup()