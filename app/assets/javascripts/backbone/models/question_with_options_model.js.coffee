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

  has_errors: =>
    !_.isEmpty(@errors) || @get('options').has_errors()

  #Can't have a blank radio question. Initialize with 3 radio options
  seed: =>
    return if @seeded
    @create_new_option('First Option')
    @create_new_option('Second Option')
    @seeded = true

  save_model: =>
    super
    @get('options').each (option) =>
      option.save_model()

  first_order_number: =>
    @get('options').first().get('order_number')

  get_order_counter: =>
    return 0 if @get('options').isEmpty()
    prev_order_counter = @get('options').last().get('order_number')
    prev_order_counter + 1

  preload_sub_elements: =>
    @trigger("preload_options", @get('options'))
    @get('options').each (option) =>
      option.preload_sub_elements()
    @seeded = true

  success_callback: (model, response) =>
    @seed()
    super

  create_new_option: (content) =>
    content = "Another Option" unless _(content).isString()
    @get('options').create({content: content, order_number: @get_order_counter(), question_id: @get('id') })

  has_drop_down_options: =>
    @get('type') == "DropDownQuestion" && @get('options').first()

  get_first_option_value: =>
    @get('options').first().get('content')

  destroy_options: =>
    collection = @get('options')
    model.destroy() while model = collection.pop()

SurveyBuilder.Models.QuestionWithOptionsModel.setup()
