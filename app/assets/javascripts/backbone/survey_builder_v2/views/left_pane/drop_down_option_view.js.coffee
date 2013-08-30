##= require ./option_view

class SurveyBuilderV2.Views.LeftPane.DropDownOptionView extends SurveyBuilderV2.Views.LeftPane.OptionView
  tagName: "option"
  className: "question-option"

  initialize: (attributes) =>
    @model = attributes.model
    @template = "{{ content }}"

    super(attributes)

  render: =>
    this.$el.append(Mustache.render(@template, @model.attributes))
    this.$el.prop('disabled', true)
    return this
